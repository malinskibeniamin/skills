# Setup React Doctor

- **react-doctor** owns deterministic React diagnostics that overlap shell hooks
- Stop scans changed and untracked React files; warnings and errors block
- Score upload and score ratchets are disabled: unlike diagnostics, scores from
  different changed-file sets are not comparable
- Browser-app opt-ins and all design rules are active in `doctor.config.json`
- `biome-overlapping` rules remain disabled

## Steps

### 1. Install

```bash
bun add -D --exact react-doctor@0.9.2
```

Pin the npm version. React Doctor moves quickly; upgrade deliberately and rerun
the transferred-rule fixtures.

### 2. Package.json

```json
{
  "scripts": {
    "doctor": "react-doctor .",
    "doctor:full": "react-doctor . --scope full --blocking none",
    "doctor:design": "react-doctor design"
  },
  "devDependencies": {
    "react-doctor": "0.9.2"
  }
}
```

### 3. Config

Copy [`doctor.config.json`](doctor.config.json) to the project root.

The config:

- preserves former hard-hook ownership as `error`
- enables all 112 released design rules
- enables every applicable browser correctness, accessibility, React, and
  maintainability opt-in
- blocks warning and error diagnostics on changed scope
- excludes the complete React Native family by tag
- disables `exhaustive-deps` and nested-component diagnostics already owned by
  Biome/Ultracite
- keeps only eight proven project conflicts and three terminal-only opt-ins off

Category severity does not activate opt-in rules. Keep every intended opt-in
rule listed explicitly.

### 4. Hook

Copy `scripts/react-doctor-stop.sh` to `.claude/hooks/`, make it executable, and
add it to Stop. Keep the adapter even if React Doctor installs a native agent
hook: the adapter provides the same fail-closed contract across harness hosts.

### 5. Verify

```bash
bun run doctor:full
bun run doctor -- --scope changed --include-untracked --blocking warning --no-score
bun run doctor:design
```

- [ ] the advisory full-project scan completes, including dead-code analysis
- [ ] changed and untracked fixtures are scanned
- [ ] configured warnings and errors exit non-zero
- [ ] missing or failed React Doctor blocks Stop
