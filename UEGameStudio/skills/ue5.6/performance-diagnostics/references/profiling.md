# 测量与定位

适用于持续低帧率、帧时间波动、输入延迟和不明瓶颈。优先参照路径条目 1、3–7、10、14、22、27；来源见 [source-index.md](source-index.md)。

## 采集设计

- 用具体操作定义可重复场景；写明设备、驱动、UE 版本、打包配置、分辨率、Scalability、VSync/限帧、冷/热启动和运行时长。
- 以目标帧时间预算衡量：30/60/120 FPS 分别约为 33.3/16.7/8.3 ms。分别记录典型帧与异常帧，不用平均 FPS 掩盖 hitch。
- 先看 Game、Render/RHI、GPU、等待和 Present 的关系。并行阶段会重叠，不能把各列毫秒数直接相加。高耗时的线程不一定是最终限制项；查看关键路径和同步点。
- Unreal Insights 的 Timing View 适合线程与任务；Memory Insights 适合分配/释放和增长；Asset Loading/Load Time 适合流送；Networking Insights 适合网络；Slate Insights 适合 UI。GPU 细节再用项目版本可用的 GPU Profiler、RenderDoc 或平台工具。
- 移动端应把 Unreal Insights 与 iOS/Android 平台原生 CPU、GPU、内存、功耗 trace 对齐；若只看引擎内部数据，可能遗漏驱动、系统调度和功耗限制。参照路径条目 22 的范围说明。

## 证据记录

| 字段 | 记录内容 |
| --- | --- |
| 症状 | 具体场景、出现频率、预算与实际帧时间 |
| 采集 | 构建、设备、设置、trace 文件和时间区间 |
| 观察 | 异常帧关键路径、事件/线程、内存变化、正常帧对照 |
| 假设 | 可被实验推翻的单一原因及替代解释 |
| 实验 | 最小改动、回滚方法、画质/延迟/内存副作用 |
| 结果 | 同条件前后数据和剩余不确定性 |

输入延迟问题还要区分输入采样、游戏逻辑、渲染提交、GPU、显示队列与呈现阶段；参考路径条目 5 和 [Low-Latency Frame Syncing](https://dev.epicgames.com/documentation/unreal-engine/low-latency-frame-syncing-in-unreal-engine)。不要用提高平均 FPS 代替端到端延迟测量。

官方起点：[性能分析与配置](https://dev.epicgames.com/documentation/en-us/unreal-engine/introduction-to-performance-profiling-and-configuration-in-unreal-engine)、[Unreal Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-insights-in-unreal-engine)、[Memory Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/memory-insights-in-unreal-engine)。
