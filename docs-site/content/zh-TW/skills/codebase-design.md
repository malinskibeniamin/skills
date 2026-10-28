---
title: /codebase-design
description: 設計具備小型介面的深層模組。適用於選擇接縫、減少跨檔案切換阻力、深化模組、測試 API，或採用共通的設計詞彙。
type: skill
sidebar:
  label: /codebase-design
---
![「/codebase-design」技能示意圖](/diagrams/skills/codebase-design.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/codebase-design.excalidraw)

當下方工作流程需要模型可呼叫的技能時，請為每個相依技能分別呼叫 Skill 工具。沒有此工具的宿主應依[相依技能載入規則](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)完整閱讀標準 `SKILL.md`。僅供使用者呼叫的技能應建議由使用者執行，不要自動呼叫。

使用 `GLOSSARY.md` 中的領域術語並遵循相關 ADR。若存在 `GLOSSARY-MAP.md`，依對照找到相應脈絡的詞彙表。

設計**深層模組**：在清楚的接縫上，以小型介面封裝大量行為，並可透過該介面進行測試。目標是為呼叫端提供槓桿效益、為維護者提升局部性，並提高可測試性。

模組應減少呼叫端必須掌握的知識與協調成本，同時保留必要行為。

## 詞彙表

請精確使用：

**模組** -- 介面加上實作：函式、類別、套件、切片。

**介面** -- 呼叫端必須知道的一切：型別、不變條件、順序、錯誤、設定、效能；範圍比簽章更廣。

**實作** -- 模組內部的內容。

**深度** -- 介面的槓桿效益。**深層**代表小型介面、大量行為；**淺層**代表介面與實作的複雜度相近。

**接縫** -- 無須編輯呼叫端即可改變行為的位置；其介面位於此處。避免使用「邊界」，除非指的是 DDD 限界上下文。

**轉接器** -- 接縫處的具體實作，依角色命名。

**槓桿效益** -- 呼叫端每學習一項介面所獲得的能力。

**局部性** -- 讓變更、錯誤、知識與驗證集中在一處。

請思考方法與參數能否縮減，以及能否在內部隱藏更多複雜性。

## 原則

- 深度是介面的屬性，而非行數比率；私有接縫無須洩漏出去。
- **刪除測試：**如果移除模組會讓複雜性一併消失，那它只是直通層；如果複雜性擴散至呼叫端或測試中，則該模組確實有其價值。
- **介面就是測試表面：**呼叫端與測試會跨越相同的接縫。越過介面測試內部，表示模組形狀不夠健全。
- **一個轉接器代表假想的接縫；兩個轉接器代表真實的接縫。**
- 簡短的區域程式碼，勝過只是搬移程式碼的抽象層。

## 從呼叫端開始的草圖 [#caller-first-sketch]

對新增或變更的介面，先寫出具代表性的呼叫端程式碼，再定義型別或簽章：一個成功情境，以及一個可信的失敗或拒絕情境。指出狀態擁有者、它保護的不變條件，以及呼叫端在失敗時觀察到的結果。重用既有領域型別；從這些呼叫推導出最小介面，而非暴露內部階段。

選定設計形狀前，針對草圖嘗試[最短的錯誤修改](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit)。小幅變更的草圖可直接寫在目前的說明中；機械式搬移不需要設計練習。只有在仍有實質分歧或使用者要求時，才比較整體形狀的替代方案。這不會新增實作前的暫停關卡。

## 可測試性

1. 接受相依項目；不要在內部建立它們。
2. 回傳結果；將環境中的副作用降至最低。
3. 維持少量的方法與參數，並確保不變條件清楚。

當兩種設計都通過刪除測試時，請使用 `/plan-arbiter` 比較深度、局部性、測試表面與回復能力。

關係：一個模組具有一個介面；深度是相對於介面衡量的；接縫是介面所在之處；轉接器滿足介面；深度會產生槓桿效益與局部性。

不採用以行數衡量深度、將介面視為 TypeScript 關鍵字，以及含糊的邊界措辭。

請閱讀 [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DEEPENING.md)，了解相依性、接縫與測試規範；並閱讀 [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DESIGN-IT-TWICE.md)，了解平行設計。
