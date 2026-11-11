---
title: /make-pr-easy-to-review
description: 整理雜亂的 PR 歷史記錄並加入審查指引，且不改變程式碼行為。
type: skill
sidebar:
  label: /make-pr-easy-to-review
---
![「/make-pr-easy-to-review」技能的示意圖](/diagrams/skills/make-pr-easy-to-review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/make-pr-easy-to-review.excalidraw)

整理 PR，讓審查者能快速了解其意圖、重要檔案與風險。預設目標是在不改變行為的前提下提升可審查性。

## 工作流程

1. 從使用者提供的 URL 或目前分支確認目標 PR。
2. 檢查提交、差異大小、變更路徑、產生的檔案，以及 PR 說明。
   若為堆疊式 PR，請與 `baseRefName` 比較、記錄其所在層級與相鄰 PR，並將
   歷史記錄操作限制在所屬分支內。
3. 找出可審查性問題：雜亂的提交、過時的說明、不相關的變更、混雜的機械性與邏輯變更、缺少測試，或不清楚審查者應從何處開始。
4. 在重寫歷史記錄或強制推送前提出計畫。重新排序、合併提交，或
   對堆疊進行連鎖變更，都需要明確取得整個堆疊的核准。
5. 套用安全的改善，接著確認工作樹或差異仍符合預期的程式碼內容。

## 歷史記錄整理

只有在使用者提出要求或同意計畫時，才能重寫歷史記錄。重寫前：

```bash
gh pr view <PR> --json title,headRefName,baseRefName,state,commits
git fetch origin <headRefName> <baseRefName>
ORIGINAL_TREE=$(git rev-parse origin/<headRefName>^{tree})
```

良好的提交分組通常會依照相依性順序排列：

1. 結構描述／儲存層，或產生的 API 定義。
2. 核心邏輯。
3. 串接與整合。
4. UI 或對外介面行為。
5. 測試。

重寫後，確認內容完全一致：

```bash
echo "Original tree: $ORIGINAL_TREE"
echo "Current tree:  $(git rev-parse HEAD^{tree})"
git diff origin/<headRefName> --stat
```

若工作樹發生非預期變更，請勿推送。

## 審查指引

如需視覺化脈絡（圖表、檔案對照圖、附註解的逐步說明），請執行 `/visual-recap`——不要在此重複製作。此技能只會改善 PR 文字本身：

- 若 `/quantify-impact` 產生了有意義的證據，請將其 `## Proven impact` 區塊（`Metric | Before | After | Delta`）放在最前面，接著附上確切的指令／環境。若衡量結果沒有用處，請保留一般的價值摘要；不要放入虛假的空白表格。若證據未達門檻，請明確寫出 `Value not proven`，不要隱瞞。
- 加入符合實際差異內容的 TL;DR。
- 將核心檔案與產生的檔案或機械性變更檔案分開。
- 明確指出高風險的行為變更、遷移順序、推出計畫，以及測試涵蓋範圍。
- 若議題追蹤系統、儀表板或設計文件有助於說明意圖，請加入其連結。

## 防護原則

- 絕不可將有意義的行為變更隱藏在「整理」之中。
- 除非使用者明確要求，否則不得略過掛鉤。
- 若 PR 規模過大，無法僅透過註記使其易於審查，應建議拆分，而不是粉飾問題。
