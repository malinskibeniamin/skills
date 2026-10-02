---
title: /codex
description: 透過 Codex CLI 委派工作給 GPT-6.1 Sol。適用於規格明確的實作、獨立審查、電腦操作、調查、資料分析或耗用大量 token 的機械式工作。
type: skill
sidebar:
  label: /codex
---
![／codex 技能示意圖](/diagrams/skills/codex.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/codex.excalidraw)

**主機閘門：**此路徑由 Claude 託管。在原生 Codex 中，除非使用者明確要求委派或使用平行代理程式，否則請直接處理。請勿啟動遞迴的 `codex exec`；保留所選的模型與推理強度；請勿重寫 Codex 設定。

僅在委派獲授權後偵測能力：`codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"' "reply OK"`。若無法使用，採用明確標示、使用乾淨上下文的 Opus 5.5 `xhigh` 審查，並說明缺少跨模型家族覆蓋。僅選用 Opus 5.5 和 GPT-6.1 Sol；若兩者都無法使用，回報此路徑受阻。

## 路由

| 變體 | 用途 |
|---|---|
| Sol，`xhigh`（`gpt-6.1-sol`；絕不使用 `max`） | 首選 PR 審查者；明確選用時執行工作、操作電腦或調查 |
| Opus 5.5，`xhigh`（`claude-opus-5-5`） | 日常工作、UI、計畫、程式碼、瑣碎工作；明確標示的乾淨上下文審查備援 |

閱讀 `config/model-routing.json`；不要依名稱或價格推斷品質。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md) 規定供應商閘門與 CLI 機制。

## 提示詞契約

Codex 看不到這段對話的任何內容。每個提示詞都必須指明儲存庫與分支、目標、範圍與排除項目、驗收條件、適用的技能規則與範例、確切的驗證命令、證據格式及停止條件。只傳送差異內容與任務本身的相關脈絡；排除機密資訊與無關檔案。

**引導承載內容：**進行實作工作時，請直接內嵌符合該路徑的特定規則，以及 `exemplars/` 中相符的檔案。

## 模式

- **實作：**`codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`；
  將並行寫入隔離於個別工作樹中。
- **審查：** Sol `xhigh`：`codex exec -s read-only -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`；提供 P0–P3 證據。不要用猜測的用量門檻改變擁有者選定的推理等級。
- **對抗審查：** 僅限 Claude 主機且已獲授權；只是一條審查路徑，不是最終結論。
- **電腦操作：**指明 URL／應用程式、狀態與證據。
- **調查／分析：**使用 `-s read-only` 並產出精簡報告。

## 工作流程

1. 通過主機與授權閘門。
2. 從 `config/model-routing.json` 選取符合品質要求的路由。
3. 撰寫自成一體的提示詞契約。
4. 使用明確的逾時設定或參考文件中的背景執行模式執行。
5. 整合前，驗證引用的檔案、命令與高風險結論。

架構、資訊綜整、產品、安全性與最終判斷由協調者負責。預設情況下，Codex 模型不負責面向使用者的 UI、文案或 API 設計。這些介面由 Opus 5.5 負責；若無法使用，回報此路徑受阻。
