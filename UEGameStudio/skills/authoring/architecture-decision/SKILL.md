---
name: architecture-decision
description: 创建架构决策记录（ADR），记录一项重大技术决策的背景、考虑过的备选方案与后果，并可选地回填缺失章节。Use when：每个重大技术选择需要落 ADR 时，或为存量 ADR 补全缺失章节（retrofit）。
---

# 架构决策记录（ADR）

## 何时使用
- 每个重大技术选择都需要一个 ADR
- `retrofit [path]` 模式：为存量 ADR 回填缺失章节（不修改已有内容）
- 无标题参数时询问"要记录什么技术决策"

## 流程
### 0. 解析参数与 retrofit 模式
1. 解析 `--review [full|lean|solo]`
2. `retrofit` 模式：读 ADR、扫描缺失章节（Status=BLOCKING、ADR Dependencies/Engine Compatibility=HIGH、GDD Requirements Addressed=MEDIUM），只追加缺失章节，绝不改已有内容

### 1. 加载引擎上下文（永远最先）
1. 读 `docs/engine-reference/[engine]/VERSION.md` 得引擎名/版本/LLM cutoff/post-cutoff 风险等级
2. 从标题确定领域，读对应 `modules/[domain].md`、`breaking-changes.md`、`deprecated-apis.md`
3. MEDIUM/HIGH 风险领域显示知识缺口警告；未配置引擎则提示先跑 `/setup-engine`

### 2-3. 编号与收集上下文
1. 扫描 `docs/architecture/` 确定下一个 ADR 编号
2. 读相关代码、既有 ADR、相关 GDD
3. **架构注册表检查（BLOCKING 门）**：读 `docs/registry/architecture.yaml`，呈现与本次决策相关的既有立场（状态所有权/接口契约/禁止模式）作为锁定约束；若提案与之矛盾，立即抛出冲突让用户选择（对齐/取代/说明例外）

### 4. 协作式引导决策
1. 先从已收集上下文推导假设（问题/备选/依赖/GDD 关联/状态=Proposed），用 confirm/adjust 的 AskUserQuestion 呈现，不用开放式提问
2. 涉及 schema 设计的问题另用单独 widget 逐一询问，不与假设混在一起
3. 确认 ADR 依赖（Depends On / Enables / Blocks）

### 5. 生成 ADR（格式见下方结构）
1. 结构含：Status、Date、Engine Compatibility、ADR Dependencies、Context、Decision、Alternatives Considered、Consequences、GDD Requirements Addressed、Performance Implications、Migration Plan、Validation Criteria、Related Decisions
2. 保存前派引擎专家 agent 验证（确认方法对引擎版本是否地道、标记 post-cutoff 变更的 API），再派 `technical-director`（TD-ADR 门，`full` 模式）做战略一致性评审
3. **GDD 同步检查**：扫被引用 GDD 是否存在与 ADR Key Interfaces/Decision 命名不一致（重命名的信号/方法/类型），有则写前突出警告

### 6. 写批准与注册表更新
1. AskUserQuestion 征得写批准；有 GDD 同步问题则提供"写 ADR + 同步改 GDD"选项
2. 扫 ADR 中新架构立场（状态所有权/接口契约/性能预算/禁止模式），经批准后追加到 `docs/registry/architecture.yaml`，不修改既有条目（变更则旧条目标 `superseded_by`）

## 输入/输出
- 输入：引擎参考、既有 ADR、GDD、`docs/registry/architecture.yaml`
- 输出：`docs/architecture/adr-[NNNN]-[slug].md`，可选更新架构注册表

## 约束
- 新 ADR 状态永远是 Proposed，不询问用户
- 假设仅覆盖：问题/备选/依赖/GDD 关联/状态，不含 schema 设计问题
- 提案与既有立场冲突时先解决，再进入协作设计
- 修改注册表需显式用户批准；绝不改既有条目
- 关闭时固定提示：在全新会话跑 `/architecture-review` 验证覆盖，不在同会话运行

## 反例（不要这样）
- 未读引擎版本就写决策，导致用了 post-cutoff 已废弃 API
- 用开放式提问让用户从零设计，而非先推导假设再 confirm/adjust
- 提案与既有 ADR 立场矛盾却照写不误
- 同会话内跑 `/architecture-review`（会污染评审独立性）
