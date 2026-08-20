---
name: design-system
description: 逐节引导撰写单个游戏系统的 GDD——收集上下文、按 8 个必节协作推进、交叉引用依赖、增量写入文件。Use when：系统索引建立后、设计单个系统 GDD 时（含 retrofit 补全）。
---

# 设计单系统 GDD

## 何时使用
- `/map-systems` 建立系统索引后，设计某个系统 GDD
- `retrofit [path]` 模式：为存量 GDD 补全缺失/占位章节
- 8 个必节：Overview、Player Fantasy、Detailed Design、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria

## 流程
### 1. 解析参数与校验
1. 系统名必需；缺失时从索引找最高优先级"未开始"系统询问
2. 检测 retrofit 模式：只补缺失/占位章节，绝不覆盖已有内容

### 2. 收集上下文（先读再问）
1. 必读：`game-concept.md`、`systems-index.md`、目标系统条目、`entities.yaml`（作为锁定事实）、`consistency-failures.md`
2. 依赖读：上游/下游依赖 GDD（提取接口、公式、边缘情况、调优旋钮）
3. 呈现上下文摘要（优先级/层/依赖/锁定事实/支柱对齐），未设计的依赖先警告并定义临时契约
4. **技术可行性预检**：按系统类别映射引擎领域，读引擎上下文，呈现可行性简报（能力/约束/知识缺口/约束性 ADR），问是否继续

### 3. 创建文件骨架
1. 立即创建含空节标题的骨架文件，问"May I create the skeleton?"
2. 拒绝则 BLOCKED（无骨架无法继续）；写后更新会话状态

### 4. 逐节设计（每节循环）
1. 循环：Context → Questions → Options → Decision → Draft → Approval → Write
2. 草稿与批准 widget 必须在同一响应出现；用 Edit 以"节标题+占位符"作唯一锚点替换
3. 每节有专属引导与强制 agent 委派（详见约束）

### 5. 设计后校验
1. 自检 8 节是否都有真内容、公式引用已定义变量、边缘有解决、依赖有接口、验收可测
2. `full` 模式跑 CD-GDD-ALIGN 门
3. 更新实体注册表（新实体/物品/公式/常量，经批准追加，不擅自改既有 value）
4. 提示在全新会话跑 `/design-review`（绝不同会话内联运行）
5. 更新系统索引与会话状态，问下一步

## 输入/输出
- 输入：game-concept、systems-index、依赖 GDD、entities.yaml、引擎上下文
- 输出：`design/gdd/[system-name].md` + 实体注册表更新 + 索引/会话状态更新

## 约束
- 每节强制委派专家 agent：B（Player Fantasy）→ creative-director；C（Detailed Design）→ 按类别路由主+支持 agent；D（Formulas）→ systems-designer（经济系统加 economy-designer）；E → systems-designer；H（Acceptance Criteria）→ qa-lead
- 公式必须含变量表与输出范围，禁止 `[Formula TBD]`
- 边缘情况必须写"若 X 则确切结果"，禁止"适当处理"
- 验收标准用 Given-When-Then，每条可独立验证
- 绝不自动生成整份 GDD 当既成事实；绝不未经批准写节；与既有 GDD 矛盾先标记

## 反例（不要这样）
- 草稿出现却没有伴随批准 widget（用户被晾在空提示）
- 用 `[To be designed]` 占位当"已完成"
- 公式用散文描述而不给变量表，导致无法实现
- 跳过专家 agent 委派、凭空编平衡数值
- 同会话内跑 `/design-review`

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「8 节太长，一次生成整份 GDD 更高效」 | 整份既成事实跳过逐节批准，等于替用户做设计决策，违反协作式引导 |
| 「公式用文字描述意思到了就行」 | 没有变量表与输出范围的公式无法被系统实现或验收，是无效规格 |
| 「这节不用派专家 agent，我自己写更快」 | 每节有强制委派路由，跳过会丢失对应角色的专业视角与一致性校验 |
| 「边缘情况写『适当处理』够了」 | 边缘必须写"若 X 则确切结果"，模糊措辞会在实现时被任意解释 |

## Red Flags（违规信号）
- 草稿出现但没有伴随批准 widget（用户被晾在空提示上）
- 节内容含 `[To be designed]` / `[Formula TBD]` 等占位符却标记为已完成
- 公式缺变量表或输出范围，边缘情况用"适当处理"类模糊表述
- 未委派专家 agent 直接写平衡数值或验收标准
- 同一会话内运行 `/design-review` 或自动生成整份 GDD 当既成事实

## Verification（证据化验证门）
- [ ] 8 个必节全部有真实内容，无 `[To be designed]`/`[Formula TBD]` 占位残留
- [ ] 每个公式含变量表与输出范围；每条边缘情况为"若 X 则确切结果"句式
- [ ] 每条验收标准为 Given-When-Then 且可独立验证
- [ ] 每节写入前有对应专家 agent 委派记录与用户批准记录
