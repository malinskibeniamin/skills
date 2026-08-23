---
title: /efficient-frontier
description: 套用以評估為依據的模型路由，並明確控管已獲授權的代理程式執行批次預算，同時不將判斷權移出負責人手中。
type: skill
sidebar:
  label: /efficient-frontier
---
![「/efficient-frontier」技能示意圖](/diagrams/skills/efficient-frontier.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/efficient-frontier.excalidraw)

讀取 `config/model-routing.json`。它是路由設定的唯一事實來源；請勿在提示詞或技能中重述主觀的模型評分。

品質優先：

1. 選擇最符合任務需求與可用執行環境的主要負責人。
2. 預設使用 `xhigh` 的 GPT-5.6 Sol；Sol 可負責使用者介面、實作、規劃、審查及電腦操作。
3. 只有在情境消融實驗證實能提升成效，或使用者明確選用時，才針對困難且品質優先的工作使用 `max`。
4. 將 Terra 與 Luna 視為須通過評估門檻的模型。在具版本控管的行為評估核准該用途之前，請勿將產品程式碼或審查工作路由給它們。
5. Fable 或 Opus 在可用且符合品質要求時，可以負責工作。除非使用者明確授權由不同模型系列進行檢查，否則審查工作應由主要負責人執行。
6. `ultra` 代表多代理程式團隊，且需要明確委派或使用 `/swarm`。
   Pro 模式、持久化推理、程式化工具呼叫及明確的快取控制僅適用於 API，除非目前使用的執行框架有提供這些功能。

由一位負責人進行實作。在未明確委派的情況下，直接依序執行任何有用的工作軌。若已委派，請為每個工作軌提供一個範圍明確的目標、輸入、排除事項、證據約定及停止條件。架構、優先順序、風險、整合及最終驗收仍由協調者負責。

## 容量

可透過明確的 `/stay-within-limits` 主機計量程序檢查 Claude 訂閱容量。容量未知時應回報為未知。切勿根據本機權杖或成本推斷容量。容量可以排除某條路由，但不能降低品質門檻。

## 晉升

變更預設值之前，請先執行 `agent-evals/context-ablation/`。一次比較一個情境群組，保持任務與評分方式不變，且僅在品質相當的結果中優先選擇成本較低者。將勝出的策略記錄於 `config/model-routing.json`。

僅在撰寫已獲授權的委派套件時，才讀取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/efficient-frontier/references/builder-upstream.md)。
