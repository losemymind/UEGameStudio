---
name: level-utils-blueprint-library
description: ULevelUtilsBlueprintLibrary（UE 5.6）关卡工具函数库 - 关卡设置查询、编辑器/运行时世界获取、关卡加载/卸载；在 Agent 需要通过 unreal Python 查询关卡设置或控制关卡加载时使用
tags: [ue5.6, level, blueprint-library, python]
---

# LevelUtilsBlueprintLibrary - Level Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `ULevelUtilsBlueprintLibrary` 暴露给 Python 的关卡工具方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/LevelUtilsBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.LevelUtilsBlueprintLibrary` 上：

```python
import unreal

api = unreal.LevelUtilsBlueprintLibrary
world = api.get_current_world()
print("current world:", world.get_name() if world else None)
```

- **命名约定**：Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无该 meta 的按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- **世界获取**：`get_current_world()` 返回当前执行上下文的世界；编辑器模式下通常为编辑器世界，PIE/运行时为游戏世界。
- **编辑器相关**：部分方法依赖编辑器上下文，在非编辑器环境返回 `None` 或抛出异常。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 世界 | `get_current_world()` | `UWorld* GetCurrentWorld()` | `World` 或 `None` |
| 世界 | `get_editor_world()` | `UWorld* GetEditorWorld()` | `World` 或 `None`（仅编辑器） |
| 世界 | `get_game_world()` | `UWorld* GetGameWorld()` | `World` 或 `None`（仅 PIE/运行时） |
| 编辑器 | `is_in_editor_mode()` | `bool IsInEditorMode()` | `bool` |
| 编辑器 | `is_in_game_mode()` | `bool IsInGameMode()` | `bool` |
| 关卡 | `load_level(world, level_path, b_should_visiblize=True, b_should_block_on_load=False)` | `bool LoadLevel(UWorld*, const FSoftObjectPath&, bool, bool)` | `bool` |
| 关卡 | `unload_level(world, level_path)` | `bool UnloadLevel(UWorld*, const FSoftObjectPath&)` | `bool` |
| 关卡 | `get_level_from_package(world, package_path)` | `ULevel* GetLevelFromPackage(UWorld*, const FString&)` | `Level` 或 `None` |
| 关卡 | `get_levels(world)` | `TArray<ULevel*> GetLevels(UWorld*)` | `Array[Level]` |
| 设置 | `set_editor_world_real_time_mode(world, b_real_time)` | `void SetEditorWorldRealTimeMode(UWorld*, bool)` | `None`（仅编辑器） |
| 设置 | `set_editor_world_pause(world, b_pause)` | `void SetEditorWorldPause(UWorld*, bool)` | `None`（仅编辑器） |

## 快速示例

```python
import unreal

api = unreal.LevelUtilsBlueprintLibrary

# 获取世界
current_world = api.get_current_world()
if current_world:
    print("world:", current_world.get_name())

# 编辑器模式检查
is_editor = api.is_in_editor_mode()
is_game = api.is_in_game_mode()
print({"editor": is_editor, "game": is_game})

# 编辑器实时模式
editor_world = api.get_editor_world()
if editor_world and is_editor:
    api.set_editor_world_real_time_mode(editor_world, True)
```

## 注意事项

- `get_current_world()` 返回当前上下文世界；编辑器静态脚本无可用世界时返回 `None`。
- `get_editor_world()` 与 `get_game_world()` 分别返回编辑器世界与游戏世界；无对应上下文时返回 `None`。
- `is_in_editor_mode()` / `is_in_game_mode()` 返回当前编辑器运行模式；PIE/PIE 预览时 `is_in_game_mode()` 为 `True`。
- `load_level` / `unload_level` 调用后需等待异步加载完成；`b_should_block_on_load=True` 阻塞至加载完成。
- 缺世界、关卡路径等必要输入返回 `BLOCKED_INPUT`；无编辑器/引擎上下文返回 `BLOCKED_TOOLING`。
- 本库为工具函数集合，不修改资产内容，仅为查询与调用入口。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
