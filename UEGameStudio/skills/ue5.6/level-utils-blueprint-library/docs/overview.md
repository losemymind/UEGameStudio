---
title: LevelUtilsBlueprintLibrary - 关卡工具库
category: UE5.6 Blueprint Libraries
---

# LevelUtilsBlueprintLibrary 概述

## 功能概述

`ULevelUtilsBlueprintLibrary` 提供关卡与世界管理的实用工具函数，包括获取当前/编辑器/游戏世界、检测当前编辑器模式（编辑/游戏）、以及关卡的加载/卸载操作。它是关卡系统与脚本/蓝图操作的核心接口。

## 核心用途与场景

- **世界上下文获取**：在编辑器脚本或工具中获取当前有效世界（编辑器世界或游戏世界）
- **编辑器模式检测**：区分编辑器模式与游戏模式，启用不同的工具行为
- **关卡加载控制**：在运行时动态加载或卸载地图关卡
- **关卡枚举与查询**：获取当前世界的关卡列表或特定关卡对象

## 更多使用示例

### 条件性工具行为

```python
import unreal

api = unreal.LevelUtilsBlueprintLibrary

# 获取当前世界
world = api.get_current_world()
if not world:
    unreal.log_error("No current world available")
    raise SystemExit(1)

# 检测当前模式
in_editor = api.is_in_editor_mode()
in_game = api.is_in_game_mode()

if in_editor:
    unreal.log("Editor mode - enabling editor tools")
    editor_world = api.get_editor_world()
    # editor World 用于编辑器操作
elif in_game:
    unreal.log("Game mode - enabling gameplay tools")
    game_world = api.get_game_world()
    # Game World 用于游戏逻辑

unreal.log(f"Current world: {world.get_name()}")
```

### 动态关卡加载

```python
# 加载指定关卡
world = api.get_current_world()
if world:
    level_path = "/Game/Maps/Level_02"
    success = api.load_level(world, level_path, 
        b_should_visiblize=True, 
        b_should_block_on_load=True)
    
    if success:
        unreal.log(f"Level {level_path} loaded successfully")
    else:
        unreal.log_error(f"Failed to load level {level_path}")
```

### 编辑器实时模式控制

```python
# 启用编辑器实时模式（非 PIE）
editor_world = api.get_editor_world()
if editor_world:
    # 设置为实时模式，时间流逝
    api.set_editor_world_real_time_mode(editor_world, True)
    
    # 可选：暂停场景
    # api.set_editor_world_pause(editor_world, True)
```

## 高级用法与最佳实践

### 世界类型选择

- **`get_current_world()`**：返回当前执行上下文的世界，适合通用工具
- **`get_editor_world()`**：仅在编辑器模式下有效，用于编辑器工具
- **`get_game_world()`**：仅在 PIE/游戏模式下有效，用于游戏逻辑

### 模式检测策略

- **`is_in_editor_mode()`**：在编辑器窗口（非 PIE）返回 true
- **`is_in_game_mode()`**：在 PIE/SE PIE 或运行时返回 true
- **组合使用**：可组合判断确定精确的运行环境

### 关卡管理

- **阻塞加载**：`b_should_block_on_load=True` 等待异步加载完成
- **可见性控制**：`b_should_visiblize=True` 自动显示新加载的关卡
- **包路径格式**：关卡路径格式为 `/Game/Maps/MapName.MapName` 或仅 `/Game/Maps/MapName`

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 返回 None | 所请求的世界类型不可用 | 检查当前运行环境（编辑器/游戏） |
| 关卡加载失败 | 路径无效或文件不存在 | 检查关卡路径与项目内容浏览器 |
| 实时模式设置失败 | 关卡未激活或环境不支持 | 确保在编辑器环境中调用 |

### 上下文依赖

- **编辑器依赖**：`get_editor_world()` 与 `is_in_editor_mode()` 仅在编辑器上下文有效
- **运行时依赖**：`get_game_world()` 仅在 PIE/游戏模式有效
- **当前世界**：`get_current_world()` 在静态脚本中可能返回 None

### 最佳实践

- ✅ 先检测运行模式再选择合适的世界获取方法
- ✅ 关卡加载后验证返回值与关卡有效性
- ✅ 使用 `get_current_world()` 作为默认选择，提高工具通用性
- ✅ 记录当前世界名称用于调试与日志
- ❌ 不要在运行时代码中使用编辑器专属方法
- ❌ 不要假设世界 always 可用（特别是静态脚本）

## 总结

`LevelUtilsBlueprintLibrary` 是关卡与世界管理的核心工具库，提供世界获取、模式检测与关卡控制功能。它在编辑器工具、运行时关卡管理与条件性行为切换中广泛应用，适合需要根据运行环境动态调整行为的游戏系统。使用时需注意上下文依赖、模式检测与阻塞/异步加载策略。
