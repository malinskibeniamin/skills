---
title: /accessibility
description: "當 React 需要 ARIA、鍵盤、焦點、表單或巢狀控制元件無障礙支援時使用。"
type: skill
sidebar:
  label: /accessibility
---
![「/accessibility」技能示意圖](/diagrams/skills/accessibility.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/accessibility.excalidraw)

每條規則只設一個執行方：

- **Biome** 負責元素語義：圖片 `alt`、自定義控制元件鍵盤操作、組合框 ARIA 和標籤關聯。
- **React Doctor** 負責結構與命名：對話方塊、巢狀控制元件、無障礙名稱、持久標籤和帶說明的無效欄位。
- **本地鉤子** 只檢查 `tablist` 與子級 `tab` 角色，以及 `data-invalid` 與 `aria-invalid` 的配對。

不要重複檢查。豁免格式：`// allow: a11y-skip [reason]`。

## 互動約定

- 優先使用原生控制元件和可見文字。自定義可點選元素需要角色、`tabIndex` 和等效鍵盤行為。
- 二選一：可點選容器不得包含互動子元素；被動容器可包含互動子元素。不要巢狀可按壓控制元件。
- 組合框公開 `aria-expanded` 和 `aria-controls`；選項卡列表包含選項卡。
- 僅在沒有可見名稱時使用 `aria-label`；它或 `aria-labelledby` 可能替換後代文字。省略 `icon`、`button` 等冗餘詞。
- 表單控制元件具有持久標籤。用 `aria-invalid` 和當前的 `aria-describedby` 關聯可見錯誤；驗證透過後移除陳舊錯誤 ID。
- 命名不明確時檢查計算後的無障礙樹，並遵循 [WAI-ARIA 命名指南](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)。

## 視覺與焦點檢查

- 保留對比明顯的 2px 焦點指示器；懸停操作也必須可由鍵盤和觸控完成。
- DOM 順序與閱讀和 Tab 順序一致。重新排序的佈局需要鍵盤和螢幕閱讀器證據。
- 模態介面捕獲並恢復焦點，同時使背景不可互動。
- 不要僅用顏色表達狀態；同時使用文字、圖示或形狀，並用 `currentcolor` 支援強制顏色。
- 觸控目標至少為 44×44 CSS 畫素。用 `@media (hover: hover) and (pointer: fine)` 限制僅懸停效果。
- 減少動態效果時，透過透明度、顏色、文字或即時狀態變化保留反饋。
- 支援 200% 文字縮放且不丟失內容。
- 在真機或模擬器上驗證高風險移動端浮層，包括 `visualViewport`、安全區域、焦點和背景禁用。

初始配置見 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md)。
