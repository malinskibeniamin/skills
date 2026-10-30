---
description: 用於基於證據審查分支、PR、WIP 或釋出中由差異引入的缺陷。
related:
  - /skills/development-lifecycle
  - /skills/tdd
search:
  boost: 3
  keywords:
    - review
    - code review
    - pull request
    - pr
sidebar:
  label: /review
title: /review
type: skill
---
![「/review」技能示意圖](/diagrams/skills/review.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/review.excalidraw)

審查差異時，請閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#review-and-diagnosis)。

介面變更應遵循[介面相容規則](https://github.com/malinskibeniamin/skills/blob/main/shared/INTERFACES.md#interface-review)，並閱讀一般的[已移除訊號參考](https://github.com/malinskibeniamin/skills/blob/main/vendor/jakubkrehel/skills/interface-review/removed-signals.md)，檢查差異兩側失去的操作提示。載入 `visual-review` 取得繪製證據；不要自動呼叫獨立的使用者專用 `interface-review`，也不要建立第二份報告。

審查固定範圍。保持唯一負責人；委派需要明確授權。沒有明確意圖時不編輯、提交、推送或發布。要求的修復僅在指定範圍內進入[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)。

依[審查運作模型](https://github.com/malinskibeniamin/skills/blob/main/review/OPERATING-MODEL.md)選擇審查深度與收斂規則；風險改變審查力度，不改變權限。

## 審查約定 [#review-contract]

- **目標**：判斷差異是否實現預期結果且沒有可信缺陷。
- **約束**：僅限差異引入的問題；將標準問題與產品/規格缺口分開；
  產生的檔案是證據。
- **驗證**：追溯來源。親自透過真實入口試用每項可執行變更；
  測試不能替代體驗。
- **停止**：涵蓋每個表面；發現必須包含證據、影響、優先順序、修正和驗證方法。

僅在缺少固定點時提問。否則解析
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`，
固定頭部與合併基準的 SHA，再檢查這些版本的完整差異和日誌。
審查 WIP 時，納入已暫存、未暫存及相關未追蹤內容；說明排除項目。
執行變異測試或並行讀取前，使用[原始碼快照](https://github.com/malinskibeniamin/skills/blob/main/review/REFERENCE.md#source-snapshots-and-mutation-tests)。
給出結論前重新核對快照識別資訊；輸入變動會使相關證據失效。

## 證據迴圈 [#evidence-loop]

**檢查 -> 驗證 -> 分類 -> 綜合。**

### 檢查 [#inspect]

1. 閱讀請求/規格、規則、完整差異、呼叫點和行為。不要讓 PR 摘要凌駕於程式碼。納入適用的 `REVIEW.md`、`CODING_STANDARDS.md` 與 `CONTRIBUTING.md`（若存在）。
2. 對每個變化的假設，反向追蹤權威生產者、結構描述、
   儲存、消費者和公開表面。按領域概念、欄位和輸出
   值搜尋，不只搜尋變更符號。
3. 從[變更證據](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md)載入適用的負責技能；重用目前產物。
4. 用相關未變程式碼中的獨立產物、基線、
   近期歷史、執行階段證據和測試資料檢驗意外情況。比較測試資料與正式環境資料結構。
5. 為一種可信碰撞建構行為反例。對映權限和可見
   表面；跳過格式化工具負責的樣式和既有缺陷。
6. 詢問：即使測試通過，仍可能錯在哪裡？

### 驗證 [#verify]

- 對照原始碼、結構描述、第一手文件或可執行檢查重現。
- 當安全性取決於一項非本地事實時，使用 `/blast-radius`；攜帶證據，而非敘述。
- 使用具有代表性的真實規模資料，執行預期路徑和一個可信的失敗或恢復路徑。
  觀察主控台、網路、日誌和回應時間；若不安全或無法使用，說明阻礙。
- 檢查測試完整性：公開行為、RED、斷言、覆蓋範圍，以及沒有固定時長等待。
  除非文字是公開輸出，否則原始碼文字檢查不算覆蓋；刪除，或改以
  公開接合面取代。語法使用靜態分析。

僅在差異提供證據時新增面向專項審查：

| 面向 | 檢查 |
|---|---|
| 面向客戶的 UI/CLI/報告 | 呈現、狀態、文案、鍵盤/a11y、主控台、可視區域 |
| 安全/隱私/資料遺失 | 攻擊者/起始權限、信任邊界、憑證從來源到使用位置的流向、可達影響、恢復 |
| 文件/公開行為 | 可發現性、預設值、省略行為、遷移/發行指引；純內部變更不需發行說明 |
| API/結構描述/SQL/PostgreSQL | 相容性、遷移、產生的輸出、實際方言 |
| Go/並行/工作流程 | 所有權、取消、競態、重試、冪等 |
| 相依套件/外部 API | 第一手文件、版本、鎖定檔、安全通告 |

差異涉及 `.proto` 檔案（包含刪除與重新命名）、Buf 設定或 protobuf 程式碼產生/執行階段契約時，完整載入 [protobuf](https://github.com/malinskibeniamin/skills/blob/main/protobuf/SKILL.md)。即使結構描述本身未變，也要追蹤受影響的產生程式碼和使用端。能力改進建議應保持非阻擋，並與缺陷分開。在[門檻審查](https://github.com/malinskibeniamin/skills/blob/main/review/GATES.md)中，語意排除不能略過符合路徑的 protobuf 門檻；一般內嵌審查使用同一技能，不必啟用門檻或委派。

依[相依技能載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)載入技能。
分別為「product」和「lie-detector」呼叫 Skill 工具；在同一流程中套用其角色。
經授權的審查面向應一起在前景執行；彙整每份報告。

### 分類 [#classify]

發現必須由差異引入、有實際影響、可重現或有具體路徑，定位到最精確的變更行，
並配最小安全修復。

- **P0**：暴露、資料遺失、中斷或核心流程不可用。
- **P1**：使用者迴歸、契約破壞、錯誤成功或嚴重 a11y 缺陷。
- **P2**：影響較低但有用且範圍明確的修正。
- 行內評論中省略未來可選工作和潤飾。

沒有測量或結構邊界，不報告效能。沒有可信風險，不報告邊緣情況。
證據也可以支持有理拒絕。

### 綜合 [#synthesize]

閱讀[溝通規則](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)；保留輸出格式。
先報告發現數量，包括明確的零。依根因去重；說明缺陷類別與受影響的實例。完成首次完整審查後，重新審查修復差異與先前發現；假設改變時擴大範圍。以證據標明每條發現的狀態。省略讚美與無關的缺陷搜尋；將價值與缺陷分開。
將產品結論行與缺陷分開報告。

## 深度模式 [#deep-mode]

使用 `--deep` 時沿用同一迴圈並建立完整適用性清單。閱讀
[DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/main/review/DEEP-AUDIT.md)；覆蓋全部表面，不自動增加代理程式。

## 輸出 [#output]

閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/review/REFERENCE.md) 以了解術語和結構。報告
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`。
附加 `entrypoint, data, actions, observations, timing, limits`、固定點、模式、計數、
`product:` 和 `lie-detector:` 結論行、結論和剩餘限制。無發現時只傳回這些結論行、結論和剩餘限制。
若 protobuf 審查範圍包含具體能力改進機會，附加獨立的非阻擋建議區段；沒有內容就省略。結構化門檻審查保留發現格式，使用其中的建議機會欄位。
