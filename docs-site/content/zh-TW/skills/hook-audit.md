---
title: /hook-audit
description: 分析 Hook 的有效性與工作階段遙測資料。適用於稽核 Hook 延遲、違規、零觸發規則、嚴重性、資訊清單偏移、技能觸發、工作階段趨勢或回顧。
type: skill
sidebar:
  label: /hook-audit
---
![「/hook-audit」技能示意圖](/diagrams/skills/hook-audit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/hook-audit.excalidraw)


稽核 `~/.claude/hook-metrics/`。Codex 回合記錄會計入流程，但空白的 Hook 對應表不代表 Hook 沒有觸發。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md) 定義了指標與門檻。

模式：預設或 `--hooks` 顯示活動；`--retro` 加入流程；`--all` 加入延遲、技能觸發及偏移。

## 流程

1. 盤點 Hook 與日期範圍；區分評估與實際執行，並依測試工具版本及模型將證據分組。應拆分或排除列於 `model-switches.jsonl` 的工作階段，而非將使用多個模型的工作階段歸入單一模型。
2. 彙總阻擋、警告、提示、拒絕、工作階段及趨勢。
3. 依要求計算 P50/P95 與總經過時間。
4. 將指令碼與觀測到的鍵進行比較；標示真正的零觸發候選項目。
5. 比較規則與強制執行情況；區分未經測試的 Hook 與建議性規則。
6. 回顧：PR 延遲、CI 首次通過率、審查輪次、意見回饋延遲及工作樹數量。
7. 完整：檢查 `skill-fires.jsonl` 與 `model-switches.jsonl`；執行 `bash scripts/generate-hook-configs.sh --check`。
8. 模型切換政策：使用 `/quantify-impact`；以任務成功率或返工量為主要指標，以快取寫入成本為護欄指標。
9. 建議最多五項行動：`Prune` 無用途的零觸發規則；`Soften` 過於頻繁的阻擋；`Harden` 具風險的警告；`Add` 缺少的確定性規則。

刪除前，請在具代表性且已限定版本的試驗中，透過 `HOOK_SHADOW_RULES` 以影子模式執行；比較任務結果與違規情況。絕不可將嚴格的安全或權限規則設為影子模式。

## 完成

回報指標、數值、樣本數、7 天趨勢及後續行動。若可比較的實際工作階段少於五個，請將結果標記為初步結果。每項刪減或嚴重性變更都必須引用來源檔案及確切的 `harness_version` + `model` 群組。
