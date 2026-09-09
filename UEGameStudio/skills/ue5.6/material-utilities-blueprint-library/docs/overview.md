---
title: MaterialUtilitiesBlueprintLibrary - 材质工具库
category: UE5.6 Blueprint Libraries
---

# MaterialUtilitiesBlueprintLibrary 概述

## 功能概述

`UMaterialUtilitiesBlueprintLibrary` 提供材质参数的查询与设置功能，支持标量、向量、纹理与静态开关参数的读取与修改。与 `KismetMaterialLibrary` 不同，它主要针对 `UMaterialInterface`（包括 `UMaterial` 与 `UMaterialInstance`）的参数查询，而设置操作需作用于 `UMaterialInstance`。

## 核心用途与场景

- **参数查询**：在运行时或编辑器中查询材质当前参数值（如当前不透明度、颜色 tint）
- **材质实例修改**：通过 `UMaterialInstance` 参数重写实现材质个性化
- **批量材质检查**：枚举材质所有参数名或特定类型参数名
- **编辑器工具集成**：在 Editor Utility Widget 中显示与修改材质参数

## 更多使用示例

### 材质参数审计

```python
import unreal

api = unreal.MaterialUtilitiesBlueprintLibrary

# 加载材质
material = unreal.load_asset("/Game/Materials/M_Character")
if not material:
    unreal.log_error("Material not found")
    raise SystemExit(1)

# 枚举所有参数名
all_params = api.get_all_parameter_names(material)
print(f"Total parameters: {len(all_params)}")

# 按类型分类
scalar_names = api.get_scalar_parameter_names(material)
vector_names = api.get_vector_parameter_names(material)
texture_names = api.get_texture_parameter_names(material)

print(f"Scalar: {scalar_names}")
print(f"Vector: {vector_names}")
print(f"Texture: {texture_names}")
```

### 材质实例参数修改

```python
# 修改材质实例参数
material_instance = unreal.load_asset("/Game/Materials/M_Character_MI")
if isinstance(material_instance, unreal.MaterialInstance):
    # 标量参数
    current_opacity = api.get_scalar_parameter_value(material_instance, "Opacity")
    api.set_scalar_parameter_value(material_instance, "Opacity", 0.8)
    
    # 向量参数
    current_tint = api.get_vector_parameter_value(material_instance, "Tint")
    api.set_vector_parameter_value(material_instance, "Tint", 
        unreal.LinearColor(1.0, 0.5, 0.5, 1.0))
    
    # 保存材质实例（编辑器模式）
    unreal.EditorAssetLibrary.save_asset(material_instance.get_path_name())
```

### 材质参数检查与验证

```python
# 验证材质是否包含特定参数
def has_parameter(material, param_name):
    all_names = api.get_all_parameter_names(material)
    return param_name in all_names

# 过滤出包含特定参数的材质
materials_to_check = [mat1, mat2, mat3]
for mat in materials_to_check:
    if has_parameter(mat, "BaseColor"):
        print(f"{mat.get_name()} has BaseColor parameter")
```

## 高级用法与最佳实践

### 参数分类管理

- **标量参数**：`float` 类型，用于控制不透明度、粗糙度、金属度等
- **向量参数**：`LinearColor` 类型，用于颜色、tint、自发光强度等
- **纹理参数**：`UTexture` 指针，用于动态替换贴图
- **静态开关参数**：`bool` 类型，控制材质特性开关（如是否使用法线贴图）

### 编辑器 vs 运行时

- **Editor Only 方法**：带 `EditorOnly` 后缀的方法仅在编辑器 Python 环境可用
- **运行时限制**：发布版本中无法使用编辑器专属方法
- **类型检查**：设置方法仅对 `UMaterialInstance` 有效，基类 `UMaterial` 不支持

### 批量操作策略

- **枚举优化**：`get_all_parameter_names()` 一次性获取所有参数名，避免多次调用
- **类型过滤**：使用分类方法（`get_scalar_parameter_names`）减少遍历开销
- **缓存结果**：参数枚举为 O(n) 操作，频繁查询时考虑缓存结果

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 返回 0 / None | 参数不存在或材质无效 | 检查参数名与材质有效性 |
| set_* 方法无效果 | 材质类型错误（需 `UMaterialInstance`） | 使用 `isinstance` 检查类型 |
| EditorOnly 方法失效 | 在运行时环境调用 | 确保在编辑器 Python 中执行 |

### 材质类型

- **UMaterial**：基类材质，不支持参数重写
- **UMaterialInstanceConstant**：静态材质实例，支持参数重写
- **UMaterialInstanceDynamic**：运行时动态材质，支持参数重写

### 最佳实践

- ✅ 先枚举参数名再查询/设置，避免无效参数名
- ✅ 设置前验证材质实例类型
- ✅ 编辑器中修改后调用 `save_asset` 持久化
- ✅ 使用 `get_all_parameter_names()` 进行材质审计
- ❌ 不要在运行时调用 EditorOnly 方法
- ❌ 不要对基类 `UMaterial` 调用设置方法（无效果）

## 总结

`MaterialUtilitiesBlueprintLibrary` 是材质参数查询与修改的实用工具库，支持标量、向量、纹理与静态开关参数的完整操作。它在材质审计、实例修改与编辑器工具集成中广泛应用，适合需要动态材质效果或材质参数管理的游戏系统。使用时需注意材质类型差异、Editor Only 限制与批量操作策略。
