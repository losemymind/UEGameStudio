---
name: data-table-function-library
description: UDataTableFunctionLibrary（UE 5.6）DataTable 函数库 - 行/列探测、CSV/JSON 导入导出与行删除；在 Agent 需要通过 unreal Python 对数据表做读取/导入/导出/删除行时使用
risk: critical
category: development
tags: [ue5.6, data-table, python, blueprint-function-library]
---

# DataTableFunctionLibrary - DataTable Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 对数据表做读取/导入/导出/删除行时使用本 skill（description 触发场景）。
- 本 skill 只在与 data-table-function-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UDataTableFunctionLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/DataTableFunctionLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UBlueprintFunctionLibrary` 的 static 函数在 Python 中以类方法形式暴露在 `unreal.UDataTableFunctionLibrary` 上，首个实参通常是目标数据表资产：

```python
import unreal

table = unreal.load_asset("/Game/Data/DT_Items")
row_names = unreal.UDataTableFunctionLibrary.get_row_names(table)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.UDataTableFunctionLibrary)` 核对）。
- 带 `WITH_EDITOR` 限定的导入/导出方法仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 行结构 | `get_row_struct(table)` | `const UScriptStruct* GetDataTableRowStruct(const UDataTable*)` | `ScriptStruct` 或 `None` |
| 探测 | `does_row_exist(table, row_name)` | `bool DoesDataTableRowExist(const UDataTable*, FName)` | `bool` |
| 读取 | `get_row_names(table)` | `void GetDataTableRowNames(const UDataTable*, TArray<FName>&)` | `Array[Name]` |
| 读取 | `get_column_names(table)` | `void GetDataTableColumnNames(const UDataTable*, TArray<FName>&)` | `Array[Name]` |
| 读取 | `get_column_export_names(table)` | `void GetDataTableColumnExportNames(const UDataTable*, TArray<FString>&)` | `Array[str]` |
| 读取 | `get_column_name_from_export_name(table, column_export_name)` | `bool GetDataTableColumnNameFromExportName(const UDataTable*, const FString&, FName&)` | `(bool, Name)` |
| 读取 | `get_column_as_string(table, property_name)` | `TArray<FString> GetDataTableColumnAsString(const UDataTable*, FName)` | `Array[str]` |
| 删除 | `remove_data_table_row(table, row_name)` | `void RemoveDataTableRow(UDataTable*, const FName&)`（WITH_EDITOR） | `None` |
| 导入 | `fill_from_csv_string(table, csv_string, import_row_struct=None)` | `bool FillDataTableFromCSVString(UDataTable*, const FString&, UScriptStruct*)`（WITH_EDITOR） | `bool` |
| 导入 | `fill_from_csv_file(table, csv_file_path, import_row_struct=None)` | `bool FillDataTableFromCSVFile(UDataTable*, const FString&, UScriptStruct*)`（WITH_EDITOR） | `bool` |
| 导入 | `fill_from_json_string(table, json_string, import_row_struct=None)` | `bool FillDataTableFromJSONString(UDataTable*, const FString&, UScriptStruct*)`（WITH_EDITOR） | `bool` |
| 导入 | `fill_from_json_file(table, json_file_path, import_row_struct=None)` | `bool FillDataTableFromJSONFile(UDataTable*, const FString&, UScriptStruct*)`（WITH_EDITOR） | `bool` |
| 导出 | `export_to_csv_string(table)` | `bool ExportDataTableToCSVString(const UDataTable*, FString&)`（WITH_EDITOR） | `(bool, str)` |
| 导出 | `export_to_csv_file(table, csv_file_path)` | `bool ExportDataTableToCSVFile(const UDataTable*, const FString&)`（WITH_EDITOR） | `bool` |
| 导出 | `export_to_json_string(table)` | `bool ExportDataTableToJSONString(const UDataTable*, FString&)`（WITH_EDITOR） | `(bool, str)` |
| 导出 | `export_to_json_file(table, json_file_path)` | `bool ExportDataTableToJSONFile(const UDataTable*, const FString&)`（WITH_EDITOR） | `bool` |
| 曲线表 | `evaluate_curve_table_row(curve_table, row_name, in_xy, context_string)` | `void EvaluateCurveTableRow(UCurveTable*, FName, float, TEnumAsByte<EEvaluateCurveTableResult::Type>&, float&, const FString&)` | `(int, float)` |

## 示例

```python
import unreal

path = "/Game/Data/DT_Items"
table = unreal.load_asset(path)
if table is None or not isinstance(table, unreal.DataTable):
    print("BLOCKED_INPUT: data table not loadable")
    raise SystemExit(1)

row_names = unreal.UDataTableFunctionLibrary.get_row_names(table)
print("row count:", len(row_names))

exists = unreal.UDataTableFunctionLibrary.does_row_exist(
    table, unreal.Name("Item_Sword"))
print("Item_Sword exists:", exists)

ok, csv_text = unreal.UDataTableFunctionLibrary.export_to_csv_string(table)
print("csv export:", ok)
```

## 限制和注意事项

- `get_*` 探测方法为只读；`fill_*` 会先清空再填充数据表资产内容，`export_to_*_file`、`remove_data_table_row`、`fill_*` 均属写入操作，完成后必须经编辑器 API 固化（`unreal.EditorAssetLibrary.save_asset`）并由审计/QA 独立验收。
- `WITH_EDITOR` 限定的方法只在编辑器 Python 可用；非编辑器环境调用会失败，应输出 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 缺资产路径/表类型等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。