---
description: 將目前的工作階段精簡成一份交接文件，供另一個代理程式或新的工作階段使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - handoff
sidebar:
  label: /handoff
title: /handoff
type: skill
---
![「/handoff」技能示意圖](/diagrams/skills/handoff.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/handoff.excalidraw)

分別呼叫 Skill 工具："agent-watchdog" 用於其他執行的聲明；"plan-arbiter" 用於競爭方案。其他宿主：[載入相依項目](https://github.com/malinskibeniamin/skills/blob/v4.40.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 程序

1. 使用宿主暫存目錄（`$TMPDIR`，否則 `/tmp`；Windows `%TEMP%`），不要寫入工作區。Unix：`handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`。
2. 依[繼續執行契約](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/progress-evidence.md#continuation)保留要求的終點。引數只聚焦下一步，不取代任務或授予權限。
3. 不要複製現有產物；改用連結。遮蔽敏感資料。標明不確定性及影響重現的省略內容。
4. 回傳路徑和 1-2 句摘要。尚無有效進展時，寫一份簡短的起始說明。

僅當使用者明確要求背景代理程式時：檢查 `command -v claude`，再用 `claude --bg --name "<name>" "<summary>"` 取代檔案，並包含 `/agent-watchdog`。失敗時回傳命令和摘要，不聲稱已啟動。

## 範本

```markdown
# Handoff
契約：<原始目標、要求的終點/停止限制、保留的決策>
狀態：<儲存庫/工作樹/分支、HEAD/基準、未提交範圍、PR/議題、檢查證據>
決策/產物：<連結、證據限制、重放資料包/命令>
下一步：<重點、操作、未決事項、驗證/交付>
建議技能：<後續技能及原因>
```
