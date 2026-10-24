---
description: >-
  以 Bend 定律證明商業規則，並將已發布的 TypeScript 或 Go 程式碼與已證明的模型比對。用於形式化證明、LAWS.bend 或 PROOF.bend，或必須對每個輸入都成立的驗收標準。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bend laws
sidebar:
  label: /bend-laws
title: /bend-laws
type: skill
---
![技能 /bend-laws 的圖表](/diagrams/skills/bend-laws.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/bend-laws.excalidraw)

定律是證明必須對每個輸入都滿足的驗收標準。[Bend](https://bend-lang.com) 依據規則的參考模型檢查證明。由該模型產生的表格將已發布的程式碼與定律綁定。

## 適用範圍 [#fit]

將定律用於決定金錢、存取或安全，且有限或基於整數運算的規則：模式、權限、狀態、門檻、時間窗口、捨入。字串、剖析器、JSON、浮點數（Bend 的 F32 是公理化的，而且沒有 F64）以及 UI 則改用屬性測試（fast-check、rapid）；證明它們的成本高於收益。

## 歸屬 [#ownership]

| `laws/<rule>/` 中的檔案 | 歸屬 |
|---|---|
| `LAWS.bend` | 人類。`bend-laws-guard` hook 會拒絕代理寫入；人類可透過 `BEND_LAWS_AUTHOR=1` 為工作階段開啟授權。 |
| `policy.bend`（模型）、`PROOF.bend`、`oracle.bend` | 代理 |
| `decisions.txt` | 由 `laws/check.sh --write` 產生 |

## 工作流程 [#workflow]

1. 閱讀已發布的規則及其測試。列出每個輸入及其回傳的決策。完成標準：輸入域已窮舉（有限）或其邊界已命名。
2. 在暫存目錄中以 `LAWS_draft.bend` 起草定律（匯入路徑只允許字母、數字、`_` 和 `-`），並在那裡證明它們。為每條定律寫一條淺白易懂的註解。完成標準：人類已審閱草稿並將其提交為 `LAWS.bend`。
   - 只呼叫受測函式。把定律用到的每個輔助函式都定義在 `LAWS.bend` 中，如此模型就無法透過重新定義詞彙來削弱定律。
   - 說明必須成立的內容。定律未規定的任何內容都由模型決定，因此每條禁止（「從不執行 X」）都要搭配一條要求（「只執行宣告了 Y 的內容」）。
   - 匯入的建構子要帶限定前綴和大括號：`case P.Yes{}:`。在匯入型別上裸寫 `case Yes:` 會綁定所有值，定律會空洞地通過（bendlang/bend#1328）；`check.sh` 和 hook 都會拒絕它。
3. 在 `policy.bend` 中為規則建模，保持與已發布程式碼相同的分支順序，並在 `PROOF.bend` 中以 `def Laws.<law>(...)` 證明每條定律。完成標準：`bend PROOF.bend` 輸出 `ALL PROOFS CHECK`。
4. 針對每條定律對模型做一次變異：修改該定律守護的一個分支，確認 `bend PROOF.bend` 在該定律處輸出 `SOME PROOFS FAIL`，然後還原。完成標準：每條定律都拒絕過一個變異體。沒有任何變異體能使其失敗的定律是空洞的。
5. 撰寫 `oracle.bend`，其 `main` 輸出 `# @generated` 標頭，並為每個輸入輸出一行 `<inputs> <decision>`，然後執行 `laws/check.sh --write`。
6. 比對已發布的程式碼：單元測試剖析 `decisions.txt`，並斷言已發布函式對每一列都回傳相同結果。對於有限域，還要斷言每個輸入恰好出現一次，並從程式碼的型別推導輸入域，如此新增的值會導致建置失敗。對於無界域，以屬性測試產生輸入，把定律的邊界值作為種子，並與以 `bend -o model.mjs` 編譯的模型比對。完成標準：已發布程式碼中的變異體會使測試失敗。
7. 將 [templates/install-bend.sh](https://github.com/malinskibeniamin/skills/blob/v4.40.0/bend-laws/templates/install-bend.sh) 和 [templates/check.sh](https://github.com/malinskibeniamin/skills/blob/v4.40.0/bend-laws/templates/check.sh) 複製到 `laws/`，然後新增一個執行兩者的必要 CI 工作。為 `laws/**/LAWS.bend` 和 `laws/**/decisions.txt` 新增 CODEOWNERS。完成標準：缺少 `LAWS.bend` 時工作失敗，新增後工作通過。

修改規則時：由人類編輯定律，代理更新模型和證明，執行 `check.sh --write`，然後修改已發布程式碼，直到其單元測試一致。把每個 `decisions.txt` 的 diff 都當作行為變更來審查。

撰寫 Bend 之前，先執行 `bend guide`；閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/bend-laws/REFERENCE.md)，了解語法陷阱、證明模式、`--verdict` 設定與升級。

## 護欄 [#guardrails]

- 向人類提議定律變更；絕不編輯 `LAWS.bend`，也不要繞過 hook。
- 讓 `@unsafe`、`def f?` 和外部程式碼遠離定律目錄：它們會關閉證明所依賴的可靠性。Bend 的閘門和 `check.sh` 都會拒絕它們。
- 在 `install-bend.sh` 中固定 Bend 版本；審慎升級並重新證明。
- 原始碼保留在本機：將程式碼傳送給 BendAI 或發布到 Bend hub 需要明確核准。
