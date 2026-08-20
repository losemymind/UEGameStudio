---
name: design-review
description: 评审一份游戏设计文档（GDD）的完整性、内部一致性、可实施性与规范符合度，产出 APPROVED/NEEDS REVISION/MAJOR REVISION NEEDED 判定。Use when：把设计文档交给程序员之前、需要检查 GDD 是否可实施时。
---

# 设计文档评审

## 何时使用
- 把 GDD 交给程序员实现之前
- 单个系统 GDD 完成后做完整性/一致性/可实施性把关
- 复评审（检测上次阻塞项是否已解决）

## 流程
### 1. 加载文档与上下文
1. 解析 --depth full/lean/solo（默认 full）
2. 全文读目标 GDD、CLAUDE.md、相关设计文档
3. 依赖图校验：对 Dependencies 节列出的每个系统，Glob 验证其 GDD 文件是否存在，标记断裂引用
4. 读 game-concept.md / narrative/（若存在）检查世界观与设计支柱冲突
5. 若存在 design/gdd/reviews/[doc]-review-log.md，读最近一条作为复评审基线

### 2. 完整性检查（8 必节）
1. 逐项核对 8 个必备章节：Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria
2. 记录缺失章节（Completeness: X/8）

### 3. 一致性与可实施性
1. 内部一致性：公式输出是否匹配描述、边界情况是否与主规则矛盾、依赖是否双向
2. 可实施性：规则是否精确到程序员无需猜测、有无"含糊带过"段落、是否考虑性能

### 4. 对抗式专家评审（仅 full，必做）
1. 打印耗时提示（8–15 分钟，可用 --review lean 提速）
2. 按 GDD 涉及的领域，用 Task **同时并行** spawn 对应专家子代理（game-designer 必跑、含公式必跑 systems-designer、经济跑 economy-designer 等）
3. 提示词必须对抗式："你的任务不是验证设计，而是找问题；挑战设计选择、指出错误/欠规范/遗漏，欢迎与主评审意见相左"
4. 专家意见汇总后 spawn creative-director 作为资深评审做综合判定（其结论即最终判定）
5. 专家间或专家与主评审有分歧时，不得私下取舍，须在输出中并列呈现由用户裁决，每条结论标注来源

### 5. 输出评审报告
1. 输出：Completeness、Dependency Graph、Required Before Implementation（阻塞项，标注来源）、Recommended Revisions、Specialist Disagreements、Scope Signal（S/M/L/XL）、判定 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
2. 本技能只读，评审阶段不写文件
3. 用 AskUserQuestion 处理全部收尾交互：是否立即修订、是否更新 systems-index / review-log、下一步动作

## 输入/输出
- 输入：GDD 文件路径、--depth 模式（可选）
- 输出：评审报告 + APPROVED/NEEDS REVISION/MAJOR REVISION NEEDED 判定 + 阻塞项/建议项清单 + 范围信号

## 约束
- 8 个必备章节必须全部核对，缺一节即不完整
- full 模式下专家评审是**强制**步骤，不得跳过；专家必须是真实 Task 子代理，不得脑内模拟
- 本技能只读，评审过程中不写任何文件；写 systems-index / review-log 须先获用户批准
- 分歧必须显式呈现，不得静默选定一方
- 每项发现标注来源 agent

## 反例（不要这样）
- 只数了"有没有 8 个标题"就判完整，不核对每节是否有实质内容
- full 模式下跳过专家 spawn，自己脑补各领域意见当专家评审
- 以"改动很小/时间紧"为由跳过对抗式评审
- 静默采纳 creative-director 的意见而隐藏专家分歧
- 评审后未经批准就改写 systems-index 或 review-log
