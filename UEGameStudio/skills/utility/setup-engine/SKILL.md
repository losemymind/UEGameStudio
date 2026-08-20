---
name: setup-engine
description: 配置项目游戏引擎并锁定版本：在 CLAUDE.md 中钉住引擎、写入技术偏好与专家路由，并在版本超出训练数据时通过 WebSearch 填充引擎参考文档。Use when 需要选定/切换引擎、锁定版本或升级引擎版本。
---

# 配置引擎

## 何时使用
- 项目尚未确定引擎，需要引导式选择
- 需要锁定引擎版本并写入技术栈
- 引擎版本超出模型训练数据，需要联网补充参考文档
- 需要刷新（refresh）或升级（upgrade）引擎版本

## 流程
### 解析参数
1. 区分模式：完整指定（引擎+版本）/ 仅引擎 / 无参引导 / refresh / upgrade。

### 引导选择（无参）
1. 先问既往经验（有经验则直接倾向该引擎）；无经验再按平台、游戏类型、团队、语言偏好、预算等决策矩阵输入，给出 1–2 个推荐并让用户拍板。

### 查找当前版本
1. 版本已给则用之；否则 WebSearch 查最新稳定版并与用户确认。

### 更新技术栈
1. 更新 CLAUDE.md 的 Technology Stack。Godot 需先问语言（GDScript / C# / 两者）；Unity 用 C#；Unreal 用 C++ + Blueprint，构建系统为 Unreal Build Tool (UBT)，资产管线为 Unreal Content Pipeline。写前展示并征得同意。

### 填充技术偏好
1. 写入引擎默认命名规范：Unity 用 PascalCase + `_camelCase` 私有字段；Unreal 用 `A`/`U`/`F` 前缀类名、`b` 前缀布尔；Godot 按所选语言用 PascalCase/snake_case。
2. 填充输入与平台（按平台映射 gamepad/touch 支持）、性能预算、测试框架、引擎专家路由表与文件扩展名路由表。

### 判定知识缺口
1. 对照训练数据基线（Godot ~4.3、Unity ~2023.x/early 6000.x、Unreal ~5.3/early 5.4）判断所选版本处于 LOW/MEDIUM/HIGH RISK。

### 填充引擎参考文档
1. LOW RISK 只建最小 VERSION.md；MEDIUM/HIGH RISK 联网抓取迁移指南、破坏性变更、废弃 API、最佳实践，建完整参考目录。

### 更新导入、agent 指令与收尾
1. 更新 CLAUDE.md 的引擎引用导入；为引擎专家 agent 补充"版本意识"小节；输出设置摘要。

### refresh / upgrade
1. refresh：重查新版本/新废弃 API 并更新文档。
2. upgrade：抓迁移指南 → 预升级审计（Grep 已废弃 API）→ 确认后更新 VERSION.md 并写迁移备注，输出后续步骤。

## 输入/输出
- 输入：引擎名/版本、游戏概念、用户决策矩阵回答。
- 输出：CLAUDE.md 技术栈、`technical-preferences.md`、`docs/engine-reference/<engine>/` 参考文档。

## 约束
- 绝不猜引擎版本，必须联网核实或用户确认。
- 写 CLAUDE.md/参考文档前必须展示并征得同意，不覆盖已有文档。
- 不得预填投机性依赖到 Allowed Libraries。
- GDScript 技术栈 Language 字段只写"GDScript"，不得附加"C++ via GDExtension"。

## 反例（不要这样）
- 用简单打分矩阵机械淘汰引擎，而非基于真实权衡给出推荐。
- 把 Unreal 5.4 之后的内容当作训练数据内知识，未标注 HIGH RISK。
- 未经确认就改 CLAUDE.md 或覆盖已有引擎参考文档。
- 给 GDScript 项目错误标注"C++ via GDExtension"为项目语言。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「5.5 和 5.4 差不多，我按已知知识写就行，不用联网」 | 规则要求超出训练数据基线必须标 HIGH RISK 并联网填充参考文档，臆造会产生过期 API 误导。 |
| 「用户没明确说版本，我猜个最新稳定版」 | 约束「绝不猜引擎版本，必须联网核实或用户确认」。 |
| 「我直接把 CLAUDE.md 和参考文档改了，效率高」 | 约束「写前必须展示并征得同意，不覆盖已有文档」。 |
| 「GDScript 项目顺手标注 C++ via GDExtension 更全面」 | 约束明确 Language 字段只写「GDScript」，反例已禁止此附加。 |

## Red Flags（违规信号）
- 未 WebSearch / 用户确认即写入具体引擎版本号。
- 把 Unreal 5.4 之后的内容当训练数据内知识而未标 HIGH RISK。
- 未经同意修改 CLAUDE.md 或覆盖已有引擎参考文档。
- 给 GDScript 项目标注「C++ via GDExtension」为项目语言。

## Verification（证据化验证门）
- [ ] 版本来源有据（WebSearch 结果或用户确认），transcript 中有核实动作。
- [ ] 超出基线版本被标注 HIGH/MEDIUM RISK，且对应参考文档已生成（迁移指南/破坏性变更/废弃 API）。
- [ ] 写 CLAUDE.md/参考文档前有「展示 + 征得同意」记录。
- [ ] 技术栈 Language 字段与所选引擎一致（GDScript 项目不含 C++ via GDExtension）。
