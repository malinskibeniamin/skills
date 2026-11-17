---
description: "通过允许列表、检查和持续缩小的违规基线，限制工具 API 与导入依赖。"
related: ["/skills/development-lifecycle", "/skills/tdd", "/skills/review"]
sidebar: {"label": "/constrain"}
title: "/constrain"
type: "skill"
---
![技能 /constrain 的流程图](/diagrams/skills/constrain.svg)

[Excalidraw](/diagrams/skills/constrain.excalidraw)

选择强制检查机制前，请阅读 [harness 改进规则](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#harness-improvement)。

先阅读[宿主兼容规则](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md)，再遵循完整的[上游技能](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/constrain/SKILL.md)。相对引用以其源目录为基准。保留探索、收集、访谈、构建、基线收紧、验证和记录阶段。这是显式实验草稿，不是默认的 React／状态策略，也不是安全沙箱。

## 宿主边界

- 在目标检出中限制用户选择的一个工具。提出允许列表前，检查已安装版本、检查命令、CI 和现有约束。加载或将技能纳入仓库不会启用规则、钩子或依赖。
- 除非用户明确授权委派，否则自行完成上游 Community 和 Usage 两条调查线。获准后使用全新上下文和有明确边界的任务说明，并遵循[模型路由](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md)；上游指令本身不构成授权。区分实际观察到的用法、不完整清单和推断的风险。
- 通过[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)加载 [grilling](https://github.com/malinskibeniamin/skills/blob/main/grilling/SKILL.md) 进行访谈。展示每份允许列表、路径例外、正向替代方案，以及按名称／类型匹配的覆盖缺口。修改规则或基线前，等待用户确认限制范围；示例中的限制不等于用户决定。
- 沿用目标项目的检查器与检查命令。涉及特定版本能力时，加载[一手文档研究](https://github.com/malinskibeniamin/skills/blob/main/read-the-damn-docs/SKILL.md)。Biome 项目保留 Biome，优先使用现有合适规则。能力缺失不代表可以悄悄迁移 lint 引擎或添加第二个检查器。说明必要的项目级依赖及范围。
- 基线仅记录新确认规则下的既有违规，按规则和文件划分；导入图按边记录。保留此前失败、基线、抑制控制及更严格策略；不要用 `--suppress-all` 抑制整个项目。若目标禁止基线，应报告冲突并商定合规迁移，而非关闭门禁。CI 必须拒绝新增／增加的违规及过期基线记录；收紧允许列表不得重新基线化无关债务。这是迁移棘轮，不是绕过机制。
- 证明合法代码通过、每种范围内的禁止用法在新文件中失败、已有基线文件增加违规时失败，以及已清偿债务不能回归。适用时覆盖别名、重新导出和命名空间，并披露检查器的漏检范围。运行实际总检查命令，撤销故意添加的违规，再次确认通过。源示例不能证明安装版本的行为。
- 通过目标项目人工维护的指导文件记录工具与检查命令。若 `AGENTS.md` 为生成文件，修改其规范输入并重新生成。允许列表保存在可执行配置中，而非另建文字目录。

结束时提供确认的限制、规则／基线路径、实际通过／失败／缩减证据与覆盖限制。遵循用户的交付终点；调用不授权全局安装、托管策略变更或无关重构。
