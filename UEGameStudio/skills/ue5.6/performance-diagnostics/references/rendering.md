# 渲染、画质与 PSO

适用于 GPU 帧时间、渲染线程/RHI 提交、画质缩放、首次出现时卡顿。参照路径条目 7、11–13、15、17、20、23–24、26、28、30–31；来源见 [source-index.md](source-index.md)。

## 定位顺序

1. 对照 `stat unit`、GPU Profiler 和 Unreal Insights，确认限制来自 GPU 执行、CPU 提交或等待。UE 5.6 起的新 GPU Profiler 和 RHI 提交流程请按项目版本核对。
2. 用 GPU pass 与可视化数据定位具体成本，再考虑像素数、材质、光照、阴影、几何、透明、后处理和内存驻留。RenderDoc 更适合核查单帧 draw/资源状态；不要用它单独解释跨帧 hitch。
3. Nanite、Lumen、VSM、TSR、World Partition、硬件光追和灯光缩放有平台与画质取舍。选一个设置或一类资产做 A/B，记录 GPU/CPU 帧时间、显存、画面差异及目标设备覆盖。Lyra Device Profiles 可作为配置组织范例，而不是直接复制项目参数。
4. 时间稳定但图像出现鬼影、闪烁或拖影时，读路径条目 17 的 temporal quality 内容，再判断抗锯齿/上采样设置；不要把画质问题误判为性能瓶颈。

## PSO / Shader hitch

- 先证明卡顿与首次遇到的 PSO 编译或创建同时间发生，并排除资产加载、GC、线程调度等并发原因。
- 比较冷驱动缓存与热缓存的同一路线。若使用 `-clearPSODriverCache` 做首次体验测试，应在可丢弃的测试环境运行，记录平台与 UE 版本。
- 查看项目使用的 PSO precaching 与 bundled cache 方案、覆盖率、遗漏及加载阶段等待策略。相关 CVar、默认值和功能覆盖持续变化，按版本查 [PSO Precaching](https://dev.epicgames.com/documentation/en-us/unreal-engine/pso-precaching-for-unreal-engine) 与 [Bundled PSO Caches](https://dev.epicgames.com/documentation/en-us/unreal-engine/manually-creating-bundled-pso-caches-in-unreal-engine)。
- 对照启动时间、运行时 hitch、临时缺画、内存和编译开销；不要仅凭启用预缓存推断卡顿已消失。

官方参考：[实时渲染优化目录](https://dev.epicgames.com/documentation/en-us/unreal-engine/optimizing-and-debugging-projects-for-realtime-rendering-in-unreal-engine)、[Lumen Performance Guide](https://dev.epicgames.com/documentation/en-us/unreal-engine/lumen-performance-guide-for-unreal-engine)、[Ray Tracing Performance Guide](https://dev.epicgames.com/documentation/en-us/unreal-engine/ray-tracing-performance-guide-in-unreal-engine)。
