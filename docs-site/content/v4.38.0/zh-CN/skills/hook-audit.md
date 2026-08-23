---
title: /hook-audit
description: 分析钩子的有效性和会话遥测数据。适用于审计钩子延迟、违规情况、零触发规则、严重级别、清单漂移、技能触发、会话趋势或复盘。
type: skill
sidebar:
  label: /hook-audit
---
![／hook-audit 技能示意图](/diagrams/skills/hook-audit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/hook-audit.excalidraw)

审计 `~/.claude/hook-metrics/` 中的会话文件。Codex 轮次记录会计入会话流程，但其中为空的钩子映射并不意味着钩子未触发。有关指标定义和阈值，请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/hook-audit/REFERENCE.md)。

模式：

- 默认模式或 `--hooks`：钩子活动、未触发情况、严重级别、强制执行。
- `--retro`：添加会话流程指标。
- `--all`：包括延迟、技能触发和清单漂移。

## 流程

1. 盘点已安装的钩子和指标日期范围。将真实运行与评估分开，并在比较证据前按测试框架版本和模型对其进行分组。
2. 按钩子汇总：阻止、警告、提醒、拒绝、会话、趋势。
3. 根据要求计算 P50/P95 延迟和总实际耗时。
4. 将已安装的脚本与观测到的键进行比较；标记真正的零触发候选项。
5. 将智能体规则与强制执行情况进行比较；区分未经测试的钩子与建议性规则。
6. 在复盘模式下，测量 PR 延迟、CI 首次通过率、审查轮次、人工反馈延迟和工作树数量。
7. 在全部模式下，检查 `skill-fires.jsonl` 并运行：

```bash
bash scripts/generate-hook-configs.sh --check
```

8. 最多建议五项操作：
   - `Prune`：从未触发且没有证据支持的用途。
   - `Soften`：阻止过于频繁。
   - `Harden`：频繁警告表明存在正确性风险。
   - `Add`：某项确定性且高价值的规则缺少强制执行。

对于删除候选项，请在具有代表性且标明版本的试验中，通过 `HOOK_SHADOW_RULES` 以影子模式运行该规则。在移除强制执行前，比较任务结果和违规情况。切勿对严格的安全或权限规则使用影子模式。

## 完成标准

报告每项指标的值、样本量、7 天趋势和后续操作。当可比较的真实会话少于五个时，将发现标记为初步结论。对于每项裁剪或严重级别变更，请引用源文件以及确切的 `harness_version` + `model` 分组。
