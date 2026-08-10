---
title: /golang
description: 应用基于证据的 Go 规则，涵盖边界、API、错误、并发、Temporal、测试、发布和控制器。适用于修改 Go 服务、处理程序、工作流或测试。
type: skill
sidebar:
  label: /golang
---
![“/golang”技能示意图](/diagrams/skills/golang.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/golang.excalidraw)

这些约定综合自两年来对多个代码仓库的审查：共 102 条规则，每条规则均有至少三个独立示例支持。本文件包含核心内容；领域文件包含实际工作指南；匿名汇总支持材料位于 `/golang-review` 的[规则目录](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md)。`/aip` 负责 proto 资源的*设计*；本技能负责其周边的 Go *实现*。

## 不可妥协的规则（S 级）

- **对所有由工作负载或租户控制的内容设置边界**：内存、基数、扇出、并发数、响应大小。无边界输入会导致内存溢出和基数失控。
- **使用生成的 getter 遍历 proto**——使用 `a.GetB().GetC()`，绝不使用层层 nil 检查。
- **字段契约由 proto 注解定义**（行为、必填性、边界）；绝不在处理程序中重复验证。
- **仅在需要表达存在性语义时使用 `optional`**：如果零是合法值，则不要使用 `optional`；更新意图由字段掩码承载。
- **集合使用 `List`**——支持分页和筛选；`Get` 只返回一个资源。
- **在 API 边界转换错误**：记录内部原因，返回具有稳定原因和公开字段路径的结构化 Connect/gRPC 错误。在传递过程中保留上游协议的粒度（Kafka 的逐分区粒度、逐项粒度）。
- **安全谓词必须失败关闭**：配置缺失、许可证或授权后端出错、策略状态不完整时都应拒绝——绝不能默认允许。
- **密钥使用引用**：绝不接受、存储、返回或记录明文密钥材料。
- **重试和退避必须适配操作生命周期**：加入抖动、设置最大边界，并确保累计时间范围处于所属超时之内。
- **配置使用语义类型**：复用代码仓库中的配置结构体（`config.TLS`、时长、枚举），绝不使用裸字符串和布尔值组合。
- **使用功能开关保护有风险的混合版本发布**；开关是迁移工具，应在整个服务集群版本收敛后移除。
- **服务器和引导文件负责装配；包负责行为**——`server.go` 中只进行构造和装配。
- **集成测试必须跨越真实边界**；模拟对象无法证明提供商、计费或序列化兼容性。
- **测试应断言稳定且可观察的行为**，而不是执行路径或偶然出现的消息文本。

## 权衡——由上下文决定，不要一概而论

- 为提高可读性，配置布尔字段采用肯定式命名——**但**如果 Go 零值在安全路径上必须失败关闭，则使用否定式 `disabled` 字段才是正确做法。
- 只有当枚举 switch 声称覆盖整个取值域时，才应在遇到未知值时失败；有意只覆盖子集的 switch 应记录并忽略其余值。
- gRPC keepalive 取决于每个中间组件是否都能识别它；不存在通用设置。
- 兼容 AIP 的接口使用有边界的筛选字符串；已有的类型化筛选 API 应保留其对象结构以维持兼容性。
- 单元测试可以自由模拟依赖；一旦测试声称验证边界兼容性，就必须跨越真实协议、角色、提供商或容器。

## 领域文件

| 工作内容 | 阅读 |
|---|---|
| Proto、处理程序、Connect/gRPC 接口、公开错误 | [PROTO-API.md](https://github.com/malinskibeniamin/skills/blob/main/golang/PROTO-API.md) |
| Goroutine、通道、缓存、关闭、共享状态 | [CONCURRENCY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONCURRENCY.md) |
| 错误包装和分类、日志记录、指标 | [ERRORS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ERRORS.md) |
| 任何 `_test.go`、测试夹具、CI 行为 | [TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TESTING.md) |
| Temporal 工作流、活动、信号 | [TEMPORAL.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TEMPORAL.md) |
| 租户输入、出站访问、授权、密钥、破坏性操作 | [SECURITY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/SECURITY.md) |
| 配置接口、功能开关、弃用、模式或字段移除 | [ROLLOUT.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ROLLOUT.md) |
| 包边界、存储层、接口 | [STRUCTURE.md](https://github.com/malinskibeniamin/skills/blob/main/golang/STRUCTURE.md) |
| Kubernetes Operator 和协调器 | [CONTROLLERS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONTROLLERS.md) |

## 钩子

编辑时会运行两项机械检查；两者都只发出警告，绝不会阻止操作：

- `go-proto-reserved`：移除已发布的 proto 字段时，必须添加 `reserved N;` 和 `reserved "name";`；重新编号绝不安全。豁免方式：`// allow: proto-unshipped [reason]`。
- `go-test-image-pin`：测试或容器镜像必须固定到受支持的发布标签，绝不能使用 `:latest`/`:main`/`:master`。豁免方式：`// allow: floating-image [reason]`。

是在审查差异而不是编写代码？请使用 `/golang-review`。
