---
name: sprint-status
description: 快速查看 sprint 进度快照，产出燃尽评估与新风险，30 行内完成。Use when 用户问"迭代进行得怎么样""sprint 更新""查看进度"。
---

# Sprint 状态快照

## 何时使用
- 快速了解当前 sprint 进度（非完整评审）
- 用户询问 sprint 进度/更新/状态

## 流程
### 1. 定位 sprint
- 有参数则匹配 `production/sprints/sprint-[N].md`；无参数取最近修改的 sprint 文件；目录不存在/为空则提示先跑 sprint-plan new 并停止
- 读完整 sprint 文件，提取编号、目标、起止日期、任务及优先级/负责人/估算

### 2. 计算剩余天数
- 算总天数、已过、剩余、时间消耗百分比；无日期则跳过燃尽评估

### 3. 扫描故事状态
- 优先读 `production/sprint-status.yaml`（权威来源）；不存在则回退 markdown 扫描（DONE/IN PROGRESS/BLOCKED/NOT STARTED），并附警告
- 检测停滞：进行中故事距 `Last Updated` 超 4 天标 STALE，并把燃尽裁定至少升级为 At Risk

### 4. 燃尽评估
- 对比完成百分比与时间消耗百分比：10 点内 On Track，10-25 点 At Risk，超 25 点 Behind

### 5. 输出
- 状态表（必需）、需关注表、燃尽、风险中的 Must-Have、新风险、一条建议（≤50 行）

### 6. 快速升级规则（置于输出顶部）
- Must-Have 阻塞/未开始且剩余时间<40% → SPRINT AT RISK
- 全部 Must-Have 完成 → 提示可从 Should Have 拉取
- 引用故事文件缺失 → NOTE 提示跑 story-readiness

## 输入/输出
- 输入：sprint 编号（可选）、sprint 计划、sprint-status.yaml、故事文件
- 输出：≤50 行进度快照（状态表 + 燃尽 + 风险 + 建议）

## 约束
- **只读**：不改计划、不改状态、不做范围裁剪
- 最多一条具体建议
- 不截断状态表

## 反例（不要这样）
- 修改 sprint 计划或故事状态
- 提出范围裁剪建议（那是 sprint-plan update 的职责）
- 忽略 sprint-status.yaml 而重复扫描 markdown
- 输出冗长报告而非快照
