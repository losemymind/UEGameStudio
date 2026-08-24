---
name: ue-observability
description: 为 UE Client/Dedicated Server/Backend 建立可关联的日志、指标、trace、崩溃与上线 SLO/告警/Runbook。Use when 设计遥测、上线观察、事故准备或定位线上退化。
---

# UE 可观测性

## 流程
1. 定义服务/客户端关键用户旅程、SLI/SLO、错误预算、平台/地区/版本维度和隐私红线；读取构建 manifest 与数据保留政策。
2. 建关联模型：build ID、session/request/match/player pseudonymous ID、server instance 与 trace ID；禁止记录 token、真实身份、聊天原文或存档敏感字段。
3. UE 侧覆盖 structured log categories、crash/ensure、Unreal Insights/Network Insights、帧/卡顿/加载/内存；服务端覆盖 RED/USE 指标、依赖与队列。
4. 定义 dashboard 与多窗口告警（症状优先、去重、抑制、owner、严重度）；每条告警链接 runbook，含诊断、止损、回滚、沟通和证据保存。
5. 与 `ue-ci-cd` 绑定 release marker，与 launch-checklist 绑定灰度和 0–4h/4–24h/24–72h 观察；由 `liveops-sre` 复核容量、on-call 与事故响应。
6. 用合成/故障注入验证信号能触发、能定位、能恢复；展示计划，经授权才修改配置或外部监控状态。
7. **仅评审模式**：不修改 dashboard、alert 或仓库配置，不发送任何告警；只输出当前缺口、建议 owner/runbook 与后续演练计划。

## 约束
- 高基数标签与 PII 默认禁止；采样、保留和成本必须量化。
- 未授权不得创建外部 dashboard/alert 或发送测试告警。
- 用户只要求评审或未授权实施时，必须停留在仅评审模式。

## 反例
- 只收平均 FPS，掩盖尾延迟和平台差异。
- 告警没有 owner/runbook。
- 日志写玩家邮箱、token 或完整聊天。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “数据越多越好” | 高基数与敏感数据会放大成本、隐私和泄露风险。 |
| “有 dashboard 就算可观测” | 没有 SLO、告警、owner 和 runbook 不能驱动响应。 |

## Red Flags
- 无 build/release marker，无法归因版本退化。
- 告警没有 owner/runbook 或从未演练。
- 设计请求下直接创建生产监控资源。

## Verification
- [ ] SLI/SLO、维度、采样/保留/成本和隐私字段明确。
- [ ] build/session/trace 可关联且能标记 release。
- [ ] 告警有阈值、窗口、owner、runbook 和演练证据。
- [ ] 设计模式下仓库与外部监控状态不变。
