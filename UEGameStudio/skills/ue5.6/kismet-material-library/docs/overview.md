---
title: KismetMaterialLibrary - 材质工具库
category: UE5.6 Kismet Libraries
---

# KismetMaterialLibrary 概述

## 功能概述

`UKismetMaterialLibrary` 提供材质参数的高级操作功能，包括读写 `UMaterialParameterCollection`（MPC）的全局标量与向量参数，以及创建 `UMaterialInstanceDynamic`（MID）运行时材质实例。它是材质系统与脚本/蓝图交互的核心接口。

## 核心用途与场景

- **全局材质参数管理**：通过 MPC 统一管理全局材质参数（如时间尺度、环境色调、天气效果）
- **运行时动态材质**：创建可修改的材质实例，实现个性化的材质效果（如角色装备自定义、环境变化）
- **批量材质更新**：在编辑器脚本中批量修改材质参数，用于构建预览或批量调整
- **条件性材质切换**：根据游戏状态或玩家选择动态调整材质参数

## 更多使用示例

### 全局环境控制

```python
import unreal

api = unreal.KismetMaterialLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

# 加载全局材质参数集合
mpc = unreal.load_asset("/Game/Materials/MPC_GlobalWeather")
if mpc:
    # 设置全局时间尺度
    api.set_scalar_parameter_value(world, mpc, "GlobalTimeScale", 0.5)
    
    # 设置环境色调
    api.set_vector_parameter_value(world, mpc, "GlobalTint", 
        unreal.LinearColor(0.8, 0.9, 1.0, 1.0))
    
    # 读取当前值验证
    time_scale = api.get_scalar_parameter_value(world, mpc, "GlobalTimeScale")
    print(f"Global time scale: {time_scale}")
```

### 装备系统动态材质

```python
# 为角色装备创建独特的材质
def customize_character_equip(character_mesh, equip_color):
    base_material = unreal.load_asset("/Game/Materials/M_Character")
    mid = api.create_dynamic_material_instance(world, base_material, 
        f"M_Char_Equip_{equip_color.get_hash_value()}")
    
    # 设置装备特有颜色
    mid.set_vector_parameter_value("EquipColor", equip_color)
    
    # 应用到角色
    character_mesh.set_material(0, mid)
    return mid

# 使用示例
weapon_color = unreal.LinearColor(0.2, 0.6, 0.9, 1.0)
custom_material = customize_character_equip(my_character_mesh, weapon_color)
```

### 批量材质调整

```python
# 批量调整关卡中所有指定材质的参数
actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)

for actor in actors:
    meshes = actor.get_components_by_class(unreal.StaticMeshComponent)
    for mesh in meshes:
        mat = mesh.get_material(0)
        if mat and mat.get_name().startswith("M_Building_"):
            # 批量设置参数
            if isinstance(mat, unreal.MaterialInstance):
                mat.set_scalar_parameter_value("WearLevel", 0.5)
```

## 高级用法与最佳实践

### MPC 参数组织

- **命名规范**：MPC 参数名建议使用层级命名（如 "Global Weather TimeScale"）便于管理
- **默认值管理**：MPC 默认值作为后备，实际运行时使用 `set_scalar_parameter_value` 覆盖
- **热重载支持**：修改 MPC 参数后，新值在下一帧生效，无需重新加载材质

### MID 创建策略

- **命名规范**：MID 名称建议包含父材质与用途信息（如 "M_Character_Tactical"）
- **生命周期管理**：MID 创建后需手动管理，避免内存泄漏；不使用的 MID 及时释放
- **重复使用**：相同配置的 MID 可以复用，避免重复创建

### 编辑器工作流

- **Build Cook Run 优化**：在构建前设置 MPC 参数，减少运行时动态材质创建
- **Material Editing Tool 集成**：编辑器脚本可批量调整参数，用于材质预览或版本控制
- **审计与追踪**：记录参数修改历史，便于调试与版本回溯

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 参数设置无效 | MPC 参数名不匹配或参数不存在 | 检查 MPC 资产内参数名与调用参数一致 |
| MID 创建失败 | 父材质无效或世界上下文缺失 | 验证 `load_asset` 返回值与世界上下文 |
| 返回 null / None | 材质或资产不存在 | 使用 `is None` 检查后继续操作 |

### 参数类型匹配

- **标量 vs 向量**：MPC 中定义的参数类型必须与调用方法匹配（`float` 用 `set_scalar`，`vector` 用 `set_vector`）
- **参数名大小写**：MPC 参数名区分大小写，必须完全匹配
- **默认值回退**：无效参数名返回 MPC 默认值而非错误

### 最佳实践

- ✅ 创建 MID 前验证父材质有效性
- ✅ 使用唯一命名避免 MID 冲突
- ✅ 修改 MPC 参数后验证读取值
- ✅ 记录参数修改用于调试
- ❌ 不要在循环中重复创建相同配置的 MID
- ❌ 不要在发布版本中大量动态创建 MID（考虑预创建或烘焙）

## 总结

`KismetMaterialLibrary` 是材质系统与脚本/蓝图交互的核心接口，支持 MPC 全局参数管理与 MID 运行时创建。它在环境控制、装备系统、批量调整等场景中广泛应用，适合需要动态材质效果或全局材质参数管理的游戏系统。使用时需注意参数类型匹配、MID 生命周期管理与构建优化策略。
