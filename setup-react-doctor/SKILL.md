---
name: setup-react-doctor
description: React health scoring via react-doctor with Stop hook to fail on score regression. Use when setting up react-doctor or preventing UI quality regressions.
---

# Setup React Doctor

- **react-doctor** for codebase health scoring (0-100)
- Stop hook runs doctor on changed files, fails on score drop
- Config disables biome-overlapping rules

## Steps

### 1. Install
```bash
bun add -D react-doctor --yarn
```

### 2. Package.json
```json
{ "scripts": { "doctor": "react-doctor ." } }
```

### 3. Config (`react-doctor.config.json`)
```json
{ "ignore": { "rules": ["react-hooks/exhaustive-deps", "react/no-nested-component"] } }
```

### 4. Hook
Copy `scripts/react-doctor-stop.sh` -> `.claude/hooks/`. `chmod +x`. Add to Stop.

### 5. Verify
- [ ] `bun run doctor` works
- [ ] Stop hook executable
