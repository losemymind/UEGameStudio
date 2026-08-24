---
name: ue-source-verification
description: 用本地 UE 版本、引擎源码和 Epic 官方文档核实版本敏感 API/CVar/行为，并生成可审计事实记录。Use when agent 将断言 UE API、默认值、废弃状态、平台行为或迁移方案。
---

# UE 来源核实

## 流程
1. 先解析当前 UEGameStudio/OpenCode 配置根，从该根读取包内 `docs/engine-reference/unreal/VERSION.md`；再从项目根读取 `.uproject`、Build.version/Target.cs。包根找不到或两类版本证据冲突时 fail-closed，禁止把项目 `docs/` 误当包内 reference。
2. 将问题拆成原子断言：符号存在性、签名、模块/头文件、版本范围、默认值、线程/网络/平台语义。
3. 来源优先级：匹配版本的本地引擎源码/头文件/注释与 release notes → Epic 官方 API/文档 → Epic issue tracker/forums（仅辅助）。第三方文章不得单独支撑事实。
4. 搜索源码时记录引擎 commit/version、绝对或引擎相对路径、行号、符号；网页记录标题、官方 URL、访问日期和适用版本。
5. 交叉核对正文与声明/实现、Editor 与 packaged、client/server、目标平台差异；矛盾时记录 UNKNOWN/CONFLICT，不挑方便答案。
6. 输出 VERIFIED/CONDITIONAL/UNVERIFIED、claim、evidence、applies_to、counter-evidence、verified_on、reverify_trigger；获批准后更新版本化事实文件。

## 约束
- 不把“UE5”当精确版本；不引用无法复现的搜索摘要。
- 未核实事实不能作为强制规则或生产修复依据。

## 反例
- 凭记忆写“所有 Server RPC 必须 Reliable”。
- 用最新在线文档证明旧分支行为。
- 来源矛盾却标 VERIFIED。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “都是 UE5，差异不大” | 小版本和分支会改变签名、默认值与实现语义。 |
| “官方搜索摘要够权威” | 摘要缺上下文与适用版本，必须打开一手来源。 |

## Red Flags
- 未解析配置根就读取相对 engine-reference。
- 只给 URL，不给适用版本或原子 claim。
- 忽略与源码相冲突的证据。

## Verification
- [ ] 每条 claim 原子化并标版本/平台/配置。
- [ ] 证据来自匹配版本源码或 Epic 官方一手来源。
- [ ] 矛盾和不确定性显式保留。
- [ ] 只读核实时仓库不变。
