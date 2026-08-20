---
name: qa-plan
description: QA 测试计划：读取 GDD 与 story，按 Logic/Integration/Visual/UI/Config 分类每个 story，产出覆盖自动化测试、手动用例、冒烟范围与试玩签字的结构化测试计划。Use when 冲刺开始前或启动一个主要功能前，提前明确所需测试工作。
---

# QA 测试计划

为冲刺、功能或单个 story 生成结构化 QA 计划。读取所有范围内 story 及其引用的 GDD，按测试类型分类，产出告诉开发者"自动化什么、手动验证什么、冒烟范围是什么、何时引入试玩者"的计划。实现完成后才写测试计划是"事后尸检"，不是计划。

## 何时使用
- 冲刺开始前，让团队提前知道所需测试工作
- 启动一个主要功能前
- 需要按 story 类型分配自动化/手动验证

## 流程
### 解析范围
1. `sprint`（读最近冲刺文件；有 sprint-status.yaml 则以其为主）/ `feature:[system]` / `story:[path]` / 无参数则询问。

### 加载输入
1. 逐 story 提取标题、ID、Type、验收标准、实现文件、引擎注释、GDD/ADR 引用、估算、依赖。
2. 一次性加载 systems-index、各 GDD 的 Acceptance Criteria/Formulas/Edge Cases 三节（不读全文）、control-manifest 的禁用模式。

### 分类 story
1. 已有 `Type:` 字段则原样采用（权威，不重分类）；缺失则按验收标准推断：Logic（计算/公式/阈值/状态转移/AI/数据校验）/ Integration（多系统交互/事件跨边界/存档往返/网络/持久化）/ Visual/Feel（动画/VFX/手感/时序/屏幕震动/粒子/音频同步）/ UI（菜单/HUD/按钮/对话框/面板）/ Config/Data（仅平衡数值/数据/配置，无新逻辑）。
2. 混合 story 按最高实现风险定主类型并注明次类型；推断的需标记为缺口。

### 生成测试计划
1. 产出 Test Summary 表、自动化测试要求（测试路径、测什么、边界用例、预估数量）、手动 QA 清单、冒烟范围、试玩要求、本冲刺 Definition of Done。
2. 用真实 story 标题、GDD 公式文本与验收标准，不用占位符。

### 写输出
1. 展示计划后询问写文件与是否回填 story 的 `## QA Test Cases` 节；写后给出后续步骤。

## 输入/输出
- 输入：冲刺/story 文件、GDD 关键节、systems-index、control-manifest
- 输出：QA 计划（`production/qa/qa-plan-[sprint-slug]-[date].md`）+ 可选回填 story 测试用例

## 约束
- 写计划前必须获批准；分类保守（Logic 与 Integration 难分时归 Integration，需单测+集成测试）。
- 不发明超出验收标准与 GDD 公式的测试用例；公式缺失就标记，不猜测。
- 试玩要求是建议性的，由用户决定边界 Visual/Feel story 是否需要试玩。
- 无参数时用 `AskUserQuestion` 选范围，其余阶段保持非交互。

## 反例（不要这样）
- 实现完成后才写测试计划——那是事后记录，不是计划。
- 用占位符文本而非真实 story 标题/公式——测试条目脱离真实需求。
- 臆造不存在的公式去生成测试用例——应标记缺失而非猜测。
- 未经批准就写计划文件。
