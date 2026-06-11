# Deslop Reference

## Surface-area budget

Treat each addition as production liability:

- Runtime path: can fail, slow down, leak, or confuse.
- API/export: becomes a contract to support.
- Dependency/config: expands upgrade and outage surface.
- Test helper/mock: can hide real behavior or harden implementation details.
- Hook/rule: can block good work or create noisy false positives.

`/deslop` composes with `/simplify`: run `/simplify` first for general cleanup, then question whether the remaining diff deserves to be owned.

## Keep rules

Keep when the addition does at least one:

1. **Product value** -- user-visible capability, clearer workflow, saved time, or removed pain.
2. **Defensive correctness** -- prevents a plausible outage, data loss, security issue, bad state, or support burden.
3. **Test confidence** -- proves behavior, regression, edge case, or release safety without coupling to implementation.

Short form: Keep when product value, defensive correctness, or test confidence is proven.

If none apply, delete it. If unsure, ask for the value claim or split the diff.

## Review passes

1. **Scope** -- Does every changed file trace to the ask?
2. **Shape** -- Can a branch, option, abstraction, helper, or file disappear?
3. **Reuse** -- Is extraction backed by two real call sites? If not, inline.
4. **State** -- Can one source of truth replace mirrored state or flags?
5. **Errors** -- Are unhappy paths visible and tested, not swallowed?
6. **Tests** -- Do tests fail for the right reason and protect behavior?
7. **Cost** -- Would you be comfortable owning this during an incident?

## Block examples

- New wrapper component only changes names around an existing component.
- Utility used once with no clear semantic boundary.
- Happy-path feature without regression or edge-case test.
- Broad config/dependency change to solve a one-line local problem.
- Defensive-looking fallback that hides errors instead of surfacing them.

## Output template

```markdown
Verdict: APPROVED | NEEDS_CHANGES

Kept
- `<path>`: value/defense/test reason.

Delete or inline
- `<path:line>`: reason, smallest replacement.

Verification
- `<command>`: pass/fail summary.
```
