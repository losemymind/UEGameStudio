---
name: release-checklist
description: 候选版本的发布就绪门（readiness）：核验不可变构建、质量、性能、安全、合规、平台认证、商店资料与回滚准备，产出 Go/No-Go 建议但不执行上线。Use when 候选构建准备提交认证或进入 launch execution 前。
---

# 发布就绪检查

## 与 launch-checklist 的边界
- 本技能回答“这个候选版本是否具备上线资格”，输出 `production/releases/[version]-readiness.md`。
- `launch-checklist` 回答“已获 Go 的版本如何部署、观察与回滚”，输出 launch log。
- 本技能不部署、不改商店状态、不扩容；launch-checklist 不重复认证或把缺失 readiness 当 PASS。

## 流程
1. 读取 `docs/workflow-catalog.yaml` 的 release 阶段 entry/exit 契约、版本号、目标平台/地区/渠道矩阵、候选构建不可变 ID 与来源提交。
2. 验证构建可复现、签名、符号归档、资产完整、版本号、安装/升级/卸载、存档迁移；记录命令、退出码和证据路径。
3. 核验 QA：零未接受 S1，S2 仅允许有 owner/理由/到期日的例外；回归、浸泡、崩溃率、`ue-performance-validation` 目标平台报告齐全。
4. 核验 `ue-security-audit` 与 `ue-release-compliance` 报告；法律/隐私/年龄评级/第三方许可/UGC/商业化/中国地区适用项不得用第三方角色知识替代官方证据。
5. 按平台逐项核验：PC 商店/成就/云存档/输入与配置；Console TRC/TCR/Lotcheck、挂起恢复/用户切换/断网/存储/家长控制；Mobile 权限、隐私标签、内购、后台、电池与包体。
6. 搜索 TODO/FIXME/HACK、调试输出、占位资产、localhost/测试凭据/开发开关，给出路径与行号；不得只报数量。
7. 并行委派 qa-lead、technical-director、game-producer、release-manager、security-engineer 与 `game-compliance-specialist` 评审真实证据；不可用即 BLOCKED，不伪造签字。
8. 输出 READY / CONDITIONAL / NOT READY、阻塞项、到期例外、签字和 launch 前置输入；经用户批准写 readiness 文件。dry-run 只展示，不写文件或产生签字。
9. READY 后建议运行 `gate-check release`，再进入 `launch-checklist`；不存在 `team-release` 独立技能，发布协调由 release-manager 负责。

## 输入/输出
- 输入：候选构建 ID、版本、平台/地区/渠道矩阵、测试/性能/安全/合规证据。
- 输出：`production/releases/[version]-readiness.md`；绝不输出部署成功结论。

## 约束
- 证据必须绑定同一不可变构建 ID；混用旧构建报告即 NOT READY。
- 平台认证与法定合规是硬门；无法核实时标 BLOCKED/MANUAL CHECK NEEDED。
- CONDITIONAL 必须含 owner、理由、风险、到期日和批准人。
- 只读检查直到用户批准写报告；不执行上线动作。

## 反例（不要这样）
- 用上一构建的性能/回归报告给当前候选版本签字。
- 用通用清单代替 Console/Mobile 认证矩阵。
- 检查 READY 后直接部署，绕过 launch-checklist 的灰度、监控和回滚门。
- 调用已合并删除的 team-release 或伪造 reviewer 签字。

## 反合理化表（借口 → 反驳）
| 借口 | 反驳 |
|---|---|
| “版本只改一行，旧报告够用” | 证据必须绑定同一构建；一行改动也会改变产物身份。 |
| “认证去年过了” | 认证适用于具体版本和提交，不是永久豁免。 |
| “READY 就顺便部署” | readiness 与 launch execution 的职责、权限和证据不同。 |

## Red Flags（违规信号）
- 输出含 CDN 部署/扩容已完成，却没有进入 launch-checklist。
- readiness 缺不可变构建 ID、安全或合规证据。
- 扫描只给数量，没有路径与行号。
- reviewer 不可用却仍显示已签字。

## Verification（证据化验证门）
- [ ] 所有测试、性能、安全、合规和认证证据绑定同一构建 ID。
- [ ] 平台/地区/渠道矩阵逐项有 PASS/FAIL/BLOCKED 与来源。
- [ ] 结论为 READY/CONDITIONAL/NOT READY，例外字段完整。
- [ ] 报告只声明 readiness，不执行上线；READY 后明确交接 launch-checklist。
