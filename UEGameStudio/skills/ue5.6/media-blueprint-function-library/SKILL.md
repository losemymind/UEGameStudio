---
name: media-blueprint-function-library
description: UMediaBlueprintFunctionLibrary（UE 5.6）媒体查询函数库 - 枚举音频/视频/网络摄像头采集设备；在 Agent 需要通过 unreal Python 查询媒体采集设备（音视频输入源）时使用
risk: safe
category: development
tags: [ue5.6, media, python, blueprint-function-library, capture-device]
---

# MediaBlueprintFunctionLibrary - 媒体采集设备查询（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 查询媒体采集设备（音视频输入源）时使用本 skill（description 触发场景）。
- 本 skill 只在与 media-blueprint-function-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UMediaBlueprintFunctionLibrary` 暴露给 Python 的静态方法，依据 `Engine/Source/Runtime/MediaAssets/Public/Misc/MediaBlueprintFunctionLibrary.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的成员整理。本库只提供媒体采集设备（音频输入、视频输入、网络摄像头）枚举查询，属于媒体职责的 Python API 入口，视频能力归 `ue-ui-engineer`，音频能力归 `game-audio-technical-specialist`。

## 入口说明

```python
import unreal
lib = unreal.MediaBlueprintFunctionLibrary
```

- Python 类名取 UCLASS 类名 `UMediaBlueprintFunctionLibrary` 去掉 U 前缀：`unreal.MediaBlueprintFunctionLibrary`。
- 静态方法直接用类调用，无需实例、不依赖编辑器世界。
- Python 类型对应：`FMediaCaptureDevice` → `unreal.MediaCaptureDevice`（字段 `display_name` / `url`）；过滤位掩码枚举为 `unreal.MediaAudioCaptureDeviceFilter`、`unreal.MediaVideoCaptureDeviceFilter`、`unreal.MediaWebcamCaptureDeviceFilter`。
- 命名约定：本头文件未声明 `ScriptMethod`，方法名按 C++ 函数名转 snake_case 推定（如 `EnumerateAudioCaptureDevices` → `enumerate_audio_capture_devices`）；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- Out/ByRef 返回约定：`void`+单 Out 直接返回该值；无 Out 无返回值则 `None`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 采集设备 | `enumerate_audio_capture_devices(filter=-1)` | `void EnumerateAudioCaptureDevices(TArray<FMediaCaptureDevice>& OutDevices, int32 Filter=-1)` | `Array[MediaCaptureDevice]`（单 Out 直接返回） |
| 采集设备 | `enumerate_video_capture_devices(filter=-1)` | `void EnumerateVideoCaptureDevices(TArray<FMediaCaptureDevice>& OutDevices, int32 Filter=-1)` | `Array[MediaCaptureDevice]`（单 Out 直接返回） |
| 采集设备 | `enumerate_webcam_capture_devices(filter=-1)` | `void EnumerateWebcamCaptureDevices(TArray<FMediaCaptureDevice>& OutDevices, int32 Filter=-1)` | `Array[MediaCaptureDevice]`（单 Out 直接返回） |

## 示例

```python
import unreal

lib = unreal.MediaBlueprintFunctionLibrary

# 全部音频输入设备（Filter 默认 -1）
audio_in = lib.enumerate_audio_capture_devices()
for dev in audio_in:
    print("audio:", dev.display_name, dev.url)

# 按位掩码筛选视频输入：仅采集卡
card = unreal.MediaVideoCaptureDeviceFilter.CARD
video_in = lib.enumerate_video_capture_devices(card)
print("video capture cards:", len(video_in))

# 前置网络摄像头
webcams = lib.enumerate_webcam_capture_devices(unreal.MediaWebcamCaptureDeviceFilter.FRONT)
for cam in webcams:
    assert cam.url.startswith("webcam://")
```

## 限制和注意事项

- 三个枚举方法均为运行时查询，返回空数组表示当前平台无符合条件的采集设备，不等于调用失败。
- `filter` 为位掩码整数，`-1`（默认）返回全部类型；Python 枚举值可作位掩码传入，组合筛选按 BitFlags 语义进行。
- 枚举仅返回设备描述（`display_name` / `url`），驱动/播放需交给 `MediaPlayer` 等运行时组件。
- 缺采集设备引用或无法从结果中取得有效 URL 时返回 `BLOCKED_INPUT`；无可用 Python/Editor 环境时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。