---
title: /hook-audit
description: 分析钩子的有效性和会话遥测数据。适用于审计钩子延迟、违规情况、零触发规则、严重级别、清单漂移、技能触发、会话趋势或复盘。
type: skill
sidebar:
  label: /hook-audit
---
![／hook-audit 技能示意图](/diagrams/skills/hook-audit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/hook-audit.excalidraw)


审计 `~/.claude/hook-metrics/`。Codex 轮次会计入会话流程，但钩子映射为空并不意味着钩子未触发。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md) 定义了指标和阈值。

模式：默认模式或 `--hooks` 用于分析活动；`--retro` 添加会话流程指标；`--all` 添加延迟、技能触发和清单漂移。

## 流程

1. 盘点钩子和日期范围；将评估与真实运行分开，并按测试框架版本和模型对其进行分组。对于列在 `model-switches.jsonl` 中的会话，应拆分或排除，而不是将混合模型会话归入单个模型。
2. 汇总阻止、警告、提醒、拒绝、会话和趋势。
3. 根据要求计算 P50/P95 延迟和总实际耗时。
4. 将脚本与观测到的键进行比较；标记真正的零触发候选项。
5. 将规则与强制执行情况进行比较；区分未经测试的钩子与建议性规则。
6. 复盘：PR 延迟、CI 首次通过率、审查轮次、反馈延迟和工作树数量。
7. 全部：检查 `skill-fires.jsonl` 和 `model-switches.jsonl`；运行 `bash scripts/generate-hook-configs.sh --check`。
8. 模型切换策略：使用 `/quantify-impact`；以任务成功率或返工量为主要指标，以缓存写入成本为约束指标。
9. 最多建议五项操作：`Prune`：裁剪无用途的零触发规则；`Soften`：软化噪声过多的阻止规则；`Harden`：强化存在风险的警告规则；`Add`：添加缺失的确定性规则。

删除前，请在具有代表性且标明版本的试验中，通过 `HOOK_SHADOW_RULES` 以影子模式运行；比较任务结果和违规情况。切勿对严格的安全或权限规则使用影子模式。

## 完成标准

报告每项指标、值、样本量、7 天趋势和后续操作。当可比较的真实会话少于五个时，将发现标记为初步结论。对于裁剪或严重级别变更，请引用源文件以及确切的 `harness_version` + `model` 分组。
