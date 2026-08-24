---
name: project-stage-detect
description: 全项目审计：扫描目录与工件，识别项目当前开发阶段、完整度与缺口，并给出按角色过滤的下一步建议。Use when 用户问"我们到哪了""处于什么阶段"或需要一次完整项目盘点。
---

# 项目阶段检测

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。

## 何时使用
- 接手已有项目，需要摸清现状
- 加入/接手一个代码库，需要了解缺口
- 里程碑前检查还缺什么
- 用户问"我们在哪个阶段 / 我们到哪了"

## 流程
### 扫描关键目录
1. 分析 `design/`（GDD 数、game-concept/pillars/systems-index）、`src/`（源文件数与系统）、`production/`（sprint/里程碑）、`prototypes/`、`docs/architecture/`（ADR 数）、`tests/`（覆盖率粗估）。

### 判定项目阶段
1. 优先读 `production/stage.txt`；缺失则按"从最先进往回"的启发式判定（Concept / Systems Design / Technical Setup / Pre-Production / Production / Polish / Release）。

### 协作式缺口识别
1. 不单纯罗列缺失文件，而是针对每个缺口提出澄清问题（例如"有战斗代码却无战斗 GDD，是先做原型还是反向补文档？"）。

### 生成阶段报告
1. 按模板输出：日期、阶段、阶段置信度、各域完整度、缺口清单、按优先级排序的下一步。

### 按角色过滤建议（可选）
1. 根据角色参数（programmer/designer/producer/general）侧重不同域。

### 写前请求批准
1. 展示摘要、缺口、下一步，询问是否写入 `production/project-stage-report.md`，等待同意。

## 输入/输出
- 输入：项目目录结构、可选的角色过滤参数。
- 输出：`production/project-stage-report.md`（阶段、完整度、缺口、建议）。

## 约束
- 先问再写，绝不静默创建文件。
- 缺口识别要提问澄清，不假设"缺了就该补"。
- 呈现选项，让用户决定下一步。

## 反例（不要这样）
- 只列缺失文件清单而不提问、不结合上下文。
- 不读 `stage.txt` 就直接用启发式覆盖显式设定。
- 未经批准就写出报告文件。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「缺什么文件列出来就够了」 | 只列缺失清单不提问不结合上下文，无法给出有效下一步；缺口识别要提问澄清。 |
| 「我判断阶段更准，不用读 stage.txt」 | stage.txt 是权威阶段，不读就用启发式会覆盖显式设定。 |
| 「报告挺全的，直接写进项目里吧」 | 先问再写，绝不静默创建文件，须经批准。 |

## Red Flags（违规信号）
- 直接列出缺失文件清单，没有针对缺口的澄清问题。
- 未读取 production/stage.txt 就给出阶段结论。
- 未经批准写 production/project-stage-report.md。

## Verification（证据化验证门）
- [ ] 扫描覆盖 design/src/production/prototypes/docs/architecture/tests 等关键目录。
- [ ] 阶段判定优先读 stage.txt，缺失才用启发式并标注置信度。
- [ ] 报告含日期、阶段、置信度、各域完整度、缺口清单、按优先级下一步。
- [ ] 写入文件前经过批准，且支持按角色过滤（programmer/designer/producer/general）。
