---
name: quartz-subsystem
description: UQuartzSubsystem（UE 5.6）Quartz 世界子系统 - 时钟创建/查询/删除与音频延迟统计；在 Agent 需要通过 unreal Python 调用 Quartz 时钟调度接口时使用，音频职责归 game-audio-technical-specialist
risk: safe
category: development
tags: [ue5.6, audio, quartz, clock, python, subsystem]
---

# QuartzSubsystem - Quartz 时钟调度（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 调用 Quartz 时钟调度接口时使用本 skill（description 触发场景）。
- 本 skill 只在与 quartz-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

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

## 示例

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

## 综合实战示例

### Quartz时钟调度管理系统

```python
import unreal

class QuartzClockManager:
    def __init__(self):
        self.api = None
        self.world = None
        self.clock_handles = {}
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.QuartzSubsystem)
        return self.api is not None
    
    def create_clock(self, clock_name, settings):
        if not self.api:
            return None
        
        handle = self.api.create_new_clock(self.world, clock_name, settings)
        if handle:
            self.clock_handles[clock_name] = handle
        return handle
    
    def start_clock(self, clock_name):
        if clock_name in self.clock_handles:
            # 通过 Clock Handle 启动（需实测确认具体 API）
            # handle = self.clock_handles[clock_name]
            return True
        return False
    
    def stop_clock(self, clock_name):
        if self.api and clock_name in self.clock_handles:
            self.api.delete_clock_by_handle(self.world, self.clock_handles[clock_name])
            del self.clock_handles[clock_name]
            return True
        return False
    
    def get_clock_timestamp(self, clock_name):
        if self.api and clock_name in self.clock_handles:
            return self.api.get_current_clock_timestamp(self.world, clock_name)
        return None

def manage_game_clocks():
    manager = QuartzClockManager()
    
    if not manager.initialize():
        print("Failed to initialize QuartzSubsystem")
        return
    
    # 创建时钟
    settings = unreal.QuartzClockSettings()
    settings.set_bpm(120.0)
    
    metronome_clock = manager.create_clock("Metronome", settings)
    music_clock = manager.create_clock("Music", settings)
    
    # 查询状态
    timestamp = manager.get_clock_timestamp("Metronome")
    print(f"Metronome timestamp: {timestamp}")
```

### 音频同步与节奏控制

```python
import unreal

def audio_synchronization_system():
    api = None
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world:
        api = world.get_subsystem(unreal.QuartzSubsystem)
    
    if not api:
        print("QuartzSubsystem not available")
        return
    
    if not api.is_quartz_enabled():
        print("Quartz not enabled in project")
        return
    
    # 创建量化时钟
    def create_quantized_clock(name, bpm, quantization_type):
        settings = unreal.QuartzClockSettings()
        settings.set_bpm(bpm)
        
        handle = api.create_new_clock(world, name, settings)
        if handle:
            # 设置量化类型（需要实测确认）
            # handle.set_quantization_type(quantization_type)
            return handle
        return None
    
    # 创建不同节奏时钟
    quarter_note_clock = create_quantized_clock("QuarterNotes", 60.0, "QuarterNote")
    eighth_note_clock = create_quantized_clock("EighthNotes", 120.0, "EighthNote")
    
    # 获取量化持续时间
    if quarter_note_clock:
        duration = api.get_duration_of_quantization_type_in_seconds(
            world,
            "QuarterNotes",
            "QuarterNote",
            1.0
        )
        print(f"Quarter note duration: {duration}s")
```

### 延迟统计与性能分析

```python
import unreal

class AudioLatencyAnalyzer:
    def __init__(self):
        self.api = None
        self.world = None
        self.latency_samples = []
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.QuartzSubsystem)
        return self.api is not None
    
    def sample_game_to_audio_latency(self):
        if not self.api:
            return None
        
        avg = self.api.get_game_thread_to_audio_render_thread_average_latency(self.world)
        min_latency = self.api.get_game_thread_to_audio_render_thread_min_latency(self.world)
        max_latency = self.api.get_game_thread_to_audio_render_thread_max_latency(self.world)
        
        return {
            "avg": avg,
            "min": min_latency,
            "max": max_latency
        }
    
    def sample_round_trip_latency(self):
        if not self.api:
            return None
        
        avg = self.api.get_round_trip_average_latency(self.world)
        min_latency = self.api.get_round_trip_min_latency(self.world)
        max_latency = self.api.get_round_trip_max_latency(self.world)
        
        return {
            "avg": avg,
            "min": min_latency,
            "max": max_latency
        }

def analyze_audio_performance():
    analyzer = AudioLatencyAnalyzer()
    
    if not analyzer.initialize():
        print("Failed to initialize")
        return
    
    # 采样延迟
    game_to_audio = analyzer.sample_game_to_audio_latency()
    round_trip = analyzer.sample_round_trip_latency()
    
    print(f"Game -> Audio: avg={game_to_audio['avg']:.2f}ms, min={game_to_audio['min']:.2f}ms, max={game_to_audio['max']:.2f}ms")
    print(f"Round Trip: avg={round_trip['avg']:.2f}ms, min={round_trip['min']:.2f}ms, max={round_trip['max']:.2f}ms")
```

## 高级用法

### 时钟同步与多系统协调

```python
import unreal

def synchronized_clock_system():
    api = None
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world:
        api = world.get_subsystem(unreal.QuartzSubsystem)
    
    if not api:
        print("QuartzSubsystem not available")
        return
    
    # 创建主时钟和副时钟
    master_settings = unreal.QuartzClockSettings()
    master_settings.set_bpm(120.0)
    master_handle = api.create_new_clock(world, "MasterClock", master_settings)
    
    slave_settings = unreal.QuartzClockSettings()
    slave_settings.set_bpm(120.0)
    slave_handle = api.create_new_clock(world, "SlaveClock", slave_settings)
    
    # 启动从时钟（需要实测确认具体 API）
    # api.start_clock_by_handle(world, slave_handle)
    
    # 查询从时钟时间
    if slave_handle:
        timestamp = api.get_current_clock_timestamp(world, "SlaveClock")
        print(f"Slave clock timestamp: {timestamp}")
```

### 复合节奏模式

```python
import unreal

def compound_rhythm_manager():
    api = None
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world:
        api = world.get_subsystem(unreal.QuartzSubsystem)
    
    if not api:
        print("QuartzSubsystem not available")
        return
    
    # 创建复合节奏：4/4拍 + 三连音
    def create_polyrhythm_clocks():
        primary_clock = api.create_new_clock(
            world,
            "Primary",
            unreal.QuartzClockSettings()
        )
        
        polyrhythm_clock = api.create_new_clock(
            world,
            "Polyrhythm",
            unreal.QuartzClockSettings()
        )
        
        # 设置不同的 BPM
        # 主节奏：120 BPM，每拍4次
        # 多节奏：160 BPM，每拍3次
        
        return primary_clock, polyrhythm_clock
    
    primary, polyrhythm = create_polyrhythm_clocks()
```

### 自定义时钟事件调度

```python
import unreal

class QuartzEventScheduler:
    def __init__(self):
        self.api = None
        self.world = None
        self.events = []
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.QuartzSubsystem)
        return self.api is not None
    
    def schedule_event(self, clock_name, beat_offset, callback):
        self.events.append({
            "clock": clock_name,
            "beat": beat_offset,
            "callback": callback
        })
    
    def process_scheduled_events(self):
        if not self.api:
            return
        
        for event in self.events:
            timestamp = self.api.get_current_clock_timestamp(self.world, event["clock"])
            # 检查是否到达调度时间（需要实测确认时间格式）
            # if timestamp.beat == event["beat"]:
            #     event["callback"]()

def scheduled_beat_events():
    scheduler = QuartzEventScheduler()
    
    if not scheduler.initialize():
        print("Failed to initialize")
        return
    
    # 调度事件
    def on_beat_1():
        print("Beat 1 triggered")
    
    def on_beat_2():
        print("Beat 2 triggered")
    
    scheduler.schedule_event("Metronome", 1.0, on_beat_1)
    scheduler.schedule_event("Metronome", 2.0, on_beat_2)
```

## 常见问题与最佳实践

### 音频同步技巧

1. **时钟参数配置**：
   - 使用 `set_bpm()` 设置速度
   - 配置 `Quantization` 以获得所需节奏精度
   
2. **时钟同步策略**：
   ```python
   def sync_clocks_to_master(master_name, slave_names):
       master_timestamp = api.get_current_clock_timestamp(world, master_name)
       
       for slave_name in slave_names:
           slave_timestamp = api.get_current_clock_timestamp(world, slave_name)
           # 调整从时钟相位
           # 实现同步逻辑
   ```

3. **延迟补偿**：
   - 使用 `get_game_thread_to_audio_render_thread_average_latency()` 获取延迟
   - 在调度事件时提前补偿延迟

### 性能优化

1. **时钟创建优化**：
   - 避免频繁创建/销毁时钟
   - 复用时钟句柄和设置
   
2. **查询频率控制**：
   - 批量查询时钟状态
   - 避免每帧查询所有时钟

### 常见陷阱

1. **时钟未启动**：
   - 创建时钟后需要显式启动
   - 检查 `is_clock_running()` 确认
   
2. **量化类型错误**：
   - 确保 `Quantization` 参数匹配预期节奏
   - 不同量化类型影响时间计算

## 限制和注意事项

- Quartz 时钟大量为 BP 调用 + 回调委托：本 skill 只提供 `UQuartzSubsystem` 的 Python 调用 API；实际调度（起停、量化、BPM 变更）大多在 `UQuartzClockHandle` 上，精确 Python 暴露名需实测确认。
- 音频职责归 `game-audio-technical-specialist`；本 skill 不替代其专业判断，也不做音频内容写入。
- 缺 `UWorld`、时钟名、时钟设置等必要输入时返回 `BLOCKED_INPUT`；子系统或音频上下文不可用时返回 `BLOCKED_TOOLING`。
- PIE/运行时环境视为 `BLOCKED_TOOLING`；未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。