---
name: review-all-gdds
description: 跨所有系统 GDD 做整体一致性与游戏设计理论审查，检测 GDD 间的矛盾、失效引用、归属冲突、公式不兼容与设计理论违规（主导策略、经济失衡、认知过载、支柱漂移），产出 PASS/CONCERNS/FAIL 判定。Use when：所有 MVP GDD 写完后架构开始前、或任一 GDD 中期大幅修订后。
---

# 跨 GDD 交叉评审

## 何时使用
- 所有 MVP 级 GDD 各自通过评审之后
- 任一 GDD 在制作中期被大幅修订之后
- /create-architecture 开始之前（防止架构继承 GDD 间的不一致）
- 需要同时看到所有系统才能发现的问题（单 GDD 内部完整性走 /design-review）

## 流程
### 1. 加载全部文档（分层）
1. L0 摘要扫描：Grep 提取所有 GDD 的 ## Summary，先给用户列清单
2. 读 design/registry/entities.yaml（若存在）作为冲突基线，否则标注"注册表为空，仅靠全读"
3. L1/L2 全读：game-concept、game-pillars、systems-index、每个在范围系统 GDD 全文
4. 系统 GDD 少于 2 个则停止，提示先写更多 GDD

### 2. 交叉一致性（与第 3 步并行 spawn）
1. 2a 依赖双向性：每个 Dependencies 声明必须对侧有呼应，标记单向依赖
2. 2b 规则矛盾：地板/上限、资源归属、状态转换、时序、叠加规则跨文档是否矛盾
3. 2c 失效引用：跨文档引用的机制/数值/系统名是否仍存在于被引 GDD
4. 2d 数据与调参旋钮归属冲突：两个 GDD 不得同时声称拥有同一数据/旋钮
5. 2e 公式兼容性：上游输出区间是否落在下游预期输入区间内
6. 2f 验收标准交叉核对：两 GDD 的 AC 能否同时成立

### 3. 游戏设计整体性（与第 2 步并行 spawn）
1. 3a 进度循环竞争：是否多个系统都自称"核心循环"并奖励同一主资源
2. 3b 玩家注意力预算：统计同时需主动管理的系统数，>3–4 即认知过载
3. 3c 主导策略检测：资源垄断、无风险高收益、无取舍、明显最优解
4. 3d 经济循环分析：每个资源的来源(sources)与去向(sinks)，标记无限来源无去向/正向反馈失控等
5. 3e 难度曲线一致性：各系统的缩放方向与速率是否匹配
6. 3f 支柱对齐：每个系统应服务至少一根设计支柱，标记支柱漂移与反支柱违规
7. 3g 玩家幻想一致性：各系统呈现的玩家身份是否兼容

### 4. 跨系统场景走查
1. 识别 3–5 个多系统同时激活的关键时刻（战斗+经济、进度+难度、叙事+玩法、3+ 系统链）
2. 逐步走查：触发→激活顺序→数据流→玩家体验→失败模式（竞态、反馈回路、状态转换破坏、矛盾信息、难度叠加、奖励双算、未定义行为）
3. 按严重度分级：BLOCKER / WARNING / INFO

### 5. 输出报告与落盘
1. 输出 Cross-GDD Review Report：Consistency Issues、Game Design Issues、Cross-System Scenario Issues、GDDs Flagged for Revision、判定 PASS / CONCERNS / FAIL
2. FAIL 时列出重跑前必须改动的具体 GDD 与内容
3. 写报告到 design/gdd/gdd-cross-review-[date].md 前用 AskUserQuestion 求批准；更新 systems-index 状态（"Needs Revision"）同理，且状态值不得加括号后缀

## 输入/输出
- 输入：focus 参数（full/consistency/design-theory/since-last-review，可选）
- 输出：跨 GDD 评审报告 + PASS/CONCERNS/FAIL 判定 + 标记需修订的 GDD 清单

## 约束
- 一致性与设计理论两条线独立，用 Task **并行** spawn，不要串行等待
- 传给子代理的是完整 GDD 路径列表 + 注册表全文 + 分配的检查项 + 引擎名/版本，不得让子代理自己重读
- 判定是建议性的：区分阻塞与咨询，不要把每条意见都当阻塞
- 不做设计决策：只标记矛盾与选项，绝不单方面判定哪份 GDD"正确"
- 写报告与改 systems-index 前必须获用户批准
- 每条问题须引用具体 GDD、章节、原文，不得含糊

## 反例（不要这样）
- 只做单 GDD 内部检查，跳过真正要做的跨文档关系审查
- 把第 2、3 步串行跑（浪费时间），或让子代理自己去重读文件
- 遇到矛盾就自行拍板哪份 GDD 是对的，而不是并列呈现让用户裁决
- 把每条警告都升级成阻塞，吓阻推进
- 未经批准就写报告或改 systems-index，或在状态值后加括号后缀破坏精确匹配
