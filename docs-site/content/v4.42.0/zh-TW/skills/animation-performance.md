---
description: "診斷已測得的網頁動畫卡頓、掉影格、繁忙執行緒上的動效、逐影格 React 工作、CSS 變數失效和 GPU 圖層成本。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animation performance"]}
sidebar: {"label":"/animation-performance"}
title: "/animation-performance"
type: "skill"
---
![「/animation-performance」技能示意圖](/diagrams/skills/animation-performance.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/animation-performance.excalidraw)

先定位影格瓶頸，再修改動效。改編自 Emil Kowalski；
參見[來源](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/EMIL-SKILLS-CREDITS.md)。稽核意味著報告；明確的修復請求
則繼續透過驗證及專案交付檢查。

## 迴圈

1. 記錄故障互動：路由、資料規模、動畫驅動方式/屬性、瀏覽器/裝置、重新整理率，
   以及重疊的導航/載入。將基線 Performance 軌跡儲存到 `.context/`；靜態程式碼疑點不等於測得的卡頓。
2. 定位拖延影格的工作：JavaScript/React、樣式失效、版面配置、繪製、合成或過量圖層記憶體。
   60 Hz 時每影格約 16.7 ms，120 Hz 時約 8.3 ms；桌面流暢不能證明手機表現。
3. 用最小的等價改動檢驗一個原因：

   | 證據 | 候選改動 |
   |---|---|
   | 每影格都觸釋出局 | 改為變換裝飾元素；保留所需文件流幾何關係 |
   | 陰影/模糊繪製昂貴 | 縮小繪製區域或簡化效果；比較視覺含義 |
   | 動效期間 JS 繁忙 | 使用適用的 CSS/WAAPI 路徑；確認實際在合成器執行 |
   | React 每影格算繪 | 使用動效值或有界的 ref 更新；保留有語義的 React 狀態 |
   | 成本隨後代增加 | 將繼承的 CSS 變數寫入侷限到運動元素 |
   | Motion 單獨變換屬性未獲加速 | 檢查已安裝版本後嘗試完整 `transform` |
   | 建立圖層造成可見停頓 | 區域性、臨時使用 `will-change`；收益未證實就移除 |

4. 在相同的基線/候選條件下重放，比較延遲影格、版面配置/繪製和記憶體。
   重新檢查快速反轉、取消、減少動態效果、焦點和視覺等價性。
   拒絕僅轉移成本的改動，以及小於執行間波動的變化。
5. 報告原因、`檔案:行號`、軌跡路徑、前後測量值和裝置限制。
   無法使用裝置時，針對該硬體的結果仍是未驗證，而不是可以編造。

## 約束

- 指明過渡屬性，不用 `all`；預設選擇 `transform`/`opacity`。
- 硬體加速是漸進增強。CSS、WAAPI 和 Motion 都不作全面保證；檢查
  [當前 Motion 指南](https://motion.dev/docs/performance)及已安裝函式庫的執行路徑。
  CPU 限速並不能模擬 GPU 或手機記憶體。
- 縮放不是高度/padding 的通用替代：它會縮放文字，卻不改變文件流。
  先保證正確性，再選擇更廉價的算繪路徑。
- 在受支援瀏覽器分析 blur/filter/clip-path；固定的畫素閾值證明不了什麼。
- 解除安裝時取消逐影格迴圈、觀察器和動畫，移除臨時圖層提示。
  記憶化由 React Compiler 負責；不要用 memo 包裝代替診斷。

如果主要成本來自路由載入、包體積或後端，而非影格，按
[依賴載入約定](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)
載入 [ux-performance](https://github.com/malinskibeniamin/skills/blob/v4.42.0/ux-performance/SKILL.md)。
