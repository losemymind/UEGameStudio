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

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「没有 changelog，凭 git log 猜个大概也能写」 | 无任何数据必须判 BLOCKED 并提示先跑 changelog，臆造会向玩家发布不实信息。 |
| 「内部系统名/ticket 号保留更专业」 | 补丁说明面向玩家，不得引用内部系统/ticket/sprint 编号，须全部翻译为玩家语言。 |
| 「平衡只写加强/削弱就行，玩家不关心数值」 | 平衡调整必须保留前后值（50→45），否则玩家无从判断影响。 |
| 「游戏没明确语气指南，随便写正式点就行」 | 无指南须默认玩家友好、非技术、热情但不夸大，且公开前经 community-manager 语气审查。 |

## Red Flags（违规信号）
- 补丁说明出现内部系统名、ticket 号、sprint 编号或开发者黑话
- 无数据仍强行生成补丁说明（未判 BLOCKED）
- 平衡调整缺失前后值
- 忽略既定语气指南（PATCH-NOTES-STYLE.md / tone-guide.md）或未做 community-manager 语气审查
- 出现"修了 inventory manager 空引用"式实现细节而非玩家体验描述

## Verification（证据化验证门）
- [ ] 输出无内部黑话/ticket/sprint 引用（全量搜索确认）
- [ ] 平衡调整条目含前后值（如 50→45）
- [ ] 语气符合指南或默认玩家友好；公开前有 community-manager 语气审查记录
- [ ] 已同时写 `docs/patch-notes/[version].md` 与 `production/releases/[version]/patch-notes.md`（或经批准跳过）
- [ ] 无数据场景已判 BLOCKED 并提示先跑 changelog（无臆造内容）

