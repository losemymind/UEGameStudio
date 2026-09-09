# AudioMixerBlueprintLibrary - API 参考（UE 5.6）

本文件整理 `Engine/Source/Runtime/AudioMixer/Classes/AudioMixerBlueprintLibrary.h` 中通过 Python 可暴露的 static `UFUNCTION`。方法暴露于 `unreal.AudioMixerBlueprintLibrary`，精确 snake_case 名以目标 5.6 编辑器 `dir()` 为准。

## 一、Submix 效果链

```python
# 追加一个 submix 效果预设到链尾
unreal.AudioMixerBlueprintLibrary.add_submix_effect(world, submix, effect_preset)

# 从链中移除
unreal.AudioMixerBlueprintLibrary.remove_submix_effect(world, submix, effect_preset)

# 清空
unreal.AudioMixerBlueprintLibrary.clear_submix_effects(world, submix)

# 读取当前链
chain = unreal.AudioMixerBlueprintLibrary.get_submix_effect_chain(world, submix)

# 整链覆盖（淡入淡出秒数 >0 平滑过渡）
unreal.AudioMixerBlueprintLibrary.set_submix_effect_chain_override(world, submix, chain, 0.5)
unreal.AudioMixerBlueprintLibrary.clear_submix_effect_chain_override(world, submix, 0.5)
```

## 二、源效果预设链

```python
unreal.AudioMixerBlueprintLibrary.add_source_effect_to_preset_chain(world, preset_chain, entry)
unreal.AudioMixerBlueprintLibrary.remove_source_effect_from_preset_chain(world, preset_chain, entry_index)
unreal.AudioMixerBlueprintLibrary.set_source_effect_preset_chain_entries(world, preset_chain, entries)
```
`entry` / `entries` 为 `FSourceEffectChainEntry`（`sound_effect_preset` + `b_is_enabled`）。

## 三、录音输出

```python
unreal.AudioMixerBlueprintLibrary.start_recording_output(world, expected_duration=10.0, submix_to_record=None)
wave = unreal.AudioMixerBlueprintLibrary.finish_recording_output(world, submix_to_record=None)
```
- `expected_duration`：预估时长（秒），用于分配缓冲。
- `submix_to_record` 缺省为 Master Submix。
- 返回的 `USoundWave` 如需持久化，通过资产库 `save_asset` 保存（属写入操作，须授权 Package）。

## 四、频谱 / FFT 分析

```python
ok = unreal.AudioMixerBlueprintLibrary.start_spectrum_analysis(
    world, submix,
    spectrum_type=unreal.AudioSpectrumType.MAGNITUDE,   # EAudioSpectrumType
    fft_size=unreal.FFTSize.FFT_SIZE_512,
    interpolation_method=unreal.FFTPeakInterpolationMethod.LINEAR,
    window_type=unreal.FFTWindowType.HANN,
    hop_size=0.0,
    spectrum_band_preset=unreal.AudioSpectrumBandPresetType.KICK_DRUM,
    auto_update=True,
)
mags = unreal.AudioMixerBlueprintLibrary.get_magnitude_for_frequencies(world, submix, [60.0, 250.0, 1000.0])
phases = unreal.AudioMixerBlueprintLibrary.get_phase_for_frequencies(world, submix, [60.0, 250.0])
unreal.AudioMixerBlueprintLibrary.stop_spectrum_analysis(world, submix)
```
枚举名以 `dir(unreal)` 中 `AudioSpectrumType / FFTSize / FFTPeakInterpolationMethod / FFTWindowType / AudioSpectrumBandPresetType` 为准。

## 五、AudioBus

```python
unreal.AudioMixerBlueprintLibrary.start_audio_bus(world, audio_bus)
unreal.AudioMixerBlueprintLibrary.stop_audio_bus(world, audio_bus)
active = unreal.AudioMixerBlueprintLibrary.is_audio_bus_active(world, audio_bus)
```

## 六、输出设备 / Submix 输出（AudioLink）

```python
ok, names = unreal.AudioMixerBlueprintLibrary.get_available_audio_mixer_submix_output_names(world)
ok2 = unreal.AudioMixerBlueprintLibrary.set_audio_mixer_submix_output_device(world, submix, device_id)
ok3, current = unreal.AudioMixerBlueprintLibrary.get_submix_output_device(world, submix)
```

## 绑定约定

- Out/ByRef：`void` + 单 Out → 直接返回；返回值 + Out → 元组。
- 设备/频谱依赖音频引擎；无输出设备、NullAudio 或 Editor 预览受限环境返回 `BLOCKED_TOOLING`。
- 录音返回的 SoundWave 固化属 `.uasset` 写入，遵循仓库 .uasset 安全规范。
