# T3 Code and Effect skill snapshot

All 15 skills and every file inside their skill directories are copied unchanged
from [pingdotgg/t3code at 1451e7c](https://github.com/pingdotgg/t3code/tree/1451e7cb23034d29774338608368a15d8845df36).
The [lock](t3code-skills.lock.json) records full revision, file digests, executable
modes and the complete skill inventory. This is a skill snapshot, not a runnable
T3 or Effect checkout. The local [compatibility contract](../shared/T3CODE-SKILLS.md)
adapts it without editing upstream bytes.

## Sources and licenses

- Three project skills: `.agents/skills` in T3 Code. Retain the
  [T3 MIT license](t3code/LICENSE), copyright 2026 T3 Tools Inc.
- Twelve reference skills: `.repos/effect-smol/.agents/skills` in the same T3
  revision. T3's [reference configuration](https://github.com/pingdotgg/t3code/blob/1451e7cb23034d29774338608368a15d8845df36/scripts/lib/reference-repos.ts)
  identifies [Effect-TS/effect](https://github.com/Effect-TS/effect) as their origin.
  Retain the [Effect MIT license](t3code/.repos/effect-smol/LICENSE), copyright
  2023 Effectful Technologies Inc. The T3 commit pins these exact copied bytes;
  it is not a claim about Effect's current main branch.
- The snapshot also carries the contribution skill's directly linked T3 policy/support
  documents. Markdown originals retain a `.upstream` suffix; the readable copies
  rebase relative links to that same commit rather than importing the full app.
  They are historical reference, not authority for a live moderation run.
  Resolve current trusted policy as required by the compatibility contract.

T3-specific helper scripts and agent metadata are source evidence. Vendoring them
does not install a Browser panel, Device panel, server, mobile client or automation.

## Usefulness ranking

Marginal usefulness for this harness, judged by portability, missing coverage and
overlap with existing owners; not measured effectiveness or invocation frequency.
All 15 ship as requested. Rank guides selection, not availability.

| Rank | Skill | Why |
|---:|---|---|
| 1 | `ci-maintenance` | Dedicated Actions trust-boundary auditing. |
| 2 | `vendored-assets` | Provenance and reproducible imports fit this harness. |
| 3 | `test-development` | Adds compiler-contract testing to existing TDD. |
| 4 | `bundle-analysis` | Separates composition questions from size measurements. |
| 5 | `changesets` | Useful release-note discipline where Changesets exists. |
| 6 | `package-development` | Export, registration and dry-pack checks for libraries. |
| 7 | `performance-analysis` | Compiler-cost testing; runtime work overlaps current owners. |
| 8 | `dependency-maintenance` | Coordinated compatibility beyond a single upgrade. |
| 9 | `jsdocs` | Checked public-API examples, not another prose workflow. |
| 10 | `contribution-triage` | Reusable policy safeguards; moderation policy is repository-specific. |
| 11 | `test-t3-app` | Concrete verifier example requiring T3 Browser tools. |
| 12 | `test-t3-mobile` | Native isolation/pairing example requiring T3 Device tools. |
| 13 | `effect-development` | Useful pointer; overlaps installed-version Effect guidance. |
| 14 | `migration-guidance` | Effect's own generator, not application upgrades. |
| 15 | `ai-docs` | Effect's own generated-documentation pipeline. |

## Refresh

Use a separate T3 Git checkout containing the reviewed full commit. The importer
reads committed objects, not dirty working-tree files. It copies both complete
skill roots, licenses and directly linked policy documents; unknown skills require an
explicit host metadata/compatibility review before import.

```sh
python3 scripts/vendor-t3code-skills.py \
  --source /path/to/t3code \
  --revision 1451e7cb23034d29774338608368a15d8845df36
bash scripts/generate-skill-catalog.sh
python3 scripts/vendor-t3code-skills.py --check
bash evals/run.sh t3code-vendored-skills
bash evals/run.sh packaging-integrity
bun run lint:fix
bun run type:check
```

The importer owns `vendor/t3code`, its lock, `t3code-skills` adapters and their
Claude registrations. Catalog generation owns Codex proxies and router discovery.
The compatibility contract stays hand-maintained. Refresh refuses modified or
unmanaged output rather than overwriting local work. Do not refresh from inside
the managed snapshot. A clean repeated import must produce identical files.
