---
name: kismet-node-helper-library
description: UKismetNodeHelperLibrary（UE 5.6）状态位/枚举辅助原语 - int32 位掩码的标记/清除/查找与状态枚举名称查询；在 Agent 需要通过 unreal Python 处理位掩码或查询枚举信息时使用
tags: [ue5.6, kismet, enum, bitmask, python]
---

# KismetNodeHelperLibrary - 位掩码与枚举辅助 Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetNodeHelperLibrary` 暴露给 Python 的位掩码与状态枚举辅助方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetNodeHelperLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理。全部成员为 static 函数且类声明为 BlueprintThreadSafe。

## 入口说明

本类全部为 static 函数，以类方法形式调用，无需实例：

```python
import unreal
api = unreal.KismetNodeHelperLibrary
```

- 无 `meta=(ScriptMethod=...)` 成员，Python 方法名按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- 位掩码以 int32 承载 N 个 bool 状态；枚举参数为 `unreal.Enum` 对象。
- `void` + 单 ByRef 参数的方法直接返回该参数新值。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 位掩码 | `bit_is_marked(data, index)` | `bool BitIsMarked(int32 Data, int32 Index)` | `bool` |
| 位掩码 | `mark_bit(data, index)` | `void MarkBit(int32& Data, int32 Index)` | `int32` |
| 位掩码 | `clear_bit(data, index)` | `void ClearBit(int32& Data, int32 Index)` | `int32` |
| 位掩码 | `clear_all_bits(data)` | `void ClearAllBits(int32& Data)` | `int32` |
| 位掩码 | `has_unmarked_bit(data, num_bits)` | `bool HasUnmarkedBit(int32 Data, int32 NumBits)` | `bool` |
| 位掩码 | `has_marked_bit(data, num_bits)` | `bool HasMarkedBit(int32 Data, int32 NumBits)` | `bool` |
| 位掩码 | `get_unmarked_bit(data, start_idx, num_bits, b_random)` | `int32 GetUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits, bool bRandom)` | `int32` |
| 位掩码 | `get_random_unmarked_bit(data, start_idx, num_bits)` | `int32 GetRandomUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits)` | `int32` |
| 位掩码 | `get_first_unmarked_bit(data, start_idx, num_bits)` | `int32 GetFirstUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits)` | `int32` |
| 枚举 | `get_enumerator_name(enum, enumerator_value)` | `FName GetEnumeratorName(const UEnum*, uint8 EnumeratorValue)` | `Name` |
| 枚举 | `get_enumerator_user_friendly_name(enum, enumerator_value)` | `FString GetEnumeratorUserFriendlyName(const UEnum*, uint8 EnumeratorValue)` | `str` |
| 枚举 | `get_valid_value(enum, enumerator_value)` | `uint8 GetValidValue(const UEnum*, uint8 EnumeratorValue)` | `int` |
| 枚举 | `get_enumerator_value_from_index(enum, enumerator_index)` | `uint8 GetEnumeratorValueFromIndex(const UEnum*, uint8 EnumeratorIndex)` | `int` |

## 快速示例

```python
import unreal

api = unreal.KismetNodeHelperLibrary

data = 0
data = api.mark_bit(data, 0)
data = api.mark_bit(data, 2)
print("bit0:", api.bit_is_marked(data, 0))
print("bit1:", api.bit_is_marked(data, 1))
print("first unmarked:", api.get_first_unmarked_bit(data, 0, 8))

enum_obj = unreal.load_object(None, "/Script/Engine.EInputEvent")
if enum_obj is not None:
    print("name:", api.get_enumerator_name(enum_obj, 1))
```

## 注意事项

- `mark_bit` / `clear_bit` / `clear_all_bits` 修改掩码值，`void` + 单 ByRef 参数直接返回更新后的 int32，需用返回值继续后续运算。
- 查找类方法在无未标记位可用时返回 `INDEX_NONE`（-1）；`get_enumerator_name` 对无效枚举值返回 `NAME_None`。
- 枚举辅助接收 `unreal.Enum` 对象，枚举值按原始值（uint8）传入。
- 全部成员为纯计算/只读查询，不修改关卡或资产，可在编辑器脚本中安全调用。
- 缺少必要输入时返回 `BLOCKED_INPUT`；编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。