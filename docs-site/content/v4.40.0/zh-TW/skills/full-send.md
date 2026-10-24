---
description: "相容預設：將作者交付推進到已授權的合併；full stop 或 --no-merge 保留合併決定。"
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

明確的 `full send <task or PR>` 選擇[作者交付工作流程](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/delivery-workflow.md)，授權對這個明確目標進行修復、提交、推送、建立 PR、跟進 CI/審查並合併。討論此技能不等於呼叫。

先前的停止條件優先：僅本機、不推送、僅草稿、PR 就緒、full stop 或 `--no-merge` 會縮小端點。僅要求跟進不授權合併。確認目標和所屬工作樹，重用現有 PR，並在 Conductor 中保持檢出其分支。僅當目標不明確或擁有者保留的決定阻塞工作時詢問。

閱讀並執行共用工作流程，而非另一套 full-send 實作。程式碼未完成時載入 [development-lifecycle](https://github.com/malinskibeniamin/skills/blob/v4.40.0/development-lifecycle/SKILL.md)；現有 PR 從目前證據開始。僅為要求的檢查點、通知、恢復或明確委派的審查讀取 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/full-send/REFERENCE.md)。不自動切換模型或建立代理程式。

靈感及研究限制：[SOURCES.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/full-send/SOURCES.md)。此本機工作流程不是複製或獲得 Theo 背書的技能。

共用工作流程為獲准的監控選擇[原生脈絡](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/T3CODE-NATIVE.md#resolve-context)；維持單一交付循環，不另建 T3 工作流程。
