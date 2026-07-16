# Engineer A — PR craft & review taste (mined from the cloud monorepo)

Source: `gh` read-only against `the cloud monorepo`. Mined 2026-07-16.
Corpus: 400 merged PRs authored by `engineer-a` (the `--limit 400` cap was hit — there are more), all merged **2026-06-03 → 2026-07-16** (~6 weeks). Plus 62 inline review comments + 3 review summaries he left on **others'** PRs.

---

## 1. PR craft conventions

### Cadence & size — small, single-purpose, very high volume
- **400+ merged PRs in 32 active merge days = ~12.5 PRs/day.** Peak days: 31 (07-15), 30 (06-05), 29 (06-25). This is a fast trunk-style flow, not big-batch.
- **Size skews small**: median **299 lines** changed, median **9 files**. p25 = 85 lines, p75 = 849, p90 = 1726. 40% of PRs are under 200 lines; 16% under 50 lines. Large PRs exist but are the exception (p95 ≈ 3100; the 90k outlier is a generated/lockfile bump).
- One PR ≈ one intent. Multi-commit PRs still name each commit in the body (see "Commits" section below), but scope stays single-purpose.

### Title convention — strict conventional commits, scope always present
- `type(scope): lowercase description`. Type distribution: **fix 156, feat 147**, refactor 25, chore 20, build 13, test 12, perf 12, ci 8, style 1, revert 1. fix≈feat balance shows steady maintenance alongside features.
- **Scope is effectively mandatory** and names the app/package, not a layer. Top scopes: `adp-ui` (dominant — 112 feat + 110 fix + refactor/chore/test/perf/build), then `adp`, `aigw`, `cloud-ui`, `admin-ui`, `playground`, `llm-providers`, `proto`, `models`, `guardrails`, `markdown-editor`, `home`, `ui`.
- Descriptions are outcome-phrased and specific: "restore provider metric sparklines", "isolate agent cache by environment", "keep list columns naturally grouped", "make validation errors actionable", "dedupe unsaved changes confirmation". Rarely mechanical ("update X").
- A handful of older/release titles break convention ("ADP UI: …", "Release ADP UI to production") — the convention tightened over time.

### Body structure — a consistent, evidence-heavy template
Sampled bodies (28233, 28225, 28224, 28213, 28191, 28147, 28158, 28159, 28226, 28205, 28189, 28176, 28144, 28139, 28107). The recurring skeleton:

1. **`## Summary`** — 3–6 bullets, each a concrete behavioral change (not file lists). Bold key nouns. Always present.
2. **`## Why`** (or `## Scope`) — present on non-trivial PRs. Explains the product/security rationale and, crucially, **what is deliberately out of scope**. E.g. 28224: "gives users useful provider activity now without backend work and avoids presenting inferred transcripts as exact matches"; 28225: "keep backend-owned health … out of scope for a follow-up".
3. **`## Commits`** — lists each commit hash + subject when the PR is multi-commit.
4. **Visual evidence** — `## Screenshots / surface review` (before/after tables), `## Visual baselines` / `## Visual-regression baselines` (committed Linux light+dark PNGs linked from `__screenshots__`), or `## Visual recap` (agent-native interactive recap link). Explicitly covers **light/dark + loading/empty/error + responsive (wide/medium/mobile)** states.
5. **`## Reviewer guide`** — on larger PRs, a numbered "read these files in this order" map.
6. **`## Follow-up`** — names the next ticket/backend change needed (28224: "Expose `aigw.provider.name` as `provider_name` …").
7. **`## Test plan` / `## Verification`** — checkbox list, always includes `bun run lint:fix`, `bun run type:check`, unit + focused integration + browser (light AND dark) + often `bun run doctor:strict` (100/100) and E2E. Reports exact test counts ("3,417 passed"). Honestly notes environmental gaps ("No physical Windows host was available…", "unrelated suites failed because `globalThis.localStorage` was unavailable").
8. **`## Review`** — records **cross-model review outcome inline**: "Independent Claude Opus review: APPROVED. Fixed both P2 findings … Claude fix re-review: APPROVED." PRs are generated with Codex ("🤖 Generated with Codex").

**What the body explains vs leaves to the diff:** it explains *behavior, rationale, scope boundaries, and proof* — never restates code. Responsive behavior and state coverage go in prose/tables; implementation detail is left to the "Reviewer guide" pointers.

---

## 2. Review feedback taxonomy (comments Engineer A leaves on OTHERS' code)

**Format signature:** structured, agentic findings tagged **`[P0 Blocker]` / `[P1 Major]` / `[P2 Minor]` / `[P3 Patch]`** (also "Priority: P1" form), each with **What / Why / Suggested fix / One-shot prompt** sections. The "One-shot prompt" gives a ready-to-run agent instruction with exact branch, file, and the test command to verify — sometimes honestly "No safe one-shot" when the fix needs design. Lighter nits are one-liners. He reviews **both frontend and backend deeply** (heavy Go security review presence).

### A. Fail-closed / authorization boundaries (backend, but reveals his correctness bar)
- 27715: "**Fail closed when enabling SecretService before tenant authz** … Reject host-mode `console_secret_service.enabled` unless the per-request ADPEnvironment authorizer is configured."
- 27711: "keep stored SaaS rows admin-only or gated until the ADP-environment resource and bindings land."
- 27697: "Always reserve `/chat`; when chat is disabled … return 404/405 before the catch-all" (default-off flag didn't actually fail closed).

### B. Input validation & injection at trust boundaries
- 27870 (Cedar policy UI): "**Escape or reject Cedar string metacharacters** … user-controlled tag keys/values … can turn a forbid's `unless` clause into an always-true carve-out."
- 27711: "`multitenant_zone` only rejects `/` and `:` … `rdpa.co@evil.example` … URL parsers treat as host `evil.example`. Please validate a bare DNS hostname under the allowed the company-owned suffix."
- 27855: "Validate the normalized relay URL … `https://` become `https://https:` instead of failing fast. After adding the default scheme, parse with `URL`, require `http:`/`https:` plus a hostname."

### C. "The test doesn't prove what it claims" (tests must be real tripwires)
- 28047: "This test rejects admission because the byte budget is below the handler cap, so it **never decompresses a body** … Add gzip cases … decompressed size is exactly `maxRequestBytes` and `maxRequestBytes+1`."
- 28047: "no test requests a literal `/v1/traces` … it cannot prevent route drift that breaks stock exporters."
- 27700: "regression table … only samples some of the handlers … omits `/debug/pprof/cmdline` … make the helper accept method/body so `POST` … returns 404."
- 27838: "add a browser/integration regression that switches environments while a mounted resource read is hung and proves the selector remains usable." (Prove the responsiveness claim, don't assert an adjacent proxy.)

### D. Boundary / off-by-one / retroactive-validation correctness
- 27713: "**aggregate MCP cap runs on the full merged spec for every managed update, so a pre-existing agent already over 32 references is bricked** for all future edits — even edits that don't touch MCP servers … grandfather existing rows … Keep the strict cap on Create." (Watches for migrations that brick existing data.)
- 28047: "A map at the configured limit therefore passes and is produced over limit (256 becomes 261 …). Stamp before final context validation … test the exact limit."

### E. Prefer platform / library primitives over hand-rolled code (FRONTEND)
- 28090: "we can use **`chrono-node`** … will solve all the weird timezone/time issues in javascript"; "**date-fns** would help a lot here."
- 26379: "brand icons — I think we can get this either from **lucide, or simple icons**, or from some branding marketing site" (don't hand-draw brand SVGs).
- 27870: "I think we should just **accept a rest operator as props so we extend a native react type** … cover all edge cases instead of manually adding each."

### F. Project React/test conventions enforced verbatim (FRONTEND)
- 27870: "**name the focus effect callback** … project React rules require named `useEffect` callbacks for debuggability."
- 27870: "**Let React Compiler handle this memo** … remove `useMemo`/`useCallback` unless there is a concrete need."
- 27870: "**Use per-test `userEvent.setup()`** … shared/default user-event state can make timing more fragile."
- 27870: "I think we can just use a **const**? I don't know why we need a function here." (Prefers the simplest construct.)

### G. Styling discipline — registry/shadcn fidelity, tokens, Tailwind over custom CSS (FRONTEND)
- 27830: "can we do the fix directly in the custom component affected … so that **`globals.css` is relatively close to original shadcn setup**? … I think we could just rely on **tailwind** here instead of … custom CSS utility/class."
- 27830: "We should use **`cnfast`/`cn`** for classnames" (repeated: "Cnfast").
- 27830: "I think we can use better way with **minmax**" (CSS grid sizing).

### H. Frontend performance — scope observers/work, no fixed sleeps (FRONTEND)
- 27830: "**Scope the resize observer to flex mode** … all tables instantiate a `ResizeObserver` … pushes synchronous resize work into unrelated tables … Attach the ref/observer only when `flexMode` is true, guard missing `ResizeObserver`."
- 27830: "**Replace fixed sleeps in resize tests** … `ResizeObserver` delivery can vary under CI load … Use `vi.waitFor`/Testing Library `waitFor` to poll the actual condition."
- 27697 (CORS): "browser chat responses can contain multiple `Access-Control-Allow-Origin` values … let the existing top-level CORS policy be the single owner."

### I. Push work to the server / single source of truth (FRONTEND↔API)
- 25350: "Would be great if it could be another **rpc or some server side filter**."
- 25350: "previously we had left a margin of ± 5% … is that still included in the calculation somewhere? **Ideally in the backend** (and then frontend just formats it to Mbps etc)."
- 27697: "`dataplane_adp_chat_invoke` is added to the built-in roles, but the **resource-aware action catalog was not updated** … update the schema fixture, and pin grouping/picker expectations."

### J. Product/UX judgement in approvals
- 27862 (APPROVED to unblock): "I would like to stick to (1) `*` for required field indicator instead of text like optional/mandatory (2) use up more screen real estate? … consistent width or use entire space on ultrawide monitors."
- 28090: "nit: could use enums but it's ok like this too." (Grades severity; lets minor things pass.)
- 27482: "this is doing a lot of things … I am ok with this change but ideally we just add a **deprecation notice** … maybe add a TODO to remove this after Aug 3rd." (Time-boxes tech debt with a concrete date.)

### K. Curiosity / scope-probing questions (his default opening move)
Many comments are questions that surface hidden requirements rather than demands: "is this to get arm/amd64 or sth?" (25350), "is this just to avoid spamming API before user fills out the form?" (25350), "Do we also need a global time period that encapsulates entire billing period?" (26630), "do we support xor? or any other logic gates?" (27870), "Do we port over secrets? How would we move them over?" (27715), "shall we split by read and write [permissions]?" (26379).

---

## 3. What this refines beyond what diffs show

- **Process is evidence-first.** Diffs show the code; the PR bodies show he treats a change as unproven until it has light+dark visual baselines, all-states coverage (loading/empty/error/responsive), exact test counts, `doctor:strict` 100/100, AND an independent cross-model (Claude Opus) review recorded in the body. Green CI alone is never the bar.
- **Cross-model review is standard, not occasional.** Own-PR bodies routinely embed "Independent Claude Opus review: APPROVED / fixed P2 findings / re-review APPROVED." He applies the same P0–P3 + What/Why/Fix/One-shot rubric when reviewing others.
- **He reviews far outside the frontend.** A large share of his sharpest findings are Go backend security/correctness (OTLP DoS amplification, authz fail-closed, injection, retryable error classification). Diffs would peg him as an adp-ui frontend dev; his review footprint is full-stack with a security lens.
- **Scope discipline is explicit and forward-looking.** Bodies name out-of-scope items and file `## Follow-up` pointers; reviews time-box debt with dates and ask for tracked follow-ups rather than blocking. He optimizes for shipping small increments while keeping the boundary honest.
- **Severity is graded, not binary.** He distinguishes P0 blockers (OOM, always-true policy carve-out) from P2/P3 nits (name a callback, drop a `useMemo`) and will approve-to-unblock while listing non-blocking preferences.
- **Recurring frontend "house style" he enforces on others:** named `useEffect` callbacks, no manual memo (React Compiler), `userEvent.setup()` per test, `waitFor` over fixed sleeps, `cn`/`cnfast` for classnames, Tailwind + design tokens over custom CSS, keep `globals.css` close to stock shadcn, extend native React types via rest props, use `date-fns`/`chrono-node`/`lucide`/`simple-icons` instead of hand-rolling, and push filtering/computation to the backend.
