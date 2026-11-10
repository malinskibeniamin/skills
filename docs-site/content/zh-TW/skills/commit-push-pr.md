---
description: 提交、推送並開啟可供審查的 PR，或執行明確授權的合併。適用於交付要求；--no-pr 會在推送後停止。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - commit push pr
sidebar:
  label: /commit-push-pr
title: /commit-push-pr
type: skill
---
![／commit-push-pr 技能圖解](/diagrams/skills/commit-push-pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/commit-push-pr.excalidraw)

閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution)。

使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)及[相依指引載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

僅在明確要求時合併：[合併規範](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)。

## 前置檢查 [#preflight]

1. 檢查狀態、差異、分支、記錄及 PR。推送或建立 PR 時，對落後基底分支且由目前使用者擁有的 PR 執行[自動變基](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#automatic-rebase)。
2. 確認終點：僅提交、推送（`--no-pr`）或 PR。僅提交會略過遠端與 `gh` 前置檢查。
3. 推送／PR：[自動設定審查保障](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)；遵守較窄的終點範圍。
4. 對 PR 執行 `gh stack view --json`。只負責一個層級；不得隱含執行 `gh stack submit`。
5. 使用負責該領域的技能進行審查；已授權的評審團審查應保留實際涵蓋範圍，不要僅因是否具名呼叫技能而阻擋工作。
6. 對可執行的 PR 工作，載入 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；要求目前有效的 PASS。BLOCKED 需要使用者豁免。
7. 依用途暫存；歸屬不明時先詢問。

## 提交 [#commit]

若使用 Changesets，完成檢查後載入 [changesets](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/changesets/SKILL.md)。

1. 留在功能分支上；若位於預設分支，請建立 `type/description`。
2. 對每個內聚的群組，先執行 `git add <explicit paths>`，再使用 `type(scope): description`：小寫、5 至 72 個字元，結尾不加句號。
3. 明確要求僅提交時，檢查工作目錄乾淨後在此停止。
4. 推送／PR、任何 CI 修正或變基：顯示 `origin/<branch>..HEAD`，然後設定追蹤並推送。
5. 改寫由使用者擁有的功能分支時，使用 `--force-with-lease`，無須再次詢問許可。絕不可使用一般的強制推送；改寫預設、共用、他人擁有或正由他人並行使用的分支，需要明確許可。

## 提取要求 [#pull-request]

`--no-pr` 絕不會建立 PR。推送後執行[現有 PR 維護](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md#existing-pr)，再檢查工作目錄。準備證據。

1. 基底：`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`。後續工作沿用目前的 PR 與[中繼資料](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/metadata.md)，包括草稿狀態。建立草稿 PR 無須核准；堆疊使用 `/stacked-prs`。
2. 每個 PR 都應分別載入 [PR](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/file-pr/SKILL.md)、[影響評估](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)與[內文](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md)；保留草稿狀態並說明價值。
3. 選擇[視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)。對於後端、API、Protobuf、契約或資料流變更，如果沒有能解釋受影響行為的截圖或影片，必須提供以原始碼為依據的圖表；優先使用 Excalidraw，並以內嵌 Mermaid 作為備援方案。重新讀取已發布的內文；生命週期 Stop 閘門會檢查證據是否存在，或是否明確說明適用範圍內的例外。
4. 公開儲存庫（`gh repo view --json visibility`）：推送前，請從提交、標題、內文及證據中移除內部組織、儲存庫、產品、人員名稱及私人連結。
5. 在內文簡述關鍵檢查與重要限制，不另建證據檔案。包含適用的 dogfood 結果；重新讀取內文並確認所附媒體的存取權限。編輯僅使受影響的證據失效。

持續維護由[維護負責流程](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md#automatic-pr-maintenance)統一負責；監看前先選擇原生接續機制，不要重複啟動派送器。

除非使用者明確要求，否則不要執行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成作業 [#completion]

1. 讀取 CI：`gh pr checks <number>`；未設定、等待中或已略過的 CI，都不算通過。
2. 自動修復適用的回饋、CI 問題及衝突；驗證並推送；透過單一、已授權的接續機制持續處理。
3. 回報 HEAD、PR、檢查結果、審查缺口，以及接續方式或阻礙；遵守較窄的停止條件。
4. 遵循 CLAUDE.md：意圖／影響／狀態，並在最後的狀態行附上完整 PR URL，包括更新時。

保留不相關的工作；明確回報失敗與復原方式。
