---
description: 編寫或修復 Playwright E2E 規範、夾具、瀏覽器測試或不穩定測試時使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - e2e testing
sidebar:
  label: /e2e-testing
title: /e2e-testing
type: skill
---
![「/e2e-testing」技能示意圖](/diagrams/skills/e2e-testing.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/e2e-testing.excalidraw)

選擇當前 Playwright、Testcontainers、axe-core 或瀏覽器 API 前，先執行 `/read-the-damn-docs`。初始設定見 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md)。

## 約定 [#conventions]

- E2E 測試放在 `e2e/*.spec.ts`，檔案按功能命名。
- 選取器優先順序：`getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS。
- 測試 ID 使用 `{feature}-{element}`，可加索引或狀態。
- 路由兄弟鉤子會在路由編輯後執行相鄰瀏覽器或整合測試。
- 結構重構鉤子要求新頁面或抽取元件配套測試。

## 無障礙和瀏覽器 [#accessibility-and-browsers]

每個頁面都執行 axe，但自動化無障礙檢查只覆蓋一部分。僅透過 axe 不能證明鍵盤順序、焦點、名稱、縮放或輔助技術行為。

PR 在 Chromium 中執行完整套件。將關鍵路徑和可信引擎風險標記為 `@cross-browser`，並在 Firefox 與 WebKit 中執行。完整瀏覽器矩陣留給夜間通道或釋出閘門。模擬不能證明所有品牌瀏覽器或實體裝置。

## 確定性 [#determinism]

- 等待原因，不等待時長。操作前註冊回應、請求或渲染 Promise。`waitForURL` 後斷言目標地標。禁止 `waitForTimeout`，也不要在 `toPass` 中使用 `expect.soft`。
- 測試導覽競態：延遲 A、啟動 A、導覽到 B，再證明 B 的狀態和副作用存在且 A 不出現。
- 在 E2E 以下層級用假計時器證明防抖截止時間與取消；E2E 不睡眠，只斷言可見結果。
- 不使用 `force: true`；修復真實使用者會遇到的遮擋。
- RPC 路由按 `Service/Method` 匹配，不匹配版本字首。
- 用 `test.step()` 包裹邏輯操作，讓 CI 指明失敗步驟。
- 測試模式下讓短暫 UI 保持可見，但斷言持久副作用而非 toast 文字。
- 剪貼簿和權限特定規範在 Chromium 執行；其他瀏覽器覆蓋等價結果。
- 緩衝後端或容器記錄直到 teardown，並擷取啟動失敗。遮蔽機密。
- CI 只允許一次重試作為臨時措施，目標為零；本機使用簡潔 reporter。
- 刪除僅驗證渲染的規範；每段旅程都要觸發使用者造成的副作用。

## 生成式與長時間探索 [#generated-and-long-lived-exploration]

僅當組合式客戶契約沒有更便宜的證明方式時，使用窄範圍生成動作序列或有狀態屬性。遵循 [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md)：保留獨立 oracle 和可重播 seed，再把真實發現轉為確定性迴歸。它補充固定旅程、跨瀏覽器檢查、無障礙、視覺審查和 dogfood。

要檢查同一瀏覽器上下文中的監聽器、DOM、計時器、訂閱或堆積增長，使用 [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md)。相互隔離的 E2E 測試無法證明資源生命週期。

## 證據與工具 [#evidence-and-tools]

監控 `bun run test:e2e`，在完成前處理失敗。

互動式自動化與工具選擇請參閱[瀏覽器／資料指引](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md#browser-and-data-tasks)。
Agent-browser 是獲准使用時的預設互動式 CLI，並非 Playwright Test 的 CI 執行器。
儲存的流程不能取代 UI 斷言；保留瀏覽器、無障礙和跨瀏覽器測試覆蓋範圍。

| 需要 | 工具 |
|---|---|
| CI／測試套件 | Playwright Test |
| 選取器或 AI 檢查 | `agent-browser snapshot` |
| 視覺冒煙證據 | `agent-browser screenshot --annotate` |
| 互動式除錯 | Playwright UI 模式 |
