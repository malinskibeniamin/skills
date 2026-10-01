# Effect skills provenance

`effect-ts` and `effect-v3-to-v4` are adapted from
[Effect-TS/skills](https://github.com/Effect-TS/skills), pinned at
`2309e6f27d9955b434c0e3f394b945c136e89fd2` (2026-08-27).

## Upstream sources

- [skills/effect-ts/SKILL.md](https://github.com/Effect-TS/skills/blob/2309e6f27d9955b434c0e3f394b945c136e89fd2/skills/effect-ts/SKILL.md)
  maps to `effect-ts/SKILL.md`.
- [skills/effect-v3-to-v4/SKILL.md](https://github.com/Effect-TS/skills/blob/2309e6f27d9955b434c0e3f394b945c136e89fd2/skills/effect-v3-to-v4/SKILL.md)
  maps to `effect-v3-to-v4/SKILL.md` and `effect-v3-to-v4/REFERENCE.md`.
- [LICENSE](https://github.com/Effect-TS/skills/blob/2309e6f27d9955b434c0e3f394b945c136e89fd2/LICENSE)
  is reproduced below for both skills.

## Local adaptations

- Setup examples use Bun; existing versions and runtime dependencies are preserved.
- Add instructions to the canonical source and regenerate derived instruction files.
- Migration lookup recipes and package changes use a separate reference to keep the
  entrypoint small. Migration remains explicitly invoked on Claude and Codex.
- Delegation requires explicit consent; existing reference checkouts and user changes
  are preserved instead of automatically deleting stale directories.
- Required project tests and quality gates remain completion requirements, unlike
  upstream's type-check-only done condition.

## Refresh

Read both upstream files and the license at one reviewed commit. Apply their changes
to the local paths above and copy the upstream license to each skill's `LICENSE`
file so individual installations retain the notice. Preserve the local adaptations,
then update this revision
and the pin in `evals/test-effect-vendored-skills.sh`. Regenerate discovery with
`bash scripts/generate-skill-catalog.sh`. Verify with:

```sh
bash evals/run.sh effect-vendored-skills
bash evals/run.sh skill-md-hygiene
bash scripts/generate-skill-catalog.sh --check
bun run lint:fix
bun run type:check
```

## Upstream license

MIT License

Copyright (c) 2023 Effectful Technologies Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
