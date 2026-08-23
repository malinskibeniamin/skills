---
title: /postgresql
description: >-
  根据工作负载证据设计 PostgreSQL。适用于 SQL 拉取请求、架构、索引、事务、迁移、性能、安全性/RLS、备份/PITR、报告，以及生成的
  Drizzle 或 Jet SQL。
type: skill
sidebar:
  label: /postgresql
---
![“/postgresql”技能示意图](/diagrams/skills/postgresql.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/postgresql.excalidraw)

应将“最佳 SQL”视为针对特定工作负载、版本、提供商和恢复约定进行衡量后得出的适配方案。PostgreSQL 原生语义和实际生成的 SQL，其优先级高于 ORM、查询构建器、提供商抽象层或厂商声明。

## 工作流

1. **选择模式：**编写/审查 SQL；设计架构/索引；编排事务/队列；迁移；诊断/调优；运维/恢复；安全/租户；报告；或集成 Jet。
2. **确定约定：**PostgreSQL 主版本/次版本及提供商/分支版本；扩展/拓扑/连接池；工作负载特征；数据量/倾斜度/增长率；并发量；延迟/吞吐量 SLO；RPO/RTO；安全要求；变更窗口。标明未知项。绝不虚构生产环境事实。
3. **获取真实依据：**实际 SQL 和参数形式、事务边界、架构/系统目录状态、代表性数据、执行计划/统计信息、等待事件、锁、资源遥测数据，以及相关的部署/配置历史。
4. **提出最小可逆变更：**说明证据、假设、预期效果、写入/存储/锁/WAL 成本、异常路径、版本/提供商注意事项、回滚或前向修复方案、中止条件和验证方法。
5. **管控实时影响：**默认情况下，生产环境诊断必须只读、范围受限且有时间限制。在执行写入、DDL、取消操作、角色/策略/配置变更、故障转移、恢复或破坏性命令之前，必须获得明确批准。再次确认目标。
6. **执行一项可衡量的变更：**保留准确的 SQL 和事务边界。在发布期间持续观察；达到中止条件时停止。
7. **以证据收尾：**验证数据库结果和用户结果，记录变更前后的观测窗口，检查恢复能力，并指出所有剩余的不确定性。

## 路由

| 工作 | 阅读 |
|---|---|
| 审查 SQL 拉取请求或数据库差异 | [SQL-PR-REVIEW.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-PR-REVIEW.md) 以及该差异涉及的每个领域参考文档 |
| 查询语义、连接、分页、DML | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md) |
| 类型、约束、索引、分区 | [SCHEMA-INDEXES.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SCHEMA-INDEXES.md) |
| 隔离级别、重试、锁、队列、预算 | [TRANSACTIONS-ORCHESTRATION.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/TRANSACTIONS-ORCHESTRATION.md) |
| 在线 DDL、回填、生成的迁移 | [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md) |
| 执行计划、统计信息、基准测试、性能回退 | [PERFORMANCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/PERFORMANCE.md) |
| 连接池、清理、WAL、复制、高可用、PITR | [OPERATIONS-RECOVERY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/OPERATIONS-RECOVERY.md) |
| 角色、RLS、租户隔离、敏感数据副本 | [SECURITY-TENANCY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SECURITY-TENANCY.md) |
| 运维总结或数据库健康报告 | [WEEKLY-REPORT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/WEEKLY-REPORT.md) |
| 支持的功能、托管服务提供商边界 | [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| Drizzle 生成的 SQL 或迁移 | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md)、[MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md) 和 [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| 使用 `go-jet/jet` 的 Go 代码 | [GO-JET.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/GO-JET.md) |
| 证据强度或语料库更新 | [EVIDENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/EVIDENCE.md) |

将 PostgreSQL 19 视为预览版本。在使用特定于版本、扩展、提供商、Drizzle 或 Jet 的行为之前，请重新查阅最新文档。

## 输出约定

返回：**上下文 -> 证据 -> 建议 -> 准确的 SQL/代码 -> 影响和风险 -> 发布/审批关卡 -> 回滚/前向修复 -> 验证**。进行审查时，应先报告正确性和安全性问题，再报告样式问题。如果缺少实时证据，请提供范围受限的收集查询，并停留在假设阶段。
