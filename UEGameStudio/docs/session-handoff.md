# UEGameStudio 会话交接说明

## 交接状态

- 交接日期：2026-08-25
- 当前分支：`master`
- 当前阶段：治理、设计、验证和构建骨架已建立；即将进入核心功能开发与内容生产 Agent 设计阶段
- 项目范围：仅负责本地 UE 游戏开发至生成本地游戏构建包
- 明确排除：商店提交、平台认证、正式发布、LiveOps、社区、营销和线上运营

## 用户确认的 Agent 规范

- 所有新 Agent 保持 `mode: subagent`。
- 使用英文 kebab-case ID。
- 正文采用中文，并保持现有 Agent 的专业、工业级风格。
- Agent 设计必须明确身份、职责、决定权边界、输入契约、工作流、证据等级、门禁、输出和完成检查。
- 决策、实施和独立验证保持分离。
- 创建新 Agent 时先展示分析与设计，取得用户确认后才能落盘；用户明确说“落盘”后才写文件。
- 可以蒸馏以下仓库中适合 UEGameStudio 的能力，但不能复制其组织冗余：
  - https://github.com/jnMetaCode/agency-agents-zh/tree/main
  - https://github.com/Donchitos/Claude-Code-Game-Studios/tree/main/CCGS%20Skill%20Testing%20Framework/agents

## 当前已落盘阵容

当前共有 15 个有效 Agent，全部为 `mode: subagent`。详细职责、权限、协作链路和能力覆盖见：

- [UEGameStudio 智能体阵容报告](agent-roster-report.md)

### 总控与决策层

- [总控编排专家](../agents/orchestration/orchestration-director.md)
- [游戏总设计师](../agents/directors/game-director.md)
- [技术总监](../agents/directors/technical-director.md)
- [游戏制作人](../agents/directors/game-producer.md)

### 学术研究层

- [人类学家](../agents/academic/academic-anthropologist.md)
- [地理学家](../agents/academic/academic-geographer.md)
- [历史学家](../agents/academic/academic-historian.md)
- [叙事学家](../agents/academic/academic-narratologist.md)
- [心理学家](../agents/academic/academic-psychologist.md)

### 专业设计层

- [首席游戏数值专家](../agents/design/lead-game-balance-designer.md)
- [首席游戏经济专家](../agents/design/lead-game-economy-designer.md)

### 验证与构建层

- [资产合规与审计专家](../agents/qa/asset-compliance-auditor.md)
- [QA 测试专家](../agents/qa/qa-test-specialist.md)
- [性能剖析专家](../agents/technical/performance-profiler.md)
- [UE 游戏构建专家](../agents/technical/ue-build-engineer.md)

## 已确认的治理关系

```text
总控编排专家
├─ 游戏总设计师：决定做什么、为什么做、玩家获得什么体验
├─ 技术总监：决定如何在 UE 中实现、技术风险和预算是什么
└─ 游戏制作人：决定由谁做、何时做、按什么依赖和里程碑推进
```

游戏总设计师根据问题选择人类学家、地理学家、历史学家、叙事学家和心理学家的最小充分组合，负责统一取舍和游戏化转译。

数值与经济协作关系：

```text
游戏总设计师定义体验与机制规则
→ 首席游戏经济专家定义资源结构、价值关系和稳定目标
→ 首席游戏数值专家定义公式、参数、曲线和概率
→ 首席游戏经济专家复核宏观稳定性
→ 游戏总设计师裁决体验取舍
→ 技术总监决定 UE 实现
→ QA 验证实际构建行为
```

## 下一阶段：蒸馏后的待设计阵容

用户认为原 21 个候选 Agent 过多。当前推荐方案已经收敛为 9 个通用基线 Agent，加 1 个按项目启用的条件 Agent。

### 9 个基线 Agent

| Agent | 英文 ID | 合并能力 |
| --- | --- | --- |
| UE 游戏玩法开发专家 | `ue-gameplay-engineer` | Gameplay Framework、普通功能、玩家控制、交互、存档与进度 |
| 战斗与 AI 系统专家 | `combat-ai-systems-engineer` | 战斗、GAS、技能、状态、行为树、EQS、感知与导航 |
| 游戏表现系统专家 | `gameplay-presentation-engineer` | 动画集成、镜头、玩法 UI、HUD 和运行时反馈 |
| 关卡与任务设计专家 | `level-mission-designer` | 关卡空间、Blockout、任务、遭遇、触发器与世界状态 |
| 游戏视听总监 | `audiovisual-director` | 美术方向、声音方向、视听语言与创意验收 |
| UE 渲染与技术美术专家 | `ue-technical-art-engineer` | 渲染、光照、材质、Shader、Niagara 与资产技术规范 |
| 游戏资产制作专家 | `game-asset-production-artist` | 角色、环境、道具、纹理、材质表现与 VFX 内容 |
| 游戏音频专家 | `game-audio-specialist` | SFX、环境声、音乐、对白处理和 UE 音频集成 |
| UE 工具与资产管线专家 | `ue-tools-pipeline-engineer` | Editor Utility、Commandlet、DCC 导入、批处理与数据管线 |

### 条件 Agent

| Agent | 英文 ID | 启用条件 |
| --- | --- | --- |
| 多人网络同步专家 | `multiplayer-network-engineer` | 项目包含联机、合作或竞技功能时启用 |

## 推荐继续顺序

下一会话不要一次性设计或创建全部 Agent。建议先评审第一批核心玩法执行层：

1. `ue-gameplay-engineer`
2. `combat-ai-systems-engineer`
3. `gameplay-presentation-engineer`
4. `level-mission-designer`

设计时重点检查：

- 通用玩法专家是否过宽，以及内部工作模式如何分流。
- 战斗与 AI 合并后如何保持 GAS、AI 和数值职责边界。
- 表现系统是否仅负责运行时集成，不越权决定视听创意。
- 关卡任务专家的设计责任与 UE 实施责任如何交接。
- 哪些执行 Agent 需要 `edit`、`bash`、`lsp` 或 `external_directory`，必须遵守最小权限。

第一批设计展示并经用户确认后，再逐个或分批落盘。

## 当前需要后续修订的治理问题

1. **人类学家权限过宽**：当前使用 `"*": allow`，与其他学术专家的只读模型不一致。
2. **游戏制作人范围超界**：仍包含发布、平台认证和 LiveOps 等表述，与本地开发至构建包的边界不一致。
3. **核心实施层缺失**：当前阵容能设计、规划和验证，但尚不能承担完整游戏功能与内容生产。
4. **统一注册表缺失**：完成核心阵容后可建立单一权威 Agent 注册表；当前以目录和阵容报告为准。

未经用户确认，不要在下一会话顺带修订以上问题。

## Git 与文件安全

- 工作树当前包含大量用户既有删除、修改和未跟踪文件。
- 不得执行 `git reset --hard`、`git checkout --` 或恢复旧 Agent。
- 不得把 Git 中已删除的旧 Agent 重新纳入当前阵容。
- 只修改用户在新会话中明确授权的文件。
- 当前阶段新增或维护的 Agent 主要位于：
  - `UEGameStudio/agents/orchestration/`
  - `UEGameStudio/agents/directors/`
  - `UEGameStudio/agents/academic/`
  - `UEGameStudio/agents/design/`
  - `UEGameStudio/agents/qa/`
  - `UEGameStudio/agents/technical/`
- 当前文档：
  - `UEGameStudio/docs/agent-roster-report.md`
  - `UEGameStudio/docs/session-handoff.md`

## 下一会话启动要求

1. 先阅读本交接说明和智能体阵容报告。
2. 扫描实际存在的 Agent 文件，不能根据 Git 删除记录推断当前阵容。
3. 使用 `skill-creator` 指导 Agent 设计或创建。
4. 本轮从第一批四个核心玩法 Agent 的设计评审开始。
5. 先展示设计，不修改文件，等待用户确认。

