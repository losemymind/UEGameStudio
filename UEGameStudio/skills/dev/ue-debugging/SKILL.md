---
name: ue-debugging
description: 基于证据诊断 UE 编译、启动、崩溃、Gameplay、Replication、渲染和性能问题，先定位根因再提出修复。Use when 症状可复现但原因未知。
---

# UE 系统化调试

## 流程
1. 建问题卡：预期/实际、首次出现、平台/构建/UE 版本、复现率、最小步骤、最近改动、影响与已有日志。
2. 保护证据：保存完整调用栈、日志上下文、CrashContext/minidump、Insights trace 或网络/渲染捕获；脱敏后记录路径和哈希。
3. 建 2–5 个可证伪假设，每个列预测、最小实验与判废条件；一次只改变一个变量。
4. 按故障域选证据：UBT/UHT/Linker；Game/Editor/Server 日志；ensure/check；Gameplay Debugger；Network Insights；Unreal Insights；RenderDoc/GPU Visualizer。
5. 用二分、最小复现、符号化栈和版本/源码核实收敛；相关不等于因果。
6. 输出 root cause/trigger/contributing factors、置信度和未排除项。用户仅要求诊断时不修改；获授权修复后补回归测试并复现失败→通过。

## 约束
- 不删缓存、DerivedDataCache、Saved 或 Intermediate 作为默认“修复”；若作为实验须精确范围、可恢复且获授权。
- 不凭单行日志下结论；线上敏感数据必须脱敏。

## 反例
- 看到 Access Violation 就断言是空指针。
- 同时改多个变量，无法归因。
- 未复现成功就宣布修复。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “这条日志通常就是根因” | 单点相关性不足，必须用预测与实验排除替代解释。 |
| “先清缓存最省事” | 宽泛清理破坏证据和可复现性，也可能掩盖真实根因。 |

## Red Flags
- 没有构建 ID/版本/原始日志就给确定性根因。
- 一次实验改变多个变量。
- 诊断请求下直接改源码或删缓存。

## Verification
- [ ] 有可复现步骤、构建/版本、原始证据和哈希/路径。
- [ ] 假设均可证伪且实验单变量。
- [ ] 根因与触发/诱因分离，声明置信度。
- [ ] 诊断模式下文件系统不变。
