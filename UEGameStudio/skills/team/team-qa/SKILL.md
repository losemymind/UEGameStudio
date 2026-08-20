---
name: team-qa
description: 编排 QA 团队走完整测试周期，从 QA 策略、测试计划、用例编写到冒烟门、手动执行与签署报告。Use when 需要为一个 sprint 或功能产出完整 QA 包。
---

# QA 团队编排

## 何时使用
- 为一个 sprint 或功能做完整测试周期
- 需要测试计划、用例、冒烟检查门、手动执行、签署报告

## 流程
### 阶段 0：解析评审模式
- `--review` > `production/review-mode.txt` > `lean`

### 团队组成（哪些 agent 参与）
- **qa-lead** — 策略、测试计划、故事分类、签署报告
- **qa-tester** — 用例编写、bug 报告、手动 QA 文档

### 阶段 1：加载上下文
1. 从参数识别 sprint（glob `production/sprints/`）或 `feature: 系统名`（按系统标签 glob 故事），无参数则读 active.md 与 sprint-status.yaml
2. 读 `production/stage.txt` 确认项目阶段
3. 上报故事数与阶段

### 阶段 2：QA 策略（qa-lead）
- 分类每个故事为 Logic/Integration/Visual-Feel/UI/Config-Data
- 识别需自动化证据 vs 手动 QA，标记缺验收标准/证据的 blocker，估手动工作量
- 先查既有冒烟报告（`production/qa/smoke-*.md`），有则直接用其结论；无则标 UNKNOWN 并建议先跑 smoke-check
- 输出策略表与冒烟结果；冒烟 FAIL 则不得进入阶段 3，用户修完重跑 smoke-check 再重跑 team-qa

### 阶段 3：测试计划生成
- 产出范围、分类表、自动化需求、手动范围、范围外、进入/退出标准；请求批准后写 `production/qa/qa-plan-[sprint]-[date].md`

### 阶段 4：用例编写（qa-tester，并行）
- 对需手动 QA 的故事并行派 qa-tester，写含前置条件/编号步骤/预期结果/实际结果（留空）/通过与否（留空）的用例，分批审批

### 阶段 5：手动 QA 执行
- 每 3-4 个故事一批，用决策点收集 PASS/PASS WITH NOTES/FAIL/BLOCKED
- FAIL 后派 qa-tester 写正式 bug 报告 `production/qa/bugs/BUG-[NNN]-[slug].md`

### 阶段 6：签署报告（qa-lead）
- 生成覆盖摘要、bug 清单、裁定（APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED），请求批准后写 `production/qa/qa-signoff-[sprint]-[date].md`

## 输入/输出
- 输入：sprint 或 feature 范围、故事文件、QA 计划、GDD 验收标准
- 输出：QA 策略、测试计划、用例、冒烟结果、手动结果、bug 报告、签署报告

## 约束
- 冒烟 FAIL 阻断后续阶段
- 有 S1/S2 未解决即 NOT APPROVED
- 写文件前须用户批准
- 完成后静默更新 session-state

## 反例（不要这样）
- 冒烟 FAIL 仍继续测试计划
- 忽略既有冒烟报告重复访谈用户
- 未分类故事类型导致自动化/手动范围不清
- 有 S1/S2 bug 却判 APPROVED

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「冒烟 FAIL 但时间紧，边测边等修复」 | 冒烟 FAIL 阻断后续阶段，须修完重跑 smoke-check 再重跑 team-qa |
| 「有 S1/S2 bug 也能先 APPROVED」 | 有 S1/S2 未解决即 NOT APPROVED，签署报告不得放宽 |
| 「忽略既有冒烟报告重新访谈用户」 | 先查既有冒烟报告复用结论，重复访谈浪费用户时间 |

## Red Flags（违规信号）
- 冒烟 FAIL 后仍进入测试计划生成
- 故事未分类导致自动化/手动范围不清
- 有 S1/S2 bug 却判 APPROVED
- 写文件前未请求用户批准

## Verification（证据化验证门）
- [ ] QA 策略表含每个故事的 Logic/Integration/Visual-Feel/UI/Config-Data 分类及自动化/手动标注
- [ ] 冒烟结果来自既有冒烟报告或 smoke-check 重跑（附来源），非 UNKNOWN
- [ ] 签署报告裁定为 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 且附 bug 清单
- [ ] 完成前已静默更新 session-state
