---
description: 创建一个项目本地技能，用于启动、驱动、观察和清理真实应用。当仓库缺少可重复的方法来验证 UI、CLI、API 或服务行为时使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - create verification skill
sidebar:
  label: /create-verification-skill
title: /create-verification-skill
type: skill
---
![展示 /create-verification-skill 技能的示意图](/diagrams/skills/create-verification-skill.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/create-verification-skill.excalidraw)

生成一个项目本地验证器，供下一个智能体在无预备上下文的情况下运行。使用仓库现有的规范技能根目录；否则默认使用 `.agents/skills/verify-<app>/`。切勿将该技能复制到多个特定于宿主的根目录中。

## 调研仓库 [#interview-the-repository]

先自行探查，再提出问题：

- **界面：**主要用户入口，以及任何次要 UI、CLI、API、移动端、桌面端或库界面。
- **启动：**仓库原生命令、就绪信号、端口、环境、种子数据和身份验证。
- **驱动：**优先使用现有的 Playwright、PTY、HTTP、调试或应用测试工具，而非通用工具。
- **观察：**屏幕截图、无障碍快照、交互记录、响应、日志、退出代码和持久副作用。
- **隔离：**每次运行独立的端口、配置文件、数据目录和测试数据。拒绝驱动由真人共享使用的实例。

如果检出版本无法运行，报告失败的前置条件，而不是编造启动说明。

对于智能体开发体验或工作树设置请求，使用[能力缺口和冷启动检查](https://github.com/malinskibeniamin/skills/blob/main/create-verification-skill/references/agent-dx.md)。

## 生成 [#generate]

编写 `SKILL.md`，使用匹配的 `name: verify-<app>` 前置元数据，并包含具体的 **启动**、**诊断**、**驱动**、**证据**和**清理**章节：

- **启动：**确切的启动和关闭命令，包含迁移和种子数据，确保从空数据状态启动可用的应用。仅有端口监听或数据库正常并不代表应用已就绪。
- **诊断：**提供一项只读检查，覆盖应用身份、构建、进程或端口所有权、数据隔离和身份验证。
- **驱动：**使用此仓库中的字面命令和稳定定位方式。优先使用角色、无障碍名称、路由、提示字符串和公共 API，而非坐标或内部实现。
- **证据：**捕获操作及其产生的状态。通过第二个公共视图验证副作用。仅允许在现有生产边界使用模拟。
- **清理：**仅停止本次运行创建的进程和临时状态。切勿按进程名称终止进程。清理后仍须保留证据。

使辅助工具可执行，并记录用法。对于有状态缺陷或反复出现的复现缺口，通过原生测试数据和调试 API 证明[捕获和重放](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md)。

## 建立功能地图的初始内容 [#seed-the-feature-map]

创建 `features/README.md`，并为最重要的 3–5 个面向用户的功能分别创建一个文件。从[功能地图示例](https://github.com/malinskibeniamin/skills/blob/main/create-verification-skill/references/feature-map-example/README.md)开始，然后用仓库证据替换所有示例。每个功能包含：

1. `子功能`
2. `如何进入该功能（用户视角）`
3. `使用 <harness> 驱动该功能`
4. `注意事项`

梳理每个入口。缺少所需种子数据会使流程失败：记录在`注意事项`中，切勿削弱流程。

## 验证生成的技能 [#prove-the-generated-skill]

执行生成的技能：启动、诊断、一条已梳理的真实用户流程、证据和清理。确认保留证据，且创建的进程或状态均未残留。清理失败尝试，修复说明并重放。未经执行的验证器只是草稿。

列出替代环境的设置缺口；在目标环境重放前，仍未经过验证。

漂移审计交由 `/maintain-verification-skill`，功能工作交由 `/dogfood`。
