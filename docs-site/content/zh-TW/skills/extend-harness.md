---
title: /extend-harness
description: 擴充並偵錯 frontend-skills 的 hook 測試框架、規則、嚴重性層級與分析功能。
type: skill
sidebar:
  label: /extend-harness
---
![/extend-harness 技能示意圖](/diagrams/skills/extend-harness.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/extend-harness.excalidraw)

請編輯來源 manifest 與函式庫，絕不要編輯產生的設定。請閱讀
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/extend-harness/REFERENCE.md)，以了解嚴重性層級、manifest 選項、解析器契約與
偵錯方式。

## 新增規則

1. 先確認 Biome 或 Ultracite 是否能表達該規則。只有跨元素、跨檔案、工作流程或代理程式行為的規則才使用 hook。
2. 從相鄰的 `.claude/hooks/checks/*.lib.sh` 開始。公開一個 `run_*` 函式，
   並新增對應的精簡 `.claude/hooks/*.sh` 包裝指令碼。
3. 在 `skill-manifest.json` 中註冊包裝指令碼，通常放在
   `PostToolUse.Edit|Write` 下。
4. 在 `evals/` 下新增聚焦的 fixture；記錄失敗後再通過的證據。
5. 重新產生並測試：

```bash
bash scripts/generate-hook-configs.sh --apply
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' |
  bash .claude/hooks/my-check.sh
```

樣式規則使用 `hook_warn`，正確性規則使用 `hook_block`，安全性關鍵規則使用 `hook_block_strict`，
觀察用途則使用 `hook_info`。若只有一個垂直領域需要該規則，請優先使用技能範圍的 hook。

## 選擇實作方式

- 經權限篩選或非同步的項目使用 manifest 物件；請保留每個指令碼的 stdin
  防護，因為 Codex 會捨棄僅適用於 Claude 的篩選器。
- 可用機械方式證明的結構應放在 Biome 或 AST 規則中。模稜兩可的
  結構判斷應留待審查；避免使用脆弱的多行 grep。
- 讓工具鏈禁用規則與 `hooks/frontend-skills.rules` 保持同步。

## 稽核或偵錯

- 執行 `/hook-audit --all`，檢查延遲、觸發情況與零觸發候選項目。
- 若 hook 未觸發，請以 `HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude` 啟動。
- 使用 `claude --safe-mode` 隔離自訂設定。
- 將 `/doctor` 的延遲發現視為 P95 預算超標。

## 完成條件

- `skill-manifest.json` 管理該規則與比對器。
- 指令碼具有可執行權限、引入 `_hook-lib.sh`、解析 stdin、篩選路徑，並
  記錄其停用機制。
- 聚焦的 fixture 證明 RED -> GREEN。
- `bash scripts/generate-hook-configs.sh --check` 通過。
- `bash evals/run.sh` 通過。
