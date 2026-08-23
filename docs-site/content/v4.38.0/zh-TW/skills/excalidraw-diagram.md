---
title: /excalidraw-diagram
description: 根據提示詞或 Mermaid 產生、完善並匯出可編輯的 Excalidraw 圖表。適用於手繪風格的架構圖、元件剖析圖、流程圖及含註解的技術插圖。
type: skill
sidebar:
  label: /excalidraw-diagram
---
![/excalidraw-diagram 技能的圖表](/diagrams/skills/excalidraw-diagram.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/excalidraw-diagram.excalidraw)

產生真正的 Excalidraw 元素，而不是點陣圖仿製品。保留一份可編輯的單一真實來源，
並從中衍生展示用資產。

在轉換 Mermaid、直接建立元素或
比照 Shadcn 風格的視覺語言之前，請先閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/excalidraw-diagram/REFERENCE.md)。

## 畫布

透過固定版本的 CLI 執行每個畫布指令：

```bash
export EXPRESS_SERVER_URL="http://127.0.0.1:${CONDUCTOR_PORT:-3000}"
bunx mcp-excalidraw-server@1.1.0 <command>
```

讓 `bunx` 使用其共用快取；不要將 CLI 加入使用此技能的儲存庫。
若有 Conductor 配置的連接埠，環境會選用該連接埠，否則使用連接埠 3000。
執行 `start`，在隔離的瀏覽器中開啟 `$EXPRESS_SERVER_URL`，保持分頁開啟，接著
確認 `status` 回報已有瀏覽器用戶端。如果無法使用隔離瀏覽器自動化，
請使用者開啟一次回報的 URL。

## 工作流程

1. 選擇目的地。拋棄式工作請使用 `.context/excalidraw/<slug>/`；永久資產則使用
   指定的專案路徑。避免覆寫現有檔案。
2. 清除任何現有畫布或使用 `--replace` 匯入之前，先以 `snapshot save <name>` 或 `export --out <file>`
   保留畫布。
3. 選擇一個標準來源。若交付成果為 Mermaid，請以 `.mmd` 作為權威來源，並
   在目標轉譯器中驗證。若交付成果為 Excalidraw，Mermaid 僅是匯入用的
   鷹架；直接編輯後，以 `.excalidraw` 作為權威來源。
4. 標準的流程、序列、狀態或關係結構應透過 Mermaid 處理；精確定位、元件剖析、
   標誌、區域或自由形式的標註則使用直接元素。
5. 在一次 `mermaid`、`add` 或 `apply` 呼叫中建立完整的第一版。為任何可能
   移動或變更的項目指定有意義的 ID。
6. 執行 `mermaid` 後，請執行 `describe`，並在匯出或直接修正前確認已有轉換後的元素。
   如果螢幕截圖可正常轉譯，但描述的場景仍為空白，請繼續以 `.mmd`
   作為標準來源，或使用直接元素重新建立；絕不可將空白的 `.excalidraw` 回報為可編輯檔案。
7. 執行 `describe`，接著執行 `screenshot --out <check.png>` -> 檢視圖片 -> 使用一次 `apply` 修補來修正碰撞、
   裁切、對比不足及箭頭交叉。重複此流程，直到畫面整潔。
8. 對於同步的畫布，請匯出非空白的 `.excalidraw`，以及 PNG 或 SVG。否則，
   在 Mermaid 仍為權威來源時，匯出 `.mmd` 與轉譯後的資產。對於專案
   資產，除非使用者要求單一扁平化檔案，否則請將可編輯的原始檔與轉譯檔放在一起。
9. 回報最終路徑、圖表模式、標準來源、無障礙描述的位置，以及
   任何仍需手動完成的瀏覽器編輯。

## 指令

```bash
# Mermaid
bunx mcp-excalidraw-server@1.1.0 mermaid diagram.mmd

# Direct scene or atomic correction
bunx mcp-excalidraw-server@1.1.0 add elements.json
bunx mcp-excalidraw-server@1.1.0 apply patch.json

# Inspect and export
bunx mcp-excalidraw-server@1.1.0 describe
bunx mcp-excalidraw-server@1.1.0 screenshot --out check.png
bunx mcp-excalidraw-server@1.1.0 export --out diagram.excalidraw
bunx mcp-excalidraw-server@1.1.0 screenshot --format svg --out diagram.svg
```

## 安全性

- 將 `clear --yes`、`import --replace` 及快照還原視為具破壞性的畫布
  操作；請先保留目前場景。
- 僅在使用者要求公開的 Excalidraw 連結時使用 `share`，因為它會上傳
  場景。
- 精確的標誌請使用 SVG 或匯入的品牌資產；不要仿製受保護的商標。
- 若檔案匯出後預期不再進行編輯，請使用 `stop` 停止本機伺服器。
