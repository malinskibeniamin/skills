---
description: "设置、设计或排查 Sonner React 通知：Toaster 位置、promise/loading 生命周期、重复消息、主题、portal 和自定义内容。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["ask sonner"]}
sidebar: {"label":"/ask-sonner"}
title: "/ask-sonner"
type: "skill"
---
![“/ask-sonner”技能示意图](/diagrams/skills/ask-sonner.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/ask-sonner.excalidraw)

使用已安装的 Sonner 版本和现有设计系统封装。
改编自 Emil Kowalski；参见[来源](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/EMIL-SKILLS-CREDITS.md)。
使用版本相关的属性或返回值前，先阅读已安装类型和最新[官方文档](https://sonner.emilkowal.ski)；
这里是指导，不是冻结的 API 规范。

## 集成

- 复用项目的 Toaster 封装，通常位于 `@/components/ui/`。在稳定的应用根节点挂载一次，
  放在会裁剪或建立堆叠上下文的祖先之外。额外的 Toaster 需要受支持且明确的定向机制；
  不要假定存在多 Toaster 属性。
- 在客户端的操作边界调用 `toast`。服务端返回结果，由客户端播报。
  优先使用事件/变更操作的结果，而不是渲染/效果的副作用。
- 用 success/error/info/warning 表达结果；手动管理生命周期时用 `toast.loading` 和稳定 id，
  对于确实会完成的 promise 用 `toast.promise`。
  更新、关闭和错误处理模式参见 [RECIPES.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/ask-sonner/RECIPES.md)。
- 重要的失败/恢复状态既要内联持久显示，也可用临时通知。
  加载提示、乐观启动或被吞掉的拒绝均不代表成功。

## 诊断

| 症状 | 修改前检查 |
|---|---|
| 通知不出现 | Toaster 生命周期、客户端调用及受支持的目标 id |
| 重复通知 | 多个 Toaster 或效果重放；稳定的操作 id |
| 一直加载 | 未完成的 promise、遗漏 catch/finally、永久显示时长 |
| 主题错误 | 现有 provider/封装传入的已解析主题 |
| 藏在对话框后/被裁剪 | Portal 位置、祖先 transform/filter/overflow、堆叠层 |
| 样式丢失 | 已安装包的 CSS 导出和框架样式表生命周期 |
| 类名未生效 | 层叠/图层和封装配置；在所属位置限制覆盖范围 |
| 手机重叠 | 受支持的偏移属性、安全区域、键盘和摆放位置 |

## 样式与验证

先用封装的变体/令牌；在源头修正选择器优先级，不要散布 `!important`。
只有已安装 API 支持所需行为时，才考虑 `unstyled` 或 `toast.custom`。
自定义控件使用项目的 Button/Link 和无障碍标签；无样式内容不会自动获得语义。

验证一个操作只产生一个通知，能正确成功/拒绝并关闭，且在键盘、屏幕阅读器播报、
减少动态效果、各主题和对话框中仍可使用。也要验证持久错误路径。
解释/审查请求返回结论；构建/修复请求继续通过项目测试和交付检查。
