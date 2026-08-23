---
title: /upgrade-dependency
description: 升级依赖项并调整所有受影响的调用点。适用于软件包或模块升级、漏洞修复、破坏性变更、代码迁移工具以及新 API 的采用。
type: skill
sidebar:
  label: /upgrade-dependency
---
![展示 /upgrade-dependency 技能的示意图](/diagrams/skills/upgrade-dependency.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/upgrade-dependency.excalidraw)

升级到请求的稳定版本；如未指定，则使用最新稳定版本。调整调用点。
遵循请求的交付终点：`plan` 仅为只读；构建或修复包含验证、提交和推送，除非用户要求仅保留本地、
不提交或不推送。仅在请求时创建 PR。
当触发相关分支时，请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/upgrade-dependency/REFERENCE.md)，了解供应链检查以及议题/PR 模板。

输入：`$ARGUMENTS` = 软件包/模块、清单路径、目标版本、自然语言或 `plan`。
## 流程

1. **确定范围**：检测清单文件/锁文件（`package.json`、`bun.lock`、`go.mod`）和工作区。梳理依赖树：直接依赖/传递依赖、父依赖/依赖方、对等依赖/插件/适配器。运行 `/quantify-impact` 获取直接指标。

2. **研究会改变行为的内容**：制定升级路径：从当前安装版本到目标版本之间的每个已发布稳定版本，并附上逐版本行为说明；仅在主版本/破坏性变更节点深入阅读（迁移指南、代码迁移工具、公告、`/read-the-damn-docs`）；略读次版本，跳过补丁版本考古；只安装一次目标版本，而不是逐个节点安装。判定 SemVer 变更类型；对于非 SemVer 或缺少变更日志的情况，评估变更量/发布频率/差异规模/影响范围。检查安全公告（Snyk/GHSA/OSV/Socket/CVE）。

3. **关卡**：有充分把握的补丁版本/次版本 -> 应用。已有文档说明的主版本 -> 每次应用一个主版本节点。非 SemVer、迁移方式不明确、影响范围大或安全性存在不确定性 -> 停止，并提供证据和需要作出的决策。`plan` -> 在聊天中报告升级路径和风险。按顺序处理软件包；明确委派或使用 `/swarm` 时，可分配相互独立的工作通道。

4. **应用**——预检：最低发布时长为 7-30 天，禁用脚本/审查 `trustedDependencies`，不得使用 git/tarball/原始 URL 依赖，如存在则使用 Socket/npq，审查锁文件，执行全新安装。保持相互独立且已验证的提交，除非用户要求提前停止：
   a. **升级版本**：`bun update <pkg>@<v>` -> `bun install` -> 当 `yarn.lock`/Snyk 需要时运行 `bun install --yarn`。Go：`go get -u <module>@<v>` -> `go mod tidy`。切勿手动编辑锁文件。
   b. **迁移**：使用官方代码迁移工具；统一处理每个受影响调用点中的 API/语法/样式/行为变更。本次升级产生的弃用警告必须立即修复，不得抑制。
   c. **获益**：在变更日志重点介绍的 API 能简化现有代码时采用它们——删除被迫添加的变通方案和过时的 polyfill；精简或加固代码，绝不进行推测性扩展。
   d. **验证**：`bun run lint:fix` -> `bun run type:check` -> `bun test`。Go：`go build ./...` -> `go test ./...` -> `go vet ./...`。同时更新相关软件包。

5. **安全**：保留可利用性分析；修复优先级：升级直接依赖 > 升级父依赖 > 使用 override/resolution/replace。绝不运行安全公告中的代码。在 PR 正文中注明安全公告 ID 和已修复版本。`/snyk-ux-security` 负责可达性分析。

6. **按要求交付**：一个 PR 包含版本升级 + 迁移 + 获益，并记录验证结果。
   只有在明确要求时，才为被风险关卡阻止的升级创建议题。

## 规则

证据应放在聊天或指定的 PR 中；仅在要求时创建本地 Markdown 文件。编辑前说明升级路径。对于主版本/非 SemVer 变更，阅读变更日志和发行说明。只有调整完每个受影响的调用点才算完成。JS 和 Go 均为一等支持对象。

## 迁移准则

完成即冻结：完成迁移的 PR 必须禁止旧的导入方式/模式（通过 lint/钩子），否则 LLM 编写者会将其重新引入。路由器/框架层采用一次性整体迁移；数据层采用绞杀者模式（新旧并存——需为此安排预算）。迁移 PR 只做迁移：保持 1:1 功能对等，在同一个 PR 中协调测试，结构性重构另行创建工单。退出时删除已废弃的层（旧版样式、垫片、一次性特殊处理）。
