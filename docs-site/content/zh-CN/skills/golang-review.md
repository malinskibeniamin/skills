---
title: /golang-review
description: 依据有证据支持的规则审查 Go 代码的边界、API、并发、错误、安全、测试和发布。适用于 Go 差异、PR、分支、模块或后端 proto。
type: skill
sidebar:
  label: /golang-review
---
![展示 /golang-review 技能的示意图](/diagrams/skills/golang-review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/golang-review.excalidraw)

一个审查维度：此 Go 差异是否遵循
[RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md) 中有证据支持的约定？目录中的每条规则都附有匿名汇总的支持计数，
因此问题会引用规则 ID 并说明在仓库中可见的影响，而不是依赖
审查者的个人偏好。

可针对任何 Go 差异独立运行，也可作为 `/review` 中的 **golang 角色** 内联运行。显式
委派或 `/swarm` 可将此技能用作边界明确的审查通道约定。

## 非目标

- 目标仓库中的 `golangci-lint` 已经强制执行的任何内容——先阅读其配置并跳过这些内容。
- 没有 RULES.md 支持的通用 Go 风格（gofmt、命名、注释语法）。
- 前端、生成的文件（`*.pb.go`、`*_pb.go`、`*.connect.go`、`@generated`/`DO NOT EDIT`）、供应商代码。
- 重新争论规则目录：你不同意的规则应作为对目录的反馈，而不是反向判定问题。

## 流程

1. **确定范围**：从固定点到 HEAD 的差异，仅限 Go 和 proto 文件。记录仓库
   `.golangci.yml` 中启用的检查器；它们强制执行的任何内容都不在审查范围内。
2. **分类**差异所属的领域：proto/API 接口、服务处理器、Temporal
   工作流/活动、Kubernetes 控制器、测试、配置/发布、面向租户的
   安全路径、并发/生命周期。
3. **加载** [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md) 中匹配的章节以及匹配的 `/golang`
   领域文件（PROTO-API、CONCURRENCY、ERRORS、TESTING、TEMPORAL、SECURITY、ROLLOUT、
   STRUCTURE、CONTROLLERS）。应用范围内的每条 S/A 级规则；明确违规时应用 B 级规则；仅当
   差异明显违反规则表述时应用 C/D 级规则。
4. 在撰写问题前，**检查 RULES.md 和 `/golang` SKILL.md 中的冲突事项列表**
   ——正向布尔值与故障关闭、枚举子集 switch、keepalive、
   过滤器对象与字符串都取决于具体上下文，不应直接视为违规。
5. **报告**问题，每项包含：规则 ID、文件:行号、差异所做的改动、要求的
   修改以及优先级。作为评审角色时最多 400 字；独立运行时可以更长，
   但必须以规则目录为依据。

## 严重程度

- **P0**：故障开放型安全谓词、租户出口流量绕过 safedial、以明文
  存储/返回/记录密钥、在持久化处理之前提交进度、
  未经版本控制的更改破坏正在运行的 Temporal 历史记录。
- **P1**：任何其他 S/A 级违规——由租户控制且无上限的增长、在公共
  接口中暴露原始内部错误、缺少分阶段移除、基于模拟测试声称完成集成。
- **P2**：B 级违规；需要作者作出判断的 S/A 级情况。
- **P3**：C/D 级措辞和细节完善问题。

已确认的缺陷无论修复规模如何，都保持为 P0/P1。

## 输出

标准评审角色约定：问题必须由差异引入、影响用户且可执行，
每项都应可直接作为 PR 评论（问题内容、依据目录规则说明原因、建议修复方式、一次性提示词）。
当范围内没有违反任何规则时：`APPROVED -- <已检查的领域>，没有违反目录规则。`
