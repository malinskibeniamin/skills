---
title: /to-tickets
description: "將計劃拆分為具有明確阻塞邊的貫穿式工單。"
type: skill
sidebar:
  label: /to-tickets
---
![「/to-tickets」技能示意圖](/diagrams/skills/to-tickets.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/to-tickets.excalidraw)

將已批准的計劃、規格或對話變成可獨立驗證的縱向切片。
若存在 `CLAUDE.md`，先讀它；否則讀 `AGENTS.md`。遵循其中的 Issue tracker 指標。缺失時使用 `/work-automation-kit` 或本地後備方案。

## 1. 收集

使用現有對話上下文。獲取傳入規格、問題或 URL 的完整正文和評論。僅在當前程式碼或領域詞彙仍不清楚時探索；遵循專案詞彙表和 ADR。先讓變更變容易，再做容易的變更。

## 2. 起草切片

每個工單：

- 貫穿所需層次的狹窄端到端路徑，而非某一層的橫向切片。
- 可獨立演示或驗證，並適合一個全新上下文視窗。
- 只宣告真實阻塞項；沒有阻塞即表示可開始。
- 描述使用者行為和驗收，不寫易過期的檔案路徑或程式碼片段。

**寬泛重構是例外。** 使用 expand、migrate、contract：在舊形式旁增加新形式；按可獨立保持綠色的批次遷移呼叫方；最後刪除舊形式。每個 migrate 批次都被 expand 阻塞。contract 被所有 migrate 批次阻塞。若批次不能獨立保持綠色，使用整合分支和最終 integrate-and-verify 工單。

若多個工單圖仍成立，使用 `/plan-arbiter`。若大型圖的前沿或阻塞關係需要檢查，使用 `/visual-plan`。

## 3. 確認

用編號列表展示**標題**、**阻塞於**和**交付內容**。詢問粒度、邊關係以及是否拆分或合併。迭代到使用者批准。

## 4. 釋出

每個工單釋出一個事項，阻塞者優先。不要修改或關閉父事項。

- **本地：** 寫入 `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`，從 `01` 編號。每個檔案列出阻塞工單編號和標題。
- **跟蹤器：** 每個工單建立一個問題。有原生子問題和阻塞關係時使用它們，否則寫明確連結。應用已配置的 `ready-for-agent` 角色。

前沿由所有阻塞項已完成的工單組成。

```markdown
# <NN> -- <工單標題>
**構建內容：** <使用者視角的端到端行為>
**阻塞於：** <工單編號和標題，或 None -- 可立即開始>
**狀態：** ready-for-agent
## 驗收標準
- [ ] <可觀察標準>
```

跟蹤器問題存在父項時新增 `## Parent`，之後是 `## What to build`、`## Acceptance criteria` 和 `## Blocked by`。
不要內聯實現細節。對於 `/prototype` 程式碼，新增指向其持久位置的上下文指標。
