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

## Router + Query

- Router loader 會在產生導覽意圖後開始從伺服器擷取資料。
- TanStack Query 負責快取、重新擷取、失效處理與垃圾回收。
- 元件透過 `useQuery` 或 `useSuspenseQuery` 觀察 Query。

路由已知的 Query 輸入只使用一條管線：`validateSearch` -> `loaderDeps` -> 單一 `queryOptions` 建構器 -> loader 與元件觀察者。只回傳 Query 使用的搜尋欄位。元件應使用 `useLoaderDeps`，而非平行讀取驅動 Query 的搜尋狀態。如果已安裝的 Router 指南支援在路由 `context` 中建構選項，請共用完全相同的選項值；絕不可採用範例中未記載於文件的語法。

- 頁面關鍵資料：等待 `ensureQueryData`；使用 `useSuspenseQuery` 觀察。
- 路由已知的延後載入資料：在 loader 中開始擷取；使用 `useQuery` 觀察，並提供可見的載入中、空白與錯誤狀態。
- 僅供互動使用的資料可從元件開始擷取。

由 Query 支援的 loader 應設定 `defaultPreloadStaleTime: 0`，並使用 `createRootRouteWithContext`。

## 導覽生命週期

將資源、導覽、結果與呈現的所有權分開：

- 被取代的導覽會失去發布權限；共用的 loader 或 Query 工作仍可繼續發揮作用。
- `beforeLoad` 用於可安全重播的驗證、重新導向或 context 建構。預載與導覽皆可能執行它；請勿在其中執行可觀察的副作用與一般資料擷取，讓 loader 保持平行處理能力。
- 直接 loader 請求會轉送 `abortController.signal`。Query 函式會轉送由 Query 所擁有的 signal。不要在每次導覽時全面取消共用工作。
- 從 `beforeLoad` 或 loader 進行重新導向時，應使用 `throw redirect(...)`，而非命令式導覽。
- 使用 `onResolved` 處理分析與不涉及 DOM 的清理。使用 `onRendered` 處理焦點、捲動、測量，或其他需要已提交路由內容的工作。
- 使用 Router 的待處理 UI 與其計時選項，而非自行建立導覽計時器。

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
- Loader 與觀察者使用相同的 Query 選項建構器及由 loader 管理的輸入。
- Query 資料具有作用中的觀察者，且所有可見狀態都完整呈現。
- 快速或預載導覽無法發布過時的路由 UI，亦不會重複執行應由應用程式管理的工作。
- 導覽測試會在 URL 變更後，對已呈現的路由地標進行斷言。
- 導覽會保留瀏覽器歷史記錄的語意。
- 搜尋 URL 能妥善處理格式錯誤、過時與分享而來的值。
- 路由樹、聚焦測試、型別檢查與程式碼檢查皆通過。
