---
description: 根據提示詞或 Mermaid 產生、完善並匯出可編輯的 Excalidraw 圖表。適用於手繪風格的架構圖、元件剖析圖、流程圖及含註解的技術插圖。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - excalidraw diagram
sidebar:
  label: /excalidraw-diagram
title: /excalidraw-diagram
type: skill
---
![/excalidraw-diagram 技能的圖表](/diagrams/skills/excalidraw-diagram.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/excalidraw-diagram.excalidraw)

建立可編輯的原生元素。場景格式、畫布/SVG 與視覺語言請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/REFERENCE.md)；後端 PR 與持續維護的文件請閱讀 [PR-WORKFLOW.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/PR-WORKFLOW.md)。

## 預設本機轉譯 [#local-default]

建立或更新原生 `.excalidraw` 檔案，再以固定版本的官方 CLI 轉譯：

```bash
EXCALIDRAW_NO_UPDATE_NOTIFIER=1 bunx @excalidraw/cli@0.2.0 render diagram.excalidraw --out diagram.png
```

需要 Node 22 或更新版本，以及已安裝的 Chrome/Chromium/Edge/Firefox；使用暫存瀏覽器設定檔，不需帳號或 API 金鑰。僅輸出 PNG，不負責配置版面。使用 `bunx` 快取，不要加入使用端的相依套件；Mermaid、即時編輯與 SVG 使用參考文件中的選用畫布方案。

## 工作流程 [#workflow]

1. 選擇目的地：暫存 `.context/excalidraw/<slug>/` 或指定的永久路徑。絕不默默覆寫檔案。
2. 替換前保留原始檔；使用畫布時，在清除或替換前執行 `snapshot save <name>` 或 `export --out <file>`。
3. 選擇權威來源：Mermaid 交付成果使用 `.mmd`，直接編輯後使用 `.excalidraw`。在目標轉譯器中驗證 Mermaid。
4. Mermaid 負責標準流程、序列、狀態與關係；直接元素負責精確定位、元件剖析、標誌、區域與標註。
5. 為可變元素指定穩定的 ID。在本機建立原生元素；畫布簡寫模式使用一次 `mermaid`、`add` 或 `apply` 建立第一個完整版本。
6. Mermaid 轉換後，在匯出或修正前執行 `describe` 檢查元素。如果螢幕截圖能轉譯，但場景為空白，請繼續以 `.mmd` 為權威來源或直接重建；絕不可將空白 `.excalidraw` 宣稱為可編輯檔案。
7. 轉譯 PNG，或在畫布中先執行 `describe` 再執行 `screenshot` -> 檢視圖片 -> 修正重疊、裁切、對比與箭頭交叉問題。重複直到圖表整潔。
8. 驗證原生元素非空白且標籤可見；將 `.excalidraw` 與 PNG 或 SVG 保存在一起。僅使用 Mermaid 的備用方案仍是 `.mmd` 加上轉譯圖，不是可編輯 Excalidraw 的宣稱。
9. 回報路徑、模式、標準來源、無障礙描述與手動瀏覽器操作。

## 安全性 [#safety]

- `clear --yes`、`import --replace` 與還原操作具有破壞性；請先保留原始檔。
- `share` 會上傳場景；僅在使用者要求公開連結時使用。
- Excalidraw+ 同步需明確選擇啟用；Git 保持權威。後端圖表失敗不阻擋交付；回報缺少的證據並繼續交付。
- 精確標誌使用 SVG 或匯入的品牌資產；不要仿製受保護的商標。
- 僅停止自己啟動的畫布伺服器。
