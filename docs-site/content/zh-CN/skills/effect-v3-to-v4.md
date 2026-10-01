---
title: "/effect-v3-to-v4"
description: "将代码库从 Effect v3 迁移到 v4，或跨越 v3/v4 边界升级 `effect` 或任意 `@effect/*` 包时使用。"
type: skill
sidebar:
  label: "/effect-v3-to-v4"
---
![/effect-v3-to-v4 技能图](/diagrams/skills/effect-v3-to-v4.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/effect-v3-to-v4.excalidraw)

依据上游迁移数据确定重命名、移除和签名变更，不猜测替代方案。

## 工作流程

1. 按下方说明准备并验证本地检出目录。
2. 完整阅读一次 `.repos/effect/MIGRATION.md`，并列出 `.repos/effect/migration/`。
3. 阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md)，然后在首次类型检查前迁移 `package.json`：移除已合并的包，并对齐其余版本。
4. 运行项目的类型检查，获取初始错误清单。
5. 按下方阅读顺序解决每个错误，修复调用处，反复检查直至没有错误。除非用户明确要求委派，否则在主会话内完成。
6. 运行项目测试和质量检查；报告结果和未解决的问题。遵守用户要求的最终目标和仓库的完成约定。

## 本地检出目录

独立浅克隆两份规范的 Effect 仓库：

```sh
git clone --depth 1 --single-branch --branch main https://github.com/Effect-TS/effect .repos/effect
git clone --depth 1 --single-branch --branch v3 https://github.com/Effect-TS/effect .repos/effect-v3
```

- `.repos/effect`：v4 迁移指南和源码。
- `.repos/effect-v3`：v3 源码，仅用于澄清旧语义。

重用任一目录前，验证其 origin、分支、版本和工作区状态。v4 检出目录必须包含 `MIGRATION.md` 和 `migration/v3-to-v4.md`：

```sh
git -C .repos/effect remote get-url origin
git -C .repos/effect branch --show-current
git -C .repos/effect status --short
node -p "require('./.repos/effect/packages/effect/package.json').version"
```

对 `.repos/effect-v3` 重复检查（分支 `v3`，版本 `3.x`）。v4 必须使用规范的 `Effect-TS/effect` origin、`main` 分支和 `4.x` 版本。旧的 `Effect-TS/effect-smol` 检出目录不是有效的迁移来源。保留已有目录和用户改动；报告不匹配，选择一个独立且未使用的克隆目录，并更新查找路径。不要删除或重置已有目录。

## 阅读顺序

1. `.repos/effect/MIGRATION.md`：迁移背景和主题索引，仅阅读一次。
2. `.repos/effect/migration/v3-to-v4.md`：每个 API 的首要参考。搜索匹配的符号或模块标题，仅阅读有限的上下文。**切勿完整阅读这一生成的参考文档。**
3. `.repos/effect/migration/*.md`：映射需要结构性重写而非简单重命名时，阅读主题指南。
4. `.repos/effect/packages/*/src/`，包括 `unstable/`：使用替代 API 前确认其真实签名。
5. `.repos/effect-v3`：仅在旧语义不明确时使用。

[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md) 包含查找示例和包级变更。在认定缺少映射前，检查 Removed Modules 和 No Counterpart Imports。报告未映射的问题，不编造 API。

## 安全约束

- 将调用处迁移到 v4；不要重新引入模拟 v3 的兼容层。
- 依据参考资料和源码解决类型错误，不使用 `any`、类型断言或类型检查抑制手段。
- 每个替代方案必须能够追溯到映射、主题指南或 v4 源码。
- 只有在明确获准委派后，才为每个智能体分配互不重叠的文件、待解决符号、阅读顺序和这些约束。要求返回修改和映射；由主会话维护错误清单。未经单独授权，不得嵌套委派。

## 完成条件

项目通过针对 v4 的类型检查及仓库要求的检查。报告类型检查和测试结果（或无法运行检查的原因）、构建的替代方案及未映射的问题。不要削弱测试以使其通过，也不要在必要验证受阻时声称完成。
