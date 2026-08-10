---
title: /registry-workflow
description: 通过分类体系和严格的同步规范维护组件注册表。适用于修改 shadcn 注册表或设计系统、同步组件或分析使用方偏差。
type: skill
sidebar:
  label: /registry-workflow
---
![「/registry-workflow」技能示意图](/diagrams/skills/registry-workflow.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/registry-workflow.excalidraw)

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/registry-workflow/REFERENCE.md)，了解分类示例、偏差检查命令、过滤方法和
治理规范。

## 模式

### 对组件进行分类

采用匹配到的最高级别，并据此确定测试深度。

| 级别 | 特征 | 测试数 |
|---|---|---|
| 原子 | 一个基础组件、0–1 个状态、无自定义键盘交互或传送门 | 3–4 |
| 分子 | 2–3 个原子、最多 2 个状态值、小型处理函数、可选传送门 | 5–8 |
| 有机体 | 3 个以上状态值、3 个以上注册表导入、自定义键盘交互、传送门 | 8–15 |

Radix 提供的键盘导航不计为自定义代码。

### 分析使用方偏差

1. 将注册表组件与使用方文件进行匹配。
2. 运行 `git diff --no-index --ignore-all-space`。
3. 过滤导入别名、客户端指令、注释和空白差异。
4. 对所有剩余组件进行分类：
   - `Upstream`：可复用的功能变更。
   - `Skip-Import-Only`：路径或指令产生的噪声。
   - `Skip-Outdated`：使用方落后于注册表；向下同步。
   - `Skip-Business-Logic`：路由、端点、分析埋点、功能开关或领域值。
5. 每个组件报告一个状态。对于混合变更中的可复用修复，应在上游重新进行清晰实现。

### 维护注册表

- 注册表同步应与功能开发分开发版。
- 将使用方特有的行为保留在托管文件之外。
- 破坏性变更必须提供代码迁移工具、变更日志条目、迁移示例和使用方
  冒烟测试。
- 保持注册表组件与路由器和框架无关。
- 通过改进组件 API 来解决使用方反复出现的误用。
- 将变更集写成升级决策：说明受影响的组件、变更前后对比及理由。

## 钩子设置

将 `scripts/ui-registry-warn.sh` 和 `scripts/registry-check.sh` 复制到 `.claude/hooks/`，
赋予其可执行权限，然后进行注册：

- PostToolUse `Edit|Write`：`ui-registry-warn.sh`
- Stop：`registry-check.sh`
- 保持共享的文件拆分约定：路由页面使用 `*.page.tsx`；可复用部分
  放在 `components/` 下。

## 完成条件

- 两个钩子均可执行。
- 编辑组件目录时会发出警告。
- 修改 `redpanda-ui/` 但未修改 `registry.json` 时会阻止操作。
- 更新 `registry.json` 但未提供变更集时会阻止操作。
