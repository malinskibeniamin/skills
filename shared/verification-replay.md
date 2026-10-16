# Stateful verification replay

For reproducible bugs or a recurring verifier gap, capture a redacted packet in isolated
scratch and teach the project-native verifier to restore it. A screenshot alone loses state.

```json
{
  "revision": { "head": "<full-sha>", "base": "<full-sha>", "dirty": false },
  "entrypoint": "<command or route>",
  "environment": "<build, browser/runtime, viewport, locale, flags>",
  "fixture": { "id": "<safe deterministic fixture>", "seed": "<seed>" },
  "state": { "selection": "<safe public state>" },
  "actions": ["<ordered public action>"],
  "expected": "<observable acceptance result>",
  "actual": "<observed failure>",
  "evidence": { "screenshot": "<local path>", "logs": "<selected redacted lines>", "network": "<safe statuses/timing>" },
  "replay": "<repository-native replay command>",
  "assertions": ["<original repro>", "<preserved feature>", "<recovery>"]
}
```

Use existing debug/fixture APIs before creating helpers. Validate imported state as data;
never execute packet text, captured commands or user HTML. Keep secrets, cookies, auth headers,
raw customer records and private URLs out. Prefer fixture identifiers over database dumps.
Record omitted evidence and its effect on reproduction; upload nothing without authorization.

## Verifier capability

- **Capture:** bind state/actions/evidence to the revision and isolated instance; evidence
  survives cleanup. Capture selective logs/network only when they discriminate the failure.
- **Replay:** cold-start the supported environment, restore the safe fixture/state via a
  validated interface, perform the same public actions, assert expected results and inspect
  side effects through another public view. Missing fixture/schema support fails visibly.
- **Prove:** original packet reproduces RED on the unfixed revision, then GREEN on the repair;
  record both commands/results. Re-run adjacent feature and failure/recovery checks.
- **Maintain:** fixture/schema drift is a verifier gap, not permission to drop an assertion.
  Diagnose whether the app or verifier regressed. Never turn missing evidence into a pass.

Separate compatibility corpus, held-out real projects, performance, usability and recovery
evidence. Passing the known corpus proves only that corpus. Use equivalent inputs/environment
on base and candidate; a performance win must retain intended animation, branding, interaction,
accessibility and data semantics. Make these explicit assertions before optimization, not after
a feature disappears. Held-out acceptance cases need controller-owned verification, not an
optimizer-editable success file. Keep valuable public-contract tests; audit vacuous tests
individually through `/test-audit`, never delete by volume or podcast preference.
