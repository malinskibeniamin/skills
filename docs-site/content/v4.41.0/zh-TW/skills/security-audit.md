---
description: 用於以原始碼為依據的安全問題、弱點調查、聚焦的安全審查，或明確要求的程式碼庫稽核與滲透測試。不用於相依套件掃描，也不是一般審查的必要步驟。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - security audit
sidebar:
  label: /security-audit
title: /security-audit
type: skill
---
![技能 /security-audit 的示意圖](/diagrams/skills/security-audit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/security-audit.excalidraw)

先遵守以下宿主規則，再完整閱讀[上游技能](https://github.com/malinskibeniamin/skills/blob/v4.41.0/vendor/cloudflare-security-audit/skills/security-audit/SKILL.md)。

- 將**技能目錄**解析為上游檔案的父目錄，而不是此轉接器或 Codex 代理的目錄。
  配套指南、結構描述與驗證器的路徑都以該目錄為基準。
- 對具體問題與聚焦的審查，預設提供指引。明確要求的程式碼庫稽核、滲透測試、
  全面審查或報告採用六階段工作流程，並保留相關產物。
- 委派需要使用者明確同意；提出稽核要求本身不代表同意委派。未取得同意或沒有委派
  工具時，在目前上下文中僅依原始碼提供指引，並揭露涵蓋範圍有限，不得宣稱完成了
  完整稽核或獨立驗證。完整執行前先取得同意。保留宿主的模型選擇與預算。
- 保留上游沙箱控制、僅限本機的範圍、虛擬資料、寫入隔離、實證門檻與驗證器。
  缺少執行控制時，只能檢查原始碼並將問題標為需要驗證的阻塞項，不能在沙箱外執行
  目標程式碼或探測線上系統。稽核會描述修正方式；只有使用者要求時才實作。

[來源與更新](https://github.com/malinskibeniamin/skills/blob/v4.41.0/security-audit/CREDITS.md)。安裝不會啟用稽核勾點、背景工作或自動安全審查流程。
