---
name: story-readiness
description: 校验一个 story 文件是否具备实施条件：检查内嵌的 GDD 需求、ADR 引用、引擎说明、清晰验收标准与无未决设计问题，产出 READY/NEEDS WORK/BLOCKED 判定并列出具体缺口。Use when：用户说"这个 story 好了吗""我可以开始这个 story 了吗""story X 可以实施了吗"。
---

# 故事可实施性校验

## 何时使用
- 在分配 story 给开发者之前
- 用户询问某个 story 是否已可实施
- 需要批量检查当前 sprint / 全部 story 的实施就绪度

## 流程
### 1. 解析范围与模式
1. 解析评审模式 full/lean/solo（命令行 > production/review-mode.txt > 默认 lean）
2. 确定范围：单文件路径 / sprint / all；无参数时用 AskUserQuestion 询问范围

### 2. 加载支撑上下文（一次加载，非逐故事重复）
1. systems-index（哪些系统有已批准 GDD）、control-manifest（含 Manifest Version 日期，缺失则记一次）、tr-registry（按 id 索引，缺失则记一次）、各被引用 ADR 的 Status 字段（缓存去重）、当前 sprint 文件（用于 Must/Should Have 优先级）

### 3. 逐项检查清单
1. 设计完整性：引用具体 GDD 需求（只给文件名不算）、需求自包含（不看 GDD 也能懂 DONE）、验收标准可测试、无需要主观判断的 AC（Visual/Feel 自动放行但须带证据文件路径）
2. 架构完整性：引用 ADR 或明示 "No ADR applies"、ADR 须 Accepted（Proposed 或缺文件即 BLOCKED）、TR-ID 有效且 active、Manifest Version 不过期、引擎说明存在（纯数据改动可 N/A）、控制清单规则注明（manifest 缺失自动放行）
3. 范围清晰度：有估算、有 in/out-of-scope 边界、依赖 story 明确列出（无则明示 None）
4. 未决问题：无 UNRESOLVED/TBD/TODO/? 标记；依赖 story 不得为 DRAFT 或缺文件（否则 BLOCKED 而非 NEEDS WORK）
5. 资产引用：扫描 assets/ 与媒体扩展名路径，Glob 验证存在性（仅存在性，不查格式）
6. Definition of Done：按 Story Type 满足最少可测试 AC 数（Logic/Integration≥3、Visual-Feel/UI≥2、Config/Data≥1）、性能预算注明、有 Type 字段、有 ## Test Evidence 段落

### 4. 判定
1. READY：全部通过或有明确 N/A 理由
2. NEEDS WORK：有项失败，但依赖 story 均存在且非 DRAFT
3. BLOCKED：依赖 story 缺失或 DRAFT，或关键设计问题无负责人；BLOCKED 可同时有 NEEDS WORK 项，须并列列出

### 5. 输出报告
1. 单 story：列出 Passing Checks、Gaps（含 Fix 具体文本）、Blockers
2. 多 story：聚合 Ready/Needs Work/Blocked 计数与每项主缺口
3. sprint 范围且 Must Have 有非就绪项时，顶部加醒目警告
4. 本技能只读，不改 story 文件；仅在对话中代拟缺失段落供批准

### 6. 导演门（仅 full）
1. solo/lean 跳过 QL-STORY-READY；full 才 spawn qa-lead
2. 传入 story 标题、AC 列表、依赖状态、判定；按 ADEQUATE/GAPS/INADEQUATE 处理

## 输入/输出
- 输入：story 路径 / sprint / all（可选），评审模式（可选）
- 输出：每 story 的 READY/NEEDS WORK/BLOCKED 判定 + 具体缺口与修复文本

## 约束
- 本技能**只读**，绝不编辑 story 文件，也不写文件；补缺仅在对话中代拟
- 判定是建议性的：BLOCKED 不硬阻断，用户可覆盖推进，但须明确记录风险
- 引用 GDD 只给文件名不算通过；必须追溯具体需求/AC/规则
- ADR 为 Proposed 或缺文件即 BLOCKED（实现指引可能随 ADR 改变而失效）
- 缺 tr-registry / control-manifest 时按"早于该系统引入"放行，不得逐故事重复扣分

## 反例（不要这样）
- 把"story 里贴了 GDD 文件名"当成"已引用 GDD 需求"通过
- 看到"feels responsive""looks good"这类主观 AC 仍判可测试
- 对 Proposed 状态的 ADR 照常放行，忽略实现指引可能被推翻
- 把依赖 DRAFT story 的依赖问题降级成 NEEDS WORK 而非 BLOCKED
- 擅自编辑 story 补缺（本技能只读），而不是代拟让用户自己写入
- 以"这只是建议"为由跳过逐项清单，只凭印象下 READY

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「story 里贴了 GDD 文件名，算引用过了」 | 只给文件名不算引用，必须追溯具体需求/AC/规则 |
| 「Proposed 的 ADR 先放行，反正之后会改」 | Proposed 或缺文件即 BLOCKED，实现指引可能随 ADR 改变而失效 |
| 「feels responsive 这种 AC 差不多能测」 | 主观 AC 不可测试，Visual/Feel 类须带证据文件路径才能放行 |

## Red Flags（违规信号）
- 报告把「贴了 GDD 文件名」当作「已引用 GDD 需求」通过
- Proposed 或缺文件的 ADR 被照常放行
- 依赖 story 为 DRAFT/缺文件却降级为 NEEDS WORK 而非 BLOCKED
- 本技能出现对 story 文件的写操作（应只读、只在对话中代拟）

## Verification（证据化验证门）
- [ ] 每个引用是否追溯到了具体 GDD 需求/AC/规则，而非仅文件名
- [ ] 每个 ADR 引用是否核对了 Status=Accepted，Proposed/缺文件标 BLOCKED
- [ ] 依赖 story 是否核对存在且非 DRAFT，否则标 BLOCKED
- [ ] DoD 是否按 Story Type 满足最少可测试 AC 数并有 ## Test Evidence 段落
