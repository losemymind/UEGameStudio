---
name: kismet-string-library
description: UKismetStringLibrary（UE 5.6）字符串函数库 - 字符串转换/构造/连接/比较/搜索/截取/大小写/填充/替换/拆分/正则通配/拆分与时间格式化；在 Agent 需要通过 unreal Python 处理字符串的转换、解析、查找、替换与格式化时使用
risk: safe
category: development
tags: [ue5.6, kismet, string, python, blueprint-function-library]
---

# KismetStringLibrary - String Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 处理字符串的转换、解析、查找、替换与格式化时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-string-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetStringLibrary`（`UBlueprintFunctionLibrary` 派生）暴露给 Python 的字符串静态函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetStringLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 77 个 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.KismetStringLibrary` 上，直接以类名调用：

```python
import unreal

n = unreal.KismetStringLibrary.len("Hello")
upper = unreal.KismetStringLibrary.to_upper("hello")
join = unreal.KismetStringLibrary.join_string_array(["a", "b"], ",")
```

- **命名约定**：本库方法均无 `meta=(ScriptMethod=...)`，Python 方法名按 C++ 函数名转 snake_case（如 `Len` → `len`、`Conv_DoubleToString` → `conv_double_to_string`、`EqualEqual_StrStr` → `equal_equal_str_str`）。`len`、`left`、`right`、`mid`、`replace`、`reverse`、`split`、`trim`、`contains`、`is_numeric` 等名称可能与内置函数/习惯用法撞名，调用时一律使用 `unreal.KismetStringLibrary.<name>` 限定。
- **精确 Python 暴露名需实测确认**：`len` 作为方法名需在目标 UE 5.6 Editor 用 `dir(unreal.KismetStringLibrary)` 核对。
- 带 Out/ByRef 参数的方法按返回约定处理：`Conv_StringToVector` 返回 `(Vector, bool)`；`Conv_StringToRotator` 返回 `(Rotator, bool)`；`Split` 返回 `(bool, str, str)`；`CullArray` 返回剩余个数 `int`。
- `DiffString` 位于 `#if WITH_EDITOR` 段，仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 转换 | `conv_double_to_string(d)` | `FString Conv_DoubleToString(double)` | `str` |
| 转换 | `conv_int_to_string(n)` / `conv_int64_to_string(n)` | `FString Conv_IntToString(int32)/Conv_Int64ToString(int64)` | `str` |
| 转换 | `conv_byte_to_string(b)` / `conv_bool_to_string(b)` | `FString Conv_ByteToString(uint8)/Conv_BoolToString(bool)` | `str` |
| 转换 | `conv_vector_to_string(v)` | `FString Conv_VectorToString(FVector)`（`X= Y= Z=` 形式） | `str` |
| 转换 | `conv_vector3f_to_string(v)` / `conv_int_vector_to_string(v)` / `conv_int_vector2_to_string(v)` / `conv_int_point_to_string(v)` / `conv_vector2d_to_string(v)` | `FString Conv_Vector3f/IntVector/IntVector2/IntPoint/Vector2dToString(...)` | `str` |
| 转换 | `conv_rotator_to_string(r)` | `FString Conv_RotatorToString(FRotator)`（`P= Y= R=`） | `str` |
| 转换 | `conv_transform_to_string(t)` | `FString Conv_TransformToString(const FTransform&)` | `str` |
| 转换 | `conv_object_to_string(obj)` | `FString Conv_ObjectToString(class UObject*)`（对象名） | `str` |
| 转换 | `conv_box_to_string(box)` / `conv_box_center_and_extents_to_string(box)` | `FString Conv_BoxToString/Conv_BoxCenterAndExtentsToString(const FBox&)` | `str` |
| 转换 | `conv_input_device_id_to_string(id)` / `conv_platform_user_id_to_string(id)` | `FString Conv_InputDeviceIdToString(FInputDeviceId)/Conv_PlatformUserIdToString(FPlatformUserId)` | `str` |
| 转换 | `conv_color_to_string(c)` | `FString Conv_ColorToString(FLinearColor)`（`(R=,G=,B=,A=)`） | `str` |
| 转换 | `conv_name_to_string(name)` / `conv_matrix_to_string(m)` | `FString Conv_NameToString(FName)/Conv_MatrixToString(const FMatrix&)` | `str` |
| 解析 | `conv_string_to_name(s)` | `FName Conv_StringToName(const FString&)` | `str`（Name） |
| 解析 | `conv_string_to_int(s)` / `conv_string_to_int64(s)` / `conv_string_to_double(s)` | `int32/int64/double Conv_StringToInt/Int64/Double(const FString&)` | `int` / `int` / `float` |
| 解析 | `conv_string_to_vector(s)` | `void Conv_StringToVector(const FString&, FVector&, bool& OutIsValid)` | `(Vector, bool)` |
| 解析 | `conv_string_to_vector3f(s)` / `conv_string_to_vector2d(s)` / `conv_string_to_rotator(s)` / `conv_string_to_color(s)` | `void Conv_StringToVector3f/Vector2D/Rotator/Color(...)` | `(Vector3f/Vector2D/Rotator/LinearColor, bool)` |
| 构造 | `build_string_double(append_to, prefix, in_double, suffix)` | `FString BuildString_Double(const FString&, const FString&, double, const FString&)` | `str` |
| 构造 | `build_string_int(append_to, prefix, in_int, suffix)` | `FString BuildString_Int(...)` | `str` |
| 构造 | `build_string_bool(append_to, prefix, in_bool, suffix)` | `FString BuildString_Bool(...)` | `str` |
| 构造 | `build_string_vector(append_to, prefix, in_vector, suffix)` | `FString BuildString_Vector(...)` | `str` |
| 构造 | `build_string_int_vector(...)` / `build_string_int_vector2(...)` / `build_string_vector2d(...)` / `build_string_rotator(...)` / `build_string_object(...)` / `build_string_color(...)` / `build_string_name(...)` | `FString BuildString_IntVector/IntVector2/Vector2d/Rotator/Object/Color/Name(...)` | `str` |
| 连接 | `concat_str_str(a, b)` | `FString Concat_StrStr(const FString&, const FString&)` | `str` |
| 比较 | `equal_equal_str_str(a, b)` | `bool EqualEqual_StrStr(const FString&, const FString&)`（精确） | `bool` |
| 比较 | `equal_equal_stri_stri(a, b)` | `bool EqualEqual_StriStri(...)`（忽略大小写） | `bool` |
| 比较 | `not_equal_str_str(a, b)` / `not_equal_stri_stri(a, b)` | `bool NotEqual_StrStr/StriStri(...)` | `bool` |
| 度量 | `len(s)` | `int32 Len(const FString&)` | `int` |
| 度量 | `is_empty(s)` | `bool IsEmpty(const FString&)` | `bool` |
| 搜索 | `find_substring(search_in, substring, b_use_case=False, b_search_from_end=False, start_position=-1)` | `int32 FindSubstring(...)` | `int`（找不到返回 -1 附近；以实测为准） |
| 搜索 | `contains(search_in, substring, b_use_case=False, b_search_from_end=False)` | `bool Contains(...)` | `bool` |
| 搜索 | `starts_with(source_string, in_prefix, search_case=ESearchCase::IgnoreCase)` | `bool StartsWith(...)` | `bool` |
| 搜索 | `ends_with(source_string, in_suffix, search_case=ESearchCase::IgnoreCase)` | `bool EndsWith(...)` | `bool` |
| 搜索 | `matches_wildcard(source_string, wildcard, search_case=ESearchCase::IgnoreCase)` | `bool MatchesWildcard(...)`（`*`/`?` 通配） | `bool` |
| 截取 | `get_substring(source_string, start_index=0, length=1)` | `FString GetSubstring(...)` | `str` |
| 截取 | `left(s, count)` / `right(s, count)` / `mid(s, start, count)` | `FString Left/Right/Mid(const FString&, int32)` | `str` |
| 截取 | `left_chop(s, count)` / `right_chop(s, count)` | `FString LeftChop/RightChop(const FString&, int32)` | `str` |
| 字符 | `get_character_as_number(s, index=0)` | `int32 GetCharacterAsNumber(const FString&, int32)` | `int` |
| 字符 | `get_character_array_from_string(s)` | `TArray<FString> GetCharacterArrayFromString(const FString&)` | `Array[str]` |
| 大小写 | `to_upper(s)` / `to_lower(s)` | `FString ToUpper/ToLower(const FString&)` | `str` |
| 填充 | `left_pad(s, ch_count)` / `right_pad(s, ch_count)` | `FString LeftPad/RightPad(const FString&, int32)` | `str` |
| 数值 | `is_numeric(s)` | `bool IsNumeric(const FString&)` | `bool` |
| 修剪 | `trim(s)` / `trim_trailing(s)` | `FString Trim/TrimTrailing(const FString&)` | `str` |
| 反转 | `reverse(s)` | `FString Reverse(const FString&)` | `str` |
| 替换 | `replace(s, from, to, search_case=ESearchCase::IgnoreCase)` | `FString Replace(...)` | `str` |
| 替换 | `replace_inline(s, search_text, replacement_text, search_case=ESearchCase::IgnoreCase)` | `int32 ReplaceInline(UPARAM(ref) FString&, ...)`（就地） | `int`（替换次数） |
| 拆分 | `parse_into_array(source_string, delimiter=" ", cull_empty_strings=True)` | `TArray<FString> ParseIntoArray(...)` | `Array[str]` |
| 拆分 | `split(source_string, in_str, search_case=ESearchCase::IgnoreCase, search_dir=ESearchDir::FromStart)` | `bool Split(const FString&, const FString&, FString& LeftS, FString& RightS, ...)` | `(bool, str, str)` |
| 聚合 | `join_string_array(source_array, separator=" ")` | `FString JoinStringArray(const TArray<FString>&, const FString&)` | `str` |
| 聚合 | `cull_array(source_string, in_array)` | `int32 CullArray(const FString&, TArray<FString>&)`（就地删除空串） | `int`（剩余个数） |
| 时间 | `time_seconds_to_string(in_seconds)` | `FString TimeSecondsToString(float)`（`分钟:秒.毫秒`） | `str` |
| 编辑器 | `diff_string(first, second)` | `FString DiffString(const FString&, const FString&)`（WITH_EDITOR，LCS 差异文本） | `str` |

## 示例

```python
import unreal

lib = unreal.KismetStringLibrary

line = "Item,Sword,100"
parts = lib.parse_into_array(line, ",")
i = lib.conv_string_to_int(parts[0] if parts[0].isdigit() else "0")
joined = lib.join_string_array(parts, " | ")

ok, vec = lib.conv_string_to_vector("X=10.000000 Y=20.000000 Z=0.000000")
if ok:
    print("parsed vector:", vec)

# 就地替换
count = lib.replace_inline(line, "Item", "Armor")
print(count, line)
```

## 限制和注意事项

- 本库全部为纯转换/Pure 函数，不修改资产；`replace_inline`、`cull_array` 只就地修改传入的 Python 字符串/数组对象本身，不触碰任何资产或关卡数据。
- 无 Python/引擎运行时上下文时按 `BLOCKED_TOOLING` 处理；缺必要输入（空引用、索引越界等）按 `BLOCKED_INPUT` 处理。
- `find_substring` 返回位置约定、`Split` 在左右端未匹配时的行为等细节以引擎实现为准；未在真实 UE 5.6 Editor 实测的调用不做"已验证"断言。
- 字符串索引按 UTF-16 码元计数（`Len`/`GetSubstring`/`Mid` 与 UE 内部一致），非 UTF-8 字节数，多字节字符场景需注意。

详细逐方法 API 与完整示例见 `docs/overview.md`。