---
title: /hook-audit
description: 分析钩子的有效性和会话遥测数据。适用于审计钩子延迟、违规情况、零触发规则、严重级别、清单漂移、技能触发、会话趋势或复盘。
type: skill
sidebar:
  label: /hook-audit
---
![／hook-audit 技能示意图](/diagrams/skills/hook-audit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/hook-audit.excalidraw)


审计 `~/.claude/hook-metrics/`，使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md) 中的指标、分组和数据缺失规则。

模式：默认模式或 `--hooks` 用于分析活动；`--retro` 添加会话流程和环境发现；`--all` 包含复盘、延迟、技能触发和清单漂移。

## 流程

1. 盘点钩子和日期范围；将评估与真实运行分开。按测试框架版本和模型分组；使用 `model-switches.jsonl` 拆分或排除混合模型会话。
2. 汇总阻止、警告、提醒、拒绝、会话和趋势；根据要求计算 P50/P95 和总实际耗时。
3. 比较脚本、观测到的键和规则执行情况；区分真正的零触发候选项、未经测试的钩子和建议性规则。
4. 复盘：遵循[会话环境复盘](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md#session-environment-retrospective)；添加可用的复盘指标。缺少遥测数据不妨碍提出有会话记录支持的发现。
5. 全部：检查 `skill-fires.jsonl`；运行 `bash scripts/generate-hook-configs.sh --check`。
6. 模型切换策略：使用 `/quantify-impact`；以任务成功率或返工量为主要指标，以缓存写入成本为约束指标。
7. 按影响程度排序，从遥测和会话发现中合计建议最多五项操作。除非用户要求实施，否则仅提供建议。

删除前，请在具有代表性且标明版本的试验中，通过 `HOOK_SHADOW_RULES` 以影子模式运行；比较任务结果和违规情况。切勿对严格的安全或权限规则使用影子模式。

## 完成标准

报告可用的指标和数值、样本量、7 天趋势和后续操作；将缺失项标记为不可用。当可比较的真实会话少于五个时，将发现标记为初步结论。对于裁剪或严重级别变更，请引用源文件以及确切的 `harness_version` + `model` 分组。
