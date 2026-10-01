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

1. 負責人：Opus 5.5 `high`（UI、程式碼、計畫）。
2. 第二路徑：透過 `/codex` 使用 Sol `medium`（規格明確的執行、電腦操作、調查）；無法使用 -> 明確標註的 Astra `high`，絕不使用更便宜的 GPT。
3. Astra `high` 審查 PR，必要時使用 Opus 5.5 `high`；Codex 剩餘用量 >=50% 時才使用 `xhigh`。
4. UI、文案、API 設計：taste >= 8 且由 Claude 負責，否則使用明確標註的 Astra 備援。
5. 瑣碎工作：Luna `high`（小幅修改、無衝突的 rebase、機械式 CI 修正、唯讀列表）；衝突、診斷、判斷 -> Sol。
6. Fable 5.1（最高 `high`）：明確要求，僅限特殊工作。`xhigh`：情境消融證據或使用者選擇；絕不使用 `max`。
7. 由使用者明確授權不同模型系列的檢查。
8. `ultra` 需要明確委派或 `/swarm`。Pro 模式、持久化推理、程式化工具、明確快取：僅限 API，除非環境已提供。

由一位負責人實作；未委派時自行執行各路徑。已授權路徑有範圍明確的目標、輸入、排除事項、證據及停止條件。負責人保留架構、優先順序、風險、整合及驗收責任。

## 容量

容量以 `/stay-within-limits` 主機計量為準；否則未知。絕不根據 token 或成本推斷。容量只能排除路徑，不能降低品質。

## 晉升

變更預設值之前，請先執行 `agent-evals/context-ablation/`。一次比較一個情境群組，保持任務與評分方式不變，且僅在品質相當的結果中優先選擇成本較低者。將勝出的策略記錄於 `config/model-routing.json`。

僅在撰寫已獲授權的委派套件時，才讀取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
