---
name: unreal-editor-subsystem
description: UUnrealEditorSubsystem（UE 5.6）编辑器主世界与视口原语 - 获取编辑器/游戏主世界、读写主关卡视口相机位姿；在 Agent 需要通过 unreal Python 获取编辑器世界上下文或控制主视口时使用
tags: [ue5.6, editor, world, viewport, python, subsystem]
---

# UnrealEditorSubsystem - Editor World & Viewport Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UUnrealEditorSubsystem` 暴露给 Python 的编辑器主世界与视口操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Subsystems/UnrealEditorSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 `ScriptMethod` 时按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- `get_editor_world()` 是各类编辑器脚本（生成、关卡操作、GameplayStatics 世界上下文）最常用的世界来源。
- 坐标为 `unreal.Vector` / `unreal.Rotator`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 世界 | `get_editor_world()` | `UWorld* GetEditorWorld()` | `World` 或 `None` |
| 世界 | `get_game_world()` | `UWorld* GetGameWorld()` | `World` 或 `None` |
| 视口相机 | `get_level_viewport_camera_info()` | `bool GetLevelViewportCameraInfo(FVector&, FRotator&)` | `(bool, Vector, Rotator)` |
| 视口相机 | `set_level_viewport_camera_info(camera_location, camera_rotation)` | `void SetLevelViewportCameraInfo(FVector, FRotator)` | `None` |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
if api is None:
    print({"status": "BLOCKED_TOOLING", "reason": "UnrealEditorSubsystem 不可用"})
    raise SystemExit(1)

world = api.get_editor_world()
if world is None:
    print({"status": "BLOCKED_TOOLING", "reason": "editor world unavailable"})
    raise SystemExit(1)

ok, cam_loc, cam_rot = api.get_level_viewport_camera_info()
if not ok:
    print({"status": "BLOCKED_TOOLING", "reason": "no level editing viewport camera"})
    raise SystemExit(1)

print({"status": "OK", "world": world.get_name(), "camera_location": cam_loc})
api.set_level_viewport_camera_info(
    unreal.Vector(0.0, 0.0, 500.0),
    unreal.Rotator(0.0, 0.0, 0.0),
)
```

## 注意事项

- `get_editor_world` / `get_game_world` 是只读查询，不修改资产；视口相机读写不改关卡内容。
- `get_level_viewport_camera_info` 的 Out 参数按返回值+Out 约定以元组 `(bool, Vector, Rotator)` 返回；`bool` 表示是否能取得主关卡编辑器视口相机。
- 非编辑器构建下 `GetLevelViewportCameraInfo` 返回零化相机与 `False`。
- 无编辑器环境（子系统不可用）→ `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
