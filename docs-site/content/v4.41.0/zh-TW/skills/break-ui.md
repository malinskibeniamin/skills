---
description: "壓力測試 UI 資料與版面配置：長文字、Unicode、縮放、窄容器、空狀態和大集合。用於診斷、dogfood、視覺審查或明確的破壞測試請求。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["break ui"]}
sidebar: {"label":"/break-ui"}
title: "/break-ui"
type: "skill"
---
![「/break-ui」技能示意圖](/diagrams/skills/break-ui.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/break-ui.excalidraw)

用苛刻但有效的資料測試真實元件。改編自 Emil Kowalski；
參見[來源](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/EMIL-SKILLS-CREDITS.md)。這是針對資料/版面配置的專項稽核，
不能代替生命週期 dogfood 或一般視覺評議。

## 執行邊界

稽核只返回證據和修復建議，不編輯正式環境元件。優先使用現有 stories、測試資料和 mock。
只有請求包含建置除錯開關或隔離工具時才建立它們；臨時材料放在 `.context/`。
明確的修復請求授權透過 TDD 和交付流程修復已確認缺陷；範圍內的常規修復無需再加核准步驟。

## 迴圈

1. 列出算繪欄位及其來源/型別、結構描述限制、可選性和集合邊界。
   缺少邊界表示未知，不是允許編造限制或修改 API。
2. 閱讀 [CATALOG.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/break-ui/CATALOG.md)，在實際契約內選取真實可信的值；
   無效/null 值僅用於本應驗證它們的邊界。不改動資料形狀、元件程式碼、token和算繪路徑。
3. 透過真實 props/mock/API 邊界注入測試資料。混合長/短/Unicode 資料、缺少的可選欄位、
   所有有效狀態和 0/1/多個元素。比較正常資料、最壞情況、空集合、單個元素和支援的數量上限。
4. 在真實容器、支援的最窄/最寬版面配置、200% 縮放以及受支援主題/方向下算繪。
   用鍵盤/觸控操作溢位區域的按鈕或連結。記錄截圖/狀態；沒有瀏覽器存取時，將 CSS 推斷標明為推斷。
5. 報告測試值、可見故障、位置、影響、建議修復和經受住測試的部分。
   識別真正的產品決策（換行/截斷、分頁/虛擬化）；保持現有慣例，不把每個邊界情況都變成重設計。
6. 對明確要求的修復，先新增失敗的公共契約迴歸測試，再修復，隨後重放所有受影響的測試資料
   和正常資料。迴歸資料僅用於測試/開發環境。

## 故障檢查點

檢查固定尺寸的 flex 兄弟元素、`min-width: 0`/`minmax(0, 1fr)`、不可斷行字串、
多行字形裁剪、字素安全的姓名首字母、地區/複數、影像回退和截斷後的完整值存取。
不要隱藏使用者需要比較的數字。

測試資料使用保留的示例域名和合成資料。不得聯絡真實客戶、將測試 HTML 作為可執行標記算繪，
或為了測試修改正式環境紀錄。只要求報告時就在報告後停止，不額外啟動持久程序或新增演示開關。
