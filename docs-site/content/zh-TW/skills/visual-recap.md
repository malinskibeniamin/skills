---
title: /visual-recap
description: 為 PR、分支、提交或差異建立互動式視覺摘要。
type: skill
sidebar:
  label: /visual-recap
---
![「/visual-recap」技能示意圖](/diagrams/skills/visual-recap.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/visual-recap.excalidraw)

本機覆寫：將上游的 `npx @agent-native/core` 範例改為 `bunx @agent-native/core`。

## 必要參考資料

建立摘要前，請先閱讀 `references/agent-native-recap.md`。該文件定義了完整的視覺摘要建立規範、禁止行內嵌入規則、Plan MCP URL 規則、差異至區塊的對應方式、遮蔽處理、安全性可見度、僅限本機檔案的隱私模式，以及審查意見回饋迴圈。

僅在相關時閱讀以下文件：

- `references/connection.md` -- 連接器探索、重新連線步驟，以及禁止行內嵌入時的備援方式。
- `references/local-files.md` -- 無託管資料庫／僅限本機的摘要模式。
- `references/wireframe.md` -- 可見差異的 UI 線框圖規則。

## 本機測試框架覆寫

- 當使用者明確呼叫 `/visual-recap` 時，請建立摘要，或將其連結至指定的 PR、分支、
  提交或差異。
- 摘要建立屬於額外的成果物工作；`/commit-push-pr` 和 `/go` 不會
  自動呼叫此功能。
- 若有具實質意義的架構或資料流變更，請使用 `/excalidraw-diagram` 建立
  `.excalidraw` 原始檔以及 PNG 或 SVG。請將 Agent-Native 摘要保留為主要審查
  介面：僅在目前的區塊目錄支援媒體時嵌入轉譯後的資產；
  否則請使用其 `diagram` 區塊，並在交接說明中附上原始檔／匯出檔路徑。
  若是簡單圖表或畫布無法使用，優先採用內建的 Mermaid 方式。
- 摘要內容必須以實際差異為依據。請遮蔽機密資訊，且不要推論已變更行中未包含的事實。
- 如果明確指定的目標不具任何有意義的視覺結構，請回傳相關證據，
  不要憑空製作摘要。
