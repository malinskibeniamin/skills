---
title: /brain-dump
description: 在深入釐清前，將缺乏結構的想法、筆記、文章、檔案或連結整理成有依據的機會摘要。適用於使用者大致知道要處理的範圍，但尚未有穩定的目標或聚焦的提問時。
type: skill
sidebar:
  label: /brain-dump
---
![「/brain-dump」技能示意圖](/diagrams/skills/brain-dump.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/brain-dump.excalidraw)

將原始訊號整理成選用的探索資料包，供後續的 `/grilling` 工作階段使用。保留
議題廣度：一份傾訴內容可能揭露數個彼此獨立的問題、任務、工單或研究方向。
維持在探索階段。除非使用者要求儲存或發布，否則請在對話中回傳摘要；不要
實作、建立工單，或將機會轉化為承諾。

## 1. 先完整吸收，再開始塑形

將對話、筆記、附件、檔案與連結視為同一份傾訴內容。如果使用者表示
還在說，請簡短回應並等待。否則直接進行，不必拘泥形式。
閱讀提供的材料與儲存庫證據。若只有文章或連結而沒有問題，
請擷取其主張、結論、限制、時機與影響。當現行標準、
API 或路線圖至關重要時，請透過 `/read-the-damn-docs` 或 `/research` 追溯第一手來源。

區分：

- 來源事實與儲存庫事實；
- 使用者的觀察、偏好與限制；
- 合理的推論，並標示為推論；
- 相互矛盾及確實未知的資訊。

絕不要求使用者重複傾訴內容或證據中已經提供的答案。

## 2. 重建問題範圍

擷取相關角色、痛點、成果、系統、觸發條件、限制、構想、已排除的方向、
急迫性與成功指標。將隱含的答案整理至 **答案台帳**，並歸入以下三種狀態：

- **已確認** -- 明確指出或有直接依據；
- **暫定** -- 經推論得出，且可放心質疑；
- **未知** -- 尚未提供，並可能改變方向。

在提出工作項目之前，先說明整體範圍；區分需求與建議的解決方案。

## 3. 擴展機會地圖

產出所有實質不同且有證據支持的方向；合併重複項目。通常列出 2 至 5 個，但若有
充分依據，則保留更多項目。只有在有依據時，才納入產品、使用者體驗、工程、文件與研究方向。

針對每個機會，說明：

1. 成果、受影響的角色與支持證據；
2. 可行的工作產出、相依性、風險與待定決策；
3. 成本最低的下一步驗證：查詢、原型、量測或可逆的小範圍實作。

根據價值、證據、急迫性與可逆性，建議起始方向或可相容的方向組合。
保留其他替代方案；機會地圖並不代表每個項目都應成為待辦工作。

## 4. 回傳成果

使用以下結構，移除空白章節：

```markdown
## Brain dump brief

### Orientation
<surface, central tension, and recommended starting direction or bundle>

### Source synthesis
<important conclusions, facts, implications, contradictions, and citations or paths>

## Answer ledger
| Likely grilling question | Extracted answer | State | Evidence |
|---|---|---|---|
| ... | ... | Settled / Tentative / Unknown | ... |

## Opportunity map
### <Opportunity>
- Outcome:
- Why this is plausible:
- Work products:
- Risks and dependencies:
- Cheapest next proof:

## Grilling handoff
- Settled context to preserve:
- Tentative assumptions to challenge:
- Material user decisions still open:
- Facts to look up without asking the user:
- Candidate prototypes or measurements:
```

讓成果本身包含足夠資訊，方便進入下一階段，但應連結或引用來源，而非直接複製。

## 5. 交接至深入釐清

當仍有重要決策尚未確定時，繼續使用 `/grilling`。傳遞每一個機會方向。只詢問
可能推翻某個方向或影響其優先順序的 **未知** 項目；當潛在缺點相當重要時，
質疑 **暫定** 項目。除非證據與其矛盾，否則將 **已確認** 項目視為已回答。

否則，請在摘要後停止，並建議下一個查詢、原型、規格、規劃或行動。
