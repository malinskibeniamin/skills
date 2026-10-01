---
title: "/effect-ts"
description: "配置使用 Effect TypeScript 库的仓库时使用。"
type: skill
sidebar:
  label: "/effect-ts"
---
![/effect-ts 技能图](/diagrams/skills/effect-ts.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/effect-ts.excalidraw)

## 安装 Effect

使用仓库的包管理器。对于新的 v4 配置，上游使用候选发布渠道：

```sh
bun add effect@rc
```

除非用户要求升级，否则保留已有的 Effect 版本。对于 v3 到 v4 的升级，使用 `/effect-v3-to-v4`，而不是将其视为全新安装。

在 monorepo 中，如需从 `node_modules/effect` 访问源码和智能体指南，可在根目录安装 Effect 作为开发依赖：

```sh
bun add -D effect@rc
```

在导入 Effect 的包中保留运行时依赖。添加下方指令前，确认 `node_modules/effect/AGENTS.md` 和 `node_modules/effect/src` 存在；若不存在，报告已安装的版本和缺失文件。

## 更新智能体指令

将下方内容添加到仓库的智能体指令规范源文件。重新生成派生的 `AGENTS.md` 或 `CLAUDE.md`；不要手动编辑生成的指令。

```md
# 进一步了解 Effect

此仓库使用 Effect TypeScript 库。

编写任何 Effect 代码前，完整阅读 `node_modules/effect/AGENTS.md`，
并按需阅读文件中的链接。

对于指南未涵盖的 API 和概念，搜索已安装的源码：
`node_modules/effect/src`。
```
