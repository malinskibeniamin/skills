---
description: 透過 ldcli 檢查 LaunchDarkly 旗標：存在狀態、受眾、影響範圍、生命週期與 Integration 和 Production 清理候選。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - launchdarkly
sidebar:
  label: /launchdarkly
title: /launchdarkly
type: skill
---
![Diagram of the /launchdarkly skill](/diagrams/skills/launchdarkly.svg)

[Open the editable Excalidraw source](/diagrams/skills/launchdarkly.excalidraw)


LaunchDarkly 操作僅使用官方 `ldcli`。先讀[CLI 預檢](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/ldcli.md)，沿用現有驗證，不輸出權杖或設定。稽核要求僅允許讀取：「能否清理此旗標？」是在尋求建議，不代表授權修改鎖定條件、棄用、封存、刪除旗標或移除程式碼。

## 範圍 [#scope]

從要求或儲存庫設定確認專案。否則查看 `ldcli projects list --help`，列出專案並詢問選擇；不要預設使用 `default`。聲稱涵蓋整個帳戶之前，必須完成分頁。

**僅檢查 Integration (`integration`) 與 Production (`production`)。** 使用 `ldcli environments list` 確認確切索引鍵。必要環境缺少或無法存取表示未知，不是空白或關閉。清理判準忽略測試、staging、preproduction、development 等未使用環境。若專案採用其他索引鍵，先確認對應關係再調整命令，不得默默替換環境。

## 檢查旗標 [#inspect-a-flag]

先讀 `ldcli flags get --help`，再取得兩個環境的完整設定。回報是否存在、建立日期、封存/棄用狀態、鎖定開關及實際傳回值。區分旗標不存在與驗證、權限、專案、環境錯誤。不存在並不授權建立；僅在使用者要求時遵循[CLI 變更流程](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/ldcli.md#change)。

回答「誰能看到？」時，追蹤預設變體、指定情境、依序執行的規則、區段、百分比/實驗推出及先決條件。只有 `on: true` 不代表所有人都取得該功能。透過 `variations[].value` 解析索引，不可假設索引零表示啟用。避免不必要地揭露情境識別碼。區分功能受眾與管理介面權限、維護者。多變體旗標須先確認哪個值表示啟用，否則回報未知。

分析相依性、程式碼參照或封存時，閱讀[生命週期與證據](https://github.com/malinskibeniamin/skills/blob/v4.42.0/launchdarkly/references/lifecycle.md)。

## 統計長期啟用的清理候選 [#count-long-enabled-cleanup-candidates]

在本技能安裝目錄中，使用 Bun 執行：

```bash
bun run scripts/audit.ts --project <project-key>
```

命令會分頁取得清單，以 `--summary 0` 取得完整鎖定設定，並透過 `ldcli` 檢查指定範圍的變更歷程。不會寫入 LaunchDarkly。原始輸出僅留在本機，不得提交或放入公開 PR。

依 UTC `auditedAt` 判斷，每個未封存旗標僅計算一次，且須同時符合：

- 建立時間**嚴格早於 30 × 24 小時前**。
- **Integration 與 Production** 均開啟鎖定，所有可能的預設、規則、指定對象及正權重推出結果均傳回布林值 `true`。
- 所選設定與旗標歷程在**過去 14 × 24 小時內**沒有變更。剛好位於截止時間的變更也應排除。使用所選環境的資源指定式篩選歷程，避免未使用環境的編輯造成誤排除；影響所選範圍的共用中繼資料變更仍須計入。

未解析的先決條件、非布林啟用值、格式錯誤或缺少的鎖定設定、無法存取的歷程均屬**未知**，不是已確認候選。聲稱精確總數之前必須釐清。候選意指**移除旗標判斷，同時保留已發布功能**，不等於關閉功能，也不等於現在就能安全封存。

## 提供證據 [#return-evidence]

先提供 `candidateCount`、專案、兩個環境索引鍵、UTC 稽核時間與 `scannedCount`。列出候選索引鍵及 `createdAt`、`lastTargetingChangeAt`；後者不是全域最後變更時間。說明忽略的環境與未知項。`exactCount: null` / 結束碼 2 表示下限；結束碼 1 表示清單取得失敗，沒有可靠數量。僅彙總完整的專案報告；權限受限的權杖無法證明已涵蓋整個帳戶。

另外列出封存阻礙。快照讀取並非原子操作，採取行動前應重新稽核。完成報告後停止，除非使用者明確要求變更。
