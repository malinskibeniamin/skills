---
title: /release
description: 跨清单、PR、标签、GitHub、Claude 和 Codex 发布不可变的 frontend-skills 版本。
type: skill
sidebar:
  label: /release
---
![/release 技能示意图](/diagrams/skills/release.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/release.excalidraw)

发布此仓库，同时确保元数据、标签和运行时缓存不会出现不一致。版本参数必须解析为精确且稳定的 SemVer，例如 `4.34.0`。

## 1. 确定发布点

1. 获取 `origin/main`；要求工作区干净，并且当前功能分支基于最新的 main。
2. 读取自最新 `v*` 标签以来的提交和已合并 PR。根据证据编写发布范围。
3. 要求 `origin/main` 上的 CI 全部通过；在版本变更工作开始前，复现并修复所有失败。
4. 确认本地标签、远程标签和 GitHub Release 均不存在。任何冲突都会终止发布。
5. 确认请求包含合并权限和发布权限。明确的 `/release <version>` 或“cut/publish <version>”请求包含这些权限；仅规划或讨论发布则不包含。

## 2. 以测试优先的方式准备

1. 首先将 `evals/test-improve-release-metadata.sh` 更改为目标版本。
2. 运行该脚本，并记录预期出现的 RED 发布元数据失败。
3. 同时更新 `skill-manifest.json`、两个插件清单、两个市场清单、其中带日期的变更日志条目、`CHANGELOG.md` 以及 README 中固定的安装版本。
4. 如果技能接口发生变化，运行钩子、目录和 AGENTS 生成器。切勿手动编辑生成的 Codex 代理。
5. 重新运行针对发布元数据和打包的评估，直至变为 GREEN。

## 3. 验证软件包

运行仓库质量门禁、软件包测试、完整的 Shell 评估套件、行为钩子测试、生成器漂移检查、JSON 解析以及 `git diff --check`。要求以下两个真实的隔离 CLI 安装程序均通过：

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

针对两个打包后的技能接口运行 `/dogfood`。如果差异中没有面向客户的渲染界面，则跳过视觉审查。审查达到稳定状态的差异，检查其标准合规性、价值、韧性、打包情况以及不可变发布风险。

## 4. 先落地，再添加标签

1. 通过 `/go` 提交、推送并创建发布 PR；附上 dogfood 验证凭证和计数。
2. 监控每项必需的 PR 检查，并解决所有现有审查线程。
3. 仅在第 1 步已确认拥有合并权限时执行合并。
4. 获取 main，并等待合并提交在 main 分支上的 CI 全部通过。
5. 在该合并提交上创建并推送带注释的 `v<version>` 标签，绝不能在功能分支提交上添加标签。

## 5. 发布并重新验证

1. 使用限定范围的说明和比较链接运行 `gh release create v<version> --verify-tag --latest`。
2. 验证远程标签解引用后指向该合并提交，其文件树与已发布的 main 一致，并且仓库的最新 Release 是新标签。
3. 使用全新的隔离 Claude 配置添加远程市场、安装插件，并验证其版本以及新发布的技能接口。
4. 使用全新的隔离 Codex 配置添加固定到新标签的远程市场、安装插件，并进行同样的验证。Claude 和 Codex 的全新隔离安装都必须通过。
5. 仅在收到请求时升级用户的现有安装；两个客户端都需要重启或重新加载。

最后提供 PR 和 Release URL、标签与合并提交标识、CI 结果、安装程序证据，以及一条可见的终端状态。
