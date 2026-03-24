---
name: setup-react-doctor
description: Install react-doctor for React codebase health scoring (performance, security, accessibility, dead code). Adds doctor script and Stop hook to fail on score regression. Use when setting up react-doctor, checking React health score, or preventing UI regressions.
---

# Setup React Doctor

## What This Sets Up

- **react-doctor** package for codebase health scoring (0-100)
- `doctor` package.json script
- `react-doctor.config.json` excluding redpanda-ui and disabling biome-overlapping rules
- **Stop hook** running doctor on changed files, failing on score drop

## Steps

### 1. Install

```bash
bun add -D react-doctor --yarn
```

### 2. Add package.json script

```json
{
  "scripts": {
    "doctor": "react-doctor ."
  }
}
```

### 3. Create `react-doctor.config.json`

```json
{
  "ignore": {
    "rules": [
      "react-hooks/exhaustive-deps",
      "react/no-nested-component"
    ],
    "files": [
      "redpanda-ui/**"
    ]
  }
}
```

### 4. Create Stop hook script

Write `react-doctor-stop.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 5. Configure Stop hook in `.claude/settings.json`

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/react-doctor-stop.sh" }
        ]
      }
    ]
  }
}
```

### 6. Verify & Commit

- [ ] `bun run doctor` works
- [ ] `react-doctor.config.json` exists
- [ ] Stop hook is executable

Commit: `Add react-doctor health scoring with Stop hook`
