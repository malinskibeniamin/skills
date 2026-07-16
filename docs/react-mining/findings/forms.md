# Forms & Validation — Mined Patterns (Engineer A, 2022-08 → 2026-07)

Theme: react-hook-form, zod, proto-driven forms, field-level errors, submit UX.
Corpus: 4,050 commits; ~389 form/validation-adjacent. Repo read-only at `~/Documents/git/cloudv2`.

## Timeline of the form stack (the spine of every pattern below)

- **2022 (cloud-ui)**: Chakra UI + Formik. `708a0e0` (2022-09-14 "Fix Form to support Chakra components"), `0fe5333` (2022-09-14 "Fix InputField for Chakra + Formik").
- **2023-01**: Migrate to **react-hook-form**; delete the bespoke `<Form>`. `06fc4b3` (2023-01-27 "admin-ui: Use React Hook Form"), `9031b8c` (2023-01-26 "Remove old Form component"). admin-ui also drops Chakra's `FormControl`/`FormErrorMessage` (`0589222`, 2022-10-26).
- **2023-2025**: RHF + hand-written validation, `formatToastErrorMessageGRPC` (`116bdad`, 2023-12-08) for API errors, zod arriving for route search.
- **2026-03 (adp-console)**: **useProtoForm** born — RHF resolver driven by `buf.validate` proto annotations via protovalidate-es; **zod deleted from form bodies**.
- **2026-04 (adp-ui)**: "AutoForm overhaul" — generic `ProtoField`, `setServerErrors`, `FormErrorSummary`, protovalidate for cross-field CEL, `form.watch`→`useWatch`, standardized required indicators.
- **2026-06/07**: `useProtoForm` chosen over `AutoForm` for bespoke forms; proto-driven help; requirement-indicator standardization finalized.

Canonical current files:
- Hook: `apps/adp-ui/src/components/registry-ui/lib/use-proto-form.ts`
- Exemplar consumer: `apps/adp-ui/src/components/secret-store/secret-form.tsx`
- Field chrome: `apps/adp-ui/src/components/molecules/create-field.tsx`
- Error summary: `apps/adp-ui/src/components/registry-ui/components/form-error-summary.tsx`

---

## Pattern 1 — Proto-schema-driven validation via `useProtoForm`, not hand-written zod resolvers

**Practice.** Forms whose data maps to a protobuf message use `useProtoForm(Schema, { defaultValues, mode })`, a thin `useForm` wrapper whose `resolver` is `createProtoResolver(schema)`. Validation rules come from `buf.validate` annotations on the `.proto` (the same source the backend enforces), so client and server agree by construction and there is no second schema to drift. The hook builds a proto message from the plain RHF values, runs protovalidate-es Standard Schema, and maps `issue.path` → RHF field errors. WHY: a hand-maintained zod schema duplicates every constraint already declared in proto and silently diverges from backend truth.

**Anti-pattern.** `useForm({ resolver: zodResolver(editSchema) })` with a manually authored zod object mirroring proto `required`/pattern/length constraints.

**Evidence.**
- `5617f07` (2026-03-30) — introduces `useProtoForm()`; migrates remote MCP edit off `zodResolver(editSchema)` to `useProtoForm(RemoteMCPConfigSchema)`; url/transport validation now from proto source of truth.
- `0b5b7d6` (2026-03-30) — "migrate all forms to useProtoForm, eliminate Zod validation."
- `a978fa1` (2026-06-03) — "build guardrail create form with useProtoForm instead of AutoForm" (proto-form chosen even over the generic AutoForm engine for bespoke layouts).

**Evolution.** zodResolver (2026-03 and earlier) → useProtoForm proto resolver (2026-03) → useProtoForm is now the default for any proto-backed form. Note: mixed-schema forms (fields from >1 message) were the last zod holdouts (`5617f07` describes this explicitly).

**Enforcement — exemplar + skill.** Exemplar: `use-proto-form.ts`. Skill wording: "A form backed by a protobuf message uses `useProtoForm(Schema, …)`. Do not write a `zodResolver` that restates proto `buf.validate` constraints — the proto is the single source of validation truth. zod is for route search params only (Pattern 9)."

---

## Pattern 2 — Never native-`disabled` the submit on `!isValid`; keep it actionable so errors surface (CONTRADICTS "disabled submit needs Tooltip")

**Practice.** A submit button must never be `disabled={!form.formState.isValid}`. A user staring at a dead grey button gets no explanation, and `FormErrorSummary` only renders once `submitCount >= 1` — which a native-disabled button can never trigger. Two accepted shapes: (a) **fully clickable** `disabled={isPending}` — the submit runs, validation fails, and `FormErrorSummary` surfaces the offending fields (the secret-form and most create pages); or (b) **soft-disabled** `CreateSubmitButton` — `aria-disabled` + swallowed clicks + `pointer-events-auto opacity-50` + a tooltip, so it stays focusable/hoverable and the tooltip can show. WHY: `disabled` kills hover/focus/click, so the very affordance that would explain the block is unreachable.

**Anti-pattern.** `<Button disabled={!isValid || isPending}>` on a create/edit form. Also: gating on `isValid` where `isValid` is stale (mode `all`/mount races) so the button never enables even on a valid form.

**Evidence.**
- `c8ecec8` (2026-04-20) — "surface offending fields in a click-to-focus validation banner"; flips five submit buttons from `disabled={!isValid || isPending}` to `disabled={isPending}` and adds `FormErrorSummary`.
- `2a48a29` (2026-06-04) — "keep guardrail create submit clickable so errors surface"; the button gated on `!isValid` so an incomplete form left a dead button with no guidance (validation pipeline was correct; the gate was the defect).
- `af067a7` (2026-06-05) "guard guardrail create wizard against premature submit"; `73d94...`/`d925374` (2026-07-14) "standardize requirement indicators" replaces the native-disabled + "Fill in all required fields" tooltip with the `CreateSubmitButton` soft-disable + "Complete the form to continue."

**Evolution.** Early: `disabled={!isValid}` (dead button). 2026-04: fully clickable + FormErrorSummary. 2026-07: for sticky-footer create pages, a `CreateSubmitButton` that soft-disables (aria-disabled + tooltip) rather than natively disabling. Both current forms keep the control interactive.

**Refines ALREADY-ENCODED "disabled submit needs Tooltip".** The 2026 code deliberately stopped natively disabling submit at all. The correct rule is: **do not use `disabled={!isValid}`**; either keep clickable so errors surface, or soft-disable via `aria-disabled` (never the native attribute) so a tooltip remains reachable.

**Enforcement — hook.** Detection: in `*.tsx`, a `<Button>`/submit whose `disabled=` expression references `isValid` / `formState.isValid` / `!...Valid`. Flag: "Do not native-disable submit on validity. Keep it clickable (surface errors via FormErrorSummary) or use CreateSubmitButton's aria-disabled + tooltip." Low false-positive: only fire when `disabled` prop textually contains `isValid`/`Valid`.

---

## Pattern 3 — Schema-driven backend error surfacing: `setServerErrors` maps `FieldViolation`s onto fields by descriptor walk (not a toast-only catch)

**Practice.** On mutation failure, call `form.setServerErrors(error)`. It walks the proto descriptor to convert each `BadRequest.FieldViolation` (snake_case server path, oneof branches flattened under `{oneofLocalName}.value`) into a per-field `form.setError(..., { type: 'server' }, { shouldFocus })`, focusing the first. It also extracts every other `google.rpc.*` detail (LocalizedMessage, Help, ErrorInfo, RequestInfo, RetryInfo, DebugInfo, PreconditionFailure, QuotaFailure, ResourceInfo) into `form.serverErrorContext` for the summary. It returns `{ handled, unmapped, context }`; the caller toasts **only** the `unmapped` violations / non-field errors. No per-form mapping table. WHY: backend field-level errors used to vanish into a generic toast; this puts them on the exact field and gives the summary a request ID + help link.

**Anti-pattern.** `catch (e) { toast.error(formatConnectError(e)) }` — field violations discarded, user cannot tell which field the server rejected.

**Evidence.**
- `4e0835a` (2026-04-22) — "schema-driven backend error surfacing on forms"; introduces `setServerErrors`, `serverErrorContext`, descriptor snake→camel via `DescField.localName`.
- `3d34365` (2026-04-09) — "improve form error handling with proto-driven validation."
- `334ed51` (2026-04-21) — "surface OAuth Provider validation error inline + in toast label" (inline first, toast as fallback label).
- `749ffe0` (2026-07-06) — "structural error frames, wire gRPC formatter" (PR review hardening of the same pipeline).

**Evolution.** `formatToastErrorMessageGRPC` toast-only (`116bdad`, 2023-12) → inline + toast (`334ed51`) → descriptor-walk auto-mapping + context object (`4e0835a`), the current standard.

**Enforcement — exemplar + skill.** Exemplar: `secret-form.tsx` `handleServerError` (`if (!result.handled || result.unmapped.length > 0) toast.error(...)`). Skill: "In a proto-form onError/catch, call `form.setServerErrors(error)` and only toast `unmapped`/non-field violations. Never discard `FieldViolation` details into a generic toast." (Refines ALREADY-ENCODED "ConnectError fieldViolations → form.setError" with the automated descriptor-walk + serverErrorContext.)

---

## Pattern 4 — oneof and message construction without casts: `createMessage`, `setOneofValue`, `getNestedErrors`, `FlattenProtoOneofs`

**Practice.** `useProtoForm` returns cast-free helpers so route/form files carry **zero** `as never`/`as Values` casts: `createMessage(values?)` builds the typed proto in the submit handler; `setOneofValue(path, case, value)` switches a oneof branch (clearing the previous branch, `shouldDirty` + `shouldValidate` by default); `getNestedErrors(path)` drills oneof error trees (`configErrors.apiKeyRef` instead of `configErrors?.value?.apiKeyRef`). The `FormShape = FlattenProtoOneofs<MessageShape<Desc>>` type flattens oneofs so `register('config.value.apiKey')` and `Path<T>` compile. WHY: raw RHF + protobuf-es oneofs otherwise force `as never` at every setValue/error access, which defeats type safety and hides real path bugs.

**Anti-pattern.** `form.setValue('providerConfig', { case, value } as never)`; `(errors.config as any).value.apiKeyRef`; `MessageShape` type aliases sprinkled to appease the compiler.

**Evidence.**
- `2df7301` (2026-03-31) — "use createMessage/setOneofValue/getNestedErrors, drop @autoform deps"; "Zero type casts remain in route form files."
- `40061841` (2026-03-30) — "add FlattenProtoOneofs type to resolve oneof paths in forms."
- `2d131c7` (2026-04-15) — "make ProtoField generic to eliminate any."

**Evolution.** `as never` everywhere (pre-2026-03) → helper trio + `FlattenProtoOneofs` (2026-03) → generic `ProtoField` (2026-04). Current: casts in form files are a smell.

**Enforcement — hook + exemplar.** Hook: flag `as never` / `as any` inside `*.tsx` files that import `useProtoForm` or `react-hook-form` (matches the CLAUDE.md "no `as any`/`as never`" rule, scoped to form files with an actionable message pointing at `setOneofValue`/`getNestedErrors`/`createMessage`). Exemplar: `use-proto-form.ts`. (Refines ALREADY-ENCODED "oneof clears previous on switch" + "form.setValue shouldDirty+shouldValidate" — both are now the built-in `setOneofValue` behavior.)

---

## Pattern 5 — Standardized requirement indicators: red asterisk via `RequiredIndicator`, never "(optional)"/"(required)" text in labels or descriptions

**Practice.** Field requirement is signalled **only** by the shared `RequiredIndicator` asterisk rendered by `CreateField` when `requirement="required"`; optional fields carry no marker. Labels and descriptions must not contain "(optional)", "(required)", or "required fields" prose. `aria-required` is set on the control, and the asterisk sits before the help affordance. WHY: mixed conventions (some fields with "(optional)" text, some with asterisks, some with nothing) read as inconsistent and clutter labels; one visual + one ARIA signal is enough.

**Anti-pattern.** `<span className="text-muted-foreground">(optional)</span>` inside a label; `desc="A name and an optional note…"`; a tooltip that lists "required fields" in prose.

**Evidence.**
- `6cea403` (2026-04-20) — "consistent required-field indicators across create forms" (introduces `RequiredIndicator`, `RequiredProtoField`).
- `4e1f94c` (2026-04-21) — "asterisk-before-help, auto-fit grid" (ordering).
- `d925374` (2026-07-14) — "standardize requirement indicators"; strips "(optional)"/"(required)" text from labels, descriptions, and tooltips across LLM-provider, agent, secret, OAuth forms; tests assert `queryByText(/optional/i)` / `/required fields/i)` is absent.
- `b66297f` (2026-07-13) — "restore required field asterisks" (regression guard: the asterisk must be present).

**Evolution.** "(optional)" text spans (2023-2026-04) → `RequiredIndicator` asterisk + `aria-required` (2026-04) → all requirement-in-prose removed, asterisk-only (2026-07).

**Enforcement — hook + exemplar.** Hook: in form/create `*.tsx`, flag string literals matching `/\((optional|required)\)/i` or `/required fields/i` inside JSX label/description/`desc=`/`help=` positions. Exemplar: `create-field.tsx` (`requirement?: 'required' | 'optional'` → `<RequiredIndicator/>`).

---

## Pattern 6 — Run protovalidate client-side before submit for forms *outside* useProtoForm (cross-field CEL)

**Practice.** Forms that keep some fields in separate `useState` atoms (so the `useProtoForm` resolver only sees a slice) must still validate the fully-built message with `createValidator()`/protovalidate against its schema before submit, mapping message-level CEL violations onto a `_form` key surfaced through the existing field-error pipeline. WHY: cross-field CEL rules (e.g. `user_delegated_requires_user_oauth`) never fire if the resolver only sees a partial message, so an avoidable backend `InvalidArgument` round-trip is the only feedback.

**Anti-pattern.** Building the request from scattered state and submitting without re-validating the whole message; relying on the backend to reject cross-field violations.

**Evidence.**
- `f79006d` (2026-04-20) — "validate MCPServerCreate cross-field CEL rules client-side"; adds `validateMCPServerCreate()` on the fully-built message.
- `ac72a1b` (2026-04-20) — "run protovalidate on MCP auth config before submit."
- `678f264` (2026-04-20) — "extend protovalidate coverage to every non-useProtoForm mutation."

**Evolution.** Backend-only cross-field validation → client-side protovalidate on the assembled message for every non-useProtoForm mutation (2026-04). The strategic direction (Pattern 1/4) is to eliminate these split-state forms so the resolver sees the whole message.

**Enforcement — skill.** "If a form keeps proto fields in separate `useState` (not all in `useProtoForm`), run `createValidator(Schema)` on the assembled message before submit and surface violations inline. Better: put all fields in `useProtoForm` so cross-field CEL validates automatically." (Reinforces the ALREADY-ENCODED "useProtoForm owns state, no parallel useState<*Config>".)

---

## Pattern 7 — zod is for route search-param validation, not form bodies

**Practice.** After proto took over form-body validation, zod's remaining job is `validateSearch` on TanStack routes: `const searchSchema = z.object({ tab: z.enum(VALID_TABS).catch('overview') })`. WHY: search params are untrusted URL strings with no proto schema; zod with `.catch()` gives a typed, self-healing default. This is a clean division of labor — proto for message bodies, zod for URL state.

**Anti-pattern.** zod resolver on a proto-backed form (Pattern 1); or, conversely, hand-parsing `search.tab` with no schema and no fallback.

**Evidence.**
- `bc38b51` (2026-05-21) — "use zod for route search validation."
- `1e3b779` (2026-05-21) — "validate governance search with zod."
- `3d09be5` (2026-04-09) — "persist tab state in URL search params with zod validation."
- `a93d017` (2026-02-06, cloud-ui) — "add validateSearch for search schema."

**Evolution.** zod-for-forms (pre-2026-03) → zod removed from forms, retained for `validateSearch` (2026 onward).

**Enforcement — skill.** "zod belongs in route `validateSearch` (with `.catch()` defaults), not in form resolvers. Form bodies validate via `useProtoForm`." (Ties into tanstack-router skill.)

---

## Pattern 8 — Strip empty/whitespace repeated-string entries on submit; opt out only via a proto annotation

**Practice.** The payload converter drops empty and whitespace-only entries from repeated scalar-string fields before submit (mirroring the existing map-key filter). Fields where an empty entry is meaningful opt out via an `allow_empty_items` `field_ui` annotation. The UI also shows a muted hint ("An empty pattern has no effect") so a blank row is never silent. WHY: an "Add" control seeds a blank row; serialized verbatim as `[""]`, a blank guardrail regex compiled to match-everything and blocked every query — a data-integrity bug, not cosmetic.

**Anti-pattern.** Serializing repeated-string arrays verbatim, shipping `[""]`; or globally trimming fields where an empty item is semantically meaningful (e.g. a text-chunker separator meaning "split by characters").

**Evidence.**
- `6a43265` (2026-06-29) — "drop empty entries from repeated string form fields"; introduces the filter, the `allow_empty_items` opt-out, and the RegexField empty-pattern hint.

**Evolution.** New defensive-correctness convention (2026-06). Supporting: `fee0790` (2026-06-01) "hide autoform unset sentinel"; `8b77a24` (2026-05-29) "prune dangling subagent mcp_servers at edit-tab submit" — same family of "don't submit meaningless empties."

**Enforcement — exemplar.** Exemplar: `apps/adp-ui/src/lib/proto-form-empty-list-entries.unit.test.ts` (+ its impl). Skill note: "Repeated scalar-string form fields drop empty/whitespace entries on submit unless the proto field carries `allow_empty_items`."

---

## Pattern 9 — Form mode is `onChange`; the `all`/mount-trigger detour caused silent submit failures (refines ALREADY-ENCODED mode:onChange)

**Practice.** `useProtoForm` defaults `mode: 'onChange'`. WHY documented by its own history: the first hook used `mode: 'all'` + a mount `trigger()` to make `isValid` fresh, but combined with an `isValid`-gated disabled submit this produced **silent submission failures** — `handleSubmit` blocked on validation errors that were never displayed. The fix moved to `onBlur`, then the pipeline settled on `onChange` with the mount `trigger()` removed and submit no longer disabled on validity (Pattern 2).

**Anti-pattern.** `mode: 'all'` with a mount `trigger()` and an `isValid`-disabled submit — the three together silently swallow submits.

**Evidence.**
- `3e148d9` (2026-04-01) — "fix silent form submission failures"; changes mode `'all'`→`'onBlur'` on all forms and adds an error callback to every `handleSubmit` (toast the first error).
- Original hook (`5617f07`, 2026-03-30) shipped `mode: 'all'` + `useEffect(() => trigger())`; current `use-proto-form.ts` defaults `mode = 'onChange'` and has removed the mount trigger.

**Evolution.** `all` + mount-trigger (2026-03) → `onBlur` (2026-04-01, silent-failure fix) → `onChange` default, no mount-trigger, submit not validity-disabled (current).

**Enforcement — skill (refinement only).** Keep the ALREADY-ENCODED "form mode onChange only" and add the WHY: "Never combine `mode: 'all'` + mount `trigger()` + `isValid`-disabled submit — it silently swallows submits." No new hook needed; Pattern 2's hook covers the disabled-submit half.

---

## Summary table

| # | Pattern | Enforcement | Strongest SHA |
|---|---------|-------------|---------------|
| 1 | useProtoForm proto-validation over hand-written zod | exemplar + skill | `5617f07` (2026-03-30) |
| 2 | Never native-disable submit on !isValid; keep actionable | hook | `c8ecec8` (2026-04-20) |
| 3 | setServerErrors maps FieldViolations to fields (descriptor walk) | exemplar + skill | `4e0835a` (2026-04-22) |
| 4 | Cast-free oneof: createMessage/setOneofValue/getNestedErrors/FlattenProtoOneofs | hook + exemplar | `2df7301` (2026-03-31) |
| 5 | Standardized required asterisk, no "(optional)" text | hook + exemplar | `d925374` (2026-07-14) |
| 6 | Client-side protovalidate for non-useProtoForm cross-field CEL | skill | `f79006d` (2026-04-20) |
| 7 | zod only for route validateSearch, not form bodies | skill | `bc38b51` (2026-05-21) |
| 8 | Drop empty repeated-string entries on submit (allow_empty_items opt-out) | exemplar | `6a43265` (2026-06-29) |
| 9 | mode:onChange; the all+mount-trigger detour caused silent failures | skill (refine) | `3e148d9` (2026-04-01) |

**Contradiction flagged:** ALREADY-ENCODED "disabled submit needs Tooltip" is superseded — 2026 code stopped natively disabling submit. Rule is now: never `disabled={!isValid}`; keep clickable (errors surface via FormErrorSummary) or soft-disable via `aria-disabled` + tooltip (`CreateSubmitButton`), never the native `disabled` attribute.
