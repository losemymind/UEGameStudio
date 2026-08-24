---
name: code-review
description: 对指定文件或目录做架构级与质量级代码评审：编码规范、架构模式、SOLID 原则、可测试性、性能。Use when：合并前评审 PR、审查某文件/目录、建立评审标准。
---

# 代码评审

## 何时使用
- 评审单个文件或目录的代码质量
- 合并/提交前把关架构与规范
- 需要 ADR 合规性审查（可附带 story 文件路径）

## 流程
### 1. 加载目标文件
- 完整读取目标文件，并读取项目编码规范（AGENTS.md / 技术偏好）

### 2. 识别引擎专项
- 读取技术偏好中的引擎专项配置；未配置则跳过引擎专项步骤

### 3. ADR 合规检查
- 可选传入 story 路径提取约束 ADR；否则从文件头注释/提交信息里搜 `ADR-NNN`
- 逐条对照 ADR 的 Decision 与 Consequences，分类偏差：ARCHITECTURAL VIOLATION（阻断）/ ADR DRIFT（警告）/ MINOR DEVIATION（提示）
- 找不到 ADR 引用则明说"跳过 ADR 合规检查"

### 4. 规范合规
- 检查：公开方法有文档注释、圈复杂度 <10、方法不超 40 行、依赖注入（无静态单例游戏状态）、配置从数据文件加载、系统暴露接口

### 5. 架构与 SOLID
- 架构：依赖方向正确、无循环依赖、分层清晰、用事件/信号做跨系统通信
- SOLID：单一职责 / 开闭 / 里氏替换 / 接口隔离 / 依赖倒置

### 6. 游戏专项关注
- UE 对象/生命周期：UCLASS/UFUNCTION/UPROPERTY specifier、GC 可达性、TWeakObjectPtr/TObjectPtr、delegate/timer 解绑、PIE/world teardown、CDO/构造器与 BeginPlay 边界
- Gameplay/网络：authority/ownership、RPC 可靠性按语义选择、RepNotify/条件复制/late join、prediction/reconciliation；GAS cost/cooldown/GameplayEffect authority
- 线程/异步：Game Thread 限制、TaskGraph/AsyncTask 回切、lambda 捕获 UObject 生命周期、StreamableHandle 持有与取消
- 性能/资产：无理由 Tick、同步加载、热路径分配/反射、SoftObjectPtr、World Partition/streaming、UMG invalidation、Cook/EditorOnly 边界
- Build/平台：module dependency、Build.cs/Target.cs、宏与 include hygiene、Dedicated Server/Shipping/平台条件、存档版本迁移

### 7. 专项评审（并行）
- 并行委派：UE 底层/模块给 ue-engine-programmer，通用玩法逻辑给 gameplay-programmer、UE Gameplay Framework 实现给 ue-gameplay-framework-specialist，通用 UI 给 ui-developer、UE UI 实现给 ue-ui-specialist；Replication/GAS/World Partition 分别给 ue-replication-specialist/ue-gas-specialist/ue-world-partition-specialist；逻辑与集成 story 给 qa-tester 或 ue-test-automation-engineer

### 8. 输出评审报告
- 分区：引擎专项、可测试性、ADR 合规、规范合规（X/6）、架构、SOLID、游戏专项、正面观察、必须修改项、建议项
- 给出 **Verdict：APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED**

## 输入/输出
- 输入：目标文件/目录 + 可选 story 文件路径 + 编码规范
- 输出：结构化评审报告 + verdict

## 约束
- 只读评审，不写任何文件
- ARCHITECTURAL VIOLATION 必须出现在"必须修改项"
- 始终包含"正面观察"小节
- 违反既有 ADR 时修复实现；设计确实变了则走正式的 ADR 修订流程

## 反例（不要这样）
- 只挑毛病不给正面反馈（遗漏正面观察）
- 把违反 ADR 的实现直接放过，或擅自新建竞争性 ADR
- 顺序等待各专项评审而非并行派发
- 写代码或改文件（本技能只读）

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「顺手改掉这个小问题更快」 | 评审是只读诊断，改文件越权且会污染评审基线，问题应留给实现方修复 |
| 「代码还行，不用写正面观察」 | 只挑毛病会破坏信任与采纳率，正面观察是约束的一部分，遗漏即不合格 |
| 「这个 ADR 不合理，直接新建一个竞争性 ADR 绕过它」 | 违反既有 ADR 应修复实现；设计确实变了要走正式 ADR 修订流程，不是擅自新建 |
| 「专项评审一个个来也行，何必并行」 | 独立专项应并行委派，并在统一证据基线上汇总。 |

## Red Flags（违规信号）
- 报告缺少 verdict 关键词（APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED）
- 报告缺少「正面观察」小节，或只报毛病不给正面反馈
- ARCHITECTURAL VIOLATION 未出现在「必须修改项」中
- 评审过程中写文件或修改代码（本技能只读）
- 独立专项顺序等待而非并行委派，或伪造不可用 reviewer 的意见

## Verification（证据化验证门）
- [ ] 报告含 verdict 且含「正面观察」小节（附报告分区证据）
- [ ] 每条 ADR 偏差都被归类为 ARCHITECTURAL VIOLATION / ADR DRIFT / MINOR DEVIATION，阻断级偏差落在「必须修改项」
- [ ] 无 ADR 引用时明确写出「跳过 ADR 合规检查」，而非默默跳过
- [ ] 评审全程未写任何文件（可核验无新增/修改文件）
- [ ] UE 生命周期、复制/GAS、异步线程、同步加载/Tick、Build/Cook/平台边界按适用性逐项审查，并引用具体行号
