---
title: /codex-compat
description: 從 Claude 掛鉤資訊清單產生對等的 Codex hooks.json 與 AGENTS.md 介面。
type: skill
sidebar:
  label: /codex-compat
---
![／codex-compat 技能示意圖](/diagrams/skills/codex-compat.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/codex-compat.excalidraw)

Codex 支援 Claude 風格的生命週期掛鉤，包括 `SessionStart`、`SubagentStart`、`PreToolUse`、`PermissionRequest`、`PostToolUse`、`PreCompact`、`PostCompact`、`UserPromptSubmit`、`SubagentStop` 與 `Stop`（https://developers.openai.com/codex/hooks）。僅限 Claude 且沒有 Codex 對應項目的事件——`FileChanged`、`WorktreeCreate`、`SessionEnd`、`PostToolUseFailure`（併入 Codex 的 `PostToolUse`）——會使用 Stop 批次備援機制，或依設計予以捨棄。`PreToolUse`／`PostToolUse` 比對器支援 `Bash`、MCP 工具名稱、`apply_patch` 與 `Edit|Write` 別名。請盡可能直接對應 `Edit|Write` 掛鉤。執行 `/read-the-damn-docs` 以瞭解目前的掛鉤行為；當直接對應或備援對應難以判斷時，請使用 `/plan-arbiter`。

## 會建立的內容

- **`.codex/hooks.json`**——直接轉換支援的 Claude 掛鉤
- **`.codex/hooks/codex-batch-check.sh`**——僅供無法針對各工具事件執行的檢查作為備援
- **`AGENTS.md`** + **`CLAUDE.md`**——共用專案規則（Codex 讀取 AGENTS.md，Claude Code 讀取 CLAUDE.md）
- **相容性矩陣**——將掛鉤分類為 `direct`、`direct with shim`、`fallback only` 或 `unsupported`

## 步驟

1. 讀取 `.claude/settings.json`，並使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codex-compat/REFERENCE.md) 相容性矩陣分類每個掛鉤。
2. 產生 `.codex/hooks.json`：
   - `SessionStart`、`UserPromptSubmit`、`Stop` -> 直接對應
   - 搭配 `Bash`、`Edit|Write`、`apply_patch`、`mcp__.*` 的 `PreToolUse` / `PostToolUse` -> 直接對應
   - 適用於 `Bash` / MCP / `apply_patch` 的 `PermissionRequest` -> 在指令碼能理解 Codex 承載資料時直接對應
   - 不支援的 Claude 事件或處理常式類型 -> 省略、加以記錄，或僅在語意仍然安全時導向備援
3. 僅在需要備援掛鉤時，將 `scripts/codex-batch-check.sh` -> `.codex/hooks/`。執行 `chmod +x`。
4. 將 `hooks/frontend-skills.rules` -> `.codex/rules/`（execpolicy 基準；不啟用掛鉤功能旗標也能運作）。
5. 使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codex-compat/REFERENCE.md) 範本產生 `AGENTS.md` + `CLAUDE.md`。
6. 啟用並信任：在 `config.toml` 中設定 `[features] hooks = true`，接著在 Codex TUI 中執行 `/hooks` 並信任這些定義（每次變更掛鉤後都要重新信任；CI 使用 `--dangerously-bypass-hook-trust` 或受管理的掛鉤目錄）。也可選擇設定 `notify = ["bash", "<repo>/.claude/hooks/codex-notify.sh"]`，以取得回合完成遙測資料。

## 驗證

- [ ] 當來源包含直接的 `Edit|Write` PostToolUse 掛鉤時，`.codex/hooks.json` 也包含這些掛鉤
- [ ] 除非確實有僅能使用備援的掛鉤需要批次檢查器，否則不應存在批次檢查器
- [ ] `.codex/rules/frontend-skills.rules` 存在，且與 `hooks/frontend-skills.rules` 完全相同
- [ ] 掛鉤功能旗標已開啟，且定義已受信任（`/hooks` 顯示其為作用中，而非待處理）
- [ ] 儲存庫根目錄中有 `AGENTS.md` + `CLAUDE.md`
- [ ] `.claude/settings.json` 未變更
