---
name: kismet-string-table-library
description: UE 5.6 字符串表（String Table）运行时 API（UKismetStringTableLibrary） - 注册表校验、表命名空间与条目源字符串/元数据读取、注册字符串表与条目键枚举；在 Agent 需要通过 unreal Python 查询游戏字符串表注册状态或读取/校验条目时使用
risk: safe
category: development
tags: [ue5.6, string-table, localization, python]
---

# KismetStringTableLibrary - 字符串表（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 查询游戏字符串表注册状态或读取/校验条目时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-string-table-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetStringTableLibrary` 暴露给 Python 的字符串表（String Table）运行时接口。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetStringTableLibrary.h` 中带 `UFUNCTION(BlueprintPure)` 标记的成员整理，全部方法只读、无副作用。

## 入口说明

```python
import unreal

api = unreal.KismetStringTableLibrary
```

- Python 类名为去掉 U 前缀的类名；全部成员为 static，以类方法形式调用。
- 方法命名为 `meta=(ScriptMethod=...)` 值转 snake_case；本类方法均无 `ScriptMethod`，故按 C++ 函数名转 snake_case。精确 Python 暴露名需实测确认。
- 表 ID（`TableId` / `TableId`）为 `unreal.Name`；键（`Key`）与元数据 ID（`MetaDataId`）按对应类型传入。
- 未注册表或条目返回空值与 `False`；无法判断时按 `BLOCKED_INPUT` 处理并停止。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 校验 | `is_registered_table_id(table_id)` | `bool IsRegisteredTableId(FName)` | `bool` |
| 校验 | `is_registered_table_entry(table_id, key)` | `bool IsRegisteredTableEntry(FName, const FString&)` | `bool` |
| 查询 | `get_table_namespace(table_id)` | `FString GetTableNamespace(FName)` | `str` |
| 查询 | `get_table_entry_source_string(table_id, key)` | `FString GetTableEntrySourceString(FName, const FString&)` | `str` |
| 查询 | `get_table_entry_meta_data(table_id, key, meta_data_id)` | `FString GetTableEntryMetaData(FName, const FString&, FName)` | `str` |
| 列举 | `get_registered_string_tables()` | `TArray<FName> GetRegisteredStringTables()` | `Array[Name]` |
| 列举 | `get_keys_from_string_table(table_id)` | `TArray<FString> GetKeysFromStringTable(FName)` | `Array[str]` |
| 列举 | `get_meta_data_ids_from_string_table_entry(table_id, key)` | `TArray<FName> GetMetaDataIdsFromStringTableEntry(FName, const FString&)` | `Array[Name]` |

## 示例

```python
import unreal

api = unreal.KismetStringTableLibrary

table_id = unreal.Name("Table_UI")
if not api.is_registered_table_id(table_id):
    print("table not registered")

keys = api.get_keys_from_string_table(table_id)
print("keys:", keys)

if keys:
    key = keys[0]
    print("source:", api.get_table_entry_source_string(table_id, key))
    print("namespace:", api.get_table_namespace(table_id))
```

## 限制和注意事项

- 本类全部为 `BlueprintPure` 只读查询，不改动运行时状态；可安全用于校验本地化资产引用与定位缺失条目。
- `get_table_entry_source_string` / `get_table_entry_meta_data` 对未注册条目返回空字符串，不区分"空条目"与"条目不存在"，需先用 `is_registered_table_entry` 校验。
- 键在字符串表内的大小写即作为键名；读取前按资产定义的确切键名传入，避免大小写不一致导致空结果。
- 返回空数组（未注册表、无键、无元数据）按数据缺失处理；字符串表系统不可用时按 `BLOCKED_TOOLING` 处理。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。