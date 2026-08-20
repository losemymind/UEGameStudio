# UE Game Studio — Agents & Skills 成品包

> 面向游戏开发智能化的**直接可安装** Agents 与 Skills 成品包。
> 目标平台：opencode / OpenWork（subagent + skill 机制）。支持安装到**单个游戏项目**或**全局**。
>
> 当前版本：`0.4.0`（见 `VERSION`；安装说明见 `INSTALL.md`）

## 这是什么

把游戏开发工作室的完整智能化工序蒸馏为**可复用、可验证、可进化**的资产。分类方式对齐 [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) 的 Studio Hierarchy 与 Skill Testing Framework：

- **agents/** — 按职能层级分类（directors / leads / specialists / operations / qa / engine），引擎无关的职能角色通用，只有引擎专属专家才进 `engine/<engine>/`
- **skills/** — 按生命周期分类（gate / review / readiness / pipeline / authoring / analysis / team / sprint / utility）

内容来自三仓库蒸馏（agent-skills / agency-agents / Claude-Code-Game-Studios），蒸馏基准见本仓库根 `DISTILLED-REFERENCE.md` 与 `DISTILLED-CATALOG.md`。

## 资产清单

### Agents（39 个，6 类）

| 分类 | 数量 | 内容 |
|---|---|---|
| `directors/` | 4 | creative-director · technical-director · producer · art-director（Tier1 决策层） |
| `leads/` | 7 | lead-programmer · game-designer · systems-designer · level-designer · narrative-director · audio-director · qa-lead（Tier2 部门主管） |
| `specialists/` | 13 | gameplay/engine/ai/network/tools/ui-programmer · technical-artist · sound-designer · ux-designer · performance-analyst · prototyper · writer · world-builder |
| `operations/` | 7 | devops-engineer · release-manager · live-ops-designer · community-manager · analytics-engineer · economy-designer · localization-lead |
| `qa/` | 3 | qa-tester · security-engineer · accessibility-specialist |
| `engine/unreal/` | 5 | unreal-specialist · ue-gas-specialist · ue-blueprint-specialist · ue-replication-specialist · ue-umg-specialist（UE 引擎专属） |

### Skills（70 个，9 类）

| 分类 | 数量 | 用途 |
|---|---|---|
| `gate/` | 1 | gate-check（阶段门裁决） |
| `review/` | 3 | design-review · review-all-gdds · architecture-review |
| `readiness/` | 2 | story-readiness · story-done |
| `pipeline/` | 6 | create-epics · create-stories · dev-story · create-control-manifest · propagate-design-change · map-systems |
| `authoring/` | 7 | architecture-decision · design-system · quick-design · ux-design · ux-review · art-bible · create-architecture |
| `analysis/` | 12 | consistency-check · code-review · balance-check · asset-audit · content-audit · tech-debt · scope-check · estimate · perf-profile · security-audit · test-evidence-review · test-flakiness |
| `team/` | 9 | team-ui · team-combat · team-narrative · team-audio · team-level · team-polish · team-release · team-live-ops · team-qa |
| `sprint/` | 5 | sprint-plan · sprint-status · milestone-review · retrospective · changelog（含玩家向补丁说明） |
| `utility/` | 25 | start · help · setup-engine · skill-test · skill-improve · test-setup · test-helpers · smoke-check · soak-test · release-checklist（含上线级） · 等 |

> **目录说明**：`agents/`、`skills/` 内采用分类子文件夹。安装脚本会**展平复制**到目标目录（见 `INSTALL.md`），opencode 加载器递归扫描、SEA 校验均兼容。

## 快速安装

```powershell
# 方式一：安装到全局（所有项目可用）
# 用 INSTALL.md 的展平脚本（递归收集 agent/*.md 与 SKILL.md 目录）

# 方式二：安装到某个游戏项目
# 用 INSTALL.md 的展平脚本复制到 <项目>\.opencode\agents\ 与 <项目>\.opencode\skills\
```

详见 `INSTALL.md`（含展平安装脚本）。

## 配套要求

- **可选**：[SEA](https://github.com/losemymind/SEA) 运行时——提供记忆蒸馏/评估/棘轮进化机制。本成品包纯资产，不强制依赖；装了 SEA 后技能可纳入进化闭环。
- 平台：opencode / OpenWork（其他 agent 平台需自行适配格式）。

## 目录

```
UEGameStudio/
├── README.md         # 本文件
├── INSTALL.md        # 安装指南（全局 / 项目，含展平安装脚本）
├── VERSION           # 成品版本号
├── agents/           # 39 个 agent（按职能层级分类）
│   ├── directors/    #   Tier1 决策层（4）
│   ├── leads/        #   Tier2 部门主管（7）
│   ├── specialists/  #   核心专家（13）
│   ├── operations/   #   运营/发布（7）
│   ├── qa/           #   质量与安全（3）
│   └── engine/unreal/ #  UE 引擎专属（5）
├── skills/           # 70 个技能（按生命周期分类，每个含 SKILL.md + test-prompts.json）
│   ├── gate/ review/ readiness/ pipeline/ authoring/
│   ├── analysis/ team/ sprint/ utility/
│   └── _evolutions/  # 技能演进注册表（70 条 CAPTURED 谱系 + L0 基线）
├── rules/            # 10 条路径作用域编码规则（ue-*）
├── docs/             # engine-reference/unreal/VERSION.md 版本锚定
└── references/       # 共享清单
```
