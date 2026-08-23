---
title: /stay-within-limits
description: 檢查明確要求之代理波次的 Claude 訂閱視窗證據。
type: skill
sidebar:
  label: /stay-within-limits
---
![「/stay-within-limits」技能示意圖](/diagrams/skills/stay-within-limits.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/stay-within-limits.excalidraw)

此項需明確使用的相容性技能會保留主機用量計量程序。模型選擇、
品質閘門與波次路由現在由 `/efficient-frontier` 和
`config/model-routing.json` 負責。

僅在主機提供最新的 Claude Code 配額快照時使用 `select-review-profile.sh`。
`ccusage` 是成本記錄，而非訂閱容量證據。若證據缺失或過時，
即代表 Claude 容量未知；請勿猜測重設時間。

請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/stay-within-limits/REFERENCE.md)，瞭解快照擷取與選擇器運作機制。回傳
觀察到的視窗及其時效性，再由 `/efficient-frontier` 選擇符合品質要求的
路由。明確使用絕不代表授予委派權限。

在此儲存庫中，請執行 `bash stay-within-limits/select-review-profile.sh`。
