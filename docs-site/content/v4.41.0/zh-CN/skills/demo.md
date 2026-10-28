---
description: 创建面向客户的功能演示，并将其发布到草稿 PR 中。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - demo
sidebar:
  label: /demo
title: /demo
type: skill
---
![描述 /demo 技能的示意图](/diagrams/skills/demo.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/demo.excalidraw)

将已完成的工作转化为面向客户的成果证明。阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/REFERENCE.md)。

## 约定 [#contract]

1. 确定目标范围；默认覆盖当前整个分支或 PR 自 merge-base 以来的内容，包括已提交、已暂存、未暂存及相关的未跟踪工作。
2. 选择最有力的可见收益，讲述一个简短的“问题 -> 操作 -> 结果”故事。
3. 将源文件和输出保存在 `demos/<slug>/` 下；更新时复用此目录，不要分散媒体文件。
4. 优先录制：使用真实的浏览器录屏，以及 asciinema `.cast` 终端回放。遵循[录制与旁白步骤](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/RECORDING.md)。终端回放不是 MP4 文件。
5. 影片交付为 `output/demo.mp4`；分章节演示交付为 `output/index.html` 及其资源。混合浏览器与终端的演示使用[演示模板](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/templates/walkthrough.html)。标明解释性或模拟材料；它们不是录制的产品证据。
6. 需要在真实录屏周围添加合成内容时，复用 HyperFrames；若源内容由现有 Remotion 项目管理，则保留该项目。不要只为录屏而安装第二个渲染器。
7. 确保演示在静音时仍可理解。仅在用户要求或源材料需要时添加旁白；将旁白与录制操作对齐，保留字幕/文字稿，并通过试听验证。云端语音、克隆声音和上传操作均须取得相应授权。
8. 检查开头、中间和结尾的帧、完整播放及错误路径；修复缺陷，排除密钥、私密数据和客户个人身份信息。若动态效果没有额外价值，可使用架构图，并提供无障碍描述和原因。
9. 不要编辑 README。遵守明确的仅本地或不推送要求；否则提交、推送当前分支，并创建链接到制品的草稿 PR。更新现有 PR 时不改变其评审状态。
10. macOS：`open -R`；其他系统：显示 `pwd`、绝对路径和准确的 `cd` 命令。

## 完成标准 [#done]

返回客户故事、制品类型/路径、录制/渲染/播放证据、已知限制，以及发布属于范围内时的草稿 PR URL。仅本地输出可以满足明确的本地终点要求，但不能满足发布请求。
