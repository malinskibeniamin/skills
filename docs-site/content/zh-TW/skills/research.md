---
title: /research
description: 研究第一手資料並儲存附有引用的研究結果。適用於長期保存的報告、文件調查、API 事實集、通讀作業或設計理由考證。
type: skill
sidebar:
  label: /research
---
![「/research」技能示意圖](/diagrams/skills/research.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/research.excalidraw)


預設直接在目前工作流程中進行研究。只有明確委派或使用 `/swarm` 時，才會啟用背景作業。

1. 將每項論述追溯至**第一手資料**：官方文件、原始碼、規格、第一方 API。
2. 撰寫單一 Markdown 文件，並為每項論述標註來源；標出所有無法確認的內容，並說明查找過的位置。
3. 遵循儲存庫既有的筆記慣例：探索性調查應保留於暫存區或記憶中；只有足以支援決策的研究結果才會存入 `docs/`。

## 分流 [#routing]

- 立即取得 API／版本相關事實 -> 直接在目前工作流程中使用 `/read-the-damn-docs`，不產生文件。
- 需要了解程式碼或設計為何存在 -> 閱讀 [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md)；追溯
  原始碼歷史與決策證據，不臆測意圖。
- 影片 -> `/video-research`；將含時間戳記的逐字稿、OCR 結果與影格視為證據。
- 經過對抗式驗證的多來源報告 -> 深度研究工具組。
- 此技能 -> 進行聚焦的閱讀，並產出附有引用的 Markdown 文件。
