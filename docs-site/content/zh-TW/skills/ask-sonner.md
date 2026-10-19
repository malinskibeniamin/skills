---
description: "設定、設計或排查 Sonner React 通知：Toaster 位置、promise/loading 生命週期、重複訊息、主題、portal 和自定義內容。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["ask sonner"]}
sidebar: {"label":"/ask-sonner"}
title: "/ask-sonner"
type: "skill"
---
![「/ask-sonner」技能示意圖](/diagrams/skills/ask-sonner.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/ask-sonner.excalidraw)

使用已安裝的 Sonner 版本和現有設計系統封裝。
改編自 Emil Kowalski；參見[來源](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
使用版本相關的屬性或返回值前，先閱讀已安裝型別和最新[官方文件](https://sonner.emilkowal.ski)；
這裡是指導，不是凍結的 API 規範。

## 整合

- 複用專案的 Toaster 封裝，通常位於 `@/components/ui/`。在穩定的應用根節點掛載一次，
  放在會裁剪或建立堆疊上下文的祖先之外。額外的 Toaster 需要受支援且明確的定向機制；
  不要假定存在多 Toaster 屬性。
- 在客戶端的操作邊界呼叫 `toast`。服務端返回結果，由客戶端播報。
  優先使用事件/變更操作的結果，而不是算繪/效果的副作用。
- 用 success/error/info/warning 表達結果；手動管理生命週期時用 `toast.loading` 和穩定 id，
  對於確實會完成的 promise 用 `toast.promise`。
  更新、關閉和錯誤處理模式參見 [RECIPES.md](https://github.com/malinskibeniamin/skills/blob/main/ask-sonner/RECIPES.md)。
- 重要的失敗/恢復狀態既要內聯持久顯示，也可用臨時通知。
  載入提示、樂觀啟動或被吞掉的拒絕均不代表成功。

## 診斷

| 症狀 | 修改前檢查 |
|---|---|
| 通知不出現 | Toaster 生命週期、客戶端呼叫及受支援的目標 id |
| 重複通知 | 多個 Toaster 或效果重放；穩定的操作 id |
| 一直載入 | 未完成的 promise、遺漏 catch/finally、永久顯示時長 |
| 主題錯誤 | 現有 provider/封裝傳入的已解析主題 |
| 藏在對話方塊後/被裁剪 | Portal 位置、祖先 transform/filter/overflow、堆疊層 |
| 樣式丟失 | 已安裝包的 CSS 匯出和框架樣式表生命週期 |
| 類名未生效 | 層疊/圖層和封裝配置；在所屬位置限制覆蓋範圍 |
| 手機重疊 | 受支援的偏移屬性、安全區域、鍵盤和擺放位置 |

## 樣式與驗證

先用封裝的變體/token；在源頭修正選擇器優先順序，不要散佈 `!important`。
只有已安裝 API 支援所需行為時，才考慮 `unstyled` 或 `toast.custom`。
自定義控制元件使用專案的 Button/Link 和無障礙標籤；無樣式內容不會自動獲得語義。

驗證一個操作只產生一個通知，能正確成功/拒絕並關閉，且在鍵盤、螢幕閱讀器播報、
減少動態效果、各主題和對話方塊中仍可使用。也要驗證持久錯誤路徑。
解釋/審查請求返回結論；建置/修復請求繼續透過專案測試和交付檢查。
