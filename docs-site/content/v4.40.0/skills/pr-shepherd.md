---
description: "Shepherd changed pull requests with SHA-bound state and safe current-workspace repairs."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["pr shepherd"]}
sidebar: {"label":"/pr-shepherd"}
title: "/pr-shepherd"
type: "skill"
---
![Diagram of the /pr-shepherd skill](/diagrams/skills/pr-shepherd.svg)

[Open the editable Excalidraw source](/diagrams/skills/pr-shepherd.excalidraw)


Compatibility entry point for one sweep of your open PRs in the current repository.
Read and run [the batch procedure](https://github.com/malinskibeniamin/skills/blob/v4.40.0/pr-shepherd/REFERENCE.md); it owns snapshot, SHA-bound evidence,
workspace routing, repairs and reporting. No background polling or merge.

The primary author front door is `/work`; an explicit request there to maintain all your
open PRs uses the same procedure without another command.
