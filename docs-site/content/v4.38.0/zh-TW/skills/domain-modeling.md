---
title: /domain-modeling
description: 建立並精煉專案的領域模型。適用於討論程式碼庫術語、撰寫或編輯 CONTEXT.md，或記錄或編輯 ADR。
type: skill
sidebar:
  label: /domain-modeling
---
![「/domain-modeling」技能示意圖](/diagrams/skills/domain-modeling.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/domain-modeling.excalidraw)

在設計過程中，主動建立並精煉專案的領域模型。這是一項*主動*的實踐——質疑術語、構思邊界情境，並在詞彙與決策明確成形的當下將其記錄下來。（僅僅為了了解詞彙而*閱讀* `CONTEXT.md` 並不算運用此技能——那只是任何技能都能採用的一行式習慣。此技能適用於變更模型，而不只是使用模型。）

## 檔案結構

大多數儲存庫只有一個限界上下文：

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

如果根目錄中有 `CONTEXT-MAP.md`，表示該儲存庫包含多個限界上下文。此對照表會指出每個限界上下文所在的位置：

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          <- system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 <- context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

依需求建立檔案——只有在確實有內容可寫時才建立。如果沒有 `CONTEXT.md`，請在第一個術語獲得釐清時建立。如果沒有 `docs/adr/`，請在需要第一份 ADR 時建立。

## 工作階段期間

### 依據詞彙表提出質疑

當使用者使用的術語與 `CONTEXT.md` 中既有的用語衝突時，立即指出。「你的詞彙表將『取消』定義為 X，但你現在似乎是指 Y——究竟是哪一個？」

### 精煉模糊用語

當使用者使用模糊或含義過多的術語時，提出精確的標準術語。「你說的是『帳戶』——你指的是客戶還是使用者？兩者是不同的概念。」

### 討論具體情境

討論領域關係時，請使用具體情境進行壓力測試。構思能探索邊界情況的情境，促使使用者精確說明各概念之間的界線。

### 與程式碼交叉比對

當使用者陳述某項機制的運作方式時，檢查程式碼是否與其一致。如果發現矛盾，請明確指出：「你的程式碼會取消整筆訂單，但你剛才說可以部分取消——哪一個才是正確的？」

### 即時更新 CONTEXT.md

術語獲得釐清時，立即更新 `CONTEXT.md`。不要累積後再一次處理——在明確下來時就記錄。請使用 [CONTEXT-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/domain-modeling/CONTEXT-FORMAT.md) 中的格式。

`CONTEXT.md` 應完全不含實作細節。不要將 `CONTEXT.md` 當作規格、暫存筆記或存放實作決策的地方。它僅是詞彙表，除此之外別無他用。

### 謹慎提出 ADR 建議

只有在以下三項條件全都成立時，才建議建立 ADR：

1. **難以逆轉**——日後改變決定的成本相當可觀
2. **缺乏脈絡時令人意外**——未來的讀者會疑惑「他們為什麼要這樣做？」
3. **源自實際的權衡取捨**——當時確實存在可行的替代方案，而你基於具體理由選擇了其中一項

只要缺少其中任何一項，就不要建立 ADR。請使用 [ADR-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/domain-modeling/ADR-FORMAT.md) 中的格式。
