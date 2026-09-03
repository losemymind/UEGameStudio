---
name: data-layer-subsystem
description: UDataLayerSubsystem（UE 5.6）Data Layer 运行时子系统 - 按资产/标签/名称设置与查询 DataLayer 运行时状态、查询活动与已加载 DataLayer 名称；在 Agent 需要通过 unreal Python 获取/调用 DataLayer 运行时状态时使用；该类在 5.6 已弃用，新实现优先用 DataLayerManager 等价 API
tags: [ue5.6, data-layer, world-partition, runtime, python, subsystem]
---

# DataLayerSubsystem - Data Layer 运行时子系统（UE 5.6）

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

## 快速示例

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

## 注意事项

- 本 skill 记录的是该类保留的 Python 调用面；全部成员在头文件中均已标记弃用（`DEPRECATED`，并注明由 DataLayerManager 接管）。新实现优先改为使用 `UDataLayerManager` 等价 API，仅在迁移尚未完成时使用本遗留入口。
- 按世界隔离：每个 `UWorld` 独立持有实例；Data Layer 状态归属当前世界，改世界/换关卡需重新获取并按新世界重新查询。
- 状态设置均为权威端操作；非权威上下文调用不会产生预期效果。
- 无 PIE/世界上下文按 `BLOCKED_TOOLING`，缺 Data Layer 资产/未配置 Data Layer 的世界按 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 环境中实测的精确暴露名、枚举常量、标签/名称/资产引用拼写不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。