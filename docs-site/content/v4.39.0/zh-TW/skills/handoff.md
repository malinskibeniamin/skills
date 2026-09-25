---
title: /handoff
description: 將目前的工作階段精簡成一份交接文件，供另一個代理程式或新的工作階段使用。
type: skill
sidebar:
  label: /handoff
---
![「/handoff」技能示意圖](/diagrams/skills/handoff.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/handoff.excalidraw)

如果交接是為了稽核另一個代理程式的執行結果，請轉至 `/agent-watchdog`。如果交接內容包含相互競爭的計畫，請將 `/plan-arbiter` 納入下一個要使用的技能。
建立一份簡潔的交接文件，供另一個代理程式或工作階段從目前進度繼續作業。

## 使用時機

當使用者想要進行以下操作時使用：
- 在新的工作階段繼續作業
- 將工作交給另一個代理程式
- 在其他地方執行原型或平行工作線
- 保留可付諸行動的脈絡，而不攜帶完整對話紀錄

## 程序

1. 建立暫存檔：
   ```bash
   handoff_file=$(mktemp -t handoff-XXXXXX.md)
   ```
2. 將交接內容寫入該路徑。
3. 保持精簡。不要重複已記錄於規格、計畫、ADR、議題、提交、差異或文件中的成果。請透過路徑或 URL 引用它們。
4. 如果使用者提供了引數，請將其視為下一個工作階段的重點，並以該工作為核心調整交接內容。
5. 遮蔽敏感資訊：API 金鑰、密碼、權杖、祕密、個人資料、客戶資料，以及任何其他機密值。只有在遮蔽會影響後續作業時才提及。
6. 如有適用技能，建議下一個工作階段使用。
7. 僅回傳交接檔案路徑，並附上 1 至 2 句摘要。
8. **背景代理程式模式**——使用者希望新的代理程式立即接手工作：
   不要儲存檔案，改為啟動 `claude --bg --name "<descriptive name>" "<handoff summary>"`
   （先檢查 `command -v claude`；如果無法使用或啟動失敗，不要聲稱代理程式
   已啟動——請輸出確切的命令與摘要，讓使用者自行執行）。一律傳入
   具描述性的 `--name`；當下一個工作階段必須驗證此代理程式的主張時，請在建議技能中納入 `/agent-watchdog`。

## 交接範本

```markdown
# Handoff

## Next session focus
<What the next agent/session should do first.>

## Current state
<Only facts needed to resume. Include branch, cwd, PR/issue links if relevant.>

## Decisions made
<Bullets. Link to ADRs/plans/issues instead of restating them.>

## Open questions
<Bullets, or "None".>

## Next actions
1. <First concrete action>
2. <Second concrete action>
3. <Verification or shipping step>

## Relevant artifacts
- <path or URL>: <why it matters>

## Suggested skills
- </skill-name>: <why>
```

## 防護原則

- 不要將交接當成隱藏的完整摘要。僅納入繼續作業所需的脈絡。
- 優先提供路徑與 URL，而非貼上內容。
- 遮蔽祕密與個人資料。
- 明確指出不確定之處。
- 如果尚未進行任何有用的工作，請如實說明，並撰寫一份簡短的起始簡介。
