---
title: /snyk-ux-security
description: 使用 Snyk 审计前端、Go 和 Bazel 依赖项，进行可利用性分诊并设置发布门禁。
type: skill
sidebar:
  label: /snyk-ux-security
---
![《/snyk-ux-security》技能示意图](/diagrams/skills/snyk-ux-security.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/snyk-ux-security.excalidraw)

审计每条路径：扫描 -> 证明可利用性 -> 忽略或升级 -> 验证 -> 到达请求的
终点。首先阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/snyk-ux-security/REFERENCE.md)；它会将每个生态系统和发布
分支引导至所需的最精简参考资料。

## 输入和通道

`$ARGUMENTS` 接受以空格分隔的路径、glob 模式或一条粘贴的 Snyk 漏洞信息。

`/snyk-ux-security apps/cloud-ui services/*/cmd`

仅报告的运行在扫描和可达性分析后停止：记录建议的清理和修复措施，
但不运行监控、不移除忽略项，也不编辑依赖项文件。

检测 `package.json`（JS）、`go.mod`（Go），以及 `MODULE.bazel` 或
`bazel/repositories.bzl`（Bazel）。在主上下文中按顺序处理路径。如果
用户明确委派或调用 `/swarm`，每条独立路径都可以分配一个工作树
通道。对于 Bazel，应确认目标分支、评估向后移植，并在用户请求 PR 时使用草稿 PR。

## 各路径处理循环

1. **准备：** 展开 glob 模式；验证 `snyk` 和 `gh` 的身份验证；解析现有的 Snyk
   项目。先根据 CODEOWNERS 推断审阅者，再参考 `git log`；用户标志优先。
2. **重新检查：** 扫描前重新分诊 `.snyk` 中的每个忽略项。使用
   `snyk ignore --remove --id=<id>` 移除过期条目，并将其报告为 `cleaned-up`。
3. **扫描：** 运行 `snyk test`；JS 还运行 `bun audit`，Go 运行 `govulncheck ./...`。
   仅当请求的终点包含 Snyk 云端更新时才运行 `snyk monitor`；它可以更新一个确切的现有项目，
   但绝不能创建项目。
4. **证明可达性：** 使用 `bun why`、`go mod why`、导入、调用点和
   易受攻击的符号。对仅涉及传递依赖项的发现运行 `/steelman`，并在修复任何 `package.json` 前运行
   `/diagnosing-bugs`。package.json 准入门禁仅允许直接依赖项、可达的父依赖项，
   或经证明为最后手段的覆盖项。
5. **忽略或升级：**
   - 默认：使用
     `snyk ignore --id=<id> --reason='<why>' --expiry=<date>` 忽略未经证实或不可达的发现；
     在任何请求的交付内容中包含 `.snyk`，然后重新扫描以确认 `Ignored`。仅在 PR 文本中说明
     并不足够。
   - 可达：使用 `/upgrade-dependency` 及其供应链门禁；优先处理直接依赖项，
     其次是父依赖项，再次是移除依赖项
     暴露面，最后才使用 `resolutions`/`overrides`/`replace`。
     覆盖项列表不断增长是一种代码异味，因为它会导致锁文件膨胀且难以扩展。
6. **应用生态系统门禁：**
   - JS：审计最低发布时长门禁、执行 Socket.dev 网页检查，并针对 React 18 运行
     `bun info <pkg>@<v> peerDependencies.react`；记录 `react19-blocked`。
     使用 `bun update`，然后运行 `bun install && bun install --yarn`。同时提交
     `bun.lock` 和 `yarn.lock`；Snyk IO 需要 `yarn.lock`。
     不要创建、更新或提交 `package-lock.json`；`lockfile-sync-check` 用于防止漂移。
   - Go：运行 `go get -u`、`go mod tidy`；同时提交 `go.mod` 和 `go.sum`。
   - Bazel：按需更新两个清单，然后运行
     `bazel mod deps --lockfile_mode=update`；保留镜像/FIPS/CMVP 约束。
7. **迁移并验证：** 阅读变更日志和 `BREAKING` 说明；将主版本 7 -> 8 -> 9
   分为独立的验证组逐步迁移。仅在用户请求时将每组提交为 `refactor(deps)`。
   绝不要推迟真实漏洞；上报阻塞项。
   JS 运行 `bun run lint:fix`、`bun run type:check`、`bun test`，并在存在构建脚本时执行构建。
   Go 运行 `go build ./...`、`go test ./...`、`go vet ./...` 和 `govulncheck ./...`。
8. **审阅和请求的交付：** 运行 `/resilience-review` 和 `/review`；仅当用户请求发布工单时，
   才对安全债务使用 `/to-tickets`。
   如果请求的终点包含提交或 PR，则提交 `fix(deps): ...`；
   仅在用户请求时使用
   `gh pr create --assignee <triggerer> --reviewer <team-group> --label security,...`
   创建 PR。
   使用 `gh api user --jq .login` 解析触发者；至少需要一个 CODEOWNERS
   团队组，并在涉及忽略项或覆盖项时自动添加安全团队。
   根据情况添加 `team/`、`dismissals`、`overrides-added`、`react19-blocked` 和 `cleaned-up`
   标签。仅当用户请求云端审阅时才运行 `gh workflow run`。

## 完成

报告路径、生态系统、分支、PR，以及已修复、已忽略、已覆盖、已迁移、受阻和
已向后移植的数量。绝不要运行公告中的代码或泄露令牌。
