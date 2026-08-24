# ADR 模板 — 架构决策记录

> 由 `architecture-decision` 技能强制使用。每个重大技术决策必须落一个 ADR。

## ADR-[编号]：[决策标题]

**状态**：Proposed | Accepted | Deprecated | Superseded
**日期**：YYYY-MM-DD
**引擎兼容性**：UE [版本]
**ADR 依赖**：Depends On / Enables / Blocks

---

## Context（背景）

- 为什么需要这项决策
- 当前技术约束与痛点
- 触发决策的信号（性能问题 / 扩展需求 / 版本升级 / 架构争议）

## Decision（决策）

- 明确、不可歧义的技术选型
- 涉及的模块、接口、数据结构（UE 类/模块名）
- **版本锚定**：断言的所有 UE API/能力，标注版本与知识缺口状态

## Alternatives Considered（考虑的备选方案）

| 方案 | 优点 | 缺点 | 为何未选 |
|---|---|---|---|
| 方案 A | | | |
| 方案 B | | | |
| 方案 C（选定） | | | |

## Consequences（后果）

- **正面**：解决什么问题、带来什么能力
- **负面**：引入的复杂度/负担/约束
- **迁移成本**：现有代码/资产需要怎么改

## GDD Requirements Addressed（满足的 GDD 需求）

- 相关系统 GDD 条目
- 接口/命名与 GDD 一致性检查

## Performance Implications（性能影响）

- 帧预算 / 内存 / 网络带宽影响
- 关联的 performance budget 表条目

## Migration Plan（迁移计划）

1. 步骤 1
2. 步骤 2
3. 回滚方案

## Validation Criteria（验证标准）

- [ ] 如何证明此决策正确（可度量判据）
- [ ] "We'll know this was right if..."

## Related Decisions（相关决策）

- 关联 ADR
- 关联 GDD

---

## 版本纪律

- 断言任何 UE API 前，读 `docs/engine-reference/unreal/VERSION.md`（锚定 5.7，知识截止 2025-05）。
- 5.4–5.7 知识缺口内的 API/能力，标注 `may have changed — verify`。