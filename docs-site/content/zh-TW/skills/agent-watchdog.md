---
description: 依據原始要求與即時證據稽核另一個代理。適用於工作階段、PR、分支、比較、已授權的修正或接手停滯工作。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - agent watchdog
sidebar:
  label: /agent-watchdog
title: /agent-watchdog
type: skill
---
![「/agent-watchdog」技能圖解](/diagrams/skills/agent-watchdog.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/agent-watchdog.excalidraw)

稽核前閱讀[稽核協定](https://github.com/malinskibeniamin/skills/blob/main/agent-watchdog/references/audit.md)；稽核複雜或語意不明時，閱讀 `references/builder-upstream.md`。
使用已獲授權的來源與宿主實際提供的工具。自行進行調查；額外代理、監看、正式環境存取與寫入操作都需要個別授權。

## 模式 [#modes]

- **僅監看：**監看工作階段、PR、分支、CI 或逐字稿，直到進入終止狀態；請勿編輯。
- **稽核：**比較要求、證據、差異、測試、CI、留言與聲明；請勿編輯。
- **稽核並修正：**先稽核，再進行範圍有限且已獲授權的修正。
- **比較：**依據同一要求評估代理或工作階段。
- **接手：**明確要求接手受阻工作；遵循[接手規則](https://github.com/malinskibeniamin/skills/blob/main/agent-watchdog/references/takeover.md)執行至要求的終點，不限於先前的方法。

當編輯權限不明確時，預設僅進行稽核。

## 工作流程 [#workflow]

接手模式使用其參考文件；其他模式依下列步驟執行：

1. 確認目標、原始要求與限制；先提出自己的假設。
2. 檢查第一手證據；比對代理的差異、檢查與聲明。
3. 註明先前已接觸過哪些資料；同一上下文中的調查不構成獨立審查或跨模型家族審查。
4. 分類為 `Gap|Bug|Verification miss|Scope drift|No issue`。
5. 僅修正已獲授權的缺漏；絕不還原無關工作或擅自移動分支。
6. 回報確切證據、需要採取行動的差異、風險與下一步；傳遞提示、處理已完成工作樹及整理輸出時，遵循稽核協定。
