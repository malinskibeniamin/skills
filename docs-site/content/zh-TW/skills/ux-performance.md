---
title: "/ux-performance"
description: "稽核並最佳化真實的 Web 使用者體驗效能。適用於緩慢的 SPA 頁面、路由、互動、超大型表格、載入、快取、記憶體、Web Vitals、Lighthouse、效能預算或 CI 退步。"
type: skill
sidebar:
  label: "/ux-performance"
---
![/ux-performance 技能示意圖](/diagrams/skills/ux-performance.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/ux-performance.excalidraw)

讓使用者更快抵達有用且回應靈敏的狀態。最佳化經過測量的關鍵路徑，而不是只看起來
昂貴的程式碼。預設以客戶端 Web 應用程式處理；只有證據顯示交付層或後端延誤使用者
旅程時，才繼續追查那些層。

## 建立效能契約

實作前先明確定義：

- **旅程**：路由、動作、起始狀態、資料量、裝置與網路等級，以及冷快取或熱快取。
  不只包含順利路徑，也要涵蓋可信的最差負載。
- **里程碑**：使用者可見的結果，例如有用內容、篩選結果或下一個完成繪製的畫面。
  加入正確性與無障礙護欄。
- **主要指標**：該里程碑的直接耗時或資源上限。
- **最小有價值變化**：可重複的 100 毫秒改善有價值；落在雜訊內的變化沒有價值。
  編輯前固定一個主要指標。
- **終點**：稽核、最佳化或安裝退步檢查。稽核只回傳發現而不編輯；最佳化持續到
  本機變更驗證完成；CI 工作只安裝經過校準的檢查。

## 執行循環

1. **盤點**真實技術堆疊、正式環境建置路徑、現有遙測、分析工具、測試、預算及已安裝
   套件版本。變更框架或函式庫語法前，先閱讀目前的第一方文件。
2. **變更程式碼前測量基準**。在接近正式環境的建置中重現相同情境與固定資料。當
   `.context/` 被忽略時，將原始追蹤存到 `.context/ux-performance/<journey>/`。依照
   [MEASUREMENT.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/MEASUREMENT.md) 結合真實使用者與實驗室證據。
3. **建立瀑布圖**，從使用者意圖一路到結果完成繪製。標記串行相依、平行或非關鍵路徑
   工作、快取狀態及最長的關鍵路徑區段。將時間歸因到排隊、網路與 TTFB、下載、解析
   與執行、應用程式工作、React 算繪與提交、樣式、版面配置及繪製。
4. **依瓶頸排序**，不要依稽核警告排序。提出 3–5 個可證偽假設，接著每次只變更一個
   因果變數。優先刪除工作、縮小輸入或移除串行相依，再考慮加速相同工作。
5. 使用 [OPTIMIZATION.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/OPTIMIZATION.md) 中範圍最小且有證據支持的選項進行**介入**。包裝器、context、快取、
   worker、編譯器、框架升級、預先擷取或伺服器端算繪都是候選方案，不是預設收益。
6. **驗證**基準與候選方案：使用相同情境、固定資料、機器、瀏覽器、建置及快取狀態。
   使用配對執行，回報中位數與離散程度。重新檢查正確性、無障礙、記憶體、bundle 與錯誤護欄。
7. **決策**。只保留明確且有價值的收益。若結果落在變異範圍內、將成本移到別處或破壞
   護欄，回報 `Value not proven — inconclusive` 並撤銷推測性複雜度。不要事後挑選指標。
8. 只在使用者要求或終點包含 CI 時**防止復發**。依照 [CI.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/CI.md) 將穩定且低成本的檢查放進 pull request，把雜訊大或深入的檢查放到夜間工作，並在部署後進行真實使用者監控。Hook 在校準前只能作為選用建議。

當效能主張涉及規模、突發負載、資源競爭或長時間工作階段時，請使用
[STRESS.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/STRESS.md) 找出容量轉折點，並驗證壓力下的正確性。

## 輸出

先提供使用者結果與最慢區段：

```md
Verdict: <測量狀態或價值結論>

| 排名 | 瓶頸 | 關鍵路徑成本 | 證據 | 下一項變更 | 信心 |
|---:|---|---:|---|---|---|
| 1 | <原因，而非症狀> | <毫秒/位元組/工作量> | <追蹤/分析> | <小範圍介入> | <高/中/低> |

Method: <精確命令、建置、固定資料、快取、裝置/網路、執行次數、基準/候選>
Guardrails: <正確性、無障礙、錯誤、記憶體、bundle>
Artifacts: <路徑或連結>
```

區分測量事實、推論與未經測試的機會。絕不能只憑 Lighthouse 分數、靜態警告、
看似更少的程式碼或相依套件升級，就宣稱速度提升。
