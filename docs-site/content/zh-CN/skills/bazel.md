---
description: >-
  构建、测试和诊断涵盖 Go、C++、TypeScript 与 React 的 Bazel 单体仓库。适用于
  BUILD/Starlark、Bzlmod、工具链、缓存、开发循环、受影响目标的 CI 和发布制品。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bazel
sidebar:
  label: /bazel
title: /bazel
type: skill
---
![/bazel 技能示意图](/diagrams/skills/bazel.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/bazel.excalidraw)

让声明的构建图重现所需行为。仓库维护的封装脚本、宏、固定版本和 CI 策略
优先于这些通用指导。

## 确定构建契约 [#establish-the-build-contract]

- 确认 Bazel 工作区根目录、`.bazelversion`、根 `MODULE.bazel`、适用的
  `.bazelrc` 导入、组件说明和实际 CI 入口。通过仓库的 Bazelisk 或封装脚本
  使用固定的 Bazel 版本，而非全局升级的二进制文件。单机覆盖配置放在现有的、
  被 Git 忽略的用户 rc 文件中。
  对照这些固定版本验证新标志、Starlark 注解语法和规则；会议演示与路线图条目
  不是已发布的 API 契约。
- 区分**哪些部分有 BUILD 文件**与**哪些部分目前由 Bazel 管理**。生成的目标
  不能证明 CI 已采用它们。检查已合并的源代码，而不是中间提交、草拟的推广计划
  或前身仓库。
- 保持单体仓库的单一根模块边界。在根目录集中声明依赖和工具链；新增嵌套的
  `MODULE.bazel` 可能使通配符发现过程看不到子树。将有意分离的工作区视为独立
  构建，不要顺便合并。
- 对 Go/Task/Gazelle 目录树，阅读 [Go 单体仓库](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/go-monorepo.md)。
  对 C++、交叉编译、加速器或通过构建图选择的集成，阅读
  [C++ 单体仓库](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/cpp-monorepo.md)。
  对前端或 Node 集成，阅读 [TypeScript 与 React](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/typescript-react.md)。仅加载相关分支说明。
- 对多应用拓扑、本地编排、受影响目标 CI、缓存、执行或选择性发布，阅读
  [单体仓库规模化](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/monorepo-scale.md)。
  研究采用方案或选择脚手架时，阅读固定版本的
  [社区示例及其限制](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/community-examples.md)。

## 选择增量循环 [#choose-the-incremental-loop]

区分动作复用、基于 Git 的目标选择、浏览器 HMR 和部署。Bazel 负责已声明的
构建、测试和制品依赖；前端工具负责 Fast Refresh，编排负责服务生命周期和发布。
只启动本地应用所需的依赖闭包，而不是所有应用。保留现有框架和包管理器；先证明
一个纵向切片可用，再将其标准化。在承诺提速前测量冷构建、热构建、无变化构建
及代表性修改；添加 Bazel 本身不能证明性能改善。

## 编辑前找到负责入口 [#find-the-owner-before-editing]

阅读最近的 BUILD 文件及其加载的宏。查找现有标签，不要猜测二进制文件、镜像或
测试目标。明确声明依赖、生成源码和运行时文件边；`deps` 与测试 `data` 解决的
问题不同。

按问题选择构建图（[查询语义](https://bazel.build/query/cquery)、
[动作图](https://bazel.build/query/aquery)）：

| 问题 | 工具 |
|---|---|
| 存在哪些测试或使用方，哪些可达某个文件？ | `query`、`tests(...)`、有限范围的 `rdeps(...)` |
| 哪个 `select()` 分支、平台或依赖生效？ | 使用失败构建配置的 `cquery` |
| 动作使用哪个编译器、标志、输入和输出？ | 使用相同配置的 `aquery` |

`query` 包含可能的配置分支，不能证明目标已执行。`aquery` 描述动作，但不会将其
生成输入实体化。部分输出或错误代表证据不完整，绝不等同于没有受影响目标。

## 修改并验证 [#change-and-verify]

1. 用失败目标或公共契约测试重现缺陷。仅修改构建时，可以将失败的分析、编译、
   格式检查或规则测试作为 RED。
2. 编辑负责的源文件、生成器输入或宏。用仓库的生成器重新生成派生 BUILD 文件，
   使用仓库的格式化工具并检查差异。保留有意设置的可见性、兼容性、标签和数据。
3. 修改依赖时，按需更新权威的语言清单或根模块，再执行规定的模块整理或锁文件
   更新。将生成的元数据一起提交。遵守 CI 的锁文件模式；在本地修复过期锁文件，
   不要删除它们或放宽 CI。参阅[锁文件模式](https://bazel.build/external/lockfile)。
4. 在相关配置下构建和测试最小的变更目标，再验证受影响的使用方。共享宏、根依赖、
   工具链和配置变更需要仓库规定的更广矩阵。不兼容平台的目标、手动目标和被过滤的
   集成目标不算通过；明确列出未测试的分支。

## 诊断时保留证据 [#diagnose-without-destroying-the-evidence]

- 重放完全相同的标签、配置、目标平台和执行平台。使用 `--announce_rc` 与
  `--verbose_failures`；仅在重现失败时添加 `--sandbox_debug`。修改标志前，
  检查合并后的 rc 选项及动作输入。
- 区分分析或标签错误、仓库拉取或认证失败、工具链或平台不匹配、沙箱或 runfiles
  失败、缓存传输问题与测试失败。修复负责的层，不要全局禁用沙箱、警告、
  sanitizer 或兼容性约束。
- 遇到 macOS 符号链接逃逸、原生工具路径解析、沙箱创建开销或通过 REAPI 在本地
  虚拟机中执行的问题时，阅读[本地执行](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/local-execution.md)。
- 区分仓库下载缓存、动作缓存和远程执行。远程缓存不是远程执行器。遵循已提交的
  缓存和上传策略；不要把私有端点或凭据写入受版本控制的配置。
- 最初保留热缓存。`clean`、`expunge`、删除锁文件或新建输出基目录都不是首选
  修复方法。如需隔离，说明假设，并只重置自己负责的重现场景。
- 确实需要重新运行测试时，限定范围并使用 `--nocache_test_results`。否则，缓存结果
  对其已声明输入仍是有效证据；如实区分缓存与实际执行。使用最小下载策略时，
  输出使用方可能需要显式获取实体文件（[远程缓存](https://bazel.build/remote/caching)）。

返回变更的图契约、确切目标、配置和检查结果，包括跳过或受阻的分支。构建镜像
不代表获准推送或部署镜像。关于来源和更新限制，阅读
[研究依据](https://github.com/malinskibeniamin/skills/blob/main/bazel/references/research-basis.md)。
