---
name: kismet-text-library
description: UKismetTextLibrary（UE 5.6）BP 文本工具库 Python 可调用子集 - 文本转换/大小写/修剪/比较/数字与货币/日期时间与时长/本地化字符串表/编辑 Text 属性；在 Agent 需要通过 unreal Python 处理 FText 时使用
risk: safe
category: development
tags: [ue5.6, kismet, text, python, blueprint]
---

# KismetTextLibrary - Text Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 处理 FText时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-text-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetTextLibrary` 中可由 Python 调用的静态成员，签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetTextLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。本 skill 只记录可由 Python 调用的成员。

## 入口说明

该库全部为 static 方法，以类方法形式调用，无需实例：

```python
import unreal

ktext = unreal.KismetTextLibrary
```

- 引擎 Python 上下文可用即可调用；不依赖编辑器子系统。
- `FText` 映射 `unreal.Text`；`FString` 映射 Python `str`；`FName` 映射 `unreal.Name`。
- 带出参的方法按反射约定返回元组，出参追加在返回值之后。

## 可用操作

| 类别 | Python 方法名 | 说明 |
| --- | --- | --- |
| 转换 | `conv_vector_to_text(in_vec)` | Vector → Text |
| 转换 | `conv_vector2d_to_text(in_vec)` | Vector2D → Text |
| 转换 | `conv_rotator_to_text(in_rot)` | Rotator → Text |
| 转换 | `conv_transform_to_text(in_trans)` | Transform → Text |
| 转换 | `conv_object_to_text(in_obj)` | Object → Text（对象名） |
| 转换 | `conv_color_to_text(in_color)` | LinearColor → Text |
| 转换 | `conv_text_to_string(in_text)` | Text → String |
| 转换 | `conv_string_to_text(in_string)` | String → Text（culture invariant） |
| 转换 | `conv_name_to_text(in_name)` | Name → Text（culture invariant） |
| 转换 | `conv_bool_to_text(in_bool)` | Boolean → Text |
| 转换 | `conv_byte_to_text(value)` | Byte → Text |
| 转换 | `conv_int_to_text(value, ...)` | Integer → Text |
| 转换 | `conv_int64_to_text(value, ...)` | Integer64 → Text |
| 转换 | `conv_double_to_text(value, rounding_mode, ...)` | Double → Text |
| 创建 | `make_invariant_text(in_string)` | 字符串 → culture invariant Text |
| 创建 | `get_empty_text()` | 返回空 Text |
| 状态 | `text_is_empty(in_text)` | 是否为空 |
| 状态 | `text_is_transient(in_text)` | 是否为 transient |
| 状态 | `text_is_culture_invariant(in_text)` | 是否 culture invariant |
| 变换 | `text_to_lower(in_text)` | 转小写（culture 正确） |
| 变换 | `text_to_upper(in_text)` | 转大写（culture 正确） |
| 变换 | `text_trim_preceding(in_text)` | 去除前导空白 |
| 变换 | `text_trim_trailing(in_text)` | 去除尾随空白 |
| 变换 | `text_trim_preceding_and_trailing(in_text)` | 去除前后空白 |
| 比较 | `equal_equal_text_text(a, b)` | 语言相等（严格） |
| 比较 | `equal_equal_ignore_case_text_text(a, b)` | 语言相等（忽略大小写） |
| 比较 | `not_equal_text_text(a, b)` | 语言不等（严格） |
| 比较 | `not_equal_ignore_case_text_text(a, b)` | 语言不等（忽略大小写） |
| 数字 | `as_currency_base(base_value, currency_code)` | 最小货币单位 → 货币文本 |
| 数字 | `as_currency_integer(value, rounding_mode, ...)` | Integer → 货币文本（废弃） |
| 数字 | `as_currency_float(value, rounding_mode, ...)` | Float → 货币文本（废弃） |
| 数字 | `as_percent_float(value, rounding_mode, ...)` | Float → 百分比文本 |
| 数字 | `as_memory(num_bytes, unit_standard=..., ...)` | 字节数 → 内存大小文本 |
| 格式化 | `format(in_pattern, in_args)` | FText::Format 格式化 |
| 日期时间 | `as_date_date_time(in_date_time, ...)` | DateTime → 日期文本 |
| 日期时间 | `as_time_zone_date_date_time(in_date_time, ...)` | UTC → 时区日期文本 |
| 日期时间 | `as_date_time_date_time(in, ...)` | DateTime → 日期时间文本 |
| 日期时间 | `as_time_zone_date_time_date_time(in_date_time, ...)` | UTC → 时区日期时间文本 |
| 日期时间 | `as_time_date_time(in, ...)` | DateTime → 时间文本 |
| 日期时间 | `as_time_zone_time_date_time(in_date_time, ...)` | UTC → 时区时间文本 |
| 日期时间 | `as_timespan_timespan(in_timespan)` | Timespan → 时长文本 |
| 本地化 | `find_text_in_localization_table(namespace, key, ...)` | 按命名空间/键查实时本地化表 |
| 本地化 | `text_is_from_string_table(text)` | 是否引用字符串表 |
| 本地化 | `text_from_string_table(table_id, key)` | 按字符串表 ID/键取文本 |
| 本地化 | `string_table_id_and_key_from_text(text)` | 从文本取字符串表 ID/键 |
| 本地化 | `get_text_id(text)` | 从文本取 ID（命名空间/键） |
| 本地化 | `get_text_source_string(text)` | 取非本地化源串 |
| 本地化 | `is_polyglot_data_valid(polyglot_data)` | 校验多语言文本数据 |
| 本地化 | `polyglot_data_to_text(polyglot_data)` | 多语言文本数据 → Text |
| 编辑 | `edit_text_property_source_string(text_owner, property_name, source_string, ...)` | 编辑 Text 属性源串 |

## 示例

```python
import unreal

ktext = unreal.KismetTextLibrary

name_text = ktext.conv_name_to_text(unreal.Name("Player_01"))
print(ktext.conv_text_to_string(name_text))  # Player_01

upper = ktext.text_to_upper(name_text)
print(ktext.conv_text_to_string(upper))     # PLAYER_01

score_text = ktext.conv_int_to_text(42)
print(ktext.conv_text_to_string(score_text))  # 42

currency = ktext.as_currency_base(650, "EUR")
print(ktext.conv_text_to_string(currency))
```

## 限制和注意事项

- 返回 `Text` 的转换方法需要时用 `conv_text_to_string` 取得可打印字符串。
- `conv_double_to_text` 与货币/百分比方法的 `rounding_mode` 使用 `unreal.RoundingMode`；日期样式使用 `unreal.DateTimeStyle`；内存单位使用 `unreal.MemoryUnitStandard`。
- 带出参的方法返回元组（如 `string_table_id_and_key_from_text(text)` 返回 `(bool, Name, String)`）。
- `edit_text_property_source_string` 属高级编辑操作，仅建议在编辑器等会收集文本属性以本地化的环境中使用。
- 缺必要输入（键、命名空间、类路径等）时返回 `BLOCKED_INPUT`；引擎 Python 上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。