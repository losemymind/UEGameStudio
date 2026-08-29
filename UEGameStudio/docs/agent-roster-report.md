# UEGameStudio 智能体阵容报告

## 报告信息

| 项目 | 内容 |
| --- | --- |
| 盘点日期 | 2026-08-29 |
| 盘点范围 | `UEGameStudio/agents/**/*.md` |
| 统计规则 | 仅统计当前实际存在的 Agent 定义；排除 `_template.md` 和 Git 中已删除的旧 Agent |
| 当前数量 | 28 |
| 运行模式 | 全部为 `mode: subagent` |
| 项目边界 | 本地 UE 游戏开发至生成本地游戏构建包；不包含商店提交、平台认证、正式发布与 LiveOps |

## 执行摘要

当前阵容已经形成“总控编排—创意/技术/生产决策—专业设计—功能与资产实施—独立验证—本地构建”的完整骨架。新增 13 个 Agent 补齐了纯文本核心系统、具体 Gameplay、AI、关卡任务设计、地图集成、角色动画、UI、视听方向、资产生命周期、视觉资产制作、技术美术、音频和工具管线。

体系按核心数据源和资产包所有权分工：纯文本底座、具体 Gameplay、AI、动画、UI、视觉技术资产、音频资产和地图资产分别有唯一主责。二进制 `.uasset` 只能通过 UE Editor 或受控编辑器自动化修改；实施者不能替代 QA、性能、合规与构建门禁。

2026-08-28 全阵容审计后的确定性整改已经落盘：人类学家已收敛为只读研究权限并补齐证据、Canon 与文化敏感性边界；游戏制作人已严格限制为本地开发和本地游戏构建包，并只路由到实际存在的 Agent；总监路由、纯文本写入白名单、视听 Provenance、UI/音频可访问性和 Plan ID 唯一性规则已同步强化。静态检查与安装回归通过；真实 UE Editor、Commandlet、DCC、音频、性能和构建行为仍需在目标项目验证。

2026-08-29 将人类学家进一步通用化：其专业输入和输出不再硬编码游戏世界、目标玩家、Canon 或 `game-director`，而由每次委派提供应用场景、受众、既定前提和决策责任人。UEGameStudio 中的游戏语境由游戏总设计师注入，Canon 裁决和游戏化转译仍归游戏总设计师；未新增重复的“游戏人类学家”。

## 当前阵容总览

```text
总控编排专家
├─ 游戏总设计师
│  ├─ 人类学家
│  ├─ 地理学家
│  ├─ 历史学家
│  ├─ 叙事学家
│  ├─ 心理学家
│  ├─ 首席游戏数值专家
│  ├─ 首席游戏经济专家
│  ├─ 关卡与任务设计专家
│  └─ 游戏视听总监
├─ 技术总监
│  ├─ UE 核心系统工程师
│  ├─ UE 游戏玩法工程师
│  ├─ 游戏 AI 系统工程师
│  ├─ UE 游戏世界构建师
│  ├─ 角色动画工程师
│  ├─ UE UI 工程师
│  ├─ UE 技术美术工程师
│  ├─ 游戏音频技术专家
│  ├─ UE 工具与资产管线工程师
│  ├─ 性能剖析专家
│  └─ UE 游戏构建专家
└─ 游戏制作人
   ├─ 游戏资产生产管理专家
   ├─ 游戏视觉资产制作专家
   ├─ 资产合规与审计专家
   └─ QA 测试专家
```

该结构表示主要责任关系，不代表专业 Agent 只能由单一负责人调用。跨域任务由总控编排专家建立依赖、门禁和交接关系。

## 一、总控编排层

| Agent | 英文 ID | 核心责任 | 权限画像 |
| --- | --- | --- | --- |
| [总控编排专家](../agents/orchestration/orchestration-director.md) | `orchestration-director` | 新任务首次强制提问、98% 需求理解与用户确认门禁、递归任务树落盘、专业路由、依赖编排、规划期澄清、状态治理、冲突升级与综合交付 | 需求确认后可读取和委派；只能编辑 `.opencode/task-plans/**`，不可执行命令或联网 |

总控编排专家不替代专业判断，也不直接实施项目变更。每个新任务的首次响应必须先提问，不得读取项目、规划、委派或实施；只有需求理解置信度达到 98%、需求摘要经用户明确确认，且规划期未知项得到澄清后，才可形成任务计划。计划进入 `PLAN_READY` 后，总控以 `M0` 为根将递归任务树写入 `.opencode/task-plans/<Plan-ID>/`，再开始委派。它负责确认谁决定、谁实施、谁验证，以及每项工作何时可以进入下一阶段。

## 二、项目决策层

| Agent | 英文 ID | 决定什么 | 不决定什么 | 权限画像 |
| --- | --- | --- | --- | --- |
| [游戏总设计师](../agents/directors/game-director.md) | `game-director` | 做什么、为什么做、玩家获得什么体验；愿景、设计支柱、Canon、核心循环与系统需求 | UE 实现、人员排期和构建执行 | 可读取和委派；不可编辑、执行命令或联网 |
| [技术总监](../agents/directors/technical-director.md) | `technical-director` | 如何在 UE 中实现；技术战略、架构、ADR、非功能预算、技术风险与技术门禁 | 创意愿景、正式排期和直接实施 | 可读取和委派；不可编辑、执行命令或联网 |
| [游戏制作人](../agents/directors/game-producer.md) | `game-producer` | 由谁做、何时做、按什么依赖和里程碑推进；范围、产能、风险与生产门禁 | 创意目标、技术架构和直接执行 | 可读取和委派；不可编辑、执行命令或联网 |
| [游戏视听总监](../agents/directors/audiovisual-director.md) | `audiovisual-director` | 批准体验目标在美术、动画、VFX、UI 与声音中的表达语言和创意质量 | 核心玩法、技术架构、排期和直接资产制作 | 可读取和委派；不可编辑、执行命令或联网 |

游戏视听总监接受游戏总设计师的体验与 Canon 基线。创意、技术与生产约束无法同时满足时，应形成可比较选项并提交用户裁决，不允许任何一方静默覆盖其他领域的决定。

## 三、学术研究层

| Agent | 英文 ID | 专业覆盖 | 典型交付 |
| --- | --- | --- | --- |
| [人类学家](../agents/academic/academic-anthropologist.md) | `academic-anthropologist` | 现实或虚构社会的文化、亲属、仪式、信仰、生计、交换与社会权力 | 文化模型、制度关系、民族志式分析、敏感性风险与应用选项 |
| [地理学家](../agents/academic/academic-geographer.md) | `academic-geographer` | 地形、气候、水文、资源、聚落、交通和地缘关系 | 地理一致性、空间因果与地图约束 |
| [历史学家](../agents/academic/academic-historian.md) | `academic-historian` | 时间线、物质文化、制度变迁、时代条件和历史因果 | 史实核验、时代错误与反事实影响 |
| [叙事学家](../agents/academic/academic-narratologist.md) | `academic-narratologist` | 叙事结构、信息流、人物弧、类型承诺、玩家选择和主题 | 叙事诊断、因果链与改稿方案比较 |
| [心理学家](../agents/academic/academic-psychologist.md) | `academic-psychologist` | 人格、动机、信念、压力反应、关系动力和成长轨迹 | 角色心理模型、冲突机制与行为预测 |

五位学术专家均使用默认拒绝的只读研究权限，提供专业分析、证据、假设和风险，不直接决定正式 Canon。人类学家保持通用研究角色，额外负责现实文化借用、Provenance、授权状态、群体内部差异与敏感性风险分析；其应用场景、受众和决策责任人由委派契约提供。在 UEGameStudio 中，游戏总设计师注入游戏语境、负责取舍并完成 Canon 裁决和游戏化转译。

## 四、专业设计层

| Agent | 英文 ID | 核心责任 | 主要门禁 |
| --- | --- | --- | --- |
| [首席游戏数值专家](../agents/design/lead-game-balance-designer.md) | `lead-game-balance-designer` | 战斗、成长、资源、掉落与随机系统的公式、参数、曲线、边界、模拟和调参 | `BAL-FORMULA`、`BAL-COMBAT`、`BAL-PROGRESSION`、`BAL-RANDOM`、`BAL-CROSS-SYSTEM` |
| [首席游戏经济专家](../agents/design/lead-game-economy-designer.md) | `lead-game-economy-designer` | 游戏包内货币、资源、物品与服务的价值结构、产出消耗、库存、转换和稳定性 | `ECO-STRUCTURE`、`ECO-FLOW`、`ECO-PRICING`、`ECO-PROGRESSION`、`ECO-STABILITY` |
| [关卡与任务设计专家](../agents/design/level-mission-designer.md) | `level-mission-designer` | 玩家路径、空间节奏、任务状态、遭遇 Brief、检查点与失败恢复 | `LEVEL-FLOW`、`MISSION-STATE`、`ENCOUNTER-BRIEF`、`LEVEL-ACCEPTANCE` |

三者的职责分界：

```text
游戏总设计师：定义体验和机制目的
首席游戏经济专家：定义资源结构、价值关系与稳定目标
首席游戏数值专家：定义公式、参数、曲线和概率
技术总监：决定 UE 实现和数据管线
QA 测试专家：验证实际功能和构建包行为
```

数值和经济专家可以执行本地只读分析和模拟，但不能直接修改代码、Blueprint、DataTable、资产或配置。关卡与任务设计专家的 `edit` 仅用于任务级精确路径白名单内的纯文本 Level/Mission Brief 与设计交付，不得创建或修改 `.uasset`、`.umap` 或最终生产地图。

## 五、功能开发与世界集成层

| Agent | 英文 ID | 核心责任 | 资产或写入边界 |
| --- | --- | --- | --- |
| [UE 核心系统工程师](../agents/technical/ue-core-systems-engineer.md) | `ue-core-systems-engineer` | Module、Subsystem、公共接口、组件与生命周期基础设施 | 仅纯文本 C++、构建规则和文本配置；禁止 `.uasset` 和具体网络业务 |
| [UE 游戏玩法工程师](../agents/technical/ue-gameplay-engineer.md) | `ue-gameplay-engineer` | 具体玩法、运行时任务真值、Gameplay Actor、GA/GE，以及 Replication、RPC、Relevancy、预测与回滚 | 当前功能所属 Gameplay 源码和资产；禁止 Map、UMG 及专业表现资产 |
| [游戏 AI 系统工程师](../agents/technical/game-ai-engineer.md) | `game-ai-engineer` | 感知、Behavior Tree、StateTree、Blackboard、EQS、导航查询与战术决策 | AIController、AI 源码与 AI 专属资产；禁止遭遇设计和地图摆放 |
| [UE 游戏世界构建师](../agents/technical/ue-world-builder.md) | `ue-world-builder` | Map、World Partition、Data Layer、Level Instance、PCG 与最终空间组装 | 只拥有地图级 Package 和白名单实例参数；禁止 Blueprint CDO、Construction Script 与类资产 |
| [角色动画工程师](../agents/technical/character-animation-engineer.md) | `character-animation-engineer` | Retarget、AnimBP、Montage、Motion Warping、Control Rig、IK 与动画优化 | 动画资产及动画专属 C++；禁止战斗结算和模型源资产创作 |
| [UE UI 工程师](../agents/technical/ue-ui-engineer.md) | `ue-ui-engineer` | UMG、CommonUI、Widget C++、数据绑定、输入焦点、HUD、菜单与适用的 UI 可访问性 | UI 源码和 Widget 资产；禁止核心玩法、任务和战斗计算 |

功能实施遵循“公共底座—具体业务—专业集成”的依赖方向。关卡任务专家拥有任务设计语义，UE 游戏玩法工程师拥有运行时权威任务状态、Save/Load 和多人复制，世界构建师只摆放实例，UI 只读展示。具体玩法只通过批准接口调用 AI、动画、UI、音频和视觉表现，不能因为需要引用资产而取得其写入权。

## 六、资产制作与管理层

| Agent | 英文 ID | 核心责任 | 资产或写入边界 |
| --- | --- | --- | --- |
| [游戏资产生产管理专家](../agents/production/game-asset-production-manager.md) | `game-asset-production-manager` | 父子 Asset ID、Brief、版本、状态、依赖、Provenance 与多门禁就绪管理 | 只写授权纯文本登记；只读清点；不修改任何 `.uasset`、`.umap` 或内容资产 |
| [游戏视觉资产制作专家](../agents/production/game-visual-asset-artist.md) | `game-visual-asset-artist` | 角色、环境、道具、纹理的视觉源资产与规范导出物 | 源内容和导出物；禁止运行时系统、地图和技术资产 |
| [UE 技术美术工程师](../agents/technical/ue-technical-art-engineer.md) | `ue-technical-art-engineer` | 材质、Shader、Niagara、导入设置、LOD/Nanite 与视觉性能适配 | 技术美术 Package 和授权资产技术设置 |
| [游戏音频技术专家](../agents/technical/game-audio-technical-specialist.md) | `game-audio-technical-specialist` | SFX、环境声、音乐、对白、MetaSound/Wwise、空间声学、对白动态和字幕/替代通道交接 | 音频源文件和音频资产；禁止 Gameplay、动画、UI 和地图内部逻辑 |
| [UE 工具与资产管线工程师](../agents/technical/ue-tools-pipeline-engineer.md) | `ue-tools-pipeline-engineer` | Editor Utility、Python、Commandlet、DCC 导入、批处理与资产验证 | 只执行授权批次；工具能力不扩大目标资产所有权 |

角色动画工程师同时参与功能表现链和资产生产链，但每项动画任务仍具有唯一主责。全部二进制资产只能通过目标 UE 版本的 Editor 或受控编辑器自动化修改；不能通过文本或字节补丁修改 `.uasset`。

## 七、质量、审计与技术验证层

| Agent | 英文 ID | 核心责任 | 门禁或结论 |
| --- | --- | --- | --- |
| [资产合规与审计专家](../agents/qa/asset-compliance-auditor.md) | `asset-compliance-auditor` | 命名、目录、引用、导入设置、预算、Cook 范围、来源记录和项目规范审计 | 资产合规门禁；只审计，不自动修复 |
| [QA 测试专家](../agents/qa/qa-test-specialist.md) | `qa-test-specialist` | 功能、集成、探索、回归和本地构建包 Smoke Test | `QA-FUNCTIONAL`、`QA-INTEGRATION`、`QA-REGRESSION`、`QA-PACKAGE` |
| [性能剖析专家](../agents/technical/performance-profiler.md) | `performance-profiler` | CPU、GPU、内存、加载与卡顿采集，瓶颈定位和优化前后验证 | `PERF-BUDGET`；测量和证明，不直接修复 |
| [UE 游戏构建专家](../agents/technical/ue-build-engineer.md) | `ue-build-engineer` | UBT、UAT、BuildCookRun、BuildGraph，以及本地 Build、Cook、Stage、Package | 可追溯的本地构建产物；不负责商店提交或部署 |

这四个角色保持相互独立：构建成功不等于 QA 通过，功能正确不等于性能达标，资产可加载也不等于资产合规。

## 权限与风险画像

### 编排权限

总控编排专家、游戏总设计师、技术总监、游戏制作人和游戏视听总监具有 `task: allow`，用于调用其他专业 Agent。除总控可通过细粒度 `edit` 规则维护 `.opencode/task-plans/**` 外，这些角色均禁止编辑和命令执行；总控的计划记录权不包含源码、配置、资产或普通项目文档，仍符合“决策与实施分离”的原则。

### 分析与验证权限

- 首席游戏数值专家和首席游戏经济专家可运行本地计算，但禁止编辑项目。
- 资产合规、QA 和性能剖析专家可执行诊断命令，但禁止直接修复项目。
- 性能剖析专家允许访问外部目录，用于目标构建、Capture 或引擎工具；需要保持路径和证据范围明确。

### 实施权限

新增功能、世界、资产和管线 Agent 具有与其实施职责匹配的 `edit`、`bash`、必要的 `lsp` 及 `external_directory` 权限。权限不代表任意项目写入权；每个 Agent 的正文进一步限定可写源码、Package、外部工具和目录。

每个实施任务还必须由总控编排专家提供精确的文本路径、Package、新对象、操作类型和外部工具白名单。交付时比较预期写入与实际修改清单；任何越界写入都不能被接受。

- UE 核心系统工程师只改纯文本底座，明确禁止 `.uasset`。
- Gameplay、AI、动画、UI、技术美术、音频与世界构建 Agent 只拥有其列明资产类型。
- 资产生产管理专家只在任务级路径白名单内维护纯文本 Manifest、Brief、Provenance 和状态；Bash 仅用于授权的清点与只读核验，外部目录仅限显式授权来源/交付目录，不直接修改内容资产。
- 工具管线工程师必须先 Dry Run，批处理能力不扩大资产所有权。
- UE 游戏构建专家继续只负责构建配置、脚本和本地构建产物。

### 当前权限结论

排除 `_template.md` 后，28 个 Agent 均以 `"*": deny` 为默认权限。人类学家现与其他学术专家一致，仅开放读取、检索、联网研究、技能读取和提问能力，禁止编辑、命令执行、委派、LSP 与外部目录。关卡任务设计和资产生产管理仍保留职责所需的 `edit`，但正文已将其限定为任务授权的纯文本交付路径；资产生产管理的 Bash 与外部目录能力也具有任务级白名单和只读操作边界。

## 主要协作链路

### 总控需求与规划门禁

```text
接收新任务
→ 首次响应必须提问，不读取项目、不规划、不委派、不实施
→ 迭代澄清目标、交付物、范围、约束、授权与验收条件
→ 需求理解置信度达到至少 98%
→ 展示需求理解摘要并取得用户明确确认
→ 读取实际阵容与项目上下文
→ 制定任务计划
→ 规划存在不确定项则暂停并提问
→ 未知项解决后进入 PLAN_READY
→ 生成 Plan ID 并落盘 M0 递归任务树
→ 委派与执行
```

用户对需求摘要的纠正或实质追加会使旧确认失效，总控必须重置置信度和确认状态。规划期问题如果改变目标、范围、固定决策、授权或验收条件，也必须返回需求澄清门禁，不得沿用旧计划。任务树使用 `M0`、`M0.1`、`M0.1.1` 等稳定路径式 ID；节点有子任务时才创建同名目录，父子包含关系与显式执行依赖分别记录。Plan ID 使用记录时区的秒级时间戳；同秒同名冲突依次追加 `-02`、`-03`，不得覆盖既有目录。

### 世界设定与玩法定义

```text
总控编排专家
→ 游戏总设计师
→ 注入游戏世界、目标玩家、Canon 与表达媒介等应用语境
→ 选择最小充分的学术专家组合
→ 专业分析、证据与风险
→ 游戏总设计师进行 Canon 裁决和游戏化转译
→ 世界设定基线、玩法支柱、系统需求与设计任务
```

### 经济与数值设计

```text
游戏总设计师定义体验与机制规则
→ 首席游戏经济专家建立资源结构与价值目标
→ 首席游戏数值专家建立公式、参数与模拟
→ 首席游戏经济专家复核宏观稳定性
→ 游戏总设计师裁决体验取舍
→ 技术总监形成 UE 技术工作包
```

非经济性的战斗、成长或随机问题可以由游戏总设计师直接委派给首席游戏数值专家。

### 游戏功能开发

```text
游戏总设计师定义体验与机制
→ 技术总监批准架构、接口、数据所有权和预算
→ 关卡与任务设计专家定义任务设计语义和状态转换
→ UE 核心系统工程师实现纯文本公共底座
→ UE 游戏玩法工程师实现具体业务、运行时权威任务状态、C++、Gameplay Blueprint 和多人同步
→ AI、动画、UI、音频和技术美术按各自资产所有权集成
→ 关卡任务设计专家定义流程与遭遇
→ UE 游戏世界构建师完成地图空间组装
→ QA、性能与构建专家独立验证
```

### 游戏资产生产

```text
游戏总设计师定义体验目标
→ 游戏视听总监定义视听语言和创意标尺
→ 游戏资产生产管理专家建立 Asset ID、Brief、依赖和门禁
→ 视觉资产、动画、音频与技术美术专家生产和技术化
→ UE 工具与资产管线工程师提供受控导入和批处理
→ Gameplay、UI 或世界构建 Agent 按契约引用和集成
→ 资产审计、性能与 QA 独立验证
```

跨链交接使用运行时事件/状态契约和 Asset Brief。引用资产不转移资产所有权，工具自动化也不转移内容决定权。

实施型 Agent 统一使用 `BLOCKED_INPUT` 与 `BLOCKED_TOOLING`。两者可以同时存在；阻断时整体状态为 `BLOCKED`，只允许输出明确标记的 `DRAFT_ONLY` 文本工件，并列出解除条件和禁止声称通过的门禁。核心系统的 `BLOCKED_ARCHITECTURE` 是专业化输入阻断，资产审计继续使用 `BLOCKED_UNVERIFIED`。

### 本地构建包验证

```text
技术总监批准技术方案和预算
→ UE 游戏构建专家执行 Build / Cook / Stage / Package
→ 资产合规与审计专家检查资产和 Cook 范围
→ QA 测试专家独立执行包体 Smoke 与回归
→ 性能剖析专家在目标构建和场景中验证性能预算
→ 游戏制作人综合生产门禁
```

实际顺序可以根据风险调整，但实施者不能自行替代独立验证结论。

## 能力覆盖矩阵

| 能力域 | 当前状态 | 当前责任 Agent |
| --- | --- | --- |
| 跨域任务编排与递归计划树 | 已覆盖 | 总控编排专家 |
| 创意愿景与总体体验 | 已覆盖 | 游戏总设计师 |
| 世界设定专业研究 | 已覆盖 | 五位学术专家 |
| 数值和平衡 | 已覆盖 | 首席游戏数值专家 |
| 游戏包内经济 | 已覆盖 | 首席游戏经济专家 |
| UE 技术战略与架构 | 已覆盖 | 技术总监 |
| 范围、排期和生产门禁 | 已覆盖 | 游戏制作人 |
| 资产合规 | 已覆盖 | 资产合规与审计专家 |
| 功能与包体 QA | 已覆盖 | QA 测试专家 |
| 性能测量与瓶颈定位 | 已覆盖 | 性能剖析专家 |
| 本地 Build/Cook/Stage/Package | 已覆盖 | UE 游戏构建专家 |
| UE 纯文本核心系统实现 | 已覆盖 | UE 核心系统工程师 |
| 具体 UE 玩法、GAS 与多人网络同步 | 已覆盖 | UE 游戏玩法工程师 |
| 感知、决策、StateTree/BT/EQS | 已覆盖 | 游戏 AI 系统工程师 |
| 关卡路径、任务状态与遭遇设计 | 已覆盖 | 关卡与任务设计专家 |
| Map、World Partition、PCG 与空间集成 | 已覆盖 | UE 游戏世界构建师 |
| 角色动画控制与运行时优化 | 已覆盖 | 角色动画工程师 |
| UMG、CommonUI、HUD 与菜单 | 已覆盖 | UE UI 工程师 |
| 视听方向与创意验收 | 已覆盖 | 游戏视听总监 |
| 资产生命周期与交付管理 | 已覆盖 | 游戏资产生产管理专家 |
| 角色、环境、道具和纹理源资产 | 已覆盖 | 游戏视觉资产制作专家 |
| 材质、Shader、Niagara 与技术美术 | 已覆盖 | UE 技术美术工程师 |
| 音频生产与 UE 音频集成 | 已覆盖 | 游戏音频技术专家 |
| UE 编辑器工具与资产管线 | 已覆盖 | UE 工具与资产管线工程师 |
| 本地化专业策划与 LQA | 专职能力缺口 | 当前无独立 Agent；按任务记录 `CAPABILITY_GAP` 并由用户指定责任方 |
| 独立安全专业评审 | 专职能力缺口 | 当前无独立 Agent；不得由不匹配角色给出绑定性结论 |

## 当前治理问题

| 优先级 | 问题 | 影响 | 建议 |
| --- | --- | --- | --- |
| 中 | 当前没有统一机器可读的 Agent 注册表 | 28 个 Agent 仍只能通过目录扫描发现，编排时容易遗漏或使用过期身份 | 建立单一权威注册表并从实际文件验证 |
| 中 | 二进制资产实施依赖可用的 UE/DCC 控制能力 | 角色定义具备边界，但环境没有对应工具时只能输出计划 | 在具体项目接入时验证 Editor、Commandlet、DCC 与音频工具链 |
| 中 | 当前无独立本地化/LQA 与安全专业 Agent | 相关任务无法获得专职绑定性结论 | 按任务登记 `CAPABILITY_GAP`，由用户指定外部责任方或另行批准建设 |

## 当前成熟度判断

| 维度 | 判断 |
| --- | --- |
| 战略与治理 | 已形成稳定骨架 |
| 世界设定与设计研究 | 覆盖较完整 |
| 数值与经济设计 | 已具备专业分工和门禁 |
| 技术方案与生产规划 | 决策层和实施层均已覆盖 |
| 质量、性能与构建 | 已具备独立验证角色 |
| 游戏功能开发 | 已形成公共底座、具体业务、专项集成与世界组装链路 |
| 视听内容生产 | 已形成方向、管理、制作、技术化、管线和独立审计链路 |
| 总体结论 | `READY_WITH_CONCERNS`：本地 UE 游戏生产角色闭环和本轮确定性治理整改已完成；进入真实项目后仍需验证编辑器/DCC 工具可用性，并处理统一注册表与专职能力缺口 |

## 后续建设原则

1. 总控收到新任务后必须先提问；达到 98% 需求理解、取得用户对需求摘要的明确确认，并解决规划期未知项后，才能规划、委派与执行。
2. 总控在 `PLAN_READY` 后必须将计划落盘为 `.opencode/task-plans/<Plan-ID>/` 下以 `M0` 为根的递归任务树；只可编辑该目录，稳定节点 ID 不得重编号或复用。
3. 以核心数据源、资产包所有权和可验证交付物确定 Agent 边界，不按职位名称无限拆分。
4. 引用资产不转移写入权；跨域修改通过契约交回唯一所有者。
5. `.uasset` 只能通过 UE Editor 或受控自动化修改，工具不可用时返回 `BLOCKED_TOOLING`。
6. 关键输入缺失时返回 `BLOCKED_INPUT`；草案不得冒充批准基线或完成状态。
7. 每个实施任务使用路径、Package、操作和外部工具白名单，并核对实际写入。
8. 逻辑资产组与可生产子 Asset ID 分离，每个子对象只有一个内容写入主责。
9. 继续保持“制定—实施—验证”分离，实施者不能批准自己的创意、合规、性能或 QA 门禁。
10. 新 Agent 继续采用英文 kebab-case ID、中文专业正文和 `mode: subagent`。
11. 所有能力严格止于本地开发和构建游戏包，不扩展到商店、认证、正式发布与 LiveOps。
