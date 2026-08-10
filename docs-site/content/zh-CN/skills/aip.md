---
title: /aip
description: >-
  设计 Google AIP 资源 API。适用于 protobuf 或 REST 资源、标准方法、HTTP
  绑定、字段、分页、过滤、长时间运行的操作、错误、兼容性或批量 API。
type: skill
sidebar:
  label: /aip
---
![/aip 技能示意图](/diagrams/skills/aip.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/aip.excalidraw)

以通用 AIP 作为事实依据。已批准的 AIP 具有规范约束力。AIP-162（草案）和 AIP-182（评审中）仅供参考：应予以考虑并明确标注，但绝不能将其表述为要求。

## 工作流程

1. 阅读拟议接口的完整内容以及附近已建立的 API。将其归类为管理平面或数据平面。
2. 完整检查 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/aip/REFERENCE.md) 中全部 72 个 `Use when` 条目一次，以建立适用性清单；使用概念或 `AIP-N` 搜索来查找详细信息，但不要将其作为唯一的发现方式。记录选择或排除每个 AIP 的原因。不要盲目应用所有 AIP。
3. 对于每个适用的 AIP（包括符合要求和仅供参考的条目），打开其确切的官方 `https://google.aip.dev/{number}` 页面。绝不能仅根据本地索引添加证据行。起草完成后，以机械化方式将适用条目的 URL 与研究记录进行比较，并在最终定稿前获取所有缺失页面。
4. 按以下顺序解决冲突：当前已批准的 AIP、已记录的本地兼容性要求、先例例外。绝不能将违规做法复制为先例。使用 `aip.dev/not-precedent` 标记必要的例外，并说明理由。
5. 根据确切的官方指南，为具体变更制定检查清单。不仅要涵盖语法，还要涵盖 proto/HTTP 结构、行为、错误、生命周期、兼容性、文档和客户端易用性。
6. 设计或评审符合规范的最小接口，同时不得暗中删除预期的用户能力。除非版本或稳定性政策允许破坏性变更，否则应保持线上协议兼容性。
7. 如果仓库中已有相应命令和配置，请使用它们运行 `api-linter`。将其视为最低保障：对于它无法编码检查的适用规则，应进行人工评审。
8. 对每个适用的 AIP 分别报告一行，格式为 `AIP | 状态 | 适用性 | 结果 | 证据/例外`；绝不能将多个 AIP 合并到同一行，也不能遗漏符合要求的通过项。另行将排除的 AIP 列为不适用，然后验证这两个集合是否恰好各统计全部 72 个已发布编号一次。将规范性问题与参考性建议分开。

## 基准要求

- 首先将管理 API 建模为无环层次结构中的命名资源，并采用标准方法。
- 为资源提供包含完整服务相对路径的规范相对资源 `name`，并添加 `(google.api.resource)` 注解；将显示文本保留在 `display_name` 中。
- 使用 `resource_reference.type` 注解请求中引用现有资源的 `name` 字段。当父资源类型未声明或可能变化时，使用 `resource_reference.child_type` 注解嵌套 List/Create 的 `parent`；否则使用父资源的 `type`；绝不能将 `type` 指向子资源。
- 确保 HTTP 路径、请求字段、方法签名、资源引用、字段行为、分页、过滤、掩码、错误和长时间运行的操作元数据保持一致。
- 保持修正后的架构自包含：为引入的每个注解或消息添加其定义所在的 import。
- 保留相对过期时间能力：将原始 TTL 数值替换为 `oneof expiration`，其中包含可作为输入的 `google.protobuf.Timestamp expire_time` 和 `google.protobuf.Duration ttl [(google.api.field_behavior) = INPUT_ONLY]`；不要只保留 `expire_time`，并且 `expire_time` 不得为 `OUTPUT_ONLY`，因为客户端可能会提供确切时间。
- 验证变更后的行为是否达到方法或操作承诺的稳态。
- 评审每项变更的兼容性，而不仅仅检查字段编号复用：名称、类型、格式、语义、HTTP 绑定、资源模式、必填性和客户端行为都很重要。
- 记录用户可见的语义、验证规则、默认值、顺序、限制、副作用、错误、保留策略和例外。

## 约束条件

- 不要为尚未分配的编号杜撰指南；该编号范围包含 72 个已发布的通用 AIP，而不是 236 份文档。
- 不要将示例视为普遍要求。仅当触发条件成立时才应用条件性 AIP。
- 不要弱化已批准 AIP 中的 **必须**/**不得**。区分 **应该** 建议和已记录的例外。
- 不要仅凭 `api-linter` 或仅凭此检查清单宣称符合规范。
- 重新检查已知陷阱：AIP-122 的相对名称和父资源引用方向；用于 HTTP 转码资源方法的 AIP-127 和 AIP-130；AIP-134 的可选更新掩码；AIP-154 中未添加注解的资源 etag；AIP-161 中被忽略的仅输出输入；AIP-192 要求每个公共声明都有注释；AIP-203 的 `IDENTIFIER` 名称和请求字段行为；`client.proto` 中的 `method_signature`；以及 AIP-214 中可作为输入的 `expire_time` 加上仅输入的 `ttl` oneof。
- 对于遗留接口，优先使用显式兼容性适配器，而不是扩展不符合规范的模式。
