---
title: "/stay-within-limits"
description: "Inspect Claude subscription-window evidence for an explicitly requested agent wave."
type: skill
sidebar:
  label: "/stay-within-limits"
---
![Diagram of the /stay-within-limits skill](/diagrams/skills/stay-within-limits.svg)

[Open the editable Excalidraw source](/diagrams/skills/stay-within-limits.excalidraw)


explicit-use compatibility skill. Model quality/routing belongs to `/efficient-frontier` and `config/model-routing.json`; explicit delegation is still required.

Use `select-review-profile.sh` only with a fresh Claude Code host quota snapshot. `ccusage` is cost history, not subscription evidence. Missing/stale evidence means Claude capacity is unknown; do not guess reset time.

[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/stay-within-limits/REFERENCE.md) owns capture/selection. Report observed windows/freshness; then `/efficient-frontier` chooses a qualified route. Invocation never grants delegation.

Run `bash stay-within-limits/select-review-profile.sh`.
