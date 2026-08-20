# DISTILLED-CATALOG — 三仓库完整可迁移清单（agents & skills）

> 本文档是 UEGameStudio 项目的**完整蒸馏目录**：从三个参考仓库中提取、总结、蒸馏出全部适合 UE 游戏开发智能化的 agents 与 skills。
>
> 参考仓库（2026-08 版本）：
> - [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)（88.6k★）— 24 技能 + 4 persona + 7 checklist + 8 command + 三层 eval
> - [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)（146k★）— ~270 agents / 17 divisions
> - [Donchitos/Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)（24.2k★）— 49 agents + 73 skills + 11 rules + 12 hooks + gate + 7-phase
>
> 配套：蒸馏基准见 `DISTILLED-REFERENCE.md`（更精炼的落地视角）；本文档为**完整全量清单**。
> 适用性标记：✅直接用 / 🔧改编 / ❌不适用（仅借鉴理念）。

---

## 1. agent-skills — 全部技能 + Agents（✅ 全量工程方法论）

### 1.1 Skills（24 个）

**Meta**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `using-agent-skills` | 技能路由总纲（任务→技能决策图 + 行为纪律） | ✅ 可直接作为 AGENTS.md 意图→技能映射蓝本 |

**DEFINE**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `interview-me` | 一次一问提取真实意图，~95% 置信才动手 | ✅ 游戏需求澄清 |
| `idea-refine` | 发散/收敛把模糊想法锤炼成一页纸方案 | ✅ 玩法立项 |
| `spec-driven-development` | 编码前 PRD 六大区块 + capability map | 🔧 术语换 UE（UBT/RunUAT/Build.cs） |

**PLAN**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `planning-and-task-breakdown` | 依赖图 + 垂直切片 + 验收标准 | ✅ |

**BUILD**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `incremental-implementation` | 薄垂直切片，每片可编译可回滚 | ✅ UE 编译慢尤其需要 |
| `test-driven-development` | RED-GREEN-REFACTOR + Prove-It | 🔧 换 UE Automation Tests |
| `context-engineering` | 五层上下文层级（规则文件>源码>错误>历史） | ✅ 极高价值，UE 代码库巨大 |
| `source-driven-development` | DETECT→FETCH→IMPLEMENT→CITE | ✅ 契合 UE 版本 API 多变 |
| `doubt-driven-development` | 非平凡决策 fresh-context 对抗评审（CLAIMM→DOUBT→RECONCILE） | ✅ 配 subagent；不可逆操作（数据迁移/多人协议）适用 |
| `frontend-ui-engineering` | Web UI 生产级工程 | 🔧 仅取"设计系统/组合优于配置"理念 → UMG |
| `api-and-interface-design` | 契约先行、Hyrum's Law、模块边界 | 🔧 换 UE 公共头/UINTERFACE/RPC 契约 |

**VERIFY**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `browser-testing-with-devtools` | 浏览器运行时可视化验证 | ❌（思路：用 MCP 给 agent "眼睛"，UE 对应 Insights/自动化截图） |
| `debugging-and-error-recovery` | Stop-the-Line + 六步分诊 | ✅ 极高价值，UE 崩溃/构建失败 |

**REVIEW**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `code-review-and-quality` | 五轴评审 + 分级 + 结构化输出 | ✅ 改五轴清单为 UE 版 |
| `code-simplification` | 保持行为不变地简化（Chesterton's Fence/Rule of 500） | ✅ 注意 UE 热路径不简化 |
| `security-and-hardening` | 威胁建模 + OWASP + LLM Top 10 | 🔧 换 UE 反作弊/存档/网络校验 |
| `performance-optimization` | Measure→Fix→Verify→Guard | 🔧 换帧预算/stat/Insights |

**SHIP**
| 技能 | 一句话 | 适用 |
|---|---|---|
| `git-workflow-and-versioning` | Trunk-based + 原子提交 + semver | ✅ 补 UE 二进制资源规则 |
| `ci-cd-and-automation` | 质量门流水线 | 🔧 换 UE CI（自托管 runner） |
| `deprecation-and-migration` | 代码即负债、废弃/迁移 | ✅ 正中 UE 版本升级痛点（UE_DEPRECATED） |
| `documentation-and-adrs` | ADR + 记 why 不记 what | ✅ GAS vs 自研等决策值得 ADR |
| `observability-and-instrumentation` | 结构化日志/RED/追踪 | 🔧 换 UE_LOG/Trace/stat |
| `shipping-and-launch` | 发布清单/灰度/回滚 | 🔧 换平台认证门 |

### 1.2 Agents（4 个 persona）
| agent | 角色 | 适用 |
|---|---|---|
| `code-reviewer` | 资深工程师五维评审，Critical/Important/Suggestion | ✅ 改编为 UE review agent（骨架 100% 复用） |
| `security-auditor` | 安全审计 + STRIDE + PoC | 🔧 重写清单为 UE 场景 |
| `test-engineer` | QA 策略 + Prove-It | 🔧 换 IMPLEMENT_SIMPLE_AUTOMATION_TEST |
| `web-performance-auditor` | CWV 审计，**Metric-Honesty 规则** | ❌（纪律全盘吸收，改造为 ue-performance-auditor） |

### 1.3 机制（最值得吸收）
- **evals 三层框架**：Tier1 结构（免费）→ Tier2 触发/路由（TF-IDF，防路由漂移）→ Tier3 行为（真实 agent 执行 + 判官核对 expectations）。SEA 缺 Tier2，可移植。
- **压力用例**（time-pressure/sunk-cost/authority-pressure）验证流程在"劝跳过"时仍成立 → 对应 SEA 反合理化表。
- **`/ship` 并行扇出**：同一轮派 code-reviewer+security+test-engineer 三个 subagent → 合并 → GO/NO-GO。opencode/SEA 可直接复刻。
- **hooks 机制性约束**：`simplify-ignore` 用文件拦截而非提示词说服；`sdd-cache` 缓存带源校验。比在 AGENTS.md 写规则可靠。
- **orchestration-patterns**：核心规则"用户是编排者，persona 不得调 persona"；反模式（路由 persona / persona 调 persona / 转述编排 / 深层树）。与 SEA 规则 9 同构。

---

## 2. agency-agents — 全部相关 agents（~90 个）

### 2.1 game-development division（21 个）

**引擎无关（7 个）**
| agent | 专长 | 适用 |
|---|---|---|
| `economy-designer` | 货币/经济平衡/Monte Carlo | ✅ |
| `game-audio-engineer` | FMOD/Wwise/自适应音频/预算 | ✅（含 UE MetaSounds 对应） |
| `game-designer` | GDD/核心循环/数值纪律 `[PLACEHOLDER]` | ✅ |
| `level-designer` | blockout 三阶段/节奏/遭遇 | ✅ |
| `narrative-designer` | 分支对话/lore 架构 | ✅（UE 接第三方对话插件/Sequencer） |
| `technical-artist` | Shader/LOD/压缩/overdraw/预算表 | ✅（理念通用） |
| `blender-addon-engineer` | 资产校验器/FBX/USD 导出 | 🔧 服务 UE 资产管道 |

**Godot（3 个）** — 方法论可迁移（signal↔delegate、节点组合↔Actor 组合、RPC 权威模型）
**Roblox（3 个）** — 方法论可迁移（DataStore↔存档、客户端-服务器安全↔RPC 校验）
**Unity（4 个）** — 方法论可迁移（ScriptableObject↔UDataAsset、编辑器自动化↔Editor Utility Widgets、lag compensation、Shader Graph↔Material Editor）

**Unreal 专属（4 个，核心资产，见 §2.5）**
`unreal-multiplayer-architect` / `unreal-systems-engineer` / `unreal-technical-artist` / `unreal-world-builder`

### 2.2 engineering division（57 个中 ~30 个相关）

**核心直接相关（6 件套 + 扩展）**
| agent | 迁移价值 |
|---|---|
| `engineering-code-reviewer` | 直接用于 UE C++/BP PR 审查，分级可定制 |
| `engineering-git-workflow-master` | uasset 冲突/.Build.cs 合并/trunk+worktree |
| `engineering-codebase-onboarding-engineer` | UE 模块/插件结构"三层输出"（1 行/5 分钟/深潜） |
| `engineering-technical-writer` | UE 文档/ADR/CI docs 门禁 |
| `engineering-minimal-change-engineer` | 防 PR 膨胀（uasset 改动最小化） |
| `engineering-software-architect` | UE 分层架构/模块解耦 |

**平台/后端向（10+）**：devops-automator（BuildGraph/Gauntlet/专服云）、sre（后端可靠性/帧率当 SLO）、incident-response-commander（上线事故）、mobile-release-engineer（移动商店）、desktop-app-engineer（启动器/BuildPatchTool）、i18n-engineer（FText/Localization Dashboard 对标 ICU）、privacy-engineer（玩家数据合规）、backend-architect/database-optimizer/database-reliability-engineer/api-platform-engineer（游戏后端）、data-engineer/data-visualization（遥测）、finops（专服成本）、identity-access（账号体系）、realtime-collaboration（联机房间）、multi-agent-systems-architect（**与 SEA 理念同源**）、autonomous-optimization-architect（性能守护者）、developer-tooling（UAT/RunUAT 包装 CLI）、rapid-prototyper（玩法验证）、AI/rag/prompt/llm-post-training（对话 NPC/LLM 工具链）、voice-ai（字幕）、video-streaming（过场 CDN）、webassembly（HTML5 构建）、network-engineer（机房/专服）、search-relevance（商城搜索）、frontend/mobile-app（配套 Web/App）。

**低相关不迁移**：cms/wordpress/drupal/uswds/filament/feishu/wechat-mini/gaussdb/email-intelligence/orgscript/solidity/it-service/rust-refactoring 等。

### 2.3 testing division（9 个，全相关）
| agent | 价值 |
|---|---|
| `testing-reality-checker` | **证据认证，默认 NEEDS WORK**（与 SEA "评估器比生成器更重要"完全同构） |
| `testing-evidence-collector` | 截图证物反幻觉，对接 UE Automation 截图比较 |
| `testing-performance-benchmarker` | 先 baseline/95% 置信/预算门禁 |
| `testing-test-results-analyzer` | 缺陷分级 P0-P3/发布就绪概率 |
| `testing-test-automation-engineer` | 方法论迁移到 UE Automation/Gauntlet |
| `testing-api-tester` | 游戏后端 API 回归 |
| `testing-accessibility-auditor` | 色弱/对比度/自定义键位/字幕 |
| `testing-tool-evaluator` | 插件/中间件选型 |
| `testing-workflow-optimizer` | Dev↔QA 循环/首过率 |

### 2.4 其他 division

**project-management（7 个全相关）**：studio-producer（多项目）、studio-operations（跨组资源）、project-shepherd（里程碑）、project-manager-senior（防镀金）、jira-workflow-steward（Jira↔Git）、experiment-tracker（A/B）、meeting-notes-specialist（决策落档）。

**design（6 个相关）**：ux-researcher、ux-architect（UMG 系统架构/设计 token）、ui-designer（UMG 设计系统）、ui-finish-gate-reviewer（防通用化 UI）、persona-walkthrough（新手引导/商城）、inclusive-visuals-specialist（角色表现审查）。

**security（7 个相关）**：ai-generated-code-auditor（AI 生成 UE C++ 查硬编码密钥/注入）、appsec-engineer、secrets-credential-engineer、senior-secops、penetration-tester（RPC 篡改/内存修改）、incident-responder、compliance-auditor。security-architect（客户端永远不可信，与 multiplayer-architect 呼应）。

**strategy playbooks（方法论整套可迁移）**：
- **phase-3-build**（Dev↔QA 循环、3 次重试升级、RICE、并行轨道）— 最值得借鉴
- **phase-4-hardening**（Reality Checker 唯一权威，默认 NEEDS WORK）— 发布前终极质量门
- phase-0/1/2（发现/战略/脚手架）、phase-5-launch、phase-6-operate
- runbooks.json 场景化一键装配 + handoff-templates（交接防上下文丢失）+ agent-activation-prompts

**specialized（12 个相关）**：agents-orchestrator（全流程编排）、workflow-architect（最强方法论：拆 happy path+失败分支+清理+测试）、codebase-archaeologist（多 AI 改动后漂移审计）、mcp-builder（UE 工作流定制 MCP）、model-qa（ML 系统审计）、document-generator、developer-advocate、lsp-index-engineer（UE 语义索引）、agentic-identity-trust、identity-graph-operator、automation-governance-architect、corporate-training-designer、organizational-psychologist。

### 2.5 Unreal 4 agent 完整要点（最高蒸馏价值）

**`unreal-multiplayer-architect`**（网络架构师）
- 权威模型：客户端发 RPC→服务端校验→复制；`UFUNCTION(Server, Reliable, WithValidation)` 的 `_Validate()` **不可省略**；每次状态变更前 `HasAuthority()`；纯表现用 `NetMulticast`
- 复制效率：`UPROPERTY(Replicated)` 只放全员需要的；`ReplicatedUsing=OnRep_X`；`GetNetPriority()` 加权；`SetNetUpdateFrequency()`（默认 100Hz 浪费，多数 20-30Hz）
- 层级纪律：GameMode=仅服务器/GameState=复制全员/PlayerState=复制全员/PlayerController=仅属主
- GAS 网络：**双初始化路径**——服务器 `PossessedBy` 初始化，客户端 `OnRep_PlayerState` 再初始化
- 频率配置：Projectile 100Hz/NPC 20Hz/环境 2Hz + `bOnlyRelevantToOwner`
- 反作弊：审计每个 Server RPC（能否发不可能值？能否直接触发他人伤害？）
- 成功指标：全部 RPC 有 `_Validate`；<15KB/s/玩家；200ms ping desync <1次/30s；专服 CPU<30%

**`unreal-systems-engineer`**（系统工程师）
- C++/BP 边界强制：**任何每帧（Tick）逻辑必须 C++**；BP 无的数据类型用 C++；引擎级扩展必须 C++
- Nanite：单场景硬上限 **1600 万实例**；不存显式 tangent；不兼容骨骼网格/masked 材质/样条/程序化网格；`r.Nanite.Visualize` 早期验证
- 内存/GC：所有 `UObject*` 必须 `UPROPERTY()`；非拥有引用 `TWeakObjectPtr<>`；跨帧不存裸 `AActor*`；用 `IsValid()` 而非 `!=nullptr`
- GAS：`.Build.cs` 加 GameplayAbilities/GameplayTags/GameplayTasks；属性集 `GAMEPLAYATTRIBUTE_REPNOTIFY`；用 FGameplayTag 而非字符串
- 构建：改 .Build.cs/.uproject 后跑 GenerateProjectFiles.bat；宏缺失→静默运行时失败
- 性能：`TickInterval=0.05f` 20Hz 封顶；低频用 FTimerManager；`SCOPE_CYCLE_COUNTER`
- 高级：Mass Entity ECS、Chaos 破坏、Lyra Modular Gameplay（UGameFeatureAction）、自定义引擎模块

**`unreal-technical-artist`**（技术美术）
- Material：可复用逻辑进 Material Function；变体用 Material Instance；Static Switch 使排列翻倍（审计）；Quality Switch 分档
- Niagara：CPU vs GPU 阈值 1000 粒子；必须设 Max Particle Count；Scalability 三档全测；GPU 避免逐粒子碰撞
- PCG：确定性图；Poisson 分布禁均匀网格；PCG 放置优先 Nanite；每图文档化参数
- LOD/剔除：非 Nanite 网格手工 LOD 链；Cull Distance Volume；World Partition 配 HLOD
- Shader 预算：Base Pass 指令 <200 mobile/<400 console/<800 PC；采样 <8 mobile
- 高级：Substrate 材质（UE5.3+）、GPU 仿真多 pass、Path Tracer 验证 Lumen、PCG 高级（tag 驱动/递归/运行时）

**`unreal-world-builder`**（开放世界构建师）
- World Partition：Cell 由流送预算决定（城区 64m/地形 128m/沙漠 256m+）；**游戏性关键内容禁放 cell 边界**；常驻内容放 Always Loaded；hash cell 填充前配好
- Landscape：分辨率 (n×ComponentSize)+1；**单区域最多 4 激活 layer**；>2 层用 RVT；洞用 Visibility Layer
- HLOD：>500m 可见区必须建；HLOD 是生成的、几何变更后重建；里程碑从最大视距目视验证
- 植被：Foliage Tool 只手摆 hero；大规模用 PCG；PCG 必须 Nanite；显式排除区；运行时 PCG 仅 <1km²
- 高级：LWC（>2km 启用，shader 用 LWCToFloat）、OFPA（One File Per Actor 多人免冲突）、Edit Layers、UWorldPartitionReplay 压测

### 2.6 机制借鉴（最值得搬的 5 样）
1. **unreal-engine 4 agent**（上述）——UE 专属，蒸馏价值最高
2. **phase-3-build + phase-4-hardening**——Dev↔QA 循环 + Reality Checker 门
3. **单源多工具渲染**（convert.sh + tools.json + install.sh）——一份定义多工具分发；`format` 字节级契约；slug 单一来源；生成物 gitignore
4. **testing 三件套**（reality-checker / evidence-collector / test-results-analyzer）——证据驱动 QA
5. **engineering 六件套**（code-reviewer / git-workflow-master / onboarding / technical-writer / minimal-change / software-architect）

---

## 3. CCGS — 完整 catalog（49 agents + 73 skills + 11 rules + 机制）

> 核心约定：**Collaborative-Not-Autonomous**（Ask → Present options → You decide → Draft → Approve；写文件前问 "May I write this to [filepath]?"）

### 3.1 Agents（49 个）— UE 适用性总览

**Tier1 Directors（4）**
| agent | 角色 | 适用 |
|---|---|---|
| `creative-director` | 愿景守护/pillar 仲裁/范围裁剪；gate: CD-* | ✅ |
| `technical-director` | 架构所有权/选型/性能预算/引擎风险 gate（读 engine-reference） | ✅ |
| `producer` | 生产总协调/sprint/里程碑/范围谈判 | ✅ |
| `art-director` | Art Bible/风格指南/资产命名 | ✅ |

**Tier2 Leads（8）**：game-designer ✅、lead-programmer ✅、audio-director ✅、narrative-director ✅、qa-lead ✅、release-manager ✅（平台认证 TRC/TCR/Lotcheck）、localization-lead ✅（UE FText）、systems-designer ✅（公式四要素强制格式）。

**Tier3 Specialists（22）**
- 直接用：level-designer、economy-designer、gameplay-programmer（**Engine Version Safety**）、engine-programmer、sound-designer、writer、world-builder、qa-tester（**内置 UE Automation 测试模板**）、performance-analyst、devops-engineer、analytics-engineer、ux-designer、prototyper（含 UE 路径）、security-engineer、accessibility-specialist、live-ops-designer、community-manager
- 改编：ai-programmer（UE BehaviorTree/EQS 复核）、network-programmer（概念通用，UE 专属由 ue-replication 承接）、tools-programmer（UE Editor Utility）、ui-programmer（UE UMG 由 ue-umg 承接）、technical-artist（UE Material/Niagara）

**引擎专家组（15）**：UE 5 个（unreal-specialist + ue-gas/ue-blueprint/ue-replication/ue-umg，**全部直接用，见 3.5**）+ Unity 5 + Godot 5（对 UE 项目不适用）。

### 3.2 Skills（73 个）— UE 适用性总览

**B1 Onboarding（7）**：start ✅、help ✅、project-stage-detect ✅、**setup-engine** ✅（已含 UE 模板：UBT/命名/专家路由表/知识截止标注）、adopt ✅（存量项目审计）、onboard ✅、reverse-document ✅（C++ 反推 GDD）。

**B2 Game Design（7）**：brainstorm ✅、map-systems ✅、design-system ✅（8 必节）、quick-design ✅、review-all-gdds ✅、propagate-design-change ✅、consistency-check ✅。

**B3 Art（3）**：art-bible ✅、asset-spec ✅、asset-audit 🔧（路径映射 UE Content）。

**B4 UX（2）**：ux-design ✅、ux-review ✅。

**B5 Architecture（4）**：create-architecture ✅、architecture-decision ✅、architecture-review ✅（含引擎反模式检查）、create-control-manifest ✅。

**B6 Stories & Sprints（8）**：create-epics ✅、create-stories ✅、**dev-story** ✅（已含 UE 专家路由表，HIGH 引擎风险必 spawn）、story-readiness ✅、story-done ✅、estimate ✅、sprint-plan ✅、sprint-status ✅。

**B7 Reviews & Analysis（9）**：design-review ✅、code-review ✅、balance-check ✅、content-audit ✅、scope-check ✅、perf-profile ✅、tech-debt ✅、gate-check ✅（并行 spawn CD/TD/PR/AD 四 gate）、security-audit ✅。

**B8 QA & Testing（10）**：qa-plan ✅、smoke-check ✅（已含 UE Saved/Logs）、soak-test ✅（已含 stat memory）、regression-suite ✅、**test-setup** ✅（已含 UE Automation 全套 + CI 模板）、**test-helpers** ✅（已含 GameTestHelpers.h 模板）、test-evidence-review ✅、test-flakiness ✅（已含 UE 日志解析）、skill-test ✅（元技能）、skill-improve ✅（元技能）。

**B9 Production（5）**：milestone-review ✅、retrospective ✅、bug-report ✅、bug-triage ✅、playtest-report ✅。

**B10 Release（6）**：release-checklist ✅、launch-checklist ✅、changelog ✅、patch-notes ✅、hotfix ✅、day-one-patch ✅。

**B11 Creative & Content（3）**：prototype ✅（含 UE 路径）、vertical-slice ✅、localize ✅（含 Unreal 文本方向 flags）。

**B12 Team Orchestration（9）**：team-combat/narrative/ui/release/polish/audio/level/live-ops/qa 全部 ✅（含 UE Actor/Component、UMG vs CommonUI、MetaSounds vs FMOD 检查）。

### 3.3 Rules（11 条，路径作用域编码标准）

| 规则 | 路径 | 强制要点 | UE 迁移 |
|---|---|---|---|
| `gameplay-code` | src/gameplay/** | 数值全配置化/全 delta time/禁直接引用 UI/禁静态单例 | ✅ 值得建 |
| `engine-code` | src/core/** | 热路径零分配/引擎不依赖 gameplay/API 弃用期 | ✅ 值得建 |
| `ai-code` | src/ai/** | AI 预算 2ms/帧/参数数据化/可视化调试钩子 | ✅ 值得建 |
| `network-code` | src/networking/** | 服务器权威/消息版本化/预测回滚/带宽预算 | ✅ 值得建 |
| `ui-code` | src/ui/** | UI 不拥有游戏状态/本地化/双输入支持/不阻塞主线程 | ✅ 值得建 |
| `design-docs` | design/gdd/** | GDD 8 必节/公式四要素/AC 可测试/增量撰写 | ✅ 完全引擎无关 |
| `narrative` | design/narrative/** | lore 交叉查矛盾/canon 分级/对话 ≤120 字符 | ✅ |
| `data-files` | assets/data/** | JSON 合法阻断构建/命名/schema/版本化 | 🔧 改 DataTable/DataAsset |
| `test-standards` | tests/** | 命名/AAA/每个 bug fix 有回归测试 | ✅ 值得建 |
| `prototype-code` | prototypes/** | 标准放宽/隔离/README/成功后重写而非迁移 | ✅ |
| `shader-code` | assets/shaders/** | 命名（含 M_Env_Water 示例）/禁 magic number/half 精度/禁循环内读纹理 | ✅ 已内建 UE 命名 |

### 3.4 机制

**12 个 Hooks**（session-start/detect-gaps/validate-commit/validate-push/validate-assets/validate-skill-change/notify/pre-compact/post-compact/session-stop/log-agent/log-agent-stop）— 全部 bash 逻辑可移植；opencode 有等价事件则挂载，否则用 **SEA 脚本替代**（scan-secrets/audit-skill/validate-memory 已有同类职责）；git 校验转 git hooks/CI。

**Gate 机制**：评审强度 full/lean(默认)/solo；三态判定 APPROVE/CONCERNS/REJECT；并行取最严；gate ID 前缀 CD-/TD-/PR-/LP-/QL-/ND-/AD-；skill 只按 ID 引用不内嵌 prompt；**阶段门 ADVISORY 不硬阻断**。

**委派模型**：垂直委派不跳层/同层横向咨询/冲突升级共享父级/变更传播 producer 协调；反模式（跳层决策/跨域实现/影子决策/单体任务/基于假设实现）。

**模型分层**：Haiku=只读格式化/Sonnet=默认实施/Opus=综合+gate 裁决。

### 3.5 5 个 UE 专家 agent 完整要点

**`unreal-specialist`**（UE 组长，Delegates to 4 子专家）
- BP vs C++ 决策（系统 C++/内容 BP）；C++ 标准（UPROPERTY/UFUNCTION/GENERATED_BODY、TObjectPtr、F/E/U/A/I 前缀、FName/FText/FString 区分、TArray/TMap/TSet、NewObject/CreateDefaultSubobject、smart pointers）
- GAS 全能力；性能（SCOPE_CYCLE_COUNTER/避免 Tick/对象池/流送/Nanite+Lumen/Insights）；网络（DOREPLIFETIME/RPC 纪律）；资产（Soft References/Primary Asset ID/Data Tables）；7 条坑清单
- 触发：新插件/BP-vs-C++/GAS/复制/性能/打包必咨询

**`ue-gas-specialist`**
- 能力生命周期（ActivateAbility/EndAbility）；成本/冷却走 GE；CanActivateAbility+CommitAbility；Ability Tasks（OnCancelled/EndTask/复制）
- GE 三分法（Duration/Infinite/Instant）+ Stacking + Executions/Modifiers + 数据驱动
- Attribute Set（PreAttributeChange/PostGameplayEffectExecute、min/max、基值 vs 当前值、禁循环依赖、Data Table 初始化）
- Gameplay Tags 层级（State.Dead、集中定义）；预测（LocalPredicted/FPredictionKey/ASC 复制模式 Full/Mixed/Minimal）；7 条反模式

**`ue-blueprint-specialist`**
- BP/C++ 边界两表（Must Be C++ 8 类 / Can Be BP 7 类）；C++=框架/BP=内容/hooks 模式
- 图洁净度（每函数 ≤20 节点/注释块/Reroute/Comment boxes）
- 命名（BP_/BPI_/BPFL_/E_/S_/bIsAlive PascalCase）；接口优先于 Cast；data-only BP vs Data Table(100+)
- 事件分发器（BeginPlay 绑定/EndPlay 解绑/禁轮询）；性能（禁 Tick/缓存引用/BP profiler）；7 项审查清单

**`ue-replication-specialist`**
- 属性复制（DOREPLIFETIME + COND_OwnerOnly/SkipOwner/InitialOnly/Custom、ReplicatedUsing+OnRep_、不复制派生值、FRepMovement）
- RPC（Server 必验证+限速/Client 少用/NetMulticast 分 Reliable-Unreliable/小载荷）
- 客户端预测（CMC/可回滚/FPredictionKey/平滑校正）
- Relevancy/Dormancy（NetRelevancyDistance/DORM_/NetPriority/bOnlyRelevantToOwner/NetUpdateFrequency）
- 带宽（量化/FVector_NetQuantize/delta 序列化/dirty flags/<10KB/s）；复制层安全；7 条反模式

**`ue-umg-specialist`**
- Widget 分层（HUD/Menu/Popup/Overlay 四层）；CommonUI（UCommonActivatableWidget 栈/队列/CommonInputActionDataBase/UCommonButtonBase）
- 数据绑定（ViewModel/WidgetController/Gameplay Tag 事件/禁轮询/ListView 用 UObject entry）
- Widget Pooling；样式中心化（三主题）；FText 本地化；平台输入提示（UCommonInputSubsystem）
- 性能（Collapsed 而非 Hidden/Invalidation Box/UI<2ms/stat slate）；无障碍；8 条反模式

### 3.6 7-phase workflow-catalog

| Phase | 关键步骤（required） |
|---|---|
| 1 Concept | setup-engine(b) → game-concept(b) → art-bible(b) → map-systems(b) |
| 2 Systems Design | design-system(每系统) → design-review(每 GDD) → review-all-gdds(b) → consistency-check |
| 3 Technical Setup | create-architecture(b) → architecture-decision(min 3 ADR) → architecture-review(b) → control-manifest(b) → accessibility-doc(b) |
| 4 Pre-Production | entity-inventory → asset-spec → ux-design(min 3 屏) → ux-review → prototype → create-epics(b) → create-stories(b) → test-setup → sprint-plan(b) → vertical-slice |
| 5 Production | sprint-plan(每 sprint) → story-readiness → dev-story(b) → code-review → story-done(b) → qa-plan → bug-* → retrospective → team-* → scope-check |
| 6 Polish | perf-profile → balance-check → asset-audit → playtest-report(min 3) → team-polish(b) |
| 7 Release | release-checklist(b) → patch-notes → changelog → launch-checklist(b，终点) |

**机制**：artifact glob 检查（b=阻断进入下一阶段）；阶段门 ADVISORY 不硬阻断；用户始终最终决定权。

---

## 4. 综合蒸馏：UE 项目最终采用清单

### 4.1 Agents（推荐分批建设）

**第一批（核心 4，已完成初版）**
- `unreal-director`（改编自 CCGS technical-director + unreal-specialist 组长角色）——技术决策/版本锚定/委派
- `unreal-specialist`（CCGS UE 组长）——GAS/性能/资产/C++ 标准
- `ue-blueprint-specialist`（CCGS）——BP 边界/图质量
- `ue-replication-specialist`（CCGS）——网络/复制

**第二批（扩展）**
- `ue-gas-specialist`（CCGS）——GAS 深度
- `ue-umg-specialist`（CCGS）——UI/CommonUI
- `unreal-technical-artist`（agency-agents + CCGS 合并）——渲染/VFX/PCG
- `unreal-world-builder`（agency-agents）——开放世界
- `unreal-multiplayer-architect`（agency-agents）——网络架构顶层
- `ue-performance-auditor`（agent-skills web-perf 改造 + Metric-Honesty）——性能审计
- `ue-reviewer` / `ue-security-auditor` / `ue-test-engineer`（agent-skills 三 persona 改编）
- `ue-reality-checker`（agency-agents testing）——证据认证/质量门

**第三批（流程层）**
- game-designer / economy-designer / level-designer / narrative-designer（agency-agents + CCGS）
- producer / qa-lead / release-manager（CCGS）
- 游戏设计/叙事/美术类（引擎无关，CCGS 直接用）

### 4.2 Skills（推荐分批建设）

**第一批（核心 8，已完成初版）**
- design：ue-game-spec（GDD 8 节）、ue-version-anchor（版本锚定）
- build：ue-blueprint-cpp-boundary、ue-test-driven-dev（UE Automation）
- verify：ue-debugging、ue-perf-profile（Insights/stat）
- review：ue-code-review（五轴 + UE 专项）
- ship：ue-release-checklist

**第二批（流程技能，改编自 CCGS/agent-skills）**
- ue-planning / ue-spec-driven-dev / ue-incremental-implementation / ue-source-driven-dev / ue-context-engineering / ue-adr（文档决策）/ ue-deprecation-migration（版本迁移）/ ue-observability（UE_LOG/Trace）/ ue-ci-cd / ue-security-audit（反作弊/网络校验）/ ue-localization / ue-shipping-launch（平台认证）

**第三批（元/编排技能）**
- ue-skill-routing（using-agent-skills 改编）/ ue-team-orchestration（team-* 改编，含 UE 路由表）/ ue-gate-check（gate 机制）/ ue-prototype-vertical-slice

### 4.3 Rules（路径作用域编码标准，推荐 UE 项目建）
`ue-gameplay-code` / `ue-engine-code` / `ue-ai-code` / `ue-network-code` / `ue-ui-code` / `ue-shader-code` / `ue-design-docs`（GDD 8 节）/ `ue-test-standards`（每 bug 有回归测试）/ `ue-prototype-code` / `ue-data-files`（改 DataTable/DataAsset 版）——共 10 条，路径作用域自动生效。

### 4.4 机制（跨三仓库吸收）
| 机制 | 来源 | 落地 |
|---|---|---|
| SKILL.md 解剖 + 反合理化表 + 证据化验证门 | agent-skills | 已纳入技能模板 |
| Metric-Honesty（绝不虚构指标） | agent-skills | 写入评测类技能 |
| 版本锚定（VERSION.md + 知识截止 + 先查再断言） | CCGS | `docs/engine-reference/unreal/` + SEA verify-versions |
| 路径作用域编码规则 | CCGS | opencode rules |
| 委派层级 + gate 质量门 + ADVISORY | CCGS | subagent 编排 + topology.json |
| Collaborative-Not-Autonomous 协议 | CCGS | 所有 agent 定义 |
| 并行扇出（/ship 范式） | agent-skills | 发布门多 agent 并行 |
| 单源多工具渲染 | agency-agents | 需要时建 convert 脚本 |
| Dev↔QA 循环 + 3 次重试升级 | agency-agents | 开发流水线 SOP |
| 证据驱动 QA（reality-checker） | agency-agents | 质量门 |
| evals Tier2 触发/路由层 | agent-skills | SEA 增强（可选） |
| 压力用例（time-pressure 等） | agent-skills | 技能评测集增强 |

### 4.5 不吸收清单
- agent-skills web 专属：frontend-ui/browser-testing/CWV 指标/webperf 命令
- agency-agents 非游戏 divisions：marketing/sales/paid-media/finance/gis/healthcare/academic 等业务向 specialized（40+）
- CCGS Unity/Godot agent 组；hooks/settings.json/statusline 需移植为 opencode/SEA 等效

---

*来源：m-20260820-012（三仓库蒸馏价值分层）。本目录随 UE 成品包建设持续更新。*
