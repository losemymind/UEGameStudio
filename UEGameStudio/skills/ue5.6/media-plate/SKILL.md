---
name: media-plate
description: "U MediaPlate插件（媒体板） - 视频/图像序列媒体板生成、播放控制与媒体资产管理；需在UE中启用MediaPlate插件"
tags: [ue5.6, media-plate, video, python, plugin]
---

# MediaPlate - 媒体板系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `MediaPlate` 插件（需在UE编辑器中启用）通过 Python 可调用的类与函数。方法名与签名依据 `MediaPlate/Source/MediaPlate/Classes/MediaPlate.h` 中带 `UFUNCTION()` 标记的成员整理；Python 方法名按反射约定转 snake_case。

## 入口说明

```python
import unreal

# 创建媒体板资产示例（需编辑器环境）
bp_asset = unreal.load_asset("/Game/Media/MediaPlateAsset")
if bp_asset is None:
    print("BLOCKED_INPUT: MediaPlate asset not found")
    raise SystemExit(1)

# 调用示例
unreal.MediaPlateLibrary.play_media_plate(bp_asset)
```

**实测要求：**
- 编辑器 Python 环境（非运行时）
- 项目已启用 `MediaPlate` 插件（Edit > Plugins > MediaPlate > Enabled + 重载）
- 带 `WITH_EDITOR` 限定的方法仅编辑器可用

**BLOCKED_TOOLING 处理：**
```python
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "MediaPlate 仅编辑器 Python 可用"})
    raise SystemExit(1)

media_plate_plugin = unreal.EditorPluginUtil.is_plugin_enabled("MediaPlate")
if not media_plate_plugin:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 MediaPlate 插件"})
    raise SystemExit(1)
```

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **媒体板播放控制** | | | |
| 播放 | `play_media_plate(media_plate)` | `void PlayMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| 暂停 | `pause_media_plate(media_plate)` | `void PauseMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| 停止 | `stop_media_plate(media_plate)` | `void StopMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| 重播 | `replay_media_plate(media_plate)` | `void ReplayMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| 更新播放状态 | `update_media_plate(playback_mode, time, b_looped)` | `void UpdateMediaPlate(EMediaPlatePlaybackMode, float, bool)`（WITH_EDITOR） | `None` |
| 获取播放状态 | `get_media_plate_state(media_plate)` | `TEnumAsByte<EMediaPlateState::Type> GetMediaPlateState(const UMediaPlate*)` | `int` |
| 获取播放时间 | `get_media_plate_time(media_plate)` | `float GetMediaPlateTime(const UMediaPlate*)` | `float` |
| 获取持续时间 | `get_media_plate_duration(media_plate)` | `float GetMediaPlateDuration(const UMediaPlate*)` | `float` |
| 获取帧率 | `get_media_plate_frame_rate(media_plate)` | `FFrameRate GetMediaPlateFrameRate(const UMediaPlate*)` | `FrameRate` |
| **媒体板配置** | | | |
| 获取纹理 | `get_media_plate_texture(const_media_plate)` | `UTexture* GetMediaPlateTexture(const UMediaPlate*)` | `Texture` 或 `None` |
| 获取视频路径 | `get_media_plate_video_path(media_plate)` | `FString GetMediaPlateVideoPath(const UMediaPlate*)` | `str` |
| 获取音频路径 | `get_media_plate_audio_path(media_plate)` | `FString GetMediaPlateAudioPath(const UMediaPlate*)` | `str` |
| 设置视频路径 | `set_media_plate_video_path(media_plate, path)` | `void SetMediaPlateVideoPath(UMediaPlate*, const FString&)`（WITH_EDITOR） | `None` |
| 设置音频路径 | `set_media_plate_audio_path(media_plate, path)` | `void SetMediaPlateAudioPath(UMediaPlate*, const FString&)`（WITH_EDITOR） | `None` |
| 播放模式 | `get_media_plate_playback_mode(media_plate)` | `EMediaPlatePlaybackMode GetMediaPlatePlaybackMode(const UMediaPlate*)` | `int` |
| 设置播放模式 | `set_media_plate_playback_mode(media_plate, mode)` | `void SetMediaPlatePlaybackMode(UMediaPlate*, EMediaPlatePlaybackMode)`（WITH_EDITOR） | `None` |
| 音量 | `get_media_plate_volume(media_plate)` | `float GetMediaPlateVolume(const UMediaPlate*)` | `float` |
| 设置音量 | `set_media_plate_volume(media_plate, volume)` | `void SetMediaPlateVolume(UMediaPlate*, float)`（WITH_EDITOR） | `None` |
| 循环 | `is_media_plate_looped(media_plate)` | `bool IsMediaPlateLooped(const UMediaPlate*)` | `bool` |
| 设置循环 | `set_media_plate_looped(media_plate, b_looped)` | `void SetMediaPlateLooped(UMediaPlate*, bool)`（WITH_EDITOR） | `None` |
| **媒体资产创建** | | | |
| 创建媒体板资产 | `create_media_plate_asset(outer, name, asset)` | `UMediaPlate* CreateMediaPlateAsset(UObject*, const FName&, FCreateMediaPlateParams&)`（WITH_EDITOR） | `MediaPlate` 或 `None` |
| 检测视频文件 | `detect_video_file(file_path)` | `bool DetectVideoFile(const FString&)`（WITH_EDITOR） | `bool` |
| **媒体纹理** | | | |
| 获取媒体纹理 | `get_media_texture(media_plate)` | `UMediaTexture* GetMediaTexture(const UMediaPlate*)` | `MediaTexture` 或 `None` |
| 设置媒体纹理 | `set_media_texture(media_plate, texture)` | `void SetMediaTexture(UMediaPlate*, UMediaTexture*)`（WITH_EDITOR） | `None` |
| **辅助** | | | |
| 获取静态类 | `get_media_plate_class()` | `UClass* GetMediaPlateClass()` | `Class` |
| 获取媒体纹理类 | `get_media_texture_class()` | `UClass* GetMediaTextureClass()` | `Class` |

## 快速示例

```python
import unreal

# 1. 验证插件与环境
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "MediaPlate 仅编辑器可用"})
    raise SystemExit(1)

plugin_enabled = unreal.EditorPluginUtil.is_plugin_enabled("MediaPlate")
if not plugin_enabled:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 MediaPlate 插件"})
    raise SystemExit(1)

# 2. 加载现有媒体板资产
path = "/Game/Media/MP_VideoWall"
media_plate = unreal.load_asset(path)
if media_plate is None or not isinstance(media_plate, unreal.MediaPlate):
    print("BLOCKED_INPUT: MediaPlate asset not loadable")
    raise SystemExit(1)

# 3. 播放控制
unreal.MediaPlateLibrary.play_media_plate(media_plate)

# 4. 查询状态
state = unreal.MediaPlateLibrary.get_media_plate_state(media_plate)
time = unreal.MediaPlateLibrary.get_media_plate_time(media_plate)
duration = unreal.MediaPlateLibrary.get_media_plate_duration(media_plate)
print(f"State={state}, Time={time:.2f}s, Duration={duration:.2f}s")

# 5. 音量调节
unreal.MediaPlateLibrary.set_media_plate_volume(media_plate, 0.8)

# 6. 获取纹理
texture = unreal.MediaPlateLibrary.get_media_plate_texture(media_plate)
if texture:
    print(f"Texture: {texture.get_path_name()}")

# 7. 保存修改（若有）
if unreal.CoreEditor.is_asset_dirty(media_plate):
    unreal.EditorAssetLibrary.save_asset(path)
```

## 注意事项

- **阻塞处理：**
  - 缺资产路径、无效 asset 类型等返回 `BLOCKED_INPUT`
  - 无编辑器环境或插件未启用返回 `BLOCKED_TOOLING`
  - `WITH_EDITOR` 限定方法仅编辑器 Python 可用；非编辑器环境调用失败

- **返回值约定：**
  - `void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位
  - `UObject*` / `UClass*` 返回对应 Python 对象或 `None`

- **持久化：**
  - 任何修改媒体板配置的写入操作（`set_*`）完成后，必须经编辑器 API 固化：
    ```python
    unreal.EditorAssetLibrary.save_asset(path)
    unreal.EditorReloadConfigSettings()
    ```

- **验证要求：**
  - `get_media_plate_*` 探测方法为只读
  - `set_*`、`create_*` 为写入操作，需由审计/QA 独立验收
  - `_detect_video_file()` 等检测类调用后应验证返回值

- **未实测声明：**
  - 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言
  - 方法名、签名、返回值类型需在 5.6 实际环境中通过 `dir(unreal.MediaPlateLibrary)`、`help()` 核对确认

详细 API 与完整示例见 `docs/overview.md`。
