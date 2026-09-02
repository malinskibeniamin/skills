---
title: "/install-anti-slop"
description: "在使用 Oxlint 或 Biome 的 TypeScript 或 JavaScript 仓库中安装精选的 anti-slop 检查，包括使用 Biome 后端的 Ultracite。适用于添加 anti-slop、防止类型证据被掩盖，或更新现有本地 anti-slop 配置。"
type: skill
sidebar:
  label: "/install-anti-slop"
---
![展示 /install-anti-slop 技能的示意图](/diagrams/skills/install-anti-slop.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/install-anti-slop.excalidraw)

通过仓库现有的代码检查器添加配置。保留其包管理器、代码检查归属、配置风格和无关工作。
切勿仅为 anti-slop 引入第二个代码检查器。

## 选择配置

1. 阅读仓库说明并检查 `git status`。检查直接依赖项、锁文件以及现有的 Biome、
   Ultracite、Oxlint 或 Vite+ 配置。
2. 只选择一个现有后端：
   - **Oxlint：**安装精选的三条语义规则。
   - **Biome 或使用 Biome 的 Ultracite：**安装两条结构规则。Biome 的
     [GritQL 插件](https://biomejs.dev/linter/plugins/)不提供符号或作用域分析，因此此配置
     有意省略 `no-widen-then-assert`；unknown 别名检查仅覆盖直接的 `unknown` 和联合类型中的
     直接成员，不解析别名链。
3. 如果仓库未使用任何受支持的代码检查器，请保持仓库不变并说明原因。

## Oxlint

1. 从包管理器或锁文件中确定已安装的 `oxlint` 版本。以开发依赖项形式安装完全相同版本的
   `@oxlint/plugins`。
2. 将随附插件复制到目标仓库：

   ```bash
   node <skill-directory>/scripts/install.mjs
   ```

   默认目标路径为 `tools/oxlint/anti-slop/`。
3. 将插件合并到现有配置中，不替换其他条目：

   ```ts
   {
     ignorePatterns: ["tools/oxlint/anti-slop/**"],
     jsPlugins: [
       { name: "anti-slop", specifier: "./tools/oxlint/anti-slop/index.ts" },
     ],
     rules: {
       "anti-slop/no-chained-type-assertions": "error",
       "anti-slop/no-unknown-type-aliases": "error",
       "anti-slop/no-widen-then-assert": "error",
     },
   }
   ```

   对于 Vite+，请将相同条目合并到 `lint` 下，并将随附路径添加到 `fmt.ignorePatterns`。

## Biome

1. 要求 Biome 2.5.9 或更高版本。扩展 `ultracite/biome/*` 的 Ultracite 配置符合要求。
2. 复制 GritQL 插件：

   ```bash
   node <skill-directory>/scripts/install.mjs --biome
   ```

   默认目标路径为 `tools/biome/anti-slop/`。
3. 将两个路径合并到现有的 `plugins` 数组：

   ```json
   {
     "plugins": [
       {
         "path": "./tools/biome/anti-slop/no-chained-type-assertions.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       },
       {
         "path": "./tools/biome/anti-slop/no-direct-unknown-type-aliases.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       }
     ]
   }
   ```

## 完成

安装程序会拒绝路径越界和已存在的目标。必要时请提供另一个相对于仓库的目标路径。仅在备份并检查
现有 anti-slop 安装后使用 `--force`。

运行仓库的代码检查和类型检查命令。除非用户明确要求仅修改配置，否则应将安装请求视为迁移范围，
并修复所负责代码中由此产生的问题。切勿仅为通过检查而弱化规则或添加忽略项。报告所选配置、复制
路径、依赖项和配置变更、验证结果以及未解决的问题。

## 归属

Oxlint 核心是
[`dmmulroy/anti-slop` v0.1.2](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c)
的本地分支。复制的 `LICENSE` 保留上游 MIT 条款。Biome GritQL 配置是结构化改编，其较窄的约定
已在上文说明。请将安装的文件视为项目自有文件，并在移植上游或 Biome 变更前进行审查。
