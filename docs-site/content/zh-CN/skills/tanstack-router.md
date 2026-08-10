---
title: /tanstack-router
description: 为 Query 所有权和类型化搜索应用 TanStack Router 模式。在更改路由、加载器、导航、路由树或搜索参数时使用。
type: skill
sidebar:
  label: /tanstack-router
---
![“/tanstack-router”技能示意图](/diagrams/skills/tanstack-router.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/tanstack-router.excalidraw)

请先遵循 `/tanstack-intent`，并加载已安装 Router 包随附的匹配指南。Intent 负责当前 API 语法和版本行为。此技能补充本地所有权和 URL 状态策略。请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/REFERENCE.md) 了解本地代码结构，并阅读 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/SETUP.md) 了解安装方法。

## 所有权

- Router 加载器在产生导航意图后启动服务端请求。
- TanStack Query 负责缓存、重新获取、失效和垃圾回收。
- 组件通过 `useQuery` 或 `useSuspenseQuery` 观察 Query。

对页面关键的阻塞式数据使用 suspense；对延迟加载的数据使用常规查询，并提供内联的加载、空状态和错误状态。由 Query 支持的加载器应设置 `defaultPreloadStaleTime: 0` 并使用 `createRootRouteWithContext`。

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
- Query 数据有活跃的观察者，并具备完整的可见状态。
- 导航保留浏览器历史记录语义。
- 搜索 URL 能够处理格式错误、已过期和共享的值。
- 路由树、相关测试、类型检查和代码检查均通过。
