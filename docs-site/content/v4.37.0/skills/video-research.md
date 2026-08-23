---
title: "/video-research"
description: "Ingest video URLs, video attachments, or local files into timestamped transcripts, OCR, and research-ready artifacts. Use when researching, summarizing, quoting, or extracting evidence from video."
type: skill
sidebar:
  label: "/video-research"
---
![Diagram of the /video-research skill](/diagrams/skills/video-research.svg)

[Open the editable Excalidraw source](/diagrams/skills/video-research.excalidraw)

Turn video into searchable evidence before researching its claims. Start without a
confirmation round when the user already supplied the video as a research source.

## Ingest

1. Resolve the source to an accessible URL or absolute local attachment path. Use only
   media the user may access; request approval before reading browser cookies or crossing
   another authentication boundary.
2. Choose an untracked output directory. Prefer `.context/video-research/<slug>/` when
   `.context` is gitignored; otherwise let the script create a temporary directory.
3. Run the bundled entrypoint from this skill's absolute directory:

```bash
bash <skill-dir>/scripts/analyze-video.sh \
  --output-dir <untracked-output-dir> \
  <video-url-or-path>
```

The entrypoint prefers native captions, then uses local Whisper, samples key frames,
runs OCR for on-screen text, and writes `analysis.json`, `transcript.txt`, and
`research.md`. It pins its one-shot tools and may download a local model on first use.
Keep the user informed about that progress; do not add those runtimes to the target
project's dependency files.

Pass `--language <code>` when known, `--model medium` for difficult audio, or
`--ocr-language <codes>` for non-English visual text. Transcription is local-only by
default. A cloud transcription service requires explicit approval because it uploads
the audio and can incur cost.

## Research

Read `research.md` first, then inspect `analysis.json` and referenced frames for context.
Treat ASR and OCR as derived evidence: verify important wording against its timestamp
and frame before quoting it. Combine transcript, on-screen text, visuals, description,
chapters, and linked primary sources; speech alone may omit the video's core evidence.

Route durable multi-source findings back through `/research`, citing the original video
with timecodes rather than citing the generated transcript as an independent source.

## Failure contract

Surface every analyzer warning. A missing transcript caused by an unavailable speech
backend is a failure, not empty content: install the missing runtime in a scratch cache
and rerun. Distinguish that from a genuinely silent video, then use OCR and frames. For
private, removed, DRM-protected, or inaccessible media, report the access boundary and
ask for an accessible file; do not bypass it.
