---
title: UnrealEditorSubsystem - 编辑器子系统
category: UE5.6 Editor Subsystems
---

# UnrealEditorSubsystem 概述

## 功能概述

`UUnrealEditorSubsystem` 是 UE 5.6 引擎提供的编辑器子系统，提供编辑器主世界与关卡视口的原语级操作。它是获取编辑器上下文世界、控制主关卡编辑器视口相机位姿的核心入口。

## 核心用途与场景

- **编辑器世界获取**：获取编辑器上下文的世界对象，作为各类编辑器脚本（生成、查询、修改）的起点
- **视口相机控制**：读取或设置主关卡编辑器视口的相机位置与旋转，用于视角预设与自动化视角切换
- **游戏世界获取**：在编辑器内获取当前 PIE/游戏世界，用于编辑器模式与游戏模式的切换
- **编辑器自动化脚本**：作为编辑器自动化、批处理与工具开发的基础入口

## 更多使用示例

### 编辑器脚本上下文

```python
import unreal

# 获取编辑器子系统
api = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
if api is None:
    unreal.log_error("UnrealEditorSubsystem not available!")
    raise SystemExit(1)

# 获取编辑器世界（最常用的入口）
world = api.get_editor_world()
if world is None:
    unreal.log_error("Editor world not available!")
    raise SystemExit(1)

unreal.log(f"Editor world: {world.get_name()}")

# 在编辑器世界中执行操作
actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)
unreal.log(f"Total actors in editor: {len(actors)}")
```

### 视口相机预设

```python
# 保存与加载相机位姿
camera_presets = {}

def save_viewport_preset(name):
    ok, loc, rot = api.get_level_viewport_camera_info()
    if not ok:
        unreal.log_error("Failed to get viewport camera")
        return
    
    camera_presets[name] = (loc, rot)
    unreal.log(f"Saved viewport preset: {name}")

def load_viewport_preset(name):
    if name not in camera_presets:
        unreal.log_error(f"Unknown preset: {name}")
        return
    
    loc, rot = camera_presets[name]
    api.set_level_viewport_camera_info(loc, rot)
    unreal.log(f"Loaded viewport preset: {name}")

# 使用示例
save_viewport_preset("top_down")
save_viewport_preset("isometric")
load_viewport_preset("top_down")
```

### 编辑器/游戏世界切换

```python
# 检测当前是否在 PIE 模式
if api.get_game_world() is not None:
    unreal.log("PIE mode active - using game world")
    game_world = api.get_game_world()
    # 在游戏世界中执行操作
else:
    unreal.log("Editor mode - using editor world")
    editor_world = api.get_editor_world()
    # 在编辑器世界中执行操作
```

## 高级用法与最佳实践

### 编辑器世界使用策略

- **最常用入口**：`get_editor_world()` 是各类编辑器脚本最常用的世界来源
- **安全检查**：调用前检查返回值是否为 None，非编辑器上下文会返回 None
- **类型验证**：编辑器世界类型为 `UWorld`，可直接用于各类 Editor API

### 视口相机控制

- **读取安全**：`get_level_viewport_camera_info()` 返回 `(bool, Vector, Rotator)` 元组，`bool` 表示是否成功
- **设置无返回**：`set_level_viewport_camera_info()` 设置后立即生效，无返回值
- **非编辑器构建**：在非编辑器构建中，视口相机操作返回零化值与 False

### 性能与性能考虑

- **低开销操作**：相机读写为低开销操作，可频繁调用（如每帧更新）
- **批量调整**：建议在批量视口调整后一次性更新 UI，减少视觉闪烁
- **动画插值**：如需平滑过渡，可在脚本中实现插值逻辑，逐步更新相机位置

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 子系统返回 None | 非编辑器上下文或编辑器未初始化 | 确保在 UE Editor 的 Python 环境执行 |
| `get_editor_world()` 返回 None | 编辑器世界不可用（如在后台脚本执行） | 检查脚本执行上下文 |
| 视口相机读取失败 | 主关卡编辑器视口不可用或已关闭 | 检查视口状态与编辑器窗口可见性 |

### 上下文依赖

- **编辑器专用**：本子系统仅在 UE Editor 内可用，运行时构建中完全不可用
- **PIE/SE PIE 差异**：PIE 模式下 `get_game_world()` 返回游戏世界，`get_editor_world()` 仍返回编辑器世界
- **子系统获取**：使用 `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)` 方法获取

### 最佳实践

- ✅ 所有编辑器脚本开始处检查子系统与世界有效性
- ✅ 使用 `get_editor_world()` 作为编辑器脚本的标准入口
- ✅ 保存与加载相机预设时记录完整的 Vector/Rotator
- ✅ 记录编辑器世界名称用于调试
- ❌ 不要在运行时代码中调用
- ❌ 不要假设编辑器视口总是打开（可能被最小化或隐藏）

## 总结

`UnrealEditorSubsystem` 是编辑器自动化与工具开发的核心入口，提供编辑器上下文世界与视口相机的原语级操作。它在编辑器脚本、批处理工具、自动化视角控制等场景中广泛应用，适合需要深度编辑器集成的游戏开发工具。使用时需注意编辑器上下文依赖、世界类型差异与错误处理策略。
