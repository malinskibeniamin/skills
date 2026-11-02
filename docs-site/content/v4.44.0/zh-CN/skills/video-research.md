---
title: /video-research
description: 将视频 URL、视频附件或本地文件转换为带时间戳的转录文本、OCR 结果和可直接用于研究的资料。适用于研究、总结、引用视频或从视频中提取证据。
type: skill
sidebar:
  label: /video-research
---
![／video-research 技能示意图](/diagrams/skills/video-research.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/video-research.excalidraw)

在研究视频中的论述之前，先将视频转化为可搜索的证据。如果用户已经提供视频作为研究资料，则直接开始，无需再次确认。

## 导入

1. 将来源解析为可访问的 URL 或本地附件的绝对路径。仅使用用户有权访问的媒体；在读取浏览器 Cookie 或跨越其他身份验证边界之前，须请求批准。
2. 选择一个不受版本控制跟踪的输出目录。如果 `.context` 已被 Git 忽略，优先使用 `.context/video-research/<slug>/`；否则让脚本创建临时目录。
3. 从此技能的绝对目录运行附带的入口脚本：

```bash
bash <skill-dir>/scripts/analyze-video.sh \
  --output-dir <untracked-output-dir> \
  <video-url-or-path>
```

该入口脚本会优先使用原生字幕，然后使用本地 Whisper，采样关键帧，对屏幕文字执行 OCR，并写入 `analysis.json`、`transcript.txt` 和 `research.md`。它会固定其一次性工具的版本，并可能在首次使用时下载本地模型。及时向用户告知相关进度；不要将这些运行时添加到目标项目的依赖文件中。

已知语言时传入 `--language <code>`，音频较难识别时传入 `--model medium`，视觉文字不是英语时传入 `--ocr-language <codes>`。默认仅在本地进行转录。云端转录服务会上传音频且可能产生费用，因此必须获得明确批准才能使用。

## 研究

先阅读 `research.md`，然后检查 `analysis.json` 和其中引用的帧以了解上下文。将 ASR 和 OCR 视为衍生证据：引用重要表述前，应根据其时间戳和对应帧进行核验。综合利用转录文本、屏幕文字、视觉内容、描述、章节和链接的第一手来源；仅靠语音可能会遗漏视频的核心证据。

通过 `/research` 整理需要长期保留的多来源研究结果，引用原始视频并标注时间码，不要将生成的转录文本作为独立来源引用。

## 失败处理约定

显示分析器发出的所有警告。因语音处理后端不可用而缺少转录文本属于失败，而不是空内容：在临时缓存中安装缺失的运行时，然后重新运行。应将这种情况与视频确实无声区分开来；对于无声视频，使用 OCR 和帧进行分析。对于私有、已删除、受 DRM 保护或无法访问的媒体，应说明访问限制并请求提供可访问的文件；不要绕过限制。
