---
description: 建立面向客戶的功能操作錄影，並將其發布至草稿 PR。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - demo
sidebar:
  label: /demo
title: /demo
type: skill
---
![／demo 技能示意圖](/diagrams/skills/demo.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/demo.excalidraw)

將已完成的工作轉化為向客戶證明價值的成果。閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/demo/REFERENCE.md)。

## 規範 [#contract]

1. 確認目標範圍；預設涵蓋目前整個分支或 PR 自 merge-base 起的內容，包括已提交、已暫存、未暫存及相關的未追蹤工作。
2. 選擇最有說服力的可見效益，講述一段簡短的「問題 -> 操作 -> 成果」故事。
3. 將原始檔和輸出保存在 `demos/<slug>/` 下；更新時重複使用此目錄，不要分散媒體檔案。
4. 優先錄製：使用真實的瀏覽器錄影，以及 asciinema `.cast` 終端機重播。遵循[錄製與旁白步驟](https://github.com/malinskibeniamin/skills/blob/v4.42.0/demo/RECORDING.md)。終端機重播不是 MP4 檔案。
5. 影片交付為 `output/demo.mp4`；分章節示範交付為 `output/index.html` 及其資源。混合瀏覽器與終端機的示範使用[示範範本](https://github.com/malinskibeniamin/skills/blob/v4.42.0/demo/templates/walkthrough.html)。標明解說性或模擬素材；它們不是錄製的產品證據。
6. 需要在真實錄影周圍加入合成內容時，重複使用 HyperFrames；若原始內容由現有 Remotion 專案管理，則保留該專案。不要只為錄影而安裝第二個算繪器。
7. 確保示範在靜音時仍可理解。僅在使用者要求或原始素材需要時加入旁白；將旁白與錄製操作對齊，保留字幕/逐字稿，並透過試聽驗證。雲端語音、複製聲音及上傳操作均須取得相應授權。
8. 檢查開頭、中間與結尾的影格、完整播放及錯誤路徑；修正缺陷，排除密鑰、私人資料與客戶個人識別資訊。若動態效果沒有額外價值，可使用架構圖，並提供無障礙描述和原因。
9. 不要編輯 README。遵守明確的僅本機或不推送要求；否則提交、推送目前分支，並建立連結至成果物的草稿 PR。更新既有 PR 時不改變其審查狀態。
10. macOS：`open -R`；其他系統：顯示 `pwd`、絕對路徑和準確的 `cd` 指令。

## 完成條件 [#done]

回傳客戶故事、成果物類型/路徑、錄製/算繪/播放證據、已知限制，以及發布屬於範圍內時的草稿 PR 網址。僅本機輸出可以滿足明確的本機終點要求，但不能滿足發布請求。
