---
name: sprint-plan
description: 基于当前里程碑、已完成工作与可用产能，生成或更新 sprint 计划。Use when 需要新建 sprint、更新现有 sprint 或查看状态。
---

# Sprint 计划

## 何时使用
- 新建一个 sprint（`new`）、更新现有 sprint（`update`）、查看状态（`status`）
- 里程碑节点需要排期下一段工作

## 流程
### 阶段 0：解析参数
- 提取模式（new/update/status），解析评审模式（`--review` > `production/review-mode.txt` > `lean`）
- `new` 且评审模式文件不存在时，用决策点让用户选 full/lean/solo 并写回文件

### 阶段 1：收集上下文
1. 读当前里程碑（`production/milestones/`）
2. 读上一 sprint 了解速率与顺延
3. 扫描 `design/gdd/` 中标记就绪的特性
4. 查风险登记册（`production/risk-register/`）

### 阶段 2：生成输出
- **new**：按模板生成 sprint 计划（目标、产能含 20% 缓冲、Must/Should/Nice 任务表、顺延、风险、外部依赖、DoD）
- **update**：读最近计划，展示当前状态，用决策点收集增删/重排/重估，重跑可行性门，写回；不重置进行中/已完成故事状态
- **status**：生成进度报告（完成/进行中/未开始/阻塞 + 燃尽评估 + 新风险）

### 阶段 3：准备 sprint-status.yaml
- 生成机器可读状态文件内容但先不写，等阶段 4 后与 markdown 一起写

### 阶段 4：Producer 可行性门
- 按评审模式 spawn producer（PR-SPRINT 门）；UNREALISTIC 则砍范围重呈，CONCERNS 则让用户选接受/调整/延期
- 请求写 `production/sprints/sprint-[N].md` 与 `production/sprint-status.yaml`

### 阶段 5：QA 计划门
- 检查是否存在 QA 计划；无则显式上报并让用户选现在跑 /qa-plan 或跳过（跳过需在计划里加警告块）

### 阶段 6：下一步
- 列出 qa-plan、story-readiness、dev-story、sprint-status、scope-check 后续动作

## 输入/输出
- 输入：里程碑、上一 sprint、设计文档、风险登记、评审模式
- 输出：sprint 计划（.md）、sprint-status.yaml、QA 计划状态与下一步

## 约束
- 写文件前须经可行性门与用户批准
- 产能预留 20% 缓冲
- 无 QA 计划必须显式警告，不得静默略过
- update 不重置进行中/已完成状态

## 反例（不要这样）
- 无 QA 计划却静默生成 sprint
- 可行性门判 UNREALISTIC 仍照原计划写
- 不预留缓冲导致计划超载
- update 时重置进行中故事状态
