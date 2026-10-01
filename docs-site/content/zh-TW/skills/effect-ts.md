---
title: "/effect-ts"
description: "設定使用 Effect TypeScript 函式庫的儲存庫時使用。"
type: skill
sidebar:
  label: "/effect-ts"
---
![/effect-ts 技能圖](/diagrams/skills/effect-ts.svg)

[開啟可編輯的 Excalidraw 來源檔案](/diagrams/skills/effect-ts.excalidraw)

## 安裝 Effect

使用儲存庫的套件管理器。對於新的 v4 設定，上游使用候選發行渠道：

```sh
bun add effect@rc
```

除非使用者要求升級，否則保留既有的 Effect 版本。對於 v3 到 v4 的升級，使用 `/effect-v3-to-v4`，而不是將其視為全新安裝。

在 monorepo 中，如需從 `node_modules/effect` 存取原始碼與代理指引，可在根目錄安裝 Effect 作為開發依賴：

```sh
bun add -D effect@rc
```

在匯入 Effect 的套件中保留執行時期依賴。加入下方指令前，確認 `node_modules/effect/AGENTS.md` 與 `node_modules/effect/src` 存在；若不存在，回報已安裝的版本與缺少的檔案。

## 更新代理指令

將下方內容加入儲存庫的代理指令標準來源檔案。重新產生衍生的 `AGENTS.md` 或 `CLAUDE.md`；不要手動編輯產生的指令。

```md
# 深入了解 Effect

此儲存庫使用 Effect TypeScript 函式庫。

撰寫任何 Effect 程式碼前，完整閱讀 `node_modules/effect/AGENTS.md`，
並依需要閱讀檔案中的連結。

對於指引未涵蓋的 API 與概念，搜尋已安裝的原始碼：
`node_modules/effect/src`。
```
