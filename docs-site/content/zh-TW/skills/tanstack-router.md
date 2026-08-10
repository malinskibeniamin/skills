---
title: /tanstack-router
description: 套用 TanStack Router 模式來管理 Query 所有權與具型別的搜尋參數。適用於變更路由、loader、導覽、路由樹或搜尋參數時。
type: skill
sidebar:
  label: /tanstack-router
---
![「/tanstack-router」技能示意圖](/diagrams/skills/tanstack-router.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/tanstack-router.excalidraw)

請先遵循 `/tanstack-intent`，並載入已安裝 Router 套件隨附的相應指南。Intent 負責目前的 API 語法與版本行為。此技能補充本機的所有權與 URL 狀態政策。請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/REFERENCE.md) 以了解本機程式碼結構，並閱讀 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/SETUP.md) 以了解安裝方式。

## 所有權

- Router loader 會在產生導覽意圖後開始從伺服器擷取資料。
- TanStack Query 負責快取、重新擷取、失效處理與垃圾回收。
- 元件透過 `useQuery` 或 `useSuspenseQuery` 觀察 Query。

頁面關鍵的阻塞式資料請使用 suspense；延後載入的資料則使用一般 query，並提供行內的載入中、空白與錯誤狀態。由 Query 支援的 loader 應設定 `defaultPreloadStaleTime: 0`，並使用 `createRootRouteWithContext`。

## 路由規則

- 使用 `{ from }` 或路由 API 限定 `useParams`、`useSearch`、`useLoaderData` 與 `useRouteContext` 的範圍；禁止使用 `strict: false`。
- 由 Query 支援的元件應讀取 Query，而非 `Route.useLoaderData`。
- 路由檔案只匯出路由設定；可重複使用的元件應放在其他位置。
- 導覽應使用 Router API，而非 `window.location`。
- `react-router-dom`、`URLSearchParams` 與 nuqs 都是遷移技術債。
- 路由樹變更後應觸發產生程序。

## 搜尋參數

Router 透過 `validateSearch` 掌控搜尋參數的型別。

- URL：可分享的分頁、篩選條件、排序方式與頁碼。
- 儲存空間：個人顯示密度、每頁筆數與收合狀態。
- 驗證列舉值、日期與有界數值；將過時的頁面索引限制在有效範圍內。
- 更新時應與先前的搜尋狀態合併。
- 在區段內使用 `replace: true`，讓「上一頁」能離開該區段。

## 完成條件

- 型別能證明路由與搜尋參數的作用範圍。
- Query 資料具有作用中的觀察者，且所有可見狀態都完整呈現。
- 導覽會保留瀏覽器歷史記錄的語意。
- 搜尋 URL 能妥善處理格式錯誤、過時與分享而來的值。
- 路由樹、聚焦測試、型別檢查與程式碼檢查皆通過。
