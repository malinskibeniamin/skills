---
title: /research
description: 研究第一手資料並儲存附有引用的研究結果。適用於長期保存的報告、文件調查、API 事實集、通讀作業或設計理由考證。
type: skill
sidebar:
  label: /research
---
![「/research」技能示意圖](/diagrams/skills/research.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/research.excalidraw)

預設直接在目前工作流程中進行研究。只有明確委派或使用 `/swarm` 時，才會啟用背景代理程式。

其工作內容：

1. 依據**第一手資料**調查問題——官方文件、原始碼、規格、第一方 API——而非這些資料的二手解讀。每項論述都必須追溯至其權威來源。
2. 將研究結果寫入單一 Markdown 檔案，並為每項論述標註來源。
3. 將檔案儲存至儲存庫原本存放此類筆記的位置；遵循既有慣例，若無既有慣例，則存放至合理的位置並說明路徑。在此技能儲存庫中，探索性調查應保留於暫存區或記憶中——只有足以支援決策的研究結果才會存入 `docs/`。

## 分流

- 需要**立即**取得某項事實以繼續撰寫程式碼（API 結構、目前的旗標、版本行為）-> 改為直接在目前工作流程中使用 `/read-the-damn-docs`；不使用背景代理程式，也不產生文件。
- 需要了解程式碼或設計為何存在 -> 閱讀 [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md)；追溯原始碼歷史與決策證據，不臆測意圖。
- 影片 URL 或附件 -> 先使用 `/video-research`；將其含時間戳記的逐字稿、OCR 結果與影格視為來源證據。
- 經過對抗式驗證的多來源事實查核**報告** -> 使用深度研究工具組。
- 此技能位於兩者之間：進行聚焦的閱讀與資料蒐集，並產出附有引用的 Markdown 文件。
