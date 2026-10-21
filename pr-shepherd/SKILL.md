---
name: pr-shepherd
description: Shepherd changed pull requests with SHA-bound state and safe current-workspace repairs.
argument-hint: "[--limit <n>] [--dry-run]"
disable-model-invocation: true
---

Compatibility entry point for one sweep of your open PRs in the current repository.
Read and run [the batch procedure](REFERENCE.md); it owns snapshot, SHA-bound evidence,
workspace routing, repairs and reporting. No background polling or merge.

The primary author front door is `/work`; an explicit request there to maintain all your
open PRs uses the same procedure without another command.
