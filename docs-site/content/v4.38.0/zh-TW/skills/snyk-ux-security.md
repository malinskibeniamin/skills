---
title: /snyk-ux-security
description: 使用 Snyk 稽核前端、Go 與 Bazel 相依套件，進行可利用性分流，並設定發布閘門。
type: skill
sidebar:
  label: /snyk-ux-security
---
![「/snyk-ux-security」技能示意圖](/diagrams/skills/snyk-ux-security.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/snyk-ux-security.excalidraw)

稽核每個路徑：掃描 -> 證明可利用性 -> 忽略或升級 -> 驗證 -> 前往要求的
端點。請先閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/snyk-ux-security/REFERENCE.md)；它會將各生態系與發布
分支導向所需的最小參考資料集。

## 輸入與工作線

`$ARGUMENTS` 接受以空格分隔的路徑、glob 模式，或一筆貼上的 Snyk 弱點。

`/snyk-ux-security apps/cloud-ui services/*/cmd`

僅產生報告的執行會在掃描與可達性分析後停止：記錄建議的清理與修復措施，
但不執行 monitor、不移除 ignore，也不編輯相依套件檔案。

偵測 `package.json`（JS）、`go.mod`（Go），以及 `MODULE.bazel` 或
`bazel/repositories.bzl`（Bazel）。在主要上下文中依序處理各路徑。如果
使用者明確委派或叫用 `/swarm`，每個獨立路徑都可以分配一條 worktree
工作線。針對 Bazel，請確認目標分支、評估向後移植，且在要求建立 PR 時使用
草稿 PR。

## 各路徑迴圈

1. **準備：**展開 glob；驗證 `snyk` 與 `gh` 的驗證狀態；解析現有的 Snyk
   專案。先從 CODEOWNERS 推斷審查者，再參考 `git log`；使用者旗標優先。
2. **重新檢視：**掃描前，重新分流每一筆 `.snyk` ignore。使用
   `snyk ignore --remove --id=<id>` 移除過期項目，並將其回報為 `cleaned-up`。
3. **掃描：**執行 `snyk test`；JS 也執行 `bun audit`，Go 則執行 `govulncheck ./...`。
   只有在要求的端點包含 Snyk 雲端更新時才執行 `snyk monitor`；它只能
   更新一個明確且現有的專案，絕不可建立新專案。
4. **證明可達性：**使用 `bun why`、`go mod why`、匯入、呼叫位置，以及
   有弱點的符號。對僅限遞移相依套件的發現執行 `/steelman`，且在進行任何
   `package.json` 修正前執行 `/diagnosing-bugs`。package.json 准入閘門
   只允許直接相依套件、可達的父套件，或經證明為最終手段的 override。
5. **忽略或升級：**
   - 預設：使用
     `snyk ignore --id=<id> --reason='<why>' --expiry=<date>`
     忽略未經證明或不可達的發現；在任何要求的交付內容中納入 `.snyk`，然後重新掃描以確認 `Ignored`。
     僅在 PR 文字中說明並不足夠。
   - 可達：使用 `/upgrade-dependency` 及其供應鏈閘門；依序優先採用直接相依套件、
     父套件、移除相依套件
     接觸面，最後才是 `resolutions`/`overrides`/`replace`。
     override 清單持續增長是個警訊，因為這會使鎖定檔膨脹，且難以隨規模擴展。
6. **套用生態系閘門：**
   - JS：稽核最低發布時間閘門、進行 Socket.dev 網頁檢查，以及針對 React 18 執行
     `bun info <pkg>@<v> peerDependencies.react`；記錄 `react19-blocked`。
     使用 `bun update`，接著執行 `bun install && bun install --yarn`。提交
     `bun.lock` 與 `yarn.lock`；Snyk IO 需要 `yarn.lock`。
     不得建立、更新或提交 `package-lock.json`；`lockfile-sync-check` 會防止檔案不同步。
   - Go：執行 `go get -u`、`go mod tidy`；一併提交 `go.mod` 與 `go.sum`。
   - Bazel：視情況更新兩份資訊清單，接著執行
     `bazel mod deps --lockfile_mode=update`；保留鏡像/FIPS/CMVP 限制。
7. **遷移與驗證：**閱讀變更記錄與 `BREAKING` 附註；將主要版本 7 -> 8 -> 9
   分成獨立且經驗證的群組逐步升級。除非使用者要求提早停止，否則將每個群組以 `refactor(deps)` 提交。
   絕不可延後真正的弱點；遇到阻礙時應上報。
   JS 執行 `bun run lint:fix`、`bun run type:check`、`bun test`，並在有建置腳本時執行建置。
   Go 執行 `go build ./...`、`go test ./...`、`go vet ./...` 與 `govulncheck ./...`。
8. **審查與要求的交付：**執行 `/resilience-review` 與 `/review`；只有在要求發布工單時，
   才對安全性技術債使用 `/to-tickets`。
   如果要求的端點包含提交或 PR，請以 `fix(deps): ...` 提交；
   只有在要求時才使用下列指令建立 PR：
   `gh pr create --assignee <triggerer> --reviewer <team-group> --label security,...`。
   使用 `gh api user --jq .login` 解析觸發者；至少需要一個 CODEOWNERS
   團隊群組，且對於忽略或 override 的情況，自動加入安全團隊。
   視情況加入 `team/`、`dismissals`、`overrides-added`、`react19-blocked` 與 `cleaned-up`
   標籤。只有在要求雲端審查時才執行 `gh workflow run`。

## 完成

回報路徑、生態系、分支、PR，以及已修正、已忽略、已覆寫、已遷移、受阻與
已向後移植的數量。絕不可執行公告中的程式碼或洩露權杖。
