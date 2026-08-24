# Performance Evidence Contract

性能结论必须来自目标平台的运行时证据，至少保存：

- 项目 commit、Engine Version、Build Configuration、地图/场景、硬件与分辨率；
- `.utrace`/CSV/截图或平台 profiler 产物路径；
- Game/Render/RHI/GPU、内存、加载与网络中与目标有关的指标；
- 同一场景的 before/after 复测和预算判定。

Unreal Insights 是 UE 的 trace 捕获与分析工具；具体启动参数和通道必须按目标版本的 Epic 官方文档核实，禁止从本模板猜测。
