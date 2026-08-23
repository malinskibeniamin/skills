---
title: /codex-compat
description: 根据 Claude 钩子清单生成对等的 Codex hooks.json 和 AGENTS.md 配置。
type: skill
sidebar:
  label: /codex-compat
---
![“/codex-compat”技能示意图](/diagrams/skills/codex-compat.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/codex-compat.excalidraw)

Codex 支持 `SessionStart`、`SubagentStart`、`PreToolUse`、`PermissionRequest`、`PostToolUse`、`PreCompact`、`PostCompact`、`UserPromptSubmit`、`SubagentStop` 和 `Stop` 的 Claude 风格生命周期钩子（https://developers.openai.com/codex/hooks）。没有对应 Codex 事件的 Claude 专属事件 -- `FileChanged`、`WorktreeCreate`、`SessionEnd`、`PostToolUseFailure`（合并到 Codex 的 `PostToolUse` 中）-- 会使用 Stop 批处理回退机制，或按设计被丢弃。`PreToolUse`/`PostToolUse` 匹配器支持 `Bash`、MCP 工具名称、`apply_patch` 和 `Edit|Write` 别名。应尽可能将 `Edit|Write` 钩子直接映射。运行 `/read-the-damn-docs` 以了解当前的钩子行为；当直接映射与回退映射之间存在歧义时，使用 `/plan-arbiter`。

## 此技能会创建什么

- **`.codex/hooks.json`** -- 对受支持的 Claude 钩子进行直接转换
- **`.codex/hooks/codex-batch-check.sh`** -- 仅用于无法在每个工具事件中运行的检查的回退脚本
- **`AGENTS.md`** + **`CLAUDE.md`** -- 共享项目规则（Codex 读取 AGENTS.md，Claude Code 读取 CLAUDE.md）
- **兼容性矩阵** -- 将钩子分类为 `direct`、`direct with shim`、`fallback only` 或 `unsupported`

## 步骤

1. 读取 `.claude/settings.json`，并使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codex-compat/REFERENCE.md) 兼容性矩阵对每个钩子进行分类。
2. 生成 `.codex/hooks.json`：
   - `SessionStart`、`UserPromptSubmit`、`Stop` -> 直接映射
   - 使用 `Bash`、`Edit|Write`、`apply_patch`、`mcp__.*` 的 `PreToolUse` / `PostToolUse` -> 直接映射
   - 针对 `Bash` / MCP / `apply_patch` 的 `PermissionRequest` -> 当脚本能够处理 Codex 载荷时直接映射
   - 不受支持的 Claude 事件或处理程序类型 -> 省略并记录，或仅在语义保持安全时路由到回退机制
3. 仅当需要回退钩子时，将 `scripts/codex-batch-check.sh` -> `.codex/hooks/`。执行 `chmod +x`。
4. 将 `hooks/frontend-skills.rules` -> `.codex/rules/`（execpolicy 基础规则；无需启用钩子功能标志即可工作）。
5. 根据 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codex-compat/REFERENCE.md) 模板生成 `AGENTS.md` + `CLAUDE.md`。
6. 启用并信任：在 `config.toml` 中设置 `[features] hooks = true`，然后在 Codex TUI 中运行 `/hooks` 并信任这些定义（每次更改钩子后都需重新信任；CI 使用 `--dangerously-bypass-hook-trust` 或托管钩子目录）。可选择配置 `notify = ["bash", "<repo>/.claude/hooks/codex-notify.sh"]`，用于回合完成遥测。

## 验证

- [ ] 当源配置中包含直接 `Edit|Write` PostToolUse 钩子时，`.codex/hooks.json` 中也包含这些钩子
- [ ] 除非确实存在仅能使用回退机制的钩子，否则不应存在批处理检查器
- [ ] `.codex/rules/frontend-skills.rules` 存在，并且与 `hooks/frontend-skills.rules` 完全相同
- [ ] 钩子功能标志已启用且定义已受信任（`/hooks` 显示它们处于活动状态，而不是待处理状态）
- [ ] 仓库根目录中存在 `AGENTS.md` + `CLAUDE.md`
- [ ] `.claude/settings.json` 未被更改
