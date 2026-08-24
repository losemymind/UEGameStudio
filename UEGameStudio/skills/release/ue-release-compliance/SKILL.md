---
name: ue-release-compliance
description: 建立版本/平台/地区/渠道合规矩阵并核实隐私、评级、许可、UGC、商业化和中国市场要求的权威证据。Use when 立项范围变化、候选版本认证或 release readiness。
---

# UE 发布合规

## 流程
1. 定义产品矩阵：build、平台、地区、渠道、年龄层、联网/账号、遥测、UGC、聊天、支付/loot box、广告、第三方 SDK/资产。
2. 为每个组合建立适用性清单：平台政策/认证、年龄评级、隐私与数据权利、儿童、跨境、消费者/退款、无障碍披露、版权/商标/开源与资产许可、UGC/审核、商业化概率披露。
3. 中国地区单独核对版号适用性、防沉迷/实名认证、未成年人付费、个人信息保护/数据出境、内容审查与运营主体；不得把通用 GDPR 清单当替代。
4. 来源优先官方法规/监管/平台/评级机构/SDK 官方条款；记录 URL/文件、版本/发布日期、访问日期、适用条件。法律结论不确定时标 LEGAL REVIEW REQUIRED。
5. 盘点 UE plugins、ThirdParty、Content 许可、字体/音频/模型/生成式资产 provenance 与 notices；扫描结果需人工确认。
6. 委派 `game-compliance-specialist` 主审，security-engineer 核数据/SDK，localization-specialist 核地区内容，release-manager 核交付；输出 PASS/CONDITIONAL/FAIL。
7. 获批准后写 `production/releases/[version]-compliance.md`，每项含 owner/evidence/expiry/status；供 release-checklist 引用。

## 约束
- 不是法律意见；无法核实或高风险解释必须升级法务/平台代表。
- 不伪造评级、版号、认证、同意或 SDK 合规证明；缺证据即 BLOCKED。

## 反例
- 用第三方 agent 文本证明当前法规要求。
- 默认“未面向儿童”而不检查年龄门与营销。
- 忽略插件、Marketplace/字体/音乐许可。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “其他游戏这样做过” | 合规取决于当前功能、地区、平台、时间和主体。 |
| “先上线再补证明” | 评级、许可、隐私或发行资格缺失可能导致拒审、下架和法律风险。 |

## Red Flags
- 矩阵没有 build/platform/region/channel 维度。
- 用非官方二手材料给法律适用性 PASS。
- 缺证据仍勾选认证、评级或许可完成。

## Verification
- [ ] 矩阵覆盖 build/platform/region/channel 与功能触发条件。
- [ ] 每项有权威来源、适用版本/日期、owner、证据、到期和状态。
- [ ] 中国地区与 UGC/支付/儿童/数据专项有明确适用性结论。
- [ ] 只读评估未提交平台表单、改产品配置或伪造证据。
