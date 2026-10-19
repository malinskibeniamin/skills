---
description: 负责修复、验证、CI 和审查跟进，直到达到已授权的终点。用于 full send；full stop 或 --no-merge 保留人工合并决定。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - full send
sidebar:
  label: /full-send
title: /full-send
type: skill
---
![技能 /full-send 的图表](/diagrams/skills/full-send.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/full-send.excalidraw)

负责结果，而不只是 diff。持续处理常规修复；只有确认达到要求的终点，或外部阻碍需要用户介入时才交回。

## 授权与范围 [#authorization-and-scope]

- 明确的 `full send <任务或 PR>` 授权修复、commit、push、创建 PR、跟进 CI/审查，以及合并这一个明确的交付成果。要求解释、创建或审查本技能不等于调用它。发现技能不等于同意执行。
- 确认仓库、目标、自己负责的分支/worktree、PR/基线、验收证据与停止条件。复用已有 PR；在 Conductor 中保持检出其分支。目标不明确时，询问目标，不要擅自选择另一个 PR。
- 先前的停止要求优先：`--no-merge`、不 push、仅本地、仅草稿或 PR 就绪都会缩小授权。仅跟进 PR 不授权合并。合并前指出哪条用户指令授权了这个具体 PR。
- 保留无关改动、分支名称、仓库保护，以及由用户决定的生产、破坏性操作和安全事项。使用当前自己负责的功能分支。扩大范围需要决策；常规修复和 lease-push 不需要。
- 除非用户明确授权委派，否则在主上下文内执行。仅使用已授权的工具、账户和隔离浏览器会话；“任何必要手段”不是绕过限制的许可。

按[技能机制](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)加载依赖。
需要 full stop、托管状态检查、阻碍通知、恢复上下文，或明确请求的 Sol loop 时，阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/REFERENCE.md)。

## 修复并证明 [#fix-and-prove]

1. 检查整个分支 diff 与用户请求，而不只看 PR 描述。修改行为前先建立失败的公共契约测试；使用 [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)。
2. 以最小改动修复根因。运行仓库原生的定向测试、lint、类型检查与必需的构建/集成检查。明确显示警告及跳过的验证范围。
3. 通过真实入口进行 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)：预期流程及可信的故障/恢复路径。可见改动需捕获并检查 [PR 视觉证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)。
4. 在主上下文中执行 [review](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md)。修复具体缺陷；由证据，而不是模型的热情或审查者的赞扬，决定是否就绪。
5. 将证据绑定到 head SHA 与基线修订。任何编辑、push、rebase 或基线变化都会使受影响的证据失效；宣告成功前重新验证。

## 发布并跟进 [#publish-and-babysit]

通过 [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md) 发布，然后继续执行，而不止于一次 CI 快照。确认提交范围及远程 head 与本地 HEAD 一致。

声明已就绪前，运行[使用方仓库的托管检查](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)。在使用方仓库中恢复缺失的前置条件；保留其原有检查名称、更严格的保护策略和审批数量。未知策略不等于检查通过。

- 在当前前台会话中监控此 PR 的检查与已请求的审查。等待中意味着继续等待，不是完成。缺少 CI 不等于 CI 通过；根据仓库策略确定必需检查，不要编造全绿证明。
- 查看失败任务的日志，复现、修复、验证、commit、push，然后监控新 head。仅在有证据时重试基础设施故障；重复且不变的失败需要诊断，不是无限重跑。不要为变绿而削弱门禁。
- 使用 [resolve-pr-feedback](https://github.com/malinskibeniamin/skills/blob/main/resolve-pr-feedback/SKILL.md) 处理人工反馈与可执行的自动反馈。分页获取全部线程、评论和审查；修复或用证据反驳，回复并重新读取解决状态。旧批准与机器人的沉默不是新审查。
- 要求必需检查和审查已完成，候选版本没有适用的未解决反馈或尚未撤销的修改请求。不要自我批准或捏造认可。若审查者、权限或服务不可用，且代理已无可执行动作，通过支持的提问或输入工具通知；如果不可用，以醒目的阻塞回执和所需的确切输入结束。等待时不得替换身份、凭据或权限。
- 必要时对落后于基线、自己负责的分支执行 rebase，验证并使用 `--force-with-lease`。后续改动保持在本 PR 内。上下文达到限制前，把 head/基线、待处理运行/线程 ID、证据与下一步写入未跟踪的检查点；不要悄悄启动守护进程、cron、auto-review 设置，或承诺会话结束后继续工作。

## 最终验证与信心 [#final-verification-and-confidence]

CI 和反馈稳定后，刷新 head/基线、完整 diff、检查、审查决定、线程、草稿状态与可合并性。对这个确切候选版本进行最后一次验证：验收检查、受影响的真实入口流程及主上下文风险审查。版本变化就回到循环；旧候选版本的通过证据不够。

只有实际观察了行为、必需门禁通过、反馈已处理、没有重要缺陷或未知项，并理解上线和恢复方式时，才报告**高信心**。指出限制；不要编造百分比，或保证 PR 永远不会回归。信心不足时应收集证据或修复，不要让用户重做常规审查。

## 完成闭环 [#close-the-loop]

已授权合并时，加载[受保护的合并契约](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)，执行带预期 head 保护的托管路径。遵守基线竞争/最新状态门禁或合并队列；不要使用管理员绕过或以 auto-merge 兜底。确认托管状态：**merged** 不等于 **queued**。跟踪已授权队列项直到最终结果；队列失败或 head/基线变化时重新验证。修改结果未知时，重试前必须读取状态。

完成前确认仓库要求的合并后检查。另行发布到生产与持续监控需要独立授权。先前不合并的停止要求以经过验证的 PR 就绪为终点；等待中的检查、审查或队列不算就绪。

返回简短凭据：结果/PR URL、验证过的 head 与合并后的 merge commit、检查、审查/线程状态、有证据的信心及真实限制/阻碍。遵循仓库的意图/影响/状态契约。不要把未完成的 PR 当作完成交回，或承诺永久监督。

灵感与研究限制：[SOURCES.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/SOURCES.md)。这是原创本地流程，不是 Theo 技能的副本或背书。
