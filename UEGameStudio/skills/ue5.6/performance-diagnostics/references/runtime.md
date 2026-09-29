# 运行时卡顿、内存与系统成本

适用于关卡流送、GC、资产加载、物理、动画、StateTree、网络及移动端的成本。参照路径条目 2、8–10、16、18–19、21–22、25、29；来源见 [source-index.md](source-index.md)。

## 关卡流送 hitch

路径条目 9 的指南以 UE 5.7 为基准，按 Insights 事件把卡顿归类为加载、对象与组件创建、物理状态/初始 overlap、渲染注册、BeginPlay/EndPlay、GC、同步加载/FlushAsyncLoading 或 PSO。先确定异常帧里的主成本与调用方，再考虑资产数量、实例化、HLOD、碰撞数据和时间预算。该指南建议的 trace channel 示例为 `-trace=default,counter,stats,file,loadtime,assetloadtime,task,chaoslocks,contextswitch`；Windows `contextswitch` 捕获有权限条件，不能用时去掉该 channel。不要把这个示例无差别用于所有项目。

在真实目标构建验证。编辑器、首次运行的驱动缓存、CPU 核心数和已复用的流送关卡会改变结果。UE 5.6/5.7 的 FastGeo、统一流送预算、异步物理状态创建等涉及实验功能，先核对版本和项目兼容性，再在可回滚分支测试。

## 内存

用 Memory Insights 对比分配、释放、LLM 标签和增长区间；用 MemReport、对象/纹理列表等交叉核查，区分真实泄漏、缓存、资源驻留和未追踪内存。记录峰值与设备预算、出现路径和对象所有者。路径条目 10 给出 City Sample 的完整案例；官方 [Memory Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/memory-insights-in-unreal-engine) 说明采集与查询。内存紧张也可能通过 GC/流送增加 CPU 卡顿。

## 专项路由

- 物理：路径条目 16 将成本分为碰撞与场景查询、刚体求解、破碎、角色物理和布料。检查碰撞形状、过滤、overlap、移动性、LOD、迭代和活跃对象数；每项都需 trace 或统计证据。
- 动画：路径条目 19 区分 Skeletal Mesh 的 Game Thread tick 成本与 Anim Blueprint/Anim Graph 的 worker thread 成本。按可见性、LOD、Update Rate、共享/预算机制及线程安全更新逐项验证。
- 网络：路径条目 21 聚焦复制引起的 hitch 与带宽饱和；先看 Networking Insights、包大小、更新频率和异常时间段，再定位对象或 RPC。
- StateTree：路径条目 18 介绍 scheduled tick policy 与不逐帧 tick 的异步任务；只在 StateTree 确实占用预算且版本支持时采用。
- 移动端：路径条目 22 指向 iOS/Android 原生 profiler 与 Unreal Insights 的联合分析；同时记录热状态、功耗、分辨率和设备 Profile。

任何减少工作量的提案都要检查玩法正确性、流送可见性、碰撞行为、网络同步和画质，并在目标设备复测。
