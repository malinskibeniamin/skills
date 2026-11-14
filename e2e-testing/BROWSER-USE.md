# Browser Use experiments (opt-in)

Keep the [default E2E tools](SKILL.md#evidence-and-tools). Evaluate Browser Use for custom
extraction or interactions only when the user opts in and the host permits it.
Project-local verifiers and host-mandated browser tools take precedence; a missing
required tool stays blocked, not a fallback.

Before authorized setup, read the current [upstream README](https://github.com/browser-use/browser-use)
and [migration/trust model](https://github.com/browser-use/browser-use/blob/main/MIGRATING.md).
For an existing coding agent, evaluate the CLI integration; use the Python library when
the requested work needs its own agent loop.

- Setup: pin the reviewed release exactly (`browser-use==<reviewed-version>`) in an
  isolated Python environment. This guidance authorizes no installation or skill registration.
- Browser: use a fresh dedicated profile, not a personal profile or its copy. Confirm the
  local/cloud target before starting: the library's `Browser()` defaults to cloud;
  `Browser('chromium')` starts a fresh local browser. Cloud use needs authorization for
  data transfer and spend. Generated Python is not sandboxed; isolate untrusted tasks in
  a container or VM.
- Evidence: repeat representative tasks against the current workflow with the same
  model, effort, browser environment and starting state. Record versions, verified
  completion, failures/manual recovery, total cost including retries and browser charges,
  and elapsed time. Vendor benchmarks do not establish a local improvement; retain the
  defaults unless the comparison demonstrates a useful gain without regressions.
