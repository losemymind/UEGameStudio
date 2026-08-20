---
name: story-done
description: 故事完成评审：读完 story 文件，逐条对照实现验证每个验收标准，检查 GDD/ADR 偏离，提示代码评审，更新 story 状态为 Complete 并给出下一个可认领 story。Use when：一个 story 实现结束时，确认它真正"做完"而非草率关闭。
---

# 故事完成评审

## 何时使用
- 任一 story 实现结束时
- 关闭 story 前，确保每个验收标准都已验证、偏离已显式记录而非悄悄引入
- 需要把设计与实现闭环、并推进到下一个 story

## 流程
### 1. 定位 story
1. 解析评审模式 full/lean/solo
2. 有路径直接读；无参数则查 production/session-state/active.md → 最新 sprint 中 IN PROGRESS → 多候选用 AskUserQuestion 让用户选

### 2. 读 story 与上下文
1. 提取：name/ID、TR-ID、Manifest Version、ADR 引用、完整 AC 列表、实现文件、Story Type、引擎说明、DoD、估算 vs 实际
2. 读 tr-registry 中每条 TR-ID 的**当前**需求文本（以它为准，不用 story 内可能过期的引用）、对应 GDD 的 AC 与关键规则、被引用 ADR 的 Decision/Consequences、control-manifest 的 Manifest Version 日期

### 3. 逐条验证 AC
1. 自动验证（无需询问）：文件存在 Glob、测试通过 Bash、无硬编码数值/字符串 Grep、依赖存在
2. 手动验证：主观品质、玩法行为、性能用 AskUserQuestion 批量确认（≤4 个一次），选项 Yes/No/Not tested yet
3. 不可验证项（需完整构建）标 DEFERRED — requires playtest session，不阻塞
4. 测试-标准可追踪表：每条 AC 映射到单测/集成测/手动确认，标 COVERED/UNTESTED
   - >50% UNTESTED → 升级 BLOCKING（不能判 COMPLETE）
   - ≤50% UNTESTED → ADVISORY（须写入 Completion Notes）
5. 测试证据门（按 Story Type）：Logic/Integration 缺测试文件即 BLOCKING；Visual-Feel/UI/Config-Data 缺证据为 ADVISORY；未声明 Type 为 ADVISORY

### 4. 检查偏离
1. 用 tr-registry 当前需求文本核对实现是否满足当下 GDD（非写 story 时）
2. Manifest Version 过期 → ADVISORY（提示跑 story-readiness）
3. ADR 约束：Grep 实现文件中被 ADR 明令禁止的模式
4. 硬编码数值/字符串检查
5. 范围检查：是否触碰了 story 声明之外的文件
6. 分类：BLOCKING（违背 GDD/ADR）/ ADVISORY（轻微漂移，功能等价）/ OUT OF SCOPE

### 5. QA 覆盖门（仅 full）
1. solo/lean 跳过 QL-TEST-COVERAGE；full 才 spawn qa-lead
2. 传入 story 路径与类型、测试文件路径、## QA Test Cases、## Acceptance Criteria
3. ADEQUATE → 继续；GAPS → ADVISORY；INADEQUATE → BLOCKING

### 6. 主程序员代码评审门
1. solo 跳过；lean 用 AskUserQuestion 询问是否已跑 /code-review 并记录；full 才 spawn lead-programmer
2. REJECT 时不得进入判定，须先解决

### 7. 呈现完成报告与判定
1. 输出 AC 通过表、测试-标准可追踪表、测试证据、偏离、范围、判定 COMPLETE / COMPLETE WITH NOTES / BLOCKED
2. BLOCKED 时停止，列出须修复项并提供帮助

### 8. 更新状态与推进
1. 写文件前用 AskUserQuestion 批准（关闭 / 关闭并记技术债 / 先修复不关闭 / 接受偏离关闭）
2. 关闭时：Status: Complete、更新 Last Updated、追加 ## Completion Notes；记技术债则追加 docs/tech-debt-register.md；同步 production/sprint-status.yaml（若存在）；给出建议 git commit
3. 读 sprint 找出下一个 READY/NOT STARTED 的 Must/Should Have story 呈现；若 Must Have 全部完成则给出 sprint 收尾序列（smoke-check → team-qa → retrospective → gate-check → sprint-plan new）

## 输入/输出
- 输入：story 文件路径（可选），评审模式（可选）
- 输出：AC 验证结果 + COMPLETE/COMPLETE WITH NOTES/BLOCKED 判定 + 更新后的 story 文件 + 下一个可认领 story

## 约束
- 未经用户批准绝不标记 Complete，绝不自动修复失败 AC（报告并询问）
- 偏离是事实不是评判：中立呈现，由用户决定可否接受
- BLOCKED 是建议性的：用户可覆盖并关闭，但须明确记录风险
- Logic/Integration story 缺测试文件即 BLOCKING，不得放行
- 需求文本以 tr-registry 当前值为准，不用 story 内可能过期的引用
- 手动确认用 AskUserQuestion 批量（≤4），代码评审询问与完成确认用结构化工具

## 反例（不要这样）
- 看到文件存在/测试能跑就默认所有 AC 通过，跳过逐条对照
- 把 >50% 未测试的 AC 仍判 COMPLETE，而不是升级 BLOCKING
- 用 story 内引用的旧需求文本核对，而非 tr-registry 当前文本
- 未经批准就改写 story 状态为 Complete
- Logic story 没单测仍放行（缺测试即 BLOCKING）
- 悄悄替用户"修正"实现以迎合 AC，而不是报告失败并询问
- 以"偏离只是建议、用户可覆盖"为由，不记录偏离就关闭
