---
title: /accessibility
description: 適用於 ARIA、鍵盤操作、焦點、表單與巢狀控制項的 React 無障礙設計。建置互動式元件或修正無障礙問題時使用。
type: skill
sidebar:
  label: /accessibility
---
![「/accessibility」技能示意圖](/diagrams/skills/accessibility.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/accessibility.excalidraw)

## 可偵測的問題

檢查工作分由三個負責方執行，每項規則僅由一方負責：

- **Biome（ultracite 預設集）** -- 單一元素規則：`<img>` 替代文字（`a11y/useAltText`）、可點擊的 `<div>`/`<span>` 鍵盤支援（`a11y/useKeyWithClickEvents` 及相關規則）、下拉式組合方塊必要的 ARIA（`a11y/useAriaPropsForRole`）、標籤關聯（`a11y/noLabelWithoutControl`）
- **React Doctor（Stop hook）** -- 結構規則：對話方塊的無障礙名稱（`react-doctor/dialog-has-accessible-name`）、巢狀互動元素（`react-doctor/html-no-nested-interactive`）、如 `Search icon` 等贅述名稱（`react-doctor/img-redundant-alt`）、以預留位置文字取代標籤（`react-doctor/label-has-associated-control`），以及缺少錯誤說明的無效控制項（`react-doctor/no-aria-invalid-without-description`）
- **此 hook** -- 僅檢查兩個引擎皆無法表達的跨屬性配對：`role="tablist"` 必須有 `role="tab"` 子元素；`data-invalid`（僅供 CSS 使用）必須搭配 `aria-invalid`

略過方式：`// allow: a11y-skip [reason]`

## 禁止巢狀可按壓元素

互動式元件只能採用一種模式，絕不可同時採用兩種：

**模式 A：容器可點擊** -- 不得包含互動式子元素。
```tsx
<ListCard onClick={handleSelect}>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <ChevronRightIcon /> {/* visual indicator only, not a button */}
</ListCard>
```

**模式 B：子元素可互動** -- 容器不可點擊。
```tsx
<ListCard>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <Button variant="ghost" size="icon"><MoreVerticalIcon /></Button>
    </DropdownMenuTrigger>
  </DropdownMenu>
</ListCard>
```

原因：點擊目標不明確、事件冒泡錯誤、螢幕閱讀器無法傳達互動模式，以及行動裝置上的觸控目標互相重疊。

## 無障礙名稱與說明

- 優先使用可見文字與原生命名方式（`<label>`、按鈕／連結內容、圖說），而非
  ARIA。僅在沒有可見名稱時使用 `aria-label`，例如只有圖示的按鈕；
  `aria-label` 或 `aria-labelledby` 可能會在無障礙樹中取代後代文字。
- 確保 `aria-describedby` 參照保持最新。驗證錯誤
  清除時，請移除過時的錯誤 ID；被參照的隱藏內容仍可能成為無障礙說明。
- 當命名或說明行為不明確時，請檢查計算後的無障礙樹。
  請遵循 [WAI-ARIA 命名指南](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)。

## 視覺檢查清單

- [ ] 所有互動式元素的焦點環皆清晰可見（至少 2px，且顏色具對比）
- [ ] 懸停與焦點樣式一致（不可只有滑鼠操作才有提示）
- [ ] 不以顏色作為傳達資訊的唯一方式
- [ ] DOM 順序與閱讀及 Tab 鍵巡覽順序一致；若使用 CSS 調整視覺順序，須有鍵盤與螢幕閱讀器的驗證依據
- [ ] 無障礙名稱符合畫面上呈現的意圖與動作；名稱中不得包含「圖示」、「按鈕」或「圖片」
- [ ] 表單欄位具有持續顯示的標籤；預留位置文字僅用於提供範例或格式提示
- [ ] 對話方塊、側邊面板與彈出式視窗會限制焦點範圍、在關閉時將焦點移回原處，並在模態狀態下讓背景無法互動
- [ ] 錯誤、已選取、警告與成功狀態絕不只依賴顏色表示；應將顏色與文字、圖示或形狀搭配使用
- [ ] 觸控目標至少為 44x44 CSS 像素
- [ ] 動畫遵循 `prefers-reduced-motion`
- [ ] 減少動態效果時，應透過不透明度、顏色、文字或即時狀態變更保留必要回饋，而非使用大幅移動
- [ ] 僅懸停時生效的效果，應透過 `@media (hover: hover) and (pointer: fine)` 限制於適合的裝置
- [ ] 行動版抽屜／側邊面板應透過 `visualViewport`、安全區域間距、焦點限制、焦點返回與背景不可互動機制處理虛擬鍵盤
- [ ] 高風險行動裝置互動須有實體裝置或模擬器的驗證依據，尤其是抽屜、側邊面板、滑動手勢及長按破壞性操作
- [ ] `forced-colors`／高對比模式：SVG 填色使用 `currentcolor`
- [ ] 文字放大至 200% 時不會遺失內容

初始設定（安裝、AXE 測試資料、hook 設定）：請參閱 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md)。
