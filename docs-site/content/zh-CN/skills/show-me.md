---
title: /show-me
description: 通过简洁的图表、代码结构草图和重点明确的 HTML 产物，帮助用户直观理解当前主题。
type: skill
sidebar:
  label: /show-me
---
![展示 /show-me 技能的图表](/diagrams/skills/show-me.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/show-me.excalidraw)

帮助用户直观理解当前对话主题。省略开场白并保持文字简短。选择能清晰表达要点的最小视图。
- 使用伪代码展示逻辑或算法：
```text
on(save)
  if content is unchanged
    return cached result
  write new content
  return fresh result
```
- 使用调用树展示运行时控制流：
```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```
- 使用组件树展示 UI 结构，包括重要的状态和模块边界：
```tsx
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```
- 使用浅层文件树展示文件职责或大范围重构：
```text
src/
├── commands/       # parses user actions
├── sessions/       # owns session state
└── transport/      # sends API requests
```
- 使用 Mermaid 展示组件交互、控制流或数据流：
```mermaid
sequenceDiagram
    participant User
    participant UI
    participant Daemon
    User->>UI: choose command
    UI->>Daemon: send expanded prompt
    Daemon-->>UI: stream result
```
- 当重点是发生了哪些变化，且周边结构已存在时，使用 `diff`。让差异结构与主题相匹配。
对于组件变更：
```diff
 <SessionPage>
   useSessionEvents()
   <SessionToolbar>
+    <RunSkillButton />
   <SessionTimeline>
+    <SkillResultCard />
```
对于文件布局变更：
```diff
 src/
 ├── commands/
+│   └── show-me.ts       # expands the slash command
 ├── sessions/
-└── transport.ts
+└── transport/
+    ├── client.ts
+    └── stream.ts
```
对于调用树或调用栈变更：
```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```
对于状态或控制流变更：
```diff
 on(save)
-  write content
+  if content is unchanged
+    return cached result
+  write new content
+  invalidate cache
```
- 当大部分内容都是新增的、遗漏上下文会掩盖职责归属或执行顺序，或者用户需要一个可复制的目标结构时，展示完整代码块：
```ts
function expandSkill(command: string): string {
  const skillName = command.slice(1)
  return `use the ${skillName} skill`
}
```
- 对于可视化 UI、布局、状态对比或复杂到不适合使用 Mermaid 的概念，编写一个聚焦单一主题的 HTML 文件——可以是图表、信息图或简短的幻灯片，选择最适合表达要点的形式。匹配产品的颜色、字体、间距和组件；使用真实的标签和数据；同时支持桌面端和移动端。然后为用户打开该文件：
```
Bash(open path/to/show-me-{description}.html)
```
### 指南
将每个可视化内容放在其所支持的简短文字旁边。只保留回答用户当前问题或解决当前讨论点的选项所需的调用、文件、属性、状态和边界。
你可以使用其中一种，也可以使用多种，但不太可能全部使用。请自行判断，不要让过多信息淹没用户。
