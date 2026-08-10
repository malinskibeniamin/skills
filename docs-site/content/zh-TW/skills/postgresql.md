---
title: /postgresql
description: >-
  根據工作負載證據設計 PostgreSQL。適用於 SQL 拉取要求、結構描述、索引、交易、遷移、效能、安全性/RLS、備份/PITR、報告，以及產生的
  Drizzle 或 Jet SQL。
type: skill
sidebar:
  label: /postgresql
---
![「/postgresql」技能圖解](/diagrams/skills/postgresql.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/postgresql.excalidraw)

將「最佳 SQL」視為針對特定工作負載、版本、供應商與復原契約實測所得的合適方案。PostgreSQL 原生語意與實際產生的 SQL，其優先順序高於 ORM、查詢建構器、供應商抽象層或廠商聲明。

## 工作流程

1. **選擇模式：**撰寫/審查 SQL；建立結構描述/索引模型；協調交易/佇列；遷移；診斷/調校；操作/復原；安全性/租戶；報告；或整合 Jet。
2. **確立契約：**PostgreSQL 主要/次要版本與供應商/分支版本；擴充功能/拓撲/連線池；工作負載型態；資料量/偏斜/成長；並行處理；延遲/吞吐量 SLO；RPO/RTO；安全性；變更時段。標示未知項目。絕不虛構正式環境的事實。
3. **擷取實際狀況：**實際 SQL 與參數型態、交易邊界、結構描述/系統目錄狀態、具代表性的資料、執行計畫/統計資料、等待事件、鎖定、資源遙測資料，以及相關的部署/設定歷程。
4. **提出最小且可逆的變更：**說明證據、假設、預期效果、寫入/儲存空間/鎖定/WAL 成本、異常路徑、版本/供應商注意事項、復原或向前修正方案、中止條件，以及驗證方式。
5. **管控即時影響：**正式環境診斷預設為唯讀、有明確範圍且有時間限制。執行寫入、DDL、取消作業、角色/政策/設定變更、容錯移轉、還原或破壞性命令之前，須取得明確核准。再次確認目標。
6. **執行一項可衡量的變更：**保留完全相同的 SQL 與交易邊界。在推出期間進行觀察；達到中止條件時停止。
7. **以證據完成工作：**驗證資料庫與使用者層面的結果、記錄變更前後的觀察時段、檢查復原能力，並指出任何尚存的不確定性。

## 閱讀路徑

| 工作 | 閱讀 |
|---|---|
| 審查 SQL 拉取要求或資料庫差異 | [SQL-PR-REVIEW.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/SQL-PR-REVIEW.md)，以及差異所涉及的每份領域參考資料 |
| 查詢語意、聯結、分頁、DML | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/SQL-AUTHORING.md) |
| 型別、限制條件、索引、分割區 | [SCHEMA-INDEXES.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/SCHEMA-INDEXES.md) |
| 隔離、重試、鎖定、佇列、預算 | [TRANSACTIONS-ORCHESTRATION.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/TRANSACTIONS-ORCHESTRATION.md) |
| 線上 DDL、回填、產生的遷移 | [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/MIGRATIONS.md) |
| 執行計畫、統計資料、基準測試、效能退化 | [PERFORMANCE.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/PERFORMANCE.md) |
| 連線池、清理、WAL、複寫、高可用性、PITR | [OPERATIONS-RECOVERY.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/OPERATIONS-RECOVERY.md) |
| 角色、RLS、租戶隔離、敏感資料副本 | [SECURITY-TENANCY.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/SECURITY-TENANCY.md) |
| 維運摘要或資料庫健康狀態報告 | [WEEKLY-REPORT.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/WEEKLY-REPORT.md) |
| 支援的功能、代管供應商限制 | [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/VERSIONS-PROVIDERS.md) |
| Drizzle 產生的 SQL 或遷移 | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/SQL-AUTHORING.md)、[MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/MIGRATIONS.md)及 [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/VERSIONS-PROVIDERS.md) |
| 使用 `go-jet/jet` 的 Go 程式碼 | [GO-JET.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/GO-JET.md) |
| 證據強度或語料庫更新 | [EVIDENCE.md](https://github.com/malinskibeniamin/skills/blob/main/postgresql/references/EVIDENCE.md) |

將 PostgreSQL 19 視為預覽版本。使用版本、擴充功能、供應商、Drizzle 或 Jet 的特定行為前，請重新查閱最新文件。

## 輸出契約

傳回：**背景脈絡 -> 證據 -> 建議 -> 完整 SQL/程式碼 -> 影響與風險 -> 推出/核准關卡 -> 復原/向前修正 -> 驗證**。進行審查時，先報告正確性與安全性問題，再處理風格問題。若缺少即時證據，請提供有明確範圍的資料收集查詢，並止於提出假設。
