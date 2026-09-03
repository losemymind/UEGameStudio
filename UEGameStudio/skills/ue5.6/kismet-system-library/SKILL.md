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

## 快速示例

```python
import unreal

def main():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    print(api.get_engine_version())
    api.print_string(world_context, "tick task", b_print_to_screen=False)

    start = unreal.Vector(0.0, 0.0, 100.0)
    end = unreal.Vector(0.0, 0.0, -1000.0)
    hit_any, hit = api.line_trace_single(
        world_context, start, end, unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
        False, [], unreal.DrawDebugTrace.FOR_ONE_FRAME, True,
    )
    print({"status": "OK", "hit": hit_any, "actor": hit.get_actor().get_actor_label() if hit_any else None})

    api.draw_debug_line(world_context, start, end, unreal.LinearColor(1.0, 0.0, 0.0, 1.0))

if __name__ == "__main__":
    main()
```

## 注意事项

- 大多数纯查询方法可在编辑器与运行时使用；运行时会话相关（时间、定时器、延迟、Trace 命中世界等）只在 PIE / 运行时语义下有效。
- 以 `conv_` 开头的方法为类型转换节点对应；`equal_equal_` / `not_equal_` 为比较运算对应。
- `DrawDebug*`、`PrintString` 等开发类方法使用后按审计要求保存/清理，不留下持久调试资产。
- 缺世界上下文、类路径、对象引用等必要输入时返回 `BLOCKED_INPUT`；编辑器/运行时上下文不可用或所需引擎系统缺失时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。