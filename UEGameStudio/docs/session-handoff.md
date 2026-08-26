# UEGameStudio 会话交接说明

## 交接状态

- 交接日期：2026-08-26
- 当前分支：`master`
- 当前阶段：治理、设计、功能开发、资产生产、独立验证和本地构建角色骨架均已建立
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

当前共有 28 个有效 Agent，全部为 `mode: subagent`。详细职责、权限、协作链路和能力覆盖见：

- [UEGameStudio 智能体阵容报告](agent-roster-report.md)

### 总控与决策层

- [总控编排专家](../agents/orchestration/orchestration-director.md)
- [游戏总设计师](../agents/directors/game-director.md)
- [技术总监](../agents/directors/technical-director.md)
- [游戏制作人](../agents/directors/game-producer.md)
- [游戏视听总监](../agents/directors/audiovisual-director.md)

### 学术研究层

- [人类学家](../agents/academic/academic-anthropologist.md)
- [地理学家](../agents/academic/academic-geographer.md)
- [历史学家](../agents/academic/academic-historian.md)
- [叙事学家](../agents/academic/academic-narratologist.md)
- [心理学家](../agents/academic/academic-psychologist.md)

### 专业设计层

- [首席游戏数值专家](../agents/design/lead-game-balance-designer.md)
- [首席游戏经济专家](../agents/design/lead-game-economy-designer.md)
- [关卡与任务设计专家](../agents/design/level-mission-designer.md)

### 功能开发与世界集成层

- [UE 核心系统工程师](../agents/technical/ue-core-systems-engineer.md)
- [UE 游戏玩法工程师](../agents/technical/ue-gameplay-engineer.md)
- [游戏 AI 系统工程师](../agents/technical/game-ai-engineer.md)
- [UE 游戏世界构建师](../agents/technical/ue-world-builder.md)
- [角色动画工程师](../agents/technical/character-animation-engineer.md)
- [UE UI 工程师](../agents/technical/ue-ui-engineer.md)

### 资产制作与管理层

- [游戏资产生产管理专家](../agents/production/game-asset-production-manager.md)
- [游戏视觉资产制作专家](../agents/production/game-visual-asset-artist.md)
- [UE 技术美术工程师](../agents/technical/ue-technical-art-engineer.md)
- [游戏音频技术专家](../agents/technical/game-audio-technical-specialist.md)
- [UE 工具与资产管线工程师](../agents/technical/ue-tools-pipeline-engineer.md)

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

## 2026-08-26 已实施批次

本批根据用户确认的“核心数据源与资产类型分工”完成 13 个 Agent：

| 生产域 | 已落盘 Agent |
| --- | --- |
| 纯文本公共底座 | `ue-core-systems-engineer` |
| 具体 Gameplay C++/Blueprint 与多人网络同步 | `ue-gameplay-engineer` |
| AI 决策资产 | `game-ai-engineer` |
| 关卡与任务设计 | `level-mission-designer` |
| 地图与世界组装 | `ue-world-builder` |
| 角色动画 | `character-animation-engineer` |
| UMG 与 UI | `ue-ui-engineer` |
| 视听方向 | `audiovisual-director` |
| 资产生命周期 | `game-asset-production-manager` |
| 视觉源资产 | `game-visual-asset-artist` |
| 技术美术 | `ue-technical-art-engineer` |
| 游戏音频 | `game-audio-technical-specialist` |
| 编辑器工具与资产管线 | `ue-tools-pipeline-engineer` |

原先拟合并的 `combat-ai-systems-engineer` 和 `gameplay-presentation-engineer` 不再创建：具体战斗与 GAS 业务归 `ue-gameplay-engineer`，AI 独立为 `game-ai-engineer`，表现责任按动画、UI、技术美术和音频的资产所有权拆分。

## 已确认的实施不变量

1. UE 核心系统工程师只改纯文本底座，禁止任何 `.uasset`，不拥有具体功能的网络同步。
2. Gameplay、AI、动画、UI、技术美术、音频和世界构建分别拥有列明的二进制资产类型。
3. `.uasset` 只能通过 UE Editor、Editor API、Editor Utility 或 Commandlet 修改，禁止文本或字节补丁。
4. 引用资产不转移写入权；地图、Gameplay 或工具 Agent 不能修改被引用资产内部实现。
5. 编辑器或 DCC 工具不可用时必须返回 `BLOCKED_TOOLING`，不能声称二进制资产已完成。
6. 资产生产管理专家管理 Asset ID、Brief、版本、依赖和门禁状态，不直接制作或批准资产。
7. 多人网络同步归 `ue-gameplay-engineer`，不再设计独立的 `multiplayer-network-engineer`；联机任务按实际需求启用该 Agent 的网络工作模式。
8. 关键语义、所有权、路径、Package 或验收输入缺失时返回 `BLOCKED_INPUT`；它可以与 `BLOCKED_TOOLING` 同时存在。
9. 关卡任务专家拥有任务设计语义，`ue-gameplay-engineer` 拥有运行时权威任务状态、Save/Load、Replication 与 Late Join；世界构建师只摆放实例，UI 只读展示。
10. 世界构建师只能修改授权实例的 Transform、地图组织和白名单 `Instance Editable` 参数，不得修改 Blueprint CDO、Construction Script 或类资产。
11. 逻辑资产组不作为内容对象；源文件、派生物和 UE Package 使用独立子 Asset ID，每个子对象只有一个内容写入主责。
12. 总控委派必须包含文本路径、Package、新对象、操作和外部工具白名单，并在汇合时核对实际写入清单。

## 当前需要后续修订的治理问题

1. **人类学家权限过宽**：当前使用 `"*": allow`，与其他学术专家的只读模型不一致。
2. **游戏制作人范围超界**：仍包含发布、平台认证和 LiveOps 等表述，与本地开发至构建包的边界不一致。
3. **统一注册表缺失**：当前共有 28 个 Agent，仍以目录和阵容报告为准；后续可建立单一机器可读注册表。
4. **真实工具能力待项目验证**：二进制资产角色已经定义安全边界，但具体项目仍需验证 UE Editor、Commandlet、DCC 和音频工具是否可用。

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
  - `UEGameStudio/agents/production/`
  - `UEGameStudio/agents/qa/`
  - `UEGameStudio/agents/technical/`
- 当前文档：
  - `UEGameStudio/docs/agent-roster-report.md`
  - `UEGameStudio/docs/session-handoff.md`

## 下一会话启动要求

1. 先阅读本交接说明和智能体阵容报告。
2. 扫描实际存在的 Agent 文件，不能根据 Git 删除记录推断当前阵容。
3. 使用 `skill-creator` 指导 Agent 设计或创建。
4. 核对 2026-08-26 新增 13 个 Agent 与实际项目工具能力，不重新创建旧候选 Agent。
5. 后续新增、合并或治理修订仍须先展示设计，取得用户确认后再落盘。
