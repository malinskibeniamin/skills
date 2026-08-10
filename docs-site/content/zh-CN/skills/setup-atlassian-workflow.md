---
title: /setup-atlassian-workflow
description: 通过 acli 配置可选启用的 Jira 工作流，用于处理工作项、状态、评论和 PR 链接。
type: skill
sidebar:
  label: /setup-atlassian-workflow
---
![／setup-atlassian-workflow 技能示意图](/diagrams/skills/setup-atlassian-workflow.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/setup-atlassian-workflow.excalidraw)

通过 `acli`（Atlassian CLI）实现可选启用的 Jira 集成。可与 `gh` 配合使用。如果缺少 `acli`，则静默跳过 Jira 操作。

功能：创建工作项、转换工作项状态、为工作项添加评论、关联 PR，以及搜索和查看上下文。

有关 acli 命令模式，请参阅 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/setup-atlassian-workflow/REFERENCE.md)。

## 步骤

### 1. 安装并进行身份验证
```bash
# Install: https://developer.atlassian.com/cloud/acli/guides/installation/
acli jira auth login
acli jira auth status  # verify
```

### 2. 配置 session-env.sh
```bash
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```
如需并行使用 gh 和 acli，请设置 `ISSUE_TRACKER=both`。

### 3. 验证
- [ ] `acli jira auth status` 已通过身份验证
- [ ] 已在会话环境中设置 `JIRA_PROJECT`
