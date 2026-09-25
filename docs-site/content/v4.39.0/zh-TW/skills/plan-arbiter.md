---
title: /plan-arbiter
description: 仲裁相互競爭的計畫。適用於從代理程式、逐字稿、視覺化計畫、PR 說明、檔案或貼上的策略中選擇或合併提案。
type: skill
sidebar:
  label: /plan-arbiter
---
![「/plan-arbiter」技能示意圖](/diagrams/skills/plan-arbiter.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/plan-arbiter.excalidraw)

閱讀 `references/builder-upstream.md` 以取得評判檢查清單。

將相互競爭的計畫整合成一個可執行的方向。保留最佳構想、排除薄弱的假設，並產出明確的交接內容，而不是含糊混雜的方案。

## 工作流程

1. 收集來源計畫：貼上的文字、本機檔案、工作階段 ID、逐字稿、PR、留言、視覺化計畫連結或聊天記錄。
2. 將每個計畫標準化：目標、範圍、假設、未解決的問題、涉及的檔案、執行順序、驗證、復原方式、複雜度。
3. 視需要根據實際的程式碼庫、文件、規格、測試、螢幕截圖或外部系統進行交叉審查。
4. 做出決定：`Adopt`、`Hybrid` 或 `Revise first`。
5. 產出一份包含驗證關卡與遭否決替代方案的執行交接內容。

除非使用者在決策後明確要求實作，否則規劃作業僅限唯讀。

## 平手裁決準則

1. 正確性及與使用者要求的契合度。
2. 以實際檔案、API、測試、資料及 UI 行為為依據的程度。
3. 較低的不可逆風險。
4. 範圍更小、可發布且驗證更嚴謹的交付內容。
5. 更明確的執行者交接內容。

## 輸出

```md
## Plan arbiter
Sources: <plans inspected>
Verdict: Adopt <plan>|Hybrid|Revise first
Why: <evidence-backed reason>
Execution plan: <ordered steps>
Rejected alternatives: <what and why>
Verification gates: <commands/checks>
Open questions: <only blockers>
```
