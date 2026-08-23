---
title: /visual-review
description: 根据视觉证据审查面向客户的界面。适用于 Web、移动端、CLI、TUI、桌面应用、报告、引导流程、表单或其他可见行为发生变化的情况。
type: skill
sidebar:
  label: /visual-review
---
![／visual-review 技能示意图](/diagrams/skills/visual-review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/visual-review.excalidraw)

从产品、设计、工程和 QA 的角度审查面向客户的界面。
基于浏览器的前端审查最为常见；移动端界面、CLI/TUI、桌面应用和生成的
报告也包括在内。请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/visual-review/REFERENCE.md)，了解证据矩阵、设计
语言、平台检查、报告规范和团队审美标准。

模式：`plan`、`implemented`、`regression`、`release`。可单独触发。

## 流程

1. **查找界面：**使用提示或 `git diff --name-only HEAD`；将路由/组件映射到
   URL，将 CLI/报告变更映射到命令。包括 shadcn/ui 或 `@/components/ui`。
2. **建立上下文：**读取设计令牌/主题和一个代表性界面。在评判前，先判断其属于品牌
   表达还是产品表达。
3. **收集证据：**使用仓库工具、`scripts/skills-browser.sh`、Playwright、固件、
   截图和命令输出。当存在直接的 UI 数值或
   性能指标时，运行 `/quantify-impact`；对于微小变更，跳过形式化的测量流程。
4. **执行审查通道：**评议（层级与任务流程）、审计（无障碍、
   响应式行为、性能）、打磨（发布质量与系统契合度）。
5. **切换视角：**产品：用户价值与阻力。设计：层级、可供性、文案、
   状态、审美。工程：韧性、时序、平台、性能。
   QA：可复现证据、异常路径、回归、自动化。
6. **追踪 UI 生命周期：**空闲/未请求 -> 待处理/加载中/提交中 -> 成功/错误 -> 已稳定/已关闭。
   验证成功的副作用已得到确认，失败的副作用会持续显示。
7. **对矩阵进行压力测试：**Chromium 桌面端和移动端；键盘 Tab、Shift+Tab、Enter、
   Space、Escape；加载、空数据、错误、密集数据；表单提交路径；通知/toast
   路径；控制台/网络。根据风险增加 Firefox 桌面端、WebKit、减少动态效果、强制颜色、文本
   缩放、RTL/本地化长文本、慢速网络/媒体限速，以及深色/浅色模式。
8. **报告并收尾：**引用证据，明确设计调整抓手，修复 P0/P1 或记录验收决定，
   并将可确定性复现的问题记录为自动化候选项。

使用参考检查清单检查安全区域和虚拟键盘行为、书写模式、
表格、CSS 简写/复杂布局、仅在需要时使用 ARIA、静态/通用元素、
密码管理器/自动填充、`aria-disabled`、焦点、嵌套按钮/链接、`requestSubmit`、
toast、媒体、WebView、往返缓存、滚动、原生控件行为、特性检测、
响应式图片/视频、宽高比、INP/长交互、字体加载，以及第三方
嵌入内容/脚本。

启发式原则：HTML 优先。生命周期胜过截图。状态胜过顺利路径。动态效果就是交互。
内容压力测试更有效。无障碍自动化只能覆盖一部分。性能具有视觉表现。同一问题出现两次，就将其自动化。

## 流程图

当截图无法解释非简单的状态流转、UI/系统边界或
变更前后结构时，使用 `/excalidraw-diagram` 创建一张简洁的流程图。仍以
截图作为主要证据；流程图用于解释关系，而非像素。将
其内联 SVG 或数据编码的 PNG 嵌入 HTML 报告，并在报告中注明相邻的可编辑
`.excalidraw` 文件路径。
对于简单图形或画布不可用的情况，使用 Mermaid 作为后备方案，并记录其局限性。

## 输出

编写一份简洁的报告。对于非简单审查或发布审查，创建
`$TMPDIR/visual-review-<timestamp>.html`。

```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <surfaces>
Checked: <browser/viewport/state/terminal evidence>
State trace: | Surface | Trigger | Pending | Success | Error | Persistence/dismissal | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Screenshots: | View | Browser | Path | Notes |
Impact: <Proven impact table + verdict, or why measurement was not useful>
Automation candidates: <deterministic hook/eval/test candidates>
```

P0 会阻碍使用、导致安全问题、数据丢失或无限循环。P1 会阻止 PR 合并。当 P0/P1 已修复或
已被接受、证据已收集或明确跳过，并且可重复的问题缺口已被跟踪时，即可完成。
