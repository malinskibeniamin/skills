---
title: /visual-review
description: 根据视觉证据审查面向客户的界面。适用于 Web、移动端、CLI、TUI、桌面应用、报告、引导流程、表单或其他可见行为发生变化的情况。
type: skill
sidebar:
  label: /visual-review
---
![／visual-review 技能示意图](/diagrams/skills/visual-review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/visual-review.excalidraw)


从产品、设计、工程和 QA 的角度审查面向客户的界面。基于浏览器的前端审查最为常见；移动端界面、CLI/TUI、桌面应用和生成的报告也包括在内。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md) 负责定义**设计调整抓手**和详细规范。模式：`plan`、`implemented`、`regression`、`release`。可单独触发。

## 流程

1. **查找：**确定 PR 的基准（适用时使用堆叠父分支），检查合并基准...HEAD，以及已暂存、未暂存和相关的未跟踪变更；仅使用 `git diff --name-only HEAD` 会遗漏已提交的工作。将路由/组件映射到 URL，将 CLI/报告映射到命令。包括 shadcn/ui 或 `@/components/ui`、共享使用方、文案、样式、资源，以及间接的数据/配置影响。任何可见变更都不容忽视。
2. **建立上下文：**读取设计令牌/主题和一个界面；判断其属于品牌表达还是产品表达。
3. **收集：**使用仓库工具、`scripts/skills-browser.sh`、Playwright、固件、截图和输出。仅对直接指标使用 `/quantify-impact`。
4. 执行**审查通道：**评议层级与任务流程；审计无障碍与性能；打磨发布质量与系统契合度。
5. **切换视角：**产品：用户价值；设计：层级、文案、状态；工程：韧性、平台；QA：可复现证据、异常路径。
6. **追踪 UI 生命周期：**空闲/未请求 -> 待处理/加载中/提交中 -> 成功/错误 -> 已稳定/已关闭。要求成功的副作用已得到确认，失败的副作用会持续显示。
7. **压力测试：**Chromium 桌面端和 Chromium 移动端；`Tab, Shift+Tab, Enter, Space, Escape`；加载、空数据、错误、密集数据；表单提交路径；通知/toast 路径；控制台/网络。根据风险增加 Firefox 桌面端、WebKit、减少动态效果、强制颜色、文本缩放、RTL/本地化长文本、慢速网络/媒体限速，以及主题。
8. **收尾：**引用证据，明确设计调整抓手，修复或接受 P0-P1，并记录可确定性复现的自动化候选项。

对于已实现/发布模式：遵循 [PR 视觉证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)：将每个受影响的界面/状态与截图和视觉测试逐一核对，在更新预期基线前检查快照差异，按常规方式重新运行，并在编辑后刷新证据。截图不是视觉测试；通过的测试也不是嵌入式的变更前后证据。

HTML 优先。生命周期胜过截图。状态胜过顺利路径。动态效果就是交互。内容压力测试更有效。无障碍自动化只能覆盖一部分。性能具有视觉表现。同一问题出现两次，就将其自动化。

需要时使用 `/excalidraw-diagram`；以截图为主要证据，Mermaid 作为后备方案。

## 输出

编写简洁的 Markdown。对于发布审查或非简单审查，创建 `$TMPDIR/visual-review-<timestamp>.html`。

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 会阻碍使用、导致安全问题、数据丢失或无限循环；P1 会阻止 PR 合并。当问题已解决或被接受、证据已收集且可重复的问题缺口已被跟踪时，即可完成。
