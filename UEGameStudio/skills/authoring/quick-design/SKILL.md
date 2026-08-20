---
name: quick-design
description: 小改动的轻量设计规格——调优、微调、小机制、小新系统，跳过完整 GDD 作者流程。Use when：改动太小不值得写完整 GDD，但又重要到需要书面理由。
---

# 快速设计规格

## 何时使用
- 改动约 4 小时实现以内：调优（改数值）、微调（小行为改动）、添加（现有系统加 1-2 个小机制）、新小系统（约一周内独立功能）
- 改动太大（新系统带显著跨系统依赖 / 超一周 / 根本改变核心规则）→ 重定向到 `/design-system`

## 流程
### 1. 分类改动
1. 读参数判断类别（Tuning/Tweak/Addition/New Small System）
2. 无参数则先问用户描述改动再分类
3. 呈现推断分类让用户确认；选"太大"则 REDIRECTED 到 `/design-system`

### 2. 上下文扫描
1. 搜 `design/gdd/` 找最相关 GDD 读受影响章节
2. 检查 `systems-index.md`（无则记录跳过依赖层检查）
3. 检查 `design/quick-specs/` 避免与既有 quick spec 矛盾
4. Tuning 类还要查 `assets/data/` 数据文件

### 3. 起草规格（按类别）
1. Tuning：单表（参数/旧值/新值/理由）+ 调优旋钮映射 + 验收标准
2. Tweak/Addition：变更摘要 + 动机 + 设计增量（引 GDD 原文 vs 新规则）+ 新规则/值 + 受影响系统 + 验收标准 + 是否需更新 GDD
3. New Small System：精简 GDD（Overview/Core Rules/Tuning Knobs/Acceptance Criteria），所有值必须放 `assets/data/*.json` 而非硬编码

### 4. 批准与归档
1. 完整呈现草稿，AskUserQuestion 批准/修订/重定向
2. 批准后写 `design/quick-specs/[kebab-case]-[日期].md`
3. 若规格标记需更新 GDD，单独征得同意并展示 old vs new 文本后再改

### 5. 交接
输出规格路径与下一步（`/story-readiness` → `/dev-story`）

## 输入/输出
- 输入：改动描述、相关 GDD、可选 systems-index 与已有 quick-specs、数据文件
- 输出：`design/quick-specs/[name]-[date].md`

## 约束
- quick spec 有意绕过 `/design-review` 与 `/review-all-gdds`（小、低风险、成本大于风险）
- 出现以下情况必须重定向：新系统该入索引 / 显著改变跨系统契约 / 影响 MDA 平衡 / 超一周工作
- 改 GDD 需显式批准并展示差异
- 所有值走数据文件，不硬编码

## 反例（不要这样）
- 把需要一周以上的功能塞进 quick spec
- 与既有 GDD 规则冲突却不引用原文对比
- 不询问就顺手修改 GDD 文件
- 调优类却去查代码而非数据文件
