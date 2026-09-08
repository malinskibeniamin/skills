---
title: /agent-watchdog
description: "依據原始要求與即時證據稽核另一個代理。適用於工作階段、PR、分支、比較、已授權的修正或接手停滯工作。"
type: skill
sidebar:
  label: /agent-watchdog
---
![「/agent-watchdog」技能圖解](/diagrams/skills/agent-watchdog.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/agent-watchdog.excalidraw)

當稽核較為複雜或來源成品語意不明時，請閱讀 `references/builder-upstream.md`。

## 模式

- **僅監看**：監控工作階段、PR、分支、CI 執行或逐字稿，直到進入終止狀態。請勿編輯。
- **稽核**：比較要求、逐字稿、差異、測試、CI、留言、螢幕截圖與最終聲明。請勿編輯。
- **稽核並修正**：先進行稽核，再針對明確且已授權的缺漏進行小範圍修正。
- **比較**：依據同一項原始要求，比較多個代理或工作階段。
- **接手**：明確要求接手停滯工作；遵循 [references/takeover.md](https://github.com/malinskibeniamin/skills/blob/main/agent-watchdog/references/takeover.md)，然後執行至要求的終點。不侷限於修補先前的做法。

當編輯權限不明確時，預設僅進行稽核。

## 工作流程

接手模式請使用其參考文件，而不是下方僅限小範圍稽核修正的步驟。

1. 確認每個目標：工作階段 ID、逐字稿、討論串 URL、PR、分支、提交、CI 執行、議題、Slack 連結或貼上的摘要。
2. 重建約定：原始要求、範圍變更、限制、隱含的驗收條件、最終聲明與注意事項。
3. 檢視證據，而非憑感覺判斷：已變更的檔案、周邊程式碼、實際命令輸出、CI、螢幕截圖、尚未解決的留言、部署日誌。
4. 將每個問題分類為：`Gap`、`Bug`、`Verification miss`、`Scope drift` 或 `No issue`。
5. 若已獲授權，僅修正明確的缺漏；除非使用者要求，否則絕不還原不相關的工作或切換分支。
6. 回報狀態，並附上確切的檔案、命令、未解決的風險與下一步行動。

## 輸出

```md
## Agent watchdog
Target: <artifact>
Mode: watch|audit|audit-and-fix|compare
Contract: <what the user asked>
Evidence checked: <files/commands/CI/comments>
Findings:
- <Gap|Bug|Verification miss|Scope drift|No issue>: <evidence and required action>
Fixes made: <if any>
Still open: <blockers or risks>
```
