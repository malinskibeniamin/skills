# Phase boundaries

A **phase** is a coherent slice of work inside one session, such as discovery,
implementation, or verification. Choose how to cross into the next phase only at the
boundary. Mid-phase, keep the reasoning together unless a real blocker forces a stop.

## Ordered decision

Take the first branch that applies:

1. **Continue.** Stay in the current session when the next phase needs this phase as a
   primary source and the host reports enough capacity. Continuing loses no reasoning.
2. **Start fresh.** Clear or open a new session when the current context is irrelevant to
   the next phase. Use the host's clear command only when it supports one.
3. **Handoff.** Use `/handoff` when context must travel to another harness, repository,
   directory, colleague, or side task. Portability is the reason to write a handoff file.
4. **Delegate when authorized.** Delegation requires an explicit request for subagents,
   delegation, parallel agent work, or `/swarm`. Without delegation consent, keep the work
   inline in the primary context.
5. **Compact.** Otherwise use the host's supported compaction or automatic context
   management. Preserve the next phase's goal, settled decisions, evidence, and open risks.

Do not invent a token threshold, quota, or reset time. Use a host meter when available;
otherwise report capacity as unknown and prefer the most reversible branch.
