# Podcast-derived improvements

Checked 2026-10-14 against the [publisher RSS](https://anchor.fm/s/1112097e0/podcast/rss)
and original public YouTube captions for the latest five releases. About 11 hours of
captions reach the recording ends; longer contextual passages were read, not every minute
manually viewed. Names/speakers may be mistranscribed. These are paraphrases and our local
adaptations, not quotations or endorsements. Those historical research passages
are separate from the now-vendored tstack skills documented below.

| Episode / primary passage | Actionable lesson | Local implementation |
|---|---|---|
| [October 12, 10:00](https://www.youtube.com/watch?v=ESq3ostvznQ&t=600s), [34:50](https://www.youtube.com/watch?v=ESq3ostvznQ&t=2090s) | Deterministic wake-ups; Sol loop fixes **or rejects** findings; full stop retains merge decision | Existing auto-review controller; read-only hosted checker; opt-in composition and no-merge example in REFERENCE |
| [September 30, 1:37:00](https://www.youtube.com/watch?v=4zMgyhXeGig&t=5820s), [1:55:00](https://www.youtube.com/watch?v=4zMgyhXeGig&t=6900s) | Restore debug state after repair; notify essential human decisions; recognize plateaus | Shared replay/progress contracts; explicit blocker notification; checker lifecycle tests |
| [September 19, 38:20](https://www.youtube.com/watch?v=gNgvYiOEXiw&t=2300s), [1:42:30](https://www.youtube.com/watch?v=gNgvYiOEXiw&t=6150s) | Act/decline/ask requires judgment; self-authored evidence can mislead | Finding disposition ledger; controller-owned trial oracle, never a worker success paragraph |
| [September 10, 57:30](https://www.youtube.com/watch?v=nHrf-83nJ7Y&t=3450s), [1:17:00](https://www.youtube.com/watch?v=nHrf-83nJ7Y&t=4620s), [1:46:00](https://www.youtube.com/watch?v=nHrf-83nJ7Y&t=6360s) | Optimization must preserve features; takeover can adapt/discard; repair failing tooling | Feature-fidelity guardrails; revert/source provenance; progress ledger and supported-tool recovery |
| [September 3, 30:20](https://www.youtube.com/watch?v=j2fG-zH6vgk&t=1820s), [48:30](https://www.youtube.com/watch?v=j2fG-zH6vgk&t=2910s), [1:46:25](https://www.youtube.com/watch?v=j2fG-zH6vgk&t=6385s) | Preserve endpoint across resumes; local/pushed/merged are distinct; never substitute identity | Endpoint checkpoint; independently observed git/hosted state; notification boundary |

The trust-boundary inference also draws on [METR's investigation](https://metr.org/blog/2026-08-26-openai-hugging-face-incident-investigation/),
which documents unsanctioned coordination and transcript/tool-call spoofing with stated
analysis limitations. It does not validate every podcast claim. Our deterministic CLI tests
prove the checker, not autonomous skill adherence; model trials remain explicitly opt-in.

The earlier [Podcast Rex summary](https://podcastrex.com/shows/nerd-snipe-with-theo-and-ben/opus-55-is-the-best-model-ever-made-grok-47-exists-gpt-6-sol-luna-impress-and-why-jev-isnt-the-solution-to-everything)
was a secondary discovery lead, now superseded by these primary-caption passages.
The bounded [T3 Code directory search](https://github.com/pingdotgg/t3code/tree/main/.agents/skills)
found contribution-triage, test-t3-app and test-t3-mobile, not canonical full-send/Sol-loop
files at that time. Canonical sources are now available in the
[pinned tstack snapshot](../vendor/tstack-NOTICE.md), composed through
[host compatibility](../shared/TSTACK.md); the earlier absence is superseded.
[test-t3-app](https://github.com/pingdotgg/t3code/blob/main/.agents/skills/test-t3-app/SKILL.md)
and [test-t3-mobile](https://github.com/pingdotgg/t3code/blob/main/.agents/skills/test-t3-mobile/SKILL.md)
reinforce operational, isolated verification with meaningful fixtures and actual pairing state.

Excluded: blanket test deletion, guessed confidence percentages, model rankings, speculative
cache/pricing changes, secret scavenging, permission expansion, arbitrary cron agents and
reviewer self-approval. Preserve TDD, routing, ownership and protected merge authorization.
