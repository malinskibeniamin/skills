---
title: /lie-detector
description: >-
  揪出变更中声称做到却未做到的内容：无法失败的测试、凭空捏造的 API、未经要求引入的变更，以及容易被照搬的反模式。用于面向用户的差异审查，并在认定 PR
  可合并前执行。
type: skill
sidebar:
  label: /lie-detector
---
![/lie-detector 技能示意图](/diagrams/skills/lie-detector.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/lie-detector.excalidraw)


将变更视为尚未得到证实。为“此变更不应合并”构建最有力的论证，再让差异中的证据
反驳它。可独立运行，也可在 `/review` 中作为**测谎审查角色**，审查每一项
面向客户的变更（UI、文案、CLI 输出、公共 API、报告）。代码缺陷由
`/review` 负责；价值判断由 `/jb` 负责。

在已提交的工作树上操作；将 `BASE` 设为合并基点。

## 1. 无法失败的测试 [#1-tests-that-cannot-fail]

对于每个新增或修改的、覆盖面向用户行为的测试：

1. 破坏它声称保护的行为：执行 `git diff "$BASE" -- <src> | git apply -R`，
   反转已修改的条件，移除渲染的元素，或更改用户看到的值
   （文案、计数、状态）；仅破坏连接关系会漏掉恒真断言。运行测试，然后执行
   `git checkout HEAD -- <src>`。代码已被破坏，测试却仍然通过：这个测试在说谎。测试失败必须
   来自断言，而不是导入、编译或初始化错误。记录命令和
   测试失败信息。
2. 按照 [test-audit 无效测试模式](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md#junk-patterns)检查仍然通过的测试。
3. 面向用户的行为变更，如果既没有经历过失败的测试，也没有通过真实入口
   重放验证（`/dogfood`），就尚未得到证实。

## 2. 缺乏证据的声明 [#2-claims-without-evidence]

列出 PR 标题、正文、提交、代码注释、文档和智能体摘要中的每一项声明。
每项声明都需要差异中的代码行、命令输出或一手文档作为依据：

- 虚构的接口或配置项：导入的符号、prop、hook、CLI 标志、配置键、环境变量、设计
  令牌、路由或选项，在已安装的版本中并不存在。检查锁文件、
  `node_modules` 中的类型或一手文档，不要凭记忆判断。
- “已测试”“已验证”“行为未变”“修复了 X”：需要命令及其输出，或一组
  先失败后通过的测试结果。
- 引用的文件与行号、问题或文档，并不支持对应的声明。

## 3. 无人要求的变更 [#3-changes-nobody-asked-for]

将每个差异块与声明的范围进行对照。标记每个未作解释、却改变可观察
行为或削弱防护的差异块：删除、跳过或放宽测试；重新生成快照；类型断言、
`@ts-ignore`、禁用 lint 检查；更改默认值、文案、路由、标志、错误处理、
重试或超时；锁文件或配置的无谓改动；手动编辑生成文件；没有截图的
视觉变更。

## 4. 会被传播的模式 [#4-patterns-that-will-spread]

人和智能体都会照搬就近的示例。对于差异中引入的每一种惯用写法：

- 使用 `rg` 查找先例；与根目录及对应作用域的 `CLAUDE.md`/`AGENTS.md`、
  `exemplars/` 和技术栈注册表进行比较。
- 与已记录的规则或仓库中的主流写法冲突：记录为问题。严重程度取决于被照搬的
  影响范围：共享组件、hook、测试夹具、测试辅助函数、模板、生成器、示例或
  技能中的问题为 P1；叶子代码中的问题为 P2。
- 从源头修复：使用认可的模式，或在同一个 PR 中更新规则，并说明
  新规则为何更好。两种风格同时存在，本身就是缺陷。

## 5. 最强反方论证关卡 [#5-steelman-gate]

以“此 PR 应当合并”为前提，遵循 [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/main/steelman/SKILL.md)。
根据 [jb](https://github.com/malinskibeniamin/skills/blob/main/jb/SKILL.md) 的结论、上述问题
以及 `/review` 的发现，构建最有力的反对论证。只有以下三项都成立时，才算**可以合并**：

- 价值：`jb:` 的结论为 `justified`；
- 真实性：此处没有 P1，且每项面向用户的行为都有先失败后通过的测试，或
  通过真实入口重放验证；
- 实现：`/review` 未报告 P0/P1。

其他情况均为**尚未证实**；指出哪一项证据能够改变结论。舍弃任何
没有文件与行号或命令输出支撑的反对意见。绝不因个人偏好阻止合并。

## 严重程度 [#severity]

- **P1**：行为已被破坏，测试却仍然通过；声明与代码或文档矛盾；虚构的
  API；未经解释的行为变更或防护削弱；容易被照搬的位置存在反模式。
- **P2**：未经验证但看似合理的声明；叶子代码中的反模式；与有效断言
  并列的恒真断言。
- **P3**：仅在摘要中提及。

最多报告五个问题，优先列出影响合并决策的问题。

## 输出 [#output]

始终以一行结论开头：

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`：未发现问题。`suspect`：仅有 P2。`lying`：存在任何 P1。随后使用
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`。没有发现问题时，
只输出结论行。
