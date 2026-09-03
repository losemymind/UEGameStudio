---
name: level-editor-subsystem
description: ULevelEditorSubsystem（UE 5.6）关卡编辑子系统 - load_level/new_level/save_current_level 等关卡加载、创建、保存与当前关卡信息，以及视图/PIE 控制；在 Agent 需要通过 unreal Python 自动化编辑器关卡加载与编辑器状态时使用
tags: [ue5.6, editor, level, python, subsystem]
---

# LevelEditorSubsystem - 关卡编辑与视口控制（UE 5.6）

本 skill 描述 UE 5.6 引擎 `ULevelEditorSubsystem` 暴露给 Python 的关卡编辑方法。方法名与签名依据 `Engine/Source/Editor/LevelEditor/Public/LevelEditorSubsystem.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的成员整理；只记录 Python 可调用的 API。

## 入口说明

- 子系统类：`unreal.LevelEditorSubsystem`（C++ 类 `ULevelEditorSubsystem` 派生自 `UEditorSubsystem`）。
- 获取方式：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 方法名约定：取 `meta=(ScriptMethod=...)` 值转 snake_case，无 ScriptMethod 时按 C++ 函数名转 snake_case。本子系统头文件未声明 ScriptMethod，故以下均采用 C++ 函数名转 snake_case；精确 Python 暴露名与默认参数形态需在目标 UE 5.6 编辑器实测确认。
- Out/ByRef 返回约定：`void` + 单 Out 参数直接返回该参数；返回值 + Out 参数按元组返回。本子系统全部成员均无 Out 参数。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 关卡加载 | `load_level(asset_path)` | `bool LoadLevel(const FString&)` | `bool` |
| 关卡创建 | `new_level(asset_path, b_is_partitioned_world=False)` | `bool NewLevel(const FString&, bool bIsPartitionedWorld=false)` | `bool` |
| 关卡创建 | `new_level_from_template(asset_path, template_asset_path)` | `bool NewLevelFromTemplate(const FString&, const FString&)` | `bool` |
| 当前关卡信息 | `get_current_level()` | `ULevel* GetCurrentLevel()` | `Level` |
| 当前关卡信息 | `set_current_level_by_name(level_name)` | `bool SetCurrentLevelByName(FName)` | `bool` |
| 关卡保存 | `save_current_level()` | `bool SaveCurrentLevel()` | `bool` |
| 关卡保存 | `save_all_dirty_levels()` | `bool SaveAllDirtyLevels()` | `bool` |
| 关卡构建 | `build_light_maps(quality=..., b_with_reflection_captures=False)` | `bool BuildLightMaps(ELightingBuildQuality, bool)` | `bool` |
| 选择集 | `get_selection_set()` | `UTypedElementSelectionSet* GetSelectionSet()` | `TypedElementSelectionSet` |
| 视口 | `editor_invalidate_viewports()` | `void EditorInvalidateViewports()` | `None` |
| 视口 | `editor_set_viewport_realtime(b_in_realtime, viewport_config_key=None)` | `void EditorSetViewportRealtime(bool, FName)` | `None` |
| 视口 | `editor_set_game_view(b_game_view, viewport_config_key=None)` | `void EditorSetGameView(bool, FName)` | `None` |
| 视口 | `editor_get_game_view(viewport_config_key=None)` | `bool EditorGetGameView(FName)` | `bool` |
| 视口 | `get_viewport_config_keys()` | `TArray<FName> GetViewportConfigKeys()` | `Array[Name]` |
| 视口 | `get_active_viewport_config_key()` | `FName GetActiveViewportConfigKey()` | `Name` |
| 视口 | `set_allows_cinematic_control(b_allow, viewport_config_key=None)` | `void SetAllowsCinematicControl(bool, FName)` | `None` |
| 视口 | `get_allows_cinematic_control(viewport_config_key=None)` | `bool GetAllowsCinematicControl(FName)` | `bool` |
| 摄像机 | `pilot_level_actor(actor_to_pilot, viewport_config_key=None)` | `void PilotLevelActor(AActor*, FName)` | `None` |
| 摄像机 | `eject_pilot_level_actor(viewport_config_key=None)` | `void EjectPilotLevelActor(FName)` | `None` |
| 摄像机 | `get_pilot_level_actor(viewport_config_key=None)` | `AActor* GetPilotLevelActor(FName)` | `Actor` 或 `None` |
| 摄像机 | `get_exact_camera_view(viewport_config_key=None)` | `bool GetExactCameraView(FName)` | `bool` |
| 摄像机 | `set_exact_camera_view(b_exact_camera_view, viewport_config_key=None)` | `void SetExactCameraView(bool, FName)` | `None` |
| 编辑模拟 | `editor_play_simulate()` | `void EditorPlaySimulate()` | `None` |
| 编辑模拟 | `editor_request_begin_play()` | `void EditorRequestBeginPlay()` | `None` |
| 编辑模拟 | `editor_request_end_play()` | `void EditorRequestEndPlay()` | `None` |
| 编辑模拟 | `is_in_play_in_editor()` | `bool IsInPlayInEditor()` | `bool` |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
if api is None:
    print({"status": "BLOCKED_TOOLING", "reason": "LevelEditorSubsystem 不可用"})
    raise SystemExit(1)

ok = api.load_level("/Game/Maps/ST_Level")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "关卡路径不存在或加载失败"})
    raise SystemExit(1)

level = api.get_current_level()
print("current level:", level.get_name())

if not api.save_current_level():
    print({"status": "BLOCKED_TOOLING", "reason": "当前关卡保存失败"})
```

## 注意事项

- 关卡加载、新建与保存会变更编辑器世界与资产状态，属世界构建边界（`ue-world-builder` 主责）；本 skill 只提供 LevelEditorSubsystem 的 Python 调用 API，不替代世界构建流程、审核与独立验收。
- `load_level` / `new_level` / `new_level_from_template` 会关闭当前 Persistent Level（不保存），执行前按治理规范确认目标关卡与备份。
- 缺关卡 AssetPath 或路径不可加载 → `BLOCKED_INPUT`；子系统或编辑器上下文不可用 → `BLOCKED_TOOLING`，不得声称关卡工作已完成。
- `get_selection_set` 返回编辑器选择集对象；读取具体选择需进一步调用该对象自身暴露的查询方法。
- 视口/摄像机参数使用 `FName`：`None` 表示当前激活视图；可用的视图配置键见 `get_viewport_config_keys()`。
- `build_light_maps` 的枚举参数默认 `unreal.LightingBuildQuality.PRODUCTION`，精确枚举成员名以实测为准。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。