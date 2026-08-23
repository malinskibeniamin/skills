---
title: /commit-push-pr
description: 提交、推送並開啟可供審查的 PR。適用於僅提交、提交並推送、建立 PR，或更新現有分支；--no-pr 會在推送後停止。
type: skill
sidebar:
  label: /commit-push-pr
---
![／commit-push-pr 技能圖解](/diagrams/skills/commit-push-pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/commit-push-pr.excalidraw)

請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)，以瞭解審查的先決條件、提交類型、標籤、內文
範本、螢幕截圖及相依套件升級章節。

## 前置檢查

1. 執行 `git status -sb`、`git diff HEAD`、`git branch --show-current`、
   `git log --oneline -5`，並檢查此分支上任何已開啟的 PR。
2. 確認要求的終點：僅提交、推送（`--no-pr`）或 PR。僅提交會略過遠端與 `gh` 前置檢查。
3. 僅推送／PR：確認有可存取的遠端。僅 PR：使用
   `gh repo view` 確認預設分支，接著確認已安裝 `gh` 且完成驗證。
4. 僅 PR：使用 `gh stack view --json` 偵測本機堆疊成員資格；如果已有 PR，也要
   檢查其 `baseRefName` 與 REST `stack` 物件。一般 PR 終點僅涵蓋目前
   層級。它絕不授權執行 `gh stack submit`，因為該命令可能會發布其他分支。
5. 僅 PR：直接執行適用的審查面向；不要僅因未叫用某個具名審查
   技能而阻擋流程。
6. 僅 PR：可執行行為需要目前有效的 `/dogfood` PASS。BLOCKED 需要使用者豁免。
7. 依用途將變更的檔案分組。僅暫存要求的路徑；只有在無法安全判定
   歸屬範圍時，才詢問範圍。

## 提交

1. 留在目前的功能分支上。如果位於預設分支，請建立 `type/description`。
2. 對每個內聚的群組：
   - `git add <explicit paths>`
   - 使用 `type(scope): terse description` 提交
   - 維持小寫、5 至 72 個字元，結尾不加句號
3. 明確的僅提交意圖會在檢查工作目錄乾淨並提供提交摘要後於此停止。
4. 僅推送／PR：顯示 `origin/<branch>..HEAD`，然後設定追蹤並推送。
5. 對目前由使用者擁有的功能分支執行 rebase 或其他歷史改寫後，如有需要，可直接使用
   `--force-with-lease`，無須再次詢問許可。絕不可使用一般的 `--force`；改寫預設、共用、
   他人擁有或正由他人並行使用的分支，需要明確許可。

## 提取要求

`--no-pr` 或明確的提交並推送要求，會在檢查工作目錄乾淨並提供已推送的
提交摘要後結束。

否則：

1. 將製作／開啟／建立 PR 視為對其先決步驟的授權：驗證、提交並
   推送目前分支。這也涵蓋目前由使用者擁有的功能分支在 rebase 後所需的
   `--force-with-lease`，但不包含合併、一般的 `--force`、改寫共用分支或不相關的修正。
2. 使用
   `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 確認明確的基底。重複使用現有的分支 PR，或
   以該基底建立 PR，並加入受指派者、標籤及參考內文範本。
   如明確要求發布整個堆疊，請改為遵循 `/stacked-prs`。
3. 對面向客戶的變更，每個檢視畫面都要包含一列螢幕截圖／介面審查。
4. 對可執行的變更，附上目前的 dogfood 執行證明。
5. 輸出 PR 網址。

除非使用者明確要求額外的產出物或歷史記錄工作，否則不要執行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## CI 與完成作業

1. 使用 `gh pr checks <number>` 取得一次 CI 狀態快照。若沒有 CI，請加以註明。
2. 如果檢查已失敗，請回報；若要在此快照之後進行修正與監控，
   需要使用 `/go`、ship、明確要求持續監看，或提出後續要求。
3. 執行 `git status` 與 `git diff`；回報尚未提交的工作。
4. 摘要說明分支、提交、PR、CI 及剩餘動作。
5. 最後以一行狀態結尾：`🟢 done — PR opened; CI <state>`、`🟡 awaiting decision — <decision>` 或
   `🔴 blocked — <external blocker and needed input>`。

絕不要暫存不相關的變更、未經確認便推送混雜的範圍，或隱瞞失敗的
命令。如果 `gh pr create` 失敗，請顯示錯誤及復原命令。
