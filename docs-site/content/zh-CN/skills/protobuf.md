---
description: >-
  设计并审查 Protobuf 模式及其使用方。适用于 .proto 变更、Buf/代码生成配置、模式演进、Protovalidate/CEL、描述符或
  protobuf 运行时契约。Google 资源 API 约定由 aip 负责。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - protobuf
sidebar:
  label: /protobuf
title: /protobuf
type: skill
---
![Protobuf](/diagrams/skills/protobuf.svg)

[Excalidraw](/diagrams/skills/protobuf.excalidraw)

把模式视为序列化、生成代码、校验及描述符驱动使用方的契约，而不只是传输 DTO。仅应用仓库实际使用的层。加载技能不代表获准委派或迁移。

## 检查契约 [#inspect-the-contract]

1. 固定审查基线和 HEAD；按要求包含工作区变更。涵盖删除和重命名的模式、导入、自定义选项、代码生成配置及受影响的输出。
2. 确认语法/版本、编译器与插件、运行时版本、Buf 模块和锁文件、生成命令、兼容策略、持久化消息及已部署的使用方。分别检查二进制、ProtoJSON、生成源码及行为兼容性。
3. 模式或代码生成变更需阅读[兼容性](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/compatibility.md)。沿受影响的描述符和消息追踪生产方、适配器、存储及客户端；生成代码是证据，不应手工修改。
4. 只加载相关细节：
   - 校验、必填语义或 CEL 变更：[校验](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/validation.md)。
   - TS/Python 运行时或 RPC 使用方：[运行时](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/runtimes.md)。
   - 反射、自定义选项、表单或重复的模式事实：[模式驱动能力](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/schema-driven.md)。
   - 采用 Google 资源约定的 API：完整加载 [aip](https://github.com/malinskibeniamin/skills/blob/main/aip/SKILL.md)。`.proto` 扩展名不意味着所有通用 AIP 都适用。
   - React Connect Query 数据流：加载 [connect-query](https://github.com/malinskibeniamin/skills/blob/main/connect-query/SKILL.md)。

## 验证行为 [#verify-behavior]

使用仓库自己的命令和固定的工具链。按已有配置运行 Buf 格式检查、构建、lint、针对实际审查或部署基线的破坏性变更检查、代码生成及受影响使用方的检查。遵循模块根目录和既有规则类别；报告被削弱的检查及策略缺口，不要悄悄改动策略。

审查保持只读：必要时将代码生成到临时输出或快照。说明不可用工具、缺失基线及未测试的语言；仅通过 lint 或二进制检查不能证明语义兼容或运行时校验。

为变更契约寻找公开接口上的反例：旧数据配新读取方、新数据配旧读取方、未设置与显式默认值、无效请求到达服务端，或编辑适配器丢失信息。实现时先让测试证明该反例失败，再修复，并通过真实使用方重放。

## 分开报告两类结果 [#report-two-distinct-results]

- **缺陷：** 差异引入的失败，包含受影响使用方/场景、证据、后果、最小兼容修复及验证。它们影响审查结论。
- **机会：** 基于实际重复或现有描述符使用方的可选模式驱动改进。说明收益、采用成本及最小实验。不要放入行内缺陷评论或阻塞发现。未采用 Protovalidate、自定义选项、AIP 约定或较新运行时，本身不构成错误。

遵循上层审查的发现格式；门禁审查将能力建议放入 `simplification_opportunities`，而不是 `findings` 或 `testing_gaps`。报告验证限制和发布风险；不要虚构独立审查、跨语言一致性或符合性测试结果。
