---
title: /resolving-merge-conflicts
description: 解決進行中的 Git 合併或重定基底衝突。
type: skill
sidebar:
  label: /resolving-merge-conflicts
---
![「/resolving-merge-conflicts」技能示意圖](/diagrams/skills/resolving-merge-conflicts.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/resolving-merge-conflicts.excalidraw)

當衝突情境涉及其他代理程式的分支／認領範圍時，請使用 `/agent-watchdog`；若檢閱原始來源後仍有多個可行的語意衝突解法，請使用 `/plan-arbiter`。

1. **查看合併／重定基底的目前狀態。**檢查 Git 歷史記錄和發生衝突的檔案。

2. **找出每個衝突的主要來源。**深入了解各項變更的原因及其原始意圖。閱讀提交訊息、查看 PR，並查閱原始議題／工單。

3. **解決每個衝突區塊。**盡可能保留雙方的意圖。若兩者不相容，請選擇
   符合此次合併既定目標的方案，並註明取捨。若主要來源顯示
   合併／重定基底本身有誤，或預期結果仍有歧義，請在確切的
   衝突處停止並詢問是否要中止；未經核准，絕不可自行中止。

4. 找出專案的**自動化檢查**並執行，通常依序為型別檢查、測試，然後格式化。修正合併所造成的所有問題。

5. **完成合併／重定基底。**暫存所有變更並提交。若正在進行重定基底，請繼續此流程，直到所有提交都完成重定基底。
