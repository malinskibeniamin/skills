---
title: "/ux-performance"
description: "审计并优化真实 Web 用户体验性能。适用于缓慢的 SPA 页面、路由、交互、超大表格、加载、缓存、内存、Web Vitals、Lighthouse、性能预算或 CI 回归。"
type: skill
sidebar:
  label: "/ux-performance"
---
![/ux-performance 技能示意图](/diagrams/skills/ux-performance.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/ux-performance.excalidraw)

让用户更快到达有用且响应灵敏的状态。优化经过测量的关键路径，而不是仅仅看起来
昂贵的代码。默认按客户端 Web 应用处理；只有证据表明交付层或后端延误用户旅程时，
才继续追查这些层。

## 建立性能契约

实施前明确：

- **旅程**：路由、操作、起始状态、数据量、设备和网络等级，以及冷缓存或热缓存。
  不只覆盖理想路径，还要包含可信的最坏负载。
- **里程碑**：用户可见的结果，例如有用内容、筛选结果或下一帧绘制完成。加入正确性
  和无障碍护栏。
- **主要指标**：该里程碑的直接耗时或资源上限。
- **最小有效变化**：可重复的 100 毫秒改进有价值；落在噪声内的变化没有价值。
  编辑前固定一个主要指标。
- **终点**：审计、优化或安装回归检查。审计只返回发现，不编辑代码；优化持续到本地
  变更验证完成；CI 工作只安装校准过的检查。

## 执行循环

1. **盘点**真实技术栈、生产构建路径、现有遥测、分析器、测试、预算和已安装包版本。
   更改框架或库语法前，先阅读当前的第一方文档。
2. **改代码前测量基线**。在接近生产的构建中复现相同场景和固定数据。当 `.context/`
   被忽略时，把原始跟踪保存到 `.context/ux-performance/<journey>/`。按
   [MEASUREMENT.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/MEASUREMENT.md) 合并真实用户和实验室证据。
3. **建立瀑布图**，从用户意图一直到结果完成绘制。标记串行依赖、并行或非关键路径工作、
   缓存状态和最长的关键路径区段。把时间归因到排队、网络和 TTFB、下载、解析和执行、
   应用工作、React 渲染和提交、样式、布局及绘制。
4. **按瓶颈排序**，不要按审计警告排序。提出 3–5 个可证伪假设，然后每次只改变一个
   因果变量。优先删除工作、缩小输入或移除串行依赖，再考虑加速相同工作。
5. 使用 [OPTIMIZATION.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/OPTIMIZATION.md) 中最窄且有证据支持的方案进行**干预**。包装器、上下文、缓存、
   worker、编译器、框架升级、预取或服务端渲染都是候选方案，不是默认收益。
6. **验证**基线和候选方案：使用相同场景、固定数据、机器、浏览器、构建和缓存状态。
   使用配对运行，报告中位数和离散程度。重新检查正确性、无障碍、内存、bundle 和错误护栏。
7. **决策**。只保留明确且有价值的收益。若结果落在方差内、把成本转移到别处或破坏护栏，
   报告 `Value not proven — inconclusive` 并撤销推测性复杂度。不要事后挑选指标。
8. 仅在用户要求或终点包含 CI 时**防止复发**。按 [CI.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/CI.md) 把稳定廉价的检查放进 pull request，把噪声大或深入的检查放到夜间任务，并在部署后进行真实用户监控。Hook 在校准前只能作为可选建议。

当性能主张涉及规模、突发负载、资源争用或长会话时，使用
[STRESS.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/STRESS.md) 找到容量拐点，并验证压力下的正确性。

## 输出

首先给出用户结果和最慢区段：

```md
Verdict: <测量状态或价值结论>

| 排名 | 瓶颈 | 关键路径成本 | 证据 | 下一项变更 | 置信度 |
|---:|---|---:|---|---|---|
| 1 | <原因，而非症状> | <毫秒/字节/工作量> | <跟踪/分析> | <小范围干预> | <高/中/低> |

Method: <精确命令、构建、固定数据、缓存、设备/网络、运行次数、基线/候选>
Guardrails: <正确性、无障碍、错误、内存、bundle>
Artifacts: <路径或链接>
```

区分测量事实、推断和未经测试的机会。绝不能仅凭 Lighthouse 分数、静态警告、
看似更少的代码或依赖升级就声称速度提升。
