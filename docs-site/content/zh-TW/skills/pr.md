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

[Try the prototype](<reviewer-accessible-url>) — <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
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


## 各區段 [#sections]

開頭一句是必要的首讀摘要，不是開場白；遵循 [PR 注意力預算](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#match-the-artifact)。下方只保留補充細節。以下主題是作者指引，不是必要標題。依範本摺疊代理詳細資料；必要視覺媒體內嵌於開頭及必要警告之後。使用 `GLOSSARY.md` 中使用者的領域語言。

### 摘要 [#summary]

僅在有幫助時補充審查重點，不要重複開頭一句話。區分核心變更與產生或機械性檔案；指出有用的審查入口，不逐一羅列檔案。區分已觀察到的結果和預期。

將 PR 內文作為操作者的精簡摘要：行為與價值、關鍵證據、領域決策、剩餘風險與復原方式，以及下一步行動；透過連結提供詳細資料，以利恢復工作。獨立的 HTML 或視覺回顧產物需要明確要求；仍須審查完整差異並提供必要的視覺證據。

從 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中選擇最小視圖。

#### 決策變更 [#changed-decisions]

當實作相對於已記錄的計畫或成果契約出現實質偏離，影響範圍、契約、驗證方式或推出風險時，請說明這些變更。沿用既有筆記或意圖圖：
先前選擇 -> 新證據 -> 目前選擇 -> 對審查的影響。
讓 PR 說明本身完整清楚；省略空泛的變更歷程，絕不虛構先前計畫或共識。

工作階段摘錄僅為選用背景資訊。只使用相關、已獲授權、已遮蔽敏感資料且審查者可存取的摘錄；否則提供安全、完整的理由說明。
不要只為提供連結而擴大分享範圍或執行權限。工作階段長度或互動輪數無法證明正確性或用心程度；請依據目前差異與執行證據核實各項說法。

將視覺內容放在其支持的文字旁。只顯示關鍵呼叫、檔案、屬性、狀態與邊界。

省略無法增進理解的視圖。

### 證據 [#evidence]

提供證明變更有效的具體證據。優先簡述指令及結果；UI 變更依內文範本提供前後比較，其他變更僅在有幫助時附媒體。說明未執行的檢查與不確定性；測試通過不代表人工審查或共識。

只在差異難以定位時使用[視覺標註](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)。大範圍 UI 工作可在有助於理解時使用 [UI 變更圖](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps)；避免重複截圖與獨立回顧檔案。

對於後端、API、Protobuf、契約、架構、資料流或工作流程變更，如果截圖或影片無法解釋受影響的行為，必須在開頭一句之後內嵌加入[後端圖表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)，並更新過時的維護圖表。優先使用 Excalidraw；繪製或託管失敗時使用內嵌 Mermaid。保留測試證據：圖表用於解釋，不代表已證明正確性。[視覺證據契約](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)規定適用範圍內的例外，以及檢查已發布內文的完成閘門。

依 [commit-push-pr 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)選擇媒體。只有互動或動態效果需要，或使用者要求時才錄製真實流程；其他情況靜態圖片與指令結果已足夠。證據的價值在於回答的問題，而非媒體等級。測試結果應簡潔、真實，不要重新建構或虛構。

### 合併風險 [#merge-danger]

說明回復路徑，並將變更歸類為單向門或雙向門。雙向門容易退回；破壞性或難以逆轉的決策屬於單向門。

列明受影響的使用者、呼叫端、契約及可信的失敗模式，包括共用的使用端。
說明復原方案時，同時依照交接標準評估錯誤偵測；明確列出重要的故障可見性缺口，不要把測試通過或回復計畫當成錯誤偵測的替代品。
