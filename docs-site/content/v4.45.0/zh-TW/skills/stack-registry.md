---
title: /stack-registry
description: 管理目前使用與禁止使用的前端技術堆疊。適用於新增特定函式庫規則、開始技術堆疊遷移、淘汰舊指南，或檢查過時 API。
type: skill
sidebar:
  label: /stack-registry
---
![「/stack-registry」技能示意圖](/diagrams/skills/stack-registry.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/stack-registry.excalidraw)

Harness 規則分為兩種持久性類別。**不變規則**（請參閱 `/frontend-invariants`）永不失效。**技術堆疊規則**會指明特定函式庫或 API，且必須標記技術堆疊世代，讓下一次遷移能將其整批取代，避免留下誤導代理程式的過時指南。過往曾有四套已淘汰技術堆疊的規則集，在程式碼完成遷移後很久仍以「目前指南」的名義留存——這正是此技能要防止的失敗模式。

## 目前的技術堆疊（`stack:2026`）

| 層級 | 目前使用 | 規則所在位置 |
|---|---|---|
| UI 工具組 | Tailwind v4 + shadcn/Base UI + 納入版本控制的登錄庫 | registry-workflow、visual-review、tailwind hooks |
| 路由器 | TanStack Router（檔案式路由、loaders、validateSearch） | tanstack-router |
| 資料 | connect-query + gRPC + protobuf-es v2 + protovalidate | connect-query |
| 表單 | react-hook-form（搭配由 proto 驅動的 resolvers）；zod 僅用於路由搜尋結構描述 | form-mode hooks |
| 用戶端狀態 | zustand + React context | zustand hooks |
| React | 19 + Compiler（不使用手動 memo，不使用 forwardRef） | react-rules hooks |
| 建置／測試 | rsbuild / vitest 四層級（搭配瀏覽器基準測試）/ Playwright | test-convention hooks、e2e-testing |

## 禁止使用的技術堆疊（由機械化檢查凍結）

由 hooks／lint 禁令強制執行——絕不推薦、絕不接受用於新程式碼，也絕不引用其慣用寫法作為指南：

`chakra`／舊版共用 UI 工具組 · `react-router-dom` · Redux Toolkit Query／redux-observable · MobX（`observer`、`makeObservable`、`useLocalObservable`）· Formik · Yup · react-intl／`FormattedMessage` + i18n 字典機制 · CRA/react-scripts/jest 慣用寫法 · nuqs（搜尋參數型別由路由器負責）。

每項禁令最多保留一項後設經驗（例如，Yup 的「驗證格式，而不只是是否存在」得以保留；其實作機制則不保留）。探勘或引用過往的程式碼審查指南時，任何提及禁止使用技術堆疊的內容都應視為歷史證據，而非操作指示。

## 遷移操作手冊（當某個層級變更時）

1. **先徹底檢視**：路由器／框架層採一次性全面遷移，資料層採絞殺者模式；資料層須為長達數月的共存期編列預算。
2. 撰寫新技術堆疊的規則群組，並以新世代標記。
3. 在同一個 PR 中淘汰舊群組：將該函式庫移至禁止使用表格、加入機械化禁令（hook／`noRestrictedImports`），並刪除其指南或加上年代標記。
4. 在同一個 PR 中更新範例——模型仿效範例的傾向比遵循規則更強。
5. 遷移的完成定義包含凍結措施；若已淘汰的技術堆疊未被禁止，LLM 作者必定會將其復活。

## 規則撰寫檢查清單

新增任何指名函式庫／API 的規則時：(a) 它其實是否是偽裝成技術堆疊規則的不變規則？若是，請改用不綁定函式庫的方式寫入 `/frontend-invariants`；(b) 在其所屬技能／hook 中以 `stack:2026` 標記；(c) 能以機械化方式檢查時就加入檢查——未強制執行的規則會逐漸偏移；(d) 加入反向規則：hook 現在必須拒絕哪些已被取代的模式？
