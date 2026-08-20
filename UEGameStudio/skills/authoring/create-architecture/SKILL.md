---
name: create-architecture
description: 逐节引导撰写主架构文档——读取所有 GDD、系统索引、既有 ADR 与引擎参考库，产出完整架构蓝图，且引擎版本感知（标记知识缺口并按锁定的引擎版本验证决策）。Use when：所有 GDD 获批后、写任何代码之前。
---

# 创建主架构

## 何时使用
- 所有 GDD 获批后、sprint 计划开始前
- 与 `/architecture-decision` 区别：ADR 记录单个点决策，本技能产出给 ADR 提供语境的整体蓝图
- 参数模式：`full`（全流程）/ `layers` / `data-flow` / `api-boundaries` / `adr-audit`

## 流程
### 阶段 0：加载全部上下文
1. **引擎上下文（关键）**：读引擎 `VERSION.md`/`breaking-changes.md`/`deprecated-apis.md`/`current-best-practices.md`/`modules/*`；未配置引擎则停止提示 `/setup-engine`
2. **设计上下文 + 技术需求提取**：读 game-concept、systems-index、tech-prefs、每个 GDD，提取技术需求基线（`TR-[gdd-slug]-[NNN]` 平铺列表）
3. **既有 ADR**：读 `docs/architecture/` 下全部，列出 ADR 与领域
4. **知识缺口清单**：生成 HIGH/MEDIUM/LOW 风险领域清单，AskUserQuestion 确认如何继续

### 阶段 1：系统分层映射
1. 把每个系统映射到层：Platform / Foundation / Core / Feature / Presentation
2. 确定模块边界与独占所有权，呈现并批准后写骨架
3. 每个 Core/Foundation 系统若触及 HIGH/MEDIUM 风险领域则内联标注引擎参考摘录

### 阶段 2：模块所有权图
1. 每个模块定义：Owns / Exposes / Consumes / 使用的引擎 API（含版本与风险）
2. post-cutoff API 标注 `⚠️ [ClassName.method()] — 版本（post-cutoff, HIGH risk）`

### 阶段 3：数据流
覆盖帧更新路径、事件/信号路径、存档路径、初始化顺序；标注同步调用/信号/共享状态，标记跨线程

### 阶段 4：API 边界
定义模块间公共契约（接口/入口点/不变量/保证），用伪代码或项目语言写

### 阶段 5：ADR 审计 + 可追踪检查
1. 每个 ADR 检查：Engine Compatibility、版本、post-cutoff 标记、GDD 关联、与本次分层是否冲突、是否仍有效
2. 技术需求基线逐条映射到 ADR 覆盖，缺口成为"必需新 ADR"

### 阶段 6：缺失 ADR 清单
按优先级分：写码前必须有（Foundation/Core）/ 相关系统构建前 / 可延后

### 阶段 7：写主架构文档
写 `docs/architecture/architecture.md`（分层图/模块所有权/数据流/API 边界/ADR 审计/必需 ADR/架构原则/开放问题）

### 阶段 7b：签收
TD-ARCHITECTURE 自审 + `full` 模式跑 LP-FEASIBILITY 门，记录 TD 签收与 LP 可行性到文档状态

### 阶段 8：交接
输出固定交接模板（Architecture Complete / 下三个 ADR / gate-check 就绪清单 / 开放问题）

## 输入/输出
- 输入：所有 GDD、systems-index、tech-prefs、既有 ADR、引擎参考库
- 输出：`docs/architecture/architecture.md` + 技术需求基线 + 必需 ADR 清单

## 约束
- **引擎版本感知**：HIGH/MEDIUM 风险领域必须交叉引用引擎文档，不能依赖训练数据
- 每个架构决策前呈现选项，绝不未经输入做绑定决策
- 增量写：每批准一节立即写，不攒到最后
- 写批准用 AskUserQuestion（写 / 先看全文 / 暂不），多文件变更列出每个文件一次性问

## 反例（不要这样）
- 未配置引擎就写架构
- 忽略 HIGH 风险引擎领域，凭训练数据给建议
- 技术需求基线漏掉某个 GDD 的隐含约束
- 一次性攒完所有章节再写（会话崩溃即全丢）
- 未经批准就做绑定式架构决策
