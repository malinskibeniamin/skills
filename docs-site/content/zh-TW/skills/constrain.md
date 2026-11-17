---
description: "以允許清單、檢查及持續縮小的違規基線，限制工具 API 與匯入相依。"
related: ["/skills/development-lifecycle", "/skills/tdd", "/skills/review"]
sidebar: {"label": "/constrain"}
title: "/constrain"
type: "skill"
---
![技能 /constrain 的流程圖](/diagrams/skills/constrain.svg)

[Excalidraw](/diagrams/skills/constrain.excalidraw)

選擇強制檢查機制前，先閱讀 [harness 改進規則](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#harness-improvement)。

先閱讀[宿主相容規則](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md)，再遵循完整的[上游技能](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/constrain/SKILL.md)。相對引用以該原始碼目錄為基準。保留探索、收集、訪談、建置、基線收緊、驗證及記錄階段。這是明確呼叫的實驗草稿，不是預設的 React／狀態政策，也不是安全沙箱。

## 宿主邊界

- 在目標工作目錄中限制使用者選定的一項工具。提出允許清單前，檢查已安裝版本、檢查命令、CI 與既有約束。載入或將技能納入儲存庫不會啟用規則、hook 或相依套件。
- 除非使用者明確授權委派，否則自行完成上游 Community 與 Usage 兩條調查線。獲准後，使用全新上下文與範圍明確的任務說明，遵循[模型路由](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md)；原始指令本身不構成授權。區分實際觀察到的用法、不完整清單及推論風險。
- 依[相依載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)載入 [grilling](https://github.com/malinskibeniamin/skills/blob/main/grilling/SKILL.md) 進行訪談。呈現各允許清單、路徑例外、正向替代方式，以及按名稱／型別比對的涵蓋缺口。修改規則或基線前，等待使用者確認限制範圍；範例中的限制不等於使用者決定。
- 沿用目標專案的檢查器與檢查命令。需要特定版本能力時，載入[第一手文件研究](https://github.com/malinskibeniamin/skills/blob/main/read-the-damn-docs/SKILL.md)。Biome 專案保留 Biome，優先使用既有適當規則。能力缺失不代表可以默默遷移 lint 引擎或新增第二個檢查器。說明所需專案層級相依套件及範圍。
- 基線只記錄新確認規則下的既有違規，按規則及檔案劃分；匯入圖則按邊記錄。保留先前失敗、基線、抑制控制及較嚴格政策；不得以 `--suppress-all` 抑制整個專案。如果目標禁止基線，應回報衝突並協議合規遷移，而非關閉門檻。CI 必須拒絕新增／增加的違規及過期基線項目；收緊允許清單不得重新建立無關債務的基線。這是遷移棘輪，不是繞過機制。
- 證明合法程式碼通過、每種範圍內的禁止用法在新檔案中失敗、基線檔案新增違規時失敗，以及已償還債務不能回歸。適用時涵蓋別名、重新匯出及命名空間，並揭露漏檢範圍。執行實際總檢查命令、移除刻意加入的違規，再次確認通過。來源範例不能證明已安裝版本的行為。
- 透過目標專案人工維護的指引記錄工具與檢查命令。若 `AGENTS.md` 是產生檔案，修改規範輸入並重新產生。允許清單留在可執行設定中，不另建文字目錄。

結束時提供經確認的限制、規則／基線路徑、實際通過／失敗／縮減證據及涵蓋限制。遵循使用者的交付終點；呼叫不授權全域安裝、託管政策變更或無關重構。
