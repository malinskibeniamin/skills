---
description: 引导搭建前端工具链、代码检查、质量门禁、React 技术栈、数据技术栈和 CI。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - frontend starter kit
sidebar:
  label: /frontend-starter-kit
title: /frontend-starter-kit
type: skill
---
![展示 /frontend-starter-kit 技能的示意图](/diagrams/skills/frontend-starter-kit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/frontend-starter-kit.excalidraw)


引导搭建可重复执行而不会产生副作用。仅按需读取所请求的 `references/<tool>/README.md` 及其链接的指南。插件使用者无需复制钩子；纯净仓库需要复制导出工具集。

## 配置方案 [#profiles]

- **完整**（默认）：采用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/frontend-starter-kit/REFERENCE.md) 中的标准技术栈，按以下顺序执行。
- **最小：**工具链、Biome、质量门禁、环境变量验证、约定式提交。
- **Redpanda：**完整配置 + `references/redpanda/README.md`、分类体系、`REDPANDA_KIT=1`。
- **`<tool>`：**仅安装该工具对应的参考配置。

## 完整配置执行顺序 [#full-order]

| 工具 | 用途 |
|---|---|
| `toolchain` | `references/toolchain/`：bun、TS 7 `tsc`/tsrs、破坏性命令防护 |
| `tanstack-intent` | 与版本匹配的指导和编辑门禁 |
| `biome` | Biome、Ultracite、自动修复钩子 |
| `quality-gate` | 脚本、CI、Stop 钩子、产物体积防护 |
| `agent-config` | `AI_AGENT=1`、输出截断 |
| `react-compiler` | 编译器、记忆化检查 |
| `zustand` | `create<T>()()`、`useShallow`、persist |
| `react-rules` | 禁止原始 HTML、TS 逃逸、XSS、桶式导入 |
| `env-validation` | t3-env/zod、`noProcessEnv` |
| `conventional-commits` | `type(scope): description` |
| `react-doctor` | 变更诊断门禁、Stop 钩子 |
| `ci-pipeline` | Actions、覆盖率、缓存 |
| `redpanda` | 注册表工作流和分类体系 |

运行时指导技能（日常工作，而非安装配置）：`/accessibility`、`/tanstack-router`、`/connect-query`、`/e2e-testing`、`/registry-workflow`、`/ux-copy`。可选基础设施（仅斜杠命令）：`/setup-routines`、`/setup-atlassian-workflow`。

## 步骤 [#steps]

1. 确认配置方案；对于完整配置，按表格顺序执行，并按需读取参考资料。
2. 仅当仓库选择严格限制副作用时，设置 `REACT_RULES_BAN_USEEFFECT=1`。
3. 为每个使用方[自动配置保障措施](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-enforcement.md)；遵守获授权的终点范围。
4. 工作流技能已随插件提供；无需额外安装任何内容。

## 验证 [#verify]

- `.claude/settings.json` 包含钩子；安装 TanStack 包时还应包含 TanStack Intent；`biome.jsonc` 和 `src/env.ts` 均存在。
- 脚本：lint、lint:fix、type:check、test、quality:gate。
- `.github/workflows/quality-gate.yml` 存在；所有钩子均可执行。
