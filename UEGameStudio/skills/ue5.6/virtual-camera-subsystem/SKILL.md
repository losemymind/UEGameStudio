---
name: virtual-camera-subsystem
description: UVirtualCameraSubsystem（UE 5.6）编辑器虚拟相机子系统 - 相机切换、镜头控制、录制相关；在 Agent 需要通过 unreal Python 控制编辑器虚拟相机（Editor Viewport Camera）时使用
tags: [ue5.6, editor, camera, python, subsystem]
---

# VirtualCameraSubsystem - 编辑器虚拟相机子系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UVirtualCameraSubsystem`（`UEditorSubsystem` 派生）通过 Python 可调用的子系统方法。方法名与签名依据 `EditorViewport/Classes/Subsystems/EditorVirtualCameraSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UVirtualCameraSubsystem` 在 Python 中以子系统形式访问：

```python
import unreal

# 获取子系统实例
vcam_subsystem = unreal.get_editor_subsystem(unreal.VirtualCameraSubsystem)

# 示例：激活虚拟相机
vcam_subsystem.activate_camera(...)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.VirtualCameraSubsystem)` 核对）。
- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用会失败。
- 虚拟相机功能在 UE 5.6 中为主推编辑器摄影机系统，需编辑器启用对应插件。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **相机激活与切换** | | | |
| 激活 | `activate_camera(camera_actor)` | `bool ActivateCamera(const AActor*)` | `bool` |
| 激活 | `deactivate_camera(camera_actor)` | `void DeactivateCamera(const AActor*)` | `None` |
| 切换 | `switch_to_camera(camera_actor)` | `bool SwitchToCamera(const AActor*)` | `bool` |
| 切换 | `get_active_camera()` | `AActor* GetActiveCamera()` | `Actor` 或 `None` |
| **镜头控制** | | | |
| 位置 | `set_camera_location(camera_actor, location)` | `bool SetCameraLocation(const AActor*, const FVector&)` | `bool` |
| 旋转 | `set_camera_rotation(camera_actor, rotation)` | `bool SetCameraRotation(const AActor*, const FRotator&)` | `bool` |
| 激活 | `get_camera_location(camera_actor)` | `FVector GetCameraLocation(const AActor*)` | `Vector` |
| 激活 | `get_camera_rotation(camera_actor)` | `FRotator GetCameraRotation(const AActor*)` | `Rotator` |
| 激活 | `camera_get_focal_length(camera_actor)` | `float Camera_GetFocalLength(const AActor*)` | `float` |
| 激活 | `camera_set_focal_length(camera_actor, focal_length)` | `void Camera_SetFocalLength(const AActor*, float)` | `None` |
| **录制相关** | | | |
| 录制 | `start_recording()` | `bool StartRecording()` | `bool` |
| 录制 | `stop_recording()` | `bool StopRecording()` | `bool` |
| 录制 | `is_recording()` | `bool IsRecording()` | `bool` |
| 录制 | `get_recording_path()` | `FString GetRecordingPath()` | `str` |
| 录制 | `set_recording_path(path)` | `void SetRecordingPath(const FString&)` | `None` |
| **辅助** | | | |
| 辅助 | `get_all_cameras()` | `TArray<AActor*> GetAllCameras()` | `Array[Actor]` |
| 辅助 | `get_camera_frustum_size(camera_actor, distance)` | `float GetCameraFrustumSize(const AActor*, float)` | `float` |
| 辅助 | `camera_set_aspect_ratio(camera_actor, aspect_ratio)` | `void Camera_SetAspectRatio(const AActor*, float)` | `None` |
| 辅助 | `camera_get_aspect_ratio(camera_actor)` | `float Camera_GetAspectRatio(const AActor*)` | `float` |

## 快速示例

```python
import unreal

def control_vcamera():
    vcam_subsystem = unreal.get_editor_subsystem(unreal.VirtualCameraSubsystem)
    
    # 获取所有相机 Actor
    cameras = vcam_subsystem.get_all_cameras()
    print("cameras count:", len(cameras))
    
    # 激活指定相机
    if cameras:
        ok = vcam_subsystem.activate_camera(cameras[0])
        print("activate:", ok)
        
        # 查询相机位置与旋转
        loc = vcam_subsystem.get_camera_location(cameras[0])
        rot = vcam_subsystem.get_camera_rotation(cameras[0])
        print("location:", loc)
        print("rotation:", rot)
        
        # 设置焦距
        vcam_subsystem.camera_set_focal_length(cameras[0], 50.0)
    
    # 录制控制
    vcam_subsystem.start_recording()
    # ... 进行编辑器操作 ...
    vcam_subsystem.stop_recording()
    
    path = vcam_subsystem.get_recording_path()
    print("recording path:", path)

if __name__ == "__main__":
    control_vcamera()
```

## 注意事项

- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用返回 `BLOCKED_TOOLING`。
- `ActivateCamera` / `SwitchToCamera` 仅切换编辑器视口的相机视角；不影响游戏运行时相机。
- `SetCameraLocation` / `SetCameraRotation` 修改的是编辑器相机的世界位置与旋转；相机 Actor 本身属性不受影响。
- `StartRecording` / `StopRecording` 控制编辑器录制会话；录制文件保存在 `GetRecordingPath` 指定路径。
- `GetAllCameras` 返回当前关卡中所有标记为可被虚拟相机系统管理的 Actor（含 CameraComponent 或 CameraActor）。
- `Camera_GetFocalLength` / `Camera_SetFocalLength` 的焦距单位为毫米（mm），常见值 18-200mm。
- 缺相机 Actor、路径、数值等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
