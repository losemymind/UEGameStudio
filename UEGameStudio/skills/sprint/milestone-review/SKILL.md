---
name: milestone-review
description: 生成里程碑综合评审，涵盖功能完整性、质量指标、风险与 Go/No-Go 建议。Use when 到达里程碑检查点或评估里程碑截止的完备度。
---

# 里程碑评审

## 何时使用
- 里程碑检查点
- 评估里程碑截止的完备度与 Go/No-Go

## 流程
### 阶段 0：解析参数
- 提取里程碑名（current 或指定名）与评审模式

### 阶段 1：加载里程碑数据
- 读 `production/milestones/` 定义（current 取最近修改），读该里程碑内全部 sprint 报告

### 阶段 2：扫描代码健康
- 扫描 TODO/FIXME/HACK 标记，查风险登记册

### 阶段 3：生成里程碑评审
- 输出：概览、功能完整性（完全/部分/未开始）、质量指标（S1/S2/S3 bug、覆盖率、性能）、代码健康、风险评估、速率分析、范围建议（Protect/At Risk/Cut）、Go/No-Go、行动项

### 阶段 3b：Producer 风险评估
- 按评审模式 spawn producer（PR-MILESTONE 门），其裁定（ON TRACK/AT RISK/OFF TRACK）指导 Go/No-Go
- OFF TRACK 默认 NO-GO，除非用户显式覆盖；AT RISK 用决策点定 CONDITIONAL GO/NO-GO/GO

### 阶段 4：保存评审
- 请求写 `production/milestones/[name]-review.md`

### 阶段 5：下一步
- gate-check（若跨阶段边界）、sprint-plan 调整下一 sprint

## 输入/输出
- 输入：里程碑名、里程碑定义、sprint 报告、风险登记
- 输出：里程碑评审文档（含 Go/No-Go 建议与行动项）

## 约束
- OFF TRACK 不得擅自判 GO
- 写文件前须用户批准
- Go/No-Go 须附理由

## 反例（不要这样）
- 对 OFF TRACK 里程碑直接给 GO
- 只列功能完成度，缺质量指标/风险/速率
- 未附理由的 Go/No-Go
- 写文件前未请求批准

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「OFF TRACK 但大部分功能做完，给 GO 也合理」 | OFF TRACK 默认 NO-GO 是硬约束，只有用户显式覆盖才能改，擅自判 GO 会误导发布决策。 |
| 「质量指标不重要，功能齐全就行」 | 约束要求输出 S1/S2/S3 bug、覆盖率、性能，只列功能完成度会遗漏发布风险。 |
| 「Go/No-Go 结论清楚，理由就不写了」 | Go/No-Go 必须附理由，无理由的建议无法被复核，等于没有评估。 |
| 「评审文档先写了再说，批准流程走个形式」 | 写文件前须用户批准是硬约束，未经批准写盘会污染里程碑记录。 |

## Red Flags（违规信号）
- OFF TRACK 里程碑被直接判为 GO（无用户显式覆盖）
- 评审中缺失质量指标（S1/S2/S3 bug、覆盖率、性能）或风险/速率分析
- Go/No-Go 结论未附任何理由
- 未请求批准就写入 `production/milestones/[name]-review.md`
- AT RISK 场景未走 CONDITIONAL GO / NO-GO / GO 决策点

## Verification（证据化验证门）
- [ ] 评审文档含功能完整性、质量指标、代码健康、风险评估、速率分析、范围建议、Go/No-Go、行动项（逐项核对）
- [ ] Producer 裁定有记录，且 OFF TRACK 场景有 NO-GO 或用户显式覆盖证据
- [ ] Go/No-Go 结论附有可复述的理由
- [ ] 写文件前有用户批准记录（未擅自写盘）

