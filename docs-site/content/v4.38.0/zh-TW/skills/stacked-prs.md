---
title: /stacked-prs
description: 使用 gh stack 建立及管理相依的 GitHub 提取要求。適用於堆疊式 PR、相依分支鏈、漸進式審查層，或將大型變更拆分成依序排列的 PR。
type: skill
sidebar:
  label: /stacked-prs
---
![「/stacked-prs」技能圖解](/diagrams/skills/stacked-prs.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/stacked-prs.excalidraw)

使用 GitHub 的 `gh stack` CLI，同時維持操作框架的審查、工作樹與交付
契約。請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/stacked-prs/REFERENCE.md)，以了解隨版本變動的指令對照表、
外部連結模式、復原方式及狀態收據。

## 契約

- **目標：** 每一層都能以其下方分支為基準，獨立進行審查。
- **防護措施：** 一個 Conductor 工作區負責一個堆疊；不相關的工作使用另一個堆疊；
  全域安裝、共用分支改寫、發布及合併皆須遵循使用者意圖。
- **驗證：** 測試每一層、審查 `<parent>...HEAD`，接著回報
  `gh stack view --json`。
- **停止點：** 遵循要求的規劃、本機、推送、草稿、開啟或合併終點。

## 1. 確立模式

檢查 `gh`、驗證狀態、儲存庫支援、目前分支、遠端、工作目錄是否乾淨，以及
`git worktree list --porcelain`。如果缺少擴充功能，請提供
`gh extension install github/gh-stack`；未經許可不得安裝。此操作框架會
推送至 `origin`；若有多個遠端，請在每個支援的指令中傳入 `--remote origin`。

預設使用**原生模式**：由一個工作區負責整個堆疊並切換分支。在執行
`add`、`checkout`、`rebase`、`sync`、`modify` 或 `push` 前，請執行：

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

結束碼 2 會以 `branch<TAB>path` 列出由其他工作樹持有的堆疊分支。請回報這些項目；不得
移除工作樹、奪取其分支，或在本機進行連鎖變更。

僅針對刻意採用每層各自使用工作樹的工作流程使用**外部連結模式**。使用
`gh stack link --base <trunk> --remote origin <bottom> ... <top>` 發布。在本機進行任何連鎖變更前，請先
協調或釋放這些工作樹。

## 2. 規劃與開發

編寫程式碼前，先顯示一份由下至上的表格：每層的目標、分支、父分支、允許的範圍及
驗證方式。相依項目應位於同一層或更低層。確認由代理程式提出的邊界；使用者明確指定的邊界
無須再次核准。

結構性指令要求工作目錄保持乾淨。使用
`gh stack init --base <trunk> <bottom-branch>` 採用或建立最底層分支。依照 RED -> GREEN -> REFACTOR
進行實作、驗證，並審慎提交。使用
`gh stack add <next-branch>` 新增下一個內聚的關注事項。請使用明確的分支名稱及標準的 `git add`/`git commit`；
避免使用會模糊層級歸屬的 `-A` 捷徑。

使用 `gh stack checkout <branch>` 切換，並使用 `gh stack view --json` 檢視。
不帶引數的指令及 TUI 輸出不適合代理程式使用。

## 3. 審查與發布

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

針對目前層執行適用的驗證及實際試用。發布前檢查每個分支；若提交內容包含非預期或
尚未完成的工作，請停止。明確提交整個堆疊時，預設會建立草稿：`gh stack submit --auto --remote origin`。只有在
使用者要求 PR 已準備好供審查時，才加入 `--open`。要求單一 PR 絕不代表授權
發布其他尚未提交的層。

## 4. 意見回饋、同步與合併

在意見所屬的分支修正回饋並加以驗證。連鎖變更會改寫上層分支。對於目前工作區中由使用者擁有並維護的堆疊，
可直接執行 rebase，並使用 `--force-with-lease` 推送整個連鎖變更，無須另行詢問許可；在回執中報告此次改寫。
只有在歸屬不明，或將改寫預設、共用、他人擁有或正由他人並行使用的分支時才詢問。接著依序使用
`gh stack rebase --upstack --remote origin` 與 `gh stack push --remote origin`。
`gh stack sync --prune --remote origin` 適用相同的歸屬界線。

使用 `gh stack rebase --continue` 繼續已解決衝突的操作。只有當使用者要求
放棄操作時才中止。外部連結模式必須先協調其工作樹。

絕不可將合併作為發布的附帶效果。明確的合併意圖僅授權指定的
連續範圍。重新檢查核准、檢查項目、線性歷程、留言及待辦事項；接著使用
`gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`，絕不可使用
`gh pr merge`。

最後回報主幹、依序排列的各層、目前層、PR URL／狀態、各層驗證結果、
工作樹衝突、已執行的改寫，以及下一個由下至上的動作。
