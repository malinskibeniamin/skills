---
title: /setup-atlassian-workflow
description: 透過 acli 設定選用的 Jira 工作流程，以處理工作項目、狀態、留言和 PR 連結。
type: skill
sidebar:
  label: /setup-atlassian-workflow
---
![「/setup-atlassian-workflow」技能的圖表](/diagrams/skills/setup-atlassian-workflow.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/setup-atlassian-workflow.excalidraw)

透過 `acli`（Atlassian CLI）選擇性整合 Jira。可與 `gh` 搭配使用。若缺少 `acli`，則會無提示地略過 Jira 操作。

功能：建立工作項目、轉換其狀態及新增留言、連結 PR，以及搜尋和檢視內容以取得上下文。

如需 acli 指令模式，請參閱 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-atlassian-workflow/REFERENCE.md)。

## 步驟

### 1. 安裝及驗證身分
```bash
# Install: https://developer.atlassian.com/cloud/acli/guides/installation/
acli jira auth login
acli jira auth status  # verify
```

### 2. 設定 session-env.sh
```bash
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```
若要同時使用 gh 與 acli，請設定 `ISSUE_TRACKER=both`。

### 3. 驗證
- [ ] `acli jira auth status` 已通過身分驗證
- [ ] 已在工作階段環境中設定 `JIRA_PROJECT`
