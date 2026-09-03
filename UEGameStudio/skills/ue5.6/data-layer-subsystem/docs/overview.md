# DataLayerSubsystem - API 参考与完整示例（UE 5.6）

本文记录 UE 5.6 引擎 `UDataLayerSubsystem` 暴露给 Python 的调用面。数据来源为头文件 `Engine/Source/Runtime/Engine/Public/WorldPartition/DataLayer/DataLayerSubsystem.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的公开成员；非 `UFUNCTION` 模板成员与仅编辑器辅助函数不进入本文档的 API 清单。类声明处注明该类已被 DataLayerManager 取代，其公开成员在头文件中均标记为弃用。

## 基类结论

- 类声明：`UCLASS(Config = Engine, MinimalAPI) class UDataLayerSubsystem : public UWorldSubsystem`。
- Python 侧按 World 子系统模式获取：`world.get_subsystem(unreal.DataLayerSubsystem)`。
- 按世界隔离，实例随所属 `UWorld` 创建与销毁；Data Layer 运行时状态属于特定世界。

## 获取模式

### 编辑器主世界

```python
import unreal

editor_subsystem = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
if editor_subsystem is None:
    raise RuntimeError("BLOCKED_TOOLING: 编辑器子系统上下文不可用")

world = editor_subsystem.get_editor_world()
if world is None:
    raise RuntimeError("BLOCKED_TOOLING: 编辑器主世界不可用")

api = world.get_subsystem(unreal.DataLayerSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_INPUT: DataLayerSubsystem 未实例化")
```

### PIE / 运行时世界

PIE 或运行时过程中取得对应当前会话的 `UWorld` 后再取子系统；Data Layer 状态在 PIE/打包运行中才具有真实语义，脚本无法取得对应世界对象时按 `BLOCKED_TOOLING` 处理。

## 方法命名与返回约定

- Python 类名：去 U 前缀，`unreal.DataLayerSubsystem`。
- Python 方法名：取 `meta=(ScriptMethod=...)` 值转 snake_case；本类方法均未声明该 meta，取 C++ 函数名转 snake_case。
- 精确 Python 暴露名须以目标 5.6 编辑器实测确认，不预先断言。
- Out/ByRef 参数约定：`void` + 单个 Out 参数直接返回该参数；返回值 + Out 参数按元组返回（返回值在前）。本类公开方法均无 Out/ByRef 参数，一律直接返回状态值或对象引用。
- 标志 `BlueprintAuthorityOnly`：状态设置方法只在权威端生效。

## 逐方法 API 参考

### 按资产（DataLayerAsset）操作

`get_data_layer_instance_from_asset(data_layer_asset)`
- C++ 签名：`UDataLayerInstance* GetDataLayerInstanceFromAsset(const UDataLayerAsset*) const`。
- 语义：按 Data Layer 资产定位对应的 `UDataLayerInstance`。
- Python 返回：`DataLayerInstance` 或 `None`。

`get_data_layer_instance_runtime_state(data_layer_asset)`
- C++ 签名：`EDataLayerRuntimeState GetDataLayerInstanceRuntimeState(const UDataLayerAsset*) const`。
- 语义：查询资产对应 Data Layer 的运行时状态。
- Python 返回：`unreal.DataLayerRuntimeState`。

`get_data_layer_instance_effective_runtime_state(data_layer_asset)`
- C++ 签名：`EDataLayerRuntimeState GetDataLayerInstanceEffectiveRuntimeState(const UDataLayerAsset*) const`。
- 语义：查询资产对应 Data Layer 的有效状态（考虑继承关系后）。
- Python 返回：`unreal.DataLayerRuntimeState`。

`set_data_layer_instance_runtime_state(data_layer_asset, state, is_recursive=False)`
- C++ 签名：`void SetDataLayerInstanceRuntimeState(const UDataLayerAsset*, EDataLayerRuntimeState InState, bool bInIsRecursive)`。
- 语义：按资产设置 Data Layer 运行时状态；`is_recursive=True` 时同步作用于子 Data Layer。
- 权威端操作，Python 返回：`None`。

```python
import unreal

api = world.get_subsystem(unreal.DataLayerSubsystem)
asset = unreal.load_asset("/Game/DataLayers/ZoneAlpha")  # 资产路径拼写以项目为准
instance = api.get_data_layer_instance_from_asset(asset)
print({"status": "OK", "instance": instance.get_name() if instance else None})
```

### 按名称/标签（Instance / FActorDataLayer）操作

`get_data_layer_from_name(name)` — `UDataLayerInstance* GetDataLayerFromName(FName) const`，按 Data Layer 名称定位实例，返回 `DataLayerInstance` 或 `None`。

`get_data_layer_from_label(label)` — `UDataLayerInstance* GetDataLayerFromLabel(FName) const`，按标签定位实例，返回 `DataLayerInstance` 或 `None`。

`get_data_layer(data_layer)` — `UDataLayerInstance* GetDataLayer(const FActorDataLayer&) const`，按旧式 `FActorDataLayer` 引用定位实例，返回 `DataLayerInstance` 或 `None`。

`get_data_layer_runtime_state(data_layer)` — `EDataLayerRuntimeState GetDataLayerRuntimeState(const FActorDataLayer&) const`。

`get_data_layer_runtime_state_by_label(label)` — `EDataLayerRuntimeState GetDataLayerRuntimeStateByLabel(FName) const`。

`get_data_layer_effective_runtime_state(data_layer)` — `EDataLayerRuntimeState GetDataLayerEffectiveRuntimeState(const FActorDataLayer&) const`。

`get_data_layer_effective_runtime_state_by_label(label)` — `EDataLayerRuntimeState GetDataLayerEffectiveRuntimeStateByLabel(FName) const`。

`get_data_layer_state(data_layer)` — `EDataLayerState GetDataLayerState(const FActorDataLayer&) const`，旧式枚举。

`get_data_layer_state_by_label(label)` — `EDataLayerState GetDataLayerStateByLabel(FName) const`，旧式枚举。

`set_data_layer_runtime_state(data_layer, state, is_recursive=False)` — `void SetDataLayerRuntimeState(const FActorDataLayer&, EDataLayerRuntimeState, bool)`；权威端操作。

`set_data_layer_runtime_state_by_label(label, state, is_recursive=False)` — `void SetDataLayerRuntimeStateByLabel(FName, EDataLayerRuntimeState, bool)`；权威端操作。

`set_data_layer_state(data_layer, state)` — `void SetDataLayerState(const FActorDataLayer&, EDataLayerState)`；权威端操作，旧式枚举。

`set_data_layer_state_by_label(label, state)` — `void SetDataLayerStateByLabel(FName, EDataLayerState)`；权威端操作，旧式枚举。

Python 示例（按标签设置与查询运行时状态）：

```python
import unreal

api = world.get_subsystem(unreal.DataLayerSubsystem)
activated = unreal.DataLayerRuntimeState.Activated  # 枚举常量拼写以目标 5.6 编辑器实测为准
api.set_data_layer_runtime_state_by_label("ZoneAlpha", activated, False)
state = api.get_data_layer_runtime_state_by_label("ZoneAlpha")
print({"status": "OK", "label": "ZoneAlpha", "runtime_state": str(state)})
```

### 名称集合（已停用返回空集）

`get_active_data_layer_names()` — `const TSet<FName>& GetActiveDataLayerNames() const`；5.6 头文件实现返回固定空集合，不能作为活动 Data Layer 真值来源。

`get_loaded_data_layer_names()` — `const TSet<FName>& GetLoadedDataLayerNames() const`；5.6 头文件实现返回固定空集合，不能作为已加载 Data Layer 真值来源。

## 完整端到端示例

```python
import unreal

def main():
    ubs = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
    if ubs is None:
        print({"status": "BLOCKED_TOOLING", "reason": "编辑器子系统上下文不可用"})
        return

    world = ubs.get_editor_world()
    if world is None:
        print({"status": "BLOCKED_TOOLING", "reason": "编辑器主世界不可用"})
        return

    api = world.get_subsystem(unreal.DataLayerSubsystem)
    if api is None:
        print({"status": "BLOCKED_INPUT", "reason": "DataLayerSubsystem 未实例化"})
        return

    label = "ZoneAlpha"
    activated = unreal.DataLayerRuntimeState.Activated  # 枚举常量拼写以目标 5.6 编辑器实测为准
    api.set_data_layer_runtime_state_by_label(label, activated, False)
    runtime_state = api.get_data_layer_runtime_state_by_label(label)
    effective_state = api.get_data_layer_effective_runtime_state_by_label(label)
    instance = api.get_data_layer_from_label(label)
    print({
        "status": "OK",
        "label": label,
        "runtime_state": str(runtime_state),
        "effective_state": str(effective_state),
        "instance": instance.get_name() if instance else None,
    })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_TOOLING`：编辑器世界或编辑器子系统上下文不可用；PIE/运行时过程中无法取得对应当前会话的 `UWorld`。
- `BLOCKED_INPUT`：`DataLayerSubsystem` 未实例化；目标世界未配置 Data Layer（无 `AWorldDataLayers`/无 Data Layer 资产）；或查询/设置的标签、名称、资产在当前世界中定位不到对象。
- 本文档只记录该类的 `UFUNCTION` 暴露面；未在真实 UE 5.6 编辑器/PIE 中实测的精确暴露名、枚举常量与资产引用拼写一律不做"已验证"断言。全部公开成员在头文件中标记弃用，新代码优先使用 DataLayerManager 等价 API。