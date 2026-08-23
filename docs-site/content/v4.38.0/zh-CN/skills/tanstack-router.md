---
title: /tanstack-router
description: 为 Query 所有权和类型化搜索应用 TanStack Router 模式。在更改路由、加载器、导航、路由树或搜索参数时使用。
type: skill
sidebar:
  label: /tanstack-router
---
![“/tanstack-router”技能示意图](/diagrams/skills/tanstack-router.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/tanstack-router.excalidraw)

请先遵循 `/tanstack-intent`，并加载已安装 Router 包随附的匹配指南。Intent 负责当前 API 语法和版本行为。此技能补充本地所有权和 URL 状态策略。请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-router/REFERENCE.md) 了解本地代码结构，并阅读 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-router/SETUP.md) 了解安装方法。

## Router + Query

- Router 加载器在产生导航意图后启动服务端请求。
- TanStack Query 负责缓存、重新获取、失效和垃圾回收。
- 组件通过 `useQuery` 或 `useSuspenseQuery` 观察 Query。

路由已知的 Query 输入只有一条管线：`validateSearch` -> `loaderDeps` -> 一个 `queryOptions` 构建器 -> 加载器和组件观察者。仅返回查询使用的搜索字段。组件使用 `useLoaderDeps`，而不是另外读取驱动查询的搜索状态。如果已安装的 Router 指南支持在路由 `context` 中构建选项，请共享完全相同的选项值；切勿采用示例中未记录的语法。

- 页面关键数据：等待 `ensureQueryData`；使用 `useSuspenseQuery` 观察。
- 路由已知的延迟数据：在加载器中启动；使用 `useQuery` 观察，并提供可见的加载、空状态和错误状态。
- 仅用于交互的数据可以从组件启动。

由 Query 支持的加载器应设置 `defaultPreloadStaleTime: 0` 并使用 `createRootRouteWithContext`。

## 导航生命周期

将资源、导航、结果和渲染的所有权彼此分离：

- 被取代的导航失去发布权限；共享的加载器或 Query 工作仍可继续发挥作用。
- `beforeLoad` 用于可安全重放的身份验证、重定向或上下文构建。预加载和导航都可能运行它；不要在其中执行可观察的副作用和常规数据获取，以便加载器保持并行。
- 直接的加载器请求传递 `abortController.signal`。Query 函数传递由 Query 拥有的信号。不要在每次导航时全局取消共享工作。
- 来自 `beforeLoad` 或加载器的重定向使用 `throw redirect(...)`，而不是命令式导航。
- 使用 `onResolved` 处理分析和非 DOM 清理。使用 `onRendered` 处理焦点、滚动、测量或其他需要已提交路由内容的工作。
- 使用 Router 的待处理界面及其计时选项，而不是自行构建导航计时器。

## 路由规则

- 使用 `{ from }` 或路由 API 限定 `useParams`、`useSearch`、`useLoaderData` 和 `useRouteContext` 的作用域；禁止使用 `strict: false`。
- 由 Query 支持的组件读取 Query，而不是 `Route.useLoaderData`。
- 路由文件仅导出路由配置；可复用组件应放在其他位置。
- 导航使用路由器 API，而不是 `window.location`。
- `react-router-dom`、`URLSearchParams` 和 nuqs 都属于迁移技术债。
- 路由树变更后需触发生成。

## 搜索参数

路由器通过 `validateSearch` 负责搜索参数的类型定义。

- URL：可共享的标签页、筛选条件、排序方式和页码。
- 存储：个人的界面密度、每页条数和折叠状态。
- 验证枚举、日期和有界数字；将过期的页面索引限制在有效范围内。
- 基于之前的搜索状态合并更新。
- 在某个分区内部使用 `replace: true`，以便按“后退”时退出该分区。

## 完成标准

- 类型能够证明路由和搜索参数的作用域正确。
- 加载器和观察者使用同一个 Query 选项构建器及由加载器拥有的输入。
- Query 数据有活跃的观察者，并具备完整的可见状态。
- 快速导航或预加载导航无法发布过期的路由界面，也不会重复执行应用所拥有的工作。
- 导航测试在 URL 更改后断言已渲染的路由地标。
- 导航保留浏览器历史记录语义。
- 搜索 URL 能够处理格式错误、已过期和共享的值。
- 路由树、相关测试、类型检查和代码检查均通过。
