---
name: audio-mixer-bp-funclibrary
description: UAudioMixerBlueprintLibrary（UE 5.6）音频混音器函数库 - Submix 效果链覆盖/叠加、源效果预设链、录音输出、频谱分析（Magnitude/Phase）、AudioBus 与输出设备名称管理；Agent 需要通过 unreal Python 做运行时音频混音器控制时使用
tags: [ue5.6, audio, submix, python, blueprint-function-library]
---

# AudioMixerBlueprintLibrary - 音频混音器函数库（UE 5.6）

本 skill 描述 UE 5.6 `UAudioMixerBlueprintLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法名与签名依据 `Engine/Source/Runtime/AudioMixer/Classes/AudioMixerBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 的 static 成员整理；Python 方法名按反射 snake_case 约定。

## 入口说明

static 函数在 Python 中以类方法暴露于 `unreal.AudioMixerBlueprintLibrary`，多数函数首个实参是 `WorldContextObject`：

```python
import unreal

world = unreal.EditorLevelLibrary.get_editor_world()
aml = unreal.AudioMixerBlueprintLibrary
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.AudioMixerBlueprintLibrary)` 核对）。
- 音频 API 与音频引擎设备绑定；编辑器纯预览与无声卡 / NullAudio 设备环境下部分调用返回失败或空结果，须先确认设备可用。

## 可用操作

### Submix 效果链（Sound Submix Effect Chain）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `add_submix_effect(world_context, sound_submix, submix_effect_preset)` | `void AddSubmixEffect(UObject*, USoundSubmix*, USoundEffectSubmixPreset*)` | `None` |
| `remove_submix_effect(world_context, sound_submix, submix_effect_preset)` | `void RemoveSubmixEffect(UObject*, USoundSubmix*, USoundEffectSubmixPreset*)` | `None` |
| `clear_submix_effects(world_context, sound_submix)` | `void ClearSubmixEffects(UObject*, USoundSubmix*)` | `None` |
| `get_submix_effect_chain(world_context, sound_submix)` | `void GetSubmixEffectChain(UObject*, USoundSubmix*, TArray<USoundEffectSubmixPreset*>&)` | `Array[SoundEffectSubmixPreset]` |
| `set_submix_effect_chain_override(world_context, sound_submix, chain, fade_time_sec)` | `void SetSubmixEffectChainOverride(UObject*, USoundSubmix*, const TArray<USoundEffectSubmixPreset*>&, float)` | `None` |
| `clear_submix_effect_chain_override(world_context, sound_submix, fade_time_sec)` | `void ClearSubmixEffectChainOverride(UObject*, USoundSubmix*, float)` | `None` |

### 源效果预设链（Source Effect Preset Chain）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `add_source_effect_to_preset_chain(world_context, preset_chain, entry)` | `bool AddSourceEffectToPresetChain(UObject*, USoundEffectSourcePresetChain*, FSourceEffectChainEntry)` | `bool` |
| `remove_source_effect_from_preset_chain(world_context, preset_chain, entry_index)` | `bool RemoveSourceEffectFromPresetChain(UObject*, USoundEffectSourcePresetChain*, int32)` | `bool` |
| `set_source_effect_preset_chain_entries(world_context, preset_chain, entries)` | `bool SetSourceEffectPresetChainEntries(UObject*, USoundEffectSourcePresetChain*, const TArray<FSourceEffectChainEntry>&)` | `bool` |

### 录音输出（Submix Recording）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `start_recording_output(world_context, expected_duration=1.0, submix_to_record=None)` | `void StartRecordingOutput(UObject*, float, USoundSubmix*)` | `None` |
| `finish_recording_output(world_context, submix_to_record=None)` | `USoundWave* FinishRecordingOutput(UObject*, USoundSubmix*)` | `SoundWave` |

### 频谱分析（Spectrum / FFT）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `start_spectrum_analysis(world_context, submix_to_analyze, spectrum_type, fft_size, interpolation_method, window_type, hop_size, spectrum_band_preset, auto_update)` | `bool StartSpectrumAnalysis(UObject*, USoundSubmix*, EAudioSpectrumType, EFFTSize, EFFTPeakInterpolationMethod, EFFTWindowType, float, EAudioSpectrumBandPresetType, bool)` | `bool` |
| `stop_spectrum_analysis(world_context, submix_to_analyze)` | `void StopSpectrumAnalysis(UObject*, USoundSubmix*)` | `None` |
| `get_magnitude_for_frequencies(world_context, submix_to_analyze, frequencies)` | `void GetMagnitudeForFrequencies(UObject*, USoundSubmix*, const TArray<float>&, TArray<float>&)` | `Array[float]` |
| `get_phase_for_frequencies(world_context, submix_to_analyze, frequencies)` | `void GetPhaseForFrequencies(UObject*, USoundSubmix*, const TArray<float>&, TArray<float>&)` | `Array[float]` |
| `add_spectrum_analysis_delegate(world_context, submix_to_analyze, band_settings, callback)` | `void AddSpectralAnalysisDelegate(UObject*, USoundSubmix*, const FSoundSubmixSpectralAnalysisBandSettings&, FOnSubmixSpectrumAnalysis)` | `None` |
| `remove_spectrum_analysis_delegate(world_context, submix_to_analyze, callback)` | `void RemoveSpectralAnalysisDelegate(UObject*, USoundSubmix*, FOnSubmixSpectrumAnalysis)` | `None` |

### AudioBus

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `start_audio_bus(world_context, audio_bus)` | `void StartAudioBus(UObject*, UAudioBus*)` | `None` |
| `stop_audio_bus(world_context, audio_bus)` | `void StopAudioBus(UObject*, UAudioBus*)` | `None` |
| `is_audio_bus_active(world_context, audio_bus)` | `bool IsAudioBusActive(UObject*, UAudioBus*)` | `bool` |

### 输出设备 / Submix 输出（AudioLink 平台扩展）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `get_available_audio_mixer_submix_output_names(world_context)` | `bool GetAvailableAudioMixerSubmixOutputNames(UObject*, TArray<FString>&)` | `(bool, Array[str])` |
| `set_audio_mixer_submix_output_device(world_context, submix, device_id)` | `bool SetAudioMixerSubmixOutputDevice(UObject*, USoundSubmix*, const FString&)` | `bool` |
| `get_submix_output_device(world_context, submix)` | `bool GetSubmixOutputDevice(UObject*, USoundSubmix*, FString&)` | `(bool, str)` |

## 快速示例

```python
import unreal

world = unreal.EditorLevelLibrary.get_editor_world()
aml = unreal.AudioMixerBlueprintLibrary

submix = unreal.load_asset("/Game/Audio/SM_Master")
if submix is None:
    print("BLOCKED_INPUT: master submix not loadable")
    raise SystemExit(1)

ok, names = aml.get_available_audio_mixer_submix_output_names(world)
print("output devices:", names if ok else [])
```

## 综合实战示例

### Submix效果链管理系统

```python
import unreal

class SubmixEffectChainManager:
    def __init__(self):
        self.aml = unreal.AudioMixerBlueprintLibrary
        self.world = None
    
    def initialize(self):
        self.world = unreal.EditorLevelLibrary.get_editor_world()
        return self.world is not None
    
    def add_effect_to_chain(self, submix, effect_preset):
        if self.world:
            self.aml.add_submix_effect(self.world, submix, effect_preset)
            return True
        return False
    
    def remove_effect_from_chain(self, submix, effect_preset):
        if self.world:
            self.aml.remove_submix_effect(self.world, submix, effect_preset)
            return True
        return False
    
    def get_effect_chain(self, submix):
        if self.world:
            effect_chain = []
            self.aml.get_submix_effect_chain(self.world, submix, effect_chain)
            return effect_chain
        return []
    
    def set_chain_override(self, submix, effects_chain, fade_time=0.5):
        if self.world:
            self.aml.set_submix_effect_chain_override(self.world, submix, effects_chain, fade_time)
            return True
        return False

def manage_submix_effects():
    manager = SubmixEffectChainManager()
    
    if not manager.initialize():
        print("Failed to initialize")
        return
    
    master_submix = unreal.load_asset("/Game/Audio/SM_Master")
    if not master_submix:
        print("Master submix not found")
        return
    
    # 添加压缩器效果
    compressor_preset = unreal.load_asset("/Game/Audio/Presets/PE_Compressor.PE_Compressor")
    manager.add_effect_to_chain(master_submix, compressor_preset)
    
    # 添加限制器效果
    limiter_preset = unreal.load_asset("/Game/Audio/Presets/PE_Limiter.PE_Limiter")
    manager.add_effect_to_chain(master_submix, limiter_preset)
    
    # 查询效果链
    chain = manager.get_effect_chain(master_submix)
    print(f"Effect chain length: {len(chain)}")
```

### 频谱分析系统

```python
import unreal

class SpectrumAnalyzer:
    def __init__(self):
        self.aml = unreal.AudioMixerBlueprintLibrary
        self.world = None
        self.analyzing = False
    
    def initialize(self):
        self.world = unreal.EditorLevelLibrary.get_editor_world()
        return self.world is not None
    
    def start_analysis(self, submix, spectrum_type="Magnitude", fft_size=2048):
        if not self.world:
            return False
        
        ok = self.aml.start_spectrum_analysis(
            self.world,
            submix,
            spectrum_type,
            fft_size,
            unreal.EFFT PeakInterpolationMethod.Quadratic,
            unreal.EFFTWindowType.Hann,
            0.5,
            unreal.EAudioSpectrumBandPreset.FullSpectrum,
            True
        )
        self.analyzing = ok
        return ok
    
    def stop_analysis(self, submix):
        if self.world and self.analyzing:
            self.aml.stop_spectrum_analysis(self.world, submix)
            self.analyzing = False
            return True
        return False
    
    def get_magnitude_for_frequency(self, submix, frequency):
        if self.world and self.analyzing:
            magnitudes = []
            self.aml.get_magnitude_for_frequencies(self.world, submix, [frequency], magnitudes)
            return magnitudes[0] if magnitudes else 0.0
        return 0.0

def audio_spectrum_monitor():
    analyzer = SpectrumAnalyzer()
    
    if not analyzer.initialize():
        print("Failed to initialize")
        return
    
    music_submix = unreal.load_asset("/Game/Audio/SM_Music")
    if not music_submix:
        print("Music submix not found")
        return
    
    # 开始频谱分析
    if analyzer.start_analysis(music_submix):
        print("Spectrum analysis started")
        
        # 查询特定频率幅度
        for freq in [100.0, 500.0, 1000.0, 5000.0]:
            magnitude = analyzer.get_magnitude_for_frequency(music_submix, freq)
            print(f"{freq}Hz: {magnitude:.4f}")
        
        # 停止分析
        analyzer.stop_analysis(music_submix)
        print("Spectrum analysis stopped")
```

### 录音输出系统

```python
import unreal

class AudioRecorder:
    def __init__(self):
        self.aml = unreal.AudioMixerBlueprintLibrary
        self.world = None
        self.recording = False
    
    def initialize(self):
        self.world = unreal.EditorLevelLibrary.get_editor_world()
        return self.world is not None
    
    def start_recording(self, submix=None, duration=60.0):
        if not self.world:
            return False
        
        self.aml.start_recording_output(self.world, duration, submix)
        self.recording = True
        return True
    
    def finish_recording(self, submix=None):
        if self.world and self.recording:
            sound_wave = self.aml.finish_recording_output(self.world, submix)
            self.recording = False
            
            # 保存到包
            if sound_wave:
                asset_path = "/Game/Audio/Recorded/SavedRecording"
                unreal.EditorAssetLibrary.save_asset(asset_path, sound_wave)
                return sound_wave
        return None

def audio_recording_example():
    recorder = AudioRecorder()
    
    if not recorder.initialize():
        print("Failed to initialize")
        return
    
    # 开始录音
    master_submix = unreal.load_asset("/Game/Audio/SM_Master")
    recorder.start_recording(master_submix, duration=10.0)
    
    print("Recording started for 10 seconds...")
    
    # 延迟10秒后停止
    # unreal.delay(10.0, lambda: finish_recording(master_submix))
```

## 高级用法

### AudioBus控制

```python
import unreal

class AudioBusManager:
    def __init__(self):
        self.aml = unreal.AudioMixerBlueprintLibrary
        self.world = None
    
    def initialize(self):
        self.world = unreal.EditorLevelLibrary.get_editor_world()
        return self.world is not None
    
    def start_audio_bus(self, audio_bus):
        if self.world:
            self.aml.start_audio_bus(self.world, audio_bus)
            return True
        return False
    
    def stop_audio_bus(self, audio_bus):
        if self.world:
            self.aml.stop_audio_bus(self.world, audio_bus)
            return True
        return False
    
    def is_bus_active(self, audio_bus):
        if self.world:
            return self.aml.is_audio_bus_active(self.world, audio_bus)
        return False

def audio_bus_example():
    manager = AudioBusManager()
    
    if not manager.initialize():
        print("Failed to initialize")
        return
    
    # 启动 AudioBus
    bus = unreal.load_asset("/Game/Audio/Buses/BUS_Music")
    manager.start_audio_bus(bus)
    
    # 查询状态
    is_active = manager.is_bus_active(bus)
    print(f"AudioBus active: {is_active}")
```

### 延迟统计与性能分析

```python
import unreal

class AudioLatencyAnalyzer:
    def __init__(self):
        self.aml = unreal.AudioMixerBlueprintLibrary
        self.world = None
        self.latency_samples = []
    
    def initialize(self):
        self.world = unreal.EditorLevelLibrary.get_editor_world()
        return self.world is not None
    
    def sample_game_to_audio_latency(self):
        if not self.world:
            return None
        
        avg = self.aml.get_game_thread_to_audio_render_thread_average_latency(self.world)
        min_lat = self.aml.get_game_thread_to_audio_render_thread_min_latency(self.world)
        max_lat = self.aml.get_game_thread_to_audio_render_thread_max_latency(self.world)
        
        self.latency_samples.append({
            "avg": avg,
            "min": min_lat,
            "max": max_lat
        })
        
        return {
            "avg": avg,
            "min": min_lat,
            "max": max_lat
        }
    
    def get_statistics(self):
        if not self.latency_samples:
            return None
        
        avg_avg = sum(s["avg"] for s in self.latency_samples) / len(self.latency_samples)
        min_min = min(s["min"] for s in self.latency_samples)
        max_max = max(s["max"] for s in self.latency_samples)
        
        return {
            "avg_avg": avg_avg,
            "min_min": min_min,
            "max_max": max_max,
            "sample_count": len(self.latency_samples)
        }

def analyze_audio_latency():
    analyzer = AudioLatencyAnalyzer()
    
    if not analyzer.initialize():
        print("Failed to initialize")
        return
    
    # 多次采样
    for _ in range(10):
        latency = analyzer.sample_game_to_audio_latency()
        print(f"Latency: avg={latency['avg']:.2f}ms")
    
    # 统计
    stats = analyzer.get_statistics()
    if stats:
        print(f"Statistics: avg={stats['avg_avg']:.2f}ms, min={stats['min_min']:.2f}ms, max={stats['max_max']:.2f}ms")
```

## 常见问题与最佳实践

### 音频设备兼容性

1. **NullAudio 设备**：
   - `-NullAudio` 启动时音频 API 返回失败
   - 应先检测 `get_available_audio_mixer_submix_output_names` 是否成功
   
2. **设备切换**：
   - 运行时支持设备切换
   - 使用 `set_audio_mixer_submix_output_device` 更改输出设备

### 性能优化

1. **频谱分析优化**：
   - 减小 FFT Size 降低计算开销
   - 关闭 `auto_update` 时手动控制更新频率
   
2. **效果链管理**：
   - 避免过长的效果链
   - 使用 `SetSubmixEffectChainOverride` 批量替换

### 常见陷阱

1. **输出设备检测**：
   - `get_available_audio_mixer_submix_output_names` 失败返回 `(False, [])`
   - 应检查返回的 `ok` 标志
   
2. **录音缓冲区**：
   - `start_recording_output` 使用固定时间缓冲
   - 必须用 `finish_recording_output` 取回结果

## 注意事项

- 大多数函数依赖音频引擎与真实输出设备；`-NullAudio` / 无设备环境应返回 `BLOCKED_TOOLING`，不得声称已执行。
- `start_recording_output` 调用后音频持续写入内存缓冲，必须用 `finish_recording_output` 取回 `SoundWave` 并 SavePackage 固化，否则结果丢失。
- 频谱分析（`start_spectrum_analysis` + `get_*_for_frequencies`）需要先成功启动分析且 `auto_update` 在 UMG/音频引擎 tick 中更新，Python 脚本调用频率应低于分析更新节奏。
- `finish_recording_output` 返回的 `SoundWave` 若需落盘，仅能经 UE 资产 API 保存；不鼓励在未授权 Package 写入时执行。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
