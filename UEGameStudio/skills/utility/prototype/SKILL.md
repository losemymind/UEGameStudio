---
name: prototype
description: 概念原型：在写 GDD 之前验证核心想法是否值得设计。按游戏类型路由到 HTML / 引擎 / 纸面三条路径，产出一次性构建并给出 PROCEED / PIVOT / KILL 判定。Use when 核心机制未经证实，需要快速验证"是否好玩"。
---

# 概念原型

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。

## 何时使用
- 头脑风暴/配置引擎后、写 GDD 前，验证核心机制是否好玩
- 生产中想快速验证某个机制或技术问题（用 `--spike`）
- 需要得到 PROCEED / PIVOT / KILL 的继续/转向/放弃结论

## 流程
### 定义问题
1. 先确定可证伪假设（"如果玩家做 X 会感到 Y，若发生 Z 即证明"）与最冒险的假设；概念太模糊无法形成假设就停下缩小问题。

### 加载概念上下文
1. 读 game-concept 的核心幻想与核心循环，读 AGENTS.md 与 technical-preferences 获取引擎与语言。

### 选择原型路径
1. 按类型选路径：动作/平台/手感类 → 引擎；逻辑/卡牌/策略类 → 纸面或 HTML；节奏/叙事 → 纸面。经验法则："手感对不对→引擎；规则有没有趣→纸面；逻辑对不对→HTML 或纸面"。

### 规划原型
1. 用 3–5 条界定最小可行原型：假设、最冒险点、最小必需、明确砍掉的内容（菜单/存档/报错/打磨/架构全砍）。只测一个机制，范围大了就继续砍。
2. 写会话检查点到 `session-state/active.md` 以便中断后恢复。

### 实现
1. 写前询问；每个文件头标注"PROTOTYPE - NOT FOR PRODUCTION"。
2. 标准刻意放宽：硬编码、占位资源、跳过报错、无架构无抽象、不加打磨。

### 试玩复盘
1. 让用户按"新玩家"心态玩，逐条收集：假设是否成立（CONFIRMED/PARTIALLY/REFUTED）、最佳时刻、最糟时刻、意外、判定。

### 生成原型报告
1. 按模板填真实观察（不写空话），询问后写入 `REPORT.md`，并更新 `prototypes/index.md`。

### 创意总监审查
1. 按 review 模式决定是否 spawn 创意总监做 CD-PLAYTEST 门禁，其结论为最终判定。

### 总结与下一步
1. PROCEED → 进入 design-review → map-systems 等设计流程。
2. PIVOT → 写 PIVOT-NOTE.md（保留什么、改什么、新假设），下次 prototype 以其为起点。
3. KILL → 核对杀项清单后记入 GRAVEYARD.md，转 brainstorm 探索新概念。

## 输入/输出
- 输入：概念描述、可选 `--path`/`--spike`/`--review`、game-concept 与引擎偏好。
- 输出：一次性原型（HTML 单文件 / 引擎工程 / 规则+试玩日志）、REPORT.md、PROCEED/PIVOT/KILL 判定、必要时 PIVOT-NOTE.md 或 GRAVEYARD.md 条目。

## 约束
- 原型代码绝不 import 生产源文件，生产代码绝不 import 原型目录。
- PROCEED 后生产实现从零重写，原型代码绝不重构进生产。
- 总投入硬上限 1 天；只测一个机制；不加打磨。
- 引擎路径迭代超 2 小时仍不可玩即重构问题或换路径。
- 同一概念 3 次 PIVOT → 强制 KILL 决策。

## 反例（不要这样）
- 用"这游戏好玩吗"这类不可证伪的问题当假设。
- 把范围扩到测多个机制，而非单一核心机制。
- 给原型加菜单/存档/音乐等打磨，超出假设即为浪费。
- 把原型代码重构进生产实现。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「这游戏好不好玩？先做出来看看」 | 假设不可证伪，无法形成 PROCEED/PIVOT/KILL 判定，须先定可证伪假设。 |
| 「多测几个机制一起做更高效」 | 只测一个机制，范围大了继续砍，多机制无法归因。 |
| 「顺手加点菜单/存档/音乐」 | 打磨超出假设即为浪费，菜单/存档/报错/打磨/架构全砍。 |
| 「原型代码不错，重构进生产吧」 | 生产实现从零重写，原型代码绝不重构进生产。 |

## Red Flags（违规信号）
- 假设以「这游戏好玩吗」等不可证伪问题形式出现。
- 范围覆盖多个机制，或给原型加了菜单/存档/音乐等打磨。
- 原型文件缺「PROTOTYPE - NOT FOR PRODUCTION」头标注。
- 原型代码 import 生产源文件，或把原型代码重构进生产。

## Verification（证据化验证门）
- [ ] 可证伪假设已定义，且最冒险假设已明确。
- [ ] 原型范围以 3–5 条界定最小可行原型，只测单一机制。
- [ ] 每个原型文件头有「PROTOTYPE - NOT FOR PRODUCTION」，会话检查点写入 session-state/active.md。
- [ ] 产出 REPORT.md（真实观察）+ PROCEED/PIVOT/KILL 判定，PIVOT/KILL 各有对应产物（PIVOT-NOTE.md/GRAVEYARD.md）。
