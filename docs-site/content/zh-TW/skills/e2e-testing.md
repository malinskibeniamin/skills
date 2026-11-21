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
- 修改路由後，重用負責該行為的瀏覽器或整合測試。新增頁面或抽取元件不代表必須新增測試；遵循[撰寫關卡](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md#authoring-gate)。
- 風險涉及多個邊界時，走真實的使用者流程並斷言可見或持久的結果。保留真實的變更整合；路由替身能驗證 UI 狀態，卻無法證明該整合可用。

## 無障礙和瀏覽器 [#accessibility-and-browsers]

每個頁面都執行 axe，但自動化無障礙檢查只覆蓋一部分。僅透過 axe 不能證明鍵盤順序、焦點、名稱、縮放或輔助技術行為。

PR 預設在 Chromium 中執行完整套件；僅執行受影響測試需要 [CI fixes](https://github.com/malinskibeniamin/skills/blob/main/ci-fixes/SKILL.md) 中的失敗封閉驗證。完整迴歸套件必須在合併前對目前組合候選版本執行，優先使用合併佇列。將關鍵路徑和可信引擎風險標記為 `@cross-browser`，也在合併前於 Firefox 與 WebKit 執行。補充夜間矩陣可擴充覆蓋，但不能取代必要契約。模擬不能證明所有品牌瀏覽器或實體裝置。

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
- CI 測試重試維持為零；診斷首次失敗，不要重試到通過。本機使用簡潔 reporter。
- 檢查對使用者有實際影響的結果，包括唯讀流程。僅驗證畫面呈現的冒煙測試必須能偵測某個具體故障；靜態地標本身無法證明整個流程能運作。

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

Browser Use（需主動選用）：[指南](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/BROWSER-USE.md)。
