---
title: /frontend-starter-kit
description: 引导搭建前端工具链、代码检查、质量门禁、React 技术栈、数据技术栈和 CI。
type: skill
sidebar:
  label: /frontend-starter-kit
---
![展示 /frontend-starter-kit 技能的示意图](/diagrams/skills/frontend-starter-kit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/frontend-starter-kit.excalidraw)

一项技能负责所有引导搭建工作。每个工具的安装步骤位于
`references/<tool>/README.md`（如有，还包括 `SETUP.md`/`REFERENCE.md`）中——仅在请求相应配置方案时
按需读取。所有步骤均可重复执行而不会产生副作用。

插件使用者已经拥有随附并完成接线的所有钩子——对他们而言，复制钩子的步骤
无需执行；只运行配置和工具相关步骤即可。对于未安装插件的纯净仓库
（“导出工具集”），则需要完整复制。

## 配置方案

- **完整**（默认）：按以下顺序安装下面的所有工具，目标为
  [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/frontend-starter-kit/REFERENCE.md) 中的标准技术栈（React 19 + Rsbuild + Tailwind + TanStack Router/Query +
  Connect Query + shadcn/Base UI + Vitest/Playwright + Biome/Ultracite + TypeScript 7 `tsc`）。
- **最小**：工具链、Biome、质量门禁、环境变量验证、约定式提交。
- **Redpanda**：完整配置 + `references/redpanda/README.md`（注册表工作流、Redpanda 组件
  分类体系、`REDPANDA_KIT=1`）。
- **`<tool>`**：仅安装该工具对应的参考配置。

## 工具（完整配置按顺序执行）

| 工具 | 参考资料 | 配置内容 |
|---|---|---|
| 工具链 | `references/toolchain/` | 强制使用 bun + TypeScript 7 `tsc`，破坏性命令防护 |
| TanStack Intent | `references/tanstack-intent/` | 与版本匹配的 TanStack 包指导 + 官方编辑门禁 |
| Biome | `references/biome/` | Biome + Ultracite，自动修复钩子 |
| 质量门禁 | `references/quality-gate/` | quality:gate 脚本、CI 工作流、Stop 钩子、产物体积防护 |
| 智能体配置 | `references/agent-config/` | AI_AGENT=1，输出截断 |
| React Compiler | `references/react-compiler/` | React Compiler + 记忆化检查 |
| Zustand | `references/zustand/` | 双括号 create、useShallow、persist |
| React 规则 | `references/react-rules/` | 禁止原始 HTML、TypeScript 逃逸、XSS、桶式导入 |
| 环境变量验证 | `references/env-validation/` | t3-env + zod；通过 Biome noProcessEnv 禁止 process.env |
| 约定式提交 | `references/conventional-commits/` | 强制采用 type(scope): description 格式 |
| React Doctor | `references/react-doctor/` | 变更诊断门禁 + Stop 钩子 |
| CI 流水线 | `references/ci-pipeline/` | GitHub Actions CI、覆盖率门禁、缓存 |
| Redpanda | `references/redpanda/` | Redpanda 注册表工作流 + 组件分类体系 |

运行时指导技能（日常工作，而非安装配置）：`/accessibility`、`/tanstack-router`、
`/connect-query`、`/e2e-testing`、`/registry-workflow`、`/ux-copy`。可选基础设施：
`/setup-routines`、`/setup-atlassian-workflow`（仅斜杠命令）。

## 步骤

1. 确认配置方案（默认为完整配置）。执行到每个工具时，再按需读取其参考资料。
2. 当仓库要求严格限制副作用时，在 session-env.sh 中设置 `REACT_RULES_BAN_USEEFFECT=1`。
3. 工作流技能（development-lifecycle、tdd、grilling、triage、
   diagnosing-bugs、prototype、domain-modeling）随此插件提供——无需安装任何内容。

## 验证

- [ ] `.claude/settings.json` 包含所有钩子；安装 TanStack 包时还应包含 TanStack Intent；`biome.jsonc` + `src/env.ts` 均存在
- [ ] 脚本：lint、lint:fix、type:check、test、quality:gate
- [ ] `.github/workflows/quality-gate.yml` 存在，所有钩子均可执行
