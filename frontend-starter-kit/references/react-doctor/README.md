# Setup React Doctor
- **react-doctor** codebase health score (0-100)
- Stop hook run doctor on changed files; failures, low scores, and warnings block
- No downgrade-to-allow loop; doctor errors are stop-gaps
- Config disable biome-overlapping rules

## Steps

### 1. Install
```bash
bun add -D react-doctor@2.2.6 --yarn   # PIN the version -- the tool moves fast and the Stop hook works around known bugs; upgrade deliberately, rerun transferred-rule fixtures after
```

### 2. Package.json
```json
{ "scripts": { "doctor": "react-doctor ." }, "devDependencies": { "react-doctor": "2.2.6" } }   // exact pin, not caret -- upgrade deliberately
```

### 3. Config (`react-doctor.config.json`)
```json
{ "ignore": { "rules": ["react-hooks/exhaustive-deps", "react/no-nested-component"] } }
```

### 4. Hook
Copy `scripts/react-doctor-stop.sh` -> `.claude/hooks/`. `chmod +x`. Add to Stop.

### 5. Verify
- [ ] `bun run doctor` work
- [ ] Stop hook executable
