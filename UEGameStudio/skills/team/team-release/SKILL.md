---
name: team-release
description: 编排发布团队把一次发布从候选版本执行到部署上线，含质量门、Go/No-Go 决策与部署。Use when 需要执行一次正式发布或版本部署。
---

# 发布团队编排

## 何时使用
- 从发布候选执行到部署的一次完整发布
- 需要质量门、Go/No-Go 决策、多角色签署

## 流程
### 阶段 0：解析版本与评审模式
- 无版本号时从 active.md 与里程碑推断，或让用户提供，不硬编码默认版本
- `--review` > `production/review-mode.txt` > `lean`

### 团队组成（哪些 agent 参与）
- **release-manager** — 发布分支、版本号、变更日志、部署
- **qa-lead** — 测试签署、回归套件、质量门
- **devops-engineer** — 构建管线、产物、部署自动化
- **security-engineer** — 发布前安全审计（有联网/多人/玩家数据时）
- **analytics-engineer** — 遥测事件与仪表盘就绪
- **community-manager** — 补丁说明、发布公告、玩家向文案
- **producer** — Go/No-Go、干系人沟通、排期
- **network-programmer** — 网络稳定性签署（有联机时）

### 阶段 1：发布规划（producer）
- 确认里程碑验收全部达成、识别本次延期项、定目标日期，输出发布授权

### 阶段 2：发布候选（release-manager）
- 切发布分支、升版本号、用 release-checklist 生成清单、冻结分支（只修 bug 不加特性）

### 阶段 3：质量门（并行）
- qa-lead 跑全量回归、验证无 S1/S2；devops-engineer 构建全平台产物并验可复现；有联网则 security-engineer 做安全审计、network-programmer 验网络稳定性

### 阶段 4：本地化、性能与遥测
- 验字符串翻译、跑性能基准；analytics-engineer 验遥测事件在发布构建正确触发、仪表盘收数、关键漏斗已埋点

### 阶段 5：Go/No-Go（producer）
- 收集各方签署，评估遗留问题，做 Go/No-Go 决策
- **NO-GO 时**：立即上报、让用户选修复/延期/带书面理由覆盖，并跳过阶段 6、产出部分报告、判 BLOCKED

### 阶段 6：部署（若 GO，release-manager + devops-engineer）
- 打 tag、用 changelog 生成日志、部署 staging 冒烟、部署生产；community-manager 并行定稿补丁说明与公告
- 部署后 48 小时人工监控仪表盘与错误率，48 小时节点排复盘

### 阶段 7：发布后
- release-manager 出发布报告；producer 更新里程碑；qa-lead 盯回归 bug；community-manager 发布玩家向文案；analytics-engineer 确认仪表盘健康

## 输入/输出
- 输入：版本号、里程碑状态、已知问题
- 输出：发布授权、发布分支、质量门结果、Go/No-Go 决策、部署状态、监控计划

## 约束
- Go/No-Go 由 producer 决策，NO-GO 时跳过部署
- 覆盖 NO-GO 需用户书面理由并嵌入发布记录
- 编排器不直接写文件

## 反例（不要这样）
- 无版本号时硬编码默认版本
- NO-GO 后仍继续打 tag/部署
- 有联网功能却跳过安全与网络签署
- 部署后不安排 48 小时监控与复盘

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「NO-GO 但问题小，先部署回头修」 | NO-GO 必须跳过部署，覆盖需用户书面理由并嵌入发布记录 |
| 「有联网但跳过安全审计省时间」 | 有联网/多人/玩家数据时必须安全+网络签署，否则上线即风险 |
| 「版本号随便填个 1.0.0」 | 不得硬编码默认版本，须从 active.md 与里程碑推断或由用户提供 |

## Red Flags（违规信号）
- 无版本号时硬编码默认版本
- NO-GO 后仍打 tag/部署
- 有联网功能却无安全审计与网络签署
- 部署后未排 48 小时监控与复盘

## Verification（证据化验证门）
- [ ] Go/No-Go 决策附各方签署记录（附签署清单）
- [ ] 质量门确认无 S1/S2 遗留（附回归结果）
- [ ] 安全审计与网络签署在联网发布时已完成（附报告）
- [ ] 部署后 48 小时监控计划与复盘节点已排定（附安排）
