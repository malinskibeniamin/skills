---
description: 負責修復、驗證、CI 和審查跟進，直到達到已授權的終點。用於 full send；full stop 或 --no-merge 保留人工合併決定。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - full send
sidebar:
  label: /full-send
title: /full-send
type: skill
---
![技能 /full-send 的圖表](/diagrams/skills/full-send.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/full-send.excalidraw)

負責成果，而不只是 diff。持續處理例行修復；只有確認達到要求的終點，或外部阻礙需要使用者介入時才交回。

## 授權與範圍 [#authorization-and-scope]

- 明確的 `full send <任務或 PR>` 授權修復、commit、push、建立 PR、跟進 CI／審查，以及合併這一個明確的交付成果。要求解釋、建立或審查本技能不等於呼叫它。發現技能不等於同意執行。
- 確認儲存庫、目標、自己負責的分支／worktree、PR／基準、驗收證據與停止條件。沿用已有 PR；在 Conductor 中保持簽出其分支。目標不明確時，詢問目標，不要擅自選擇另一個 PR。
- 先前的停止要求優先：`--no-merge`、不 push、僅本機、僅草稿或 PR 就緒都會縮小授權。僅跟進 PR 不授權合併。合併前指出哪條使用者指令授權了這個具體 PR。
- 保留無關改動、分支名稱、儲存庫保護，以及由使用者決定的正式環境、破壞性操作和安全事項。使用目前自己負責的功能分支。擴大範圍需要決策；例行修復和 lease-push 不需要。
- 除非使用者明確授權委派，否則在主要上下文內執行。僅使用已授權的工具、帳戶和隔離瀏覽器工作階段；「任何必要手段」不是繞過限制的許可。

依[技能機制](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)載入相依項目。
需要 full stop、託管狀態檢查、阻礙通知、復原上下文，或明確要求的 Sol loop 時，閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/REFERENCE.md)。

## 修復並證明 [#fix-and-prove]

1. 檢查整個分支 diff 與使用者要求，而不只看 PR 描述。修改行為前先建立失敗的公開契約測試；使用 [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)。
2. 以最小改動修復根因。執行儲存庫原生的針對性測試、lint、型別檢查與必要的建置／整合檢查。明確顯示警告及略過的驗證範圍。
3. 透過真實入口進行 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)：預期流程及可信的故障／復原路徑。可見改動需擷取並檢查 [PR 視覺證據](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)。
4. 在主要上下文中執行 [review](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md)。修復具體缺陷；由證據，而不是模型的熱情或審查者的讚揚，決定是否就緒。
5. 將證據綁定至 head SHA 與基準修訂。任何編輯、push、rebase 或基準變更都會使受影響的證據失效；宣告成功前重新驗證。

## 發布並跟進 [#publish-and-babysit]

透過 [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md) 發布；[自動設定使用端儲存庫的審查保障並驗證就緒狀態](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)。不要止於一次 CI 快照；確認提交範圍與遠端 HEAD 和本機 HEAD 一致。

- 在目前前景工作階段中監控此 PR 的檢查與已請求的審查。等待中代表繼續等待，不是完成。缺少 CI 不等於 CI 通過；依儲存庫政策確定必要檢查，不要編造全綠證明。
- 查看失敗工作的紀錄，重現、修復、驗證、commit、push，然後監控新 head。僅在有證據時重試基礎設施故障；重複且不變的失敗需要診斷，不是無限重跑。不要為變綠而削弱關卡。
- 使用 [resolve-pr-feedback](https://github.com/malinskibeniamin/skills/blob/main/resolve-pr-feedback/SKILL.md) 處理人工回饋與可執行的自動回饋。分頁取得全部討論串、留言和審查；修復或用證據反駁，回覆並重新讀取解決狀態。舊核准與機器人的沉默不是新審查。
- 要求必要檢查和審查已完成，候選版本沒有適用的未解決回饋或尚未撤銷的修改要求。不要自行核准或捏造認可。若審查者、權限或服務無法使用，且代理已無可執行動作，透過支援的提問或輸入工具通知；若無法使用，以醒目的受阻執行記錄與所需的確切輸入結束。等待時不得替換身分、憑證或權限。
- 必要時對落後於基準、自己負責的分支執行 rebase，驗證並使用 `--force-with-lease`。後續改動保持在本 PR 內。上下文達到限制前，把 head／基準、待處理執行／討論串 ID、證據與下一步寫入未追蹤的檢查點；不要悄悄啟動常駐程式、cron、auto-review 設定，或承諾工作階段結束後繼續工作。

## 最終驗證與信心 [#final-verification-and-confidence]

CI 和回饋穩定後，更新 head／基準、完整 diff、檢查、審查決定、討論串、草稿狀態與可合併性。對這個確切候選版本進行最後一次驗證：驗收檢查、受影響的真實入口流程及主要上下文風險審查。版本變更就回到循環；舊候選版本的通過證據不夠。

只有實際觀察了行為、必要關卡通過、回饋已處理、沒有重要缺陷或未知項，並理解上線和復原方式時，才回報**高信心**。指出限制；不要編造百分比，或保證 PR 永遠不會發生回歸。信心不足時應蒐集證據或修復，不要讓使用者重做例行審查。

## 完成閉環 [#close-the-loop]

已授權合併時，載入[受保護的合併契約](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)，執行帶預期 head 保護的託管路徑。遵守基準競爭／最新狀態關卡或合併佇列；不要使用管理員繞過或以 auto-merge 作為替代方案。確認託管狀態：**merged** 不等於 **queued**。追蹤已授權佇列項目直到最終結果；佇列失敗或 head／基準變更時重新驗證。修改結果未知時，重試前必須讀取狀態。

完成前確認儲存庫要求的合併後檢查。另行發布到正式環境與持續監控需要獨立授權。先前不合併的停止要求以經過驗證的 PR 就緒為終點；等待中的檢查、審查或佇列不算就緒。

回傳簡短憑據：結果／PR URL、驗證過的 head 與合併後的 merge commit、檢查、審查／討論串狀態、有證據的信心及真實限制／阻礙。遵循儲存庫的意圖／影響／狀態契約。不要把未完成的 PR 當作完成交回，或承諾永久監督。

靈感與研究限制：[SOURCES.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/SOURCES.md)。這是原創本機流程，不是 Theo 技能的副本或背書。
