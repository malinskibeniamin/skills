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

僅在使用者明確要求委派時，閱讀 [Poteto 適配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#delegation)。

選擇模型前，閱讀[工具選擇規則](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working)。

`config/model-routing.json` 決定路由；不要將主觀評分複製到提示詞中。

1. 擁有者：Opus 5.5 `xhigh`，負責日常工作、計畫、程式碼與 UI。
   對 `quality_first.hard` 所列的高難度任務使用 Fable 5.2 `xhigh`：重大遷移或重構、複雜架構或研究、長週期技術工作，或已觀察到的 Opus 能力不足。先補齊上下文、工具與檢查；任務較長或一次測試失敗，本身不足以觸發升級。
2. Sol `xhigh` 透過 `/codex` 審查 PR；若無法使用，採用明確標示、使用乾淨上下文的 Opus `xhigh` 審查，並說明缺少跨模型家族覆蓋。
3. UI、文案與 API 設計由 Opus 負責，taste >= 8。若無法使用，回報 UI 路徑受阻，不要默默替換模型。
4. 瑣碎工作由日常模型 Opus 直接處理。使用者選用 Codex 時，由 Sol `xhigh` 執行工作、操作電腦或調查。
5. 僅使用 Opus/Fable/Sol；絕不使用 `max`。回報 Fable 高難度任務路徑無法使用的情況；只有負責人明確選用時，才能在該路徑改用 Opus。負責人的偏好優先於歷史評分。
6. 跨模型家族審查需要明確授權；模型偏好本身不允許啟動代理。
7. `ultra` 需要明確委派或 `/swarm`。Pro 模式、持久化推理、程式化工具與顯式快取僅限 API，除非執行環境開放這些功能。

由一位負責人實作；未委派時自行執行各路徑。已授權路徑有範圍明確的目標、輸入、排除事項、證據及停止條件。負責人保留架構、優先順序、風險、整合及驗收責任。

保留工作階段中明確選定的模型。任務符合高難度條件時，只在主機支援選擇的情況下選用 Fable 角色；這不代表授權遞迴呼叫、建立新對話串、使用付費額度或悄悄切換模型。確認主機實際提供的模型及其精確識別碼；回報缺少的路徑，而不是使用會解析成其他模型的別名。
處理 Fable 任務、進行模型交接或修改 Claude 提示詞時，請閱讀[模型提示指南](https://github.com/malinskibeniamin/skills/blob/main/shared/model-prompting.md)。

## 容量 [#capacity]

容量以 `/stay-within-limits` 主機計量為準；否則未知。絕不根據 token 或成本推斷。容量只能排除路徑，不能降低品質。

## 晉升 [#promotion]

目前的 `xhigh` 預設值是擁有者的明確選擇，不是依據基準測試的晉升。
在未經要求的預設值變更前執行 `agent-evals/context-ablation/`：每次改變一個上下文群組，保持工作與評分不變，只在品質相當的結果中選擇更低成本。將勝出策略記錄到 `config/model-routing.json`。

[任務包與來源](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md): 僅供已獲授權的委派使用。
