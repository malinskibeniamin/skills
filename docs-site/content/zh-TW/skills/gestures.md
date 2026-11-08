---
description: >-
  建立或修正網頁拖曳、滑動、抽屜、排序與長按互動：直接追蹤、彈性阻力、放開速度、慣性、吸附點與可中斷行為。不適用於 React Native 或 Swift
  原生開發。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - gestures
sidebar:
  label: /gestures
title: /gestures
type: skill
---
![技能 /gestures 的示意圖](/diagrams/skills/gestures.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/gestures.excalidraw)

讓直接操作跟隨指標，並在放開後以可預期的方式停穩。
改編自 Emil Kowalski；[來源與相容性](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
提問與審查只回傳指引或發現，不修改程式碼；建立與修正遵循專案的 TDD、驗證和交付規範。
載入本技能不代表獲准安裝工具或存取裝置。

## 選擇負責方 [#choose-the-owner]

檢查元件、輸入路徑、已安裝的函式庫及版本與現有 UI 封裝。
自行實作物理效果前，先重用抽屜、對話框、通知或排序基礎元件。
僅在符合現有技術堆疊與要求範圍時考慮 Vaul；保留焦點限制、Escape 關閉、焦點還原、
捲動鎖定及關閉行為。手勢不是替換可用函式庫的理由。使用 API 前先查已安裝的型別與目前官方文件。

## 手勢循環 [#gesture-loop]

1. **定義意圖。** 確定軸向、拖曳把手、邊界與吸附點、提交動作、取消路徑和非拖曳替代方式。
   適合時優先使用原生捲動或吸附。區分按下回饋與啟用；保留無障礙 click/submit 控制項。
2. **協調輸入。** 讓捲動、文字選取和可互動子元素保留原生行為。
   自訂指標處理要追蹤作用中指標 ID，只擷取負責的拖曳，並處理 `pointercancel`、
   `lostpointercapture`、額外指標與卸載。取消不得提交關閉、刪除或排序結果。
   在手勢開始前設定局部 `touch-action`，保留雙指縮放。
   手機或瀏覽器症狀請載入 [mobile-native](https://github.com/malinskibeniamin/skills/blob/main/mobile-native/SKILL.md)。
3. **直接追蹤。** 在邊界內，以元素目前可見的位置為基準，按 1:1 對應指標位移。
   使用函式庫的動態值或直接寫入 transform；追蹤時不加彈簧或轉場，不在每次移動時觸發 React 重新渲染。
   只在超出允許邊界時施加阻力。避免用每影格更新的繼承式 CSS 變數驅動大型後代樹；
   分析實際更新路徑的效能。
4. **處理放開。** 讀取負責軸上的目前位移與近期帶正負號的速度。依距離或允許方向上有意的快速甩動，
   選擇吸附或關閉目標；維持一致單位。只用來重新定位的拖曳可以放開即停。
   甩動可以使用慣性；彈簧收尾可以繼承放開速度。只保留一個放開驅動機制：
   函式庫的慣性和自訂彈簧不能互相競爭。
5. **允許重新抓取。** 再次抓取時，停止放開驅動機制、讀取目前位置，並以此重設拖曳起點。
   支援時從目前數值與速度重新定向。彈簧和 CSS 都不會自動保證交接連續。
   遮罩與縮放等關聯值應由同一個拖曳進度推導；防止過期的完成回呼在中斷後卸載元素或提交動作。
6. **以無障礙方式停穩。** 減少動態效果模式下保留必要的直接追蹤，但移除裝飾性彈跳和長距離慣性；
   迅速或立即停穩。按鈕、鍵盤和無須拖曳的指標路徑也能達成相同結果。
   長按以線性進度表示經過時間，提早放開、Escape 或失去擷取時取消，而且只提交一次。
   長按不能是執行動作的唯一方式，也不能取代確認。

門檻單位、阻力、抽屜及長按專用檢查見 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/gestures/REFERENCE.md)。
其中數字只是調整起點，不是固定規則。多元素時序與轉場設計載入 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md)；
已量測的拖曳卡頓載入 [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md)。
遵循[相依載入契約](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 驗證與交接 [#verify-and-hand-off]

測試慢拖、短距離快速甩動、反向、邊界阻力、回彈、收尾中重新抓取、巢狀捲動、子元素啟用、
取消、多指、尺寸變更、卸載和減少動態效果。檢查鍵盤與非拖曳方式是否等效，並保留焦點。
使用真實元件；只有需要判斷連續性時，才以正常速度錄製並逐影格檢查。
程式碼檢查不能證明手感、影格率或手機行為。
真機驗證需要可用且獲授權的硬體；回報缺少的涵蓋範圍，不要只為滿足本技能而對外開放開發伺服器或安裝工具。

簡要回報追蹤與放開方案、門檻和單位、取消與替代行為、實際驗證及尚未涵蓋的裝置路徑。
將審查發現與美感偏好分開。
