---
name: kismet-material-library
description: UKismetMaterialLibrary（UE 5.6，unreal.KismetMaterialLibrary）材质参数公共函数库 - 读写 UMaterialParameterCollection（MPC）标量/向量参数、创建动态材质实例（MID）；在 Agent 需要通过 unreal Python 读取或修改材质全局参数、生成运行时材质实例时使用
risk: safe
category: development
tags: [ue5.6, material, blueprint, python, library]
---

# KismetMaterialLibrary - Material Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 读取或修改材质全局参数、生成运行时材质实例时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-material-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetMaterialLibrary`（`UBlueprintFunctionLibrary` 派生）暴露给 Python 的材质参数函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetMaterialLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.KismetMaterialLibrary` 上，直接以类名调用，无需实例。多数方法需要 `WorldContextObject` 参数：

```python
import unreal

api = unreal.KismetMaterialLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

api.set_scalar_parameter_value(world, mpc, "GlobalTimeScale", 1.5)
```

- **命名约定**：本库头文件成员未携带 `ScriptMethod`/`ScriptName` 脚本化名称，方法名统一按 C++ 函数名转 snake_case（`SetScalarParameterValue` → `set_scalar_parameter_value`、`GetVectorParameterValue` → `get_vector_parameter_value`）。精确 Python 暴露名需实测确认。
- **类名**：取 C++ 类名去 `U` 前缀（`unreal.KismetMaterialLibrary`），不采用类级 `ScriptName` 别名；实测时以 `dir(unreal)` / 反射结果为准。
- `Collection` 参数为 `unreal.MaterialParameterCollection` 实例（`unreal.load_asset("/Game/.../MPC_Name")` 加载）。
- 向量值类型为 `unreal.LinearColor(R, G, B, A)`，标量/颜色参数名传字符串。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 写入 | `set_scalar_parameter_value(world_context_object, collection, parameter_name, parameter_value)` | `void SetScalarParameterValue(UObject* WorldContextObject, UMaterialParameterCollection* Collection, FName ParameterName, float ParameterValue)` | `None` |
| 写入 | `set_vector_parameter_value(world_context_object, collection, parameter_name, parameter_value)` | `void SetVectorParameterValue(UObject* WorldContextObject, UMaterialParameterCollection* Collection, FName ParameterName, const FLinearColor& ParameterValue)` | `None` |
| 读取 | `get_scalar_parameter_value(world_context_object, collection, parameter_name)` | `float GetScalarParameterValue(UObject* WorldContextObject, UMaterialParameterCollection* Collection, FName ParameterName)` | `float` |
| 读取 | `get_vector_parameter_value(world_context_object, collection, parameter_name)` | `FLinearColor GetVectorParameterValue(UObject* WorldContextObject, UMaterialParameterCollection* Collection, FName ParameterName)` | `LinearColor` |
| 实例 | `create_dynamic_material_instance(world_context_object, parent, optional_name="None", creation_flags=unreal.MIDCreationFlags.NONE)` | `UMaterialInstanceDynamic* CreateDynamicMaterialInstance(UObject* WorldContextObject, UMaterialInterface* Parent, FName OptionalName, EMIDCreationFlags CreationFlags)` | `MaterialInstanceDynamic` |

## 示例

```python
import unreal

api = unreal.KismetMaterialLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

mpc = unreal.load_asset("/Game/Materials/MPC_Global")
if mpc is None:
    print({"status": "BLOCKED_INPUT", "reason": "MPC 资产未找到"})

# 写读标量参数
api.set_scalar_parameter_value(world, mpc, "GlobalTimeScale", 1.5)
speed = api.get_scalar_parameter_value(world, mpc, "GlobalTimeScale")

# 写读向量参数
api.set_vector_parameter_value(world, mpc, "GlobalTint", unreal.LinearColor(0.2, 0.4, 0.8, 1.0))
tint = api.get_vector_parameter_value(world, mpc, "GlobalTint")

# 创建运行时动态材质实例
base_mat = unreal.load_asset("/Game/Materials/M_Character")
mid = api.create_dynamic_material_instance(world, base_mat, "M_Character_Dyn")

# 通过 MID 实例自身的 set_*_parameter_value 修改材质实例参数
mid.set_scalar_parameter_value("EmissiveStrength", 3.0)
```

## 限制和注意事项

- 本库读写的是 `UMaterialParameterCollection`（MPC 全局参数实例），不是单个材质实例资产；`parameter_name` 必须与 MPC 资产内定义的参数名一致，无效参数名引擎记录日志、读取返回默认值，先按 `BLOCKED_INPUT` 补齐。
- `create_dynamic_material_instance` 在运行时生成可修改的 `UMaterialInstanceDynamic`；`optional_name` 传 `"None"` 即 `NAME_None`；`creation_flags` 为位域枚举 `unreal.MIDCreationFlags`（`NONE`/`TRANSIENT`），默认 `NONE`。精确枚举暴露名需实测确认。
- `WorldContextObject` 缺省时传编辑器主世界；无世界上下文时按 `BLOCKED_INPUT` 处理。
- 材质参数与材质系统职责归 `ue-technical-art-engineer`；本 skill 只提供 Python 调用 API，负责把参数改动落到对应材质资产与资产保存流程。
- 无编辑器/引擎上下文时按 `BLOCKED_TOOLING` 处理。本库写入会改变运行时参数状态，落盘型修改（保存 MPC/MID 资产）必须经编辑器接口与审计确认。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；`dir(unreal.KismetMaterialLibrary)` 实测命名后再落脚本。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。