---
title: /resilience-review
description: 當可信的故障可能造成資料遺失、安全性或隱私損害、不可逆的操作、違反契約，或很可能讓使用者陷入無法繼續的困境時，執行依風險排序的墨菲審查。
type: skill
sidebar:
  label: /resilience-review
---
![／resilience-review 技能的圖表](/diagrams/skills/resilience-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/resilience-review.excalidraw)

針對可信風險進行墨菲檢查，而非窮舉所有邊界情況。

## 證據優先

當風險有信任邊界、不可逆的影響、明訂的契約、已觀察到的事件、經證實的規模，或很可能發生的使用者路徑作為佐證時，才算可信。僅僅「可能發生」並不足夠。直接略過低風險工作，無須繁文縟節。

釐清操作、狀態變更、副作用、相依項目及目前規模。只探查相關類別。原生 Codex 會以內嵌方式執行，除非使用者明確要求代理程式或叫用 `/swarm`。
- **輸入：**跨越信任邊界的格式錯誤或過時資料。
- **時序：**可能造成資料損毀或誤導的重複或亂序工作。
- **系統：**導致必要契約失效的相依項目故障。
- **狀態：**存在很可能觸發路徑的不可能狀態。
- **復原：**一般使用者可能陷入無法繼續的困境，或收到虛假的成功訊息。

對每個可信的發現，說明證據、觸發條件、預期行為、最小防護措施，以及最小公開契約測試。沒有證據就不算發現。

安全性、隱私、資料遺失及破壞性操作應採取失敗時關閉的策略。除此之外，應優先選擇明確失敗，而非推測性重試、備援方案、快取、功能旗標或可觀測性措施。

當外部行為決定風險時，使用 `/read-the-damn-docs`。透過 `/diagnosing-bugs` 確認真實缺陷，然後新增一個處於 RED 階段的迴歸測試。只有在面向客戶的復原流程中才使用 `/visual-review`。
## 輸出
```md
## Resilience review
Risk surface:
- ...
Evidence:
- ...
Credible findings:
| Scenario | Evidence | Smallest guard | Contract test |
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

規則：引用檔案／路由／表單／API。依嚴重程度排列發現；不要以數量作為獎勵。真實且高影響的缺口會構成阻擋。假設性的邊界情況不會因此成為工作項目。

請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/resilience-review/REFERENCE.md)。
