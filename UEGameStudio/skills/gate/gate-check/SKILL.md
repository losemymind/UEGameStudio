---
name: gate-check
description: 校验项目是否准备好推进到下一开发阶段，产出 PASS/CONCERNS/FAIL 判定并列出具体阻塞项与缺失产物。Use when：用户说"我们准备好进入 X 了吗""能否推进到生产""能不能开始下一阶段""通过这个门"。
---

# 阶段门校验

## 何时使用
- 用户询问"准备好进入某个阶段了吗"或"能否推进"
- 需要正式判定当前阶段能否进入下一阶段（Concept → Systems Design → Technical Setup → Pre-Production → Production → Polish → Release）
- 需要列出推进前必须补齐的产物与质量缺口

## 流程
### 1. 解析参数
1. 确定目标阶段：无参数时先自动探测当前阶段，再用 AskUserQuestion 与用户确认要跑的道门，不可跳过确认
2. 解析评审模式 full/lean/solo（优先级：命令行 > production/review-mode.txt > 默认 lean）
   - solo：跳过四位导演，只做产物存在性检查
   - lean/full：四道导演门全部运行

### 2. 按门核对产物与质量
1. 读目标门定义的 Required Artifacts，逐项 Glob/Read 验证（验证真实内容，不是空模板头）
2. 执行 Quality Checks：测试用 Bash 跑、设计评审读 8 必节、性能读 technical-preferences、本地化 Grep 硬编码
3. 跑 Cross-Reference Checks：design/gdd 与 src/ 对照、架构文档与代码对照、sprint 计划引用真实工作项
4. 无法自动验证的项标记 MANUAL CHECK NEEDED，用 AskUserQuestion 询问用户，绝不默认 PASS
5. 先读 docs/consistency-failures.md（若存在），抽取与目标阶段 Domain 匹配的条目作为审查重点

### 3. 导演组并行评审（lean/full）
1. 用 Task 同时并行 spawn 四个导演子代理：creative-director（CD-PHASE-GATE）、technical-director（TD-PHASE-GATE）、producer（PR-PHASE-GATE）、art-director（AD-PHASE-GATE）
2. 每个传入：目标阶段名、已发现产物清单、该门定义要求的上下文字段
3. 汇总四位导演结论（READY / CONCERNS / NOT READY）
   - 任一 NOT READY → 判定至少 FAIL
   - 任一 CONCERNS → 判定至少 CONCERNS
   - 全部 READY → 具备 PASS 资格（仍受产物/质量检查约束）

### 4. 产出判定并自检
1. 输出结构化报告（Required Artifacts X/Y、Quality Checks、Blockers、Recommendations）
2. 输出判定：PASS（产物齐全 + 质量全过）/ CONCERNS（有小缺口可在下阶段补）/ FAIL（关键阻塞须先解决）
3. 执行链式自检：针对判定草稿提 5 个质疑问题，其中至少 2 个必须用 Read/Grep 实际复查文件而非仅凭反思，视结果修订判定
4. PASS 且用户确认推进后，写 production/stage.txt（单行，先征得同意）

## 输入/输出
- 输入：目标阶段名（可选）、评审模式（可选）
- 输出：门校验报告 + PASS/CONCERNS/FAIL 判定 + 阻塞项与缺失产物清单 + 推荐下一步

## 约束
- 判定是**建议性（advisory）**的，不硬阻断用户推进；记录风险后由用户决定是否在有关切时继续
- 绝不自动补建缺失文件以制造 PASS（违背门的本意）；缺失即报 FAIL 并点名应运行的技能
- 未经验证的项不得默认 PASS，标为 MANUAL CHECK NEEDED
- 导演面板四个子代理必须真实 Task spawn，不得脑内模拟

## 反例（不要这样）
- 只查文件存在不验证内容，把空模板当通过
- 把无法自动验证的核心循环可玩性悄悄标成 PASS，跳过询问用户
- 发现缺失产物后自己创建文件凑出一个 PASS，而不是报 FAIL 并给出补救技能
- solo 模式下仍假装跑了四位导演；或 lean 模式下跳过导演门
- 以"反正用户可以覆盖判定"为由草率下 PASS，而不做链式自检

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「文件存在就够了，看一眼标题即可」 | 门要验证的是真实内容而非空模板头；只查存在会把空模板当通过，违背门的本意 |
| 「用户反正能覆盖判定，随便给个 PASS」 | 判定建议性不等于可以草率；链式自检就是为把隐藏风险显性化 |
| 「缺的文件我顺手建一个，好让流程走通」 | 自动补建缺失产物等于伪造 PASS，缺失即报 FAIL 并点名补救技能 |

## Red Flags（违规信号）
- 报告中所有产物项都标 PASS，但没有任何 Glob/Read 的实质内容摘录，只有文件名
- 导演门结论在 lean/full 模式下无任何 Task spawn 痕迹，四位导演意见凭空出现
- 无法自动验证的项直接写成 PASS，未出现 MANUAL CHECK NEEDED 标记或 AskUserQuestion 记录

## Verification（证据化验证门）
- [ ] 每个 Required Artifact 是否附上 Glob/Read 命中路径与内容摘要，而非仅文件名
- [ ] 四个导演子代理结论是否来自真实 Task spawn 的返回结果（lean/full 模式）
- [ ] 所有 MANUAL CHECK NEEDED 项是否有对应的 AskUserQuestion 提问与用户答复记录
- [ ] 判定草稿是否经过至少 5 个链式自检质疑，且其中 ≥2 个留下 Read/Grep 复查证据
