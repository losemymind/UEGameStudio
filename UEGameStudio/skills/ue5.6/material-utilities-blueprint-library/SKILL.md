---
name: material-utilities-blueprint-library
description: UMaterialUtilitiesBlueprintLibrary（UE 5.6）材质工具函数库 - 材质实例查询与参数设置、纹理通道混合；在 Agent 需要通过 unreal Python 操作材质实例或查询材质属性时使用
risk: safe
category: development
tags: [ue5.6, material, materials, blueprint-library, python]
---

# MaterialUtilitiesBlueprintLibrary - Material Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 操作材质实例或查询材质属性时使用本 skill（description 触发场景）。
- 本 skill 只在与 material-utilities-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UMaterialUtilitiesBlueprintLibrary` 暴露给 Python 的材质工具方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/MaterialUtilitiesBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.MaterialUtilitiesBlueprintLibrary` 上：

```python
import unreal

api = unreal.MaterialUtilitiesBlueprintLibrary

# 获取材质参数
material = unreal.load_asset("/Game/Materials/M_Test")
param = api.get_scalar_parameter_value(material, "Opacity")
print("opacity:", param)
```

- **命名约定**：Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无该 meta 的按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- **参数分类**：`Scalar`（标量）、`Vector`（向量）、`Texture`（纹理）、`Static Switch`（静态开关）等参数类型对应不同获取/设置方法。
- **材质实例**：`MaterialInstanceConstant` / `MaterialInstanceDynamic` 支持参数重写；基类材质（`UMaterial`）不支持。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 标量 | `get_scalar_parameter_value(material, param_name)` | `float GetScalarParameterValue(const UMaterialInterface*, const FName)` | `float` |
| 标量 | `set_scalar_parameter_value(material_instance, param_name, param_value)` | `void SetScalarParameterValue(UMaterialInstance*, const FName, float)` | `None` |
| 标量 | `get_scalar_parameter_value_editor_only(material, param_name)` | `float GetScalarParameterValueEditorOnly(const UMaterialInterface*, const FName)` | `float`（仅编辑器） |
| 向量 | `get_vector_parameter_value(material, param_name)` | `FLinearColor GetVectorParameterValue(const UMaterialInterface*, const FName)` | `LinearColor` |
| 向量 | `set_vector_parameter_value(material_instance, param_name, param_value)` | `void SetVectorParameterValue(UMaterialInstance*, const FName, const FLinearColor&)` | `None` |
| 向量 | `get_vector_parameter_value_editor_only(material, param_name)` | `FLinearColor GetVectorParameterValueEditorOnly(const UMaterialInterface*, const FName)` | `LinearColor`（仅编辑器） |
| 纹理 | `get_texture_parameter_value(material, param_name)` | `UTexture* GetTextureParameterValue(const UMaterialInterface*, const FName)` | `Texture` 或 `None` |
| 纹理 | `set_texture_parameter_value(material_instance, param_name, param_value)` | `void SetTextureParameterValue(UMaterialInstance*, const FName, UTexture*)` | `None` |
| 纹理 | `get_texture_parameter_value_editor_only(material, param_name)` | `UTexture* GetTextureParameterValueEditorOnly(const UMaterialInterface*, const FName)` | `Texture`（仅编辑器） |
| 开关 | `get_static_switch_parameter_value(material, param_name)` | `bool GetStaticSwitchParameterValue(const UMaterialInterface*, const FName, bool& bIsOverride)` | `Tuple[bool, bool]` |
| 开关 | `set_static_switch_parameter_value(material_instance, param_name, param_value, b_override)` | `void SetStaticSwitchParameterValue(UMaterialInstance*, const FName, bool, bool)` | `None` |
| 开关 | `get_static_switch_parameter_value_editor_only(material, param_name)` | `bool GetStaticSwitchParameterValueEditorOnly(const UMaterialInterface*, const FName)` | `bool`（仅编辑器） |
| 名称 | `get_all_parameter_names(material)` | `TArray<FName> GetAllParameterNames(const UMaterialInterface*)` | `Array[Name]` |
| 名称 | `get_scalar_parameter_names(material)` | `TArray<FName> GetScalarParameterNames(const UMaterialInterface*)` | `Array[Name]` |
| 名称 | `get_vector_parameter_names(material)` | `TArray<FName> GetVectorParameterNames(const UMaterialInterface*)` | `Array[Name]` |
| 名称 | `get_texture_parameter_names(material)` | `TArray<FName> GetTextureParameterNames(const UMaterialInterface*)` | `Array[Name]` |
| 名称 | `get_static_switch_parameter_names(material)` | `TArray<FName> GetStaticSwitchParameterNames(const UMaterialInterface*)` | `Array[Name]` |

## 示例

```python
import unreal

api = unreal.MaterialUtilitiesBlueprintLibrary

# 加载材质实例
material = unreal.load_asset("/Game/Materials/M_Test_MI")
if not material or not isinstance(material, unreal.MaterialInstance):
    print("BLOCKED_INPUT: material not found or not a MaterialInstance")
    raise SystemExit(1)

# 获取所有参数名
all_names = api.get_all_parameter_names(material)
print("all params:", all_names)

# 标量参数
opacity = api.get_scalar_parameter_value(material, "Opacity")
api.set_scalar_parameter_value(material, "Opacity", 0.5)

# 向量参数
tint = api.get_vector_parameter_value(material, "Tint")
api.set_vector_parameter_value(material, "Tint", unreal.LinearColor(1.0, 0.5, 0.5, 1.0))

# 纹理参数
base_texture = api.get_texture_parameter_value(material, "BaseColor")
print("base texture:", base_texture.get_name() if base_texture else None)

# 保存材质实例（Editor Only）
# unreal.EditorAssetLibrary.save_asset(material.get_path_name())
```

## 限制和注意事项

- `get_*_parameter_value` 适用于任何 `UMaterialInterface`；`set_*_parameter_value` 仅适用于 `UMaterialInstance`（`MaterialInstanceConstant` / `Dynamic`）。
- Editor Only 方法（带 `EditorOnly` 后缀）只在编辑器 Python 可用；运行时环境调用返回 `None` 或失败。
- `get_static_switch_parameter_value` 返回 `(value, is_override)` 元组；`set_static_switch_parameter_value` 的 `b_override` 决定是否覆盖基类设置。
- 修改 `MaterialInstance` 参数后需调用 `unreal.EditorAssetLibrary.save_asset` 持久化到磁盘；DLC Cook 前需确认参数重写状态。
- 缺材质路径、参数名等必要输入返回 `BLOCKED_INPUT`；无编辑器/引擎上下文返回 `BLOCKED_TOOLING`。
- 本库为查询与设置工具，不修改材质源资产（`UMaterial`），仅为 `UMaterialInstance` 参数重写的便捷入口。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
