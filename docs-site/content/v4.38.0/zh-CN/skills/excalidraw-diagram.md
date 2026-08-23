---
title: /excalidraw-diagram
description: 根据提示词或 Mermaid 生成、优化并导出可编辑的 Excalidraw 图表。适用于手绘风格的架构图、组件结构图、流程图和带注释的技术插图。
type: skill
sidebar:
  label: /excalidraw-diagram
---
![/excalidraw-diagram 技能示意图](/diagrams/skills/excalidraw-diagram.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/excalidraw-diagram.excalidraw)

生成真正的 Excalidraw 元素，而不是仿制的位图。保留一个可编辑的单一事实来源，
并以此生成演示资源。

在转换 Mermaid、直接创建元素或
匹配 Shadcn 风格的视觉语言之前，请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/excalidraw-diagram/REFERENCE.md)。

## 画布

通过固定版本的 CLI 运行每个画布命令：

```bash
export EXPRESS_SERVER_URL="http://127.0.0.1:${CONDUCTOR_PORT:-3000}"
bunx mcp-excalidraw-server@1.1.0 <command>
```

让 `bunx` 使用其共享缓存；不要将 CLI 添加到使用方仓库中。
如果存在 Conductor 分配的端口，环境会选择该端口，否则使用端口 3000。
运行 `start`，在隔离浏览器中打开 `$EXPRESS_SERVER_URL`，保持标签页打开，然后
确认 `status` 显示存在浏览器客户端。如果无法使用隔离浏览器自动化，
请让用户打开一次报告的 URL。

## 工作流

1. 选择目标位置。临时工作使用 `.context/excalidraw/<slug>/`；持久资源使用
   请求中指定的项目路径。避免覆盖现有文件。
2. 在清空现有画布或使用 `--replace` 导入之前，通过 `snapshot save <name>` 或 `export --out <file>`
   保留画布。
3. 选择一个规范源。对于 Mermaid 交付物，应以 `.mmd` 为权威源，并
   在目标渲染器中验证。对于 Excalidraw 交付物，Mermaid 是导入
   脚手架；直接编辑后，以 `.excalidraw` 为权威源。
4. 标准流程、时序、状态或关系结构通过 Mermaid 处理；精确定位、组件结构、徽标、区域或自由形式的标注
   则使用直接元素。
5. 在一次 `mermaid`、`add` 或 `apply` 调用中创建完整的首个版本。为任何可能移动或更改的内容
   指定有意义的 ID。
6. 运行 `mermaid` 后，执行 `describe`，并在导出或直接
   修正前确认存在已转换的元素。如果截图能够渲染，但描述的场景仍为空，请保持以 `.mmd`
   为规范源，或使用直接元素重新构建；绝不能将空的 `.excalidraw` 报告为可编辑文件。
7. 运行 `describe`，然后执行 `screenshot --out <check.png>` -> 查看图像 -> 通过一次 `apply` 补丁修复元素重叠、
   裁切、对比度不足和箭头交叉问题。重复此过程，直至图表整洁。
8. 对于同步画布，导出非空的 `.excalidraw` 以及 PNG 或 SVG。否则，
   导出 `.mmd` 和渲染资源，并继续以 Mermaid 为权威源。对于项目
   资源，除非用户要求单一扁平文件，否则应将可编辑源文件与渲染文件放在一起。
9. 报告最终路径、图表模式、规范源、无障碍说明的位置，以及
   仍需在浏览器中手动进行的任何编辑。

## 命令

```bash
# Mermaid
bunx mcp-excalidraw-server@1.1.0 mermaid diagram.mmd

# Direct scene or atomic correction
bunx mcp-excalidraw-server@1.1.0 add elements.json
bunx mcp-excalidraw-server@1.1.0 apply patch.json

# Inspect and export
bunx mcp-excalidraw-server@1.1.0 describe
bunx mcp-excalidraw-server@1.1.0 screenshot --out check.png
bunx mcp-excalidraw-server@1.1.0 export --out diagram.excalidraw
bunx mcp-excalidraw-server@1.1.0 screenshot --format svg --out diagram.svg
```

## 安全

- 将 `clear --yes`、`import --replace` 和快照恢复视为破坏性的画布
  操作；请先保留当前场景。
- 仅当用户请求公开的 Excalidraw 链接时才使用 `share`，因为它会上传
  场景。
- 对于精确徽标，请使用 SVG 或导入的品牌资源；不要近似仿制受保护的标志。
- 文件导出后，如果预计不再进行编辑，请使用 `stop` 停止本地服务器。
