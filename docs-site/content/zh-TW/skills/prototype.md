---
title: /prototype
description: 為尚未釐清的邏輯、互動或視覺問題建立可拋棄的證據。當可執行的證據能在做出承諾前消除行為或 UI 的不確定性時使用。
type: skill
sidebar:
  label: /prototype
---
![／prototype 技能示意圖](/diagrams/skills/prototype.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/prototype.excalidraw)

原型只回答一個具名問題。它是證據，而不是早期的正式環境分支。

選擇成本最低且能如實反映問題的形式：

- 邏輯／狀態的不確定性 -> 小型可執行狀態模型；請參閱 [LOGIC.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/LOGIC.md)。
- UI／互動的不確定性 -> 數個具有實質差異的變體；請參閱
  [UI.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md)。
- API／工具的不確定性 -> 對沙箱或測試資料進行最小化呼叫。

可行時，將可運作的成品放在 `.context/prototypes/<question>/` 下；只有當實際執行環境必須載入時，才放在
目標旁。請清楚標示任何位於程式碼樹內的成品。

## 保留方式

將完成的原型保留為可執行的**第一手來源**，但絕不可將僅供原型使用的
程式碼合併至 main：

- 當要求的交付階段允許提交時，請將成品提交至獨立的
  `prototype/<name>` 分支，並在議題或決策紀錄中留下相關背景資訊的指標。
- 否則，請將其保留在 `.context/prototypes/<question>/` 下並回報路徑。在清理可交付的差異前，請將任何
  位於程式碼樹內的成品移動或複製至該處。請勿刪除。

請在議題、ADR、實作筆記或
實作提交中記錄問題、證據與結論。main 僅保留經驗證的正式環境決策。

## 限制條件

1. 優先使用標準函式庫與現有相依套件；不得建立與
   問題無關的專案骨架。
2. 僅需一個指令即可執行。
3. 僅使用記憶體內或暫存式持久化。
4. 顯示相關狀態與觀察結果。
5. 在採信結論前，請針對關鍵路徑與可能的
   邊界執行一次 `/dogfood`；不要對每次中間編輯都進行實際試用。
6. 關鍵路徑回答問題後，請套用上述保留政策。

如果原型與計畫相矛盾，請在正式環境
實作前重新檢視受影響的決策。
