---
name: kismet-system-library
description: UKismetSystemLibrary（UE 5.6）系统级静态工具库 - 通用对象/类/路径工具、时间与定时器、日志打印、控制台、碰撞与射线检测、调试绘制、平台与服务、属性访问、事务、资产管理；在 Agent 需要通过 unreal Python 使用 UE 系统级通用函数库时使用
tags: [ue5.6, kismet, system, trace, collision, python]
---

# KismetSystemLibrary - 系统通用工具库（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetSystemLibrary` 暴露给 Python 的静态工具方法。签名与成员依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetSystemLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无则按 C++ 函数名转 snake_case。

## 入口说明

本库全部为静态方法，以类方法形式调用，不需要实例：

```python
import unreal
api = unreal.KismetSystemLibrary
```

- 需要世界上下文的方法传入任意已归入世界的对象（如 `unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()`）。
- Static 函数返回约定：仅一个 Out/ByRef 参数时直接返回该值；返回值与 Out 并存时按元组返回（返回值为首位）；无 Out 且无返回值时返回 `None`。
- 精确 Python 暴露名需在目标 5.6 编辑器 `dir()`/`help()` 实测确认。

## 可用操作（主要分组）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 对象 | `is_valid(object_to_test)` | `bool IsValid(const UObject*)` | `bool` |
| 对象 | `get_object_name(object)` | `FString GetObjectName(const UObject*)` | `str` |
| 对象 | `get_display_name(object)` | `FString GetDisplayName(const UObject*)` | `str` |
| 路径 | `get_path_name(object)` | `FString GetPathName(const UObject*)` | `str` |
| 路径 | `get_system_path(object)` | `FString GetSystemPath(const UObject*)` | `str` |
| 时间 | `get_game_time_in_seconds(world_context_object)` | `double GetGameTimeInSeconds(...)` | `float` |
| 时间 | `get_frame_count()` | `int64 GetFrameCount()` | `int` |
| 延迟 | `delay(world_context_object, duration)` | `void Delay(...)` | `None` |
| 定时器 | `set_timer(object, function_name, time, b_looping, ...)` | `FTimerHandle K2_SetTimer(...)` | `TimerHandle` |
| 定时器 | `clear_timer(object, function_name)` | `void K2_ClearTimer(...)` | `None` |
| 日志 | `print_string(world_context_object, in_string, ...)` | `void PrintString(...)` | `None` |
| 日志 | `log_string(in_string, b_print_to_log=True)` | `void LogString(...)` | `None` |
| 转换 | `conv_object_to_class(object, class)` | `UClass* Conv_ObjectToClass(...)` | `Class` |
| 加载 | `load_asset_blocking(asset)` | `UObject* LoadAsset_Blocking(TSoftObjectPtr<UObject>)` | `Object` 或 `None` |
| 加载 | `make_soft_object_path(path_string)` | `FSoftObjectPath MakeSoftObjectPath(...)` | `SoftObjectPath` |
| 碰撞 | `line_trace_single(world_context_object, start, end, trace_channel, ...)` | `bool LineTraceSingle(..., FHitResult& OutHit)` | `(bool, HitResult)` |
| 碰撞 | `sphere_overlap_actors(world_context_object, sphere_pos, sphere_radius, object_types, ...)` | `bool SphereOverlapActors(..., TArray<AActor*>& OutActors)` | `(bool, Array[Actor])` |
| 调试 | `draw_debug_line(world_context_object, line_start, line_end, line_color, ...)` | `void DrawDebugLine(...)` | `None` |
| 调试 | `draw_debug_sphere(world_context_object, center, radius, ...)` | `void DrawDebugSphere(...)` | `None` |
| 边界 | `get_component_bounds(component)` | `void GetComponentBounds(..., FVector&, FVector&, float&)` | `(Vector, Vector, float)` |
| 平台 | `launch_url(url)` | `void LaunchURL(const FString&)` | `None` |
| 平台 | `get_device_id()` | `FString GetDeviceId()` | `str` |
| 平台 | `is_standalone(world_context_object)` | `bool IsStandalone(...)` | `bool` |
| 事务 | `begin_transaction(context, description, primary_object)` | `int32 BeginTransaction(...)` | `int` |
| 资源 | `get_object_from_primary_asset_id(primary_asset_id)` | `UObject* GetObjectFromPrimaryAssetId(...)` | `Object` 或 `None` |
| 资源 | `get_primary_asset_id_from_object(object)` | `FPrimaryAssetId GetPrimaryAssetIdFromObject(...)` | `PrimaryAssetId` |
| 比较 | `equal_equal_class_class(a, b)` | `bool operator==(const UClass*, const UClass*)` | `bool` |
| 比较 | `not_equal_class_class(a, b)` | `bool operator!=(const UClass*, const UClass*)` | `bool` |
| 比较 | `equal_equal_object_object(a, b)` | `bool operator==(const UObject*, const UObject*)` | `bool` |
| 比较 | `not_equal_object_object(a, b)` | `bool operator!=(const UObject*, const UObject*)` | `bool` |
| 比较 | `equal_equal_vector_vector(a, b)` | `bool operator==(const FVector&, const FVector&)` | `bool` |
| 比较 | `not_equal_vector_vector(a, b)` | `bool operator!=(const FVector&, const FVector&)` | `bool` |
| 比较 | `equal_equal_box_box(a, b)` | `bool operator==(const FBox&, const FBox&)` | `bool` |
| 比较 | `not_equal_box_box(a, b)` | `bool operator!=(const FBox&, const FBox&)` | `bool` |
| 比较 | `equal_equal_rotator_rotator(a, b)` | `bool operator==(const FRotator&, const FRotator&)` | `bool` |
| 比较 | `not_equal_rotator_rotator(a, b)` | `bool operator!=(const FRotator&, const FRotator&)` | `bool` |
| 比较 | `equal_equal_plane_plane(a, b)` | `bool operator==(const FPlane&, const FPlane&)` | `bool` |
| 比较 | `not_equal_plane_plane(a, b)` | `bool operator!=(const FPlane&, const FPlane&)` | `bool` |
| 比较 | `equal_equal_quat_quat(a, b)` | `bool operator==(const FQuat&, const FQuat&)` | `bool` |
| 比较 | `not_equal_quat_quat(a, b)` | `bool operator!=(const FQuat&, const FQuat&)` | `bool` |
| 比较 | `equal_equal_transform_transform(a, b)` | `bool operator==(const FTransform&, const FTransform&)` | `bool` |
| 比较 | `not_equal_transform_transform(a, b)` | `bool operator!=(const FTransform&, const FTransform&)` | `bool` |
| Trace | `sphere_trace_single(world_context_object, start, end, sphere_radi...` | `bool SphereTraceSingle(..., FHitResult& OutHit)` | `(bool, HitResult)` |
| Trace | `capsule_trace_single(world_context_object, start, end, capsule_radi...` | `bool CapsuleTraceSingle(..., FHitResult& OutHit)` | `(bool, HitResult)` |
| Trace | `box_trace_single(world_context_object, start, end, box_extent, ...)` | `bool BoxTraceSingle(..., FHitResult& OutHit)` | `(bool, HitResult)` |
| 调试 | `draw_debug_box(world_context_object, box_center, box_extent, ...)` | `void DrawDebugBox(...)` | `None` |
| 调试 | `draw_debug_cylinder(world_context_object, start, end, radius, ...)` | `void DrawDebugCylinder(...)` | `None` |
| 其他 | `get_actor_bounds(actor)` | `void GetActorBounds(..., FVector&, FVector&)` | `(Vector, Vector)` |
| 其他 | `get_engine_version()` | `FString GetEngineVersion()` | `str` |

## 快速示例

```python
import unreal

def main():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    # 版本与比较
    print(api.get_engine_version())
    v1 = unreal.Vector(1.0, 0.0, 0.0)
    v2 = unreal.Vector(1.0, 0.0, 0.0)
    print(api.equal_equal_vector_vector(v1, v2))

    # Trace检测
    start = unreal.Vector(0.0, 0.0, 100.0)
    end = unreal.Vector(0.0, 0.0, -1000.0)
    hit_any, hit = api.line_trace_single(
        world_context, start, end, unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
        False, [], unreal.DrawDebugTrace.FOR_ONE_FRAME, True,
    )
    print({"status": "OK", "hit": hit_any, "actor": hit.get_actor().get_actor_label() if hit_any else None})

    sphere_hit_any, sphere_hit = api.sphere_trace_single(
        world_context, start, end, 10.0,
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.FOR_ONE_FRAME, True,
    )
    print({"sphere": sphere_hit_any})

    capsule_hit_any, capsule_hit = api.capsule_trace_single(
        world_context, start, end, 10.0, 20.0,
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.FOR_ONE_FRAME, True,
    )
    print({"capsule": capsule_hit_any})

    box_hit_any, box_hit = api.box_trace_single(
        world_context, start, end, unreal.Vector(10.0, 10.0, 20.0),
        unreal.Rotator(0.0, 0.0, 0.0), unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
        False, [], unreal.DrawDebugTrace.FOR_ONE_FRAME, True,
    )
    print({"box": box_hit_any})

    # 调试绘制
    api.draw_debug_box(world_context, unreal.Vector(0.0, 0.0, 50.0), unreal.Vector(10.0, 10.0, 10.0), unreal.LinearColor(1.0, 0.0, 0.0, 1.0))
    api.draw_debug_cylinder(world_context, unreal.Vector(0.0, 0.0, 0.0), unreal.Vector(0.0, 0.0, 100.0), 10.0, unreal.LinearColor(0.0, 1.0, 0.0, 1.0))

    # 边界获取
    actor = unreal.get_engine_subsystem(unreal.UnrealEditorSubsystem).get_game_instance().get_world().get_actors()[0]
    origin, box_ext = api.get_actor_bounds(actor)
    print({"origin": origin, "extent": box_ext})

if __name__ == "__main__":
    main()
```

## 综合实战示例

### 网络状态判定与环境检测

```python
import unreal

def network_detection_example():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    is_standalone = api.is_standalone(world_context)
    device_id = api.get_device_id()
    engine_version = api.get_engine_version()
    
    print(f"Standalone: {is_standalone}, Device: {device_id}, Engine: {engine_version}")
    
    return {
        "standalone": is_standalone,
        "device_id": device_id,
        "engine_version": engine_version
    }

def environment_sensor_check():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 项目设置查询
    project_settings = unreal.get_default_obj(unreal.ProjectSettings)
    project_name = project_settings.get_project_name()
    project_version = project_settings.get_project_version()
    
    print(f"Project: {project_name}, Version: {project_version}")
    
    return {
        "project_name": project_name,
        "project_version": project_version
    }
```

### 属性访问与反射

```python
import unreal

def actor_property_accessor(actor):
    api = unreal.KismetSystemLibrary
    
    # 对象属性Name
    name = api.get_object_name(actor)
    display_name = api.get_display_name(actor)
    path = api.get_path_name(actor)
    sys_path = api.get_system_path(actor)
    
    return {
        "name": name,
        "display_name": display_name,
        "path": path,
        "system_path": sys_path
    }

def dynamic_object_creation(class_path, outer=None):
    api = unreal.KismetSystemLibrary
    
    # 通过路径创建类实例
    new_class = unreal.load_class(None, class_path)
    if new_class is None:
        return None
    
    # 动态创建对象
    new_object = unreal.create_package(None, "/Game/NewObject")
    instance = unreal.spawn_object(new_class, new_object)
    
    return instance
```

### 定时器系统管理

```python
import unreal

class TimerManagerController:
    def __init__(self):
        self.timer_handles = {}
    
    def create_repeating_timer(self, actor, function_name, interval):
        api = unreal.KismetSystemLibrary
        handle = api.set_timer(
            actor,
            function_name,
            interval,
            True
        )
        self.timer_handles[function_name] = handle
        return handle
    
    def create_one_shot_timer(self, actor, function_name, delay):
        api = unreal.KismetSystemLibrary
        handle = api.set_timer(
            actor,
            function_name,
            delay,
            False
        )
        self.timer_handles[function_name] = handle
        return handle
    
    def clear_all_timers(self, actor):
        api = unreal.KismetSystemLibrary
        for func_name, handle in self.timer_handles.items():
            api.clear_timer(actor, func_name)
        self.timer_handles.clear()

def scheduled_task_system():
    controller = TimerManagerController()
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 创建定期任务
    controller.create_repeating_timer(world_context, "OnTick", 0.1)
    
    # 创建延迟任务
    controller.create_one_shot_timer(world_context, "OnDelayComplete", 5.0)
    
    return controller
```

### 碰撞与射线检测增强

```python
import unreal

def advanced_line_trace_system():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 多通道检测
    channels = [
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY2,
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY3
    ]
    
    results = {}
    for channel in channels:
        start = unreal.Vector(0.0, 0.0, 100.0)
        end = unreal.Vector(0.0, 0.0, -1000.0)
        
        hit_any, hit = api.line_trace_single(
            world_context, start, end, channel,
            False, [], unreal.DrawDebugTrace.NONE, True
        )
        
        results[channel.name] = {
            "hit": hit_any,
            "actor": hit.get_actor().get_actor_label() if hit_any else None,
            "point": hit.get_location() if hit_any else None
        }
    
    return results

def proximity_detector(origin, radius, object_types):
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    overlap_any, actors = api.sphere_overlap_actors(
        world_context,
        origin,
        radius,
        object_types,
        None,
        None,
        unreal.DrawDebugTrace.NONE,
        True,
        unreal.LinearColor(1.0, 0.0, 0.0, 1.0)
    )
    
    return {
        "overlap": overlap_any,
        "actor_count": len(actors) if actors else 0,
        "actors": [a.get_actor_label() for a in actors] if actors else []
    }
```

## 高级用法

### 事务系统与批量操作

```python
import unreal

def batch_transaction_controller():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEditorSubsystem).get_game_instance()
    
    # 开始事务
    transaction_id = api.begin_transaction(
        world_context,
        "Batch Actor Move",
        None
    )
    
    try:
        # 执行批量操作
        actors = unreal.EditorLevelLibrary.get_all_dirty_actors()
        for actor in actors:
            location = actor.get_actor_location()
            new_location = unreal.Vector(
                location.get_x() + 10.0,
                location.get_y(),
                location.get_z()
            )
            actor.set_actor_location(new_location, False, True)
        
        # 提交事务
        api.end_transaction()
        
    except Exception as e:
        # 回滚事务
        api.abort_transaction(transaction_id)
        raise e
```

### 资源与PrimaryAsset管理

```python
import unreal

def primary_asset_loader(asset_id_string):
    api = unreal.KismetSystemLibrary
    
    # 创建PrimaryAssetId
    asset_id = unreal.create_primary_asset_id_from_string(asset_id_string)
    
    # 加载资源
    asset = api.get_object_from_primary_asset_id(asset_id)
    
    # 获取PrimaryAssetId
    returned_id = api.get_primary_asset_id_from_object(asset) if asset else None
    
    return {
        "asset": asset,
        "asset_id": returned_id.get_primary_asset_name() if returned_id else None
    }

def asset_loading_validator():
    api = unreal.KismetSystemLibrary
    
    # 同步加载
    asset_path = "/Game/Characters/BP_Character.BP_Character_C"
    asset_class = unreal.load_class(None, asset_path)
    
    if asset_class:
        soft_path = api.make_soft_object_path(asset_path)
        print(f"Loaded class: {asset_class.get_name()}, SoftPath: {soft_path.to_string()}")
    
    return asset_class is not None
```

### 编辑器集成与调试

```python
import unreal

def editor_debug_draw_system():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    # 绘制调试信息
    for i in range(10):
        start = unreal.Vector(float(i * 100), 0.0, 0.0)
        end = unreal.Vector(float(i * 100), 1000.0, 0.0)
        
        color = unreal.LinearColor(
            i / 10.0,
            1.0 - (i / 10.0),
            0.5,
            1.0
        )
        
        api.draw_debug_line(
            world_context,
            start,
            end,
            color,
            5.0,
            0.0,
            1.0
        )
```

## 常见问题与最佳实践

### 平台差异处理

1. **平台特定路径**：
   - Windows: `/Game/Assets/Windows/`
   - macOS: `/Game/Assets/macOS/`
   - Linux: `/Game/Assets/Linux/`
   
   ```python
   import unreal
   
   platform_name = unreal.PlatformInfo.get_platform_name()
   asset_path = f"/Game/Assets/{platform_name}/BP_Character"
   ```

2. **设备能力检测**：
   ```python
   import unreal
   
   def get_device_capabilities():
       api = unreal.KismetSystemLibrary
       world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
       
       is_standalone = api.is_standalone(world_context)
       device_id = api.get_device_id()
       
       # 深度查询需要 PlatformInfo 模块
       platform_info = unreal.PlatformInfo
       render_caps = platform_info.get_render_device_capabilities()
       
       return {
           "standalone": is_standalone,
           "device_id": device_id,
           "render_caps": render_caps
       }
   ```

### 线程安全注意事项

1. **主线程限制**：
   - 绝大多数 `KismetSystemLibrary` 方法必须在游戏线程调用
   - 编辑器脚本模式（Python 控制台）通常在主线程执行
   - 异步任务中调用需通过 `AsyncTask` 调度

2. **避免跨线程对象引用**：
   ```python
   import unreal
   
   def safe_async_actor_query():
       actor_ref = None
       
       def capture_actor():
           nonlocal actor_ref
           actors = unreal.EditorLevelLibrary.get_all_dirty_actors()
           actor_ref = actors[0] if actors else None
       
       unreal.AsyncTask(capture_actor).then(lambda _: print("Actor captured"))
   ```

### Trace 性能优化

1. **碰撞通道管理**：
   - 使用精确的 `TraceTypeQuery` 避免全场景检测
   - 忽略不需要检测的 Actor：`ignore_actors` 参数
   
2. **调试绘制分离**：
   ```python
   def optimized_trace_without_debug():
       api = unreal.KismetSystemLibrary
       world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
       
       hit_any, hit = api.line_trace_single(
           world_context,
           start,
           end,
           unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
           False,  # bTraceComplex
           [],     # ignore_actors
           unreal.DrawDebugTrace.NONE,  # 关闭调试绘制
           True    # draw_debug
       )
       
       return hit_any, hit
   ```

### 内存管理技巧

1. **临时对象清理**：
   - `Spawn*` 函数创建的对象自动管理生命周期
   - 手动创建的对象需及时清理或设置 `Outer`
   
2. **批量操作分帧**：
   ```python
   def batch_operation_frame_split(actors, operation_fn):
       def process_batch(batch, remaining):
           for actor in batch:
               operation_fn(actor)
           
           if remaining:
               next_batch = remaining[:10]
               next_remaining = remaining[10:]
               unreal.delay(0.0, lambda: process_batch(next_batch, next_remaining))
       
       process_batch(actors[:10], actors[10:])
   ```

## 注意事项

- 大多数纯查询方法可在编辑器与运行时使用；运行时会话相关（时间、定时器、延迟、Trace 命中世界等）只在 PIE / 运行时语义下有效。
- 以 `conv_` 开头的方法为类型转换节点对应；`equal_equal_` / `not_equal_` 为比较运算对应。
- Trace 方法调用时传入 `draw_debug_type` 为 `FOR_ONE_FRAME` 或 `FOR_DURATION` 会在视口产生临时调试绘制，影响性能，生产代码中应关闭调试输出。
- `DrawDebug*` 系列方法需在 PIE / 运行时或 Editor 视口调试模式下可见；编辑器非调试模式下调用无效果，不产生持久资产。
- 缺世界上下文、类路径、对象引用、Trace 参数（起点/终点/半径/方向等）等必要输入时返回 `BLOCKED_INPUT`；编辑器/运行时上下文不可用或所需引擎系统缺失时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。