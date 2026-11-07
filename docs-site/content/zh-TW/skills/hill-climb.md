---
description: 透過有界評估循環最佳化明確的目標。適用於 hill-climb 請求，或依可執行評估、效能基準測試、視覺比較反覆改善的任務；不用於單次審查。
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["hill climb"]}
sidebar: {"label":"/hill-climb"}
title: "/hill-climb"
type: "skill"
---
![「/hill-climb」技能圖解](/diagrams/skills/hill-climb.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/hill-climb.excalidraw)

最佳化產物，不是迎合評審。優先採用可執行的證據，並校準視覺判斷。

## 與既有負責技能協作 [#compose-with-existing-owners]

依說明僅載入適用的[負責技能](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)，共用一套循環與預算：

- [開發生命週期](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md)負責實作與交付。報告、計畫及審查請求維持唯讀，僅允許寫入明確要求的計畫成品；[improve](https://github.com/malinskibeniamin/skills/blob/main/improve/SKILL.md) 可以建議爬坡，但不能自行啟動。
- [Quantify impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) 負責指標、最低有價值改善幅度與雜訊。
- 對於 UI，[視覺審查](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md)負責實際畫面證據與專項指引路由；[dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md) 負責真實行為以及失敗與復原檢查。
- 僅在明確授權後，[council](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/council/SKILL.md) 或 [sol-loop](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/sol-loop/SKILL.md) 才能依[主機相容約定](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#review-evidence-for-council-and-sol-loop)提供唯讀審查輪次。僅載入 hill-climb 不授予委派權限。否則應在主要脈絡中審查，並明確標註。[Efficient frontier](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md) 負責已授權的模型路由與可用容量。

## 編輯前定義爬坡目標 [#define-the-hill-before-editing]

使用既有任務約定，或在目前脈絡中簡要記錄：

- **目標：**受益者、預期結果、主要指標或明確的評量面向、驗收條件，以及最低有價值改善幅度。數字本身不等於價值。
- **護欄：**受保護的行為、無障礙性、安全性、允許編輯的範圍與資源限制。保留無關改動，以及使用者最初要求的交付終點。
- **驗證：**評估器指令或視覺評估流程、測試資料、環境、原始修訂版本，以及最佳的已確認候選版本（目前最佳版本）。保留這兩個參照。
- **停止：**交付終點、有限的評估／資源預算與停滯規則。預設最多嘗試三個候選，不論是否接受；一次介入只算一個候選，與檔案數量無關。基準批次、重試與確認都計入評估／資源預算。每次嘗試前預留確認所需的容量；若剩餘容量不足，就停止搜尋。更嚴格的使用者、審查或主機限制優先；重新建立基準不能重設計數。

如果沒有可信的評估器，就在授權範圍內建立最小的驗證器，或指出缺少的前提。不要用容易達成的代理指標取代要求的結果。如果基準已經滿足目標，確認後就停止，不做推測性修改。

## 校準評估器 [#calibrate-the-evaluator]

選擇適用的分支，並在可比輪次中固定輸入：

| 分支 | 基準與證據 |
|---|---|
| 可執行正確性／評估 | 重現具代表性的失敗，並保留有效對照。固定斷言、預期答案與支援的路由；可行時保留留出案例，供最終確認使用。 |
| 效能／資源 | 使用[最佳化實驗協定](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments)：相同負載與環境、配對量測、雜訊，以及相對原始版本和目前最佳版本的行為保真護欄。 |
| 視覺品質 | 在可比的路由、資料、檢視區、縮放、佈景主題與互動狀態下，擷取原始版本、候選版本及有用的參考產品。選擇與任務相關的面向，例如層級、可讀性與回饋；保留行為與無障礙檢查。 |

進行已授權的獨立視覺審查時，使用新的脈絡，並提供相同的產物、評量準則、意圖、限制、檢查結果及未解決問題。不要透露期望的數字評分、先前評分或偏好的贏家；可行時為候選版本使用中性標籤。要求提供有證據的比較與具體缺陷。只有明確要求時才提供數字評分，而且始終僅供參考。主要脈絡內的自評既不是盲評，也不是獨立審查。

重新評估未改變的參照，以偵測評審漂移。如果相同輸入得到明顯不同的判斷，應調查原因或回報不確定性，而非宣稱獲勝。修復評估器，或變更評量準則、測試資料、模型、環境，都必須重新建立基準後再比較。不要把新評分拼入舊趨勢，也不要為了通過評估而削弱測試。 新增或替換已授權的評審時，先用未改變的參照校準該評審，並分別保留各評審的結果。

## 開始爬坡 [#climb]

1. **提出假設：**選擇一個有證據的瓶頸或具體品質缺陷，預測小規模、可逆的修改如何改善目標而不破壞護欄。
2. **修改：**僅透過負責該任務的既有工作流程實施這項介入。保留可復原的目前最佳版本；審查進行時，不要編輯其評估範圍內的輸入。
3. **評估：**對確切的候選版本執行相關檢查與已固定的評估器。重用有效證據，並如實記錄無效樣本、失敗及無法涵蓋的範圍。
4. **先確認，再保留：**有價值、超出雜訊，且相對原始版本與目前最佳版本都維持護欄的改善，在一批新的、預先固定的評估確認前都只是暫定結果。只有確認成功後，才能更新目前最佳版本。確認失敗或結果不明確時，拒絕該試驗；只回復這次試驗中自己負責的改動，保留已確認的目前最佳版本與他人的工作。平手或缺少結果都不是收益。
5. **記錄：**維護精簡的輪次紀錄：候選身分、假設、證據／差異、護欄結果、保留／回復決定、剩餘預算，以及未解決問題。只有執行確實需要時，才使用被忽略或暫存的儲存位置；不要例行產生稽核傾印，也不要每輪都建立一個 PR。

確認達成驗收條件、耗盡預算、連續兩個候選都沒有收益，或遇到外部阻礙／保留決策時停止。

| 停止時的證據 | 回報 |
|---|---|
| 目前確認結果滿足目標與全部護欄 | `met`；保留已確認的目前最佳版本。 |
| 在預算或停滯限制處，有效評估仍未達到目標 | `unmet`；保留最佳的已確認版本，而非最後一次試驗。 |
| 評估器缺少或無效、發生漂移，或無法取得必要的審查涵蓋範圍 | `unverified`；保留目前最佳版本，並指出缺少的證據。 |

更高的評分不能解決實質缺陷。保留最初的範圍與目標；應診斷無效評估，而非反覆評估未改變的候選，直到抽到通過的評分。

最佳化提示詞或工具描述時，先在已聲明的路由中建立行為正確性。接著將通過的測試集固定為護欄，逐步減少脈絡，並重跑對照與留出案例。將兩個階段分開；如果更短的指令讓工具選擇變差，就應淘汰該候選。使用[代理程式寫作指南](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL.md)；模型或脈絡路由的變更仍須遵守 [efficient frontier 的評估門檻](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md#promotion)。

## 確認並交接 [#confirm-and-hand-off]

僅當輸入未改變時，才能重用確認結果；相對原始版本重跑已失效的功能／視覺檢查。明確說明缺少的獨立審查涵蓋範圍；共識或評分不能取代驗證或人工核准。

回報結果與目標狀態、原始版本到最終版本的證據、保留與回復的實驗、剩餘限制，以及循環停止的原因。透過既有的交付負責技能繼續到使用者要求的終點；hill-climb 本身不增加建立 PR、合併、部署或監控的授權。

範例：
- `/hill-climb improve sidebar readability against the supplied screenshots; preserve keyboard flows; 3 candidates; local only; no delegates`
- `/hill-climb reduce tool-description tokens while preserving the existing tool-choice eval across supported routes; 3 candidates; local only; no delegates`

來源：[Theo 的說明](https://x.com/theo/status/2118465321032106235)，13:04–20:44（參照比較與評分漂移），26:21–30:27（先評估，再壓縮）。
