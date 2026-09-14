---
name: data-layer-subsystem
description: UDataLayerSubsystem（UE 5.6）Data Layer 运行时子系统 - 按资产/标签/名称设置与查询 DataLayer 运行时状态、查询活动与已加载 DataLayer 名称；在 Agent 需要通过 unreal Python 获取/调用 DataLayer 运行时状态时使用；该类在 5.6 已弃用，新实现优先用 DataLayerManager 等价 API
risk: safe
category: development
tags: [ue5.6, data-layer, world-partition, runtime, python, subsystem]
---

# DataLayerSubsystem - Data Layer 运行时子系统（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 获取/调用 DataLayer 运行时状态时使用本 skill（description 触发场景）。
- 本 skill 只在与 data-layer-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UDataLayerSubsystem` 暴露给 Python 的 Data Layer 运行时能力。头文件 `Engine/Source/Runtime/Engine/Public/WorldPartition/DataLayer/DataLayerSubsystem.h`。该类派生自 `UWorldSubsystem`，负责按资产/标签/名称设置与查询 Data Layer（Data Layer Instance）的运行时状态。头文件在类声明处注明该类已被 DataLayerManager 取代：本 skill 记录的是该类保留的遗留 Python 暴露面，可用但已弃用，新代码应优先使用 DataLayerManager 等价 API。

## 入口说明

`UDataLayerSubsystem` 属于 World 子系统，按世界隔离，从对应 `UWorld` 获取：

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
api = world.get_subsystem(unreal.DataLayerSubsystem)
```

- Python 类名为去 U 前缀的反射类 `unreal.DataLayerSubsystem`。
- 世界来源二选一：编辑器主世界用 `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()`；PIE/运行时世界传入对应运行的 `UWorld`。
- Data Layer 状态是运行时概念，PIE/打包运行中才体现真实状态；无 PIE/世界上下文按 `BLOCKED_TOOLING` 处理并停止。
- `world` 为 `None` 按 `BLOCKED_TOOLING`；`api` 为 `None`（子系统未实例化）按 `BLOCKED_INPUT`；目标世界未配置 Data Layer（无 `AWorldDataLayers`/无 Data Layer 资产）时查询无意义，按 `BLOCKED_INPUT`。
- Python 方法名按反射约定转 snake_case：本类方法均未声明 `ScriptMethod` meta，取 C++ 函数名转 snake_case；精确 Python 暴露名需实测确认。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 资产→实例 | `get_data_layer_instance_from_asset(data_layer_asset)` | `UDataLayerInstance* GetDataLayerInstanceFromAsset(const UDataLayerAsset*) const` | `DataLayerInstance` 或 `None` |
| 资产状态 | `get_data_layer_instance_runtime_state(data_layer_asset)` | `EDataLayerRuntimeState GetDataLayerInstanceRuntimeState(const UDataLayerAsset*) const` | `DataLayerRuntimeState` |
| 资产状态 | `get_data_layer_instance_effective_runtime_state(data_layer_asset)` | `EDataLayerRuntimeState GetDataLayerInstanceEffectiveRuntimeState(const UDataLayerAsset*) const` | `DataLayerRuntimeState` |
| 资产状态 | `set_data_layer_instance_runtime_state(data_layer_asset, state, is_recursive=False)` | `void SetDataLayerInstanceRuntimeState(const UDataLayerAsset*, EDataLayerRuntimeState, bool)` | `None`（仅权威端） |
| 名称/标签 | `get_data_layer_from_name(name)` | `UDataLayerInstance* GetDataLayerFromName(FName) const` | `DataLayerInstance` 或 `None` |
| 名称/标签 | `get_data_layer_from_label(label)` | `UDataLayerInstance* GetDataLayerFromLabel(FName) const` | `DataLayerInstance` 或 `None` |
| 名称/标签 | `get_data_layer(data_layer)` | `UDataLayerInstance* GetDataLayer(const FActorDataLayer&) const` | `DataLayerInstance` 或 `None` |
| 状态查询 | `get_data_layer_runtime_state(data_layer)` | `EDataLayerRuntimeState GetDataLayerRuntimeState(const FActorDataLayer&) const` | `DataLayerRuntimeState` |
| 状态查询 | `get_data_layer_runtime_state_by_label(label)` | `EDataLayerRuntimeState GetDataLayerRuntimeStateByLabel(FName) const` | `DataLayerRuntimeState` |
| 状态查询 | `get_data_layer_effective_runtime_state(data_layer)` | `EDataLayerRuntimeState GetDataLayerEffectiveRuntimeState(const FActorDataLayer&) const` | `DataLayerRuntimeState` |
| 状态查询 | `get_data_layer_effective_runtime_state_by_label(label)` | `EDataLayerRuntimeState GetDataLayerEffectiveRuntimeStateByLabel(FName) const` | `DataLayerRuntimeState` |
| 状态查询 | `get_data_layer_state(data_layer)` | `EDataLayerState GetDataLayerState(const FActorDataLayer&) const` | `DataLayerState` |
| 状态查询 | `get_data_layer_state_by_label(label)` | `EDataLayerState GetDataLayerStateByLabel(FName) const` | `DataLayerState` |
| 状态设置 | `set_data_layer_runtime_state(data_layer, state, is_recursive=False)` | `void SetDataLayerRuntimeState(const FActorDataLayer&, EDataLayerRuntimeState, bool)` | `None`（仅权威端） |
| 状态设置 | `set_data_layer_runtime_state_by_label(label, state, is_recursive=False)` | `void SetDataLayerRuntimeStateByLabel(FName, EDataLayerRuntimeState, bool)` | `None`（仅权威端） |
| 状态设置 | `set_data_layer_state(data_layer, state)` | `void SetDataLayerState(const FActorDataLayer&, EDataLayerState)` | `None`（仅权威端） |
| 状态设置 | `set_data_layer_state_by_label(label, state)` | `void SetDataLayerStateByLabel(FName, EDataLayerState)` | `None`（仅权威端） |
| 名称集合 | `get_active_data_layer_names()` | `const TSet<FName>& GetActiveDataLayerNames() const` | `Name 集合`（5.6 实现返回空集） |
| 名称集合 | `get_loaded_data_layer_names()` | `const TSet<FName>& GetLoadedDataLayerNames() const` | `Name 集合`（5.6 实现返回空集） |

- 状态枚举：`EDataLayerRuntimeState`（未加载 / 已加载 / 已激活）与旧式 `EDataLayerState`；`Effective` 变体返回考虑继承关系后的有效状态。
- 全部 `Set` 方法带 `BlueprintAuthorityOnly`，仅权威端（服务器/PIE 中具有权威的客户端）可生效。
- `get_active_data_layer_names()` / `get_loaded_data_layer_names()` 在 5.6 头文件中为已停用实现，返回固定空集合，不应作为真值来源。

## 示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    print("BLOCKED_TOOLING: 世界上下文不可用")
else:
    api = world.get_subsystem(unreal.DataLayerSubsystem)
    if api is None:
        print("BLOCKED_INPUT: DataLayerSubsystem 未实例化")
    else:
        state = unreal.DataLayerRuntimeState.Activated  # 枚举常量拼写以目标 5.6 编辑器实测为准
        api.set_data_layer_runtime_state_by_label("ZoneAlpha", state, False)
        print("state:", api.get_data_layer_runtime_state_by_label("ZoneAlpha"))
```

## 综合实战示例

### Data Layer运行时管理器

```python
import unreal

class DataLayerRuntimeManager:
    def __init__(self):
        self.api = None
        self.world = None
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.DataLayerSubsystem)
        return self.api is not None
    
    def activate_layer(self, layer_label):
        if self.api:
            state = unreal.DataLayerRuntimeState.Activated
            self.api.set_data_layer_runtime_state_by_label(layer_label, state, False)
            return True
        return False
    
    def deactivate_layer(self, layer_label):
        if self.api:
            state = unreal.DataLayerRuntimeState.NotLoaded
            self.api.set_data_layer_runtime_state_by_label(layer_label, state, False)
            return True
        return False
    
    def get_layer_state(self, layer_label):
        if self.api:
            return self.api.get_data_layer_runtime_state_by_label(layer_label)
        return None
    
    def get_all_active_layers(self):
        if self.api:
            return self.api.get_active_data_layer_names()
        return set()

def manage_data_layer_scenes():
    manager = DataLayerRuntimeManager()
    
    if not manager.initialize():
        print("Failed to initialize DataLayerSubsystem")
        return
    
    # 激活场景区域
    manager.activate_layer("ZoneAlpha")
    manager.activate_layer("ZoneBeta")
    
    # 隐藏非相关区域
    manager.deactivate_layer("ZoneGamma")
    
    # 查询
    active = manager.get_all_active_layers()
    print(f"Active layers: {len(active)}")
```

### World Partition场景优化

```python
import unreal

class WorldPartitionOptimizer:
    def __init__(self):
        self.api = None
        self.world = None
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.DataLayerSubsystem)
        return self.api is not None
    
    def optimize_layers_for_performance(self, max_active_layers=5):
        if not self.api:
            return
        
        # 按优先级激活层
        priority_layers = ["Zone_Alpha", "Zone_Beta", "Zone_Gamma"]
        
        active_count = 0
        for layer_label in priority_layers:
            if active_count >= max_active_layers:
                self.api.set_data_layer_runtime_state_by_label(
                    layer_label,
                    unreal.DataLayerRuntimeState.NotLoaded,
                    False
                )
            else:
                self.api.set_data_layer_runtime_state_by_label(
                    layer_label,
                    unreal.DataLayerRuntimeState.Activated,
                    False
                )
                active_count += 1
    
    def purge_unused_layers(self, active_labels):
        if not self.api:
            return
        
        # 获取所有已加载层
        loaded = self.api.get_loaded_data_layer_names()
        
        # 关闭不在活跃列表中的层
        for label in loaded:
            if label not in active_labels:
                self.api.set_data_layer_runtime_state_by_label(
                    label,
                    unreal.DataLayerRuntimeState.NotLoaded,
                    False
                )

def optimize_large_world():
    optimizer = WorldPartitionOptimizer()
    
    if not optimizer.initialize():
        print("Failed to initialize DataLayerSubsystem")
        return
    
    # 先激活近处区域
    optimizer.optimize_layers_for_performance(max_active_layers=3)
    
    # 根据需要动态切换
    active_zones = ["Zone_Alpha", "Zone_Beta", "Zone_Gamma"]
    optimizer.purge_unused_layers(active_zones)
```

### 多世界Data Layer同步

```python
import unreal

def sync_data_layers_across_worlds():
    editor_world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    if editor_world is None:
        print("Editor world not available")
        return
    
    editor_api = editor_world.get_subsystem(unreal.DataLayerSubsystem)
    
    # 同步 Editor 世界的 Data Layer 状态到 PIE 世界
    gi = unreal.get_game_instance()
    if gi:
        pie_world = gi.get_world()
        if pie_world and pie_world != editor_world:
            pie_api = pie_world.get_subsystem(unreal.DataLayerSubsystem)
            
            if editor_api and pie_api:
                # 复制层状态
                active_layers = editor_api.get_active_data_layer_names()
                for layer_name in active_layers:
                    state = editor_api.get_data_layer_runtime_state_by_label(layer_name)
                    pie_api.set_data_layer_runtime_state_by_label(layer_name, state, False)
```

## 高级用法

### Data Layer性能监控

```python
import unreal

class DataLayerPerformanceMonitor:
    def __init__(self):
        self.api = None
        self.world = None
        self.layer_stats = {}
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.DataLayerSubsystem)
        return self.api is not None
    
    def record_layer_load_time(self, layer_label, load_time_ms):
        if layer_label not in self.layer_stats:
            self.layer_stats[layer_label] = {"total": 0, "count": 0, "min": float('inf'), "max": 0}
        
        stats = self.layer_stats[layer_label]
        stats["total"] += load_time_ms
        stats["count"] += 1
        stats["min"] = min(stats["min"], load_time_ms)
        stats["max"] = max(stats["max"], load_time_ms)
    
    def get_stats(self):
        result = {}
        for layer, stats in self.layer_stats.items():
            if stats["count"] > 0:
                result[layer] = {
                    "avg": stats["total"] / stats["count"],
                    "min": stats["min"],
                    "max": stats["max"],
                    "count": stats["count"]
                }
        return result

def monitor_data_layer_performance():
    monitor = DataLayerPerformanceMonitor()
    
    if not monitor.initialize():
        print("Failed to initialize")
        return
    
    # 监控层加载性能
    start_time = unreal.SystemLibrary.get_time_seconds(None)
    monitor.api.set_data_layer_runtime_state_by_label("ZoneAlpha", unreal.DataLayerRuntimeState.Activated, False)
    end_time = unreal.SystemLibrary.get_time_seconds(None)
    
    load_time_ms = (end_time - start_time) * 1000
    monitor.record_layer_load_time("ZoneAlpha", load_time_ms)
    
    print(f"Load time: {load_time_ms:.2f}ms")
    print(f"Stats: {monitor.get_stats()}")
```

### Data Layer分层管理

```python
import unreal

def hierarchical_data_layer_manager():
    api = None
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world:
        api = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if not api:
        print("DataLayerSubsystem not available")
        return
    
    # 按层级激活
    def activate_with_hierarchy(layer_label, recursive=True):
        # 激活当前层
        api.set_data_layer_runtime_state_by_label(layer_label, unreal.DataLayerRuntimeState.Activated, False)
        
        # 如果需要递归激活父层
        if recursive:
            # 父层通常遵循命名约定，如 "Zone" 是 "Zone_Alpha" 的父层
            parent_layer = layer_label.rsplit("_", 1)[0] if "_" in layer_label else None
            if parent_layer:
                api.set_data_layer_runtime_state_by_label(
                    parent_layer,
                    unreal.DataLayerRuntimeState.Activated,
                    False
                )
    
    activate_with_hierarchy("Zone_Alpha_Subsection1", True)
```

### Data Layer资源联动

```python
import unreal

def data_layer_resource_linkage():
    api = None
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world:
        api = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if not api:
        print("DataLayerSubsystem not available")
        return
    
    # 通过资产获取 Data Layer Instance
    asset = unreal.load_asset("/Game/DataLayers/DL_ZoneAlpha.DL_ZoneAlpha")
    if asset:
        instance = api.get_data_layer_instance_from_asset(asset)
        if instance:
            state = api.get_data_layer_instance_runtime_state(asset)
            print(f"Layer state: {state}")
```

## 常见问题与最佳实践

### 性能优化技巧

1. **分批激活层**：
   - 避免一次性激活所有 Data Layer
   - 使用优先级队列逐批激活
   
2. **懒加载策略**：
   ```python
   def lazy_load_layers(needed_layers, max_concurrent=3):
       loaded = 0
       for layer in needed_layers:
           if loaded < max_concurrent:
               activate_layer(layer)
               loaded += 1
           else:
               # 等待某些层激活完成后再激活下一批
               break
   ```

3. **缓存状态**：
   - 避免频繁查询 `get_data_layer_runtime_state_by_label`
   - 在状态变更时更新本地缓存

### 常见陷阱

1. **仅权威端生效**：
   - `SetDataLayerRuntimeState` 等方法带 `BlueprintAuthorityOnly`
   - 客户端调用不会产生实际效果
   
2. **空集合返回**：
   - `get_active_data_layer_names()` 在 5.6 中返回空集合
   - 应使用 `get_data_layer_runtime_state_by_label` 查询具体层状态

### 最佳实践

1. **分场景管理**：
   - 使用层级命名约定（Zone_Alpha, Zone_Alpha_Sub1）
   - 通过前缀/后缀组织逻辑组
   
2. **状态保存与恢复**：
   ```python
   def save_layer_states():
       states = {}
       for layer in get_all_layers():
           states[layer] = get_layer_state(layer)
       return states
   
   def restore_layer_states(states):
       for layer, state in states.items():
           set_layer_state(layer, state)
   ```

## 限制和注意事项

- 本 skill 记录的是该类保留的 Python 调用面；全部成员在头文件中均已标记弃用（`DEPRECATED`，并注明由 DataLayerManager 接管）。新实现优先改为使用 `UDataLayerManager` 等价 API，仅在迁移尚未完成时使用本遗留入口。
- 按世界隔离：每个 `UWorld` 独立持有实例；Data Layer 状态归属当前世界，改世界/换关卡需重新获取并按新世界重新查询。
- 状态设置均为权威端操作；非权威上下文调用不会产生预期效果。
- 无 PIE/世界上下文按 `BLOCKED_TOOLING`，缺 Data Layer 资产/未配置 Data Layer 的世界按 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 环境中实测的精确暴露名、枚举常量、标签/名称/资产引用拼写不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。