---
title: MediaBlueprintFunctionLibrary - 媒体采集设备库
category: UE5.6 Media Libraries
---

# MediaBlueprintFunctionLibrary 概述

## 功能概述

`UMediaBlueprintFunctionLibrary` 提供媒体采集设备的枚举查询功能，包括音频输入设备、视频输入设备与网络摄像头设备的枚举。它本身不负责设备驱动或播放，仅为设备发现提供运行时枚举能力。

## 核心用途与场景

- **设备枚举**：在运行时查询可用的音视频采集设备（麦克风、摄像头、采集卡）
- **设备选择 UI**：在设置菜单中显示可用设备列表供用户选择
- **自动化配置**：根据设备类别筛选特定类型的采集设备（如仅显示采集卡）
- **诊断与调试**：在调试或测试环境中检查设备可用性与枚举结果

## 更多使用示例

### 设备枚举与用户选择

```python
import unreal

lib = unreal.MediaBlueprintFunctionLibrary

# 枚举全部音频输入设备
audio_devices = lib.enumerate_audio_capture_devices()
print(f"Available audio input devices: {len(audio_devices)}")

for dev in audio_devices:
    print(f"- {dev.display_name} (URL: {dev.url})")

# 允许用户选择设备
selected_device = select_from_device_list(audio_devices)

# 将设备 URL 传递给媒体播放器
# media_player.set_source_url(selected_device.url)
```

### 设备分类筛选

```python
# 按位掩码筛选视频输入设备
card_filter = unreal.MediaVideoCaptureDeviceFilter.CARD
video_cards = lib.enumerate_video_capture_devices(card_filter)
print(f"Video capture cards: {len(video_cards)}")

# 枚举前置摄像头
webcam_front = lib.enumerate_webcam_capture_devices(
    unreal.MediaWebcamCaptureDeviceFilter.FRONT)
print(f"Front webcams: {len(webcam_front)}")
```

### 设备可用性诊断

```python
def check_media_devices():
    """检查系统媒体采集设备可用性"""
    results = {
        "audio_in": lib.enumerate_audio_capture_devices(),
        "video_in": lib.enumerate_video_capture_devices(),
        "webcam": lib.enumerate_webcam_capture_devices(),
    }
    
    print("Media Device Check Results:")
    print(f"Audio input: {len(results['audio_in'])} devices")
    print(f"Video input: {len(results['video_in'])} devices") 
    print(f"Webcam: {len(results['webcam'])} devices")
    
    return results
```

## 高级用法与最佳实践

### 设备枚举策略

- **无阻塞枚举**：枚举操作为快照式查询，返回当前可用设备列表
- **位掩码筛选**：通过 `filter` 参数进行位掩码筛选，`-1` 返回全部类型
- **平台兼容性**：不同平台可用设备类别可能不同（如移动端无外接视频输入）

### 用户界面集成

- **实时刷新**：在设置 UI 中定期刷新设备列表（设备可能被插拔）
- **默认设备**：记录上次选择的设备，提高用户体验
- **设备名称显示**：使用 `display_name` 字段展示用户友好名称

### 错误处理与回退

- **空数组处理**：返回空数组表示无设备，不等于错误
- **默认回退**：无可用设备时，使用预设默认设备或禁用相关功能
- **用户提示**：设备不可用时向用户清晰说明问题与解决方案

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 返回空数组 | 平台无设备或驱动未安装 | 向用户提示设备不可用 |
| 设备 URL 格式异常 | 设备驱动问题或平台限制 | 记录日志供调试 |
| 枚举失败 | 平台能力缺失或权限问题 | 检查平台文档与权限设置 |

### 枚举语义

- **快照式枚举**：返回当前时刻的设备列表，不保证后续时刻有效
- **运行时查询**：每次调用都执行设备扫描，避免缓存陈旧数据
- **位掩码组合**：`filter` 参数为位掩码整数，Python 枚举可直接使用

### 最佳实践

- ✅ 显示设备名称而非 URL 给用户
- ✅ 提供设备刷新按钮或自动定时刷新
- ✅ 记录设备枚举日志用于调试
- ✅ 无设备时提供清晰的回退与提示
- ❌ 不要假设设备总是可用
- ❌ 不要缓存设备列表而不刷新

## 总结

`MediaBlueprintFunctionLibrary` 是媒体采集设备枚举的核心工具库，提供音频输入、视频输入与网络摄像头设备的运行时查询能力。它在设备选择 UI、自动化配置与诊断工具中广泛应用，适合需要媒体采集功能的游戏或应用。使用时需注意平台兼容性、空数组处理与用户提示策略。
