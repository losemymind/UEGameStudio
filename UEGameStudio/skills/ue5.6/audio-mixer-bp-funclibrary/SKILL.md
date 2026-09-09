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

## 注意事项

- 大多数函数依赖音频引擎与真实输出设备；`-NullAudio` / 无设备环境应返回 `BLOCKED_TOOLING`，不得声称已执行。
- `start_recording_output` 调用后音频持续写入内存缓冲，必须用 `finish_recording_output` 取回 `SoundWave` 并 SavePackage 固化，否则结果丢失。
- 频谱分析（`start_spectrum_analysis` + `get_*_for_frequencies`）需要先成功启动分析且 `auto_update` 在 UMG/音频引擎 tick 中更新，Python 脚本调用频率应低于分析更新节奏。
- `finish_recording_output` 返回的 `SoundWave` 若需落盘，仅能经 UE 资产 API 保存；不鼓励在未授权 Package 写入时执行。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
