---
title: /release
description: 在資訊清單、PR、標籤、GitHub、Claude 與 Codex 之間發布不可變的 frontend-skills 版本。
type: skill
sidebar:
  label: /release
---
![「/release」技能示意圖](/diagrams/skills/release.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/release.excalidraw)

發布此儲存庫，同時避免中繼資料、標籤或執行階段快取出現分歧。
版本引數必須解析為確切且穩定的 SemVer，例如 `4.34.0`。

## 1. 確立發布點

1. 擷取 `origin/main`；要求工作目錄乾淨，且目前位於以最新 main 為基礎的功能分支。
2. 讀取自最新 `v*` 標籤以來的提交與已合併 PR。根據證據撰寫發布範圍。
3. 要求 `origin/main` 的 CI 維持通過；開始版本作業前，重現並修正所有失敗。
4. 證明本機標籤、遠端標籤與 GitHub 發行版本皆不存在。任何衝突都必須停止作業。
5. 確認請求包含合併權限與發布權限。明確的
   `/release <version>` 或「cut/publish <version>」具備這些權限；規劃或討論發布則不具備。

## 2. 以測試優先方式準備

1. 先將 `evals/test-improve-release-metadata.sh` 變更為目標版本。
2. 執行該檔案，並記錄預期的 RED 發布中繼資料失敗。
3. 一併更新 `skill-manifest.json`、兩份外掛資訊清單、兩個市集、各自含日期的
   變更記錄項目、`CHANGELOG.md`，以及 README 的安裝版本固定值。
4. 若技能介面有所變更，請執行掛鉤、目錄與 AGENTS 產生器。絕不可手動編輯
   產生的 Codex 代理檔案。
5. 重新執行聚焦的發布中繼資料與封裝評估，直到達到 GREEN。

## 3. 驗證套件

執行儲存庫品質閘門、套件測試、完整 Shell 評估套件、行為掛鉤測試、
產生器漂移檢查、JSON 解析，以及 `git diff --check`。要求下列兩個真實的隔離式 CLI
安裝程式皆通過：

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

針對兩個已封裝的技能介面執行 `/dogfood`。若差異不包含任何會呈現給客戶的介面，
則略過視覺檢閱。檢閱已達固定點的差異，確認其標準、價值、韌性、
封裝方式與不可變發布風險。

## 4. 加上標籤前先完成合併

1. 透過 `/go` 提交、推送並開啟發布 PR；包含內部試用收據與計數。
2. 監控每項必要的 PR 檢查，並解決所有現有的審查討論串。
3. 僅能依據步驟 1 中確立的合併權限進行合併。
4. 擷取 main，並等待合併提交上的 main 分支 CI 通過。
5. 在該合併提交上建立並推送附註的 `v<version>`，絕不可加在功能提交上。

## 5. 發布並重新執行

1. 使用範圍明確的說明與比較連結執行 `gh release create v<version> --verify-tag --latest`。
2. 驗證遠端標籤解析至該合併提交、其檔案樹與已發布的 main 相符，且
   儲存庫的最新發行版本為新標籤。
3. 從全新的隔離式 Claude 設定加入遠端市集、安裝外掛，
   並驗證其版本及新發布的技能介面。
4. 從全新的隔離式 Codex 設定加入固定至新標籤的遠端市集、
   安裝外掛並進行相同驗證。Claude 與 Codex 的全新隔離式安裝都必須通過。
5. 僅在收到要求時升級使用者目前使用中的安裝；兩個用戶端皆需重新啟動或重新載入。

最後提供 PR 與發行版本 URL、標籤與合併識別資訊、CI 結果、安裝程式證據，以及一項
清楚可見的終端狀態。
