---
description: 建立專案本機技能，用來啟動、操作、觀察並清理實際應用程式。當儲存庫缺乏可重複驗證 UI、CLI、API 或服務行為的方式時使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - create verification skill
sidebar:
  label: /create-verification-skill
title: /create-verification-skill
type: skill
---
![/create-verification-skill 技能示意圖](/diagrams/skills/create-verification-skill.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/create-verification-skill.excalidraw)

先從目標專案的說明與技能找出既有驗證方式，不受名稱限制。對已涵蓋的流程重用它；漂移交由 `/maintain-verification-skill`。在 T3 Code 儲存庫中，針對每個受影響的介面載入[Web/桌面端](https://github.com/malinskibeniamin/skills/blob/v4.41.0/t3code-skills/test-t3-app/SKILL.md)或[原生行動端](https://github.com/malinskibeniamin/skills/blob/v4.41.0/t3code-skills/test-t3-mobile/SKILL.md)技能，並套用[原生驗證約定](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/T3CODE-SKILLS.md#native-verification)。缺少工具不能成為建立替代驗證器的理由。

只有在已證實存在涵蓋缺口時，才在儲存庫的標準技能根目錄編寫一個可從零啟動的驗證器；若無此目錄，則使用 `.agents/skills/verify-<app>/`。不要複製到各主機專用目錄，也不要重複已涵蓋的原生流程。

## 探查儲存庫 [#interview-the-repository]

先探索再提問：

- **介面：**主要使用者進入點，以及任何次要的 UI、CLI、API、行動裝置、桌面或函式庫介面。
- **啟動：**儲存庫原生指令、就緒訊號、連接埠、環境、種子資料和驗證方式。
- **操作：**先使用既有的 Playwright、PTY、HTTP、偵錯或應用程式測試工具，再考慮通用工具。
- **觀察：**螢幕截圖、無障礙快照、逐字稿、回應、日誌、結束代碼和持久化的副作用。
- **隔離：**每次執行專用的連接埠、設定檔、資料目錄和測試資料。拒絕操作人員共用的執行中執行個體。

若簽出版本無法執行，回報失敗的先決條件，而不是編造啟動說明。

針對代理開發體驗或工作樹設定要求，使用[能力缺口與冷啟動檢查](https://github.com/malinskibeniamin/skills/blob/v4.41.0/create-verification-skill/references/agent-dx.md)。

## 產生 [#generate]

撰寫 `SKILL.md`，其 frontmatter 使用相符的 `name: verify-<app>`，並包含具體的 **啟動**、**診斷**、**操作**、**證據**和**清理**章節：

- **啟動：**確切的啟動與停止指令，包含遷移和種子資料，確保從空資料狀態啟動可用的應用程式。僅有連接埠監聽或資料庫正常不代表應用程式已就緒。
- **診斷：**提供一項唯讀檢查，涵蓋應用程式身分、建置、處理程序或連接埠擁有權、資料隔離和驗證方式。
- **操作：**來自此儲存庫的字面指令和穩定控制代碼。優先使用角色、無障礙名稱、路由、提示字串和公開 API，而非座標或內部實作。
- **證據：**擷取操作及其產生的狀態。透過第二個公開檢視驗證副作用。僅能在既有的正式環境邊界使用模擬。
- **清理：**只停止本次執行所建立的處理程序和暫存狀態。絕不要依處理程序名稱終止。證據在清理後仍須保留。

讓輔助工具可執行，並記錄用法。對於有狀態缺陷或反覆出現的重現缺口，透過原生測試資料與偵錯 API 證明[擷取和重放](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/verification-replay.md)。

## 建立功能地圖的初始內容 [#seed-the-feature-map]

建立 `features/README.md`，並為最重要的 3–5 項使用者功能各建立一個檔案。從[功能地圖範例](https://github.com/malinskibeniamin/skills/blob/v4.41.0/create-verification-skill/references/feature-map-example/README.md)開始，接著以儲存庫證據取代所有範例。每項功能包含：

1. `子功能`
2. `如何前往（使用者視角）`
3. `使用 <harness> 操作`
4. `注意事項`

映射每個進入點。缺少所需種子資料會使流程失敗：記錄在`注意事項`中，絕不要放寬流程要求。

## 證明產生的技能可用 [#prove-the-generated-skill]

執行產生的技能：啟動、診斷、一條已映射的實際使用者流程、證據和清理。確認保留證據，且沒有留下已建立的處理程序或狀態。清理失敗嘗試，修正說明並重放。未執行過的驗證器只是草稿。

列出替代環境的設定缺口；在目標環境重放前，仍未經驗證。

將漂移稽核交由 `/maintain-verification-skill`，功能工作交由 `/dogfood`。
