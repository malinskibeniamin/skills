---
title: /swarm
description: 用於跨工作樹工作線執行獨立批次工作的平行執行器。
type: skill
sidebar:
  label: /swarm
---
![／swarm 技能示意圖](/diagrams/skills/swarm.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/swarm.excalidraw)

將獨立的批次工作分派至隔離的工作線，逐一驗證後再合併結果。Swarm
會執行既有目標；它不會取代規劃，也不負責交付端點。

使用 `/swarm <free-form goal>`。根據使用者的文字推斷工作線。除非缺少必要的情境資訊，否則啟動前不要要求核准。
叫用 `/swarm` 或明確要求平行代理，即表示選擇啟用原生 Codex
子代理。啟用任何其他技能皆不代表授予此項同意。

## 定位

- `/work` 負責生命週期。
- `/grilling` 敲定計畫與文件。
- `/swarm` 加速執行獨立工作線。
- `/go` 負責驗證與交付。

## 啟動流程

1. 快速掌握情境：檢查目前的儲存庫狀態、規則、文件、分支、PR，以及存在時的有效目標。在內部使用 `/prime` 風格的簡報。
2. 對於長時間／高成本的 swarm，在第一波之前及各波之間套用 `/efficient-frontier` 的用量限制預算。預設節流：除非使用者另有指示，否則最多同時執行 3 個代理。
3. 在底層使用 `/efficient-frontier`：由協調者負責協調、整合與最終審查；委派範圍明確的儲存庫搜尋、實作、測試與日誌精簡工作線。
4. 根據文字選擇工作區政策：
   - 預設：使用相同的分支／工作樹／PR。
   - 如果使用者要求分離、隔離或每個代理各自使用工作樹：為每條工作線建立一個工作樹／分支。
   - 如果衝突風險很高：拆分寫入工作或依序執行；在資訊清單中說明原因。
5. 擬定精簡的 swarm 資訊清單，然後立即啟動：
   ```txt
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane-name>: <mission> | scope: <paths> | skills: </skill...>
   ```
6. 僅建立彼此不同的工作線。不要建立重複或定義模糊的代理。
7. 協調者在本機處理關鍵路徑、合併結果、解決互相衝突的發現、進行驗證，並關閉代理。

## 工作線設計

每條工作線都會收到一份工作封包：

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [/prime, /tdd, /review]
context: docs, decisions, branch or PR, relevant paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or "report-only"
forbidden: duplicate lanes, unrelated files, commits, pushes unless asked
termination: concrete deliverable and stop condition for this lane
model_policy: inherit by default; override only when useful or user asks
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

除非封包指定 `report-only`，否則代理可以讀取及寫入。在共用政策下，請指派檔案擁有權，或讓大量寫入的工作線依序執行。在工作樹政策下，分支名稱應具描述性，建立工作樹時可採用 `<owner>/<ticket>/<lane-desc>` 格式。
除非另行授權巢狀委派，否則已建立的工作線不得建立下層代理。

## 技能組合

- 長時間／高成本的波次控制：由 `/efficient-frontier` 負責用量檢查及暫停／繼續的交接。
- 啟動工作線之前及各波之間：使用 `/efficient-frontier`；僅在可取得最新主機配額快照時使用
  `/stay-within-limits`。
- 工作線模型選擇：使用 `config/model-routing.json`。每個寫入範圍只指派一位
  實作負責人；不要將同一項實作重複交給一組模型。由評估把關的
  變體在消融測試套件正式採用前仍不可使用。
- 前沿模型權杖規範：由 `/efficient-frontier` 決定哪些工作要委派、哪些要保留給協調者。
- 工作者工作線從一開始就撰寫最精簡清楚的解決方案；審查者工作線直接評估語意密度。
- 架構：依情境、模組、接縫或配接器分散執行 `/improve architecture`。
- TDD：依獨立行為或公開介面拆分涵蓋範圍。在編輯正式環境程式碼前先完成 RED；結果中必須包含 RED->GREEN 或測試失敗的證據。
- 技能／測試框架工作：為每條工作線指派評估的負責人。每個變更的技能或掛鉤都必須在範圍內有對應的評估，並由該工作線或協調者負責。
- 設計／文案工作：只有在寫入範圍不重疊時，才能拆分 `/visual-review`、`/ux-copy`、無障礙與表達工作線。
- 審查：拆分標準、規格、韌性、安全性、效能、測試、使用者體驗與強化論證等面向。
- 診斷：拆分重現迴圈、假設、檢測工具與迴歸測試。
- 產品：結合 `/grilling` 探索模式、`/prototype` 與 `/steelman` 工作線，以提出選項及反方意見。
- 交接：完成 grilling 後建立精簡封包，讓每個代理都能從目前的決策開始工作。
- 學習：依理論、範例、儲存庫中的用法、權衡與陷阱拆分主題。

## 合併協定

- 閱讀每項結果；對於寫入工作線，不要盲目信任摘要。
- 有意識地套用或保留變更；絕不要盲目接受重疊的編輯。
- 建議互相衝突時：呈現選項、證據及協調者的建議。
- 合併後執行針對性檢查。對於 TDD 工作線，實作證據之前必須先有測試失敗的證據。
- 最終輸出：資訊清單摘要、已合併的變更、已拒絕／延後的工作、測試、阻礙因素、下一步行動。

## 相容性

Codex 與 Claude Code 必須根據提示和成品運作，而非依賴隱藏掛鉤。有原生子代理可用時請使用它們。如果沒有子代理工具，請將工作封包輸出為交接檔案或指令，以供手動啟動。
