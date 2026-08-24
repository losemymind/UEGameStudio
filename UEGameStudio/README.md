# UE Game Studio — Agents & Skills 成品包

> 面向游戏开发智能化的**直接可安装** Agents 与 Skills 成品包。
> 目标平台：opencode / OpenWork（subagent + skill 机制）。支持安装到**单个游戏项目**或**全局**。
>
> 当前版本：`0.5.0`（见 `VERSION`；安装说明见 `INSTALL.md`）

## 这是什么

把游戏开发工作室的完整智能化工序蒸馏为**可复用、可验证、可进化**的资产。分类方式对齐业界成熟的工作室职能层级（Tier 1 导演 → Tier 2 主管 → Tier 3 专项 → 学术支持组）：

- **agents/** — 按职能层级分类（directors / leads / designers / programmers / artists / qa / operations / academic）
- **skills/** — 按生命周期分类（gate / review / readiness / pipeline / authoring / analysis / team / sprint / utility）

内容来自业界成熟 agent 技能库与游戏工作室工作流的方法论蒸馏与本地化适配，命名规范参考 [jnMetaCode/agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh)。随版本持续迭代。

## 资产清单

### Agents（41 个，9 类）

| 分类 | 数量 | 内容 |
|---|---|---|
| `directors/` | 3 | creative-director · technical-director · game-producer（Tier 1 导演层） |
| `leads/` | 7 | game-designer · lead-programmer · art-director · audio-director · narrative-director · qa-lead · release-manager（Tier 2 主管层） |
| `designers/` | 8 | economy-designer · level-designer · systems-designer · world-builder · narrative-designer · live-ops-designer · writer · ux-designer（Tier 3 设计组） |
| `programmers/` | 5 | engine-programmer · gameplay-programmer · blueprint-developer · ui-developer · prototyper（Tier 3 编程组） |
| `artists/` | 2 | technical-artist · sound-designer（Tier 3 美术/音频组） |
| `qa/` | 6 | qa-tester · crash-analyst · performance-analyst · quality-diagnostics-expert · accessibility-specialist · reality-checker（Tier 3 QA 组） |
| `operations/` | 6 | devops-engineer · security-engineer · analytics-engineer · studio-operations · localization-specialist · community-manager（Tier 3 运维/本地化/社区） |
| `academic/` | 4 | historian · anthropologist · geographer · psychologist（学术支持组，按需咨询） |
| `utility/` | 1 | image-captioner（图片→结构化文字，服务资产/关卡/UX 规格） |

### Skills（42 个，11 类）

| 分类 | 数量 | 技能 |
|---|---|---|
| `onboarding/` | 3 | start · setup-engine · project-stage-detect |
| `design/` | 6 | brainstorm · design-system · design-review · balance-check · consistency-check · ux-design |
| `architecture/` | 4 | create-architecture · architecture-decision · architecture-review · art-bible |
| `planning/` | 5 | create-epics · create-stories · dev-story · sprint-plan · estimate |
| `dev/` | 4 | prototype · vertical-slice · reverse-document · localize |
| `review/` | 3 | code-review · gate-check · scope-check |
| `qa/` | 5 | qa-plan · smoke-check · regression-suite · bug-report · bug-triage |
| `release/` | 4 | release-checklist · launch-checklist · changelog · hotfix |
| `production/` | 2 | milestone-review · retrospective |
| `team/` | 5 | team-combat · team-level · team-ui · team-qa · team-polish |
| `perf/` | 1 | perf-profile |

> **目录说明**：`agents/`、`skills/` 内采用分类子文件夹。安装脚本会**展平复制**到目标目录（见 `INSTALL.md`），opencode 加载器递归扫描、自进化运行时校验均兼容。

## 快速安装

```powershell
# 方式一：安装到全局（所有项目可用）
# 用 INSTALL.md 的展平脚本（递归收集 agent/*.md 与 SKILL.md 目录）

# 方式二：安装到某个游戏项目
# 用 INSTALL.md 的展平脚本复制到 <项目>\.opencode\agents\ 与 <项目>\.opencode\skills\
```

详见 `INSTALL.md`（含展平安装脚本）。

## 配套要求

- **可选**：自进化运行时（SEA 等）——提供记忆蒸馏/评估/棘轮进化机制。本成品包纯资产，不强制依赖；装了此类运行时后技能可纳入进化闭环。
- 平台：opencode / OpenWork（其他 agent 平台需自行适配格式）。

## 目录

```
UEGameStudio/
├── README.md         # 本文件
├── INSTALL.md        # 安装指南（全局 / 项目，含展平安装脚本）
├── VERSION           # 成品版本号
├── agents/           # 41 个 agent（按职能层级分类）
│   ├── directors/    #   Tier 1 导演层（3）
│   ├── leads/        #   Tier 2 主管层（7）
│   ├── designers/    #   Tier 3 设计组（8）
│   ├── programmers/  #   Tier 3 编程组（5）
│   ├── artists/      #   Tier 3 美术/音频组（2）
│   ├── qa/           #   Tier 3 QA 组（6）
│   ├── operations/   #   Tier 3 运维/本地化/社区（6）
│   ├── academic/     #   学术支持组（4，按需咨询）
│   └── utility/      #   工具类（1：image-captioner）
├── skills/           # 42 个技能（11 类，去重合并后）
│   ├── onboarding/ on combat/ on design/ 
│   ├── architecture/ planning/ dev/ review/
│   ├── qa/ release/ production/ team/ perf/
│   └── _evolutions/
├── rules/            # 10 条路径作用域编码规则（ue-*）
├── docs/             # engine-reference/unreal/VERSION.md 版本锚定
└── references/       # 共享清单
```
