# KismetTextLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetTextLibrary.h` 整理 `UKismetTextLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的静态成员，方法名由 C++ 函数名按反射约定转 snake_case。全部方法为 static，以 `unreal.KismetTextLibrary` 类方法形式调用，无需实例。

## 获取类

```python
import unreal

ktext = unreal.KismetTextLibrary
```

- 类对象直接可用；引擎 Python 上下文不可用时按 `BLOCKED_TOOLING` 处理并停止。
- 不依赖编辑器子系统与 `UWorld`。

## 通用约定

- `FText` 映射 `unreal.Text`；`FString` 映射 Python `str`；`FName` 映射 `unreal.Name`。
- 带 `FText&` / `FName&` / `FString&` / `bool&` 出参的成员返回元组，出参追加在返回值之后。
- 数字格式化参数默认值与头文件一致（`bAlwaysSign=False`、`bUseGrouping=True`、整数位 `1..324`、小数位 `0..3`）。
- 枚举默认值：舍入 `unreal.RoundingMode`；日期样式 `unreal.DateTimeStyle`；内存单位 `unreal.MemoryUnitStandard`。

## 文本转换

### conv_vector_to_text

- C++ 签名：`FText Conv_VectorToText(FVector InVec)`（BlueprintPure）
- Python：`conv_vector_to_text(in_vec) -> Text`
- 说明：向量 → 本地化格式化文本，形式 `X= Y= Z=`。
- 示例：

```python
vec_text = ktext.conv_vector_to_text(unreal.Vector(1.0, 2.0, 3.0))
print(ktext.conv_text_to_string(vec_text))
```

### conv_vector2d_to_text

- C++ 签名：`FText Conv_Vector2dToText(FVector2D InVec)`（BlueprintPure）
- Python：`conv_vector2d_to_text(in_vec) -> Text`
- 说明：二维向量 → 文本，形式 `X= Y=`。

```python
v2d_text = ktext.conv_vector2d_to_text(unreal.Vector2D(1.0, 2.0))
```

### conv_rotator_to_text

- C++ 签名：`FText Conv_RotatorToText(FRotator InRot)`（BlueprintPure）
- Python：`conv_rotator_to_text(in_rot) -> Text`
- 说明：旋转量 → 文本，形式 `P= Y= R=`。

```python
rot_text = ktext.conv_rotator_to_text(unreal.Rotator(0.0, 90.0, 0.0))
```

### conv_transform_to_text

- C++ 签名：`FText Conv_TransformToText(const FTransform& InTrans)`（BlueprintPure）
- Python：`conv_transform_to_text(in_trans) -> Text`
- 说明：变换 → 文本，含 Translation/Rotation/Scale。

```python
xf_text = ktext.conv_transform_to_text(unreal.Transform(location=unreal.Vector(1, 2, 3)))
```

### conv_object_to_text

- C++ 签名：`FText Conv_ObjectToText(class UObject* InObj)`（BlueprintPure）
- Python：`conv_object_to_text(in_obj) -> Text`
- 说明：对象 → culture invariant 文本（对象 GetName）。

```python
obj_text = ktext.conv_object_to_text(some_actor)
```

### conv_color_to_text

- C++ 签名：`FText Conv_ColorToText(FLinearColor InColor)`（BlueprintPure）
- Python：`conv_color_to_text(in_color) -> Text`
- 说明：线性颜色 → 文本，形式 `(R=,G=,B=,A=)`。

```python
color_text = ktext.conv_color_to_text(unreal.LinearColor(1.0, 0.0, 0.0, 1.0))
```

### conv_text_to_string

- C++ 签名：`FString Conv_TextToString(const FText& InText)`（BlueprintPure）
- Python：`conv_text_to_string(in_text) -> str`
- 说明：文本 → 字符串（本地化值）。

```python
raw = ktext.conv_text_to_string(ktext.text_to_upper(my_text))
```

### conv_string_to_text

- C++ 签名：`FText Conv_StringToText(const FString& InString)`（BlueprintPure）
- Python：`conv_string_to_text(in_string) -> Text`
- 说明：字符串 → culture invariant 文本。

```python
label_text = ktext.conv_string_to_text("Hello")
```

### conv_name_to_text

- C++ 签名：`FText Conv_NameToText(FName InName)`（BlueprintPure）
- Python：`conv_name_to_text(in_name) -> Text`
- 说明：名称 → culture invariant 文本。

```python
tag_text = ktext.conv_name_to_text(unreal.Name("Env_Zone"))
```

## 文本创建与状态

### make_invariant_text

- C++ 签名：`FText MakeInvariantText(const FString& InString)`（BlueprintPure）
- Python：`make_invariant_text(in_string) -> Text`
- 说明：字符串 → culture invariant 文本，不参与本地化。需要可本地化文本时使用 `conv_string_to_text` 或 Literal Text。

```python
invariant = ktext.make_invariant_text("fixed message")
```

### get_empty_text

- C++ 签名：`FText GetEmptyText()`（BlueprintPure）
- Python：`get_empty_text() -> Text`
- 说明：返回空文本。

```python
empty = ktext.get_empty_text()
```

### text_is_empty

- C++ 签名：`bool TextIsEmpty(const FText& InText)`（BlueprintPure）
- Python：`text_is_empty(in_text) -> bool`
- 说明：文本是否为空。

```python
if ktext.text_is_empty(target_text):
    print("empty")
```

### text_is_transient

- C++ 签名：`bool TextIsTransient(const FText& InText)`（BlueprintPure）
- Python：`text_is_transient(in_text) -> bool`
- 说明：文本是否为 transient（未被本地化表引用）。

### text_is_culture_invariant

- C++ 签名：`bool TextIsCultureInvariant(const FText& InText)`（BlueprintPure）
- Python：`text_is_culture_invariant(in_text) -> bool`
- 说明：文本是否 culture invariant。

## 文本变换

### text_to_lower

- C++ 签名：`FText TextToLower(const FText& InText)`（BlueprintPure）
- Python：`text_to_lower(in_text) -> Text`
- 说明：按当前文化正确转小写；返回实例与原文本链接，文化切换时会重建。

```python
lower = ktext.text_to_lower(name_text)
```

### text_to_upper

- C++ 签名：`FText TextToUpper(const FText& InText)`（BlueprintPure）
- Python：`text_to_upper(in_text) -> Text`
- 说明：按当前文化正确转大写。

```python
upper = ktext.text_to_upper(name_text)
```

### text_trim_preceding

- C++ 签名：`FText TextTrimPreceding(const FText& InText)`（BlueprintPure）
- Python：`text_trim_preceding(in_text) -> Text`
- 说明：去除文本前导空白。

### text_trim_trailing

- C++ 签名：`FText TextTrimTrailing(const FText& InText)`（BlueprintPure）
- Python：`text_trim_trailing(in_text) -> Text`
- 说明：去除文本尾随空白。

### text_trim_preceding_and_trailing

- C++ 签名：`FText TextTrimPrecedingAndTrailing(const FText& InText)`（BlueprintPure）
- Python：`text_trim_preceding_and_trailing(in_text) -> Text`
- 说明：去除文本前后空白。

```python
clean = ktext.text_trim_preceding_and_trailing(dirty_text)
```

## 文本比较

### equal_equal_text_text

- C++ 签名：`bool EqualEqual_TextText(const FText& A, const FText& B)`（BlueprintPure）
- Python：`equal_equal_text_text(a, b) -> bool`
- 说明：严格语言相等（A == B，区分大小写）。

### equal_equal_ignore_case_text_text

- C++ 签名：`bool EqualEqual_IgnoreCase_TextText(const FText& A, const FText& B)`（BlueprintPure）
- Python：`equal_equal_ignore_case_text_text(a, b) -> bool`
- 说明：忽略大小写的语言相等。

### not_equal_text_text

- C++ 签名：`bool NotEqual_TextText(const FText& A, const FText& B)`（BlueprintPure）
- Python：`not_equal_text_text(a, b) -> bool`
- 说明：严格语言不等。

### not_equal_ignore_case_text_text

- C++ 签名：`bool NotEqual_IgnoreCase_TextText(const FText& A, const FText& B)`（BlueprintPure）
- Python：`not_equal_ignore_case_text_text(a, b) -> bool`
- 说明：忽略大小写的语言不等。

```python
same = ktext.equal_equal_text_text(text_a, text_b)
```

## 数字与文本格式化

### conv_bool_to_text

- C++ 签名：`FText Conv_BoolToText(bool InBool)`（BlueprintPure）
- Python：`conv_bool_to_text(in_bool) -> Text`
- 说明：布尔 → `true` / `false` 文本。

### conv_byte_to_text

- C++ 签名：`FText Conv_ByteToText(uint8 Value)`（BlueprintPure）
- Python：`conv_byte_to_text(value) -> Text`
- 说明：字节 → 数字文本。

### conv_int_to_text

- C++ 签名：`FText Conv_IntToText(int32 Value, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324)`（BlueprintPure）
- Python：`conv_int_to_text(value, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324) -> Text`
- 说明：整数 → 数字文本，可按格式选项调整。

```python
score_text = ktext.conv_int_to_text(1200, b_use_grouping=True)
```

### conv_int64_to_text

- C++ 签名：`FText Conv_Int64ToText(int64 Value, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324)`（BlueprintPure）
- Python：`conv_int64_to_text(value, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324) -> Text`
- 说明：64 位整数 → 数字文本。

### conv_double_to_text

- C++ 签名：`FText Conv_DoubleToText(double Value, TEnumAsByte<ERoundingMode> RoundingMode, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324, int32 MinimumFractionalDigits = 0, int32 MaximumFractionalDigits = 3)`（BlueprintPure）
- Python：`conv_double_to_text(value, rounding_mode, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324, minimum_fractional_digits=0, maximum_fractional_digits=3) -> Text`
- 说明：double → 数字文本；`rounding_mode` 使用 `unreal.RoundingMode`。

```python
dist_text = ktext.conv_double_to_text(
    12.3456,
    unreal.RoundingMode.HALF_TO_EVEN,
    maximum_fractional_digits=2,
)
```

### format

- C++ 签名：`FText Format(FText InPattern, TArray<FFormatArgumentData> InArgs)`（BlueprintPure）
- Python：`format(in_pattern, in_args) -> Text`
- 说明：按 `FText::Format` 用参数数组格式化文本；参数数据结构为 `unreal.FormatArgumentData`（`argument_name` / `argument_value_type` / 对应值字段）。

```python
import unreal

arg = unreal.FormatArgumentData()
arg.set_editor_property("argument_name", "Name")
arg.set_editor_property("argument_value_type", unreal.FormatArgumentType.TEXT)
arg.set_editor_property("argument_value", ktext.conv_string_to_text("Ada"))

greeting = ktext.format(ktext.conv_string_to_text("Hi, {Name}!"), [arg])
print(ktext.conv_text_to_string(greeting))
```

### as_currency_base

- C++ 签名：`FText AsCurrencyBase(int32 BaseValue, const FString& CurrencyCode)`（BlueprintPure）
- Python：`as_currency_base(base_value, currency_code) -> Text`
- 说明：按最小货币单位生成当前文化下的货币文本；`currency_code`（如 `EUR`）与显示文化相互独立。

```python
price = ktext.as_currency_base(650, "EUR")
print(ktext.conv_text_to_string(price))
```

### as_currency_integer

- C++ 签名：`FText AsCurrency_Integer(int32 Value, TEnumAsByte<ERoundingMode> RoundingMode, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324, int32 MinimumFractionalDigits = 0, int32 MaximumFractionalDigits = 3, const FString& CurrencyCode = TEXT(""))`（BlueprintPure，DisplayName 已标注 DEPRECATED）
- Python：`as_currency_integer(value, rounding_mode, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324, minimum_fractional_digits=0, maximum_fractional_digits=3, currency_code="") -> Text`
- 说明：整数 → 货币文本；废弃接口，优先使用 `as_currency_base`。

### as_currency_float

- C++ 签名：`FText AsCurrency_Float(float Value, TEnumAsByte<ERoundingMode> RoundingMode, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324, int32 MinimumFractionalDigits = 0, int32 MaximumFractionalDigits = 3, const FString& CurrencyCode = TEXT(""))`（BlueprintPure，DisplayName 已标注 DEPRECATED）
- Python：`as_currency_float(value, rounding_mode, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324, minimum_fractional_digits=0, maximum_fractional_digits=3, currency_code="") -> Text`
- 说明：float → 货币文本；废弃接口，优先使用 `as_currency_base`。

### as_percent_float

- C++ 签名：`FText AsPercent_Float(float Value, TEnumAsByte<ERoundingMode> RoundingMode, bool bAlwaysSign = false, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324, int32 MinimumFractionalDigits = 0, int32 MaximumFractionalDigits = 3)`（BlueprintPure）
- Python：`as_percent_float(value, rounding_mode, b_always_sign=False, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324, minimum_fractional_digits=0, maximum_fractional_digits=3) -> Text`
- 说明：float → 百分比文本。

```python
pct = ktext.as_percent_float(0.25, unreal.RoundingMode.HALF_TO_EVEN)
```

### as_memory

- C++ 签名：`FText AsMemory(int64 NumBytes, TEnumAsByte<EMemoryUnitStandard> UnitStandard = EMemoryUnitStandard::IEC, bool bUseGrouping = true, int32 MinimumIntegralDigits = 1, int32 MaximumIntegralDigits = 324, int32 MinimumFractionalDigits = 0, int32 MaximumFractionalDigits = 3)`（BlueprintPure）
- Python：`as_memory(num_bytes, unit_standard=unreal.MemoryUnitStandard.IEC, b_use_grouping=True, minimum_integral_digits=1, maximum_integral_digits=324, minimum_fractional_digits=0, maximum_fractional_digits=3) -> Text`
- 说明：字节数 → 当前文化下的内存大小文本；`IEC` 为 1024 进制，`SI` 为 1000 进制。

```python
mem = ktext.as_memory(5 * 1024 * 1024, unreal.MemoryUnitStandard.IEC)
```

## 日期时间与时长

### as_date_date_time

- C++ 签名：`FText AsDate_DateTime(const FDateTime& InDateTime, TEnumAsByte<EDateTimeStyle::Type> InDateStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_date_date_time(in_date_time, in_date_style=unreal.DateTimeStyle.DEFAULT) -> Text`
- 说明：日期时间 → 日期文本（invariant 时区，按给定值原样使用）。

### as_time_zone_date_date_time

- C++ 签名：`FText AsTimeZoneDate_DateTime(const FDateTime& InDateTime, const FString& InTimeZone = TEXT(""), TEnumAsByte<EDateTimeStyle::Type> InDateStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_time_zone_date_date_time(in_date_time, in_time_zone="", in_date_style=unreal.DateTimeStyle.DEFAULT) -> Text`
- 说明：UTC 日期时间 → 指定时区日期文本（默认本地时区，含 DST）。

### as_date_time_date_time

- C++ 签名：`FText AsDateTime_DateTime(const FDateTime& In, TEnumAsByte<EDateTimeStyle::Type> InDateStyle = EDateTimeStyle::Default, TEnumAsByte<EDateTimeStyle::Type> InTimeStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_date_time_date_time(in_date_time, in_date_style=..., in_time_style=...) -> Text`
- 说明：日期时间 → 日期+时间文本（invariant 时区）。

### as_time_zone_date_time_date_time

- C++ 签名：`FText AsTimeZoneDateTime_DateTime(const FDateTime& InDateTime, const FString& InTimeZone = TEXT(""), TEnumAsByte<EDateTimeStyle::Type> InDateStyle = EDateTimeStyle::Default, TEnumAsByte<EDateTimeStyle::Type> InTimeStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_time_zone_date_time_date_time(in_date_time, in_time_zone="", in_date_style=..., in_time_style=...) -> Text`
- 说明：UTC 日期时间 → 指定时区日期+时间文本。

### as_time_date_time

- C++ 签名：`FText AsTime_DateTime(const FDateTime& In, TEnumAsByte<EDateTimeStyle::Type> InTimeStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_time_date_time(in_date_time, in_time_style=unreal.DateTimeStyle.DEFAULT) -> Text`
- 说明：日期时间 → 时间文本（invariant 时区）。

### as_time_zone_time_date_time

- C++ 签名：`FText AsTimeZoneTime_DateTime(const FDateTime& InDateTime, const FString& InTimeZone = TEXT(""), TEnumAsByte<EDateTimeStyle::Type> InTimeStyle = EDateTimeStyle::Default)`（BlueprintPure）
- Python：`as_time_zone_time_date_time(in_date_time, in_time_zone="", in_time_style=...) -> Text`
- 说明：UTC 日期时间 → 指定时区时间文本。

### as_timespan_timespan

- C++ 签名：`FText AsTimespan_Timespan(const FTimespan& InTimespan)`（BlueprintPure）
- Python：`as_timespan_timespan(in_timespan) -> Text`
- 说明：时长 → 时长文本。

```python
ts = ktext.as_timespan_timespan(unreal.Timespan(days=0, hours=1, minutes=30, seconds=0))
```

## 本地化与字符串表

### find_text_in_localization_table

- C++ 签名：`bool FindTextInLocalizationTable(const FString& Namespace, const FString& Key, FText& OutText, const FString& SourceString = TEXT(""))`（BlueprintPure）
- Python：`find_text_in_localization_table(namespace, key, source_string="") -> (bool, Text)`
- 说明：按命名空间/键在实时本地化表中查找已本地化文本；`source_string` 非空时要求匹配源串。查找结果经 `OutText` 出参随返回值一同返回。

```python
found, out_text = ktext.find_text_in_localization_table("MyNS", "Key01")
if found:
    print(ktext.conv_text_to_string(out_text))
```

### text_is_from_string_table

- C++ 签名：`bool TextIsFromStringTable(const FText& Text)`（BlueprintPure）
- Python：`text_is_from_string_table(text) -> bool`
- 说明：文本是否引用字符串表。

### text_from_string_table

- C++ 签名：`FText TextFromStringTable(const FName TableId, const FString& Key)`（BlueprintPure）
- Python：`text_from_string_table(table_id, key) -> Text`
- 说明：按字符串表 ID 与键创建文本；未找到条目时返回占位文本。

```python
st_text = ktext.text_from_string_table(unreal.Name("UI_Table"), "btn_start")
```

### string_table_id_and_key_from_text

- C++ 签名：`bool StringTableIdAndKeyFromText(FText Text, FName& OutTableId, FString& OutKey)`（BlueprintPure）
- Python：`string_table_id_and_key_from_text(text) -> (bool, Name, str)`
- 说明：从文本取得字符串表 ID 与键；成功返回 `True`。

```python
ok, table_id, key = ktext.string_table_id_and_key_from_text(st_text)
```

### get_text_id

- C++ 签名：`bool GetTextId(FText Text, FString& OutNamespace, FString& OutKey)`（BlueprintPure）
- Python：`get_text_id(text) -> (bool, str, str)`
- 说明：从文本取得 ID（命名空间与键，命名空间可能为空）。

### get_text_source_string

- C++ 签名：`FString GetTextSourceString(FText Text)`（BlueprintPure）
- Python：`get_text_source_string(text) -> str`
- 说明：取得文本的非本地化源串；对生成文本（如 Format 结果）会按本地语言深构建源串。

### is_polyglot_data_valid

- C++ 签名：`void IsPolyglotDataValid(const FPolyglotData& PolyglotData, bool& IsValid, FText& ErrorMessage)`（BlueprintPure）
- Python：`is_polyglot_data_valid(polyglot_data) -> (bool, Text)`
- 说明：校验多语言文本数据（`unreal.PolyglotTextData`）；数据无效时经 `ErrorMessage` 出参返回说明。

```python
data = unreal.PolyglotTextData()
data.set_editor_property("category", "Game")
valid, error_text = ktext.is_polyglot_data_valid(data)
print(valid, ktext.conv_text_to_string(error_text) if not valid else "")
```

### polyglot_data_to_text

- C++ 签名：`FText PolyglotDataToText(const FPolyglotData& PolyglotData)`（BlueprintPure）
- Python：`polyglot_data_to_text(polyglot_data) -> Text`
- 说明：从多语言文本数据（`unreal.PolyglotTextData`）创建文本；数据无效返回空文本。

```python
created = ktext.polyglot_data_to_text(data)
```

## 编辑文本属性源串

### edit_text_property_source_string

- C++ 签名：`bool EditTextPropertySourceString(UObject* TextOwner, const FName PropertyName, const FString SourceString, const bool bEmitChangeNotify = true)`（BlueprintCallable）
- Python：`edit_text_property_source_string(text_owner, property_name, source_string, b_emit_change_notify=True) -> bool`
- 说明：编辑 `TextOwner` 上指定名 Text 属性的源串，类似细节面板编辑；尽可能保留既有 ID，否则按对象与属性构建确定性 ID。编辑后的文本属性需进入本地化收集环境（编辑器等）才安全；构造脚本内建议 `b_emit_change_notify=False`。成功返回 `True`。

```python
ok = ktext.edit_text_property_source_string(
    my_object,
    unreal.Name("DisplayName"),
    "新显示名",
    b_emit_change_notify=True,
)
if not ok:
    print("edit failed")
```

## 完整示例：格式化与本地化文本

```python
import unreal

def main():
    ktext = unreal.KismetTextLibrary

    arg = unreal.FormatArgumentData()
    arg.set_editor_property("argument_name", "Player")
    arg.set_editor_property("argument_value_type", unreal.FormatArgumentType.TEXT)
    arg.set_editor_property("argument_value", ktext.conv_string_to_text("Ada"))

    pattern = ktext.conv_string_to_text("Welcome, {Player}!")
    message = ktext.format(pattern, [arg])

    upper = ktext.text_to_upper(message)
    print(ktext.conv_text_to_string(upper))

    price = ktext.as_currency_base(650, "EUR")
    mem = ktext.as_memory(8 * 1024 * 1024, unreal.MemoryUnitStandard.IEC)
    print(ktext.conv_text_to_string(price))
    print(ktext.conv_text_to_string(mem))

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（命名空间/键、对象与属性名、字符串表 ID 等）。
- `BLOCKED_TOOLING`：引擎 Python 上下文不可用，无法执行。
- `BLOCKED_UNVERIFIED`：缺编辑器环境或来源证据，不能对调用结果给 PASS。
- 文本转换与本地化行为依赖活动文化；相同输入在不同文化下可能产生不同输出。
- 带出参的成员返回元组，务必按上述顺序解包；解包数目不符视为调用契约不满足。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；标称方法与精确 Python 暴露名需在目标编辑器实测确认后方可断言。

本文档只记录头部文件中带 `UFUNCTION` 标记、可由 Python 直接调用的成员。