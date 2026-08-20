---
name: propagate-design-change
description: 当 GDD 被修订时，扫描所有 ADR 与可追踪索引，识别哪些架构决策现在可能过期，产出变更影响报告并引导用户解决。Use when：任何 GDD 内容发生修订之后。
---

# 传播设计变更

## 何时使用
- 任何 GDD 被修订之后（规则/公式/验收标准/调优旋钮变化）
- 用法：`/propagate-design-change design/gdd/combat-system.md`

## 流程
### 1. 校验参数
1. GDD 路径是必需的，缺失或文件不存在则报错退出

### 2-3. 读取变更与旧版
1. 读当前 GDD 全文
2. `git show HEAD:design/gdd/[filename].md` 取上一版；无 git 历史则报告"新 GDD，无内容可传播"
3. 做概念性 diff，产生产变更摘要（哪些节变了、哪些没变、哪些会影响架构）

### 4. 加载架构输入
1. 读 `docs/architecture/` 下所有 ADR，提取每个 ADR 的 "GDD Requirements Addressed"
2. 读 `architecture-traceability.md`（若存在）
3. 汇报："已加载 [N] 个 ADR，其中 [M] 个引用 [gdd filename]"

### 5. 影响分析
1. 对每个引用该 GDD 的 ADR：定位需求是否仍存在 → 对比"ADR 写作时 GDD 说了什么"与"现在说了什么" → 评估决策是否仍有效
2. 分类：✅ Still Valid / ⚠️ Needs Review / 🔴 Likely Superseded
3. 每个受影响 ADR 产出影响条目（假设、现状、评估、建议动作）

### 6. 呈现影响报告
`full` 模式跑 TD-CHANGE-IMPACT 门复核分类与级联影响；然后展示报告给用户

### 7-9. 解决与落盘
1. 逐个 ADR 问用户如何处理（Superseded / Update in place / Keep as-is / Skip）
2. 更新 ADR 状态、`architecture-traceability.md`、写出 `change-impact-[date]-[system].md`
3. 建议后续：Superseded 的 ADR 跑 `/architecture-decision` 写替代；多个受影响时跑 `/architecture-review`

## 输入/输出
- 输入：变更后的 GDD、git 上一版、所有 ADR、可选可追踪索引
- 输出：变更影响报告 `docs/architecture/change-impact-[date]-[system].md` + ADR 状态更新

## 约束
- 逐个 ADR 询问，不批量决定
- 修改任何文件前征得同意
- 非破坏性：绝不删除 ADR 内容，只追加 "Superseded by" 备注

## 反例（不要这样）
- 不读 git 上一版就凭印象判断"变了什么"
- 只扫直接引用、漏掉级联影响其他 ADR 或系统
- 不询问就批量把所有 ADR 标成 Superseded
- 直接改写或删除 ADR 正文
