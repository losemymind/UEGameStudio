---
name: ue-performance-validation
description: 在目标平台/代表性内容上用 Unreal Insights、GPU/内存/加载工具实测性能预算，比较修复前后并生成可发布证据。Use when 垂直切片、里程碑、打磨和 release readiness。
---

# UE 性能验证

## 流程
1. 读取获批预算：目标硬件/OS/分辨率/画质/构建配置/地图/玩家数/网络条件，以及 frame CPU/GPU、线程、内存、加载、卡顿、网络阈值；缺失则 BLOCKED。
2. 固定测试协议：不可变构建 ID、设备 ID/规格、预热、场景步骤、采样时长、重复次数、后台条件和统计口径（median/P95/P99/峰值）。
3. 采集目标平台数据：Unreal Insights CPU/GPU/Load Time/Memory/Network trace；GPU Visualizer/ProfileGPU；MemReport/LLM；CSV Profiler；平台工具按需。保存原始 trace/log/命令/退出码。
4. 校验 trace 的 build/地图/时长/通道完整性；剔除样本必须说明理由，不得挑最好一次。
5. 对每项给 PASS/WARN/FAIL、预算/实测/余量/置信区间；关联 hitch、callstack、asset、network actor 等热点。
6. 修复必须在相同协议上 A/B 复测并跑玩法回归；由 performance-analyst + ue-engine-programmer 复核，复制场景加 ue-replication-specialist。
7. 经批准写 `production/polish/perf-report.md`，引用原始证据；例外含 owner、理由、到期日、批准人。
8. **协议规划模式**：只读取现有预算/环境信息并输出测试协议与缺失条件；不得运行 profile、改变设备/项目配置或写 `perf-report.md`。

## 约束
- 静态扫描只能生成候选，不能给预算 PASS；Editor 数据不能代替目标平台 Shipping/Development 约定构建。
- 不修改系统设置、设备状态或项目配置来“优化结果”而不记录。
- 未获执行授权或用户只要求协议时，必须使用协议规划模式。

## 反例
- 用代码扫描估算 FPS 并标 PASS。
- 只报平均帧率，不报 frame time、P95/P99 和 hitch。
- 修复前后换地图/硬件/画质。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “平均 60 FPS 就达标” | 均值会隐藏 P95/P99 卡顿和最坏帧。 |
| “Editor 数据趋势一样” | Editor 开销与目标平台构建不同，不能作为发布门证据。 |

## Red Flags
- trace 无 build/设备/场景/时长元数据。
- 只报告平均值或选择最好样本。
- A/B 协议不一致仍宣称收益。

## Verification
- [ ] 协议和预算含设备、构建、场景、配置、重复与统计口径。
- [ ] 原始 trace/log 与不可变 build ID 绑定。
- [ ] 报告给预算/实测/余量/P95/P99/异常和热点证据。
- [ ] 规划/只读模式不改项目、设备或外部状态。
