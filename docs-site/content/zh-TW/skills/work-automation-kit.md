---
title: /work-automation-kit
description: 安裝規劃／專案管理工作流程：規格、工單拆分、追蹤器文件、分流。
type: skill
sidebar:
  label: /work-automation-kit
---
![/work-automation-kit 技能示意圖](/diagrams/skills/work-automation-kit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/work-automation-kit.excalidraw)

安裝工作流程技能，並建立追蹤器標籤、領域情境與 ADR 配置。提示詞迴圈：探索 -> 呈現 -> 確認 -> 寫入。

## 安裝 [#install]

安裝一次：

```bash
for skill in grilling domain-modeling triage diagnosing-bugs prototype \
  implement-spec pr retro tdd codebase-design review \
  to-questionnaire to-spec to-tickets handoff writing-for-agents visual-plan \
  visual-recap plan-arbiter agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

使用 Jira 時，可透過 `acli` 選用 `setup-atlassian-workflow`。

## 專案情境 [#project-context]

閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/work-automation-kit/REFERENCE.md)，接著：

1. 檢查遠端儲存庫、代理程式規則、`docs/agents/`、詞彙表/ADR、是否已安裝 triage，以及 monorepo 跡象。
2. 先建議追蹤器；僅在選擇會導致不同流程時才詢問。
3. 已安裝 triage 時，詢問是否保留五個預設標準角色標籤（建議：是）；只有在使用者回答否時才收集覆寫值。否則略過標籤。
4. 非 monorepo 預設採用單一情境，無須詢問。僅對 monorepo 提供多重情境選項，接著確認配置。
5. 寫入前確認文件草稿；重複使用 `templates/`。
6. 選擇一個指示檔案：若 `CLAUDE.md` 存在，優先編輯該檔案；否則編輯 `AGENTS.md`；兩者皆不存在時，詢問要建立哪一個。寫入已核准的：
   - `docs/agents/issue-tracker.md`，存在 `/wayfinder` 時包含 `## Wayfinding operations`；
   - 僅在有 triage 時寫入 `docs/agents/triage-labels.md`；
   - `docs/agents/domain.md`；
   - 所選檔案的 `## Agent skills` 區塊，包含 `### Issue tracker`、摘要/連結，以及依條件加入的標籤與領域指引。
7. 寫入後驗證 `### Issue tracker` 及其連結，以及標籤、Wayfinding 操作與情境配置。
