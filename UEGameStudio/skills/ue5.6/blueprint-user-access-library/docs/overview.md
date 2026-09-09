---
title: BlueprintUserAccessLibrary - 用户访问控制库
category: UE5.6 Blueprint Libraries
---

# BlueprintUserAccessLibrary 概述

## 功能概述

`UBlueprintUserAccessLibrary` 提供运行时用户角色识别与访问权限查询功能。通过分析 `ULocalPlayer` 对象，可以区分玩家（Player）、编辑器（Editor）与脚本（Script）三种用户类型，为权限控制、调试功能与调试模式提供运行时支持。

## 核心用途与场景

- **差异化调试模式**：在编辑器内运行时启用高级调试功能，纯运行时构建中禁用
- **权限控制**：根据用户类型启用不同的功能集（如开发工具、隐藏调试菜单）
- **自动化测试**：在脚本模式下启用特殊测试行为或跳过需要人工交互的流程
- **日志与追踪**：为不同用户类型输出差异化的日志级别与追踪信息

## 更多使用示例

### 调试模式自动切换

```python
import unreal

api = unreal.BlueprintUserAccessLibrary

# 获取当前玩家列表
local_players = unreal.get_engine_subsystem(unreal.LocalPlayerSubsystem).get_local_players()

for lp in local_players:
    user_type = api.get_user_type(lp)
    player_name = lp.get_player_controller().get_player_name() if lp.get_player_controller() else "Unknown"
    
    if user_type == unreal.EBlueprintUserAccessLibraryUserType.EDITOR:
        print(f"[DEBUG] Editor user '{player_name}' logged in - enabling debug features")
        # 启用调试 UI、详细日志、性能监控
    elif user_type == unreal.EBlueprintUserAccessLibraryUserType.PLAYER:
        print(f"[INFO] Player '{player_name}' logged in - standard mode")
        # 正常游戏模式，禁用调试功能
    elif user_type == unreal.EBlueprintUserAccessLibraryUserType.SCRIPT:
        print(f"[TEST] Script user '{player_name}' logged in - test mode")
        # 启用自动化测试模式
```

### 开发者控制台

```python
# 在编辑器内运行时，自动显示开发者控制台
if api.is_editor(local_player):
    print("Editor user - showing developer console")
    # 呈现开发者选项菜单、性能统计、内存浏览器
else:
    print("Standard user - no developer options")
```

### 条件性功能启用

```python
# 使用快捷方式快速判断用户类型
if api.is_editor(lp):
    # 仅在编辑器内启用的功能
    unreal.log("Enable debug hotkeys")
elif api.is_player(lp):
    # 运行时玩家功能
    unreal.log("Standard gameplay")
elif api.is_script(lp):
    # 自动化脚本功能
    unreal.log("Automation mode")
```

## 高级用法与最佳实践

### 多玩家环境管理

- **玩家集合处理**：`get_local_players()` 返回所有本地玩家，适合多玩家本地合作或测试场景
- **类型一致性**：同一进程内所有 `LocalPlayer` 应具有相同用户类型（除非特殊测试配置）
- **运行时切换**：PIE 进入游戏模式后，用户类型固定，不支持运行时切换

### 权限控制策略

- **分层权限**：`EDITOR > SCRIPT > PLAYER`（调试功能 > 自动化测试 > 正常玩家）
- **渐进式启用**：从基础玩家功能开始，根据用户类型动态启用更高级功能
- **构建配置检查**：在发布版本中，`is_editor()` 恒为 false，无需额外构建宏

### 与 CI/CD 集成

- **自动化测试标识**：脚本模式用于标识 CI/CD 环境的自动化测试运行
- **生产构建防护**：发布版本自动禁用编辑器与脚本模式的功能
- **日志过滤**：不同用户类型输出不同详细程度的日志，便于调试与生产环境管理

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| `get_user_type()` 返回默认值 | `LocalPlayer` 为 null 或失效 | 先通过 `LocalPlayerSubsystem` 获取有效列表 |
| `is_editor()` 恒为 false | 在非编辑器构建或 PIE 外运行 | 确保在编辑器内运行或 PIE 模式下测试 |
| 玩家名称为 None | `PlayerController` 尚未初始化 | 延迟到 `BeginPlay` 后获取 |

### 环境依赖

- **编辑器上下文**：`is_editor()` 仅在 UE Editor 内运行时有效（PIE/SE PIE），纯 Editor 窗口不触发
- **运行时构建**：`Editor=False` 的构建包中，`is_editor()` 恒为 false
- **脚本上下文**：Python 脚本（如 Editor Utility Script）运行时用户类型为 `SCRIPT`

### 最佳实践

- ✅ 先通过 `LocalPlayerSubsystem` 获取有效玩家列表再查询
- ✅ 使用 `is_editor/is_player/is_script` 快捷方法简化代码
- ✅ 在玩家切换或进入世界时重新检查用户类型
- ✅ 为不同用户类型提供明确的视觉或日志反馈
- ❌ 不要在 `BeginPlay` 前过度依赖用户类型判断
- ❌ 不要假设所有本地玩家类型一致（除非明确知道是单玩家）

## 总结

`BlueprintUserAccessLibrary` 是运行时用户角色识别的重要工具，通过 `ULocalPlayer` 分析区分玩家、编辑器与脚本三种使用场景。它为调试模式、权限控制与自动化测试提供运行时决策依据，适合需要差异化用户体验或测试支持的复杂游戏系统。使用时需注意不同运行环境（编辑器/运行时/构建）下的用户类型行为差异。
