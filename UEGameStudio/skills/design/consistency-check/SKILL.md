---
name: consistency-check
description: 扫描所有 GDD 对照实体注册表，检测跨文档矛盾（同名实体数值不一、同物品数值冲突、同公式变量不一致）。grep-first 策略：只读注册表一次，随后只精查冲突片段。Use when：写完新 GDD 后、整体评审前、或按需检查单个实体/物品。
---

# 一致性检查

## 何时使用
- 每写完一份新 GDD（进入下一系统前）
- 在做整体评审之前，先取得干净的基线
- 在生成架构文档之前（矛盾会污染下游 ADR）
- 按需检查单个实体或物品

## 流程
### 1. 解析参数并加载注册表
- 无参数/`full`：全量检查；`since-last-review`：只查上次评审后被改动的 GDD；`entity:<name>`/`item:<name>`：只查单一对象
- 读取注册表 `design/registry/entities.yaml`，构建四张查找表：`entity_map`、`item_map`、`formula_map`、`constant_map`
- 注册表为空则提示"先跑设计系统写 GDD，注册表会自动填充"，并停止

### 2. 定位范围内的 GDD
- 查找 `design/gdd/*.md`，排除 `game-concept.md`、`game-pillars.md`；系统索引只从 canonical `design/systems-index.md` 读取
- `since-last-review` 模式用 `git log --name-only` 找出最近被改动的 GDD

### 3. 搜索优先的矛盾扫描
- 对每个注册项，在范围内 GDD 里搜索其名称，只取匹配行及上下文，不做无目标的全量读取
- 实体扫描：对比 GDD 中出现的数值/类别/派生值 与注册表
- 物品扫描：对比售价/重量/堆叠规则/类别
- 公式扫描：对比变量名、输出范围
- 常量扫描：对比数值
- 判定：值不同 → 🔴 CONFLICT；GDD 提到但未给可比属性 → ℹ️ UNVERIFIABLE

### 4. 深度调查（仅对矛盾）
- 对每个冲突做定点完整读取，确认语境后判断：哪份 GDD 是对的（看注册表 `source` 字段）、注册表是否过期、是否是真实设计变更
- 分类：🔴 CONFLICT（必须解决）、⚠️ STALE REGISTRY（注册表落后）、ℹ️ UNVERIFIABLE（仅记录）

### 5. 输出报告
- 报告分区：冲突、注册表过期、不可验证引用、干净项
- 给出 **Verdict：PASS | CONFLICTS FOUND**

### 6. 注册表修正
- 仅在征得同意后更新过期项（写 `revised:` 日期，注释旧值）；不删除条目，改用 `status: deprecated`
- 发现 🔴 冲突时追加记录到 `docs/consistency-failures.md`

## 输入/输出
- 输入：`design/registry/entities.yaml` + `design/gdd/*.md`
- 输出：一致性检查报告 + 可选的注册表修正 + 失败日志条目

## 约束
- 只读报告为主，注册表修正必须先征得同意
- 必须给出 verdict 关键词（PASS / CONFLICTS FOUND / COMPLETE / BLOCKED）
- 永不删除注册表条目，只标记 deprecated
- grep-first：除冲突调查外不做全量读取

## 反例（不要这样）
- 直接全量读取所有 GDD（浪费 token，违背 grep-first 优化）
- 发现冲突后擅自改写 GDD 而不先确认哪份是权威来源
- 删除被移除的注册条目而不是标记 deprecated
- 漏记冲突日志，导致历史丢失

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「数值差一点没关系，不用记冲突日志」 | 漏记会让历史矛盾无法追溯，下游 ADR 会被污染，代价远大于一次日志追加 |
| 「直接改掉 GDD 更快，省得来回确认」 | 不确认权威来源就改会掩盖真实设计变更，可能把错的注册表当成对的基线 |
| 「注册表里这条没用了，删掉更干净」 | 删除即历史丢失，只能标记 deprecated 保留追溯，否则无法回滚 |
| 「全量读一遍 GDD 更省心，不用 grep」 | 违背 grep-first 优化，token 成本不可持续，大项目直接超预算 |

## Red Flags（违规信号）
- 报告里没有 verdict 关键词（PASS / CONFLICTS FOUND / COMPLETE / BLOCKED）
- 直接全量读取所有 GDD，而非 grep-first 只精查冲突片段
- 擅自改写 GDD 或删除注册条目而未征得同意
- 发现 🔴 CONFLICT 却未追加记录到 `docs/consistency-failures.md`

## Verification（证据化验证门）
- [ ] 报告含明确 verdict 关键词，且与扫描结果一致（附报告片段为证）
- [ ] 每个冲突都定位到具体 GDD 与注册表条目，并附定点读取的语境依据
- [ ] 注册表修正带 `revised:` 日期与旧值注释，被移除项为 `status: deprecated` 而非真删除
- [ ] 冲突已同步记录到 `docs/consistency-failures.md`（附日志行证据）
