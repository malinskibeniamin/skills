---
title: /commit-push-pr
description: "提交、推送並開啟可供審查的 PR，或執行明確授權的合併。適用於交付要求；--no-pr 會在推送後停止。"
type: skill
sidebar:
  label: /commit-push-pr
---
![／commit-push-pr 技能圖解](/diagrams/skills/commit-push-pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/commit-push-pr.excalidraw)


請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)，以瞭解審查關卡、提交、標籤、內文及證明。

明確的合併要求使用 [references/merge.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)，而不是下方的 PR 建立流程。僅要求稽核、提交、推送、PR、`/go` 或交付並不授權合併。

## 前置檢查

1. 檢查 `git status -sb`、`git diff HEAD`、目前分支、近期記錄，以及此分支上的任何 PR。
2. 確認終點：僅提交、推送（`--no-pr`）或 PR。僅提交會略過遠端與 `gh` 前置檢查。
3. 推送／PR 需要遠端；PR 還需要已完成驗證的 `gh` 及預設分支。
4. 對 PR 執行 `gh stack view --json`；檢查基底／堆疊。一般 PR 僅涵蓋一個層級，絕不執行 `gh stack submit`。
5. 直接執行適用的審查面向；不要僅因未叫用某個具名技能而阻擋流程。
6. 可執行的 PR 工作需要目前有效的 `/dogfood` PASS；BLOCKED 需要使用者豁免。
7. 依用途暫存；僅限要求的路徑。如果歸屬不明，請先詢問。

## 提交

1. 留在功能分支上；若位於預設分支，請建立 `type/description`。
2. 對每個內聚的群組，先執行 `git add <explicit paths>`，再使用 `type(scope): terse description`：小寫、5 至 72 個字元，結尾不加句號。
3. 明確的僅提交意圖會在檢查工作目錄乾淨並提供摘要後於此停止。
4. 推送／PR：顯示 `origin/<branch>..HEAD`，然後設定追蹤並推送。
5. 改寫目前由使用者擁有的功能分支後，如有需要，可直接使用 `--force-with-lease`，無須再次詢問許可。絕不可使用一般的強制推送；改寫預設、共用、他人擁有或正由他人並行使用的分支，需要明確許可。

## 提取要求

`--no-pr` 絕不會建立 PR。推送後，請更新現有 PR 的證明／內文；否則，在推送並檢查工作目錄乾淨後結束。推送前先準備好本機視覺證明。

建立 PR 即授權驗證、提交、推送，以及在目前由使用者擁有的分支上執行受 lease 保護的 rebase；絕不授權合併或不相關的修正。

1. 使用 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 確認基底。重複使用現有的分支 PR，或以該基底建立 PR，並加入受指派者、標籤及參考範本。發布整個堆疊時使用 `/stacked-prs`。
2. 每個 PR 都要執行 `/quantify-impact`；納入精簡的價值說明或已證實的指標，不要為了展示而跑基準測試。
3. 每項可見變更，無論多小，都需要參考文件中的清單、嵌入的變更前／後畫面、已審查的快照，以及通過的視覺測試。若缺少證明，除非使用者明確豁免，否則會阻擋發布。
4. 附上目前的 dogfood 執行證明。重新閱讀內文、確認審查者可存取圖片，並輸出網址。更新／重新開啟也適用相同關卡；編輯會使受影響的證明失效。

除非使用者明確要求，否則不要執行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成作業

1. 取得一次 CI 狀態快照：`gh pr checks <number>`；若沒有 CI，請加以註明。
2. 回報現有的失敗。若要在此快照之後進行修正與監控，需要使用 `/go`、ship、明確要求持續監看，或提出後續要求。
3. 回報 `git status`、剩餘差異、分支、提交、PR、CI 及下一步動作。
4. 最後依照儲存庫標記慣例，以一行狀態結尾：`done`、`awaiting decision` 或 `blocked`。

絕不要暫存不相關的工作、推送未經確認的混雜範圍，或隱瞞失敗。如果 `gh pr create` 失敗，請顯示錯誤及復原命令。
