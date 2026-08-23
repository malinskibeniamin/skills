---
name: video-research
description: Ingest video URLs, video attachments, or local files into timestamped transcripts, OCR, and research-ready artifacts. Use when researching, summarizing, quoting, or extracting evidence from video.
---

Turn video into searchable evidence. Start immediately when the user supplied it as a source.

## Ingest

1. Resolve accessible URL/absolute attachment path. Use only authorized media; ask before browser cookies or another auth boundary.
2. Use untracked `.context/video-research/<slug>/` when ignored, else temporary output.
3. From the absolute skill directory run:

```bash
bash <skill-dir>/scripts/analyze-video.sh \
  --output-dir <untracked-output-dir> \
  <video-url-or-path>
```

It prefers captions, then local Whisper, samples frames, OCRs text, and writes `analysis.json`, `transcript.txt`, `research.md`. One-shot tools are pinned; first run may download a local model. Report progress; never add runtimes to target dependencies.

Optional: `--language <code>`, difficult audio `--model medium`, non-English visuals `--ocr-language <codes>`. Transcription is local by default. Cloud transcription uploads audio and may cost money, so requires explicit approval.

## Research

Read `research.md`, then `analysis.json` and frames. ASR/OCR are derived: verify important wording at timestamp/frame before quoting. Combine transcript, on-screen text, visuals, description, chapters, and linked primary sources.

Durable multi-source work uses `/research`; cite the original video with timecodes, not generated transcript as an independent source.

## Failure

Surface all warnings. A missing transcript from unavailable speech backend is failure: install runtime in scratch cache and rerun. Distinguish genuinely silent video and use OCR/frames. For private, removed, DRM, or inaccessible media, report boundary and request an accessible file; never bypass it.
