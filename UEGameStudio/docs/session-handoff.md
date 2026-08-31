# UEGameStudio 会话交接说明

## 交接状态

- 交接日期：2026-08-31
- 当前分支：`master`
- 交接基线：`0db7340 refactor: harden agent governance and generalize anthropology`
- 远端状态：交接生成前 `master` 与 `origin/master` 同步于 `0db7340`；当前批次为未提交差异
- 当前阶段：可安装成品、治理规则、递归任务计划、正式项目验证方法和安装回归均已建立；统一机器可读注册表已落地，本地化/LQA 与安全专业能力缺口已补齐，当前阵容 30 Agent（28 基线 + 2 新增），可接入真实 UE 项目验证
- 项目范围：仅负责本地 UE 游戏开发至生成本地游戏构建包
- 明确排除：商店提交、平台认证、正式发布、LiveOps、社区、营销和线上运营
- 当前活动任务：已完成统一注册表与 `localization-lqa-specialist`、`security-engineer` 落盘批次；未提交、未推送

## 当前可交付内容

| 路径 | 当前用途 |
| --- | --- |
| `UEGameStudio/agents/` | 30 个可安装 opencode subagent，按 7 个专业层级组织 |
| `UEGameStudio/AGENTS.md` | 部署到目标项目的统一 UEGameStudio 协作规则 |
| `UEGameStudio/INSTALL.md` | 安装、升级、验证和卸载说明 |
| `UEGameStudio/scripts/install.ps1` | 幂等安装与 `opencode.json` 安全合并 |
| `UEGameStudio/scripts/test-install.ps1` | 安装器隔离回归测试 |
| `UEGameStudio/docs/formal-project-validation.md` | 正式 UE 项目的全阵容实测、故障注入和自动修复方法 |
| `UEGameStudio/docs/agent-registry.json` | 机器可读权威注册表（30 条），由 `scripts/verify-registry.ps1` 与实际 Agent frontmatter 双向校验 |
| `UEGameStudio/docs/agent-roster-report.md` | 当前阵容、权限、协作链和治理问题报告 |

## 用户确认的 Agent 规范

- 所有新 Agent 保持 `mode: subagent`。
- 使用英文 kebab-case ID。
- 正文采用中文，并保持现有 Agent 的专业、工业级风格。
- Agent 设计必须明确身份、职责、决定权边界、输入契约、工作流、证据等级、门禁、输出和完成检查。
- 总控收到任何新任务后的首次响应必须先提问，不得读取项目、制定计划、委派或实施。
- 总控只有在需求理解置信度达到至少 98%、需求理解摘要经用户明确确认后，才能读取实际阵容和项目上下文并开始制定任务计划。
- 总控制定计划期间遇到会改变计划的不确定项必须暂停并提问；若答案改变已确认需求，必须重置需求置信度和确认状态。
- 总控在 `PLAN_READY` 后将计划写入 `.opencode/task-plans/<Plan-ID>/`，以 `M0` 为根使用 `M0.1`、`M0.1.1` 等稳定路径式编号递归展开。
- 总控只能编辑 `.opencode/task-plans/**`；任务树写入属于治理状态维护，不授予源码、配置、资产或普通项目文档写入权。
- 决策、实施和独立验证保持分离。
- 创建新 Agent 时先展示分析与设计，取得用户确认后才能落盘；用户明确说“落盘”后才写文件。
- 可以蒸馏以下仓库中适合 UEGameStudio 的能力，但不能复制其组织冗余：
  - https://github.com/jnMetaCode/agency-agents-zh/tree/main
  - https://github.com/Donchitos/Claude-Code-Game-Studios/tree/main/CCGS%20Skill%20Testing%20Framework/agents

## 当前已落盘阵容

当前共有 30 个有效 Agent，全部为 `mode: subagent`。详细职责、权限、协作链路和能力覆盖见：

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
- [本地化与 LQA 专家](../agents/production/localization-lqa-specialist.md)
- [UE 技术美术工程师](../agents/technical/ue-technical-art-engineer.md)
- [游戏音频技术专家](../agents/technical/game-audio-technical-specialist.md)
- [UE 工具与资产管线工程师](../agents/technical/ue-tools-pipeline-engineer.md)

### 验证与构建层

- [资产合规与审计专家](../agents/qa/asset-compliance-auditor.md)
- [安全专业评审](../agents/qa/security-engineer.md)
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

游戏总设计师根据问题选择人类学家、地理学家、历史学家、叙事学家和心理学家的最小充分组合，负责向通用学术专家注入游戏应用语境、统一取舍并完成游戏化转译。人类学家不因被游戏项目调用而取得游戏设计或 UE 实现职责。

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

1. 总控收到任何新任务后必须先提问；首次响应不得读取项目、制定计划、拆分任务、委派 Agent 或开始实施。
2. 总控只有在需求理解置信度达到至少 98% 并取得用户对当前需求摘要的明确确认后，才能读取实际阵容与项目上下文并开始规划。
3. 总控规划期间遇到会影响主责、依赖、范围、写入边界、门禁或验收方式的不确定项时必须暂停并提问；答案改变需求时须重置确认并重新澄清。
4. 总控在 `PLAN_READY` 后生成稳定 Plan ID，将完整任务计划落盘为以 `M0` 为根的递归树；子节点使用父 ID 追加序号，节点 ID 签发后不得重编号或复用。
5. 总控通过细粒度 `edit` 规则只能维护 `.opencode/task-plans/**`；有子任务的节点才创建同名目录，父子包含关系与显式执行依赖必须分开记录。
6. UE 核心系统工程师只改纯文本底座，禁止任何 `.uasset`，不拥有具体功能的网络同步。
7. Gameplay、AI、动画、UI、技术美术、音频和世界构建分别拥有列明的二进制资产类型。
8. `.uasset` 只能通过 UE Editor、Editor API、Editor Utility 或 Commandlet 修改，禁止文本或字节补丁。
9. 引用资产不转移写入权；地图、Gameplay 或工具 Agent 不能修改被引用资产内部实现。
10. 编辑器或 DCC 工具不可用时必须返回 `BLOCKED_TOOLING`，不能声称二进制资产已完成。
11. 资产生产管理专家管理 Asset ID、Brief、版本、依赖和门禁状态，不直接制作或批准资产。
12. 多人网络同步归 `ue-gameplay-engineer`，不再设计独立的 `multiplayer-network-engineer`；联机任务按实际需求启用该 Agent 的网络工作模式。
13. 关键语义、所有权、路径、Package 或验收输入缺失时返回 `BLOCKED_INPUT`；它可以与 `BLOCKED_TOOLING` 同时存在。
14. 关卡任务专家拥有任务设计语义，`ue-gameplay-engineer` 拥有运行时权威任务状态、Save/Load、Replication 与 Late Join；世界构建师只摆放实例，UI 只读展示。
15. 世界构建师只能修改授权实例的 Transform、地图组织和白名单 `Instance Editable` 参数，不得修改 Blueprint CDO、Construction Script 或类资产。
16. 逻辑资产组不作为内容对象；源文件、派生物和 UE Package 使用独立子 Asset ID，每个子对象只有一个内容写入主责。
17. 总控委派必须包含文本路径、Package、新对象、操作和外部工具白名单，并在汇合时核对实际写入清单。

## 2026-08-27 已实施治理修订

总控编排专家已加入强制需求澄清与规划门禁：

1. 每个新任务的首次响应必须先提问，且该轮不得读取项目、规划、委派或实施。
2. 需求理解置信度达到至少 98% 后，仍须展示需求理解摘要并取得用户明确确认。
3. 只有当前需求摘要被确认后，才能读取实际阵容与项目上下文并制定任务计划。
4. 规划期间发现会改变计划的不确定项时必须暂停并提问；答案改变需求时，旧确认和计划草案失效。
5. 门禁状态统一为 `REQUIREMENTS_CLARIFICATION`、`REQUIREMENTS_CONFIRMATION`、`PLANNING_CLARIFICATION` 和 `PLAN_READY`。
6. `PLAN_READY` 后由总控生成 `YYYYMMDD-HHMMSS-<slug>` 格式的 Plan ID，并把任务计划写入 `.opencode/task-plans/<Plan-ID>/`。
7. 任务树以 `M0` 为根，使用 `M0.1`、`M0.1.1` 等稳定路径式编号递归展开；废弃节点保留并标记 `CANCELLED` 或 `SUPERSEDED`。
8. 总控新增的 `edit` 权限采用路径级默认拒绝，只允许 `.opencode/task-plans/**`；不开放 Bash，也不扩大项目实施权限。

## 2026-08-28 全阵容审计整改

本轮未新增或删除 Agent，仍以 28 个实际 `mode: subagent` 文件为准。确定性整改包括：

- `academic-anthropologist` 已按学术专家公共结构重构，权限从 `"*": allow` 收敛为默认拒绝的只读研究模型；补齐咨询边界、证据等级、`BLOCKED_UNVERIFIED`、现实文化借用/授权敏感性、内部差异和人的能动性。
- `game-producer` 已严格限制为本地开发与本地游戏构建包，生产路由只使用当前实际 Agent ID；本地化/LQA、安全等无专职角色的领域明确登记为 `CAPABILITY_GAP`，不再虚构负责人。
- `technical-director` 已明确多人网络同步与 GAS 业务归 `ue-gameplay-engineer`，安全专业为当前能力缺口，而非独立在编 Agent。
- `audiovisual-director` 已补充真实 Agent 的主责/会签路由、视听可访问性和参考 Provenance/授权交接；不扩大为资产实施者。
- `level-mission-designer` 的编辑权仅用于任务授权的纯文本 Level/Mission Brief 与设计交付路径，禁止任何 `.uasset`、`.umap` 或生产地图修改。
- `game-asset-production-manager` 的编辑权仅用于授权的纯文本 Manifest、Brief、Provenance 和状态登记；Bash 仅作授权清点与只读核验，外部目录仅限显式白名单，不修改任何内容资产。
- `ue-ui-engineer` 与 `game-audio-technical-specialist` 已补充按项目适用的字幕、对白动态、对比度、非纯色觉编码、焦点、缩放/安全区和替代信息通道契约；没有测试环境时不得宣称未受支持的辅助技术兼容性。
- `game-director` 仅把用户或项目已给定的商业模式作为本地设计约束，不得据此扩展真实货币、商店或线上服务范围。
- `orchestration-director` 保留首次提问、98% 需求确认和递归 `M0` 规则，并补充 Plan ID 时区记录、ISO 8601 时间字段和同秒同名冲突后缀。

本轮明确未做：不建立机器可读 Registry，不批量调整其余 Agent 的 Bash 权限，不新增本地化/LQA 或安全 Agent，不修改安装器与验证脚本。

本轮落盘后验证：实际扫描仍为 28 个 Agent，全部 `mode: subagent` 且默认 `"*": deny`；5 个 `task: allow` Agent 的反引号路由未发现不存在 ID；12 个本轮目标文件均为 LF；两份治理文档的相对链接有效；`scripts/test-install.ps1` 通过 28-Agent 复制、模板排除、配置合并、新配置与幂等回归。以上不替代真实 UE/DCC/音频/性能/构建环境验证。

## 2026-08-29 人类学家通用化

- 保留唯一的 `academic-anthropologist`，不新增职责重复的“游戏人类学家”。
- 人类学家的身份、输入、工作流和输出已去除对游戏世界、目标玩家、Canon 与 `game-director` 的硬编码，改由委派契约提供应用场景、受众、既定前提和决策责任人。
- `game-director` 在游戏任务中负责注入游戏世界、目标玩家、表达媒介、现有 Canon 与允许调整边界；人类学家只返回通用专业分析，Canon 裁决和游戏化转译仍归游戏总设计师。
- 路由原则：纯文化研究、一致性或敏感性审查可直接交人类学家；涉及游戏 Canon、玩法或内容转译时必须由游戏总设计师综合；UE 实现继续交技术总监和实施 Agent。

## 2026-08-28 收尾验证

本次收尾基于提交序列：

| 提交 | 内容 |
| --- | --- |
| `56af86b` | 总控首次强制提问、98% 需求理解和用户确认门禁 |
| `3f93f4e` | 项目级规则、安装器、安装回归与正式项目验证方法 |
| `bd242a7` | `M0` 根节点、路径式递归任务树和计划目录细粒度写权限 |

已完成验证：

- 主工作区在生成本交接前为干净状态，`master` 与 `origin/master` 同步在 `bd242a7`。
- 实际扫描得到 28 个有效 Agent，排除 `_template.md`；全部包含 `mode: subagent`。
- `scripts/test-install.ps1` 通过：28 Agent 复制、模板排除、项目根 `AGENTS.md` 隔离、UEGameStudio 指令合并、新配置生成和重复安装幂等均通过。
- 总控权限静态检查通过：`edit` 默认拒绝，只允许 `.opencode/task-plans/**`，未出现宽泛 `edit: allow`。
- Markdown/Git 差异检查通过，无空白错误或冲突标记。

收尾结论为 `READY_WITH_CONCERNS`：仓库内成品已经形成自包含安装和治理闭环，可以进入真实 UE 项目接入；真实 Editor、Commandlet、DCC、音频、性能和构建链仍须在目标项目中验证，不能仅凭仓库内静态规则判定整套体系为 `PASS`。

## 2026-08-31 注册表落地与专职缺口补齐

本批复盘已完成 2026-08-29 交接中登记的两个治理问题，并落盘两个新 Agent：

- **统一机器可读注册表**：新增 `UEGameStudio/docs/agent-registry.json`（30 条，含 `id`/`file`/`layer`/`title`/`mode`/`description`/`permission` 摘要），并新增 `UEGameStudio/scripts/verify-registry.ps1` 双向校验脚本：实际 `agents/**/*.md` 扫描数、`mode: subagent`、默认 `"*": deny`、标题/描述/权限六项与实际 frontmatter 逐条比对，漂移即 FAIL。
- **本地化与 LQA 专家**：新增 `agents/production/localization-lqa-specialist.md`。蒸馏自 Donchitos `localization-lead`/`/localize` 与 msitarzewski `i18n-engineer`，去组织冗余。负责 Loc 数据模型、纯文本 Loc/术语/字符串资源、i18n 就绪契约与 LQA；其自产 Loc 交付不可自验，LQA 只验证 UI/音频/运行时文本集成，交付由 `asset-compliance-auditor` 与 `qa-test-specialist` 独立验收。编辑权仅限任务白名单纯文本 Loc 路径。
- **安全专业评审**：新增 `agents/qa/security-engineer.md`。蒸馏自 addyosmani `security-and-hardening`/`security-auditor`、msitarzewski/jnMetaCode `security-engineer` 与 Donchitos `/security-audit`。审计型角色（同 `asset-compliance-auditor` 体例），范围限本地 UE 开发至本地构建包：威胁建模、C++/Blueprint 静态审查、Replication/RPC、Save/Load、凭据/密钥、插件依赖与构建产物泄漏检查；只评审不修复，给出 `SEC-REVIEW` 门禁。
- **同步更新**：`agent-roster-report.md`（数量 28→30、阵容总览、权限画像、能力矩阵两缺口→已覆盖、治理问题两条→已解决）、`INSTALL.md`（28→30，5 处）、`scripts/test-install.ps1`（断言 28→30 与文案）。
- **本轮验证**：`verify-registry.ps1` PASS（30 agents）、`test-install.ps1` PASS（30-Agent 复制、模板排除、配置合并、幂等）、治理文档相对链接 PASS、5 个 `task: allow` Agent 与两个新 Agent 的反引号路由未发现缺失 ID、新增/修改文件行尾全部 LF。以上不替代真实 UE Editor/Commandlet/DCC/音频/性能/构建环境验证，也未经真实项目调用验证两个新 Agent 的权限与门禁行为。
- 未提交、未推送。

## 当前需要后续修订的治理问题

1. **统一机器可读注册表**：已落地为 `UEGameStudio/docs/agent-registry.json`，由 `verify-registry.ps1` 双向校验；后续可让总控编排直接读取注册表作为阵容发现入口并保持同步。
2. **真实工具能力待项目验证**：二进制资产角色已经定义安全边界，但具体项目仍需验证 UE Editor、Commandlet、DCC 和音频工具是否可用；本地化 LQA 与安全评审能力同样只在真实 Editor/构建环境中调用验证。
3. **本地化/LQA 与安全专业能力**：已补齐为 `localization-lqa-specialist` 与 `security-engineer`；能力覆盖矩阵、路由与治理问题登记已更新，遇到相关任务不再登记 `CAPABILITY_GAP`。

未经用户确认，不要在下一会话顺带修订以上问题。

## Git 与文件安全

- 本轮整改基于 `bd242a7`，开始前已有本文件的用户未提交更新；当前预期包含 10 个 Agent、阵容报告和本文件的未提交差异。新会话必须以实际 `git status` 为准，不得覆盖或拆分用户原有交接更新。
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

1. 先阅读本交接说明、智能体阵容报告、项目根 `AGENTS.md` 和成品 `UEGameStudio/AGENTS.md`。
2. 运行 `git status`，核对当前 HEAD、远端同步状态和本交接文件是否已提交；不得依赖交接生成时的瞬时工作树状态。
3. 扫描实际存在的 Agent 文件，不能根据 Git 删除记录推断当前阵容；当前期望为 30 个有效 `mode: subagent`（排除 `_template.md`）。
4. 使用 `skill-creator` 指导 Agent 设计或创建；后续新增、合并或治理修订仍须先展示设计，取得用户明确“落盘”授权后再写文件；涉及 Agent 阵容变化时，落盘后必须同步更新 `docs/agent-registry.json` 并运行 `scripts/verify-registry.ps1` 确认 PASS。
5. 不重新创建已删除的旧候选 Agent，不顺带修订“当前需要后续修订的治理问题”或新增缺口角色。
6. 总控处理新任务时必须执行“首次提问 → 98% 需求理解 → 用户明确确认摘要 → 规划期疑点继续提问 → `PLAN_READY` → 落盘任务树”的门禁。
7. 总控在委派前必须检查 `.opencode/task-plans/<Plan-ID>/M0.md` 及递归节点已完整落盘，实际写入不得超出 `.opencode/task-plans/**`。
8. 若下一阶段是接入真实 UE 项目，先按 `docs/formal-project-validation.md` 建立可恢复基线、工具冻结、路径/Package 白名单和最小 Vertical Slice，再执行任何项目写入。
9. 若用户未指定新的建设目标，不主动扩大范围；当前仓库侧没有需要自动续跑的未完成实施任务。
