---
title: /e2e-testing
description: >-
  適用於表單、表格與工作流程的 Playwright + Testcontainers + axe-core E2E 模式。撰寫或修正 e2e
  規格、fixture、瀏覽器測試，或偵錯不穩定的 Playwright 執行時使用。
type: skill
sidebar:
  label: /e2e-testing
---
![「/e2e-testing」技能示意圖](/diagrams/skills/e2e-testing.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/e2e-testing.excalidraw)

在固定使用目前的 Playwright、Testcontainers、axe-core 或瀏覽器工具 API 之前，先執行 `/read-the-damn-docs`。
## 慣例

- `e2e/*.spec.ts` -- 所有 e2e 測試皆使用 `.spec.ts`
- 依功能命名：`login.spec.ts`、`create-topic.spec.ts`
- 選取器：`getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS
- 測試 ID：`{feature}-{element}`、`{feature}-{element}-{index}`、`{feature}-{state}`

## 編輯時掛鉤

- **路由同層測試**：路由或 `*.page.tsx` 變更時，執行同層的 `*.browser.test.*` 或 `*.integration.test.*`；若失敗則阻擋。
- **結構重構測試提醒**：新增 `*.page.tsx` 或拆分元件檔案時，必須附帶 `.test`、`.integration.test` 或 `.browser.test`。

## 無障礙 -- 每個頁面都執行 axe

```ts
import { test, expect } from '../fixtures/base'
test('page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

自動化無障礙檢查只能偵測部分問題。針對關鍵流程，
也要驗證鍵盤操作順序、焦點移動、無障礙名稱、縮放，以及目標
輔助技術的行為；不得將僅通過 axe 的結果稱為無障礙。

## 瀏覽器證據

在 PR 中使用 Chromium 執行完整測試套件。在 Firefox 與 WebKit 中僅執行標記為 `@cross-browser` 的流程。
完整的既定瀏覽器矩陣僅保留給夜間執行管線或發布閘門。
標記關鍵流程、備援路徑及可信的特定引擎風險，而非每項測試。
必要時限定需特定權限的規格範圍，但要在其他環境中測試同等行為。
瀏覽器模擬無法證明所有品牌瀏覽器或實體裝置的風險。

## 確定性規則（從多年修正不穩定測試的經驗中歸納）

- **等待原因，絕不等待固定時間**：點擊導覽後使用 `waitForURL()`，接著斷言目的地的地標，因為 URL 發布並不代表路由 DOM 已完成提交。在斷言由 RPC 驅動的 UI 前使用 `waitForResponse()`/`waitForRequest()`；其餘情況等待元素狀態。不得使用 `waitForTimeout`；不得在 `toPass` 內使用 `expect.soft`（軟性失敗不會重試該區塊）。
- **導覽競爭條件**：延遲路由 A、啟動 A，接著導覽至 B。斷言 B 的地標與副作用出現，且 A 絕不會顯示。請在觸發動作前註冊網路與渲染狀態的 Promise。
- **計時行為應在 E2E 以下的層級測試**：使用單元／整合測試中的假計時器，驗證防抖／延遲期限與取消行為；E2E 不透過休眠，僅斷言可見結果。
- **不得使用 `force: true` 點擊** -- 若元素需要強制點擊，代表有其他內容遮擋它，而使用者也會遇到相同阻礙；請修正遮擋問題。
- **僅依 `Service/Method` 比對 RPC 路由**，絕不固定比對版本（比對器中的 `v1alpha1` 會在下次 API 升版時失效）。
- **以 `test.step()` 包住每個邏輯動作** -- 如此一來，CI 失敗輸出便會指出確切步驟；步驟越小，診斷越快。
- **短暫顯示的 UI**：以測試模式旗標執行測試套件，避免 toast 自動消失；斷言副作用（已送出請求、資料列已出現），而非 toast 文字。
- **依賴剪貼簿／權限的規格僅在 Chromium 執行**（Firefox/WebKit 的權限模型不同）。
- **可偵錯性是測試的一部分**：緩衝後端／容器日誌，使其在清理後仍可取得；若 `start()` 失敗，先擷取日誌再中止。從失敗傾印中遮蔽密鑰／權杖。
- 重試：CI 中暫時設為 1 次，目標為 0 次；需要重試的規格代表存在等待錯誤。在本機優先使用 Markdown 報告器（節省 LLM 權杖）。
- 品質重於數量：刪除只驗證渲染的規格；每個規格都必須觸發使用者可造成的副作用。

## 產生式瀏覽器探索

當可信的客戶合約橫跨組合式狀態轉換，且無法在成本更低的測試接縫加以證明時，
使用範圍狹窄的產生式動作序列或具狀態的屬性。
遵循不限定執行器的[屬性式測試指南](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tdd/PROPERTY-BASED-TESTING.md)：
保留獨立的邊界預期結果判定機制、保存重播證據，並將每個實際發現
轉化為確定性的迴歸測試。產生式探索是固定流程、
跨瀏覽器檢查、無障礙檢查、視覺審查與內部試用的補充；不會取代其中任何一項。

## 長期存續的 SPA 資源

針對在單一瀏覽器執行環境中累積的監聽器、已脫離的 DOM、計時器、訂閱或堆積成長，
請閱讀 [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/e2e-testing/SOAK-TESTING.md)。將重複
往返視為資源生命週期合約；一般彼此隔離的 E2E 測試無法證明這一點。

## E2E 監控器
`Monitor: bun run test:e2e` -- 串流顯示結果，並在測試套件完成前對失敗作出反應。

## Agent-Browser 與 Playwright

| 工作 | 工具 |
|------|------|
| 測試套件 | 透過 `Monitor: bun run test:e2e` 使用 Playwright |
| 產生選取器 | `agent-browser snapshot`（無障礙樹） |
| 視覺煙霧測試 | `agent-browser screenshot --annotate` |
| 互動式偵錯 | Playwright UI 模式 |
| CI | Playwright |
| AI 頁面檢查 | agent-browser |

設定（安裝、組態、fixture、Testcontainers）：請參閱 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/e2e-testing/SETUP.md)。
