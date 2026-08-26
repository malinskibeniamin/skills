---
title: /swarm
description: "透過工作樹通道並行執行相互獨立的批次工作。"
type: skill
sidebar:
  label: /swarm
---
![／swarm 技能示意圖](/diagrams/skills/swarm.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/swarm.excalidraw)

# Swarm

把相互獨立的批次工作拆分到多個通道，逐一驗證後再整合。Swarm 執行已有目標；它不替代規劃，也不負責交付。並行工作必須由使用者透過 `/swarm` 或直接請求明確選擇；其他技能不構成授權。

`/work` 負責生命週期，`/grilling` 解決選擇，`/go` 負責釋出。

## 啟動

1. 檢查倉庫規則、狀態、分支或 PR、相關文件和當前目標。
2. 對長時間或高成本批次，在啟動前及批次之間使用 `/efficient-frontier`。除非使用者另有要求，最多同時執行三個智慧體。
3. 協調者保留編排、關鍵路徑、整合和判斷。僅委派邊界明確的搜尋、實現、測試或證據歸納工作。
4. 選擇工作區策略：
   - 預設：共用分支、工作樹和 PR。
   - 使用者要求隔離：每個通道使用一個描述性工作樹和分支。
   - 衝突風險高：分離作用域或序列寫入。
5. 展示簡潔清單後啟動：

   ```text
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane>: <mission> | scope: <paths> | skills: </skill...>
   ```

6. 只建立不同的通道。協調者整合結果、解決衝突發現、執行最終驗證並關閉智慧體。

## 任務包

每個通道收到：

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [only relevant skills]
context: rules, decisions, branch or PR, paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or report-only
forbidden: duplicate work, unrelated files, commits or pushes unless requested
termination: deliverable and stop condition
model_policy: inherit unless evidence or the user requires an override
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

Worker 只能寫入其作用域。共享通道必須有不同的所有權；工作樹通道使用描述性分支；建立後代智慧體需要單獨授權。

## 通道規則

- 使用 `config/model-routing.json`；不要讓不同模型重複同一實現。
- 每個寫入作用域只能有一個實現負責人；每個變更的技能或鉤子也要指定相應評估或評估負責人。
- TDD 通道在實現證據前返回 RED -> GREEN 或失敗測試證據。
- 按模組或接縫拆分架構工作；按獨立公共行為拆分測試。
- 僅在作用域不重疊時拆分 `/visual-review` 與 `/ux-copy`。
- 審查通道可按規範、標準、韌性、安全、效能、測試和 UX 拆分。
- 診斷通道可按復現、假設、插樁和迴歸證明拆分。
- 綜合判斷和使用者保留決策由協調者負責。

## 整合協議

讀取產物和變更檔案，不只看摘要。有意拒絕或協調重疊。建議衝突時，展示證據、選項和協調者的選擇。整合後執行聚焦檢查；TDD 工作必須先有 RED 證據再有 GREEN。報告清單、採納與拒絕的工作、測試、阻塞項和下一步。

## 相容性

Codex 與 Claude Code 必須依據明確提示和產物工作。沒有原生子智慧體時，輸出任務包供手動啟動。
