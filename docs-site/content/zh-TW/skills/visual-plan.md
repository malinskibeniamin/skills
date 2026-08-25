---
title: /visual-plan
description: >-
  使用圖表、檔案對應圖、附註程式碼與 UI 審查，建立互動式 Agent-Native 視覺計畫。適用於規劃非簡單的產品、UI、架構、資料、API
  或互相競爭的方案。
type: skill
sidebar:
  label: /visual-plan
---
![「/visual-plan」技能的圖表](/diagrams/skills/visual-plan.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/visual-plan.excalidraw)

本機覆寫：將上游的 `npx @agent-native/core` 範例改為 `bunx @agent-native/core`。

## 必要參考資料

建立或更新視覺計畫前，請先閱讀 `references/agent-native-plan.md`。此文件定義完整的 Agent-Native 計畫契約、Plan MCP 用法、區塊目錄要求、視覺介面選擇、留言回饋迴圈、本機檔案隱私模式，以及文件品質規則。

僅在相關時閱讀以下文件：

- `references/connection.md` -- 連接器探索、絕不內嵌的備援方案、重新連線步驟。
- `references/local-files.md` -- 本機／離線／私密計畫模式。
- `references/wireframe.md` -- 線框稿 HTML/CSS 規則。
- `references/canvas.md` -- 畫布／原型審查介面。
- `references/document-quality.md` -- 獨立計畫的品質門檻。
- `references/exemplar.md` -- 計畫結構範例。

## 本機作業環境覆寫

- 對於重要計畫，請遵循 [`../shared/intent-map.md`](https://github.com/malinskibeniamin/skills/blob/main/shared/intent-map.md)。在既有的 Agent-Native 圖表或畫布介面中呈現首次閱讀圖，不要再建立第二個說明成果物。
- 當多個計畫或代理程式意見不一致時，使用 `/plan-arbiter`。
- 實作前若仍有未決事項，使用 `/grilling`。
- 除非使用者明確核准實作，否則規劃作業僅限唯讀。
