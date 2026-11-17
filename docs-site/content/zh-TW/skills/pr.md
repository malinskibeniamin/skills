---
description: 在撰寫 PR 說明，或持續更新目前工作階段中已開啟 PR 的範圍、商業價值與證據時使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr
sidebar:
  label: /pr
title: /pr
type: skill
---
![/pr 技能的示意圖](/diagrams/skills/pr.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/pr.excalidraw)

完整的 [Matt Pocock 原始檔](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/SKILL.md)與[原始署名](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md)已隨整套技能固定版本。此本機調整保留下列 PR 描述、證據及目前工作階段 PR 所有權規則。


閱讀[保護讀者注意力的契約](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。

## 現有 PR [#existing-pr]

在工作階段開始或恢復時、範圍、實作或證據發生實質變更後，以及交接前：

1. 尋找與此對話、工作階段或聊天明確關聯的已開啟 PR；否則透過 `gh pr view` 檢查目前分支。確認開啟狀態、儲存庫、來源分支、基底分支及歸屬；不可選擇無關的近期 PR。沒有已開啟的 PR 就無須維護，也不代表可以建立 PR。
2. 將已發布的說明與**完整 PR 差異**、原始目標及目前的驗證結果比對，而非只看最近一輪對話或提交。對堆疊 PR，逐一對照父分支評估受影響的層級。 依照[視覺標註](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)檢查擷取畫面、標記及圖例是否過時。
3. 個別載入 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)。重新評估商業價值及產品或程式碼庫影響；重用仍有效的證據、重跑已失效的比較，並移除缺乏依據的主張。價值未知時，明確寫出 `not established`。
4. 對已獲授權的修改或交付，一併更新受影響的擷取畫面、標記及圖例；保留人工開頭（意圖過時時提醒作者編輯），更新代理草擬的開頭，原地替換過時的代理項目，精簡說明受益對象、價值、證據及實質風險。更新[人工審查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)，包括審查人員指派、復原及偵測缺口。保留人工意圖與必要證據；連結詳細資料、略過準確說明、省略工作階段紀錄。
5. 編輯後重新讀取託管平台上的內文，確認其描述的是已發布的來源分支狀態。唯讀要求僅回報偏差，不進行編輯。明確要求僅本機修改或禁止推送時，延後發布；不可將尚未發布的工作描述為已交付。

## 內文範本 [#body-template]

使用精簡易懂、描述成果且符合儲存庫慣例的標題。標題與開頭一句屬於人類作者：保留其提供的措辭。代擬時，明確標示標題及開頭為等待人工編輯的代理草稿；不得聲稱由人類撰寫或已獲認可。已獲授權的草稿 PR 可繼續發布。維護時保留人工文字；意圖改變時指出問題，不要悄悄改寫。

順序為：一句話說明變更及原因 -> UI 變更前後擷取畫面表格 -> 有幫助時附可點選原型 -> 一個預設摺疊的 `<details>` 中的代理說明。原型連結也可緊接表格之前。不適用的視覺或原型部分應省略，不要發布佔位內容。使用以下結構：

```markdown
<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) - <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
UI packaging: <已發布錄影 URL，或依 package-my-work 明確說明非 UI 原因/擁有者豁免>

- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

驗證失敗或受阻、實質風險、回復成本高或偵測缺口，應在詳細資料之前提供簡短的**可見警告**。摺疊例行紀錄，不要隱藏阻礙。在代理說明中評估[人工審查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)的全部五項標準，無須新增五個制式標題。保留必要的參考資料、驗收標準及儲存庫專屬欄位。

UI 變更依照[視覺證據契約](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)提供可比較的真實基底版本與候選版本擷取畫面。說明比較無法進行或不適用的原因；不得虛構變更前狀態或將佔位 URL 當作證據。非 UI 變更省略畫面表格，保留適用的圖表證據。原型補充而非取代畫面或測試。

### 可點選的審查原型 [#clickable-review-prototypes]

當互動、難以到達的應用程式狀態或替代方案適合動手審查時，連結至 [UI 原型](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md#shareable-review-prototype)。在輕量網站直接使用真實應用程式元件、字型、設計權杖及佈景主題提供者；透過明確標示的測試資料隔離 Electron、原生程式碼及後端邊界。審查者無須簽出分支或設定完整應用程式環境即可進入相關狀態。設計問題尚未確定時，提供具有實質差異的方案，以及可分享的變體與狀態 URL；已確定的小改動不需要變體或新原型。

僅使用目標儲存庫已有文件、獲核准且受 SSO 保護的 Quick Site 或同等私人預覽流程部署。查找該流程的指令與設定；[Shopify Quick](https://shopify.engineering/quick) 僅是靈感，並不提供基礎設施存取權或通用部署指令。託管或 SSO 無法使用時，保留可執行產物、說明缺口並使用擷取畫面；不得默默改為公開發布或新增託管、驗證基礎設施。確認審查者存取權、連結目標狀態及資源載入；聲稱受 SSO 保護前，確認登出後無法存取。明確標示模擬行為及未經驗證的存取權。將 URL 與產物綁定至審查版本；相關變更後更新或標示過時。遵循[原型保留政策](https://github.com/malinskibeniamin/skills/blob/main/prototype/SKILL.md#retention)。


## 描述與風險 [#description-and-risk]

撰寫或更新內文前，閱讀[補充描述指南](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#supporting-description)，了解證據、決策變更及風險。
PR 內文是供操作者使用的精簡摘要；額外摘要產物必須由使用者明確要求。
符合條件的非 UI 契約需要[後端圖表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)；UI 錄影仍須遵循 `package-my-work`。
說明回復路徑，並判斷變更是單向門還是雙向門。
列出受影響的使用者、呼叫端、契約及可信故障模式，包括共用消費端。
