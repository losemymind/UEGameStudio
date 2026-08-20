---
name: ux-review
description: 验证 UX 规格、HUD 设计或交互模式库的完整性、无障碍合规、GDD 对齐与可实施性，产出 APPROVED / NEEDS REVISION / MAJOR REVISION 判定与具体缺口。Use when：`/ux-design` 完成后、交接给 ui-programmer 或 art-director 之前。
---

# UX 规格验证

## 何时使用
- `/ux-design` 完成后
- 交接给 `ui-programmer` / `art-director` 之前
- Pre-Production→Production 门检查前（关键屏幕需有已评审规格）
- UX 规格大修订后

## 流程
### 1. 解析参数
1. 支持：具体文件路径 / `all`（验证 `design/ux/` 全部）/ `hud` / `patterns` / 无参数则询问
2. `all` 先输出汇总表（文件 | 判定 | 主要问题）再逐个详情

### 2. 加载交叉引用上下文
读输入平台配置（以 tech-prefs 为准而非规格头）、无障碍层级、模式库、GDD UI Requirements、player-journey

### 3. 校验清单
1. **3A UX Spec**：完整性（必需节）+ 质量（玩家需求清晰/状态完整/输入覆盖/数据架构/无障碍/GDD 对齐/模式库一致/本地化/验收标准质量）
2. **3B HUD**：HUD 哲学、信息架构覆盖全部系统、布局分区、元素规格、玩法上下文状态、视觉预算、平台适配、调优旋钮
3. **3C Pattern Library**：目录索引最新、标准控件齐全、每个模式含 When to Use/When NOT to Use/状态/无障碍/实施笔记、动画与声音标准表、模式间无冲突

### 4. 输出判定
按模板输出完整性/质量问题/GDD 对齐/无障碍/模式库一致，最后给 APPROVED / NEEDS REVISION / MAJOR REVISION，并列出 BLOCKING 与 ADVISORY 问题数

### 5. 协作协议
只读——不编辑不写文件，只报告发现

## 输入/输出
- 输入：UX 规格/HUD/模式库文档 + 交叉引用上下文
- 输出：评审判定报告（只读，不写文件）

## 约束
- 只读，绝不修改文件
- 判定是建议性的，不阻止用户推进；用户选择带着 NEEDS REVISION 推进即自担风险
- 数据架构检查：UI 不得列为游戏状态所有者；实时数据必须说明更新触发
- 无障碍检查按承诺层级核对（颜色不得唯一承载信息）

## 反例（不要这样）
- 修改被评审的文件（本技能只读）
- 只看 happy path，漏掉错误/空/加载状态
- 用规格自己的头部信息判断输入方法，而不用 tech-prefs 权威来源
- 判定后强行阻止用户推进
