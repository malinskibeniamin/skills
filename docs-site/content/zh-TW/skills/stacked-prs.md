---
title: /stacked-prs
description: 使用 gh stack 建立及管理相依的 GitHub 提取要求。適用於堆疊式 PR、相依分支鏈、漸進式審查層，或將大型變更拆分成依序排列的 PR。
type: skill
sidebar:
  label: /stacked-prs
---
![「/stacked-prs」技能圖解](/diagrams/skills/stacked-prs.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/stacked-prs.excalidraw)


使用 `gh stack`；[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stacked-prs/REFERENCE.md) 涵蓋指令、外部連結模式及復原方式。

## 契約

- 每一層都能以其父分支為基準，獨立進行審查。
- 一個 Conductor 工作區負責一個堆疊；不相關的工作使用另一個堆疊。
- 測試每一層、審查 `<parent>...HEAD`，並回報 `gh stack view --json`。
- 遵循要求的規劃、本機、推送、草稿、開啟或合併終點。

## 確立模式

檢查 `gh`、驗證狀態、儲存庫支援、目前分支、遠端、工作目錄是否乾淨，以及 `git worktree list --porcelain`。如果缺少擴充功能，請提供 `gh extension install github/gh-stack`；未經許可不得安裝。若有多個遠端，請傳入 `--remote origin`。

預設使用原生模式：由一個工作區負責整個堆疊並切換分支。在執行結構性指令前，請執行：

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

結束碼 2 會回報 `branch<TAB>path`；不得奪取分支、移除工作樹，或進行連鎖變更。僅針對刻意採用每層各自使用工作樹的設定使用外部連結模式：
`gh stack link --base <trunk> --remote origin <bottom> ... <top>`。在進行連鎖變更前，請先協調這些工作樹。

## 規劃與開發

顯示一份由下至上的表格，包含目標、分支、父分支、範圍及驗證方式。相依項目應位於其使用者所在層或更低層。僅確認由代理程式提出的邊界。

結構性指令要求工作目錄保持乾淨。使用 `gh stack init --base <trunk> <bottom>` 開始。依照 RED -> GREEN -> REFACTOR 進行實作、驗證並提交。使用 `gh stack add <next>` 新增一個內聚的關注事項。請使用明確的分支名稱並逐一加入檔案，不要使用 `git add -A`。

使用 `gh stack checkout <branch>` 及 `gh stack view --json`；避免使用不帶引數的指令及 TUI 指令。

## 審查與發布

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

發布前，請驗證並實際試用每一層。提交整個堆疊時預設會建立草稿：`gh stack submit --auto --remote origin`；只有在使用者要求時才加入 `--open`。要求單一 PR 絕不代表發布其他層。

針對每一層套用 [PR 證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)：`/quantify-impact`、內嵌的變更前後對照，以及針對可見變更通過的視覺測試。與其父分支比較；提交前準備內文，之後再進行驗證。連鎖變更會使證據失效。

## 意見回饋、同步與合併

在意見所屬的分支修正回饋並加以驗證。連鎖變更會改寫上層分支。對於目前工作區中由使用者擁有的堆疊，可直接執行 rebase 並使用 force-with-lease，無須再次詢問許可；請回報此次操作。只有在歸屬不明，或將變更預設、共用、他人擁有或正由他人並行使用的分支時才詢問。依序使用 `gh stack rebase --upstack --remote origin` 與 `gh stack push --remote origin`；`gh stack sync --prune --remote origin` 適用相同的界線。

使用 `gh stack rebase --continue` 繼續處理衝突；只有在使用者要求時才中止。外部連結模式必須先協調工作樹。

絕不可將合併作為發布的附帶效果。明確的合併意圖僅涵蓋指定的連續範圍。重新檢查核准、檢查項目、歷程、留言及待辦事項；使用 `gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`，絕不可使用 `gh pr merge`。

最後回報主幹、依序排列的各層、目前層、PR 狀態／URL、驗證結果、衝突、已執行的改寫，以及下一個由下至上的動作。
