# UNiagaraFunctionLibrary API 参考（UE 5.6）

本页列出 `UNiagaraFunctionLibrary` 的完整 Python 方法映射表，按功能分组。

## 系统创建与发射（Spawn）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `spawn_system_at_location(world_context, system_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAtLocation(...)` | `NiagaraComponent` 或 `None` |
| `spawn_system_around_point(world_context, system_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAroundPoint(...)` | `NiagaraComponent` 或 `None` |
| `spawn_emitter_at_location(world_context, emitter_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAtLocation(...)` | `NiagaraComponent` 或 `None` |
| `spawn_emitter_around_point(world_context, emitter_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAroundPoint(...)` | `NiagaraComponent` 或 `None` |

## 查询与控制（Query & Control）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_system_bounds(world_context, system)` | `FBoxSphereBounds GetSystemBounds(...)` | `BoxSphereBounds` |
| `get_system_age(world_context, system)` | `float GetSystemAge(...)` | `float` |
| `get_emitter_count(world_context, system)` | `int GetEmitterCount(...)` | `int` |
| `get_emitter_name(world_context, system, emitter_index)` | `FString GetEmitterName(...)` | `str` |
| `set_paused(world_context, system, b_paused)` | `void SetPaused(...)` | `None` |
| `is_paused(world_context, system)` | `bool IsPaused(...)` | `bool` |
| `set_speed(world_context, system, speed)` | `void SetSpeed(...)` | `None` |
| `get_speed(world_context, system)` | `float GetSpeed(...)` | `float` |

## 数据接口（Data Interface）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `set_vector_param(world_context, system, param_name, value)` | `bool SetVectorParameter(...)` | `bool` |
| `set_vector4_param(world_context, system, param_name, value)` | `bool SetVector4Parameter(...)` | `bool` |
| `set_color_param(world_context, system, param_name, value)` | `bool SetColorParameter(...)` | `bool` |
| `set_scalar_param(world_context, system, param_name, value)` | `bool SetScalarParameter(...)` | `bool` |
| `set_bool_param(world_context, system, param_name, value)` | `bool SetBoolParameter(...)` | `bool` |
| `set_transform_param(world_context, system, param_name, value, b_only_affect_parent)` | `bool SetTransformParameter(...)` | `bool` |
| `set_asset_param(world_context, system, param_name, value)` | `bool SetAssetParameter(...)` | `bool` |

## 其他（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_scatter_samples(world_context, system, sample_count, out_samples)` | `bool GetScatterSamples(...)` | `(bool, Array[Transform])` |
| `get_emitter_sample_count(world_context, system, emitter_index)` | `int GetEmitterSampleCount(...)` | `int` |
