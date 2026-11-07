---
description: "整理整個程式碼庫或指定範圍內洩漏的抽象、複製貼上的邏輯、暫時替代方案及多餘包裝，同時保留預期行為。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["untangle codebase"]}
sidebar: {"label":"/untangle-codebase"}
title: "/untangle-codebase"
type: "skill"
---
![技能示意圖 /untangle-codebase](/diagrams/skills/untangle-codebase.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/untangle-codebase.excalidraw)

改編自 [caldoai/skills](https://github.com/malinskibeniamin/skills/blob/main/vendor/caldoai/skills/untangle-codebase/SKILL.md)；
參見[來源與更新](https://github.com/malinskibeniamin/skills/blob/main/untangle-codebase/CREDITS.md)。此工作流程取代上游自動啟動子代理、無限循環整理，以及順帶修改錯誤行為的授權。

## 範圍與基準

建立結果契約：目標範圍（未指定時為整個專案自有程式碼庫）、保留行為的界線、驗證方式及要求的終點。
保留無關工作與公開契約。僅規劃或審查的要求維持唯讀；實作遵循儲存庫的
[交付契約](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，包括明確的僅本機或禁止推送限制。
匯入或討論此技能不等於呼叫。

僅提出一次以下選用附加工作，並遵從要求中既有的選擇：

| 附加工作 | 內容 |
| --- | --- |
| 註解 | 移除僅重述程式碼的註解。 |
| 測試 | 移除無法捕捉真實缺陷的測試，並修正沒有缺陷時仍失敗的測試。 |

未指定時詢問選擇；選擇前繼續結構整理，不執行這兩項附加工作。
重構時為保留涵蓋範圍而必須進行的測試更新，不屬於選用精簡。

使用[儲存庫導覽](https://github.com/malinskibeniamin/skills/blob/main/shared/repo-navigation.md)確認進入點、使用端、領域規則及現有檢查。
透過公開介面記錄基準及可信的失敗與復原情境。產生的成品與第三方快照仍交由各自維護者負責。

## 先診斷，再編輯

問：**這些部分是否應該一起變更？** 在範圍內列出有證據支持的問題：

- **隱藏關聯：** 重複知識、隱含共用狀態、呼叫順序慣例，以及按技術層分散的功能邏輯。
- **不必要關聯：** 呼叫端依賴內部細節、穩定領域依賴多變實作、僅服務特定呼叫端的參數，以及將變更洩漏給呼叫端的淺層抽象。
- **冗餘：** 僅轉送呼叫的包裝、推測性的擴充點或設定，以及看似未使用的程式碼。
- **特殊情況：** 單一值分支、呼叫端特例、遭吞掉的錯誤、休眠、重試、停用測試及暫時替代方案。追溯它們保護的需求或外部限制；存在本身不代表缺陷。

為每個發現保留位置、受影響的呼叫端、具體變更或失敗情境，以及能發現錯誤修正的驗證。
必要時使用 Git 共同變更歷史與相依證據；缺少圖邊不能證明程式碼已無用。
刪除或共用前遵循[無用程式碼與重複邏輯診斷](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#dead-code-and-duplication)。
決策記錄留在現有任務筆記或暫存目錄，預設不新增儲存庫報告。

## 圍繞需求重新設計

將相關問題歸入最小的根因修正。把共同變更的知識放到其負責模組中，分開獨立的變更原因。
優先使用穩定的領域介面，而非多變實作細節。選擇模組邊界時使用
[程式碼庫設計](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/SKILL.md)。

與維持現狀比較：指出方案消除的協調成本或失敗，以及必須保留的契約。
包裝可能負責驗證、授權、可觀測性或相容性；相似程式碼可能代表不同領域規則。
除非證據支持移轉，否則保留這些責任。更多輔助函式、更少行數或特殊情況，本身不能證明設計更好。

例如，對話框的任意焦點延遲與全域略過焦點還原旗標，可能都源於缺少統一的焦點還原責任方。
同時替換前應驗證巢狀對話框及鍵盤流程，而不是分別刪除兩個替代方案。

## 分步實作與驗證

1. 每次結構變更前建立相關行為檢查；優先重用測試，未涵蓋風險使用 [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)。
2. 移轉受影響的呼叫端，再移除已替代的內部實作，以及需求已由新設計滿足的替代方案。保留外部必要相容性。
3. 每步後按[適度驗證](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification)重播預期及失敗路徑。新發現的缺陷另外回報；附帶行為變更必須明確納入範圍，不得混入保留行為的重構。
4. 若選擇註解清理，刪除實作重述，保留外部限制及有用不變量；僅在移除過時替代方案時一併刪除說明。
5. 若選擇測試整理，載入[測試稽核](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md)，最後再精簡。替代行為檢查通過前保留回歸涵蓋範圍。說明每個刪除的測試為何無法捕捉獨立回歸；將脆弱的內部斷言改寫為公開介面檢查，而不是刪除必要涵蓋範圍。

## 審查與結束

在主要上下文內審查隱藏關聯、不必要關聯、冗餘及特殊情況。
僅在明確取得委派同意後，依宿主的模型與隔離規則使用子代理；載入此技能不構成同意。
使用 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)檢查可執行行為，再對完整差異執行[審查](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md)。

修正已確認且在範圍內的問題；首次範圍內審查無問題、基準行為保留且必要檢查通過時結束。
保留合理例外；回報未知項、涵蓋缺口及範圍外機會，不擴大任務。
總結根因修正、保留的限制、驗證及剩餘限制，接著僅完成要求的交付終點。
未經測量，不宣稱速度、token 用量或缺陷數量有所改善。
