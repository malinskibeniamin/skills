---
description: "選擇並測試 animatic 影片的語音、算繪器、風格與串接工具，然後儲存目標儲存庫的設定。明確執行此技能來設定或更換工具鏈。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["setup animatic"]}
sidebar: {"label":"/setup-animatic"}
title: "/setup-animatic"
type: "skill"
---
![技能圖 /setup-animatic](/diagrams/skills/setup-animatic.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/setup-animatic.excalidraw)

先閱讀[宿主相容規則](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md)與 [animatic 宿主邊界](https://github.com/malinskibeniamin/skills/blob/main/animatic/SKILL.md)，再遵循完整的[上游設定流程](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/setup-animatic/SKILL.md)。相對引用以該原始碼目錄為基準；`<animatic>` 是隨儲存庫保存的相鄰目錄，不是本地轉接器。保留分階段訪談、語音範例、單片段建置及設定必須經過測試的要求。

## 執行範圍

- 詢問工具選擇前先檢查實際機器。推薦現有且可用的選項，解釋連網或離線行為與費用，然後等待使用者選擇。金鑰存在不代表授權付費語音或資料揭露。顯示命令錯誤；由使用者決定替代方案。
- 修改前確認選定的機器及安裝、快取範圍。遠端設定要求使用者明確指定遠端目標並提供獲授權的存取。在遠端機器上檢查與測試，不以本地測試代替。使用宿主安全憑證流程；遠端無法存取是阻礙，不是建立機器、複製秘密或更改 SSH、全域設定的理由。
- 沿用目標專案的工具鏈與已核准的相依套件位置。上游輔助指令碼會在 `ANIMATIC_HOME` 安裝自己的 npm 相依套件；設定前解釋此行為。一次性測試使用暫存快取。
- 先顯示擬寫入的內容，再將已測試的參數與環境變數名稱寫入目標儲存庫的 `docs/agents/animatic.md`。保留現有選擇；秘密值只放在環境或宿主秘密管理器中。
- 透過產生式指令的規範來源新增設定連結，然後重新產生。僅在允許時直接編輯人工維護的指令。本 harness 的 `AGENTS.md` 由 `CLAUDE.md` 與 `.agents/codex-appendix.md` 產生。不要僅為該連結新增任何指令檔案。

結束時提供已測試的機器、設定路徑、工具選擇、語音範例與測試 MP4 的路徑，以及剩餘限制。僅將技能納入儲存庫不會執行設定。
