---
description: 日常工作選用 Opus，高難度技術工作選用 Fable，審查選用 Sol；保留所選模型，且委派須有明確授權。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - efficient frontier
sidebar:
  label: /efficient-frontier
title: /efficient-frontier
type: skill
---
![「/efficient-frontier」技能示意圖](/diagrams/skills/efficient-frontier.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/efficient-frontier.excalidraw)

委派時閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#delegation)。
遵循[工具選擇規則](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working)。

角色由 `config/model-routing.json` 定義；不要在提示詞中加入主觀評分。

1. Opus 5.5 `xhigh`：日常工作、計畫、程式碼與 UI。Fable 5.2 `xhigh`：`quality_first.hard`。先補齊上下文、工具與檢查；任務很長或單次測試失敗本身不是升級理由。
2. Sol `xhigh` 透過 `/codex` 審查；無法使用時，採用明確標示的乾淨上下文 Opus `xhigh` 審查，並說明缺少跨模型家族覆蓋。
3. Opus 負責 UI、文案與 API 設計（taste >= 8）；無法使用時回報受阻。
4. 瑣碎工作：在目前的 Opus 上直接處理；使用者選用 Codex 後的執行、電腦操作與調查：Sol。
5. 僅使用 Opus/Fable/Sol；絕不使用 `max`。回報 Fable 無法使用；只有擁有者選擇時才以 Opus 替代。
6. 跨模型家族審查需要使用者明確授權；路由不是啟動代理程式的許可。
7. `ultra`：明確委派或 `/swarm`；僅限 API 的功能見[參考文件](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md#routing-notes)。

保留所選模型與端點；確認主機的模型識別碼與存取權限。路由不授權遞迴呼叫、新執行緒、付費額度或靜默切換。未獲委派授權時直接處理。工作簡報限定目標、輸入、排除項目、證據與停止條件；最終驗收由擁有者負責。
使用 Fable、交接工作或修改提示詞時，閱讀[模型提示指南](https://github.com/malinskibeniamin/skills/blob/main/shared/model-prompting.md)。

## 容量 [#capacity]

`/stay-within-limits`：使用主機計量，否則容量未知；絕不從 token 數或費用推斷，也不降低品質。

## 升級 [#promotion]

擁有者選定的 `xhigh` 不代表評估勝出。未經要求的變更：執行 `agent-evals/context-ablation/`；每次只改變一組上下文，固定任務與評分，只在品質相同時選擇較低成本，並將勝出方案記錄到路由設定。

[委派資料包](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
