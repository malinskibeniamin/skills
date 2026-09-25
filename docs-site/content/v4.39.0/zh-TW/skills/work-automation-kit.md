---
title: /work-automation-kit
description: 安裝規劃／專案管理工作流程：規格、工單拆分、追蹤器文件、分流。
type: skill
sidebar:
  label: /work-automation-kit
---
![/work-automation-kit 技能示意圖](/diagrams/skills/work-automation-kit.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/work-automation-kit.excalidraw)

安裝工作流程技能，並為各個儲存庫建立情境架構：

- 議題追蹤器：GitHub、GitLab、本機 Markdown、Jira/Atlassian 或其他工具。
- 分流標籤：用於標準角色的專案字串。
- 領域文件：`CONTEXT.md`、`CONTEXT-MAP.md`、ADR 配置。

由提示詞驅動。探索 -> 呈現 -> 確認 -> 寫入。

## 內含的工作流程

各安裝一次以下規劃技能組：`grilling`、`domain-modeling`、`triage`、
`diagnosing-bugs`、`prototype`、`to-questionnaire`、`to-spec`、`to-tickets`、`handoff`、
`writing-for-agents`、`visual-plan`、`visual-recap`、`plan-arbiter`、`agent-watchdog`、
`read-the-damn-docs` 和 `efficient-frontier`。

透過 `acli` 使用 Jira 時，可選擇安裝 `setup-atlassian-workflow`。

## 安裝

```bash
for skill in \
  grilling domain-modeling triage diagnosing-bugs prototype to-questionnaire to-spec \
  to-tickets handoff writing-for-agents visual-plan visual-recap plan-arbiter \
  agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

## 選用：Atlassian/Jira
如果團隊使用 Jira，請執行 `setup-atlassian-workflow`。

## 專案情境設定

詳情請參閱 `REFERENCE.md`。

1. 探索 `git remote -v`、代理程式文件、現有的 `docs/agents/`、情境文件、ADR、是否已安裝 `triage`，以及單一儲存庫多套件架構的跡象（`pnpm-workspace.yaml`、套件工作區，或已有內容的 `packages/*/src`）。
2. 先呈現建議的追蹤器；僅在選擇確實會導致不同流程時才詢問。
3. 如果已安裝 `triage`，請詢問一個問題：「保留預設的分流標籤嗎？」（建議：**是**）。如果回答是，請使用五個標準角色名稱。只有在使用者回答否時，才收集覆寫值。若未安裝 `triage`，請略過標籤設定。
4. 若沒有單一儲存庫多套件架構的跡象，請**不經詢問直接選擇單一情境**。僅針對單一儲存庫多套件架構提供**多重情境**選項，然後確認配置。
5. 寫入前先確認文件草稿。重複使用 `templates/`。
6. 以確定性方式選擇代理程式指示檔案：若 `CLAUDE.md` 存在，優先編輯該檔案；否則編輯 `AGENTS.md`；如果兩者都不存在，請詢問要建立哪一個。只更新選定的檔案，然後寫入已核准的文件：
   - 安裝 `/wayfinder` 時，`docs/agents/issue-tracker.md` 須包含 `## Wayfinding operations`
   - 僅在已安裝 `triage` 時建立 `docs/agents/triage-labels.md`
   - `docs/agents/domain.md`
   - 在選定的代理程式指示檔案中加入 `## Agent skills` 區塊；其中必須包含 `### Issue tracker`，並附上一行摘要及指向 `docs/agents/issue-tracker.md` 的連結，以及依條件加入的分流標籤與領域文件指引
7. 驗證代理程式指示區塊中存在 `### Issue tracker`，且其連結指向所選的追蹤器文件；同時也要驗證所有必要標籤、Wayfinding 操作及領域配置。
