---
description: "选择并测试 animatic 视频的语音、渲染器、风格和拼接工具，然后保存目标仓库的配置。明确运行此技能来设置或更换工具链。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["setup animatic"]}
sidebar: {"label":"/setup-animatic"}
title: "/setup-animatic"
type: "skill"
---
![技能图 /setup-animatic](/diagrams/skills/setup-animatic.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/setup-animatic.excalidraw)

先阅读[宿主兼容规则](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md)和 [animatic 宿主边界](https://github.com/malinskibeniamin/skills/blob/main/animatic/SKILL.md)，再遵循完整的[上游设置流程](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/setup-animatic/SKILL.md)。相对引用以该源码目录为基准；`<animatic>` 是随仓库保存的相邻目录，不是本地适配器。保留分阶段访谈、语音样本、单片段构建及配置必须经过测试的要求。

## 执行范围

- 提问工具选择前检查实际机器。推荐已有且可用的选项，解释联网或离线行为及成本，然后等待用户选择。存在密钥不授权付费语音或数据披露。展示命令错误；由用户决定替代方案。
- 修改前明确选定机器及安装、缓存范围。远程设置要求用户明确指定远程目标并提供获授权的访问。在远程机器上检查和测试，不用本地测试代替。使用宿主安全凭据流程；远程无法访问是阻碍，不是创建机器、复制秘密或更改 SSH、全局设置的理由。
- 复用目标项目的工具链及已批准的依赖位置。上游辅助脚本在 `ANIMATIC_HOME` 安装自己的 npm 依赖；设置前解释此行为。一次性测试使用临时缓存。
- 先展示拟写入的内容，再将已测试的参数和环境变量名称写入目标仓库的 `docs/agents/animatic.md`。保留现有选择；秘密值只保存在环境或宿主秘密管理器中。
- 通过生成式指令的规范来源添加配置链接，然后重新生成。仅在允许时直接编辑人工维护的指令。本 harness 的 `AGENTS.md` 由 `CLAUDE.md` 和 `.agents/codex-appendix.md` 生成。不要仅为该链接新建任何指令文件。

结束时提供已测试的机器、配置路径、工具选择、语音样本和测试 MP4 的路径，以及尚存的限制。仅将技能纳入仓库不会运行设置。
