---
name: perf-profile
description: UE 性能候选热点分诊：读取预算并检查 Tick、同步加载、GC、复制、渲染和资产风险，形成待实测假设；不得代替目标平台性能验证。Use when 尚未具备运行时 trace、需要为 ue-performance-validation 缩小采集范围。
---

# UE 性能剖析分诊

## 流程
1. 从项目 GDD/ADR/technical preferences 读取目标平台预算；包内版本参考须先解析当前 UEGameStudio/OpenCode 配置根再读取，找不到则 fail-closed，禁止把项目 `docs/` 与包内 reference 混淆。
2. 搜索并按系统归类候选：Actor/Component Tick 与 tick prerequisites、逐帧分配/容器复制/反射；同步 LoadObject/BlockingLoad；GC/UObject 生命周期；TaskGraph/锁；Replication 频率/属性/RPC/NetDormancy/RepGraph；Slate/UMG invalidation；材质/透明/LOD/Nanite/Lumen/VSM；World Partition/streaming；音频 voice；包体/加载。
3. 每个候选写 location、触发路径、为何可能热点、需采集的 Insights channel/stat/场景、潜在影响和误报条件；不把文本匹配当瓶颈。
4. 按玩家影响×出现频率×预算风险排序，交给 performance-analyst；复制场景加 ue-replication-specialist，UE 底层引擎加 ue-engine-programmer。
5. 输出只读分诊报告和 `ue-performance-validation` 实测计划。没有目标平台原始 trace 时状态只能 CANDIDATE/UNMEASURED，不能 OK/PASS。

## 约束
- 本技能只读，不写报告文件、不修改代码；用户要求实测时切换到 ue-performance-validation。
- 不用通用 `_process/Update` 词表冒充 UE 审计；不在未测量时宣称收益。

## 反例
- 以 Tick 字符串命中数推算 FPS。
- 只看 Game Thread，忽略 GPU、RHI、内存、加载和网络。
- 输出预算 PASS 但无 build/设备/trace。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “代码看起来很慢” | 静态证据只能形成可证伪假设。 |
| “Editor stat fps 够了” | 正式门需要固定协议的目标平台原始证据。 |

## Red Flags
- 使用估算值填“当前实测”。
- 建议无 location/采集方法/误报条件。
- 修改源码或生成 perf-report。

## Verification
- [ ] 候选覆盖 UE CPU/GPU/内存/加载/复制/UI/streaming 域。
- [ ] 每项含位置、触发、采集方法、影响与误报条件。
- [ ] 所有未实测结论明确 CANDIDATE/UNMEASURED。
- [ ] 全程工作树不变并交接 ue-performance-validation。
