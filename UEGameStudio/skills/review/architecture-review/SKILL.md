---
name: architecture-review
description: 校验架构的完整性与一致性：构建 GDD 技术需求到 ADR 的可追踪矩阵，识别覆盖缺口、检测跨 ADR 冲突、核对引擎版本兼容一致性，产出 PASS/CONCERNS/FAIL 判定。Use when：架构进入 Pre-Production 前、需要验证架构是否覆盖所有设计需求时，是架构版的 design-review。
---

# 架构评审

## 何时使用
- Technical Setup 到 Pre-Production 之间的质量门
- 验证架构决策是否覆盖所有 GDD 技术需求
- 检测跨 ADR 冲突与引擎版本不一致
- rtm 模式：在 Production 阶段扩展为 需求→ADR→Story→Test 完整链路追踪

## 流程
### 1. 加载文档
1. L0 摘要扫描 GDD 与 ADR 的 ## Summary（single-gdd/engine 模式按需裁剪读取范围）
2. 全读：所有在范围 GDD、systems-index、所有在范围 ADR、architecture.md（若存在）、engine-reference（VERSION/breaking-changes/deprecated-apis/modules）、technical-preferences
3. 读 docs/consistency-failures.md（若存在），提取匹配 Domain 的已知冲突点

### 2. 从每个 GDD 提取技术需求
1. 先读 docs/architecture/tr-registry.yaml（若存在）按 id 与规范化文本索引，防止 ID 重排
2. 提取每份 GDD 的技术需求（数据结构、性能约束、引擎能力、跨系统通信、状态持久化、线程/时序、平台需求等）
3. 匹配规则：精确匹配复用旧 TR-ID、无匹配分配新 TR-[system]-NNN、含糊则问用户
4. status: deprecated 的需求跳过

### 3. 构建可追踪矩阵
1. 对每条需求在 ADR 的 "GDD Requirements Addressed" 与决策正文中查找覆盖
2. 标记 Covered / Partial / Gap，统计 X/Y/Z
3. rtm 模式：加载 stories（提取 TR-ID、路径、状态、Test Evidence）与测试文件，扩展为 GDD→ADR→Story→Test 全链，标 COVERED/MISSING/NO STORY/NO ADR

### 4. 跨 ADR 冲突检测
1. 检测：数据归属冲突、集成契约冲突、性能预算冲突、依赖环、架构模式冲突、状态管理冲突
2. 依赖排序：收集所有 Depends On，拓扑排序，标记指向 Proposed/不存在 ADR 的悬空依赖与依赖环
3. 输出推荐的实现顺序

### 5. 引擎兼容性交叉核对 + 专家咨询
1. 版本一致性：所有 ADR 是否同意同一引擎版本，标记过期版本引用
2. Post-Cutoff API 一致性、Deprecated API 引用（对照 deprecated-apis.md）、缺 Engine Compatibility 章节的盲区
3. spawn 主引擎专家子代理复核审计发现、找引擎特有反模式，其意见与审计同等权重
4. 对 HIGH RISK 引擎发现反向检查 GDD 假设是否与已验证引擎现实冲突，产出 GDD Revision Flags 表

### 6. 架构文档覆盖
1. systems-index 每个系统是否出现在架构分层、数据流是否覆盖跨系统通信、有无无 GDD 对应的孤儿架构

### 7. 输出报告与落盘
1. 输出 Architecture Review Report：Traceability Summary、Coverage Gaps（含建议 ADR 与引擎风险等级）、Cross-ADR Conflicts、ADR Dependency Order、GDD Revision Flags、Engine Compatibility Issues、判定 PASS/CONCERNS/FAIL
2. FAIL 时列阻塞项与必建 ADR 优先级
3. 写文件（报告 / 追踪索引 / tr-registry）前用 AskUserQuestion 批准并先展示草稿；更新 systems-index 状态值必须恰为 "Needs Revision" 不加后缀
4. 只把 🔴 CONFLICT 追加到 consistency-failures.md（若已存在），GAP 不记录

## 输入/输出
- 输入：focus 参数（full/coverage/consistency/engine/single-gdd/rtm，可选）
- 输出：架构评审报告 + 可追踪矩阵/RTM + PASS/CONCERNS/FAIL 判定 + 建议 ADR 清单 + GDD 修订标记

## 约束
- 判定是建议性的：CONCERNS 甚至 FAIL 下用户仍可决定继续
- 需求含糊时问用户"是技术需求还是设计偏好"，不要猜
- 写任何文件前先内联展示草稿，用 AskUserQuestion 结构化批准；多文件变更须一次性列出全部文件
- TR-ID 稳定：绝不重排或删除既有条目；deprecated 须经用户确认
- 缺 ADR（GAP）是架构完成前的正常现象，不记入 consistency-failures.md
- rtm 模式仅在有 story 与 test 时使用

## 反例（不要这样）
- 只读 GDD 不读 ADR 就断言"覆盖"，或反过来不核对 ADR 正文只看标题
- 重新编号已有 TR-ID，破坏未来 story 的引用稳定性
- 未经批准直接写报告 / 改 systems-index，或在状态值后加括号后缀
- 把 GAP（缺 ADR）当冲突记进 consistency-failures.md
- 跳过引擎专家咨询，自己脑补引擎细节当专家意见
- 以"判定只是建议"为由跳过可追踪矩阵的逐条核对
