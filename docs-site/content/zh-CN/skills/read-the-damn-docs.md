---
title: /read-the-damn-docs
description: 从一手文档中研究当前行为。适用于第三方 API、库、CLI、云服务、API 变更、身份验证、计费、安全、迁移或部署。
type: skill
sidebar:
  label: /read-the-damn-docs
---
![“/read-the-damn-docs”技能示意图](/diagrams/skills/read-the-damn-docs.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/read-the-damn-docs.excalidraw)


阅读 `references/builder-upstream.md`，查看完整的触发条件列表。这是快速核查官方事实的路径，无需创建研究产物。需要长期保存的多来源报告使用内置的深度研究技能，并将带引用的 Markdown 文件保存到仓库中已有的笔记存放路径。

## 工作流程 [#workflow]

1. 明确具体的包、版本、端点、CLI、配置、辅助工具、模式或产品功能。
2. 如果本地文档、规范、ADR 或生成的类型定义了契约，请先阅读它们。
3. 对于外部或快速变化的行为，搜索当前官方文档，并打开 API 参考、迁移指南、发行说明、更新日志、SDK 源码或类型定义。
4. 提取导入方式、选项、默认值、破坏性变更、限制、权限和示例。
5. 结合仓库模式应用这些事实；不要盲目照搬示例。
6. 引用影响笔记或答复的事实来源。标出所有无法确认的内容，并说明查找过的位置。

## 强触发条件 [#strong-triggers]

- 最新、当前、官方、受支持、最佳实践、今天或要求查询。
- 安装、升级、配置或导入包、SDK、模型、提供商、插件或 CLI。
- 弃用、未知选项、缺少导出、配置无效、字段不受支持或版本不匹配。
- 难以回退的传输格式、模式、持久化 ID、事件、客户可见行为或自动化。
- 身份验证、OAuth、密钥、Webhook、个人身份信息、加密、保留策略、迁移、重试、速率限制、配额、计费或部署。
