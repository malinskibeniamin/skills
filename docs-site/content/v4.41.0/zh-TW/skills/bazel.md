---
description: >-
  建置、測試與診斷涵蓋 Go、C++、TypeScript 和 React 的 Bazel 單一儲存庫。適用於
  BUILD/Starlark、Bzlmod、工具鏈、快取、開發循環、受影響目標的 CI 與發布產物。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bazel
sidebar:
  label: /bazel
title: /bazel
type: skill
---
![/bazel 技能示意圖](/diagrams/skills/bazel.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/bazel.excalidraw)

讓宣告的建置圖重現所需行為。儲存庫維護的包裝腳本、巨集、固定版本與 CI 政策
優先於這些通用指引。

## 確定建置契約 [#establish-the-build-contract]

- 確認 Bazel 工作區根目錄、`.bazelversion`、根 `MODULE.bazel`、適用的
  `.bazelrc` 匯入、元件說明和實際 CI 進入點。透過儲存庫的 Bazelisk 或包裝
  腳本使用固定的 Bazel 版本，不要使用全域升級的執行檔。個別電腦的覆寫設定
  放在現有且被 Git 忽略的使用者 rc 檔案中。
  依這些固定版本驗證新旗標、Starlark 註記語法與規則；會議示範與路線圖項目
  不是已發布的 API 契約。
- 升級版本、排查隨附 JDK 的信任問題或檢查 Bazel 10 相容性時，閱讀
  [版本指引](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/releases.md)。
  將同一版本線的修補更新與主動選用的候選版本測試分開。
- 區分**哪些部分有 BUILD 檔案**與**哪些部分目前由 Bazel 管理**。產生的目標
  不能證明 CI 已採用它們。檢查已合併的原始碼，而不是中間提交、推行草案或
  前身儲存庫。
- 維持單一儲存庫的一個根模組邊界。在根目錄集中宣告相依項與工具鏈；新增巢狀
  `MODULE.bazel` 可能讓萬用字元探索略過子樹。將刻意分離的工作區視為獨立
  建置，不要順便合併。
- 對 Go/Task/Gazelle 目錄樹，閱讀 [Go 單一儲存庫](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/go-monorepo.md)。
  對 C++、交叉編譯、加速器或透過建置圖選取的整合，閱讀
  [C++ 單一儲存庫](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/cpp-monorepo.md)。
  對前端或 Node 整合，閱讀 [TypeScript 與 React](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/typescript-react.md)。只載入相關分支說明。
- 對多應用程式拓撲、本機協調、受影響目標 CI、快取、執行或選擇性發布，閱讀
  [單一儲存庫規模化](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/monorepo-scale.md)。
  研究採用方案或選擇專案範本時，閱讀固定版本的
  [社群範例及其限制](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/community-examples.md)。

## 選擇增量循環 [#choose-the-incremental-loop]

分清動作重用、根據 Git 選取目標、瀏覽器 HMR 與部署。Bazel 負責已宣告的建置、
測試與產物相依關係；前端工具負責 Fast Refresh，協調機制負責服務生命週期與
發布。只啟動本機應用程式需要的相依閉包，不要啟動所有應用程式。保留現有框架
和套件管理器；先證明一個垂直切片可用，再將其標準化。在承諾加速之前，測量冷
建置、暖建置、無變更建置與代表性修改；加入 Bazel 本身不能證明效能改善。

## 編輯前找到負責入口 [#find-the-owner-before-editing]

閱讀最近的 BUILD 檔案及其載入的巨集。尋找現有標籤，不要猜測執行檔、映像檔
或測試目標。明確宣告相依項、產生的原始碼與執行階段檔案邊；`deps` 和測試
`data` 解決的是不同問題。

依問題選擇建置圖（[查詢語意](https://bazel.build/query/cquery)、
[動作圖](https://bazel.build/query/aquery)）：

| 問題 | 工具 |
|---|---|
| 有哪些測試或使用端，哪些可以連到某個檔案？ | `query`、`tests(...)`、有限範圍的 `rdeps(...)` |
| 哪個 `select()` 分支、平台或相依項生效？ | 使用失敗建置設定的 `cquery` |
| 動作使用哪個編譯器、旗標、輸入與輸出？ | 使用相同設定的 `aquery` |

`query` 包含可能的設定分支，不能證明目標已執行。`aquery` 描述動作，但不會將
產生的輸入實體化。部分輸出或錯誤表示證據不完整，絕不等同於沒有受影響目標。

## 修改並驗證 [#change-and-verify]

1. 以失敗目標或公開契約測試重現缺陷。僅修改建置時，可將失敗的分析、編譯、
   格式檢查或規則測試作為 RED。
2. 編輯負責的原始檔、產生器輸入或巨集。使用儲存庫的產生器重新產生衍生 BUILD
   檔案，使用其格式化工具並檢查差異。保留刻意設定的可見性、相容性、標籤與資料。
3. 修改相依項時，視需要更新具權威性的語言清單或根模組，再執行規定的模組整理
   或鎖定檔更新。將產生的中繼資料一起提交。遵守 CI 的鎖定檔模式；在本機修正
   過期鎖定檔，不要刪除它們或放寬 CI。參閱[鎖定檔模式](https://bazel.build/external/lockfile)。
4. 在相關設定下建置與測試最小的變更目標，再驗證受影響的使用端。共用巨集、根
   相依項、工具鏈與設定的變更，需要儲存庫規定的更廣測試矩陣。平台不相容、
   手動執行與被篩掉的整合目標不算通過；明確列出未測試的分支。

## 診斷時保留證據 [#diagnose-without-destroying-the-evidence]

- 重播完全相同的標籤、設定、目標平台與執行平台。使用 `--announce_rc` 和
  `--verbose_failures`；僅在重現失敗時加入 `--sandbox_debug`。修改旗標前，
  檢查合併後的 rc 選項與動作輸入。
- 區分分析或標籤錯誤、儲存庫擷取或驗證失敗、工具鏈或平台不符、沙箱或 runfiles
  失敗、快取傳輸問題與測試失敗。修正負責的層，不要全域停用沙箱、警告、
  sanitizer 或相容性限制。
- 遇到 macOS 符號連結逃逸、原生工具路徑解析、沙箱建立成本，或透過 REAPI 在本機
  虛擬機中執行的問題時，閱讀[本機執行](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/local-execution.md)。
- 區分儲存庫下載快取、動作快取與遠端執行。遠端快取不是遠端執行器。遵循已提交
  的快取與上傳政策；不要將私人端點或憑證寫進受版本控制的設定。
- 起初保留暖快取。`clean`、`expunge`、刪除鎖定檔或新增輸出基底目錄都不是
  第一線修正方式。如需隔離，說明假設，並只重設自己負責的重現情境。
- 確實需要重新執行測試時，限定範圍並使用 `--nocache_test_results`。否則，快取結果
  對已宣告的輸入仍是有效證據；如實區分快取和實際執行。採用最少下載策略時，
  輸出使用端可能需要明確取得實體檔案（[遠端快取](https://bazel.build/remote/caching)）。

回報變更的圖契約、確切目標、設定與檢查結果，包括略過或受阻的分支。建置映像檔
不代表獲准推送或部署它。關於來源與更新限制，閱讀
[研究依據](https://github.com/malinskibeniamin/skills/blob/v4.41.0/bazel/references/research-basis.md)。
