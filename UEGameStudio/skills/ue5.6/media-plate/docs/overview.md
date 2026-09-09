# MediaPlate 插件 - 完整 API 参考（UE 5.6）

**插件：** MediaPlate  
**要求：** 需在UE编辑器中启用 MediaPlate 插件  
**运行时：** 仅编辑器 Python（`WITH_EDITOR`）  
**未实测声明：** 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言

---

## 一、媒体板播放控制（Playback Control）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `play_media_plate(media_plate)` | `void PlayMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| `pause_media_plate(media_plate)` | `void PauseMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| `stop_media_plate(media_plate)` | `void StopMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| `replay_media_plate(media_plate)` | `void ReplayMediaPlate(UMediaPlate*)`（WITH_EDITOR） | `None` |
| `update_media_plate(playback_mode, time, b_looped)` | `void UpdateMediaPlate(EMediaPlatePlaybackMode, float, bool)`（WITH_EDITOR） | `None` |
| `get_media_plate_state(media_plate)` | `TEnumAsByte<EMediaPlateState::Type> GetMediaPlateState(const UMediaPlate*)` | `int` |
| `get_media_plate_time(media_plate)` | `float GetMediaPlateTime(const UMediaPlate*)` | `float` |
| `get_media_plate_duration(media_plate)` | `float GetMediaPlateDuration(const UMediaPlate*)` | `float` |
| `get_media_plate_frame_rate(media_plate)` | `FFrameRate GetMediaPlateFrameRate(const UMediaPlate*)` | `FrameRate` |
| `is_media_plate_looped(media_plate)` | `bool IsMediaPlateLooped(const UMediaPlate*)` | `bool` |
| `get_media_plate_playback_mode(media_plate)` | `EMediaPlatePlaybackMode GetMediaPlatePlaybackMode(const UMediaPlate*)` | `int` |

---

## 二、媒体板配置（Configuration）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_media_plate_texture(const_media_plate)` | `UTexture* GetMediaPlateTexture(const UMediaPlate*)` | `Texture \| None` |
| `get_media_plate_video_path(media_plate)` | `FString GetMediaPlateVideoPath(const UMediaPlate*)` | `str` |
| `get_media_plate_audio_path(media_plate)` | `FString GetMediaPlateAudioPath(const UMediaPlate*)` | `str` |
| `set_media_plate_video_path(media_plate, path)` | `void SetMediaPlateVideoPath(UMediaPlate*, const FString&)`（WITH_EDITOR） | `None` |
| `set_media_plate_audio_path(media_plate, path)` | `void SetMediaPlateAudioPath(UMediaPlate*, const FString&)`（WITH_EDITOR） | `None` |
| `set_media_plate_playback_mode(media_plate, mode)` | `void SetMediaPlatePlaybackMode(UMediaPlate*, EMediaPlatePlaybackMode)`（WITH_EDITOR） | `None` |
| `get_media_plate_volume(media_plate)` | `float GetMediaPlateVolume(const UMediaPlate*)` | `float` |
| `set_media_plate_volume(media_plate, volume)` | `void SetMediaPlateVolume(UMediaPlate*, float)`（WITH_EDITOR） | `None` |
| `set_media_plate_looped(media_plate, b_looped)` | `void SetMediaPlateLooped(UMediaPlate*, bool)`（WITH_EDITOR） | `None` |

---

## 三、媒体资产创建（Asset Creation）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `create_media_plate_asset(outer, name, asset)` | `UMediaPlate* CreateMediaPlateAsset(UObject*, const FName&, FCreateMediaPlateParams&)`（WITH_EDITOR） | `MediaPlate \| None` |
| `detect_video_file(file_path)` | `bool DetectVideoFile(const FString&)`（WITH_EDITOR） | `bool` |

---

## 四、媒体纹理（Media Texture）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_media_texture(media_plate)` | `UMediaTexture* GetMediaTexture(const UMediaPlate*)` | `MediaTexture \| None` |
| `set_media_texture(media_plate, texture)` | `void SetMediaTexture(UMediaPlate*, UMediaTexture*)`（WITH_EDITOR） | `None` |

---

## 五、辅助工具（Utilities）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_media_plate_class()` | `UClass* GetMediaPlateClass()` | `Class` |
| `get_media_texture_class()` | `UClass* GetMediaTextureClass()` | `Class` |

---

## 六、UFUNCTION 对应的 Python 方法清单

**所有 `UMediaPlate` 类的 `UFUNCTION()` 成员方法：**

1. `PlayMediaPlate`
2. `PauseMediaPlate`
3. `StopMediaPlate`
4. `ReplayMediaPlate`
5. `UpdateMediaPlate`
6. `GetMediaPlateState`
7. `GetMediaPlateTime`
8. `GetMediaPlateDuration`
9. `GetMediaPlateFrameRate`
10. `IsMediaPlateLooped`
11. `GetMediaPlatePlaybackMode`
12. `SetMediaPlatePlaybackMode`
13. `GetMediaPlateVolume`
14. `SetMediaPlateVolume`
15. `SetMediaPlateLooped`
16. `GetMediaPlateTexture`
17. `GetMediaPlateVideoPath`
18. `GetMediaPlateAudioPath`
19. `SetMediaPlateVideoPath`
20. `SetMediaPlateAudioPath`
21. `GetMediaTexture`
22. `SetMediaTexture`
23. `GetMediaPlateClass`（静态）
24. `GetMediaTextureClass`（静态）

**说明：**
- `WITH_EDITOR` 限定方法仅编辑器 Python 可用
- 未列出 `BlueprintPure` 方法因可能已在其他蓝图库合并
- 实际暴露的方法以目标编辑器 `help(unreal.MediaPlateLibrary)` 输出为准

---

## 七、使用限制与要求

- **插件依赖：** 项目必须在 Edit > Plugins > MediaPlate 中启用插件并重载
- **编辑器限制：** 全部方法需在编辑器 Python 中调用（`unreal.System.is_running_in_editor() == True`）
- **BLOCKED_TOOLING：** 项目未启用 MediaPlate 插件或非编辑器环境返回 `BLOCKED_TOOLING`
- **BLOCKED_INPUT：** 缺少媒体板资产路径、无效 asset 类型或路径不存在返回 `BLOCKED_INPUT`
- **写入持久化：** `set_*` 方法修改后必须调用 `unreal.EditorAssetLibrary.save_asset()` 固化
- **未实测调用：** 本表未在真实 UE 5.6 Editor 中实测，调用前需在目标 5.6 环境验证
