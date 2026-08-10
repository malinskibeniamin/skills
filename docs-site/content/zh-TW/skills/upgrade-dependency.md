---
title: /upgrade-dependency
description: 升級相依套件並調整所有受影響的呼叫端。適用於套件或模組升級、漏洞修復、破壞性變更、codemod，以及採用新 API。
type: skill
sidebar:
  label: /upgrade-dependency
---
![「/upgrade-dependency」技能的圖表](/diagrams/skills/upgrade-dependency.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/upgrade-dependency.excalidraw)

升級至指定的穩定版本；若未指定，則使用最新穩定版本。調整受影響的呼叫端。
遵循指定的交付終點：`plan` 僅供唯讀；建置／修正會在本機變更通過驗證後停止；
只有在明確要求時，才會提交、推送或建立 PR。
當觸發相關分支時，請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/REFERENCE.md)，以取得供應鏈檢查及議題／PR 範本。

輸入：`$ARGUMENTS` = 套件／模組、資訊清單路徑、目標版本、自然語言，或 `plan`。
## 流程

1. **界定範圍**：偵測資訊清單／鎖定檔（`package.json`、`bun.lock`、`go.mod`）及工作區。繪製相依性樹狀結構：直接／間接相依、上游／下游相依項、對等相依套件／外掛／轉接器。執行 `/quantify-impact` 以取得直接量化指標。

2. **研究會改變行為的內容**：建立升級路徑：從目前安裝版本到目標版本之間的每個已發布穩定版本，並附上各版本的行為說明；僅在主要版本／破壞性變更的跨越點深入閱讀（遷移指南、codemod、公告、`/read-the-damn-docs`）；略讀次要版本，跳過修補版本的考古式追查；只安裝一次目標版本，不需逐次安裝每個中間版本。判定 SemVer 類別；若非 SemVer／缺少變更日誌，則評估變更量、發布頻率、差異規模及影響範圍。檢查安全公告（Snyk／GHSA／OSV／Socket／CVE）。

3. **關卡**：有把握的修補／次要版本 -> 套用。已有文件說明的主要版本 -> 一次套用一個主要版本的跨越。若為非 SemVer、遷移方式不明、影響範圍大，或存在安全性不確定因素 -> 停止並提供
   證據及所需決策。`plan` -> 在對話中回報路徑及風險。依序處理
   各套件；明確委派或 `/swarm` 可分派互相獨立的工作軌。

4. **套用** -- 前置檢查：版本至少發布 7–30 天、停用指令碼／檢查 `trustedDependencies`、不得使用 git／tarball／原始 URL 相依套件、若有 Socket／npq 則執行、檢查鎖定檔、執行全新安裝。維持個別且已驗證的變更群組；僅在要求時分別提交：
   a. **升級版本**：`bun update <pkg>@<v>` -> `bun install` -> 當 `yarn.lock`／Snyk 需要時執行 `bun install --yarn`。Go：`go get -u <module>@<v>` -> `go mod tidy`。切勿手動編輯鎖定檔。
   b. **遷移**：使用官方 codemod；統整每個受影響呼叫端的 API／語法／樣式／行為變更。這次升級產生的棄用警告必須立即修正，不得壓制。
   c. **效益**：若變更日誌特別介紹的 API 可簡化既有程式碼，便予以採用 -- 刪除被迫採用的暫時解法及過時的 polyfill；精簡或強化程式碼，切勿在缺乏依據下擴充。
   d. **驗證**：`bun run lint:fix` -> `bun run type:check` -> `bun test`。Go：`go build ./...` -> `go test ./...` -> `go vet ./...`。相關套件應一併更新。

5. **安全性**：保留對可利用性的分析；修復優先順序：直接相依套件升級 > 上游套件升級 > override／resolution／replace。切勿執行安全公告中的程式碼。PR 內文須記錄安全公告 ID 及已修復版本。`/snyk-ux-security` 負責判定可觸及性。

6. **指定的交付方式**：單一 PR 應包含版本升級、遷移及效益改善，並記錄驗證結果。
   風險關卡受阻時，僅在要求下建立議題。

## 規則

證據應放在對話或指定的 PR 中；只有在要求時才建立本機 Markdown。編輯前先說明
升級路徑。對主要版本／非 SemVer 變更，須閱讀變更日誌及版本資訊。只有在
每個受影響的呼叫端都完成調整後，才算完成。JS 與 Go 均為第一級支援對象。

## 遷移原則

完成即凍結：完成遷移的 PR 必須禁止舊的 import／模式（透過 lint／hook），否則 LLM 作者可能使其死灰復燃。路由器／框架層採用一次性全面遷移；資料層採用絞殺者模式（新舊並存 -- 須為此編列預算）。遷移 PR 專注於遷移：維持 1:1 功能對等、在同一個 PR 中協調並修正測試，結構性重構則另行建立議題。退出時刪除已無用途的層（舊版樣式、shim、一次性解法）。
