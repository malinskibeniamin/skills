---
description: 根据提示词或 Mermaid 生成、优化并导出可编辑的 Excalidraw 图表。适用于手绘风格的架构图、组件结构图、流程图和带注释的技术插图。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - excalidraw diagram
sidebar:
  label: /excalidraw-diagram
title: /excalidraw-diagram
type: skill
---
![/excalidraw-diagram 技能示意图](/diagrams/skills/excalidraw-diagram.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/excalidraw-diagram.excalidraw)

创建可编辑的原生元素。场景格式、画布/SVG 和视觉语言请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/REFERENCE.md)；后端 PR 和持续维护的文档请阅读 [PR-WORKFLOW.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/PR-WORKFLOW.md)。

## 默认本地渲染 [#local-default]

创建或更新原生 `.excalidraw` 文件，然后使用固定版本的官方 CLI 渲染：

```bash
EXCALIDRAW_NO_UPDATE_NOTIFIER=1 bunx @excalidraw/cli@0.2.0 render diagram.excalidraw --out diagram.png
```

需要 Node 22 或更新版本，以及已安装的 Chrome/Chromium/Edge/Firefox；使用临时浏览器配置文件，无需账号或 API 密钥。仅输出 PNG，不负责布局。使用 `bunx` 缓存，不要添加到使用方依赖中；Mermaid、实时编辑和 SVG 使用参考文档中的可选画布方案。

## 工作流 [#workflow]

1. 选择目标位置：临时 `.context/excalidraw/<slug>/` 或指定的持久路径。绝不悄悄覆盖文件。
2. 替换前保留源文件；使用画布时，在清空或替换前执行 `snapshot save <name>` 或 `export --out <file>`。
3. 选择权威源：Mermaid 交付物使用 `.mmd`，直接编辑后使用 `.excalidraw`。在目标渲染器中验证 Mermaid。
4. Mermaid 负责标准流程、时序、状态和关系；直接元素负责精确定位、组件结构、徽标、区域和标注。
5. 为可变元素指定稳定的 ID。在本地创建原生元素；画布简写模式使用一次 `mermaid`、`add` 或 `apply` 创建首个完整版本。
6. Mermaid 转换后，在导出或修正前执行 `describe` 检查元素。如果截图可以渲染，但场景为空，请继续以 `.mmd` 为权威源或直接重建；绝不能将空的 `.excalidraw` 声称为可编辑文件。
7. 渲染 PNG，或在画布中先执行 `describe` 再执行 `screenshot` -> 查看图像 -> 修复重叠、裁切、对比度和箭头交叉问题。重复直到图表整洁。
8. 验证原生元素不为空且标签可见；将 `.excalidraw` 与 PNG 或 SVG 保存在一起。仅使用 Mermaid 的备用方案仍是 `.mmd` 加渲染图，而不是可编辑 Excalidraw 的声明。
9. 报告路径、模式、规范源、无障碍说明和手动浏览器操作。

## 安全 [#safety]

- `clear --yes`、`import --replace` 和恢复操作具有破坏性；先保留源文件。
- `share` 会上传场景；仅在用户请求公开链接时使用。
- Excalidraw+ 同步需明确选择启用；Git 保持权威。后端图表失败不阻塞交付；报告缺失的证据并继续交付。
- 精确徽标使用 SVG 或导入的品牌资源；不要近似仿制受保护的标志。
- 仅停止自己启动的画布服务器。
