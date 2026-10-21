# Anti-slop checks

Use [dmmulroy/anti-slop](https://github.com/dmmulroy/anti-slop) for low-evidence
TypeScript/JavaScript audits or explicitly requested setup. Its rules are opinionated;
project contracts and demonstrated defects decide adoption, not the upstream label.
Its AST/lexical-scope analysis is partial evidence, not type-checker or cross-file proof.

## Review evidence, not appearances

- **Preserve type evidence:** inspect chained assertions (`no-chained-type-assertions`)
  and widening known values before casting them back (`no-widen-then-assert`). Keep
  inference or use `satisfies`; parse genuinely unknown input at its trust boundary.
- **Justify necessary assertions:** prefer a typed API, schema, or guard. When an assertion
  remains necessary, identify the invariant and where it was established. Upstream's
  `require-safety-comment-for-type-assertion` checks for an explanation, not its truth.
- **Check transformations:** review growing reducer accumulator copies and eager array
  pipelines. Before rewriting, preserve receiver semantics, callback order/indexes, sparse
  arrays, and truthiness. Omitted object properties are not equivalent to explicit
  `undefined`. Measure performance claims; fewer passes alone do not prove a speedup.
- **Keep policy local:** upstream bans on runtime `typeof`, broad `unknown` contracts,
  module mocks, or symbol names are not universal defects. Preserve legitimate boundary
  validation and test seams; report only concrete contract/risk violations.

## Requested integration only

Upstream ships a vendorable Oxlint plugin, not an official npm package. Inspect its
[installation skill](https://github.com/dmmulroy/anti-slop/tree/main/skills/install-anti-slop)
and source at the chosen revision before copying. Preserve provenance, MIT notices,
existing config, and local customizations; match exact Oxlint/`@oxlint/plugins` versions.
Select rules against invalid and valid cases through the actual lint command; use Effect
rules only for an applicable Effect project. Its installer enables all generic rules, so
do not run it merely to add these review principles or silently replace Biome.
