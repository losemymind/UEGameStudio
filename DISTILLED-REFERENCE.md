# DISTILLED-REFERENCE — UE 游戏开发 Agents & Skills 蒸馏基准

> 本文档是 UEGameStudio 项目「总结（蒸馏）适合 UE 游戏开发智能化和自动化流程中的 Agents 和 Skills」的**基准文档**。后续所有 UE 技能/agent 的创建与演进，均以本文为对照基准。
>
> 参考仓库（2026-08 版本）：
> - [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)（88.6k★）— 生产级工程技能
> - [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)（146k★）— AI agent 个性集合
> - [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)（24.2k★）— 游戏开发工作室编排

---

## 1. 项目定位

把 UE 游戏开发的智能化/自动化流程经验，蒸馏成**可复用、可验证、可进化**的 Agents 与 Skills，并接入 SEA 机制（记忆蒸馏 → 技能固化 → 棘轮评估）实现可持续进化。

**适用技术栈**：Unreal Engine 5（C++/Blueprint/GAS/UMG/Replication）、OpenCode/OpenWork（subagent + skill 机制）。

---

## 2. 三仓库对比

| 维度 | **agent-skills** | **agency-agents** | **CCGS** |
|---|---|---|---|
| 本质 | 24 个生命周期工程技能 | ~270 个 agent 个性集合 | 完整游戏工作室编排系统 |
| 领域 | 通用工程（无游戏） | 多领域（含 4 个 Unreal） | **游戏全流程**（49 agents/73 skills/11 rules/12 hooks） |
| 核心资产 | 「如何写技能」方法论 | agent 结构模板 + UE 内容 | UE 工作流编排 + 版本锚定 |
| 对 UE 深度 | 无 | unreal-systems-engineer 达 C++ 代码级 | 5 个 UE 专家 agent + 17 个引擎参考文档 |
| 架构亮点 | 三层 eval 框架 + 反合理化表 | 单 markdown 源 → 14 种工具渲染 | 路径作用域规则 + gate 质量门 |

**价值分层**：
- agent-skills 教「技能怎么写才有效」（过程编码 + 反合理化 + 证据化验证门）
- agency-agents 提供「agent 怎么组织 + UE 领域知识源」
- CCGS 提供「游戏流程怎么编排 + UE 如何细分」

---

## 3. 蒸馏原则

| 原则 | 含义 |
|---|---|
| 吸收规范，不吸收平台 | agent-skills 的技能写作规范全吸收；其 web 专属技能不吸收 |
| 吸收内容，适配平台 | agency-agents 的 UE agent 内容吸收；Claude Code 专属渲染不吸收 |
| 吸收机制，移植机制 | CCGS 的 UE 编排机制吸收；其 Claude 专属 hooks/settings 需移植为 opencode/SEA 等效 |
| 先版本后断言 | 一切 UE API 断言前必须版本锚定（CCGS P4 纪律与 SEA P4 一致） |
| 可回滚、可验证 | 每个技能带评测集；每个 agent 定义可 git 回滚（SEA 棘轮） |

---

## 4. agent-skills 蒸馏详析

### 4.1 技能编写规范（全部采用）

**SKILL.md 结构解剖**（frontmatter + 正文骨架）：

```yaml
---
name: skill-name-with-hyphens   # kebab-case，与目录名完全一致
description: 第三人称直陈"做什么" + "Use when [触发条件]"；禁写流程步骤（会诱导 agent 照摘要执行）；≤1024 字符
---
```

正文骨架（lint 强制五小节，可换等价标题）：
```
## Overview               → 电梯演讲 + 关键立场
## When to Use            → 触发条件 + 何时不用（When NOT）
## [核心流程]             → 编号步骤 + 决策矩阵 + ASCII 流程图
## Common Rationalizations → 反合理化表：左列借口 / 右列反驳
## Red Flags              → 技能被违反的可观察信号
## Verification           → 证据化验证门（[ ] 检查清单，要求证据，禁"seems right"）
```

**关键设计决策**：
1. **过程，不是散文** — 技能是可执行工作流，不是参考文档
2. **反合理化** — 每技能含"我会加测试的"/"这能跑就行"等借口表 + 反驳，防 agent 跳过步骤
3. **验证不可谈判** — 每技能以证据要求结尾；渐进披露（SKILL.md 是入口，支撑文件按需加载，省 token）
4. **Discover the Stack First** — 不假设测试命令/构建命令，先探测仓库（适配 UE 的 UBT/Build.bat）

### 4.2 可迁移技能（按 UE 流程映射）

| 阶段 | 技能 | UE 适配点 |
|---|---|---|
| 定义 | spec-driven-development | 编码前写 PRD，6 大领域：Objective/Project Structure/Code Style/Testing/Boundaries |
| 计划 | planning-and-task-breakdown | 依赖图 + 垂直切片，任务 ≤5 文件 + 验收标准 |
| 构建 | test-driven-development | RED-GREEN-REFACTOR；UE 用 Unreal Automation Tests |
| 构建 | source-driven-development | DETECT→FETCH→IMPLEMENT→CITE；UE API 多变，官方文档为据 |
| 构建 | incremental-implementation | 薄垂直切片，一次只做一件事 |
| 验证 | debugging-and-error-recovery | Stop-the-Line + 6 步：复现→定位→最小化→修根因→守卫→端到端 |
| 评审 | code-review-and-quality | 五轴评审 + Critical/Required/Nit 分级 + 变更规模 ~100 行 |
| 评审 | security-and-hardening | OWASP + AI/LLM Top 10（输出=不可信/提示注入） |
| 交付 | ci-cd-and-automation | 质量门流水线；UE 需自托管 runner 装 Unreal Editor |
| 交付 | git-workflow-and-versioning | Trunk-based、原子提交、semver + 人写 changelog |
| 交付 | shipping-and-launch | 发布清单、回滚流程 |

### 4.3 4 个 persona（单角色单视角，可并行扇出）

| agent | 角色 | 要点 |
|---|---|---|
| code-reviewer | Senior Staff Engineer | 五轴评审，Verdict: APPROVE/REQUEST CHANGES |
| test-engineer | QA Engineer | Prove-It 模式（先写必失败的复现测试） |
| security-auditor | Security Engineer | STRIDE 威胁建模 + OWASP Top 10 |
| web-performance-auditor | Web Perf Engineer | Metric-Honesty 规则（绝不虚构指标）— **此规则全盘吸收** |

**编排纪律**：用户或斜杠命令是编排者；**persona 不得调用 persona**；并行扇出 + 主上下文合并。

---

## 5. agency-agents 蒸馏详析

### 5.1 架构（单源多工具）

```
divisions/*.md（源，frontmatter + 模板正文）
   ↓ convert.sh（渲染）
integrations/<tool>/（14 种格式：opencode-md / claude-code / cursor-mdc / codex-toml / gemini-md ...）
   ↓ install.sh（分发探测）
各工具配置目录
```

**opencode 渲染格式**：frontmatter 重写为 `name / description / mode: subagent / color`（命名色映射 hex）。
→ **我们可直接复用该渲染契约，自定义 UE agent 集。**

### 5.2 agent 文件模板

```markdown
---
name: <Human Role>
description: <一段式角色 + 触发条件>
color: <命名色>        # convert 映射 hex
emoji: <emoji>
vibe: <一句话气质>
---
# <Name> Agent Personality
## 🧠 Your Identity & Memory      # Role / Personality / Memory / Experience
## 🎯 Your Core Mission           # 3-6 个使命区
## 🚨 Critical Rules You Must Follow  # 含 **MANDATORY** 强调项
## 📋 Your Technical Deliverables # 带可直接复制的代码
## 🔄 Your Workflow Process       # 编号步骤
## 📋 Your Deliverable Template   # 输出报告模板
## 💭 Your Communication Style
## 🔄 Learning & Memory           # 跨会话应积累经验
## 🎯 Your Success Metrics
## 🚀 Advanced Capabilities
**Instructions Reference**: <引导语>
```

### 5.3 4 个 Unreal agent（可直接改编为内容源）

| agent | 专长 |
|---|---|
| unreal-systems-engineer | C++/BP 边界（每帧逻辑必须 C++）、GAS（Ability/AttributeSet 网络复制）、Nanite 16M 实例上限、Lumen、内存模型（UPROPERTY/IsValid/TWeakObjectPtr）、Mass ECS、Chaos 破坏、Lyra Modular Gameplay；含 `.Build.cs`/UAttributeSet 可复制代码 |
| unreal-technical-artist | Material Editor、Niagara VFX、PCG 程序化生成、LOD 管线（LOD0-3）、overdraw 审计、性能预算 |
| unreal-multiplayer-architect | Actor 复制、GameMode/GameState 层级、网络预测、专属服务器、Replication Graph |
| unreal-world-builder | UE5 World Partition、Landscape、HLOD、大规模关卡流送、开放世界 |

---

## 6. CCGS 蒸馏详析

### 6.1 5 个 UE 专家 agent（最细 UE 拆分，均含 7 条反模式清单）

| agent | 专长 |
|---|---|
| **unreal-specialist** | UE 主专家（leader），**Delegates to** 其余 4 个；Blueprint vs C++ 决策、GAS/Enhanced Input/CommonUI、C++ 标准（F/T/U/A 前缀、UPROPERTY/TObjectPtr/GENERATED_BODY）、SCOPE_CYCLE_COUNTER、Unreal Insights、Soft References/Data Tables |
| **ue-gas-specialist** | Ability 生命周期（CommitAbility/EndAbility）、Gameplay Effects（**绝不允许直接改属性**）、AttributeSet 钩子（PreAttributeChange/PostGameplayEffectExecute）、Gameplay Tags 层级、Ability Tasks、预测（FPredictionKey）、ASC 复制模式（Full/Mixed/Minimal） |
| **ue-blueprint-specialist** | C++ vs BP 决策表（Must Be C++ / Can Be Blueprint 两表）、≤20 节点/函数图、命名（BP_/BPI_/BPFL_/E_/S_）、Data-Only Blueprint、接口优先于 Cast、禁 Tick / Tick 中禁 Cast |
| **ue-replication-specialist** | DOREPLIFETIME + 条件（COND_OwnerOnly/SkipOwner/InitialOnly/Custom）、RPC 服务端验证输入、Reliable 仅关键事件、客户端预测回滚、NetRelevancy/Dormancy/NetPriority、带宽量化（FVector_NetQuantize，目标 <10KB/s/client） |
| **ue-umg-specialist** | CommonActivatableWidget 栈、HUD/Menu/Popup/Overlay 分层、WidgetController/ViewModel 绑定、Widget Pooling、集中样式资产、平台自适应输入（UCommonInputSubsystem）、性能 <2ms frame budget、stat slate、可访问性（文字缩放/色盲/字幕） |

### 6.2 版本锚定纪律（最独特机制，必吸收）

```
docs/engine-reference/unreal/
├── VERSION.md            # 锚定 UE 5.7（2025-11 发布）、LLM 知识截止 2025-05、显式知识缺口警告（5.4-5.7 超训练数据）
├── current-best-practices.md  # Megalights/Nanite/Lumen/Substrate 选型、C++20、TObjectPtr GC 安全
├── breaking-changes.md / deprecated-apis.md
├── modules/              # animation/audio/input/navigation/networking/physics/rendering/ui（版本验证日期 + Knowledge Gap 标注）
└── plugins/              # gameplay-ability-system.md(386 行全 C++ 示例)/common-ui/gameplay-camera-system/pcg
```

规则：**所有 agent/skill 强制先查 VERSION.md 再断言 API**；超训练数据的 API 显式标注 "may have changed in [version] — verify"。
→ 与 SEA P4 版本自适应天然一致，直接复用 `SEA/scripts/verify-versions.py`。

### 6.3 11 条路径作用域规则（编码标准自动生效）

| 规则 | 路径 | 强制内容 |
|---|---|---|
| engine-code | src/core/** | 热路径零分配、API 线程安全、引擎绝不依赖 gameplay、变更需弃用期 |
| gameplay-code | src/gameplay/** | 数值全外部配置（禁硬编码）、全 delta time、禁直接引用 UI、禁静态单例 |
| ai-code | src/ai/** | AI 预算 ≤2ms/帧、参数数据文件可调、状态需可视化调试钩子、意图预告 |
| network-code | src/networking/** | 服务器权威（绝不信客户端）、消息版本化、复制策略声明、带宽预算 |
| ui-code | src/ui/** | UI 绝不拥有游戏状态（command/event 请求变更）、全本地化、键鼠+手柄双支持 |
| design-docs | design/gdd/** | GDD 8 必需章节、公式含变量/范围/示例、验收标准可测试、增量撰写 |
| narrative | design/narrative/** | lore 交叉查矛盾、canon 分级、对话 ≤120 字符 |
| data-files | assets/data/** | JSON 合法性（坏 JSON 阻塞构建）、命名/文档化 schema |
| test-standards | tests/** | 命名规范、AAA、**每个 bug 修复必须有回归测试** |
| prototype-code | prototypes/** | 放宽标准 + 隔离子目录 + README + 不得部署 |
| shader-code | assets/shaders/** | 命名 `M_Env_Water` 式、无魔法数字、half 精度、禁循环内读纹理、两 pass 模糊 |

### 6.4 编排机制

1. **Studio Hierarchy 三层**：Tier1 Directors（Opus：creative-director/technical-director/producer）→ Tier2 Leads（Sonnet：game-designer/lead-programmer/art-director/audio-director/narrative-director/qa-lead/release-manager/localization-lead）→ Tier3 Specialists（Sonnet/Haiku：22 专业 + 15 引擎）
2. **委派模型**：Vertical Delegation（复杂决策不跳层）/ Horizontal Consultation（同层咨询不越域）/ Conflict Resolution（升级共享父级）/ Change Propagation（跨域由 producer 协调）
3. **24 个 gate 质量门**：verdict 三档 APPROVE/CONCERNS/REJECT；并行 gate 取最严；Review Mode 三档（full/lean/solo）
4. **7-phase workflow-catalog**：Concept → Systems Design → Technical Setup → Pre-Production → Production → Polish → Release（每步含 command/required/artifact glob）
5. **Collaborative-Not-Autonomous 协议**：Ask → Present options（2-4 个带利弊）→ You decide → Draft → Approve；写文件前必须问 "May I write this to [filepath]?"
6. **模型分层**：Haiku=只读/简单查询；Sonnet=实现与设计（默认）；Opus=多文档综合/高风险 gate

---

## 7. 蒸馏结论：推荐建设的 UE Agents

合并三方，7 个核心 agent（层级结构，镜像 CCGS 委派模型）：

```
Tier 1  Director
  unreal-director（UE 技术总监：BP vs C++ 决策、版本锚定、跨系统仲裁）
Tier 2  Specialist（unreal-director Delegates to）
  unreal-specialist          ← CCGS 主专家（GAS/Enhanced Input/CommonUI/C++ 标准/Insights）
  ue-gas-specialist          ← CCGS（GameplayAbilitySystem 全规则）
  ue-blueprint-specialist    ← CCGS（BP/C++ 边界）
  ue-replication-specialist  ← CCGS（网络/复制）
  ue-umg-specialist          ← CCGS（UI/CommonUI）
  unreal-technical-artist    ← agency-agents + CCGS 合并（渲染/VFX/PCG/LOD）
  unreal-world-builder       ← agency-agents（World Partition/HLOD/开放世界）
  unreal-multiplayer-architect ← agency-agents（网络架构，与 ue-replication 互补）
```

> **取舍提示**：起始可先建 1 个 `unreal-director` + 2-3 个高频专家（unreal-specialist / ue-blueprint-specialist / ue-replication-specialist），验证有效后再扩展全量。SEA 要求「候选先入注册表 → 评估 → HITL 审批 → solidify」，建议按批次演进而非一次铺满。

## 8. 蒸馏结论：推荐建设的 UE Skills

用 agent-skills 规范重写 CCGS 流程，按 7-phase 组织（每个 SKILL.md 遵循 4.1 解剖）：

| 阶段 | Skill 名（建议） | 内容来源 |
|---|---|---|
| 定义 | `ue-game-spec` | GDD 8 章节（design-docs 规则）+ capability map |
| 定义 | `ue-version-anchor` | 版本锚定核实（VERSION.md + verify-versions.py） |
| 计划 | `ue-planning` | 依赖图 + 垂直切片 + UE 任务模板 |
| 构建 | `ue-source-driven-dev` | source-driven-development + 官方文档核实 |
| 构建 | `ue-blueprint-cpp-boundary` | BP/C++ 决策表 + 命名规范 |
| 构建 | `ue-test-driven-dev` | Automation Tests + `UnrealEditor -nullrhi -ExecCmds="Automation RunTests"` |
| 验证 | `ue-debugging` | 编译错误/崩溃/日志（Saved/Logs/）+ Stop-the-Line |
| 验证 | `ue-perf-profile` | Unreal Insights + stat 命令 + 先测量后优化 |
| 评审 | `ue-code-review` | 五轴评审 + 网络/复制/GC 专项 |
| 评审 | `ue-security-audit` | 反作弊/服务端权威/权限校验 |
| 交付 | `ue-ci-cd` | 自托管 runner + 质量门流水线 |
| 交付 | `ue-release-checklist` | 发布清单 + 回滚流程 |

## 9. 必须保留的工程机制

| 机制 | 来源 | 落地方式 |
|---|---|---|
| SKILL.md 解剖规范 + 反合理化表 + 证据化验证门 | agent-skills | 作为技能模板基准（`SEA/templates/skill-template`） |
| **Metric-Honesty** 规则（绝不虚构指标） | agent-skills | 写入所有评测类技能 |
| 版本锚定（VERSION.md + 知识缺口声明 + 先查再断言） | CCGS | 建 `docs/engine-reference/unreal/`，复用 SEA verify-versions |
| 路径作用域编码规则 | CCGS | opencode rules（rules/ 目录）或 SEA 校验脚本 |
| 委派层级 + gate 质量门 | CCGS | subagent 编排 + `SEA/agents/topology.json` |
| Collaborative-Not-Autonomous 协议 | CCGS | 写入所有 agent 定义 |
| 单源多工具渲染契约 | agency-agents | 需要时建 convert 脚本（不急需） |

## 10. 不吸收清单

- agent-skills 的 web 专属技能：frontend-ui-engineering / browser-testing-with-devtools / performance-optimization（CWV 目标）/ observability（云服务版）
- agency-agents 的非游戏 divisions：marketing / sales / paid-media / finance / gis / healthcare 等
- CCGS 的 Claude Code 专属机制：hooks / settings.json / statusline.sh / worktree isolation / `/team-*` 斜杠命令（需移植为 opencode 等效，优先复用 SEA 脚本）
- CCGS 的 Godot / Unity agent 集（本项目聚焦 UE）

---

## 11. 后续执行路径（从本基准出发）

1. **建版本锚定基础**：`docs/engine-reference/unreal/VERSION.md`（UE 版本 + 知识截止 + 知识缺口）——一切技能/agent 的前提
2. **建首批 Skills**：按 §8 从 `ue-version-anchor`、`ue-blueprint-cpp-boundary`、`ue-code-review` 起，走 skill-craft 流程（候选→评估→HITL→solidify）
3. **建首批 Agents**：`unreal-director` + 2-3 个专家，走 agent-improvement 流程，注册进 `SEA/agents/topology.json`
4. **建评测集**：每个技能带 test-prompts.json（含 verifiable 用例），进棘轮基线
5. **迭代蒸馏**：UE 任务执行中把经验写入 `SEA/memory/`，高频做法固化为技能，回到本基准更新

---

*来源会话：m-20260820-*（三仓库克隆 + explore subagent 深度分析）。本基准随 UE 技能/agent 建设持续更新。
