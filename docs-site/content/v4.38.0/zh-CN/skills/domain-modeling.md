---
title: /domain-modeling
description: 构建并完善项目的领域模型。适用于讨论代码库术语、编写或编辑 CONTEXT.md，或记录或编辑 ADR。
type: skill
sidebar:
  label: /domain-modeling
---
![‌/domain-modeling 技能示意图](/diagrams/skills/domain-modeling.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/domain-modeling.excalidraw)

在设计过程中主动构建并完善项目的领域模型。这是一项*主动的*工作规范——质疑术语、构造边界场景，并在术语表和决策一经明确时立即将其记录下来。（仅仅为了查阅词汇而*阅读* `CONTEXT.md` 并不算使用这项技能——那只是任何技能都能做到的一行式习惯。这项技能用于变更模型，而不仅仅是使用模型。）

## 文件结构

大多数仓库只有一个上下文：

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

如果根目录中存在 `CONTEXT-MAP.md`，则该仓库包含多个上下文。该映射文件会指明每个上下文所在的位置：

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          <- system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 <- context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

按需创建文件——仅在有内容需要写入时才创建。如果不存在 `CONTEXT.md`，就在第一个术语得到明确时创建。如果不存在 `docs/adr/`，就在需要编写第一份 ADR 时创建。

## 会话期间

### 根据术语表检查用词

当用户使用的术语与 `CONTEXT.md` 中的现有语言冲突时，立即指出。“你的术语表将‘取消’定义为 X，但你想表达的似乎是 Y——究竟是哪一个？”

### 明确模糊语言

当用户使用含糊或含义过多的术语时，提出一个精确的规范术语。“你说的是‘账户’——你指的是客户还是用户？这是两个不同的概念。”

### 讨论具体场景

讨论领域关系时，使用具体场景对其进行压力测试。构造能够探查边界情况的场景，促使用户准确界定各概念之间的边界。

### 与代码交叉核对

当用户说明某项机制的工作方式时，检查代码是否与之相符。如果发现矛盾，应将其指出：“你的代码会取消整个订单，但你刚才说可以部分取消——哪一种才是正确的？”

### 即时更新 CONTEXT.md

术语一经明确，就立即更新 `CONTEXT.md`。不要集中到最后处理——应在术语明确时随即记录。使用 [CONTEXT-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/domain-modeling/CONTEXT-FORMAT.md) 中的格式。

`CONTEXT.md` 应完全不包含实现细节。不要将 `CONTEXT.md` 当作规范、草稿本或实现决策的存放处。它只是术语表，不作他用。

### 谨慎建议编写 ADR

仅当以下三个条件全部满足时，才建议创建 ADR：

1. **难以逆转**——日后改变决定将付出显著代价
2. **缺少上下文会令人意外**——未来的读者会疑惑“他们为什么要这样做？”
3. **源于真实的权衡**——存在切实可行的替代方案，而你出于特定原因选择了其中一种

如果缺少其中任何一项，就不必编写 ADR。使用 [ADR-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/domain-modeling/ADR-FORMAT.md) 中的格式。
