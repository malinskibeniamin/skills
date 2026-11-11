---
description: 將 React、TypeScript 與 UI 實作從高階成果一路推進至自行驗證。
related:
  - /skills/tdd
  - /skills/review
search:
  boost: 3
  keywords:
    - development lifecycle
    - work
    - implementation
    - development workflow
sidebar:
  label: /development-lifecycle
title: /development-lifecycle
type: skill
---
![「/development-lifecycle」技能的流程圖](/diagrams/skills/development-lifecycle.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/development-lifecycle.excalidraw)

進行多步驟實作或發佈時，請閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution)。

作者入口：`/work`。負責一個結果。編輯前閱讀[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，明確歸屬、隔離和端點。遵循[溝通約定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#admit-work-by-priority)及[相依載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 成果契約 [#outcome-contract]

陳述**目標**（成果）、**護欄**（保留的界線）、**驗證**（可觀察的證據）及**停止條件**（端點或阻礙）。

陳述契約；建置、修正或實作請求應立即繼續。
在該終點範圍內[自動補齊使用端儲存庫的審查保障](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)。

## 執行迴圈 [#loop]

**檢查 -> 行動 -> 驗證 -> 重複**

### 檢查 [#inspect]

閱讀工單、內文、標籤與留言；釐清標題和參照。透過查詢、探查、可逆假設或暫停來釐清盲點與易變的未知事項；遵循儲存庫慣例與已展現的規模。

撰寫前閱讀適用範圍的規範，並從指令碼、設定與 CI 確認儲存庫原生的格式化、lint、型別檢查及受影響測試指令。記錄相關的基準失敗；沿用已安裝的工具鏈。

處理 T3 簽出或 Effect 程式碼時，以 `work` 為入口解析[原生脈絡](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)；在整個循環中使用回傳的目標專案指南和範圍檢查。

載入[變更證據路由](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md)與相關負責技能。評估可信風險；只在視覺比較有用或明確要求時於編輯前擷取基準。重用現有測試、輔助工具與有效證據。

依據固定評估反覆最佳化時，載入 [hill-climb](https://github.com/malinskibeniamin/skills/blob/main/hill-climb/SKILL.md)。

[Figma/圖片](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/build-design/SKILL.md)。

### 行動 [#act]

程式碼庫屬於使用者；對本次變更負責，而非進行無關的重新設計。診斷一般工具故障並重試安全的檢查；對結果不確定的寫入，先讀取狀態再決定是否重試。等待開放問題的答覆時，繼續不依賴該答覆的工作；尊重刻意設定的存取邊界。

單一負責人；委派與背景工作需要明確同意。依本地慣例實作可正常運作的最小差異。對可信且尚未涵蓋的回歸使用 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)；其他情況使用現有檢查或探測即可。僅重新規劃受影響部分；避免推測性抽象與順手清理。

每完成一批邏輯完整的編輯，先執行限定範圍的格式化或自動修正與 lint，再執行相關的型別檢查及測試。只有檔案內容與檢查涵蓋範圍完全相同時，才可重用已完成的 hook 結果。檢查自動修正的差異；修正失敗並重新執行。若按檔案限定範圍不可靠，保留整個專案的型別檢查。

變更匯入邊或處理循環相依／barrel 檔案診斷時，請使用[以相依圖為依據的檢查迴圈](https://github.com/malinskibeniamin/skills/blob/main/shared/check-loop.md#import-cycles-and-barrels)。

### 驗證 [#verify]

交回每個實作回合前，針對受影響範圍執行儲存庫要求的格式化、lint、型別、測試、建置與靜態檢查關卡；內部迴圈的局部檢查絕不取代必要的最終關卡。對實質且可執行的行為載入 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；測試其實際進入點及一條可信的失敗或復原路徑。審查目標、護欄與可信風險：檢查通過不代表建置了正確的東西。失敗成為下一步行動；修正並重複。另行回報無關的基準失敗，絕不將其描述為全部通過。

修正原因，而不是更動關卡來掩蓋問題。絕不透過型別逃生通道、抑制檢查、略過或削弱測試、擴大排除範圍、降低嚴格程度或隱藏失敗結束碼來取得通過結果。有問題的檢查需要證據與明確的工具變更理由，並以應失敗及應通過的案例證明修正後的規則仍能偵測目標缺陷。

若缺少可重複執行的進入點：以可拋棄的測試工具證明，再將長期缺口交由 `/create-verification-skill` 處理。

## 界線 [#boundaries]

僅針對使用者保留的決策，或不可逆的正式環境、法律、隱私、破壞性及高安全風險操作詢問。只有長期任務需要檢查點時才沿用現有筆記；例行工作不需要證據或檢查清單檔案。

## 完成 [#completion]

閱讀並執行[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)：內嵌自我審查、適用證據、發布以及要求的 CI/回饋跟進。重用目前驗證；所有退出條件滿足後，在要求的端點停止。[重構](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md#refactor-branch)。
