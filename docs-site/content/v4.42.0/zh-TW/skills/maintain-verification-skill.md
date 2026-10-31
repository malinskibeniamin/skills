---
title: /maintain-verification-skill
description: 依據原始碼與實際執行行為稽核專案本機的驗證器與功能對照表。用於修復兩者可能過時或掩蓋產品迴歸問題的情況。
type: skill
sidebar:
  label: /maintain-verification-skill
---
![「/maintain-verification-skill」技能示意圖](/diagrams/skills/maintain-verification-skill.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/maintain-verification-skill.excalidraw)

驗證變更後的行為或維護驗證流程時，請閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#verification)。

確保驗證器及其功能對照表如實反映現況。依據原始碼與實際執行行為，涵蓋每項已對照的功能。回傳一種結果：**乾淨**、**已變更**或**受阻**。

## 範圍限制

僅編輯驗證技能目錄：其 `SKILL.md`、功能對照表及其所屬的輔助工具。絕不編輯產品程式碼。若應用程式已不再提供某項行為，代表文件與現況不符或產品發生迴歸；修復前者，回報後者。

## 執行流程

1. **定位。** 依已記錄的能力找出專案本機驗證器，而非要求 `verify-*` 前綴。對 T3 Code 的應用程式與行動端技能，套用[原生驗證約定](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/T3CODE-SKILLS.md#native-verification)。使用驗證器實際的啟動、就緒、操作、證據與清理說明。若沒有驗證器涵蓋該流程，轉交至 `/create-verification-skill`。若有多個適用驗證器，為每個受影響的介面指定負責者；只有歸屬仍不明確時才詢問。
2. **核對索引。** 比較 `features/README.md` 與同層級的功能檔案。移除失效項目，並加入從路由、命令、選單或公開文件中找到但尚未列入的具體使用者介面。
3. **原始碼涵蓋範圍。** 針對每項功能，追查目前的進入點、穩定控制介面、先決條件與可觀察結果。記錄可能與現況不符之處，並附上原始碼位置及一個實際執行步驟。除非使用者明確授權委派，否則依序檢查。
4. **實際執行涵蓋範圍。** 先執行驗證器的 doctor，再逐一驅動每項功能至少一次。依驗證器規範，對 UI／服務使用單一、隔離且長時間運作的執行個體，或為短時間運作的 CLI 各自建立全新的隔離工作階段。在清理前擷取證據。
5. **安全復原。** 檢查[重放資料包](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/verification-replay.md)的測試資料或結構描述偏移，以及功能一致性。驅動結果出乎預期後，再次執行 doctor；若 doctor 無法偵測卡死狀態，請重設或重新啟動。清除失敗反覆執行留下的殘留物，但不要刪除證據。每次修復測試工具後，都要重新實際執行。
6. **分類處理。** 使用者說明錯誤屬於文件與現況不符。功能可正常運作，但測試工具無法驅動，屬於測試工具缺口。產品行為故障屬於產品缺口：回報問題，並保持產品程式碼不變。
7. **完成。** 關閉並移除本次執行所建立的資源，並確認證據仍保留。重新閱讀已變更的驗證器檔案。透過呼叫端要求的端點交付結果。

## 執行記錄

- **結果：** `clean | changed | blocked`。
- **涵蓋範圍：** 每項功能的原始碼與實際執行證據。
- **修正：** 對照表、操作說明或輔助工具的修正，以及重新執行的結果。
- **產品缺口：** 具體的行為缺陷與重現步驟，不在驗證器中掩飾問題。
- **限制：** 無法滿足的先決條件、已嘗試的路徑，以及剩餘風險。

`clean` 要求每項已對照功能皆有原始碼與實際執行涵蓋證據。`changed` 要求每項修正皆成功重新執行。`blocked` 須指出確切缺少的先決條件。
