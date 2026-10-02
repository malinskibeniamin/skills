---
title: /efficient-frontier
description: 套用以評估為依據的模型路由，並明確控管已獲授權的代理程式執行批次預算，同時不將判斷權移出負責人手中。
type: skill
sidebar:
  label: /efficient-frontier
---
![「/efficient-frontier」技能示意圖](/diagrams/skills/efficient-frontier.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/efficient-frontier.excalidraw)

選擇模型前，閱讀[工具選擇規則](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working)。

`config/model-routing.json` 決定路由；不要將主觀評分複製到提示詞中。

1. 擁有者：Opus 5.5 `xhigh`，負責日常工作、計畫、程式碼與 UI。
2. Sol `xhigh` 透過 `/codex` 審查 PR；若無法使用，採用明確標示、使用乾淨上下文的 Opus `xhigh` 審查，並說明缺少跨模型家族覆蓋。
3. UI、文案與 API 設計由 Opus 負責，taste >= 8。若無法使用，回報 UI 路徑受阻，不要默默替換模型。
4. 瑣碎工作由日常模型 Opus 直接處理。使用者選用 Codex 時，由 Sol `xhigh` 執行工作、操作電腦或調查。
5. 僅選用 Opus/Sol 組合；絕不使用 `max`。若兩者都無法使用，回報此路徑受阻。歷史評分不能覆寫擁有者的偏好。
6. 跨模型家族審查需要明確授權；模型偏好本身不允許啟動代理。
7. `ultra` 需要明確委派或 `/swarm`。Pro 模式、持久化推理、程式化工具與顯式快取僅限 API，除非執行環境開放這些功能。

由一位負責人實作；未委派時自行執行各路徑。已授權路徑有範圍明確的目標、輸入、排除事項、證據及停止條件。負責人保留架構、優先順序、風險、整合及驗收責任。

## 容量

容量以 `/stay-within-limits` 主機計量為準；否則未知。絕不根據 token 或成本推斷。容量只能排除路徑，不能降低品質。

## 晉升

目前的 `xhigh` 預設值是擁有者的明確選擇，不是依據基準測試的晉升。
在未經要求的預設值變更前執行 `agent-evals/context-ablation/`：每次改變一個上下文群組，保持工作與評分不變，只在品質相當的結果中選擇更低成本。將勝出策略記錄到 `config/model-routing.json`。

僅在撰寫已獲授權的委派套件時，才讀取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
