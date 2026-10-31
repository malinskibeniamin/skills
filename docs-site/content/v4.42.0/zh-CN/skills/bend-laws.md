---
description: >-
  用 Bend 定律证明业务规则，并将已发布的 TypeScript 或 Go 代码与已证明的模型比对。用于形式化证明、LAWS.bend 或 PROOF.bend，或必须对每个输入都成立的验收标准。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bend laws
sidebar:
  label: /bend-laws
title: /bend-laws
type: skill
---
![技能 /bend-laws 的图表](/diagrams/skills/bend-laws.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/bend-laws.excalidraw)

验证变更后的行为或维护验证流程时，请阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#verification)。

定律是证明必须对每个输入都满足的验收标准。[Bend](https://bend-lang.com) 依据规则的参考模型检查证明。由该模型生成的表格将已发布的代码与定律绑定。

## 适用范围 [#fit]

将定律用于决定资金、访问或安全，且有限或基于整数运算的规则：模式、权限、状态、阈值、时间窗口、舍入。字符串、解析器、JSON、浮点数（Bend 的 F32 是公理化的，并且没有 F64）以及 UI 则改用基于属性的测试（fast-check、rapid）；证明它们的成本高于收益。

## 归属 [#ownership]

| `laws/<rule>/` 中的文件 | 归属 |
|---|---|
| `LAWS.bend` | 人类。`bend-laws-guard` hook 会拒绝代理写入；人类可通过 `BEND_LAWS_AUTHOR=1` 为会话开启授权。 |
| `policy.bend`（模型）、`PROOF.bend`、`oracle.bend` | 代理 |
| `decisions.txt` | 由 `laws/check.sh --write` 生成 |

## 工作流程 [#workflow]

1. 阅读已发布的规则及其测试。列出每个输入及其返回的决策。完成标准：输入域已穷举（有限）或其边界已命名。
2. 在临时目录中以 `LAWS_draft.bend` 起草定律（导入路径只允许字母、数字、`_` 和 `-`），并在那里证明它们。为每条定律写一条通俗易懂的注释。完成标准：人类已审阅草稿并将其提交为 `LAWS.bend`。
   - 只调用被测函数。把定律用到的每个辅助函数都定义在 `LAWS.bend` 中，这样模型就无法通过重新定义词汇来削弱定律。
   - 说明必须成立的内容。定律未规定的任何内容都由模型决定，因此每条禁止（“从不运行 X”）都要配上一条要求（“只运行声明了 Y 的内容”）。
   - 导入的构造器要带限定前缀和花括号：`case P.Yes{}:`。在导入类型上裸写 `case Yes:` 会绑定所有值，定律会空洞地通过（bendlang/bend#1328）；`check.sh` 和 hook 都会拒绝它。
3. 在 `policy.bend` 中为规则建模，保持与已发布代码相同的分支顺序，并在 `PROOF.bend` 中以 `def Laws.<law>(...)` 证明每条定律。完成标准：`bend PROOF.bend` 输出 `ALL PROOFS CHECK`。
4. 针对每条定律对模型做一次变异：修改该定律守护的一个分支，确认 `bend PROOF.bend` 在该定律处输出 `SOME PROOFS FAIL`，然后还原。完成标准：每条定律都拒绝过一个变异体。没有任何变异体能使其失败的定律是空洞的。
5. 编写 `oracle.bend`，其 `main` 输出 `# @generated` 头部，并为每个输入输出一行 `<inputs> <decision>`，然后运行 `laws/check.sh --write`。
6. 比对已发布的代码：单元测试解析 `decisions.txt`，并断言已发布函数对每一行都返回相同结果。对于有限域，还要断言每个输入恰好出现一次，并从代码的类型推导输入域，这样新增值会导致构建失败。对于无界域，用基于属性的测试生成输入，把定律的边界值作为种子，并与用 `bend -o model.mjs` 编译的模型比对。完成标准：已发布代码中的变异体会使测试失败。
7. 将 [templates/install-bend.sh](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bend-laws/templates/install-bend.sh) 和 [templates/check.sh](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bend-laws/templates/check.sh) 复制到 `laws/`，然后添加一个运行两者的必需 CI 作业。为 `laws/**/LAWS.bend` 和 `laws/**/decisions.txt` 添加 CODEOWNERS。完成标准：缺少 `LAWS.bend` 时作业失败，添加后作业通过。

修改规则时：由人类编辑定律，代理更新模型和证明，运行 `check.sh --write`，然后修改已发布代码，直到其单元测试一致。把每个 `decisions.txt` 的 diff 都当作行为变更来审查。

编写 Bend 之前，先运行 `bend guide`；阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bend-laws/REFERENCE.md)，了解语法陷阱、证明模式、`--verdict` 配置和升级。

## 护栏 [#guardrails]

- 向人类提议定律变更；绝不编辑 `LAWS.bend`，也不要绕过 hook。
- 让 `@unsafe`、`def f?` 和外部代码远离定律目录：它们会关闭证明所依赖的可靠性。Bend 的门禁和 `check.sh` 都会拒绝它们。
- 在 `install-bend.sh` 中固定 Bend 版本；有计划地升级并重新证明。
- 源代码保留在本机：将代码发送给 BendAI 或发布到 Bend hub 需要明确批准。
