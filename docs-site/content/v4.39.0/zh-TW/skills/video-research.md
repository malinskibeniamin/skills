---
title: /video-research
description: 將影片 URL、影片附件或本機檔案擷取為附時間戳記的逐字稿、OCR 結果，以及可供研究使用的成品。適用於研究、摘要、引用或從影片擷取證據。
type: skill
sidebar:
  label: /video-research
---
![「/video-research」技能示意圖](/diagrams/skills/video-research.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/video-research.excalidraw)

在研究影片中的主張之前，先將影片轉換為可搜尋的證據。如果使用者已提供影片作為研究來源，請直接開始，不必先進行一輪確認。

## 擷取

1. 將來源解析為可存取的 URL 或本機附件的絕對路徑。僅使用使用者有權存取的媒體；讀取瀏覽器 Cookie 或跨越其他驗證界線前，必須先取得核准。
2. 選擇未受版本控制追蹤的輸出目錄。若 `.context` 已列入 gitignore，優先使用 `.context/video-research/<slug>/`；否則讓指令碼建立暫存目錄。
3. 從此技能的絕對目錄執行隨附的進入點：

```bash
bash <skill-dir>/scripts/analyze-video.sh \
  --output-dir <untracked-output-dir> \
  <video-url-or-path>
```

此進入點會優先使用原生字幕，其次使用本機 Whisper、擷取關鍵影格、對畫面文字執行 OCR，並寫入 `analysis.json`、`transcript.txt` 和 `research.md`。它會固定其一次性工具的版本，且首次使用時可能會下載本機模型。請持續告知使用者相關進度；不要將這些執行階段加入目標專案的相依套件檔案。

若已知語言，請傳入 `--language <code>`；若音訊難以辨識，請使用 `--model medium`；若視覺文字並非英文，請使用 `--ocr-language <codes>`。逐字稿預設僅在本機產生。雲端語音轉文字服務會上傳音訊，且可能產生費用，因此必須取得明確核准。

## 研究

先閱讀 `research.md`，再檢查 `analysis.json` 與其中引用的影格，以掌握脈絡。將 ASR 與 OCR 視為衍生證據：引用重要措辭前，應對照其時間戳記與影格進行驗證。整合逐字稿、畫面文字、視覺內容、說明、章節與連結的第一手來源；僅靠語音可能會遺漏影片的核心證據。

將需要長期保存的多來源研究結果交回 `/research` 處理，並以時間碼引用原始影片，而不要將產生的逐字稿視為獨立來源加以引用。

## 失敗處理規範

顯示分析器的每一則警告。若因語音後端無法使用而缺少逐字稿，這代表失敗，而非內容為空：請在暫存快取中安裝缺少的執行階段後重新執行。應將此情況與影片確實沒有聲音加以區分，若為後者，則改用 OCR 與影格。若媒體為私人、已移除、受 DRM 保護或無法存取，請說明存取限制並要求提供可存取的檔案；不要繞過該限制。
