# KismetNodeHelperLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetNodeHelperLibrary.h` 整理 `UKismetNodeHelperLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的全部成员。全部为 static 函数且类声明为 BlueprintThreadSafe，Python 方法名由 C++ 函数名按反射约定转 snake_case；每个成员给出 C++ 签名、Python 参数、返回约定与完整示例；完整示例即调用样板。

## 通用约定

- 以 `unreal.KismetNodeHelperLibrary` 的类方法形式调用，无需实例：

```python
import unreal

api = unreal.KismetNodeHelperLibrary
```

- 位掩码以 int32 承载 N 个 bool 状态（bit 0 为最低位）。
- 返回约定：`void` + 单 ByRef 参数直接返回该参数新值；返回值 + Out 按元组返回；无 Out 无返回值则返回 `None`。
- `uint8` 返回在 Python 中为 `int`；FName 返回为 `unreal.Name`。
- 枚举参数为 `unreal.Enum` 对象，用 `unreal.load_object(None, "/Script/<Module>.<EnumName>")` 获取。
- 标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。

## 位掩码操作

### bit_is_marked

- C++ 签名：`static bool BitIsMarked(int32 Data, int32 Index)`
- Python：`bit_is_marked(data, index) -> bool`
- 说明：返回 `Data` 中 `Index` 位是否被置位。
- 示例：

```python
data = 0
data = api.mark_bit(data, 2)
print("bit2 set:", api.bit_is_marked(data, 2))
```

### mark_bit

- C++ 签名：`static void MarkBit(int32& Data, int32 Index)`
- Python：`mark_bit(data, index) -> int32`
- 说明：将 `Data` 的 `Index` 位置位；`void` + 单 ByRef 参数，直接返回更新后的掩码，必须用返回值。
- 示例：

```python
data = 0
data = api.mark_bit(data, 0)
data = api.mark_bit(data, 3)
print("mask:", data)
```

### clear_bit

- C++ 签名：`static void ClearBit(int32& Data, int32 Index)`
- Python：`clear_bit(data, index) -> int32`
- 说明：清除 `Data` 的 `Index` 位；直接返回更新后的掩码。
- 示例：

```python
data = api.clear_bit(data, 0)
print("bit0 cleared:", not api.bit_is_marked(data, 0))
```

### clear_all_bits

- C++ 签名：`static void ClearAllBits(int32& Data)`
- Python：`clear_all_bits(data) -> int32`
- 说明：清除全部位；直接返回更新后的掩码（0）。
- 示例：

```python
data = api.clear_all_bits(data)
print("mask:", data)
```

### has_unmarked_bit

- C++ 签名：`static bool HasUnmarkedBit(int32 Data, int32 NumBits)`
- Python：`has_unmarked_bit(data, num_bits) -> bool`
- 说明：在 `Data` 低 `NumBits` 位中是否存在未标记位。
- 示例：

```python
# 0~7 共 8 位，仅两个未用：bit1、bit2
partial = 0
partial = api.mark_bit(partial, 0)
partial = api.mark_bit(partial, 3)
print("has unmarked:", api.has_unmarked_bit(partial, 8))
```

### has_marked_bit

- C++ 签名：`static bool HasMarkedBit(int32 Data, int32 NumBits)`
- Python：`has_marked_bit(data, num_bits) -> bool`
- 说明：在 `Data` 低 `NumBits` 位中是否存在已标记位。
- 示例：

```python
print("has marked:", api.has_marked_bit(partial, 8))
```

### get_unmarked_bit

- C++ 签名：`static int32 GetUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits, bool bRandom)`
- Python：`get_unmarked_bit(data, start_idx, num_bits, b_random) -> int32`
- 说明：从 `StartIdx` 起查找一个未标记位返回其索引；`b_random` 为 `True` 时随机选择。无可用位返回 `INDEX_NONE`（-1）。
- 示例：

```python
slot = api.get_unmarked_bit(partial, 0, 8, False)
print("slot:", slot)
```

### get_random_unmarked_bit

- C++ 签名：`static int32 GetRandomUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits)`
- Python：`get_random_unmarked_bit(data, start_idx, num_bits) -> int32`
- 说明：随机选择一个未标记位返回其索引。无可用位返回 `INDEX_NONE`（-1）。
- 示例：

```python
slot = api.get_random_unmarked_bit(partial, 0, 8)
print("random slot:", slot)
```

### get_first_unmarked_bit

- C++ 签名：`static int32 GetFirstUnmarkedBit(int32 Data, int32 StartIdx, int32 NumBits)`
- Python：`get_first_unmarked_bit(data, start_idx, num_bits) -> int32`
- 说明：从 `StartIdx` 起查找首个未标记位返回其索引。无可用位返回 `INDEX_NONE`（-1）。
- 示例：

```python
first = api.get_first_unmarked_bit(partial, 0, 8)
print("first slot:", first)  # 预期 1
```

## 枚举辅助

### get_enumerator_name

- C++ 签名：`static FName GetEnumeratorName(const UEnum* Enum, uint8 EnumeratorValue)`（BlueprintPure）
- Python：`get_enumerator_name(enum, enumerator_value) -> Name`
- 说明：返回枚举值对应的枚举项名称；无效值返回 `NAME_None`。
- 示例：

```python
enum_obj = unreal.load_object(None, "/Script/Engine.EInputEvent")
if enum_obj is not None:
    name = api.get_enumerator_name(enum_obj, 1)
    print("item name:", name)
```

### get_enumerator_user_friendly_name

- C++ 签名：`static FString GetEnumeratorUserFriendlyName(const UEnum* Enum, uint8 EnumeratorValue)`（BlueprintPure）
- Python：`get_enumerator_user_friendly_name(enum, enumerator_value) -> str`
- 说明：返回枚举值对应的可读显示名称（DisplayName）。
- 示例：

```python
label = api.get_enumerator_user_friendly_name(enum_obj, 1)
print("friendly name:", label)
```

### get_valid_value

- C++ 签名：`static uint8 GetValidValue(const UEnum* Enum, uint8 EnumeratorValue)`（BlueprintPure）
- Python：`get_valid_value(enum, enumerator_value) -> int`
- 说明：校验枚举值；合法则原样返回，非法则返回该枚举的最大有效值。
- 示例：

```python
fixed = api.get_valid_value(enum_obj, 200)
print("valid value:", fixed)
```

### get_enumerator_value_from_index

- C++ 签名：`static uint8 GetEnumeratorValueFromIndex(const UEnum* Enum, uint8 EnumeratorIndex)`（BlueprintPure）
- Python：`get_enumerator_value_from_index(enum, enumerator_index) -> int`
- 说明：按枚举索引返回对应原始值；非法索引返回 `INDEX_NONE`（-1）。
- 示例：

```python
value = api.get_enumerator_value_from_index(enum_obj, 0)
print("value at index 0:", value)
```

## 完整示例：8 槽位分配器

```python
import unreal

def main():
    api = unreal.KismetNodeHelperLibrary

    num_slots = 8
    mask = 0
    assigned = []

    for _ in range(3):
        slot = api.get_first_unmarked_bit(mask, 0, num_slots)
        if slot == -1:
            print({"status": "BLOCKED_INPUT", "reason": "no slot available"})
            return
        mask = api.mark_bit(mask, slot)
        assigned.append(slot)

    mask = api.clear_bit(mask, assigned[1])

    enum_obj = unreal.load_object(None, "/Script/Engine.EInputEvent")
    item = None
    if enum_obj is not None:
        item = api.get_enumerator_user_friendly_name(enum_obj, 1)

    print({
        "status": "OK",
        "assigned": assigned,
        "freed": assigned[1],
        "mask": mask,
        "has_unmarked": api.has_unmarked_bit(mask, num_slots),
        "sample_enum_label": item,
    })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（枚举对象、无效槽位请求等）。
- `BLOCKED_TOOLING`：编辑器上下文不可用，无法执行。
- 全部成员为纯计算/只读查询，不修改关卡或资产；无写入后验收要求。
- 标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。