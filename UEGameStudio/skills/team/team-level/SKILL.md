---
name: team-level
description: 编排关卡设计团队制作一个完整区域/关卡，从叙事与视觉方向到布局、系统集成、无障碍与 QA。Use when 需要完整制作一个区域或关卡。
---

# 关卡团队编排

## 何时使用
- 完整制作一个区域/关卡（教程、森林地牢、枢纽城镇、Boss 竞技场）
- 需要叙事、视觉、布局、系统、无障碍、QA 多角色端到端协作

## 流程
### 阶段 0：解析评审模式
- `--review` > `production/review-mode.txt` > `lean`

### 团队组成（哪些 agent 参与）
- **narrative-director** — 叙事目的、角色、情绪弧
- **world-builder** — 背景设定、环境叙事、世界规则
- **level-designer** — 空间布局、节奏、遭遇、导航
- **systems-designer** — 敌人构成、掉落表、难度平衡
- **art-director** — 视觉主题、配色、光照、资产需求
- **accessibility-specialist** — 导航清晰度、色盲安全、认知负荷
- **qa-tester** — 用例、边界测试、试玩清单

### 步骤 1：叙事+视觉方向（三路并行）
- narrative-director 定叙事目的/角色/情绪弧；world-builder 提供设定与环境叙事；art-director 定视觉主题、色温、形状语言、视觉地标（并读 art-bible）
- **art-director 的视觉目标是布局的输入约束**，必须在步骤 2 传给 level-designer
- 决策点确认后进入步骤 2

### 步骤 2：布局与遭遇设计（level-designer）
- 以步骤 1 输出为上下文设计空间布局、节奏曲线、遭遇难度、谜题、兴趣点（须匹配视觉地标）、出入口
- **相邻区域依赖检查**：若引用相邻区域但 `design/levels/[area].md` 不存在，上报并让用户选择占位标记 UNRESOLVED 或先做该区域，禁止臆造
- 决策点确认后进入步骤 3

### 步骤 3：系统集成（systems-designer）
- 敌人构成、掉落表、难度平衡、区域特有机制/环境危害、资源分布；决策点确认

### 步骤 4：生产概念+无障碍（并行）
- art-director 依定稿布局产出关键空间概念规格、资产归属、视线/光照、VFX，并标记与步骤 1 视觉目标冲突处
- accessibility-specialist 审查导航清晰度、关键路径标识是否仅用颜色、谜题认知负荷（超 3 个同时状态即警示）、色盲对比度，输出含 BLOCKING/RECOMMENDED 分级
- 有 BLOCKING 无障碍问题须用户确认是返工还是登记已知缺口

### 步骤 5：QA 规划（qa-tester）
- 关键路径用例、边界情况（序列破坏/软锁）、试玩清单、完成验收标准

### 步骤 6：汇总文档
- 由 level-designer 子 agent 编译全部输出为关卡设计文档并请求写入 `design/levels/[level-name].md`（编排器不直接写）

## 输入/输出
- 输入：关卡名/区域、game-concept、game-pillars、既有关卡/叙事/世界文档
- 输出：关卡设计文档、遭遇数、资产清单、跨关卡依赖（标记 UNRESOLVED）、无障碍问题及解决状态

## 约束
- 每步转换前用户批准
- 视觉目标必须先于布局，布局不得违背视觉方向
- 相邻区域缺失须上报，不得臆造内容
- 编排器不直接写文件

## 反例（不要这样）
- 布局先于视觉方向，或与视觉地标矛盾
- 对缺失的相邻区域臆造内容
- 有 BLOCKING 无障碍问题仍静默推进
- 关键路径标识仅靠颜色
