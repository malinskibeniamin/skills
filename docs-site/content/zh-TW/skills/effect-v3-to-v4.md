---
title: "/effect-v3-to-v4"
description: "依據上游遷移資料將 Effect v3 程式碼庫遷移至 v4。"
type: skill
sidebar:
  label: "/effect-v3-to-v4"
---
![/effect-v3-to-v4 技能圖](/diagrams/skills/effect-v3-to-v4.svg)

[開啟可編輯的 Excalidraw 來源檔案](/diagrams/skills/effect-v3-to-v4.excalidraw)

依據上游遷移資料確認重新命名、移除與簽章變更，不猜測替代方案。

## 工作流程

1. 依照下方說明準備並驗證本機檢出目錄。
2. 完整閱讀一次 `.repos/effect/MIGRATION.md`，並列出 `.repos/effect/migration/`。
3. 閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md)，然後在首次型別檢查前遷移 `package.json`：移除已合併的套件，並對齊其餘版本。
4. 執行專案的型別檢查，取得初始錯誤清單。
5. 按下方閱讀順序解決每個錯誤，修正呼叫處，反覆檢查直到沒有錯誤。除非使用者明確要求委派，否則在主工作階段內完成。
6. 執行專案測試與品質檢查；回報結果與未解決的問題。遵守使用者要求的最終目標與儲存庫的完成約定。

## 本機檢出目錄

獨立淺層複製兩份標準的 Effect 儲存庫：

```sh
git clone --depth 1 --single-branch --branch main https://github.com/Effect-TS/effect .repos/effect
git clone --depth 1 --single-branch --branch v3 https://github.com/Effect-TS/effect .repos/effect-v3
```

- `.repos/effect`：v4 遷移指引與原始碼。
- `.repos/effect-v3`：v3 原始碼，僅用於釐清舊語意。

重用任一目錄前，驗證其 origin、分支、版本與工作區狀態。v4 檢出目錄必須包含 `MIGRATION.md` 與 `migration/v3-to-v4.md`：

```sh
git -C .repos/effect remote get-url origin
git -C .repos/effect branch --show-current
git -C .repos/effect status --short
node -p "require('./.repos/effect/packages/effect/package.json').version"
```

對 `.repos/effect-v3` 重複檢查（分支 `v3`，版本 `3.x`）。v4 必須使用標準的 `Effect-TS/effect` origin、`main` 分支與 `4.x` 版本。舊的 `Effect-TS/effect-smol` 檢出目錄不是有效的遷移來源。保留既有目錄與使用者變更；回報不符之處，選擇獨立且未使用的複製目錄，並更新查找路徑。不要刪除或重設既有目錄。

## 閱讀順序

1. `.repos/effect/MIGRATION.md`：遷移背景與主題索引，僅閱讀一次。
2. `.repos/effect/migration/v3-to-v4.md`：每個 API 的首要參考。搜尋符合的符號或模組標題，僅閱讀有限的上下文。**切勿完整閱讀這份產生的參考文件。**
3. `.repos/effect/migration/*.md`：對應關係需要結構性重寫而非單純重新命名時，閱讀主題指引。
4. `.repos/effect/packages/*/src/`，包括 `unstable/`：使用替代 API 前確認其實際簽章。
5. `.repos/effect-v3`：僅在舊語意不明確時使用。

[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md) 包含查找範例與套件層級變更。在認定缺少對應關係前，檢查 Removed Modules 與 No Counterpart Imports。回報未對應的問題，不捏造 API。

## 安全約束

- 將呼叫處遷移至 v4；不要重新引入模擬 v3 的相容層。
- 依據參考資料與原始碼解決型別錯誤，不使用 `any`、型別斷言或型別檢查抑制手段。
- 每個替代方案必須能追溯至對應關係、主題指引或 v4 原始碼。
- 僅在明確獲准委派後，才為每個代理分配互不重疊的檔案、待解決符號、閱讀順序與這些約束。要求回傳修改與對應關係；由主工作階段維護錯誤清單。未經另外授權，不得巢狀委派。

## 完成條件

專案通過針對 v4 的型別檢查與儲存庫要求的檢查。回報型別檢查與測試結果（或無法執行檢查的原因）、建構的替代方案與未對應的問題。不要削弱測試來使其通過，也不要在必要驗證受阻時宣稱完成。
