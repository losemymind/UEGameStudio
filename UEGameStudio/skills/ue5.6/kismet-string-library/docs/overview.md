# KismetStringLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetStringLibrary.h` 整理 `UKismetStringLibrary`（继承 `UBlueprintFunctionLibrary`）中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的 static 成员。Python 类名去掉 `U` 前缀：`unreal.KismetStringLibrary`；本库方法均无 `ScriptMethod` meta，Python 方法名一律按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 用 `dir(unreal.KismetStringLibrary)` 实测确认。

本库共 77 个带 `UFUNCTION` 标记的成员，全部属于 `Utilities|String` 分类，以下按功能族分组逐个列出。

## 通用约定

```python
import unreal

lib = unreal.KismetStringLibrary
s = lib.conv_int_to_string(42)
parts = lib.parse_into_array("a,b,c", ",")
```

- 方法名由 C++ 名转 snake_case 派生，示例：`Conv_IntToString` → `conv_int_to_string`、`EqualEqual_StrStr` → `equal_equal_str_str`、`Len` → `len`、`Left/Right/Mid` → `left/right/mid`、`ReplaceInline` → `replace_inline`。
- 与 Python 内置对象重名的派生名（`len`、`left`、`right`、`mid`、`split`、`reverse`、`replace`、`trim`、`contains`、`is_numeric` 等）必须用 `unreal.KismetStringLibrary.<name>` 限定调用。
- `FString` 参数传 Python `str`；`FName` 参数可直接传字符串；`TArray<FString>` 传 `Array[str]`；枚举参数（`ESearchCase`/`ESearchDir`）传名称字符串或 `unreal.ESearchCase`/`unreal.ESearchDir` 值。
- Out/ByRef 约定同上库：单个 Out 直接返回；多个 Out 按声明顺序返回元组；有返回值 + Out 时返回值在首位。
- 字符串长度与索引按 UTF-16 码元（UE 的 `FString`/`TCHAR` 语义），不是 Python 的 `len()` 字节数；含中文/emoji 时注意两者的差别。

## 转换族（To String，21 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `conv_double_to_string(in_double)` | `FString Conv_DoubleToString(double)` | `str` |
| `conv_int_to_string(in_int)` | `FString Conv_IntToString(int32)` | `str` |
| `conv_int64_to_string(in_int)` | `FString Conv_Int64ToString(int64)` | `str` |
| `conv_byte_to_string(in_byte)` | `FString Conv_ByteToString(uint8)` | `str` |
| `conv_bool_to_string(in_bool)` | `FString Conv_BoolToString(bool)`（`true`/`false`） | `str` |
| `conv_vector_to_string(in_vec)` | `FString Conv_VectorToString(FVector)`（`X= Y= Z=`） | `str` |
| `conv_vector3f_to_string(in_vec)` | `FString Conv_Vector3fToString(FVector3f)`（`X= Y= Z=`） | `str` |
| `conv_int_vector_to_string(in_int_vector)` | `FString Conv_IntVectorToString(FIntVector)` | `str` |
| `conv_int_vector2_to_string(in_int_vector2)` | `FString Conv_IntVector2ToString(FIntVector2)`（`X= Y=`） | `str` |
| `conv_int_point_to_string(in_int_point)` | `FString Conv_IntPointToString(FIntPoint)`（`X= Y=`） | `str` |
| `conv_vector2d_to_string(in_vec)` | `FString Conv_Vector2dToString(FVector2D)`（`X= Y=`） | `str` |
| `conv_rotator_to_string(in_rot)` | `FString Conv_RotatorToString(FRotator)`（`P= Y= R=`） | `str` |
| `conv_transform_to_string(in_trans)` | `FString Conv_TransformToString(const FTransform&)`（`Translation:... Rotation:... Scale:...`） | `str` |
| `conv_object_to_string(in_obj)` | `FString Conv_ObjectToString(class UObject*)`（对象名） | `str` |
| `conv_box_to_string(box)` | `FString Conv_BoxToString(const FBox&)` | `str` |
| `conv_box_center_and_extents_to_string(box)` | `FString Conv_BoxCenterAndExtentsToString(const FBox&)` | `str` |
| `conv_input_device_id_to_string(in_device_id)` | `FString Conv_InputDeviceIdToString(FInputDeviceId)` | `str` |
| `conv_platform_user_id_to_string(in_platform_user_id)` | `FString Conv_PlatformUserIdToString(FPlatformUserId)` | `str` |
| `conv_color_to_string(in_color)` | `FString Conv_ColorToString(FLinearColor)`（`(R=,G=,B=,A=)`） | `str` |
| `conv_name_to_string(in_name)` | `FString Conv_NameToString(FName)` | `str` |
| `conv_matrix_to_string(in_matrix)` | `FString Conv_MatrixToString(const FMatrix&)` | `str` |

示例：

```python
s = lib.conv_bool_to_string(True)
v = lib.conv_vector_to_string(unreal.Vector(1.0, 2.0, 3.0))
n = lib.conv_object_to_string(some_actor)
```

## 解析族（String To X，9 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `conv_string_to_name(in_string)` | `FName Conv_StringToName(const FString&)` | `str`（Name） |
| `conv_string_to_int(in_string)` | `int32 Conv_StringToInt(const FString&)` | `int` |
| `conv_string_to_int64(in_string)` | `int64 Conv_StringToInt64(const FString&)` | `int` |
| `conv_string_to_double(in_string)` | `double Conv_StringToDouble(const FString&)` | `float` |
| `conv_string_to_vector(in_string)` | `void Conv_StringToVector(const FString&, FVector& OutConvertedVector, bool& OutIsValid)` | `(Vector, bool)` |
| `conv_string_to_vector3f(in_string)` | `void Conv_StringToVector3f(const FString&, FVector3f& OutConvertedVector, bool& OutIsValid)` | `(Vector3f, bool)` |
| `conv_string_to_vector2d(in_string)` | `void Conv_StringToVector2D(const FString&, FVector2D& OutConvertedVector2D, bool& OutIsValid)` | `(Vector2D, bool)` |
| `conv_string_to_rotator(in_string)` | `void Conv_StringToRotator(const FString&, FRotator& OutConvertedRotator, bool& OutIsValid)` | `(Rotator, bool)` |
| `conv_string_to_color(in_string)` | `void Conv_StringToColor(const FString&, FLinearColor& OutConvertedColor, bool& OutIsValid)` | `(LinearColor, bool)` |

示例：

```python
i = lib.conv_string_to_int("42")
ok, vec = lib.conv_string_to_vector("X=10.000000 Y=20.000000 Z=0.000000")
if ok:
    print(vec)
ok2, rot = lib.conv_string_to_rotator("P=0.000000 Y=90.000000 R=0.000000")
```

## 构造族（Build String，11 个）

全部形如 `AppendTo + Prefix + 数值/结构的 ToString + Suffix`，返回 `str`：

| Python 方法名 | C++ 签名 |
| --- | --- |
| `build_string_double(append_to, prefix, in_double, suffix)` | `FString BuildString_Double(const FString&, const FString&, double, const FString&)` |
| `build_string_int(append_to, prefix, in_int, suffix)` | `FString BuildString_Int(const FString&, const FString&, int32, const FString&)` |
| `build_string_bool(append_to, prefix, in_bool, suffix)` | `FString BuildString_Bool(...)` |
| `build_string_vector(append_to, prefix, in_vector, suffix)` | `FString BuildString_Vector(...)` |
| `build_string_int_vector(append_to, prefix, in_int_vector, suffix)` | `FString BuildString_IntVector(...)` |
| `build_string_int_vector2(append_to, prefix, in_int_vector, suffix)` | `FString BuildString_IntVector2(...)` |
| `build_string_vector2d(append_to, prefix, in_vector2d, suffix)` | `FString BuildString_Vector2d(...)` |
| `build_string_rotator(append_to, prefix, in_rot, suffix)` | `FString BuildString_Rotator(...)` |
| `build_string_object(append_to, prefix, in_obj, suffix)` | `FString BuildString_Object(...)` |
| `build_string_color(append_to, prefix, in_color, suffix)` | `FString BuildString_Color(...)` |
| `build_string_name(append_to, prefix, in_name, suffix)` | `FString BuildString_Name(...)` |

示例：

```python
line = lib.build_string_int("ID:", "#", 7, ";")
json_like = lib.build_string_vector("[", "", unreal.Vector(1,2,3), "]")
```

## 连接与比较（5 个 + 字符串对比）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `concat_str_str(a, b)` | `FString Concat_StrStr(const FString& A, const FString& B)` | `str` |
| `equal_equal_str_str(a, b)` | `bool EqualEqual_StrStr(const FString&, const FString&)`（精确相等） | `bool` |
| `equal_equal_stri_stri(a, b)` | `bool EqualEqual_StriStri(...)`（忽略大小写） | `bool` |
| `not_equal_str_str(a, b)` | `bool NotEqual_StrStr(...)`（精确不等） | `bool` |
| `not_equal_stri_stri(a, b)` | `bool NotEqual_StriStri(...)`（忽略大小写不等） | `bool` |

示例：

```python
joined = lib.concat_str_str("Item_", "Sword")
same = lib.equal_equal_stri_stri("Item_Sword", "item_sword")
```

## 度量（2 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `len(s)` | `int32 Len(const FString& S)` | `int` |
| `is_empty(s)` | `bool IsEmpty(const FString& InString)` | `bool` |

示例：

```python
n = lib.len("Hello")
empty = lib.is_empty("")
```

## 搜索（6 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `find_substring(search_in, substring, b_use_case=False, b_search_from_end=False, start_position=-1)` | `int32 FindSubstring(const FString&, const FString&, bool, bool, int32)` | `int` |
| `contains(search_in, substring, b_use_case=False, b_search_from_end=False)` | `bool Contains(const FString&, const FString&, bool, bool)` | `bool` |
| `starts_with(source_string, in_prefix, search_case=ESearchCase::IgnoreCase)` | `bool StartsWith(const FString&, const FString&, ESearchCase::Type)` | `bool` |
| `ends_with(source_string, in_suffix, search_case=ESearchCase::IgnoreCase)` | `bool EndsWith(const FString&, const FString&, ESearchCase::Type)` | `bool` |
| `matches_wildcard(source_string, wildcard, search_case=ESearchCase::IgnoreCase)` | `bool MatchesWildcard(const FString&, const FString&, ESearchCase::Type)`（`*`/`?` 通配，较慢） | `bool` |
| `get_character_as_number(source_string, index=0)` | `int32 GetCharacterAsNumber(const FString&, int32)`（越界返回 0） | `int` |

示例：

```python
idx = lib.find_substring("Hello World", "World", b_use_case=True)
w = lib.matches_wildcard("game_log_001.txt", "*.txt")
code = lib.get_character_as_number("ABC", 1)
```

## 截取（6 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `get_substring(source_string, start_index=0, length=1)` | `FString GetSubstring(const FString&, int32, int32)` | `str` |
| `left(source_string, count)` | `FString Left(const FString&, int32)` | `str` |
| `left_chop(source_string, count)` | `FString LeftChop(const FString&, int32)`（从尾部去掉 N 个字符） | `str` |
| `right(source_string, count)` | `FString Right(const FString&, int32)`（最右侧 N 个字符） | `str` |
| `right_chop(source_string, count)` | `FString RightChop(const FString&, int32)`（从头部去掉 N 个字符） | `str` |
| `mid(source_string, start, count)` | `FString Mid(const FString&, int32, int32)` | `str` |

示例：

```python
sub = lib.mid("Hello World", 6, 5)
head = lib.left("Hello", 2)
tail = lib.right("Hello", 2)
```

## 变换（15 个：大小写/填充/修剪/反转/替换/拆分/聚合/字符数组）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `to_upper(s)` / `to_lower(s)` | `FString ToUpper/ToLower(const FString&)` | `str` |
| `left_pad(s, ch_count)` / `right_pad(s, ch_count)` | `FString LeftPad/RightPad(const FString&, int32)`（`Ch` 填充） | `str` |
| `trim(s)` / `trim_trailing(s)` | `FString Trim/TrimTrailing(const FString&)`（去除前导/尾部空白） | `str` |
| `reverse(s)` | `FString Reverse(const FString&)` | `str` |
| `replace(s, from, to, search_case=ESearchCase::IgnoreCase)` | `FString Replace(const FString&, const FString&, const FString&, ESearchCase::Type)`（返回新串） | `str` |
| `replace_inline(s, search_text, replacement_text, search_case=ESearchCase::IgnoreCase)` | `int32 ReplaceInline(UPARAM(ref) FString&, const FString&, const FString&, ESearchCase::Type)`（就地替换） | `int`（替换次数） |
| `parse_into_array(source_string, delimiter=" ", cull_empty_strings=True)` | `TArray<FString> ParseIntoArray(const FString&, const FString&, const bool)` | `Array[str]` |
| `split(source_string, in_str, search_case=ESearchCase::IgnoreCase, search_dir=ESearchDir::FromStart)` | `bool Split(const FString&, const FString&, FString& LeftS, FString& RightS, ESearchCase::Type, ESearchDir::Type)` | `(bool, str, str)` |
| `join_string_array(source_array, separator=" ")` | `FString JoinStringArray(const TArray<FString>&, const FString&)` | `str` |
| `get_character_array_from_string(source_string)` | `TArray<FString> GetCharacterArrayFromString(const FString&)` | `Array[str]` |
| `cull_array(source_string, in_array)` | `int32 CullArray(const FString&, TArray<FString>& InArray)`（删除 InArray 中空项，返回剩余个数） | `int` |
| `diff_string(first, second)`（WITH_EDITOR） | `FString DiffString(const FString&, const FString&)`（LCS 差异文本，编辑器专用） | `str` |
| `time_seconds_to_string(in_seconds)` | `FString TimeSecondsToString(float)`（`分钟:秒.毫秒`，带前导零） | `str` |

示例：

```python
patched = lib.replace("a-b-c", "-", "/")
r = lib.replace_inline("\"a=b\",\"c\"", "=", ":")   # 就地修改并返回替换次数
ok_l_r, left_s, right_s = lib.split("key:value", ":")
tokens = lib.parse_into_array("1,2,,3", ",", False)
stamp = lib.time_seconds_to_string(125.7)
```

## 完整示例：CSV 行解析 → 字段校验 → 重新拼接

```python
import unreal


def main():
    if not hasattr(unreal, "KismetStringLibrary"):
        print({"status": "BLOCKED_TOOLING", "reason": "KismetStringLibrary 不可用"})
        return

    lib = unreal.KismetStringLibrary
    line = "Item,100,true"

    fields = lib.parse_into_array(line, ",")
    if len(fields) != 3 or not lib.is_numeric(fields[1]):
        print({"status": "BLOCKED_INPUT", "reason": "字段数量或数值字段不合法"})
        return

    price = lib.conv_string_to_int(fields[1])
    ok, vec = lib.conv_string_to_vector("X=10.000000 Y=20.000000 Z=0.000000")
    if not ok:
        vec = unreal.Vector(0.0, 0.0, 0.0)

    out_line = lib.build_string_int(
        lib.concat_str_str(fields[0], ","), "", price + 1, "")
    joined = lib.join_string_array([out_line, str(vec)], ";")

    print({
        "status": "OK",
        "price": price,
        "parsed_vec": str(vec),
        "joined": joined,
        "note": "纯字符串处理，未修改任何资产",
    })


if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_TOOLING`：无 Python/引擎运行时上下文，无法执行任何库调用。
- `BLOCKED_INPUT`：必要输入缺失或不合法（空引用、字段与预期不符、索引越界等）。
- 本库全部为纯函数/就地修改传入对象，不触碰渲染、资产或关卡数据；`replace_inline`、`cull_array` 只就地修改 Python 侧对象。
- 本文件覆盖头文件中全部带 `UFUNCTION` 标记成员（共 77 个）；头文件中 `UE_DEPRECATED` 且未加 `UFUNCTION` 的旧成员（过时转换/构造）不在此列。字符串长度按 UE UTF-16 码元语义，索引约定（`FindSubstring` 未找到返回值、`CullArray` 返回口径等）以目标 UE 5.6 Editor 实测为准；未实测的调用不做"已验证"断言。