---
name: map-systems
description: 把游戏概念拆解为独立系统，映射依赖关系，排定设计优先级，并创建系统索引。Use when：游戏概念确定后、开始写任何 GDD 之前；或用 `next` 挑选下一个待设计系统。
---

# 系统拆解与索引

## 何时使用
- `design/gdd/game-concept.md` 确定之后、写任何 GDD 之前
- `/map-systems`（全流程）或 `/map-systems next`（挑选下一最高优先级系统并交接 `/design-system`）

## 流程
### 阶段 1：读概念
1. 读 `game-concept.md`（缺失则报错，提示先跑 `/brainstorm`）
2. 可选读 `game-pillars.md`、已有 `systems-index.md`（存在则续接不重建）、Glob 已有 GDD

### 阶段 2：系统枚举（协作）
1. 从概念的核心机制/核心循环/技术考量/MVP 定义提取显式系统
2. 推断隐式系统（"战斗"隐含伤害/生命/命中/状态/敌人 AI/战斗 UI/死亡重生等），并向用户解释为何需要
3. 按类别呈现（名称/类别/一句描述/显式或隐式），AskUserQuestion 让用户增删合并，迭代到批准

### 阶段 3：依赖映射（协作）
1. 用依赖启发式（输入输出/结构/UI）为每个系统列依赖
2. 排序分层：Foundation（零依赖）→ Core → Feature → Presentation → Polish
3. 检测循环依赖并提议解决方案
4. 高亮瓶颈系统（高风险）与叶子节点（低风险），询问用户确认；`full` 模式跑 TD-SYSTEM-BOUNDARY 门

### 阶段 4：优先级分配（协作）
1. 启发式自动分配：MVP / Vertical Slice / Alpha / Full Vision
2. 用"技术必要性 + 玩家体验"解释每个系统的优先级定位，不用纯技术理由
3. AskUserQuestion 确认；`full` 模式跑 PR-SCOPE 门
4. 结合依赖序 + 优先级得出最终设计顺序（团队写 GDD 的顺序）

### 阶段 5：写系统索引
1. 用模板填充枚举表/依赖图/设计顺序/高风险系统/进度追踪
2. 写前展示摘要并征得同意；`full` 模式跑 CD-SYSTEMS 门
3. 更新 `production/session-state/active.md`

### 阶段 6：交接设计单系统
1. 选系统后调用 `/design-system [system-name]`，不在本技能重复其工作流
2. 完成后循环问下一个

## 输入/输出
- 输入：`game-concept.md`、可选 `game-pillars.md`、已有索引与 GDD
- 输出：`design/gdd/systems-index.md`（枚举/依赖图/设计顺序/优先级/进度追踪）

## 约束
- 绝不自动生成完整系统列表后未经审阅直接写入
- 绝不未经确认就开始设计某个系统
- 每次写文件前 "May I write to [filepath]?"
- 枚举/依赖/优先级都必须展示给用户验证
- 本技能拥有系统索引；`/design-system` 拥有单系统 GDD，不重复

## 反例（不要这样）
- 跳过隐式系统推断，只列概念文档里显式提到的系统
- 不检测循环依赖或瓶颈系统
- 优先级理由只写"X 依赖 Y"而不说明对玩家体验的影响
- 未经用户批准就把整套系统清单写进索引
