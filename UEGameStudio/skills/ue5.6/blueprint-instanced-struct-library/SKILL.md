---
name: blueprint-instanced-struct-library
description: UBlueprintInstancedStructLibrary（UE 5.6）Instanced Struct 原语 - 重置/校验/比较 InstancedStruct；在 Agent 需要通过 unreal Python 创建、检查或比较 Instanced Struct 时使用
tags: [ue5.6, blueprint, instanced-struct, python]
---

# BlueprintInstancedStructLibrary - Instanced Struct Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UBlueprintInstancedStructLibrary` 暴露给 Python 的 Instanced Struct 操作方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintInstancedStructLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的普通成员整理。

## 入口说明

本类全部为 static 函数，以类方法形式调用，无需实例：

```python
import unreal
api = unreal.BlueprintInstancedStructLibrary
```

- Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无该 meta 的按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- 依赖编译器泛型展开的成员不在本 skill 范围内，不做调用断言。
- 参数与结果类型为 `unreal.InstancedStruct`；状态结果类型为 `unreal.EStructUtilsResult`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 重置 | `reset(instanced_struct, struct_type=None)` | `void Reset(FInstancedStruct&, const UScriptStruct* = nullptr)` | `InstancedStruct` |
| 校验 | `is_instanced_struct_valid(instanced_struct)` | `EStructUtilsResult IsInstancedStructValid(const FInstancedStruct&)` | `EStructUtilsResult` |
| 比较 | `equal_equal_instanced_struct(a, b)` | `bool EqualEqual_InstancedStruct(const FInstancedStruct&, const FInstancedStruct&)` | `bool` |
| 比较 | `not_equal_instanced_struct(a, b)` | `bool NotEqual_InstancedStruct(const FInstancedStruct&, const FInstancedStruct&)` | `bool` |
| 校验 | `is_valid_instanced_struct(instanced_struct)` | `bool IsValid_InstancedStruct(const FInstancedStruct&)` | `bool` |

## 快速示例

```python
import unreal

api = unreal.BlueprintInstancedStructLibrary

holder = unreal.load_asset("/Game/Blueprints/BP_ItemDB")
if holder is None:
    print("BLOCKED_INPUT: asset not found")
else:
    config = holder.get_editor_property("instanced_config")  # 类型为 unreal.InstancedStruct
    print("valid:", api.is_valid_instanced_struct(config))

    reset_config = api.reset(config)  # 重置为空结构，直接返回新值
    print("reset valid:", api.is_valid_instanced_struct(reset_config))

    print("equal:", api.equal_equal_instanced_struct(config, reset_config))
```

## 注意事项

- 只操作 `unreal.InstancedStruct` 对象；`void` + 单 ByRef 参数的方法直接返回该参数的新值。
- `is_instanced_struct_valid` 返回 `unreal.EStructUtilsResult`，具体取值按目标编辑器实测确认。
- `reset` 修改结构内容，属内容修改：写入后须经编辑器保存并由审计/QA 独立验收。
- 比较与校验为只读操作，可直接执行。
- 缺少必要输入时返回 `BLOCKED_INPUT`；编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。