---
description: 用于基于源代码的安全问题、漏洞调查、针对性安全审查，或明确要求的代码库审计和渗透测试。不用于依赖扫描，也不是常规审查的必选步骤。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - security audit
sidebar:
  label: /security-audit
title: /security-audit
type: skill
---
![技能 /security-audit 的示意图](/diagrams/skills/security-audit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/security-audit.excalidraw)

先遵循以下宿主规则，再完整阅读[上游技能](https://github.com/malinskibeniamin/skills/blob/v4.41.0/vendor/cloudflare-security-audit/skills/security-audit/SKILL.md)。

- 将**技能目录**解析为上游文件的父目录，而不是此适配器或 Codex 代理的目录。
  配套指南、模式文件和验证器的路径都以该目录为基准。
- 对具体问题和针对性审查，默认提供指导。明确要求的代码库审计、渗透测试、
  全面审查或报告采用六阶段工作流，并保留相关产物。
- 委派需要用户明确同意；提出审计请求本身不等于同意委派。没有同意或委派工具时，
  在当前上下文中仅依据源代码提供指导，并披露覆盖范围有限，不得声称完成了全面审计
  或独立验证。完整执行前先征得同意。保留宿主的模型选择和预算。
- 保留上游沙箱控制、仅限本地的范围、虚拟数据、写入隔离、证据门槛和验证器。
  缺少执行控制时，只能检查源代码并将问题标为需要验证的阻塞项，不能在沙箱外执行
  目标代码或探测在线系统。审计描述修复方案；只有用户要求时才实施。

[来源与更新](https://github.com/malinskibeniamin/skills/blob/v4.41.0/security-audit/CREDITS.md)。安装不会启用审计钩子、后台工作或自动安全审查流程。
