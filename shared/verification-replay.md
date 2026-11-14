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

## Browser and data tasks

Choose the assertion's seam. HTTP/data tasks may use the project API client or a reviewed
saved flow; HTTP success is not UI evidence. UI changes require fresh real-browser
navigation/actions, visible assertions and console/network inspection after the last UI edit.

Honor user/host browser requirements and the project verifier. When choice is permitted,
consider agent-browser for interactive automation instead of playwright-cli or browser MCP:
compact snapshots/refs help inspection, but required auth, device and session capabilities win.
Preserve the project CI runner; Playwright Test owns its assertions, isolation, traces,
retries and cross-browser coverage, not the interactive CLI.
Measure comparable runs before claiming speed, token or memory savings.

### Saved data flows

Use for repeated, allowlisted reads, not as a UI-test shortcut. Check `agent-browser --version`,
`flow --help` support and the current [upstream contract](https://github.com/vercel-labs/agent-browser/blob/v0.43.0/docs/content/docs/network.mdx#saved-flows)
before use; saved flows are experimental in 0.43.0.

- Set `AGENT_BROWSER_FLOWS_DIR` to isolated temporary storage. In a task-owned session,
  start `--capture flow open` at blank, then `open <url>`; use synthetic data.
  Close only your session; never attach a human profile or auto-connect.
- Inspect `flow steps --json`, then `flow save <name> --from <seq> --to <seq> --output <id>`.
  Review saved requests, params and replayed actions; allowlisted reads must be safe by
  semantics, not just HTTP method. Run without `--allow-write`; stop on write confirmation.
- Treat artifacts as sensitive: URLs, bodies and params can contain secrets or PII despite
  redaction. Keep them out of commits, shared caches, uploads and logs; clean up scratch.
  Credential headers are omitted; bearer/signed APIs may need UI, not saved token copies.
- Reuse with `flow run <name> --param k=v --fields field1,field2 --limit <n>`.
  Require `success: true`, `data.ok: true`, `data.verified: true`, no `drift` and absent/false
  `confirmation_required`; exit zero alone can mean confirmation, not execution. Stop rather than approve
  writes. Re-capture drifted flows through the UI rather than weakening assertions.
- Record actual transport `data.steps[].tier` and `fellBack`, plus mocked versus live data.
  Runs try HTTP, in-page requests, then command replay; 0.43.0 has no HTTP-only/no-fallback
  switch. Browserless success is possible, not guaranteed. A replay is not a UI assertion.
  A direct-HTTP fast-path claim requires nonempty `data.steps`, every required step
  `tier: http`, no per-step `fellBack`, and independent live-backend evidence. HTTP tiers
  can serve route mocks without a backend request.

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
