---
title: "/stay-within-limits"
description: "Inspect Claude subscription-window evidence for an explicitly requested agent wave."
type: skill
sidebar:
  label: "/stay-within-limits"
---
![Diagram of the /stay-within-limits skill](/diagrams/skills/stay-within-limits.svg)

[Open the editable Excalidraw source](/diagrams/skills/stay-within-limits.excalidraw)

This explicit-use compatibility skill keeps the host-meter procedure. Model selection,
quality gates, and wave routing now belong to `/efficient-frontier` and
`config/model-routing.json`.

Use `select-review-profile.sh` only when the host exposes a fresh Claude Code quota
snapshot. `ccusage` is cost history, not subscription-capacity evidence. Missing or stale
evidence means Claude capacity is unknown; do not guess a reset time.

Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/stay-within-limits/REFERENCE.md) for snapshot capture and selector mechanics. Return the
observed windows and freshness, then let `/efficient-frontier` choose a quality-qualified
route. Explicit use never grants delegation permission.

In this repository, run `bash stay-within-limits/select-review-profile.sh`.
