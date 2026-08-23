---
title: /e2e-testing
description: >-
  适用于表单、表格和工作流的 Playwright + Testcontainers + axe-core
  端到端测试模式。在编写或修复端到端测试规范、测试夹具、浏览器测试，或调试不稳定的 Playwright 运行时使用。
type: skill
sidebar:
  label: /e2e-testing
---
![关于 /e2e-testing 技能的示意图](/diagrams/skills/e2e-testing.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/e2e-testing.excalidraw)

在固定当前 Playwright、Testcontainers、axe-core 或浏览器工具 API 的版本前，先运行 `/read-the-damn-docs`。
## 约定

- `e2e/*.spec.ts` -- 所有端到端测试都使用 `.spec.ts`
- 按功能命名：`login.spec.ts`、`create-topic.spec.ts`
- 选择器：`getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS
- 测试 ID：`{feature}-{element}`、`{feature}-{element}-{index}`、`{feature}-{state}`

## 编辑时钩子

- **路由同级测试**：当路由或 `*.page.tsx` 发生更改时，运行同级的 `*.browser.test.*` 或 `*.integration.test.*`；如果失败则阻止继续。
- **结构重构测试提醒**：新增 `*.page.tsx` 或拆分出的组件文件需要随附 `.test`、`.integration.test` 或 `.browser.test`。

## 无障碍性 -- 每个页面都运行 axe

```ts
import { test, expect } from '../fixtures/base'
test('page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

自动化无障碍性检查只能检测部分问题。对于关键流程，
还要验证键盘顺序、焦点移动、无障碍名称、缩放以及目标
辅助技术的行为；不要将仅通过 axe 检查称为无障碍。

## 浏览器证据

在 PR 中使用 Chromium 运行完整测试套件。在 Firefox 和 WebKit 中仅运行标记为 `@cross-browser` 的流程。
将完整的已声明浏览器矩阵留给夜间流水线或发布门禁。
应标记关键流程、回退路径和可信的引擎特有风险，而不是标记每个测试。
必要时限制权限特定测试规范的范围，但要在其他环境中验证等效行为。
浏览器模拟并不能证明覆盖了每种品牌浏览器或物理设备的风险。

## 确定性规则（从多年修复不稳定测试的经验中总结）

- **等待原因，绝不等待固定时长**：导航点击后使用 `waitForURL()`；在断言由 RPC 驱动的界面前使用 `waitForResponse()`/`waitForRequest()`；其他情况等待元素状态。不要使用 `waitForTimeout`；不要在 `toPass` 中使用 `expect.soft`（软失败不会重试该代码块）。
- **定时行为应在端到端测试以下的层级验证**：在单元测试或集成测试中使用模拟计时器验证防抖/延迟的时限和取消行为；端到端测试无需休眠，只断言可见结果。
- **不要使用 `force: true` 点击** -- 如果元素需要强制点击，说明有东西遮挡了它，用户也会遇到同样的阻碍；应修复遮挡问题。
- **仅按 `Service/Method` 匹配 RPC 路由**，绝不固定版本（匹配器中的 `v1alpha1` 会在下一次 API 版本升级时失效）。
- **用 `test.step()` 包裹每个逻辑操作** -- 这样 CI 失败输出就能指出确切步骤；步骤越小，诊断越快。
- **短暂显示的界面元素**：使用能阻止消息提示自动消失的测试模式标志运行测试套件；断言副作用（请求已发出、行已出现），而不是消息提示文本。
- **依赖剪贴板/权限的测试规范仅在 Chromium 中运行**（Firefox/WebKit 的权限模型不同）。
- **可调试性是测试的一部分**：缓冲后端/容器日志，使其在清理后仍然保留；当 `start()` 失败时，在退出前捕获日志。从失败信息转储中隐去密钥/令牌。
- 重试：CI 中暂时设为 1 次，目标是 0 次；需要重试的测试规范存在等待逻辑缺陷。本地优先使用 Markdown 报告器（对大语言模型令牌更友好）。
- 质量重于数量：删除仅验证渲染的测试规范；每个测试规范都必须触发用户可以执行的副作用。

## 生成式浏览器探索

当一个可信的客户契约涉及组合式状态转换，并且无法在成本更低的边界上
得到验证时，使用范围有限的生成式操作序列或有状态属性。
遵循与运行器无关的[基于属性的测试指南](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md)：
保留独立的边界预言机，保存重放证据，并将每个真实发现
转化为确定性回归测试。生成式探索是固定流程、
跨浏览器检查、无障碍性检查、视觉审查和内部试用的补充；它不会取代其中任何一项。

## 长期运行的 SPA 资源

对于在同一浏览器上下文中持续累积的监听器、已分离的 DOM、计时器、订阅或堆增长，
请阅读 [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md)。将重复的
往返过程视为资源生命周期契约；普通的隔离端到端测试无法验证这一点。

## 端到端测试监控
`Monitor: bun run test:e2e` -- 流式输出结果，在测试套件完成前对失败作出响应。

## Agent-Browser 与 Playwright

| 任务 | 工具 |
|------|------|
| 测试套件 | 通过 `Monitor: bun run test:e2e` 使用 Playwright |
| 生成选择器 | `agent-browser snapshot`（无障碍树） |
| 视觉冒烟测试 | `agent-browser screenshot --annotate` |
| 交互式调试 | Playwright UI 模式 |
| CI | Playwright |
| AI 页面检查 | agent-browser |

设置（安装、配置、测试夹具、Testcontainers）：请参阅 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md)。
