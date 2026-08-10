---
title: /extend-harness
description: 扩展和调试 frontend-skills 钩子测试框架、规则、严重性级别和分析功能。
type: skill
sidebar:
  label: /extend-harness
---
![/extend-harness 技能示意图](/diagrams/skills/extend-harness.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/extend-harness.excalidraw)

请编辑源清单和库，切勿编辑生成的配置。请阅读
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/extend-harness/REFERENCE.md)，了解严重性级别、清单选项、解析器契约和
调试方法。

## 添加规则

1. 首先确认 Biome 或 Ultracite 是否能够表达该规则。仅对跨元素、
   跨文件、工作流或智能体行为规则使用钩子。
2. 以相邻的 `.claude/hooks/checks/*.lib.sh` 为基础。公开一个 `run_*` 函数，
   并添加对应的精简 `.claude/hooks/*.sh` 包装脚本。
3. 在 `skill-manifest.json` 中注册该包装脚本，通常放在
   `PostToolUse.Edit|Write` 下。
4. 在 `evals/` 下添加一个针对性测试夹具；记录失败后再通过的证据。
5. 重新生成并测试：

```bash
bash scripts/generate-hook-configs.sh --apply
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' |
  bash .claude/hooks/my-check.sh
```

样式问题使用 `hook_warn`，正确性问题使用 `hook_block`，安全关键规则使用 `hook_block_strict`，
观察性规则使用 `hook_info`。如果只有一个垂直领域需要该规则，优先使用技能作用域的钩子。

## 选择实现方式

- 经过权限筛选或异步执行的条目使用清单对象；保留每个脚本的标准输入
  防护逻辑，因为 Codex 会丢弃仅适用于 Claude 的筛选器。
- 可通过机械方式证明的结构应放入 Biome 或 AST 规则。将含义不明确的
  结构性判断留给审查；避免使用脆弱的多行 grep。
- 保持工具链禁用规则与 `hooks/frontend-skills.rules` 同步。

## 审计或调试

- 运行 `/hook-audit --all`，检查延迟、触发情况和零触发候选项。
- 钩子缺失时，使用 `HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude` 启动。
- 使用 `claude --safe-mode` 隔离自定义配置。
- 将 `/doctor` 发现的延迟问题视为 P95 预算超限。

## 完成标准

- `skill-manifest.json` 负责定义规则和匹配器。
- 脚本具有可执行权限、引用 `_hook-lib.sh`、解析标准输入、筛选路径，并
  记录其绕过机制。
- 针对性测试夹具证明 RED -> GREEN。
- `bash scripts/generate-hook-configs.sh --check` 通过。
- `bash evals/run.sh` 通过。
