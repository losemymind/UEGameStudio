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
1. 先解析 UEGameStudio/OpenCode 配置根，再读包内 `docs/engine-reference/[engine]/VERSION.md`；项目 ADR/registry 仍相对项目根。包根找不到则 fail-closed，不混淆两类 `docs/`
2. 从标题确定领域，读对应 `modules/[domain].md`、`breaking-changes.md`、`deprecated-apis.md`
3. MEDIUM/HIGH 风险领域显示知识缺口警告；未配置引擎则提示先跑 `/setup-engine`

### 2-3. 编号与收集上下文
1. 扫描 `docs/architecture/` 确定下一个 ADR 编号
2. 读相关代码、既有 ADR、相关 GDD
3. **架构注册表检查（BLOCKING 门）**：读 `docs/registry/architecture.yaml`，呈现与本次决策相关的既有立场（状态所有权/接口契约/禁止模式）作为锁定约束；若提案与之矛盾，立即抛出冲突让用户选择（对齐/取代/说明例外）

### 4. 协作式引导决策
1. 先从已收集上下文推导假设（问题/备选/依赖/GDD 关联/状态=Proposed），请求用户 confirm/adjust，不用开放式提问
2. 涉及 schema 设计的问题另用单独 widget 逐一询问，不与假设混在一起
3. 确认 ADR 依赖（Depends On / Enables / Blocks）

### 5. 生成 ADR（格式见下方结构）
1. 结构含：Status、Date、Engine Compatibility、ADR Dependencies、Context、Decision、Alternatives Considered、Consequences、GDD Requirements Addressed、Performance Implications、Migration Plan、Validation Criteria、Related Decisions
2. 保存前派引擎专家 agent 验证（确认方法对引擎版本是否地道、标记 post-cutoff 变更的 API），再派 `technical-director`（TD-ADR 门，`full` 模式）做战略一致性评审
3. **GDD 同步检查**：扫被引用 GDD 是否存在与 ADR Key Interfaces/Decision 命名不一致（重命名的信号/方法/类型），有则写前突出警告

### 6. 写批准与注册表更新
1. 请求用户批准写入；有 GDD 同步问题则提供"写 ADR + 同步改 GDD"选项
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

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「引擎版本我知道，不用读 VERSION.md 了」 | 训练数据有 cutoff，post-cutoff 新增/废弃 API 只能靠引擎参考库核实，凭记忆会写出已废弃接口 |
| 「提案和注册表立场冲突，但用户没要求检查，先照写」 | 注册表是 BLOCKING 门，冲突不解决就写会把矛盾固化进文档，后续 ADR 互相打架 |
| 「顺手把注册表既有条目也改了，更整洁」 | 既有条目是不可变立场，只能新条目 + 旧条目标 `superseded_by`，直接改会丢失决策历史 |

## Red Flags（违规信号）
- ADR 里出现未读取引擎版本就引用的 API，且无 post-cutoff 风险标注
- 用开放式提问让用户从零设计，而非先推导假设再 confirm/adjust
- 未经批准就改 `docs/registry/architecture.yaml` 的既有条目
- 同一会话内直接运行 `/architecture-review`（污染评审独立性）

## Verification（证据化验证门）
- [ ] 已从配置根的包内 VERSION 取得参考版本，并与项目 `.uproject`/Build.version 交叉核对
- [ ] 注册表立场冲突已在写入前抛出并由用户明确选择（对齐/取代/说明例外），有对话记录
- [ ] 新 ADR 状态字段 = Proposed，未向用户询问状态
- [ ] 注册表更新（若有）经用户批准，且只含新增条目，无既有条目被改动
