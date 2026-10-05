---
title: /commit-push-pr
description: 提交、推送並開啟可供審查的 PR，或執行明確授權的合併。適用於交付要求；--no-pr 會在推送後停止。
type: skill
sidebar:
  label: /commit-push-pr
---
![／commit-push-pr 技能圖解](/diagrams/skills/commit-push-pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/commit-push-pr.excalidraw)


使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)及[相依指引載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

僅在明確要求時合併：[合併規範](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)。

## 前置檢查 [#preflight]

1. 檢查狀態、差異、目前分支、近期記錄，以及此分支上的任何 PR；執行 rebase 前先做[變基前檢查](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#pre-rebase-check)。
2. 確認終點：僅提交、推送（`--no-pr`）或 PR。僅提交會略過遠端與 `gh` 前置檢查。
3. 推送／PR 需要遠端；PR 需要已完成驗證的 `gh` 及基底分支。
4. 對 PR 執行 `gh stack view --json`；檢查基底／堆疊。一般 PR 僅涵蓋一個層級，絕不執行 `gh stack submit`。
5. 直接執行審查；具名技能呼叫不是核准關卡。
6. 對可執行的 PR 工作，載入 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；要求目前有效的 PASS。BLOCKED 需要使用者豁免。
7. 依用途暫存要求的路徑；如果歸屬不明，請先詢問。

## 提交 [#commit]

1. 留在功能分支上；若位於預設分支，請建立 `type/description`。
2. 對每個內聚的群組，先執行 `git add <explicit paths>`，再使用 `type(scope): terse description`：小寫、5 至 72 個字元，結尾不加句號。
3. 明確要求僅提交時，檢查工作目錄乾淨後在此停止。
4. 推送／PR：顯示 `origin/<branch>..HEAD`，然後設定追蹤並推送。
5. 改寫目前由使用者擁有的分支時，使用 `--force-with-lease`，無須再次詢問許可。絕不可使用一般的強制推送；改寫預設、共用、他人擁有或正由他人並行使用的分支，需要明確許可。

## 提取要求 [#pull-request]

`--no-pr` 絕不會建立 PR。推送後，請更新現有 PR 的證明／內文；否則，在推送並檢查工作目錄乾淨後結束。推送前先準備好本機視覺證明。

1. 使用 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 確認基底。後續工作繼續加入目前的 PR；只有尚無 PR 時，才建立 PR，並加入受指派者、標籤及範本。建立草稿 PR 無須另行取得核准。發布整個堆疊時使用 `/stacked-prs`。
2. 每個 PR 都應分別載入 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) 與 [pr](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md)；納入價值說明或已證實的指標。
3. 每項可見變更都需要參考文件中的清單、變更前／後的螢幕擷取畫面與影片、已審查的快照，以及通過的視覺測試。若缺少證明，除非使用者明確豁免，否則會阻擋發布。
4. 公開儲存庫（`gh repo view --json visibility`）：推送前，請從提交、標題、內文及證明中移除內部組織、儲存庫、產品、人員名稱及私人連結。
5. 附上 dogfood 執行證明。重新閱讀內文、確認審查者可存取圖片，並輸出網址。更新／重新開啟也適用相同關卡；編輯會使受影響的證明失效。

除非使用者明確要求，否則不要執行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成作業 [#completion]

1. 取得一次 CI 狀態快照：`gh pr checks <number>`；若沒有 CI，請加以註明。
2. 回報失敗；若要進一步修正 CI，需要使用 `/go`、ship、明確要求持續監看，或提出後續要求。
3. 回報狀態、剩餘差異、分支、提交、PR、CI 及下一步動作。
4. 遵循 CLAUDE.md 的狀態與意圖／影響規範。只要 PR 已存在，無論是新建或更新，都要在最後的狀態行附上完整的 PR URL。

絕不要暫存不相關的工作、推送混雜範圍，或隱瞞失敗。如果 `gh pr create` 失敗，請顯示錯誤及復原命令。
