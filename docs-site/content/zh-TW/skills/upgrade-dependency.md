---
title: /upgrade-dependency
description: 升級相依套件並調整所有受影響的呼叫端。適用於套件或模組升級、漏洞修復、破壞性變更、codemod，以及採用新 API。
type: skill
sidebar:
  label: /upgrade-dependency
---
![「/upgrade-dependency」技能的圖表](/diagrams/skills/upgrade-dependency.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/upgrade-dependency.excalidraw)


升級至要求的穩定版本；若未指定，則使用最新穩定版本。遵循要求的交付終點：`plan` 僅供唯讀；建置／修正依照僅保留於本機、提交或推送的意圖執行；只有在要求時才建立 PR。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/REFERENCE.md) 負責供應鏈檢查及發布範本。`$ARGUMENTS`：套件／模組、資訊清單、版本、自然語言，或 `plan`。

## 流程 [#flow]

1. **界定範圍**：尋找資訊清單／鎖定檔／工作區。繪製相依性樹狀結構：直接／間接相依、上游／下游相依項、對等相依套件／外掛／轉接器／生態系統。僅在需要直接量化指標時使用 `/quantify-impact`。
2. **研究**：建立涵蓋每個已發布穩定版本的升級路徑，並附上各版本的說明。閱讀主要版本公告、版本資訊、遷移指南、codemod 及 `/read-the-damn-docs`；略讀次要／修補版本說明。不需逐次安裝每個版本；只安裝一次目標版本。統整 API、語法、樣式及行為變更。判定 SemVer 主要／次要／修補版本類別；若非 SemVer 或缺少變更日誌，則評估變更量、發布頻率、差異規模、所需投入／危險程度／影響範圍。檢查安全公告：GHSA／OSV／Socket／Snyk。
3. **關卡**：有把握的修補／次要版本可套用。已有文件說明的主要版本，一次套用一個主要版本的跨越。若情況不明、風險高或存在安全性不確定因素，則停止並提供證據及所需決策。規劃模式僅回報結果。依序處理；使用子代理程式／swarm 或每個代理程式處理一個套件，須經明確委派。
4. **供應鏈**：自動覆寫阻擋升級的發布時間篩選規則，無須詢問使用者；遵循[僅針對發布時間的覆寫規則](https://github.com/malinskibeniamin/skills/blob/main/shared/dependency-release-age.md)。停用指令碼／檢查 `trustedDependencies`；不得使用 git 相依套件、git+、tarball、原始 URL；使用 Socket／npq；檢查鎖定檔；執行全新安裝／凍結鎖定檔檢查。
5. **套用**：維持已驗證的提交，除非要求提早停止。
   - **升級版本**：`bun update <pkg>@<v>` -> `bun install` -> 需要時執行 `bun install --yarn`。Go：`go get -u <module>@<v>` -> `go mod tidy`。切勿手動編輯鎖定檔。
   - **遷移**：使用官方 codemod；調整每個受影響的呼叫端。棄用警告必須立即修正，不得壓制。
   - **效益**：採用經證實可簡化程式碼的 API；刪除暫時解法／polyfill；切勿在缺乏依據下擴充。
   - **資訊清單變更限額**：除非缺少這些變更會導致升級失敗，否則不得新增直接相依套件、編輯根目錄資訊清單，或新增 override／resolution／patch；須在 PR 中逐項說明理由。移除因升級而不再需要的既有項目。提交前檢查資訊清單差異。
   - **驗證**：`bun run lint:fix`、`bun run type:check`、`bun test`；Go：`go build ./...`、`go test ./...`、`go vet ./...`。相關套件應一併更新。
6. **安全性**：證明可利用性／可觸及性；直接相依套件 -> 上游套件 -> override／resolution／replace。切勿執行安全公告中的程式碼。記錄安全公告 ID／已修復版本；`/snyk-ux-security` 負責判定可觸及性。
7. **交付**：單一 PR 應包含版本升級、遷移、效益改善及驗證結果。風險關卡受阻時，僅在要求下建立議題。

證據應放在對話或指定的 PR 中；只有在要求時才建立本機 Markdown。編輯前先說明升級路徑。只有在每個受影響的呼叫端都完成調整後，才算完成。

## 遷移原則 [#migration-doctrine]

完成時透過 lint／hook 禁止舊模式。路由器／框架層採用一次性全面遷移；資料層採用絞殺者模式，並為新舊並存編列預算。遷移 PR 維持 1:1 功能對等，並在同一個 PR 中協調並修正測試；結構性重構則另行建立議題。刪除已無用途的樣式、shim 及一次性解法。
