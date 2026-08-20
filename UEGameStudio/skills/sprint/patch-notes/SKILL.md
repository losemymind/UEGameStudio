---
name: patch-notes
description: 从 git 历史、sprint 数据与内部变更日志生成玩家向补丁说明，把开发者语言翻译为清晰有吸引力的玩家沟通。Use when 需要为某版本生成公开补丁说明。
---

# 玩家向补丁说明

## 何时使用
- 为某版本生成公开补丁说明
- 需要把开发者语言翻译为玩家语言

## 流程
### 阶段 1：解析参数
- `version` 与 `--style brief|detailed|full`（默认 detailed）；无版本则先询问

### 阶段 2：收集变更数据
- 读 `production/releases/[version]/changelog.md` 或 `docs/CHANGELOG.md`，回退 git log；读 sprint 复盘、平衡文档、bug 记录
- 无任何数据则提示先跑 changelog 并判 BLOCKED 停止

### 阶段 2b：检测语气指南与模板
- 查技术偏好、`docs/PATCH-NOTES-STYLE.md`、`design/community/tone-guide.md` 的语气/声音指令并应用；无则默认玩家友好、非技术、热情但不夸大
- 查补丁说明模板，有则用模板结构，无则用内置风格模板

### 阶段 3：分类与翻译
- 归类为新内容/玩法变更/质量优化/Bug 修复/性能/已知问题
- 开发者语言转玩家语言（"重构伤害计算管线"→"改进命中判定精度"），移除纯内部变更，保留平衡数值（50→45）

### 阶段 4：生成补丁说明
- brief（要点式）/detailed（含上下文）/full（加开发者评论）

### 阶段 5：审查输出
- 无内部黑话、无内部系统/ticket/sprint 引用、平衡含前后值、bug 描述玩家体验、语气匹配游戏风格

### 阶段 6：保存
- 请求写 `docs/patch-notes/[version].md`，并同时写 `production/releases/[version]/patch-notes.md` 内部归档

## 输入/输出
- 输入：版本号、内部变更日志、git 历史、复盘、语气指南/模板
- 输出：玩家向补丁说明（三种风格），写 `docs/patch-notes/[version].md`

## 约束
- 不得引用内部系统、ticket、sprint 编号
- 平衡调整保留前后值
- 无数据时判 BLOCKED 而非臆造
- 公开前经 community-manager 语气审查

## 反例（不要这样）
- 补丁说明出现"修了 inventory manager 的空引用"而非"修复打开背包崩溃"
- 无数据仍硬编补丁说明
- 平衡调整不写前后值
- 忽略游戏既定语气指南
