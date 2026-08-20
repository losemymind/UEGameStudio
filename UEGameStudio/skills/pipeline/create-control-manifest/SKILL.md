---
name: create-control-manifest
description: 架构完成后，从所有已接受 ADR、技术偏好与引擎参考文档中提取出给程序员的平铺可执行规则表——按系统与层列出"必须做什么"和"绝不能做什么"。Use when：`/architecture-review` 通过、ADR 进入 Accepted 状态后；新 ADR 被接受或修订时重新生成。
---

# 创建控制清单（Control Manifest）

## 何时使用
- `/architecture-review` 通过、ADR 已 Accepted 之后
- 有新 ADR 被接受或现有 ADR 修订时重跑（`update` 参数）
- 比 ADR 更即时可用——ADR 解释"为什么"，清单只讲"做什么"

## 流程
### 1. 加载所有输入
1. Glob `docs/architecture/adr-*.md`，只读 Status: Accepted 的 ADR，记录每条规则的 ADR 编号与标题
2. 读 `.claude/docs/technical-preferences.md`（命名规范、性能预算、批准库、禁止模式）
3. 读引擎 `VERSION.md`、`deprecated-apis.md`（→禁用 API）、`current-best-practices.md`（若有）

### 2. 从每个 ADR 提取规则
1. **Required Patterns** ← "Implementation Guidelines" 中的 must/should/required/always 与指定模式
2. **Forbidden Approaches** ← "Alternatives Considered" 中被否定的方案及理由（"绝不使用 X，因为 Y"）
3. **Performance Guardrails** ← "Performance Implications" 的帧/内存预算
4. **Engine API Constraints** ← "Engine Compatibility" 中的 post-cutoff API 与需验证行为
5. **按层分类**：Foundation（场景/事件/存档/引擎初始化）、Core（核心玩法/主玩家系统/物理碰撞）、Feature（次要系统/次要机制/AI）、Presentation（渲染/音频/UI/VFX/着色器）；跨层 ADR 则复制到各层

### 3. 添加全局规则
命名规范、性能预算、批准库/插件、禁用 API、跨层约束

### 4. 呈现规则摘要（写前）
按层统计 required/forbidden/guardrail 数量，AskUserQuestion 确认完整性；`full` 模式跑 TD-MANIFEST 门做技术评审

### 5. 写清单
写 `docs/architecture/control-manifest.md`（含 Manifest Version = 生成日期，story 内嵌此版本以检测过期规则）

## 输入/输出
- 输入：全部 Accepted ADR、`technical-preferences.md`、引擎参考文档
- 输出：`docs/architecture/control-manifest.md`

## 约束
- 每条规则必须可追溯到某个 ADR/技术偏好/引擎文档，不添加无来源的规则
- 照 ADR 原样提取，不意译改变含义
- 写前展示摘要、征得同意；跳过 Proposed/Deprecated/Superseded ADR
- 禁用 API 全部来自 deprecated-apis.md

## 反例（不要这样）
- 加入一条没有来源 ADR 的"我觉得应该这样"规则
- 从 Proposed（未接受）ADR 提取规则当成强制要求
- 用自己的话改写 ADR 的 must/should 而改变原意
- 不区分层，把所有规则混在一张表里

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「这条规则是行业惯例，直接加进去更保险」 | 每条规则必须可追溯到某个 ADR/技术偏好/引擎文档，不添加无来源的规则，否则清单失去可审计性。 |
| 「Proposed 的 ADR 内容已经很成熟，先当强制要求提出来」 | 只读 Status: Accepted 的 ADR，Proposed 尚未接受，提取为强制要求会误导程序员。 |
| 「must/should 换个说法更顺口，意思差不多」 | 照 ADR 原样提取，不意译改变含义；改写会悄悄改变规则的强制度。 |

## Red Flags（违规信号）
- 清单中出现无法对应任何 ADR 编号/技术偏好/引擎文档来源的规则。
- 禁用 API 未全部来自 deprecated-apis.md。
- 规则被改写后与 ADR 原 must/should 语义不一致（强制度被降低）。
- 清单中混入了 Proposed/Deprecated/Superseded ADR 的规则。

## Verification（证据化验证门）
- [ ] 每条规则都能回溯到 ADR 编号/技术偏好/引擎文档，来源可逐一举证。
- [ ] Manifest Version 等于生成日期，可供 story 内嵌用于检测过期规则。
- [ ] 写前已展示按层统计的 required/forbidden/guardrail 数量并征得同意。
- [ ] 所有禁用 API 均可追溯到 deprecated-apis.md，无凭空添加。
