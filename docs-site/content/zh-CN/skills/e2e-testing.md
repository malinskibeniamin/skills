---
title: /e2e-testing
description: "编写或修复 Playwright E2E 规范、夹具、浏览器测试或不稳定测试时使用。"
type: skill
sidebar:
  label: /e2e-testing
---
![关于 /e2e-testing 技能的示意图](/diagrams/skills/e2e-testing.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/e2e-testing.excalidraw)

# E2E 测试

选择当前 Playwright、Testcontainers、axe-core 或浏览器 API 前，先运行 `/read-the-damn-docs`。初始设置见 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md)。

## 约定

- E2E 测试放在 `e2e/*.spec.ts`，文件按功能命名。
- 选择器优先级：`getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS。
- 测试 ID 使用 `{feature}-{element}`，可加索引或状态。
- 路由兄弟钩子会在路由编辑后运行相邻浏览器或集成测试。
- 结构重构钩子要求新页面或抽取组件配套测试。

## 无障碍和浏览器

每个页面都运行 axe，但自动化无障碍检查只覆盖一部分。仅通过 axe 不能证明键盘顺序、焦点、名称、缩放或辅助技术行为。

PR 在 Chromium 中运行完整套件。将关键路径和可信引擎风险标记为 `@cross-browser`，并在 Firefox 与 WebKit 中运行。完整浏览器矩阵留给夜间通道或发布门禁。模拟不能证明所有品牌浏览器或实体设备。

## 确定性

- 等待原因，不等待时长。操作前注册响应、请求或渲染 Promise。`waitForURL` 后断言目标地标。禁止 `waitForTimeout`，也不要在 `toPass` 中使用 `expect.soft`。
- 测试导航竞态：延迟 A、启动 A、导航到 B，再证明 B 的状态和副作用存在且 A 不出现。
- 在 E2E 以下层级用假计时器证明防抖截止时间与取消；E2E 不睡眠，只断言可见结果。
- 不使用 `force: true`；修复真实用户会遇到的遮挡。
- RPC 路由按 `Service/Method` 匹配，不匹配版本前缀。
- 用 `test.step()` 包裹逻辑操作，让 CI 指明失败步骤。
- 测试模式下让短暂 UI 保持可见，但断言持久副作用而非 toast 文本。
- 剪贴板和权限特定规范在 Chromium 运行；其他浏览器覆盖等价结果。
- 缓冲后端或容器日志直到 teardown，并捕获启动失败。遮蔽秘密。
- CI 只允许一次重试作为临时措施，目标为零；本地使用简洁 reporter。
- 删除仅验证渲染的规范；每段旅程都要触发用户造成的副作用。

## 生成式与长时间探索

仅当组合式客户契约没有更便宜的证明方式时，使用窄范围生成动作序列或有状态属性。遵循[基于属性的测试](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md)：保留独立 oracle 和可重放 seed，再把真实发现转为确定性回归。它补充固定旅程、跨浏览器检查、无障碍、视觉审查和 dogfood。

要检查同一浏览器上下文中的监听器、DOM、计时器、订阅或堆增长，使用[浸泡测试](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md)。相互隔离的 E2E 测试无法证明资源生命周期。

## 证据与工具

监控 `bun run test:e2e`，在完成前处理失败。

| 需要 | 工具 |
|---|---|
| CI／测试套件 | Playwright |
| 选择器或 AI 检查 | `agent-browser snapshot` |
| 视觉冒烟证据 | `agent-browser screenshot --annotate` |
| 交互式调试 | Playwright UI 模式 |
