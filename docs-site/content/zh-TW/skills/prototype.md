---
description: 為尚未釐清的邏輯、互動、視覺或實作問題建立可拋棄的證據。當可執行的證據能在做出決定前消除不確定性時使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - prototype
sidebar:
  label: /prototype
title: /prototype
type: skill
---
![／prototype 技能示意圖](/diagrams/skills/prototype.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/prototype.excalidraw)

面臨重要的產品或設計選擇時，請閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#product-and-planning)。

使用者明確要求介面工作台時，可推薦 `variant`（設計方案）、`state-machine`（可到達狀態）或 `break`（極端情境）。閱讀[介面保留規則](https://github.com/malinskibeniamin/skills/blob/main/shared/INTERFACES.md#workbench-retention)及對應分支；這些技能僅由使用者呼叫，不是自動相依項。保留可執行的原型，不要將臨時路由或切換器放入正式環境 PR。

原型只回答一個具名問題。它是證據，而不是早期的正式環境分支。

選擇成本最低且能如實反映問題的形式：

- 邏輯／狀態的不確定性 -> 小型可執行狀態模型；請參閱 [LOGIC.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/LOGIC.md)。
- UI 與互動 -> 應用程式內探索或[可分享的審查網站](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md#shareable-review-prototype)；設計尚未確定時提供具有實質差異的變體。
- API／工具的不確定性 -> 對沙箱或測試資料進行最小化呼叫。
- [比較實作](#compare-implementations).

可行時，將可運作的成品放在 `.context/prototypes/<question>/` 下；只有當實際執行環境必須載入時，才放在
目標旁。請清楚標示任何位於程式碼樹內的成品。

## 比較實作 [#compare-implementations]

選擇一個有代表性的工作負載，並透過同一個公開進入點執行。固定現行實作、候選實作和測試資料的版本，並將評估工具獨立於兩種實作。使用[差異測試](https://github.com/malinskibeniamin/skills/blob/main/tdd/DIFFERENTIAL-TESTING.md)比對可觀察的行為、錯誤和持久性副作用，使用[quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments)進行配對量測，並設定值得採用的最小改善幅度和停止條件。如果無法在隔離環境中驗證關鍵行為，請回報這項缺口，不要僅憑微型基準測試決定是否採用。

## 保留方式 [#retention]

將完成的原型保留為可執行的**第一手來源**，但絕不可將僅供原型使用的
程式碼合併至 main：

- 當要求的交付階段允許提交時，請將成品提交至獨立的
  `prototype/<name>` 分支，並在議題或決策紀錄中留下相關背景資訊的指標。
- 否則，請將其保留在 `.context/prototypes/<question>/` 下並回報路徑。在清理可交付的差異前，請將任何
  位於程式碼樹內的成品移動或複製至該處。請勿刪除。

請在議題、ADR、筆記或
實作提交中記錄問題、證據與結論。main 僅保留經驗證的正式環境決策。

## 限制條件 [#constraints]

1. 預設使用標準函式庫和現有相依套件。經授權的比較可以在隔離環境中使用候選執行階段或函式庫；不要變更專案相依套件。
2. 僅需一個指令即可執行。
3. 僅使用記憶體內或暫存式持久化。
4. 顯示相關狀態與觀察結果。
5. 在採信結論前，請針對關鍵路徑與可能的
   邊界執行一次 `/dogfood`；不要對每次中間編輯都進行實際試用。
6. 關鍵路徑回答問題後，請套用上述保留政策。

如果原型與計畫相矛盾，請在正式環境
實作前重新檢視受影響的決策。
