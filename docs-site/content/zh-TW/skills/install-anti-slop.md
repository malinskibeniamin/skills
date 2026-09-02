---
title: "/install-anti-slop"
description: "在使用 Oxlint 或 Biome 的 TypeScript 或 JavaScript 儲存庫中安裝精選的 anti-slop 檢查，包括使用 Biome 後端的 Ultracite。適用於新增 anti-slop、防止型別證據遭掩蓋，或更新既有的本機 anti-slop 設定檔。"
type: skill
sidebar:
  label: "/install-anti-slop"
---
![「/install-anti-slop」技能示意圖](/diagrams/skills/install-anti-slop.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/install-anti-slop.excalidraw)

透過儲存庫現有的程式碼檢查工具加入設定。保留其套件管理器、程式碼檢查權責、設定風格與無關工作。
絕不可只為了 anti-slop 引入第二個程式碼檢查工具。

## 選擇設定檔

1. 閱讀儲存庫指示並檢查 `git status`。檢查直接相依套件、鎖定檔，以及現有的 Biome、
   Ultracite、Oxlint 或 Vite+ 設定。
2. 只選擇一個現有後端：
   - **Oxlint：**安裝精選的三條語意規則設定檔。
   - **Biome 或使用 Biome 的 Ultracite：**安裝兩條結構規則設定檔。Biome 的
     [GritQL 外掛](https://biomejs.dev/linter/plugins/)不提供符號或作用域分析，因此此設定檔
     刻意省略 `no-widen-then-assert`；unknown 別名檢查只涵蓋直接的 `unknown` 與聯集型別中的
     直接成員，不解析別名鏈。
3. 若儲存庫未使用任何受支援的程式碼檢查工具，請保持儲存庫不變並說明原因。

## Oxlint

1. 從套件管理器或鎖定檔確認已安裝的 `oxlint` 版本。以開發相依套件形式安裝完全相同版本的
   `@oxlint/plugins`。
2. 將隨附外掛複製到目標儲存庫：

   ```bash
   node <skill-directory>/scripts/install.mjs
   ```

   預設目標路徑為 `tools/oxlint/anti-slop/`。
3. 將外掛合併到現有設定，不取代其他項目：

   ```ts
   {
     ignorePatterns: ["tools/oxlint/anti-slop/**"],
     jsPlugins: [
       { name: "anti-slop", specifier: "./tools/oxlint/anti-slop/index.ts" },
     ],
     rules: {
       "anti-slop/no-chained-type-assertions": "error",
       "anti-slop/no-unknown-type-aliases": "error",
       "anti-slop/no-widen-then-assert": "error",
     },
   }
   ```

   若使用 Vite+，請將相同項目合併到 `lint` 下，並將隨附路徑加入 `fmt.ignorePatterns`。

## Biome

1. 要求 Biome 2.5.9 或更新版本。擴充 `ultracite/biome/*` 的 Ultracite 設定符合資格。
2. 複製 GritQL 外掛：

   ```bash
   node <skill-directory>/scripts/install.mjs --biome
   ```

   預設目標路徑為 `tools/biome/anti-slop/`。
3. 將兩個路徑合併到現有的 `plugins` 陣列：

   ```json
   {
     "plugins": [
       {
         "path": "./tools/biome/anti-slop/no-chained-type-assertions.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       },
       {
         "path": "./tools/biome/anti-slop/no-direct-unknown-type-aliases.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       }
     ]
   }
   ```

## 完成

安裝程式會拒絕路徑越界與已存在的目標。必要時請提供另一個相對於儲存庫的目標路徑。僅在備份並
檢查現有 anti-slop 安裝後使用 `--force`。

執行儲存庫的程式碼檢查與型別檢查命令。除非使用者明確要求只修改設定，否則應將安裝要求視為
遷移範圍，並修正所負責程式碼中因此產生的問題。絕不可只為了通過檢查而弱化規則或新增忽略項。
請回報所選設定檔、複製路徑、相依套件與設定變更、驗證結果及未解決的問題。

## 所有權

Oxlint 核心是
[`dmmulroy/anti-slop` v0.1.2](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c)
的本機分支。複製的 `LICENSE` 保留上游 MIT 條款。Biome GritQL 設定檔是結構化改編，其較窄的契約
已在上文說明。請將安裝的檔案視為專案自有檔案，並在移植上游或 Biome 變更前進行審查。
