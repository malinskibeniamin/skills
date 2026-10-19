---
description: "修復手機網頁的檢視區、觸控、安全區域、鍵盤、滾動和 PWA 瀏覽器介面問題。用於手機特有的網頁行為，不用於 React Native 或 Swift。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["mobile native"]}
sidebar: {"label":"/mobile-native"}
title: "/mobile-native"
type: "skill"
---
![「/mobile-native」技能示意圖](/diagrams/skills/mobile-native.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/mobile-native.excalidraw)

消除瀏覽器/平臺使用障礙，但不關閉無障礙功能。
改編自 Emil Kowalski；參見[來源](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
審查請求保持只讀；修復遵循專案 TDD 和交付檢查。

## 診斷與範圍

確認報告中的手機/瀏覽器、版面配置、輸入路徑、鍵盤/PWA 模式和受支援裝置。
先復現，再修改預設值。使用能力查詢而不是 user-agent 嗅探；觸控和滑鼠可同時存在。
現有 UI 基礎元件和token仍負責各自範圍。

| 症狀 | 區域性修正 |
|---|---|
| 點選後 hover 殘留 | 用 `(hover: hover) and (pointer: fine)` 限制裝飾性 hover；保留焦點/按壓反饋 |
| 點選高亮與設計反饋衝突 | 僅在已提供等效反饋後，對控制元件區域性設定透明點選高亮 |
| 底部操作被瀏覽器介面遮擋 | 應用外殼用 `100dvh`；穩定的首屏展示區用 `100svh` |
| 輸入框獲焦時自動縮放 | 計算後的輸入文字至少 16 CSS px；保留使用者縮放 |
| 按壓反饋遲緩 | CSS `:active`/pointer-down 反饋；啟用仍使用可存取的 click/submit |
| 滾動鏈傳到面板後方 | 在實際滾動容器設定 `overscroll-behavior: contain` |
| 劉海/主屏指示條遮擋內容 | `viewport-fit=cover`，再用 `env(safe-area-inset-*, 0px)` 設定 padding |
| 拖動時選中控制元件標籤 | 僅對該控制元件設定 `user-select: none`；可讀內容仍可選擇 |
| 自定義橫向手勢與滾動衝突 | 區域性設定 `touch-action: pan-y pinch-zoom`；保留縱向滾動和雙指縮放 |
| 瀏覽器介面主題不匹配 | 主題後設資料與應用實際解析的主題一致 |

鍵盤、手勢、過度滾動和 PWA 細節參見 [PLATFORM.md](https://github.com/malinskibeniamin/skills/blob/main/mobile-native/PLATFORM.md)。
使用可選 viewport/meta 功能前，先檢查當前瀏覽器支援情況。

## 保留功能

- 保留 `width=device-width, initial-scale=1`、雙指縮放和大字號。
  不要設定 `user-scalable=no`，也不要用 `maximum-scale=1` 限制縮放。
- 將手勢歸屬限定在相應把手/介面。設定 `touch-action` 時保留雙指縮放；
  `none` 不是通用拖動修復。如果原生滾動/吸附已滿足需要，優先使用它們。
- 不要以 `pointerdown` 啟用取代 `click`：按壓反饋不同於提交操作。
  鍵盤啟用、滑動離開和 `pointercancel` 都必須正常工作。
- 根節點的過度滾動變更取決於產品。文件保留瀏覽器重新整理/滾動行為；
  只限制擁有該手勢的應用區域。
- 保留複製/選擇、連結上下文選單、焦點環和語義控制元件角色。
  監聽器保持被動，除非有範圍明確的取消需求。

## 驗證

重放觸控與鍵盤路徑、雙指縮放/200% 文字、豎屏/橫屏、開啟鍵盤、位址列展開/收起、
巢狀滾動及支援的亮色/暗色/PWA 模式。瀏覽器模擬只驗證版面配置；記錄哪些行為已在真機確認。
若沒有硬體，報告程式碼/模擬證據及剩餘手機檢查。不要僅為滿足此技能而將開發伺服器暴露到網路。

報告症狀 -> 修改的宣告 -> 觀察到的行為，以及未驗證的裝置路徑。
