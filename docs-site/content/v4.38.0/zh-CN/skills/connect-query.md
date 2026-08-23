---
title: /connect-query
description: >-
  使用 Connect Query 和 Protobuf v2 构建类型安全的 ConnectRPC 数据流。适用于 API
  调用、变更操作、查询钩子、传输层、缓存失效或生成的客户端。
type: skill
sidebar:
  label: /connect-query
---
![/connect-query 技能示意图](/diagrams/skills/connect-query.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/connect-query.excalidraw)

在确定当前 ConnectRPC、Connect Query 或 Protobuf API 指南之前，请先运行 `/read-the-damn-docs`。
## 此技能可捕获的问题

- 当文件使用 ConnectRPC 时，**禁止从 `@tanstack/react-query` 直接使用 `useQuery`/`useMutation`**——应使用 Connect Query（例外：`useTransport`/`callUnaryMethod` 模式）
- **禁止无参数调用 `invalidateQueries()`**——必须指定查询键
- **对 `axios`/`fetch()` 发出警告**——优先使用 ConnectRPC 传输层
- **Protobuf v2**：禁止使用 `new Message()` -> 改用 `create(Schema)`。禁止使用 `PlainMessage`/`PartialMessage` -> 改用 `MessageShape`/`MessageInitShape`。禁止手动编写 `$typeName` 字面量。

豁免方式：`// allow: direct-query [reason]`

## 查询层规范（提炼自 4 年的代码审查记录）

- **使用缓存层级，而非魔法数字**：在一个文件中定义 2–3 个语义化常量（`SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME`）；仅当数据只会通过你自己的失效操作发生变化时，才使用 `Infinity`。重试策略应统一定义在 QueryClient 上（对 5xx/网络错误重试，绝不对 4xx 重试）。
- **在钩子中使用 `transform`/`select`，绝不在组件中解析**——组件接收可直接展示的数据；分页大小由钩子强制执行，而不是在调用处解析。
- **使缓存失效，不要重新获取；始终等待其完成**——即发即弃的失效操作会与导航产生竞态，导致下一个页面渲染陈旧缓存。查询键：按服务/方法划分较宽泛的范围（对无限查询要考虑基数），绝不过度具体。
- **加载器 <-> 钩子的查询键必须一致**——如果路由加载器使用略有不同的查询键预取数据，就会在不易察觉的情况下重复获取。请在测试中断言查询键相等。
- **每个 RPC 对应一个钩子；拆分调用多个 RPC 的页面**，使每个服务调用都有各自的数据钩子。变更钩子以 `Mutation` 结尾（自行管理提示消息时以 `WithToast` 结尾）。
- **验证方向**：客户端 Proto 验证（protovalidate）适用于你发送的数据。响应已经过服务端验证——不要再次验证读取的数据。
- **Proto 可选字段应为 `undefined`，绝不能为 `null`**；无界列表使用无限查询 + “加载更多”；轮询使用内置的 `refetchInterval`，不要自行实现计时器。

Protobuf 注意事项（Timestamp、Duration、Any、缓存模式）：[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/connect-query/REFERENCE.md)。设置：[SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/connect-query/SETUP.md)。
