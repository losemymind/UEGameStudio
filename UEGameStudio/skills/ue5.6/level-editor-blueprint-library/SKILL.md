---
name: level-editor-blueprint-library
description: ULevelEditorBlueprintLibrary（UE 5.6）关卡编辑器蓝图库 - 关卡选择/设置查询、编辑器视口控制、PIE 控制、关卡加载/保存；在 Agent 需要通过 unreal Python 控制编辑器关卡状态与视口时使用
risk: critical
category: development
tags: [ue5.6, editor, level, blueprint-library, python]
---

# LevelEditorBlueprintLibrary - Level Editor Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 控制编辑器关卡状态与视口时使用本 skill（description 触发场景）。
- 本 skill 只在与 level-editor-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `ULevelEditorBlueprintLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法与签名依据 `Engine/Source/Editor/LevelEditor/Public/LevelEditorBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 的 static 成员整理；Python 方法名按 `meta=(ScriptName=...)` / 反射 snake_case 约定。

## 入口说明

`UBlueprintFunctionLibrary` 的 static 函数在 Python 中以类方法暴露于 `unreal.LevelEditorBlueprintLibrary`：

```python
import unreal

api = unreal.LevelEditorBlueprintLibrary
world = api.get_editor_world()
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.LevelEditorBlueprintLibrary)` 核对）。
- 全部方法均为静态类方法；`unreal.LevelEditorBlueprintLibrary` 为类对象而非实例。
- 本库仅编辑器 Python 可用（`WITH_EDITOR`），运行时环境调用返回 `None` 或失败。

## 可用操作

### 世界与模式

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 世界 | `get_editor_world()` | `UWorld* GetEditorWorld()` | `World` 或 `None`（仅编辑器） |
| 世界 | `get_game_world()` | `UWorld* GetGameWorld()` | `World` 或 `None`（仅 PIE/运行时） |
| 世界 | `get_current_world()` | `UWorld* GetCurrentWorld()` | `World` 或 `None` |
| 模式 | `is_in_editor_mode()` | `bool IsInEditorMode()` | `bool` |
| 模式 | `is_in_game_mode()` | `bool IsInGameMode()` | `bool` |
| 模式 | `is_in_play_in_editor()` | `bool IsInPlayInEditor()` | `bool` |
| 模式 | `is_in_profiling_mode()` | `bool IsInProfilingMode()` | `bool` |

### 关卡加载与保存

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 加载 | `load_level(world, level_path, b_should_visiblize=True, b_should_block_on_load=False)` | `bool LoadLevel(UWorld*, const FSoftObjectPath&, bool, bool)` | `bool` |
| 卸载 | `unload_level(world, level_path)` | `bool UnloadLevel(UWorld*, const FSoftObjectPath&)` | `bool` |
| 保存 | `save_current_level()` | `bool SaveCurrentLevel()` | `bool`（仅编辑器） |
| 保存 | `save_level(world, level_path, b_check_modified=False)` | `bool SaveLevel(UWorld*, const FSoftObjectPath&, bool)` | `bool` |
| 保存 | `save_all_dirty_levels()` | `bool SaveAllDirtyLevels()` | `bool` |
| 构建 | `build_actor_lighting()` | `bool BuildActorLighting()` | `bool` |
| 构建 | `build_light_maps(quality=..., b_with_reflection_captures=False)` | `bool BuildLightMaps(ELightingBuildQuality, bool)` | `bool` |

### 视口控制

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 刷新 | `editor_invalidate_viewports()` | `void EditorInvalidateViewports()` | `None` |
| 实时 | `editor_set_viewport_realtime(b_in_realtime)` | `void EditorSetViewportRealtime(bool)` | `None` |
| 游戏视图 | `editor_set_game_view(b_game_view)` | `void EditorSetGameView(bool)` | `None` |
| 游戏视图 | `editor_get_game_view()` | `bool EditorGetGameView()` | `bool` |
| 摄像机控制 | `editor_set_allows_cinematic_control(b_allow)` | `void EditorSetAllowsCinematicControl(bool)` | `None` |
| 摄像机控制 | `editor_get_allows_cinematic_control()` | `bool EditorGetAllowsCinematicControl()` | `bool` |
| 精确摄像机 | `editor_set_exact_camera_view(b_exact)` | `void EditorSetExactCameraView(bool)` | `None` |
| 精确摄像机 | `editor_get_exact_camera_view()` | `bool EditorGetExactCameraView()` | `bool` |

### PIE 控制

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 开始 | `editor_play_simulate()` | `void EditorPlaySimulate()` | `None` |
| 开始 | `editor_request_begin_play()` | `void EditorRequestBeginPlay()` | `None` |
| 结束 | `editor_request_end_play()` | `void EditorRequestEndPlay()` | `None` |

### 摄像机操控

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 驾驶 | `pilot_level_actor(actor)` | `void PilotLevelActor(AActor*)` | `None` |
| 驾驶 | `eject_pilot_level_actor()` | `void EjectPilotLevelActor()` | `None` |
| 驾驶 | `get_pilot_level_actor()` | `AActor* GetPilotLevelActor()` | `Actor` 或 `None` |

### 选择集

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 选择 | `get_selected_actors()` | `TArray<AActor*> GetSelectedLevelActors()` | `Array[Actor]` |
| 选择 | `get_selected_external_assets()` | `TArray<FAssetData> GetSelectedAssetsFromAssetSelection()` | `Array[AssetData]` |
| 选择 | `get_selected_external_components()` | `TArray<FActorInstanceComponent*> GetSelectedComponentsFromComponentSelection()` | `Array[Component]` |
| 选择 | `clear_selection_set()` | `void ClearSelectionSet()` | `None` |

### 其它

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 视口 | `get_editor_viewport_size()` | `FIntPoint GetEditorViewportSize()` | `IntPoint` |
| 视口 | `get_editor_viewport_position()` | `FIntPoint GetEditorViewportPosition()` | `IntPoint` |
| 关卡 | `get_current_level()` | `ULevel* GetCurrentLevel()` | `Level` 或 `None` |
| 关卡 | `get_level_from_package(world, package_path)` | `ULevel* GetLevelFromPackage(UWorld*, const FString&)` | `Level` 或 `None` |
| 关卡 | `get_levels(world)` | `TArray<ULevel*> GetLevels(UWorld*)` | `Array[Level]` |

## 示例

```python
import unreal

api = unreal.LevelEditorBlueprintLibrary

# 获取世界
editor_world = api.get_editor_world()
if editor_world is None:
    print({"status": "BLOCKED_TOOLING", "reason": "Editor world unavailable"})
    raise SystemExit(1)

# 模式检查
is_editor = api.is_in_editor_mode()
is_game = api.is_in_game_mode()
is_pie = api.is_in_play_in_editor()
print({"editor": is_editor, "game": is_game, "pie": is_pie})

# 保存当前关卡
if not api.save_current_level():
    print({"status": "BLOCKED_TOOLING", "reason": "Save failed"})

# 加载关卡
ok = api.load_level(editor_world, "/Game/Maps/ST_Level")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "Level not found or load failed"})
```

## 限制和注意事项

- `get_editor_world()` 返回编辑器世界；PIE/运行时上下文为空时返回 `None`。
- `is_in_editor_mode()` / `is_in_game_mode()` / `is_in_play_in_editor()` 返回当前编辑器模式；多视口/PIE 预览时状态可能重叠。
- `load_level` / `unload_level` 调用后需等待异步加载完成；`b_should_block_on_load=True` 阻塞至加载完成。
- `build_light_maps` 的 `ELightingBuildQuality` 枚举默认 `PRODUCTION`；精确枚举成员名以实测为准。
- 缺世界、关卡路径等必要输入返回 `BLOCKED_INPUT`；无编辑器/引擎上下文返回 `BLOCKED_TOOLING`。
- `pilot_level_actor` 等摄像机操控方法在非编辑器模式下调用无效。
- 本库为编辑器操作入口，不修改资产内容本身，仅为查询与控制入口。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
