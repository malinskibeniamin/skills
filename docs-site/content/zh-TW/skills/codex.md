---
title: /codex
description: 透過 Codex CLI 委派工作給 GPT-5.6。適用於規格明確的實作、獨立審查、電腦操作、調查、資料分析或耗用大量 token 的機械式工作。
type: skill
sidebar:
  label: /codex
---
![／codex 技能示意圖](/diagrams/skills/codex.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/codex.excalidraw)

**主機閘門：**此路徑由 Claude 託管。在原生 Codex 中，除非使用者明確要求委派或使用平行代理程式，否則請直接處理。請勿啟動遞迴的 `codex exec`；保留所選的模型與推理強度；請勿重寫 Codex 設定。

每個工作階段偵測一次功能支援：

```bash
codex exec -m gpt-5.6-sol "reply OK"
```

若無法使用，請改用可用的最強 GPT 並加以標示。若 CLI 無法使用，則略過此路徑並記錄原因。

## 路由變體

| 變體 | 強度 | 用途 |
|---|---|---|
| Sol | `xhigh`；有評估依據或明確選用時使用 `max` | 程式碼、UI、審查、規劃、電腦操作 |
| Terra | 視功能支援而定 | 受評估閘門管控的非程式碼工具迴圈 |
| Luna | 視功能支援而定 | 受評估閘門管控的低風險工具迴圈 |

選擇前請閱讀 `config/model-routing.json`。請勿根據價格或名稱推斷變體品質。請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md)，瞭解跨供應商閘門與 CLI 運作機制。

## 提示詞契約

Codex 看不到這段對話的任何內容。每個提示詞都必須指明儲存庫與分支、目標、範圍與排除項目、驗收條件、適用的技能規則與範例、確切的驗證命令、證據格式及停止條件。只傳送差異內容與任務本身的相關脈絡；排除機密資訊與無關檔案。

**引導承載內容：**進行實作工作時，請直接內嵌符合該路徑的特定規則，以及 `exemplars/` 中相符的檔案。

## 模式

- **實作：**`codex exec -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"'`；
  將並行寫入隔離於個別工作樹中。
- **審查：**優先使用與作者不同的模型系列。由 Sol 撰寫的工作可以使用 Claude 的高品質替代方案；備援方案是加以標示、使用乾淨脈絡的 Sol 審查。使用 `-s read-only` 模式與 P0-P3 證據。
- **對抗式交流（在 Claude 託管的工作流程中自動進行）：**獲得授權時使用不同的模型系列；將結果視為其中一條評估路徑，而非最終裁決。
- **電腦操作：**指明 URL／應用程式、狀態與證據。
- **調查／分析：**使用 `-s read-only` 並產出精簡報告。

## 工作流程

1. 通過主機與授權閘門。
2. 從 `config/model-routing.json` 選取符合品質要求的路由。
3. 撰寫自成一體的提示詞契約。
4. 使用明確的逾時設定或參考文件中的背景執行模式執行。
5. 整合前，驗證引用的檔案、命令與高風險結論。

高度仰賴判斷的架構設計、資訊綜整、產品、安全性及最終審查，仍由前沿模型協調者負責。Sol 可以負責面向使用者的輸出，且必須符合相同的視覺證據閘門。
