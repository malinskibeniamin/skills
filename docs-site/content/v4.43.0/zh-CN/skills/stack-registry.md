---
title: /stack-registry
description: 管理当前及已禁用的前端技术栈。适用于添加特定于库的规则、启动技术栈迁移、废止旧指南或检查过时 API。
type: skill
sidebar:
  label: /stack-registry
---
![／stack-registry 技能示意图](/diagrams/skills/stack-registry.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/stack-registry.excalidraw)

Harness 规则分为两种持久性类别。**不变量**（参见 `/frontend-invariants`）永不过期。**技术栈规则**会明确指定某个库或 API，并且必须标记技术栈代次，以便下次迁移时整体替换，而不会遗留误导智能体的过时指南。历史教训：四套已淘汰技术栈的规则集在代码完成迁移很久后，仍作为“当前指南”留存——本技能正是为了防止这种故障模式。

## 当前技术栈（`stack:2026`）

| 层级 | 当前选型 | 规则所在位置 |
|---|---|---|
| UI 工具包 | Tailwind v4 + shadcn/Base UI + 内置副本的注册表 | registry-workflow、visual-review、tailwind hooks |
| 路由 | TanStack Router（基于文件、加载器、validateSearch） | tanstack-router |
| 数据 | connect-query + gRPC + protobuf-es v2 + protovalidate | connect-query |
| 表单 | react-hook-form（以及由 proto 驱动的解析器）；zod 仅用于路由搜索参数 schema | form-mode hooks |
| 客户端状态 | zustand + React 上下文 | zustand hooks |
| React | 19 + Compiler（不手动使用 memo，不使用 forwardRef） | react-rules hooks |
| 构建/测试 | rsbuild / vitest 四层测试体系（以及浏览器基线）/ Playwright | test-convention hooks、e2e-testing |

## 已禁用的技术栈（通过机制冻结）

通过钩子和 lint 禁令强制执行——绝不推荐，绝不接受用于新代码，也绝不引用其惯用写法作为指南：

`chakra` / 旧版共享 UI 工具包 · `react-router-dom` · Redux Toolkit Query / redux-observable · MobX（`observer`、`makeObservable`、`useLocalObservable`）· Formik · Yup · react-intl / `FormattedMessage` + i18n 字典机制 · CRA/react-scripts/jest 惯用写法 · nuqs（搜索参数类型由路由器负责）。

每项禁令最多保留一条元层面的经验（例如，从 Yup 中保留了“验证格式，而不只是是否存在”，但不保留其实现机制）。挖掘或引用历史代码审查指南时，任何涉及已禁用技术栈的内容都属于历史证据，而非操作指引。

## 迁移操作手册（当某一层发生变化时）

1. **先充分论证**：路由器/框架层采用一次性整体迁移，数据层采用绞杀者模式；为数据层持续数月的共存期预留预算。
2. 编写新技术栈的规则组，并使用新代次标记。
3. 在同一个 PR 中废止旧规则组：将对应库移入禁用表，添加机制化禁令（钩子/`noRestrictedImports`），并删除其指南或为其添加时代标签。
4. 在同一个 PR 中更新范例——模型模仿范例的倾向强于遵循规则。
5. 迁移的完成定义包含冻结措施；未被禁用的已淘汰技术栈必定会被作为作者的 LLM 重新启用。

## 规则编写检查清单

添加任何指明库/API 的规则时：(a) 它实际上是否是伪装成技术栈规则的不变量？若是，请在 `/frontend-invariants` 中以不依赖具体库的方式表述；(b) 在其所属技能/钩子中使用 `stack:2026` 标记；(c) 尽可能为其提供机制化检查——未强制执行的规则会逐渐失效；(d) 补充反向约束：钩子现在必须拒绝哪种已被取代的模式？
