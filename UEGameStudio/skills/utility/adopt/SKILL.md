---
name: adopt
description: 存量项目/旧版模板升级审计：审计既有项目产物是否符合模板技能所需的"格式"（不只是存在与否），按影响分级差距并产出编号迁移计划。Use when 加入一个进行中的项目或从旧版模板升级时。
---

# 存量项目模板升级审计

审计既有项目产物对模板技能管线的**格式合规性**，产出分优先级的迁移计划。它回答的不是"有什么"（那是 project-stage-detect 的问题），而是"现有产物能否真正配合模板技能正常工作"。一个项目可能有 GDD、ADR、story，但若内部格式不对，格式敏感技能仍会静默失败或产出错误结果。

## 何时使用
- 加入一个进行中的项目，需要评估既有产物与模板技能的兼容性
- 从旧版模板升级，需要迁移既有 GDD/ADR/story/基础设施
- 需要一份可勾选、可复跑的迁移计划（`docs/adoption-plan-[date].md`）

## 流程
### 检测项目状态
1. 读 `production/stage.txt`（如有，作为权威阶段），检查 game-concept、systems-index、GDD/ADR/story 数量、引擎配置、引擎参考文档、既有 adoption-plan。
2. 若无 stage.txt，用启发式推断阶段；若项目看起来是全新（无任何产物），询问用户改走 `/start` 或帮助定位非标准路径。

### 格式审计
1. **GDD 格式**：检查 8 个必需小节（Overview / Player Fantasy / Detailed / Formulas / Edge Cases / Dependencies / Tuning / Acceptance Criteria），并检查 header 的 `**Status**:` 字段与合法值。
2. **ADR 格式**：检查 `## Status`（缺失=BLOCKING）、`## ADR Dependencies`、`## Engine Compatibility`、`## GDD Requirements Addressed`、`## Performance Implications`。
3. **systems-index 格式**：检查状态单元格的括号值（破坏精确匹配，BLOCKING）、非法状态值、列结构。
4. **story 格式**：检查 Manifest Version、TR-ID 引用、ADR 引用、Status 字段、验收标准复选框。
5. **基础设施**：TR 注册表、控制清单、版本戳、sprint-status、stage.txt、引擎参考、可追溯性矩阵。
6. **技术偏好**：检查 `[TO BE CONFIGURED]`（引擎/语言/渲染/物理未配置为 HIGH）。

### 分级与排序差距
1. 将差距分四级：BLOCKING（现在就让技能静默出错）/ HIGH（导致 story 生成缺安全校验或基础设施引导失败）/ MEDIUM（降级质量与追踪）/ LOW（可选改进）。
2. 统计每级数量；零 BLOCKING 且零 HIGH 则报告"模板兼容"。

### 构建迁移计划
1. 按序编号：BLOCKING → HIGH（基础设施先于 GDD/ADR 内容）→ MEDIUM（GDD 先于 ADR 先于 story）→ LOW。
2. 每条含问题陈述、修复命令或手工步骤、时间估算、勾选框。
3. 特殊处理：systems-index 括号状态值、ADR 缺 Status、GDD 缺小节分别给出具体修复命令。
4. 基础设施引导固定顺序：修 ADR 格式 → `/architecture-review` 建 TR 注册表 → `/create-control-manifest` → `/sprint-plan update` → `/gate-check` 写 stage.txt。
5. 明确说明：存量 story 继续可用（字段缺失时新格式检查自动通过），不重生成进行中的 story。

### 展示摘要并询问写入
1. 展示摘要与 Gap Preview（BLOCKING 逐条列出、HIGH/MEDIUM/LOW 只给数量）。
2. 经 `AskUserQuestion` 确认后写 `docs/adoption-plan-[date].md`。

### 设置评审模式 / 提供首个动作
1. 写入计划后检查/设置 `production/review-mode.txt`（full/lean/solo）。
2. 用 `AskUserQuestion` 提供最高优先级差距的立即处理选项。

## 输入/输出
- 输入：既有 GDD/ADR/story/基础设施/技术偏好文档
- 输出：分级差距清单 + 编号迁移计划（`docs/adoption-plan-[date].md`）+ 评审模式设置

## 约束
- 先静默完成全部审计再展示任何内容；展示摘要后再请求写入。
- 写入前必须确认；计划是建议性的，用户决定修什么、何时修。
- 永不重写已有内容的 GDD/ADR/story——只填补缺失的差距。
- 一次只给一个下一步动作，不列一堆并行任务。

## 反例（不要这样）
- 只检查"文件是否存在"而忽略内部格式——存在但格式错的 GDD/ADR 会让技能静默出错。
- 把 `/adopt` 当成 `/project-stage-detect`——前者是"能不能用"，后者是"有什么"。
- 未展示摘要就直接写文件——用户看不到范围与成本。
- 重生成进行中的 story 以补格式字段——会破坏进行中的工作；字段缺失时检查自动通过是有意设计。
