---
name: performance-diagnostics
description: 在 UE5.6 项目出现帧时间超预算、卡顿、内存增长、加载或流送、渲染成本及平台性能回退时使用；从可复现证据定位瓶颈，提出并复测最小优化实验，不用于单纯崩溃排查。
category: development
risk: critical
---

# UE 性能诊断与优化

把性能问题写成可复现、可测量的假设，再选择工具和改动。来源是 Epic 的 [Unreal Performance Optimization Learning Path](https://dev.epicgames.com/community/learning/paths/Rkk/unreal-engine-unreal-performance-optimization-learning-path)。[来源索引](references/source-index.md)列出截至 2026-09-29 的 31 个子条目及核对范围；不要把目录简介当作已阅读全文。

## 何时使用此技能

- UE5.6 目标构建发生持续低帧率、尾部卡顿、输入延迟、内存增长、加载或流送回退。
- 需要选择 Unreal Insights、GPU Profiler 或平台工具，解释 Trace 并设计优化前后对照实验。
- 需要把渲染、运行时或跨系统性能问题移交给相应 Agent，并保留证据与版本限制。
- 仅有崩溃堆栈、没有性能症状时，使用崩溃分析流程。

## 工作方法

1. 确认 UE 版本、目标平台与设备、构建配置、场景、目标帧时间、问题类型（持续低帧率、偶发 hitch、内存增长、输入延迟或画质问题）。缺失信息可以先从现有 trace、日志和项目配置推断，并标注假设。
2. 在目标硬件上用代表性打包构建复现；记录分辨率、Scalability、VSync、帧率上限、冷/热缓存、运行路线及采样次数。比较以毫秒为主，关注尾部帧时间和波动，不仅看平均 FPS。
3. 用 `stat unit` 等快速定位 Game、Render/RHI、GPU 或等待；再选 Unreal Insights 的 Timing、Memory、Load Time、Networking、Slate 等视图，或 GPU Profiler、RenderDoc、平台原生工具。工具、trace channel 和命令以项目 UE 版本的官方文档及实际可用性为准。
4. 在 trace 中标出异常帧或内存区间，给出时间轴、线程/事件、成本、与正常样本的差异。区分相关性与根因；对于 GPU/CPU 重叠、帧队列、VSync 和异步任务，避免把相加时间当作帧时间。
5. 每次只验证一个主要假设，给出可回滚的最小实验；在相同条件下对照基线，报告帧时间、hitch 频率、内存和画质或延迟的取舍。没有复现与测量时，把建议写成待验证假设。

## 按问题读取

- 帧时间、Unreal Insights、输入延迟和跨平台测量：读 [profiling.md](references/profiling.md)。
- GPU、Nanite、Lumen、VSM、TSR、光追、灯光和 PSO：读 [rendering.md](references/rendering.md)。
- 关卡流送、内存、GC、物理、动画、网络及移动端卡顿：读 [runtime.md](references/runtime.md)。
- 需要回溯教程或核查版本：读 [source-index.md](references/source-index.md)，再打开对应原文。旧教程的 CVar、默认值、实验功能和菜单位置必须按项目版本核对。

定位完成后，实施者再按责任选择现有的 `rendering-optimization`、`world-optimization`、`mass-entity`、`animation-optimization`、`streaming-optimization` 或 `network-optimization`。这些 skill 的命令和参数是候选示例，须经当前 UE 版本、平台和项目配置核实，并用同条件 A/B 测量确认。

## 交付

给出问题定义、采集条件、证据表、最可能瓶颈及置信度、下一步实验、验证结果、版本限制和来源链接。若用户要求直接改项目，先定位现有设置和代码；修改后用相同场景复测。不要把未运行的命令或未采集的 trace 写成已验证结论。

## 示例

收到“UE5.6 打包版切换地图时卡顿”后，先填一份可复用的采集卡，再选择工具：

```text
UE 版本 / 构建 ID / 配置：
平台 / 设备 / 驱动：
地图与复现步骤：
分辨率 / 质量档位 / VSync：
冷启动或热缓存 / 预热：
采样窗口 / 重复次数：
批准的帧时间与加载预算：
异常帧时间范围 / Trace 文件：
对照实验唯一变量：
画质、内存或功能副作用：
```

用这张卡在异常区间检查 Load Time 与 Timing 事件，比较同条件正常区间；无法提供 Trace 时将流送、同步 IO 或 PSO 等写成待验证假设。

## 限制和注意事项

- 学习路径 31 个子条目中，来源索引标记“目录”的内容只核对了总页简介；视频字幕未核对，不能据此声称教程中的具体命令或阈值。
- 路径含不同 UE 版本的教程；任何菜单、CVar、默认值和实验性功能都需按当前 UE5.6 工程核对。
- 没有目标设备和代表性构建时，只能给早期定位或实验计划；没有批准预算时不能判定性能门禁通过。
