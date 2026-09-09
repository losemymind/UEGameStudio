---
name: niagara-function-library
description: UNiagaraFunctionLibrary（UE 5.6）Niagara特效函数库 - 系统创建/发射/查询、数据接口、特效控制；在 Agent 需要通过 unreal Python 控制 Niagara 特效时使用
tags: [ue5.6, niagara, particles, python, statics]
---

# NiagaraFunctionLibrary - Niagara特效工具库（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UNiagaraFunctionLibrary`（`UObject` 派生，**静态类**）通过 Python 可调用的类方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Engine/NIagaraFunctionLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UNiagaraFunctionLibrary` 在 Python 中以类方法形式暴露在 `unreal.NiagaraFunctionLibrary` 上：

```python
import unreal

# 示例：在指定位置发射粒子系统
unreal.NiagaraFunctionLibrary.spawn_system_at_location(
    world_context, unreal.load_asset("/Game/Niagara/Sys_Explosion"),
    unreal.Vector(0.0, 0.0, 100.0), unreal.Rotator(0.0, 0.0, 0.0)
)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.NiagaraFunctionLibrary)` 核对）。
- 大部分方法需要有效的 `WorldContextObject`（如 `get_game_instance()` 或任意已归入世界的 Actor）。
- 带 `WITH_EDITOR` 限定的方法仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **系统创建与发射** | | | |
| 发射 | `spawn_system_at_location(world_context, system_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAtLocation(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_system_around_point(world_context, system_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAroundPoint(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_emitter_at_location(world_context, emitter_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAtLocation(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_emitter_around_point(world_context, emitter_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAroundPoint(...)` | `NiagaraComponent` 或 `None` |
| **查询与控制** | | | |
| 查询 | `get_system_bounds(world_context, system)` | `FBoxSphereBounds GetSystemBounds(...)` | `BoxSphereBounds` |
| 查询 | `get_system_age(world_context, system)` | `float GetSystemAge(...)` | `float` |
| 查询 | `get_emitter_count(world_context, system)` | `int GetEmitterCount(...)` | `int` |
| 查询 | `get_emitter_name(world_context, system, emitter_index)` | `FString GetEmitterName(...)` | `str` |
| 控制 | `set_paused(world_context, system, b_paused)` | `void SetPaused(...)` | `None` |
| 控制 | `is_paused(world_context, system)` | `bool IsPaused(...)` | `bool` |
| 控制 | `set_speed(world_context, system, speed)` | `void SetSpeed(...)` | `None` |
| 控制 | `get_speed(world_context, system)` | `float GetSpeed(...)` | `float` |
| **数据接口** | | | |
| 数据 | `set_vector_param(world_context, system, param_name, value)` | `bool SetVectorParameter(...)` | `bool` |
| 数据 | `set_vector4_param(world_context, system, param_name, value)` | `bool SetVector4Parameter(...)` | `bool` |
| 数据 | `set_color_param(world_context, system, param_name, value)` | `bool SetColorParameter(...)` | `bool` |
| 数据 | `set_scalar_param(world_context, system, param_name, value)` | `bool SetScalarParameter(...)` | `bool` |
| 数据 | `set_bool_param(world_context, system, param_name, value)` | `bool SetBoolParameter(...)` | `bool` |
| 数据 | `set_transform_param(world_context, system, param_name, value, b_only_affect_parent)` | `bool SetTransformParameter(...)` | `bool` |
| 数据 | `set_asset_param(world_context, system, param_name, value)` | `bool SetAssetParameter(...)` | `bool` |
| **其他** | | | |
| 辅助 | `get_scatter_samples(world_context, system, sample_count, out_samples)` | `bool GetScatterSamples(...)` | `(bool, Array[Transform])` |
| 辅助 | `get_emitter_sample_count(world_context, system, emitter_index)` | `int GetEmitterSampleCount(...)` | `int` |

## 快速示例

```python
import unreal

def control_niagara():
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    api = unreal.NiagaraFunctionLibrary
    
    # 在指定位置发射粒子系统
    system_template = unreal.load_asset("/Game/Niagara/Sys_Explosion")
    system = api.spawn_system_at_location(
        world_context, system_template,
        unreal.Vector(100.0, 0.0, 50.0),
        unreal.Rotator(0.0, 0.0, 0.0),
        unreal.Vector(1.0, 1.0, 1.0),
        True
    )
    
    # 设置系统参数
    api.set_vector_param(world_context, system, "SpawnPosition", unreal.Vector(0.0, 0.0, 0.0))
    api.set_scalar_param(world_context, system, "EmissionRate", 100.0)
    
    # 暂停/恢复
    api.set_paused(world_context, system, True)
    unreal.delay(2.0)
    api.set_paused(world_context, system, False)
    
    # 查询系统年龄
    age = api.get_system_age(world_context, system)
    print("system age:", age)

if __name__ == "__main__":
    control_niagara()
```

## 注意事项

- 大部分 Niagara 控制方法需要有效的 `WorldContextObject` 与 Niagara 系统组件引用；非运行时调用返回 `BLOCKED_TOOLING`。
- `SpawnSystemAtLocation` 系列方法创建的组件默认自动销毁；设置 `b_auto_destroy=False` 可手动管理生命周期。
- `Set*Parameter` 系列方法修改的是运行时参数；生效时间取决于 Niagara 系统更新周期（通常是下一帧）。
- 粒子系统路径无效、模板未加载、参数名不存在等返回 `BLOCKED_INPUT`；无世界上下文或 Niagara 系统未激活返回 `BLOCKED_TOOLING`。
- `WITH_EDITOR` 限定的方法仅编辑器 Python 可用；非编辑器环境调用会失败。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
