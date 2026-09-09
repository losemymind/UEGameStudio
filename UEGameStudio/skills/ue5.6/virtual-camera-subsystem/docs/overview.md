# UVirtualCameraSubsystem API 参考（UE 5.6）

本页列出 `UVirtualCameraSubsystem` 的完整 Python 方法映射表，按功能分组。

## 相机激活与切换（Camera Activation & Switching）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `activate_camera(camera_actor)` | `bool ActivateCamera(const AActor*)` | `bool` |
| `deactivate_camera(camera_actor)` | `void DeactivateCamera(const AActor*)` | `None` |
| `switch_to_camera(camera_actor)` | `bool SwitchToCamera(const AActor*)` | `bool` |
| `get_active_camera()` | `AActor* GetActiveCamera()` | `Actor` 或 `None` |

## 镜头控制（Camera Control）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `set_camera_location(camera_actor, location)` | `bool SetCameraLocation(const AActor*, const FVector&)` | `bool` |
| `set_camera_rotation(camera_actor, rotation)` | `bool SetCameraRotation(const AActor*, const FRotator&)` | `bool` |
| `get_camera_location(camera_actor)` | `FVector GetCameraLocation(const AActor*)` | `Vector` |
| `get_camera_rotation(camera_actor)` | `FRotator GetCameraRotation(const AActor*)` | `Rotator` |
| `camera_get_focal_length(camera_actor)` | `float Camera_GetFocalLength(const AActor*)` | `float` |
| `camera_set_focal_length(camera_actor, focal_length)` | `void Camera_SetFocalLength(const AActor*, float)` | `None` |

## 录制相关（Recording）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `start_recording()` | `bool StartRecording()` | `bool` |
| `stop_recording()` | `bool StopRecording()` | `bool` |
| `is_recording()` | `bool IsRecording()` | `bool` |
| `get_recording_path()` | `FString GetRecordingPath()` | `str` |
| `set_recording_path(path)` | `void SetRecordingPath(const FString&)` | `None` |

## 辅助（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_all_cameras()` | `TArray<AActor*> GetAllCameras()` | `Array[Actor]` |
| `get_camera_frustum_size(camera_actor, distance)` | `float GetCameraFrustumSize(const AActor*, float)` | `float` |
| `camera_set_aspect_ratio(camera_actor, aspect_ratio)` | `void Camera_SetAspectRatio(const AActor*, float)` | `None` |
| `camera_get_aspect_ratio(camera_actor)` | `float Camera_GetAspectRatio(const AActor*)` | `float` |
