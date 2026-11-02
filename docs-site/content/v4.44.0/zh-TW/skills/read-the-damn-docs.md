---
title: /read-the-damn-docs
description: 從主要文件研究目前的行為。適用於第三方 API、函式庫、CLI、雲端服務、API 變動、驗證、計費、安全性、遷移或部署。
type: skill
sidebar:
  label: /read-the-damn-docs
---
![/read-the-damn-docs 技能圖解](/diagrams/skills/read-the-damn-docs.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/read-the-damn-docs.excalidraw)


閱讀 `references/builder-upstream.md` 以取得完整的觸發條件清單。這是快速查核官方資訊的途徑，不需要建立研究產出。需要長期保存的多來源報告應使用內建的深度研究技能，並將附有引用的 Markdown 檔案儲存於儲存庫慣用的筆記路徑。

## 工作流程 [#workflow]

1. 識別確切的套件、版本、端點、CLI、設定、輔助工具、結構描述或產品介面。
2. 當本機文件、規格、ADR 或產生的型別定義合約時，優先閱讀這些內容。
3. 對於外部或快速變動的行為，搜尋最新的官方文件，並開啟 API 參考資料、遷移指南、版本資訊、變更記錄、SDK 原始碼或型別定義。
4. 擷取匯入、選項、預設值、重大變更、限制、權限、範例。
5. 依照儲存庫模式套用事實；不要盲目照搬範例。
6. 引用影響筆記或答案的事實來源。標出所有無法確認的內容，並說明查找過的位置。

## 強烈觸發條件 [#strong-triggers]

- 最新、目前、官方、支援、最佳實務、今天，或要求查詢。
- 安裝、升級、設定或匯入套件、SDK、模型、供應商、外掛程式或 CLI。
- 已棄用、未知選項、缺少匯出、無效設定、不支援的欄位或版本不相容。
- 難以回復的線路格式、結構描述、永久性 ID、事件、客戶可見的行為、自動化。
- 驗證、OAuth、密鑰、Webhook、個人識別資訊、加密、保留政策、遷移、重試、速率限制、配額、計費、部署。
