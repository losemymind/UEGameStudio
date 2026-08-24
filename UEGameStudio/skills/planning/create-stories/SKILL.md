---
name: create-stories
description: 把单个 epic 拆成可实施的 story 文件，每个 story 内嵌其 GDD 需求的 TR-ID、ADR 指引、验收标准、story 类型与测试证据路径。Use when：每个 epic 创建完成后。
---

# 创建 Stories

## 何时使用
- 每个 epic 创建完成后（`/create-epics` 之后）
- 按依赖顺序：Foundation epic 先拆，再 Core，以此类推
- 下一环节是 `dev-story readiness` 再 `dev-story implement`

## 流程
### 1. 解析参数
1. 解析 `--review [full|lean|solo]`，否则读 `production/review-mode.txt`，再否则默认 `lean`
2. 接受 `[epic-slug]` 或完整 `EPIC.md` 路径；无参数时列出可用 epic 询问

### 2. 加载该 Epic 的全部输入
1. 读 `EPIC.md`、对应 GDD 全文（8 节）、所有治理 ADR（Decision/Implementation Guidelines/Engine Compatibility/Engine Notes）、`control-manifest.md`、`tr-registry.yaml`
2. **ADR 存在性校验**：确认每个被引用的 ADR 文件确实在磁盘上；缺失则立即停止，不拆任何 story

### 3. 按类型分类 story
| 类型 | 判定依据 |
|---|---|
| Logic | 公式、数值阈值、状态转移、AI 决策、计算 |
| Integration | 两系统交互、跨边界信号、存档往返 |
| Visual/Feel | 动画表现、VFX、"手感"、时序、屏幕震动、音效同步 |
| UI | 菜单、HUD、按钮、屏幕、对话框、提示 |
| Config/Data | 仅改数值/数据文件，无新代码逻辑 |

混合 story 取实现风险最高的类型；类型决定 `dev-story done` 关闭前需要什么测试证据。

### 4. 拆解 GDD 为 story
1. 按"相同核心实现"分组验收标准，一组 = 一个 story
2. 排序：基础行为在前、边缘情况在后、UI 最后
3. 单个 story = 一次聚焦会话（约 2–4 小时），过大则拆成两个
4. 每个 story 确定：TR-ID、治理 ADR（Proposed 则标 Blocked；多个 ADR 列出并指定主治理 ADR；无 ADR 必须写 `ADR: N/A — 原因`，不能留空）、story 类型、引擎风险

### 5. QA Lead 就绪门 + 测试用例
1. `full` 模式用 QL-STORY-READY 门检查 story 的可测性，GAPS/INADEQUATE 先修
2. 优先复用已存在的 `qa-plan-*.md` 中的测试规格；Logic/Integration story 生成 Given-When-Then 测试用例，Visual/Feel/UI story 生成手工验证步骤

### 6. 呈现并写文件
1. 写文件前展示完整 story 清单，请求用户一次性批准
2. 写 `story-NNN-[slug].md`（含 Context、Acceptance Criteria、Implementation Notes、Out of Scope、QA Test Cases、Test Evidence、Dependencies）
3. 同步更新 `EPIC.md` 的 Stories 表与 `index.md`

## 输入/输出
- 输入：`EPIC.md`、对应 GDD、治理 ADR、`control-manifest.md`、`tr-registry.yaml`、可选 `qa-plan-*.md`
- 输出：`production/epics/[epic-slug]/story-NNN-[slug].md`，并更新 EPIC 与索引

## 约束
- 验收标准来自 GDD，实施说明来自 ADR，规则来自 manifest——不发明
- ADR 文件缺失必须停止，不拆 story
- 测试用例由 qa-lead 在创建期定义，程序员照做，不临时发明
- ADR 字段留空 = 未检查，禁止
- 只到 story 文件层，不开始实施

## 反例（不要这样）
- 引用不存在的 ADR 就继续拆 story
- 一个 story 塞进需要 8 小时以上的工作量
- 跳过 QA 就绪门，让不可测的验收标准进入实施
- 把 GDD 内容用自己的话改写而非忠实引用

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「这个 ADR 我记不清路径了，先写上编号后面再补」 | ADR 文件缺失必须立即停止，不拆任何 story；引用不存在的 ADR 会让实施阶段凭空遵循一个不存在的规则。 |
| 「这条验收标准原文太长，我用自己的话概括一下」 | 验收标准来自 GDD，必须忠实引用而非改写；意译会悄悄改变验收口径。 |
| 「这个 story 大概 8 小时能做完，不用拆」 | 单个 story = 一次聚焦会话（约 2–4 小时），过大必须拆开，否则可测性与可验收性都会崩。 |

## Red Flags（违规信号）
- story 中 ADR 字段为空、写成"待定"或引用了一个磁盘上不存在的 ADR 编号。
- 一个 story 的验收标准超过一次聚焦会话仍不拆分。
- 混合类型 story 取了低风险类型而非实现风险最高的类型。
- EPIC.md 的 Stories 表与 index.md 在写 story 后未被同步更新。

## Verification（证据化验证门）
- [ ] 每个 story 的 TR-ID 都能在 tr-registry.yaml 中查得，且非凭空发明。
- [ ] 所有被引用的 ADR 文件都经存在性校验确认在磁盘上，缺失时已停止。
- [ ] 每个 story 的 story 类型与对应测试证据路径已填写，无空字段。
- [ ] EPIC.md 的 Stories 表与 index.md 已同步更新，且 story 按基础行为→边缘情况→UI 排序。
