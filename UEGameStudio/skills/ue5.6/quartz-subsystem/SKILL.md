---
name: quartz-subsystem
description: UQuartzSubsystem（UE 5.6）Quartz 世界子系统 - 时钟创建/查询/删除与音频延迟统计；在 Agent 需要通过 unreal Python 调用 Quartz 时钟调度接口时使用，音频职责归 game-audio-technical-specialist
tags: [ue5.6, audio, quartz, clock, python, subsystem]
---

# QuartzSubsystem - Quartz 时钟调度（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UQuartzSubsystem` 暴露给 Python 的 Quartz 时钟操作与延迟统计方法。方法名与签名依据 `Engine/Source/Runtime/AudioMixer/Public/Quartz/QuartzSubsystem.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的成员整理；无 `ScriptMethod` 元数据时按 C++ 函数名转 snake_case，精确 Python 暴露名需实测确认。

## 入口说明

`UQuartzSubsystem` 以 `UTickableWorldSubsystem`（`UWorldSubsystem` 派生）为基类，从目标世界获取：

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
api = world.get_subsystem(unreal.QuartzSubsystem)
```

- 返回 `None` 表示当前世界未挂载该子系统或音频上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- Python 类名去掉 U 前缀：`unreal.QuartzSubsystem`。
- 带 `WorldContextObject` 参数的方法在 Python 侧传入调用所使用的 `UWorld`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 开关检测 | `is_quartz_enabled()` | `bool IsQuartzEnabled()` | `bool` |
| 时钟创建 | `create_new_clock(world_context_object, clock_name, in_settings, b_override_settings_if_clock_exists=False, b_use_audio_engine_clock_manager=True)` | `UQuartzClockHandle* CreateNewClock(const UObject*, FName, FQuartzClockSettings, bool, bool)` | `QuartzClockHandle` 或 `None` |
| 时钟删除 | `delete_clock_by_name(world_context_object, clock_name)` | `void DeleteClockByName(const UObject*, FName)` | `None` |
| 时钟删除 | `delete_clock_by_handle(world_context_object, in_clock_handle)` | `void DeleteClockByHandle(const UObject*, UQuartzClockHandle*&)` | `None` |
| 时钟查询 | `get_handle_for_clock(world_context_object, clock_name)` | `UQuartzClockHandle* GetHandleForClock(const UObject*, FName)` | `QuartzClockHandle` 或 `None` |
| 时钟查询 | `does_clock_exist(world_context_object, clock_name)` | `bool DoesClockExist(const UObject*, FName)` | `bool` |
| 时钟查询 | `is_clock_running(world_context_object, clock_name)` | `bool IsClockRunning(const UObject*, FName)` | `bool` |
| 时钟查询 | `get_current_clock_timestamp(world_context_object, in_clock_name)` | `FQuartzTransportTimeStamp GetCurrentClockTimestamp(const UObject*, const FName&)` | `QuartzTransportTimeStamp` |
| 时钟查询 | `get_estimated_clock_run_time(world_context_object, in_clock_name)` | `float GetEstimatedClockRunTime(const UObject*, const FName&)` | `float` |
| 时钟查询 | `get_duration_of_quantization_type_in_seconds(world_context_object, clock_name, quantization_type, multiplier=1.0)` | `float GetDurationOfQuantizationTypeInSeconds(const UObject*, FName, const EQuartzCommandQuantization&, float)` | `float` |
| 延迟指标 | `get_game_thread_to_audio_render_thread_average_latency(world_context_object)` | `float GetGameThreadToAudioRenderThreadAverageLatency(const UObject*)` | `float` |
| 延迟指标 | `get_game_thread_to_audio_render_thread_min_latency(world_context_object)` | `float GetGameThreadToAudioRenderThreadMinLatency(const UObject*)` | `float` |
| 延迟指标 | `get_game_thread_to_audio_render_thread_max_latency(world_context_object)` | `float GetGameThreadToAudioRenderThreadMaxLatency(const UObject*)` | `float` |
| 延迟指标 | `get_audio_render_thread_to_game_thread_average_latency()` | `float GetAudioRenderThreadToGameThreadAverageLatency()` | `float` |
| 延迟指标 | `get_audio_render_thread_to_game_thread_min_latency()` | `float GetAudioRenderThreadToGameThreadMinLatency()` | `float` |
| 延迟指标 | `get_audio_render_thread_to_game_thread_max_latency()` | `float GetAudioRenderThreadToGameThreadMaxLatency()` | `float` |
| 延迟指标 | `get_round_trip_average_latency(world_context_object)` | `float GetRoundTripAverageLatency(const UObject*)` | `float` |
| 延迟指标 | `get_round_trip_min_latency(world_context_object)` | `float GetRoundTripMinLatency(const UObject*)` | `float` |
| 延迟指标 | `get_round_trip_max_latency(world_context_object)` | `float GetRoundTripMaxLatency(const UObject*)` | `float` |
| 配置 | `set_quartz_subsystem_tickable_when_paused(b_in_tickable_when_paused)` | `void SetQuartzSubsystemTickableWhenPaused(const bool)` | `None` |

## 快速示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
api = world.get_subsystem(unreal.QuartzSubsystem)

settings = unreal.QuartzClockSettings()
handle = api.create_new_clock(world, "Midi_Clock", settings)
if handle is not None:
    running = api.is_clock_running(world, "Midi_Clock")
    print("clock running:", running)
```

## 注意事项

- Quartz 时钟大量为 BP 调用 + 回调委托：本 skill 只提供 `UQuartzSubsystem` 的 Python 调用 API；实际调度（起停、量化、BPM 变更）大多在 `UQuartzClockHandle` 上，精确 Python 暴露名需实测确认。
- 音频职责归 `game-audio-technical-specialist`；本 skill 不替代其专业判断，也不做音频内容写入。
- 缺 `UWorld`、时钟名、时钟设置等必要输入时返回 `BLOCKED_INPUT`；子系统或音频上下文不可用时返回 `BLOCKED_TOOLING`。
- PIE/运行时环境视为 `BLOCKED_TOOLING`；未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。