# DataTableFunctionLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/DataTableFunctionLibrary.h` 整理 `UDataTableFunctionLibrary`（继承 `UBlueprintFunctionLibrary`）中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的 static 成员。Python 方法名取 `meta=(ScriptMethod=...)` 值并转 snake_case；无 ScriptMethod 的方法名由 C++ 函数名派生。每个方法给出 C++ 签名、Python 参数、返回约定与完整示例；完整示例即调用样板。

## 1. 入口与命名约定

```python
import unreal

table = unreal.load_asset("/Game/Data/DT_Items")
row_names = unreal.UDataTableFunctionLibrary.get_row_names(table)
```

- 每个方法的第一实参通常为目标数据表资产（`unreal.DataTable`）。
- 带 `meta=(ScriptMethod=...)` 的函数：Python 端调用名 = ScriptMethod 值转 snake_case，例如 `GetDataTableRowStruct` 的 ScriptMethod 为 `GetRowStruct` → `get_row_struct`；`DoesDataTableRowExist` → `does_row_exist`。
- 无 ScriptMethod 的成员按 C++ 函数名转 snake_case，例如 `RemoveDataTableRow` → `remove_data_table_row`。
- 精确 Python 暴露名以目标 5.6 编辑器实测为准（`dir(unreal.UDataTableFunctionLibrary)` 核对）。
- 导入（Fill）、导出（Export）与删除行方法位于 `#if WITH_EDITOR` 段，仅编辑器 Python 可用。

## 2. Out / ByRef 返回约定

| 组合 | 返回约定 |
| --- | --- |
| `void` + 单个 Out/ByRef 参数 | 直接返回该 Out 参数的值 |
| `void` + 多个 Out/ByRef 参数 | 按声明顺序返回元组 `(out1, out2, ...)` |
| 有返回值 + Out/ByRef 参数 | 返回 `(return_value, out1, ...)`，返回值在首位 |
| 无 Out 且无返回值 | 返回 `None` |

类型映射：

| C++ | Python |
| --- | --- |
| `const UDataTable*` | `unreal.DataTable` |
| `UCurveTable*` | `unreal.CurveTable` |
| `FName` | `unreal.Name`（通常可直接传 str） |
| `FString` | `str` |
| `bool` | `bool` |
| `float` | `float` |
| `UScriptStruct*` | `unreal.ScriptStruct` |
| `TArray<FName>` | `list[Name]` |
| `TArray<FString>` | `list[str]` |
| `EEvaluateCurveTableResult` | `int`（0=RowFound，1=RowNotFound） |

## 3. 行结构与行/列探测

### get_row_struct

- C++ 签名：`static const UScriptStruct* GetDataTableRowStruct(const UDataTable* Table)`；BlueprintPure
- Python：`get_row_struct(table) -> ScriptStruct`（返回 `unreal.ScriptStruct`；空表返回 `None`）
- 说明：获取数据表使用的行结构（RowStruct），用于校验导入行结构是否匹配。
- 示例：

```python
s = unreal.UDataTableFunctionLibrary.get_row_struct(table)
print("RowStruct:", s)
```

### does_row_exist

- C++ 签名：`static bool DoesDataTableRowExist(const UDataTable* Table, FName RowName)`
- Python：`does_row_exist(table, row_name) -> bool`
- 示例：

```python
exists = unreal.UDataTableFunctionLibrary.does_row_exist(table, "Item_Sword")
print("exists:", exists)
```

### get_row_names

- C++ 签名：`static void GetDataTableRowNames(const UDataTable* Table, TArray<FName>& OutRowNames)`
- Python：`get_row_names(table) -> Array[Name]`（单个 Out 参数直接返回）
- 示例：

```python
rows = unreal.UDataTableFunctionLibrary.get_row_names(table)
print([str(r) for r in rows])
```

### get_column_names

- C++ 签名：`static void GetDataTableColumnNames(const UDataTable* Table, TArray<FName>& OutColumnNames)`
- Python：`get_column_names(table) -> Array[Name]`（原始属性名）
- 示例：

```python
cols = unreal.UDataTableFunctionLibrary.get_column_names(table)
```

### get_column_export_names

- C++ 签名：`static void GetDataTableColumnExportNames(const UDataTable* Table, TArray<FString>& OutExportColumnNames)`
- Python：`get_column_export_names(table) -> Array[str]`（CSV/JSON 友好导出名）
- 示例：

```python
exports = unreal.UDataTableFunctionLibrary.get_column_export_names(table)
```

### get_column_name_from_export_name

- C++ 签名：`static bool GetDataTableColumnNameFromExportName(const UDataTable* Table, const FString& ColumnExportName, FName& OutColumnName)`
- Python：`get_column_name_from_export_name(table, column_export_name) -> tuple[bool, Name]`
- 说明：把友好导出名反查到原始属性名（配合 `get_column_names` / `get_column_as_string`）。
- 示例：

```python
ok, raw_name = unreal.UDataTableFunctionLibrary.get_column_name_from_export_name(
    table, "ItemName")
```

### get_column_as_string

- C++ 签名：`static TArray<FString> GetDataTableColumnAsString(const UDataTable* DataTable, FName PropertyName)`
- Python：`get_column_as_string(table, property_name) -> Array[str]`（不含行名列）
- 说明：按列读取全部行的属性值；属性名须为原始属性名。
- 示例：

```python
values = unreal.UDataTableFunctionLibrary.get_column_as_string(table, "ItemName")
```

## 4. 行删除（WITH_EDITOR，仅编辑器）

### remove_data_table_row

- C++ 签名：`static void RemoveDataTableRow(UDataTable* DataTable, const FName& RowName)`
- Python：`remove_data_table_row(table, row_name) -> None`
- 说明：删除指定行；属资产内容修改，完成后需编辑器 API 固化并由审计/QA 独立验收。
- 示例：

```python
unreal.UDataTableFunctionLibrary.remove_data_table_row(table, "Item_Retired")
unreal.EditorAssetLibrary.save_asset("/Game/Data/DT_Items")
```

## 5. 导入与导出（WITH_EDITOR，仅编辑器）

### export_to_csv_string

- C++ 签名：`static bool ExportDataTableToCSVString(const UDataTable* DataTable, FString& OutCSVString)`
- Python：`export_to_csv_string(table) -> tuple[bool, str]`
- 示例：

```python
ok, csv_text = unreal.UDataTableFunctionLibrary.export_to_csv_string(table)
```

### export_to_csv_file

- C++ 签名：`static bool ExportDataTableToCSVFile(const UDataTable* DataTable, const FString& CSVFilePath)`
- Python：`export_to_csv_file(table, csv_file_path) -> bool`（文件为 UTF-8）
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.export_to_csv_file(
    table, "C:/Dev/out/DT_Items.csv")
```

### export_to_json_string

- C++ 签名：`static bool ExportDataTableToJSONString(const UDataTable* DataTable, FString& OutJSONString)`
- Python：`export_to_json_string(table) -> tuple[bool, str]`
- 示例：

```python
ok, json_text = unreal.UDataTableFunctionLibrary.export_to_json_string(table)
```

### export_to_json_file

- C++ 签名：`static bool ExportDataTableToJSONFile(const UDataTable* DataTable, const FString& JSONFilePath)`
- Python：`export_to_json_file(table, json_file_path) -> bool`（文件为 UTF-8）
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.export_to_json_file(
    table, "C:/Dev/out/DT_Items.json")
```

### fill_from_csv_string

- C++ 签名：`static bool FillDataTableFromCSVString(UDataTable* DataTable, const FString& CSVString, UScriptStruct* ImportRowStruct = nullptr)`
- Python：`fill_from_csv_string(table, csv_string, import_row_struct=None) -> bool`
- 说明：先清空再填充；传入行结构时强制自动化导入（不弹窗）。属破坏性写路径。
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.fill_from_csv_string(
    table, csv_text, import_row_struct=row_struct)
```

### fill_from_csv_file

- C++ 签名：`static bool FillDataTableFromCSVFile(UDataTable* DataTable, const FString& CSVFilePath, UScriptStruct* ImportRowStruct = nullptr)`
- Python：`fill_from_csv_file(table, csv_file_path, import_row_struct=None) -> bool`
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.fill_from_csv_file(table, "C:/Dev/in/DT_Items.csv")
```

### fill_from_json_string

- C++ 签名：`static bool FillDataTableFromJSONString(UDataTable* DataTable, const FString& JSONString, UScriptStruct* ImportRowStruct = nullptr)`
- Python：`fill_from_json_string(table, json_string, import_row_struct=None) -> bool`
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.fill_from_json_string(table, json_text)
```

### fill_from_json_file

- C++ 签名：`static bool FillDataTableFromJSONFile(UDataTable* DataTable, const FString& JSONFilePath, UScriptStruct* ImportRowStruct = nullptr)`
- Python：`fill_from_json_file(table, json_file_path, import_row_struct=None) -> bool`
- 示例：

```python
ok = unreal.UDataTableFunctionLibrary.fill_from_json_file(table, "C:/Dev/in/DT_Items.json")
```

## 6. 同库曲线表成员

### evaluate_curve_table_row

- C++ 签名：`static void EvaluateCurveTableRow(UCurveTable* CurveTable, FName RowName, float InXY, TEnumAsByte<EEvaluateCurveTableResult::Type>& OutResult, float& OutXY, const FString& ContextString)`
- Python：`evaluate_curve_table_row(curve_table, row_name, in_xy, context_string) -> tuple[int, float]`
- 说明：首参为 `UCurveTable*` 而非数据表；两个 Out 参数按声明顺序组成元组（`OutResult` 枚举，0=RowFound，1=RowNotFound）。
- 示例：

```python
result, out_xy = unreal.UDataTableFunctionLibrary.evaluate_curve_table_row(
    curve_table, "Speed", 0.5, "evaluate context")
```

## 7. 完整示例：CSV 导入并核对行数

```python
import unreal

def main():
    table = unreal.load_asset("/Game/Data/DT_Items")
    if table is None or not isinstance(table, unreal.DataTable):
        print({"status": "BLOCKED_INPUT", "reason": "data table not loadable"})
        return

    ok = unreal.UDataTableFunctionLibrary.fill_from_csv_file(
        table, "C:/Dev/in/DT_Items.csv")
    if not ok:
        print({"status": "BLOCKED_TOOLING", "reason": "fill_from_csv_file failed"})
        return

    rows = unreal.UDataTableFunctionLibrary.get_row_names(table)
    exports = unreal.UDataTableFunctionLibrary.get_column_export_names(table)

    unreal.EditorAssetLibrary.save_asset("/Game/Data/DT_Items")

    print({
        "status": "SAVED_PENDING_AUDIT",
        "row_count": len(rows),
        "columns": [str(c) for c in exports],
        "note": "已完成编辑器 API 固化，尚待审计/QA 独立验收",
    })

if __name__ == "__main__":
    main()
```

## 8. 阻塞状态与诚实性

- `BLOCKED_INPUT`：资产不可加载 / 类型不符 / 缺少必要输入。
- `BLOCKED_TOOLING`：无编辑器环境或 `WITH_EDITOR` 方法不可用；非编辑器环境不得声称导入导出已执行。
- `fill_*` 会清空并重填数据表资产内容；`export_to_*_file`、`remove_data_table_row`、`fill_*` 均属写操作，完成后必须经编辑器 API 固化（`unreal.EditorAssetLibrary.save_asset`）并由审计/QA 独立验收。
- 写路径执行后未固化或未验收时，状态标记为 `SAVED_PENDING_AUDIT` / `BLOCKED_UNVERIFIED`，不等同于"已完成"。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的静态成员；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。