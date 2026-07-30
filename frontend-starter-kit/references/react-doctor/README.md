# Setup React Doctor

- **react-doctor** owns deterministic React diagnostics that overlap shell hooks
- Stop scans changed and untracked React files; error diagnostics block
- Score upload and score ratchets are disabled: unlike diagnostics, scores from
  different changed-file sets are not comparable
- Opt-in design rules are explicitly classified in `doctor.config.json`
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
- enables 24 deterministic design rules as blocking errors
- enables 50 contextual design rules as non-blocking warnings
- leaves 30 subjective rules to the focused `react-doctor design` review
- explicitly disables 8 brand-taste rules
- disables `exhaustive-deps` and nested-component diagnostics already owned by
  Biome/Ultracite

Category severity does not activate opt-in rules. Keep every intended opt-in
rule listed explicitly.

### 4. Hook

Copy `scripts/react-doctor-stop.sh` to `.claude/hooks/`, make it executable, and
add it to Stop. Keep the adapter even if React Doctor installs a native agent
hook: the adapter provides the same fail-closed contract across harness hosts.

### 5. Verify

```bash
bun run doctor -- --scope changed --include-untracked --blocking error --no-score
bun run doctor:design
```

- [ ] changed and untracked fixtures are scanned
- [ ] a configured error exits non-zero
- [ ] configured warnings remain advisory
- [ ] missing or failed React Doctor blocks Stop
