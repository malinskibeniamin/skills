---
description: 揪出变更中声称做到却未做到的内容：凭空捏造的 API 或声明、假装成功的代码、无法失败的测试、未经要求引入的变更，以及容易被照搬的反模式。用于每个 PR。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - lie detector
sidebar:
  label: /lie-detector
title: /lie-detector
type: skill
---
![/lie-detector 技能示意图](/diagrams/skills/lie-detector.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/lie-detector.excalidraw)


将变更视为尚未得到证实。为“此变更不应合并”构建最有力的论证，再让差异中的证据
反驳它。可独立运行，也可在 `/review` 中作为**测谎审查角色**，审查每一项
差异；优先关注面向客户的部分（UI、文案、CLI 输出、公共 API、报告）。
代码缺陷由 `/review` 负责；价值判断由 `/product` 负责。使用固定的审查范围，
若请求包含 WIP，则纳入明确捕获的 WIP。

## 1. 缺乏证据的声明 [#1-claims-without-evidence]

列出 PR 标题、正文、提交、代码注释、文档和智能体摘要中的每一项声明。
每项声明都需要差异中的代码行、命令输出或一手文档作为依据：

- 虚构的接口或配置项：导入的符号、prop、hook、CLI 标志、配置键、环境变量、设计
  令牌、路由或选项，在已安装的版本中并不存在。检查锁文件、
  `node_modules` 中的类型或一手文档，不要凭记忆判断。
- “已测试”“已验证”“修复了 X”“行为未变”：需要命令及其输出，或一组
  先失败后通过的测试结果。
- 引用的文件与行号、问题或文档，并不支持对应的声明。

## 2. 假装完成工作的代码 [#2-code-that-pretends]

追踪每条变更路径，确认用户或调用方实际得到的结果。标记声称完成了
实际未做的工作的代码：

- 工作完成前就报告成功：在变更操作、
  写入或失效操作完成前，就显示提示、执行重定向或返回 `200`；
- 吞掉错误、仅记录日志，或回退到默认值、占位内容或缓存数据，
  而 UI 却显示成功；
- 将桩代码、TODO、硬编码或模拟数据，或禁用的分支作为已完成功能交付；
- 没有任何代码路径读取的标志、选项或配置键；
- 名称、注释、类型或类型断言与其描述的代码不符；
- 无法进入或永不结束的加载、空数据或错误状态。

## 3. 无法失败的测试 [#3-tests-that-cannot-fail]

对于每个新增或修改的测试：

1. 按[审查隔离](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md#source-snapshots-and-mutation-tests)在一次性快照中
   破坏测试声称保护的行为：反转变更条件、移除渲染元素或改变用户可见的值。
   仅破坏连接关系会漏掉恒真断言。在快照中重新运行测试；保持原始文件、
   索引和分支不变。仍然通过：测试在说谎。RED 必须来自断言失败，
   而非环境设置失败。记录命令和失败；无法隔离时应明确报告证据缺口，
   而不是修改当前检出目录。
2. 按照 [test-audit 无效测试模式](https://github.com/malinskibeniamin/skills/blob/v4.42.0/test-audit/SKILL.md#junk-patterns)检查仍然通过的测试。
3. 行为变更，如果既没有经历过失败的测试，也没有通过真实入口重放验证（`/dogfood`），
   就尚未得到证实。

## 4. 无人要求的变更 [#4-changes-nobody-asked-for]

将每个差异块与声明的范围进行对照。标记每个未作解释、却改变可观察行为或削弱防护的差异块：删除、跳过或放宽测试；重新生成快照；`@ts-ignore` 或禁用 lint 检查；更改默认值、文案、路由、标志、错误处理、重试或超时；扩大排除范围、放宽编译器或 lint 规则，或将 shell、CI 的失败退出转换为成功；锁文件或配置的无谓改动；手动编辑生成文件；没有截图的视觉变更。将变更的检查和配置与其评判的实现分别审查；合理的规则修正需要通过实际命令验证已知错误和有效案例。

对于授权证明类型，将创建过程追溯到可信的检查模块。断言、导出的未经检查的构造函数，或声称安全的注释，都不能替代授权检查；类型检查通过本身不能证明可信模块正确。
遇到链式断言、被丢弃的类型证据或拟采用的 anti-slop 规则时，使用 [anti-slop 清单](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/anti-slop.md)；仅凭上游偏好不能构成审查问题。

## 5. 会被传播的模式 [#5-patterns-that-will-spread]

人和智能体都会照搬就近的示例。对于差异中引入的每一种惯用写法，使用
`rg` 查找先例，并与根目录及对应作用域的 `CLAUDE.md`/`AGENTS.md`、`exemplars/`
和技术栈注册表进行比较。与已记录的规则或仓库中的主流写法冲突：记录为问题；
严重程度取决于被照搬的影响范围：共享组件、hook、测试夹具、测试辅助函数、模板、
生成器、示例或技能中的问题为 P1；叶子代码中的问题为 P2。从源头修复：使用认可的
模式，或在同一个 PR 中更新规则，并说明原因。两种风格同时存在，本身就是缺陷。

## 6. 最强反方论证关卡 [#6-steelman-gate]

以“此 PR 应当合并”为前提，遵循 [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/steelman/SKILL.md)。
根据 [product](https://github.com/malinskibeniamin/skills/blob/v4.42.0/product/SKILL.md) 的结论、上述问题
以及 `/review` 的发现，构建最有力的反对论证。只有以下三项都成立时，才算**可以合并**：

- 价值：`product:` 的结论为 `justified`；
- 真实性：此处没有 P1，且每项变更的行为都有先失败后通过的测试，或
  通过真实入口重放验证；
- 实现：`/review` 未报告 P0/P1。

其他情况均为**尚未证实**；指出哪一项证据能够改变结论。舍弃任何
没有文件与行号或命令输出支撑的反对意见。绝不因个人偏好阻止合并。

## 严重程度 [#severity]

- **P1**：声明与代码或文档矛盾；虚构的 API；代码报告了实际未实现的成功；
  行为已被破坏，测试却仍然通过；未经解释的行为变更或
  防护削弱；容易被照搬的位置存在反模式。
- **P2**：未经验证但看似合理的声明；误导性的名称或注释；叶子代码中的
  反模式；与有效断言并列的恒真断言。
- **P3**：仅在摘要中提及。

最多报告五个问题，优先列出影响合并决策的问题。

## 输出 [#output]

始终以一行结论开头：

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`：未发现问题。`suspect`：仅有 P2。`lying`：存在任何 P1。随后使用
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`。没有发现问题时，只输出结论行。
