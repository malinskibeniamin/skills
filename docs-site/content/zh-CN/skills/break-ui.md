---
description: "压力测试 UI 数据与布局：长文本、Unicode、缩放、窄容器、空状态和大集合。用于诊断、dogfood、视觉审查或明确的破坏测试请求。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["break ui"]}
sidebar: {"label":"/break-ui"}
title: "/break-ui"
type: "skill"
---
![“/break-ui”技能示意图](/diagrams/skills/break-ui.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/break-ui.excalidraw)

用苛刻但有效的数据测试真实组件。改编自 Emil Kowalski；
参见[来源](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。这是针对数据/布局的专项审计，
不能代替生命周期 dogfood 或一般视觉评议。

## 执行边界

审计只返回证据和修复建议，不编辑生产组件。优先使用现有 stories、测试数据和 mock。
只有请求包含构建调试开关或隔离工具时才创建它们；临时材料放在 `.context/`。
明确的修复请求授权通过 TDD 和交付流程修复已确认缺陷；范围内的常规修复无需再加审批步骤。

## 循环

1. 列出渲染字段及其来源/类型、模式限制、可选性和集合边界。
   缺少边界表示未知，不是允许编造限制或修改 API。
2. 阅读 [CATALOG.md](https://github.com/malinskibeniamin/skills/blob/main/break-ui/CATALOG.md)，在实际契约内选取真实可信的值；
   无效/null 值仅用于本应验证它们的边界。不改动数据形状、组件代码、令牌和渲染路径。
3. 通过真实 props/mock/API 边界注入测试数据。混合长/短/Unicode 数据、缺少的可选字段、
   所有有效状态和 0/1/多个元素。比较正常数据、最坏情况、空集合、单个元素和支持的数量上限。
4. 在真实容器、支持的最窄/最宽布局、200% 缩放以及受支持主题/方向下渲染。
   用键盘/触摸操作溢出区域的按钮或链接。记录截图/状态；没有浏览器访问时，将 CSS 推断标明为推断。
5. 报告测试值、可见故障、位置、影响、建议修复和经受住测试的部分。
   识别真正的产品决策（换行/截断、分页/虚拟化）；保持现有惯例，不把每个边界情况都变成重设计。
6. 对明确要求的修复，先添加失败的公共契约回归测试，再修复，随后重放所有受影响的测试数据
   和正常数据。回归数据仅用于测试/开发环境。

## 故障检查点

检查固定尺寸的 flex 兄弟元素、`min-width: 0`/`minmax(0, 1fr)`、不可断行字符串、
多行字形裁剪、字素安全的姓名首字母、地区/复数、图像回退和截断后的完整值访问。
不要隐藏用户需要比较的数字。

测试数据使用保留的示例域名和合成数据。不得联系真实客户、将测试 HTML 作为可执行标记渲染，
或为了测试修改生产记录。只要求报告时就在报告后停止，不额外启动持久进程或添加演示开关。
