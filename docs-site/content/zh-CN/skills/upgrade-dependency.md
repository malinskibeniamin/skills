---
title: /upgrade-dependency
description: 升级依赖项并调整所有受影响的调用点。适用于软件包或模块升级、漏洞修复、破坏性变更、代码迁移工具以及新 API 的采用。
type: skill
sidebar:
  label: /upgrade-dependency
---
![展示 /upgrade-dependency 技能的示意图](/diagrams/skills/upgrade-dependency.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/upgrade-dependency.excalidraw)


升级到请求的稳定版本；如未指定，则使用最新稳定版本。遵循请求的交付终点：`plan` 仅为只读；构建或修复遵循仅保留本地、提交或推送的意图；仅在请求时创建 PR。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/REFERENCE.md) 提供供应链检查以及发布模板。`$ARGUMENTS`：软件包/模块、清单文件、版本、自然语言或 `plan`。

## 流程 [#flow]

1. **确定范围**：查找清单文件/锁文件/工作区。梳理依赖树：直接依赖/传递依赖、父依赖/依赖方、对等依赖/插件/适配器/生态系统。仅在获取直接指标时使用 `/quantify-impact`。
2. **研究**：制定涵盖每个已发布稳定版本的升级路径，并附上逐版本说明。阅读主版本公告、发行说明、迁移指南、代码迁移工具以及 `/read-the-damn-docs`；略读次版本/补丁版本说明。不要逐个版本安装；只安装一次目标版本。汇总 API、语法、样式和行为变更。判定 SemVer 主版本/次版本/补丁版本类型；对于非 SemVer 或缺少变更日志的情况，评估变更量、发布频率、差异规模、工作量/危险程度/影响范围。检查安全公告：GHSA/OSV/Socket/Snyk。
3. **关卡**：有充分把握的补丁版本/次版本可应用。已有文档说明的主版本每次应用一个主版本节点。迁移方式不明确、风险高或安全性存在不确定性时停止，并提供证据和需要作出的决策。计划模式仅报告。按顺序处理；使用子代理/swarm 或为每个代理分配一个软件包均需明确委派。
4. **供应链**：自动覆盖阻止升级的发布时长过滤规则，无需询问用户；遵循[仅针对发布时长的覆盖规则](https://github.com/malinskibeniamin/skills/blob/main/shared/dependency-release-age.md)。禁用脚本/审查 `trustedDependencies`；不得使用 git 依赖、git+、tarball、原始 URL；使用 Socket/npq；审查锁文件；执行全新安装/冻结锁文件检查。
5. **应用**：保持已验证的提交，除非用户要求提前停止。
   - **升级版本**：`bun update <pkg>@<v>` -> `bun install` -> 按需运行 `bun install --yarn`。Go：`go get -u <module>@<v>` -> `go mod tidy`。切勿手动编辑锁文件。
   - **迁移**：使用官方代码迁移工具；调整每个受影响的调用点。弃用警告必须立即修复，不得抑制。
   - **获益**：采用经验证能简化代码的 API；删除变通方案/polyfill；绝不进行推测性扩展。
   - **清单变更限额**：不得新增直接依赖、编辑根清单文件或添加 override/resolution/补丁，除非缺少这些变更会导致升级失败；在 PR 中逐项说明理由。删除升级后不再需要的现有项。提交前检查清单文件的差异。
   - **验证**：`bun run lint:fix`、`bun run type:check`、`bun test`；Go：`go build ./...`、`go test ./...`、`go vet ./...`。同时更新相关软件包。
6. **安全**：证明可利用性/可达性；升级直接依赖 -> 升级父依赖 -> 使用 override/resolution/replace。绝不运行安全公告中的代码。记录安全公告 ID/已修复版本；`/snyk-ux-security` 负责可达性分析。
7. **按要求交付**：一个 PR 包含版本升级、迁移、获益和验证结果。只有在明确要求时，才为被风险关卡阻止的升级创建议题。

证据应放在聊天或指定的 PR 中；仅在要求时创建本地 Markdown 文件。编辑前说明升级路径。只有调整完每个受影响的调用点才算完成。

## 迁移准则 [#migration-doctrine]

完成时通过 lint/钩子禁止旧模式。路由器/框架层采用一次性整体迁移；数据层采用绞杀者模式，并为新旧并存安排预算。迁移 PR 保持 1:1 功能对等，在同一个 PR 中协调测试；结构性重构另行创建工单。删除已废弃的样式、垫片和一次性特殊处理。
