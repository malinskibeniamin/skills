---
title: /hook-audit
description: 分析 Hook 的有效性與工作階段遙測資料。適用於稽核 Hook 延遲、違規、零觸發規則、嚴重性、資訊清單偏移、技能觸發、工作階段趨勢或回顧。
type: skill
sidebar:
  label: /hook-audit
---
![「/hook-audit」技能示意圖](/diagrams/skills/hook-audit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/hook-audit.excalidraw)

稽核 `~/.claude/hook-metrics/` 中的工作階段檔案。Codex 回合記錄會計入工作階段
流程，但其中空白的 Hook 對應表不代表 Hook 沒有觸發。請閱讀
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/hook-audit/REFERENCE.md)，以瞭解指標定義與門檻。

模式：

- 預設或 `--hooks`：Hook 活動、未觸發狀況、嚴重性、強制執行。
- `--retro`：加入工作階段流程指標。
- `--all`：納入延遲、技能觸發及資訊清單偏移。

## 流程

1. 盤點已安裝的 Hook 與指標日期範圍。區分實際執行與評估，並先依測試工具版本及
   模型將證據分組，再進行比較。
2. 依 Hook 彙總：阻擋、警告、提示、拒絕、工作階段、趨勢。
3. 依要求計算 P50/P95 延遲與總經過時間。
4. 將已安裝的指令碼與觀測到的鍵進行比較；標示真正的零觸發候選項目。
5. 比較代理程式規則與強制執行情況；區分未經測試的 Hook 與建議性規則。
6. 在回顧模式中，衡量 PR 延遲、CI 首次通過率、審查輪次、人員意見回饋
   延遲及工作樹數量。
7. 在完整模式中，檢查 `skill-fires.jsonl` 並執行：

```bash
bash scripts/generate-hook-configs.sh --check
```

8. 建議最多五項行動：
   - `Prune`：從未觸發，且沒有證據支持其用途。
   - `Soften`：阻擋過於頻繁。
   - `Harden`：頻繁出現的警告證實存在正確性風險。
   - `Add`：某項具確定性且高價值的規則缺乏強制執行。

針對刪除候選項目，請在具代表性且已限定版本的試驗中，透過 `HOOK_SHADOW_RULES`
以影子模式執行該規則。在移除強制執行前，比較任務結果與違規情況。絕不可將嚴格的安全或權限規則設為影子模式。

## 完成

回報每項指標的數值、樣本數、7 天趨勢及後續行動。若可比較的實際工作階段少於五個，
請將結果標記為初步結果。每項刪減或嚴重性變更都必須引用來源檔案及確切的
`harness_version` + `model` 群組。
