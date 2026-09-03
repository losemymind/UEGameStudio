# QuartzSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/AudioMixer/Public/Quartz/QuartzSubsystem.h` 整理 `UQuartzSubsystem` 中带 `UFUNCTION(BlueprintCallable)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case；每个成员给出 C++ 签名、Python 参数、返回约定与示例；精确 Python 暴露名需实测确认。

## 获取子系统

`UQuartzSubsystem` 以 `UTickableWorldSubsystem`（`UWorldSubsystem` 派生）为基类，从目标世界获取：

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    raise RuntimeError("BLOCKED_TOOLING: editor world unavailable")

quartz = world.get_subsystem(unreal.QuartzSubsystem)
if quartz is None:
    raise RuntimeError("BLOCKED_TOOLING: QuartzSubsystem unavailable")
```

- Python 类名去掉 U 前缀：`unreal.QuartzSubsystem`。
- 带 `WorldContextObject` 的方法在 Python 侧传入该世界：`world`。
- 音频职责归 `game-audio-technical-specialist`；本 skill 仅提供 `UQuartzSubsystem` 的 Python 调用 API。

## 通用约定

- 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；`UQuartzSubsystem` 头文件未声明 `ScriptMethod`，故按 C++ 函数名转 snake_case。
- `WorldContextObject`（`const UObject*`）参数在 Python 调用时传 `world`；无该参数的方法（音频线程→游戏线程三组延迟）不需要世界参数。
- Quartz 时钟大量是 BP 调用 + 回调委托形式；`UQuartzSubsystem` 的 BP 暴露成员不携带可 Python 绑定的回调委托，时钟级调度回调绑定到 `UQuartzClockHandle` 侧，Python 侧回调绑定需实测确认。

## 时钟创建与删除

### create_new_clock

- C++ 签名：`UQuartzClockHandle* CreateNewClock(const UObject* WorldContextObject, FName ClockName, FQuartzClockSettings InSettings, bool bOverrideSettingsIfClockExists = false, bool bUseAudioEngineClockManager = true)`
- Python：`create_new_clock(world_context_object, clock_name, in_settings, b_override_settings_if_clock_exists=False, b_use_audio_engine_clock_manager=True) -> QuartzClockHandle`
- 说明：创建新时钟；同名时钟已存在时按 `bOverrideSettingsIfClockExists` 决定是否覆盖设置。返回时钟句柄 `QuartzClockHandle`，失败返回 `None`。
- 示例：

```python
settings = unreal.QuartzClockSettings(
    time_signature=(4, 4),
    b_ignore_audio_clock_manager=False,
)
handle = quartz.create_new_clock(
    world, "MainClock", settings,
    b_override_settings_if_clock_exists=True,
)
if handle is None:
    print("BLOCKED_TOOLING: clock creation failed")
```

### delete_clock_by_name

- C++ 签名：`void DeleteClockByName(const UObject* WorldContextObject, FName ClockName)`
- Python：`delete_clock_by_name(world_context_object, clock_name) -> None`
- 说明：按名称删除已存在的时钟。
- 示例：

```python
quartz.delete_clock_by_name(world, "MainClock")
```

### delete_clock_by_handle

- C++ 签名：`void DeleteClockByHandle(const UObject* WorldContextObject, UPARAM(ref) UQuartzClockHandle*& InClockHandle)`
- Python：`delete_clock_by_handle(world_context_object, in_clock_handle) -> None`
- 说明：按句柄删除时钟，`in_clock_handle` 按引用传入。
- 示例：

```python
quartz.delete_clock_by_handle(world, handle)
```

## 时钟查询

### get_handle_for_clock

- C++ 签名：`UQuartzClockHandle* GetHandleForClock(const UObject* WorldContextObject, FName ClockName)`
- Python：`get_handle_for_clock(world_context_object, clock_name) -> QuartzClockHandle`
- 说明：获取已存在时钟的句柄，未找到返回 `None`。
- 示例：

```python
handle = quartz.get_handle_for_clock(world, "MainClock")
if handle is None:
    print("BLOCKED_INPUT: clock not found")
```

### does_clock_exist

- C++ 签名：`bool DoesClockExist(const UObject* WorldContextObject, FName ClockName)`
- Python：`does_clock_exist(world_context_object, clock_name) -> bool`
- 说明：时钟是否已创建。
- 示例：

```python
if not quartz.does_clock_exist(world, "MainClock"):
    quartz.create_new_clock(world, "MainClock", settings)
```

### is_clock_running

- C++ 签名：`bool IsClockRunning(const UObject* WorldContextObject, FName ClockName)`
- Python：`is_clock_running(world_context_object, clock_name) -> bool`
- 说明：指定时钟当前是否在运行。
- 示例：

```python
running = quartz.is_clock_running(world, "MainClock")
```

### get_current_clock_timestamp

- C++ 签名：`FQuartzTransportTimeStamp GetCurrentClockTimestamp(const UObject* WorldContextObject, const FName& InClockName)`
- Python：`get_current_clock_timestamp(world_context_object, in_clock_name) -> QuartzTransportTimeStamp`
- 说明：返回时钟传输时间戳（`QuartzTransportTimeStamp` 结构）。
- 示例：

```python
ts = quartz.get_current_clock_timestamp(world, "MainClock")
```

### get_estimated_clock_run_time

- C++ 签名：`float GetEstimatedClockRunTime(const UObject* WorldContextObject, const FName& InClockName)`
- Python：`get_estimated_clock_run_time(world_context_object, in_clock_name) -> float`
- 说明：返回时钟已运行的估算秒数；受延迟影响并非精确值。
- 示例：

```python
secs = quartz.get_estimated_clock_run_time(world, "MainClock")
```

### get_duration_of_quantization_type_in_seconds

- C++ 签名：`float GetDurationOfQuantizationTypeInSeconds(const UObject* WorldContextObject, FName ClockName, const EQuartzCommandQuantization& QuantizationType, float Multiplier = 1.0f)`
- Python：`get_duration_of_quantization_type_in_seconds(world_context_object, clock_name, quantization_type, multiplier=1.0) -> float`
- 说明：返回指定量化类型（`unreal.QuartzCommandQuantization` 枚举）的持续时间秒数，可选倍率。
- 示例：

```python
dur = quartz.get_duration_of_quantization_type_in_seconds(
    world, "MainClock", unreal.QuartzCommandQuantization.HALF_NOTE,
    multiplier=2.0,
)
```

## Quartz 开关与延迟指标

### is_quartz_enabled

- C++ 签名：`bool IsQuartzEnabled()`
- Python：`is_quartz_enabled() -> bool`
- 说明：Quartz 音频引擎能力是否可用。
- 示例：

```python
if not quartz.is_quartz_enabled():
    print("BLOCKED_TOOLING: quartz disabled")
```

### set_quartz_subsystem_tickable_when_paused

- C++ 签名：`void SetQuartzSubsystemTickableWhenPaused(const bool bInTickableWhenPaused)`
- Python：`set_quartz_subsystem_tickable_when_paused(b_in_tickable_when_paused) -> None`
- 说明：设置子系统在游戏暂停时是否继续 Ticking。
- 示例：

```python
quartz.set_quartz_subsystem_tickable_when_paused(True)
```

### 延迟指标（游戏线程 → 音频渲染线程）

- `get_game_thread_to_audio_render_thread_average_latency(world_context_object) -> float`（`GetGameThreadToAudioRenderThreadAverageLatency(const UObject*)`）
- `get_game_thread_to_audio_render_thread_min_latency(world_context_object) -> float`（`GetGameThreadToAudioRenderThreadMinLatency(const UObject*)`）
- `get_game_thread_to_audio_render_thread_max_latency(world_context_object) -> float`（`GetGameThreadToAudioRenderThreadMaxLatency(const UObject*)`）

```python
avg = quartz.get_game_thread_to_audio_render_thread_average_latency(world)
min_l = quartz.get_game_thread_to_audio_render_thread_min_latency(world)
max_l = quartz.get_game_thread_to_audio_render_thread_max_latency(world)
```

### 延迟指标（音频渲染线程 → 游戏线程）

- `get_audio_render_thread_to_game_thread_average_latency() -> float`
- `get_audio_render_thread_to_game_thread_min_latency() -> float`
- `get_audio_render_thread_to_game_thread_max_latency() -> float`

```python
avg = quartz.get_audio_render_thread_to_game_thread_average_latency()
```

### 延迟指标（往返）

- `get_round_trip_average_latency(world_context_object) -> float`（`GetRoundTripAverageLatency(const UObject*)`）
- `get_round_trip_min_latency(world_context_object) -> float`（`GetRoundTripMinLatency(const UObject*)`）
- `get_round_trip_max_latency(world_context_object) -> float`（`GetRoundTripMaxLatency(const UObject*)`）

```python
rt_avg = quartz.get_round_trip_average_latency(world)
```

## 完整示例：时钟验证与延迟采集

```python
import unreal

def main():
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world is None:
        print({"status": "BLOCKED_TOOLING", "reason": "editor world unavailable"})
        return

    quartz = world.get_subsystem(unreal.QuartzSubsystem)
    if quartz is None:
        print({"status": "BLOCKED_TOOLING", "reason": "QuartzSubsystem unavailable"})
        return

    if not quartz.is_quartz_enabled():
        print({"status": "BLOCKED_TOOLING", "reason": "quartz disabled"})
        return

    if not quartz.does_clock_exist(world, "MainClock"):
        quartz.create_new_clock(
            world,
            "MainClock",
            unreal.QuartzClockSettings(),
            b_override_settings_if_clock_exists=False,
        )

    handle = quartz.get_handle_for_clock(world, "MainClock")
    report = {
        "status": "OK",
        "clock_exists": quartz.does_clock_exist(world, "MainClock"),
        "clock_running": quartz.is_clock_running(world, "MainClock"),
        "has_handle": handle is not None,
        "run_time_secs": quartz.get_estimated_clock_run_time(world, "MainClock"),
        "round_trip_avg_latency": quartz.get_round_trip_average_latency(world),
    }
    print(report)

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入，如目标 `UWorld`、时钟名、`QuartzClockSettings`。
- `BLOCKED_TOOLING`：子系统、编辑器上下文或音频设备不可用；PIE/运行时环境视为不可执行。
- 音频职责边界：时钟调度与音频内容写入归 `game-audio-technical-specialist`，本 skill 只提供 Python 调用 API。
- 带回调/委托的时钟调度在 `UQuartzClockHandle` 侧，Python 侧回调绑定需实测确认；未实测不声称已验证。
- 本文件只记录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。