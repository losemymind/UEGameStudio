---
name: create-epics
description: 把已批准的 GDD 与架构文档翻译成 epics——每个架构模块一个 epic，定义范围、治理 ADR、引擎风险与未追踪需求。Use when：架构评审与 control-manifest 通过后、进入某层开发前拆分工作量。
---

# 创建 Epics

## 何时使用
- `/architecture-review` 与 `/create-control-manifest` 通过之后
- 每接近某一层（Foundation→Core→Feature→Presentation）开发时按层运行一次
- 不要过早建 Feature 层 epic——Core 未接近完成时设计还会变
- 本技能只到 epic 层，拆 story 交给 `/create-stories [epic-slug]`

## 流程
### 1. 解析参数与评审模式
1. 解析 `--review [full|lean|solo]`，否则读 `production/review-mode.txt`，再否则默认 `lean`
2. 支持 `all` / `layer: foundation|core|feature|presentation` / `[system-name]`；无参数时询问用户

### 2. 加载输入（只读范围内系统）
1. 先用 Grep 扫所有 GDD 的 `## Summary` 做快速过滤，只精读范围内系统
2. 精读：`systems-index.md`、范围内 GDD、`architecture.md`、覆盖范围内系统的已接受 ADR、`control-manifest.md`、`tr-registry.yaml`、`docs/engine-reference/[engine]/VERSION.md`
3. 汇报："已加载 [N] 个 GDD、[M] 个 ADR，引擎：[名称+版本]"

### 3. 定义每个 Epic
1. 按依赖安全顺序处理：Foundation → Core → Feature → Presentation
2. 每个系统映射到 `architecture.md` 中的一个架构模块
3. 对照 TR 注册表核查 ADR 覆盖：列出已追踪（有 Accepted ADR）与未追踪（无 ADR）需求；未追踪时警告"story 会被标记 Blocked 直到补 ADR"
4. 向用户展示每个 epic 的定义（Layer/GDD/模块/治理 ADR/引擎风险/覆盖数/未追踪清单），用 AskUserQuestion 逐 epic 询问是否创建

### 4. Producer 结构门（仅 full 模式）
- `full` 模式下写文件前，用 Task 以 PR-EPIC 门检查所有 epic 的范围结构；UNREALISTIC 时拆分/合并后重跑；CONCERNS 时让用户决定

### 5. 写文件
1. 写 `production/epics/[epic-slug]/EPIC.md`（含 Overview、Governing ADRs、GDD Requirements、Definition of Done、Next Step）
2. 更新 `production/epics/index.md` 主索引

## 输入/输出
- 输入：已批准的 GDD、`architecture.md`、已接受 ADR、`control-manifest.md`、`tr-registry.yaml`、引擎版本
- 输出：`production/epics/[epic-slug]/EPIC.md` + `production/epics/index.md`

## 约束
- 一个 epic 一次，逐个定义、逐个征得同意
- 写任何文件前必须获得用户批准
- 内容必须来自 GDD/ADR/架构文档，不凭空发明
- 绝不在此技能内创建 story
- 未追踪需求必须先警告再继续

## 反例（不要这样）
- 一次批量写出所有 epic 而不逐个确认
- Core 未完成就提前创建 Feature 层 epic
- 跳过 ADR 覆盖核查，让无 ADR 的需求悄悄进入 epic
- 顺手把 story 也拆了（越权）

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「一次把全部 epic 都建好更高效」 | 每个 epic 要逐个定义、逐个征得同意；批量写会跳过 ADR 覆盖核查，让无 ADR 的需求悄悄进入 epic。 |
| 「没 ADR 的需求先塞进 epic，之后再补」 | 未追踪需求必须先警告再继续，否则 story 会被标记 Blocked，反过来拖慢整个下游流程。 |
| 「Core 已经规划得差不多，可以提前把 Feature 层 epic 建出来」 | Core 未接近完成时设计还会变，提前建的 Feature epic 会过期，属于返工。 |

## Red Flags（违规信号）
- 输出目录一次性出现多个 EPIC.md，且无逐 epic 的 AskUserQuestion 批准记录。
- Core 层 GDD 尚未完成，Feature 层的 EPIC.md 却已被创建。
- 报告中缺失"未追踪需求清单"，或对无 ADR 的需求未发出 Blocked 警告。
- epic 目录下出现 story 文件（越权拆 story）。

## Verification（证据化验证门）
- [ ] 每个 epic 都能映射到 architecture.md 中的一个架构模块，且附有该模块名。
- [ ] 已对照 tr-registry.yaml 列出已追踪与未追踪需求，未追踪项已向用户发出 Blocked 警告。
- [ ] 有逐 epic 的批准记录（AskUserQuestion 或等价痕迹），而非一次性批量写盘。
- [ ] 引擎风险已从 ADR 或 VERSION.md 标注，且未创建任何 story 文件。
