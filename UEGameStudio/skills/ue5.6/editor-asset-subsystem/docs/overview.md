# EditorAssetSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/UnrealEd/Public/Subsystems/EditorAssetSubsystem.h` 整理 `UEditorAssetSubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的全部成员。Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 `ScriptMethod` 时按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。每个成员给出 C++ 签名、Python 参数、返回约定与完整示例。

## 获取子系统

```python
import unreal

editor_asset_subsystem = unreal.get_editor_subsystem(unreal.EditorAssetSubsystem)
if editor_asset_subsystem is None:
    raise RuntimeError("BLOCKED_TOOLING: EditorAssetSubsystem 不可用")
```

## 通用约定

- 路径形式已在前文定义。完整路径可由已加载对象获得：

```python
name = editor_asset_subsystem.get_path_name_for_loaded_asset(asset)
```

- `FName` 参数在 Python 中用字符串传入，如 `"SourceScan"`。
- 返回 `None` 视为失败；空数组视为没有候选或失败，按阻塞规则处理。

## 加载与查询

### load_asset

- C++ 签名：`UObject* LoadAsset(FString AssetPath)`（BlueprintCallable）
- Python：`load_asset(asset_path) -> Object`
- 说明：加载资产。若对象已加载则直接返回，否则加载；失败返回 `None`。
- 示例：

```python
mesh = editor_asset_subsystem.load_asset("/Game/Meshes/SM_Box")
if mesh is None:
    print("BLOCKED_INPUT: asset not loadable")
```

### load_blueprint_class

- C++ 签名：`UClass* LoadBlueprintClass(FString AssetPath)`（BlueprintCallable）
- Python：`load_blueprint_class(asset_path) -> Class`
- 说明：加载 Blueprint 资产并返回其生成的类；失败返回 `None`。
- 示例：

```python
bp_class = editor_asset_subsystem.load_blueprint_class("/Game/Blueprints/BP_Prop")
if bp_class is None:
    print("BLOCKED_INPUT: blueprint class not loadable")
else:
    assert bp_class.is_child_of(unreal.Actor)
```

### get_path_name_for_loaded_asset

- C++ 签名：`FString GetPathNameForLoadedAsset(UObject* LoadedAsset)`（BlueprintCallable）
- Python：`get_path_name_for_loaded_asset(loaded_asset) -> str`
- 说明：返回已加载资产的完整路径，格式 `/Game/MyFolder/MyAsset.MyAsset`，类似 `GetPathName()`。
- 示例：

```python
path = editor_asset_subsystem.get_path_name_for_loaded_asset(mesh)
print(path)
```

### find_asset_data

- C++ 签名：`FAssetData FindAssetData(FString AssetPath)`（BlueprintCallable）
- Python：`find_asset_data(asset_path) -> AssetData`
- 说明：返回资产的 `AssetData`（无需加载资产即可查询注册表元数据），可用于 AssetRegistryHelpers。
- 示例：

```python
data = editor_asset_subsystem.find_asset_data("/Game/Meshes/SM_Box")
if data.is_valid():
    print(data.asset_name, data.asset_class)
```

### does_asset_exist

- C++ 签名：`bool DoesAssetExist(FString AssetPath)`（BlueprintCallable）
- Python：`does_asset_exist(asset_path) -> bool`
- 说明：检查资产是否在 Asset Registry 中存在且有效。
- 示例：

```python
if not editor_asset_subsystem.does_asset_exist(path):
    print("BLOCKED_INPUT: asset missing")
```

### do_assets_exist

- C++ 签名：`bool DoAssetsExist(TArray<FString> AssetPaths)`（BlueprintCallable）
- Python：`do_assets_exist(asset_paths) -> bool`
- 说明：所有给定资产均存在且有效才返回 `True`。
- 示例：

```python
all_ok = editor_asset_subsystem.do_assets_exist(["/Game/A/x", "/Game/B/y"])
```

### find_package_referencers_for_asset

- C++ 签名：`TArray<FString> FindPackageReferencersForAsset(FString AssetPath, bool bLoadAssetsToConfirm = false)`（BlueprintCallable，`AdvancedDisplay=1`）
- Python：`find_package_referencers_for_asset(asset_path, b_load_assets_to_confirm=False) -> Array[str]`
- 说明：查找引用该资产的所有 Package 路径，只查 Soft 与 Hard 依赖；`b_load_assets_to_confirm=True` 时加载资产与潜在引用者以确认依赖。Package 依赖带缓存，全部加载重存前可能出现误报。
- 示例：

```python
refs = editor_asset_subsystem.find_package_referencers_for_asset(
    "/Game/Shared/SM_Pillar",
    b_load_assets_to_confirm=True,
)
print("referencers:", refs)
```

## 复制

### duplicate_loaded_asset

- C++ 签名：`UObject* DuplicateLoadedAsset(UObject* SourceAsset, FString DestinationAssetPath)`（BlueprintCallable）
- Python：`duplicate_loaded_asset(source_asset, destination_asset_path) -> Object`
- 说明：复制已加载资产，会尝试 Checkout 目标文件。
- 示例：

```python
copy = editor_asset_subsystem.duplicate_loaded_asset(mesh, "/Game/Meshes/SM_Box_V2")
if copy is None:
    print("duplicate failed")
```

### duplicate_asset

- C++ 签名：`UObject* DuplicateAsset(FString SourceAssetPath, FString DestinationAssetPath)`（BlueprintCallable）
- Python：`duplicate_asset(source_asset_path, destination_asset_path) -> Object`
- 说明：按路径复制资产，复制前会加载源资产，并尝试 Checkout 目标文件。
- 示例：

```python
dup = editor_asset_subsystem.duplicate_asset(
    "/Game/Meshes/SM_Box",
    "/Game/Meshes/SM_Box_Batch",
)
```

### duplicate_directory

- C++ 签名：`bool DuplicateDirectory(FString SourceDirectoryPath, FString DestinationDirectoryPath)`（BlueprintCallable）
- Python：`duplicate_directory(source_directory_path, destination_directory_path) -> bool`
- 说明：整目录复制，复制前加载其中资产并尝试 Checkout 目标文件。
- 示例：

```python
ok = editor_asset_subsystem.duplicate_directory("/Game/Meshes", "/Game/Meshes_Backup")
```

## 重命名与移动

### rename_loaded_asset

- C++ 签名：`bool RenameLoadedAsset(UObject* SourceAsset, FString DestinationAssetPath)`（BlueprintCallable）
- Python：`rename_loaded_asset(source_asset, destination_asset_path) -> bool`
- 说明：对已加载资产执行等效 Move 的重命名，会尝试 Checkout 文件。
- 示例：

```python
ok = editor_asset_subsystem.rename_loaded_asset(mesh, "/Game/Meshes/SM_Box_01")
```

### rename_asset

- C++ 签名：`bool RenameAsset(FString SourceAssetPath, FString DestinationAssetPath)`（BlueprintCallable）
- Python：`rename_asset(source_asset_path, destination_asset_path) -> bool`
- 说明：按路径重命名（等效移动），重命名前加载资产并尝试 Checkout。
- 示例：

```python
ok = editor_asset_subsystem.rename_asset(
    "/Game/Meshes/SM_Box",
    "/Game/Architecture/SM_Box",
)
if not ok:
    print("rename/move failed")
```

### rename_directory

- C++ 签名：`bool RenameDirectory(FString SourceDirectoryPath, FString DestinationDirectoryPath)`（BlueprintCallable）
- Python：`rename_directory(source_directory_path, destination_directory_path) -> bool`
- 说明：整目录重命名（移动其中全部资产），会加载并尝试 Checkout 文件。
- 示例：

```python
ok = editor_asset_subsystem.rename_directory("/Game/Meshes", "/Game/Assets/Meshes")
```

## 删除与合并

### delete_loaded_asset

- C++ 签名：`bool DeleteLoadedAsset(UObject* AssetToDelete)`（BlueprintCallable）
- Python：`delete_loaded_asset(asset_to_delete) -> bool`
- 说明：删除已加载资产。Force Delete：不检查其他关卡/Actor 的引用，关闭资产编辑器，可能清空 Undo 历史，并尝试将文件标记为删除。
- 示例：

```python
ok = editor_asset_subsystem.delete_loaded_asset(copy)
if not ok:
    print("delete failed")
```

### delete_loaded_assets

- C++ 签名：`bool DeleteLoadedAssets(TArray<UObject*> AssetsToDelete)`（BlueprintCallable）
- Python：`delete_loaded_assets(assets_to_delete) -> bool`
- 说明：批量删除已加载资产，语义同 `delete_loaded_asset`。
- 示例：

```python
ok = editor_asset_subsystem.delete_loaded_assets(obsolete_assets)
```

### delete_asset

- C++ 签名：`bool DeleteAsset(FString AssetPathToDelete)`（BlueprintCallable）
- Python：`delete_asset(asset_path_to_delete) -> bool`
- 说明：按路径删除资产所在 Package（包内全部对象一并删除），删除前会加载资产。
- 示例：

```python
ok = editor_asset_subsystem.delete_asset("/Game/Meshes/SM_Temp")
```

### delete_directory

- C++ 签名：`bool DeleteDirectory(FString DirectoryPath)`（BlueprintCallable）
- Python：`delete_directory(directory_path) -> bool`
- 说明：递归删除目录内全部 Package；目录随后为空时一并删除。Force Delete 语义同资产删除。
- 示例：

```python
ok = editor_asset_subsystem.delete_directory("/Game/Meshes/Scratch")
```

### consolidate_assets

- C++ 签名：`bool ConsolidateAssets(UObject* AssetToConsolidateTo, TArray<UObject*> AssetsToConsolidate)`（BlueprintCallable）
- Python：`consolidate_assets(asset_to_consolidate_to, assets_to_consolidate) -> bool`
- 说明：把 `AssetsToConsolidate` 的所有引用替换为 `AssetToConsolidateTo`，随后删除被合并资产并留下 Redirector；成功后自动保存被修改对象。**被合并资产会被删除**。
- 示例：

```python
target = editor_asset_subsystem.load_asset("/Game/Meshes/SM_Main")
victims = [editor_asset_subsystem.load_asset(p) for p in dup_paths]
ok = editor_asset_subsystem.consolidate_assets(target, victims)
```

## 修订控制

### checkout_loaded_asset

- C++ 签名：`bool CheckoutLoadedAsset(UObject* AssetToCheckout)`（BlueprintCallable）
- Python：`checkout_loaded_asset(asset_to_checkout) -> bool`
- 说明：Checkout 对象对应资产。
- 示例：

```python
ok = editor_asset_subsystem.checkout_loaded_asset(mesh)
```

### checkout_loaded_assets

- C++ 签名：`bool CheckoutLoadedAssets(TArray<UObject*> AssetsToCheckout)`（BlueprintCallable）
- Python：`checkout_loaded_assets(assets_to_checkout) -> bool`
- 说明：批量 Checkout 已加载资产。
- 示例：

```python
ok = editor_asset_subsystem.checkout_loaded_assets(assets)
```

### checkout_asset

- C++ 签名：`bool CheckoutAsset(FString AssetToCheckout)`（BlueprintCallable）
- Python：`checkout_asset(asset_to_checkout) -> bool`
- 说明：按路径 Checkout 资产。
- 示例：

```python
ok = editor_asset_subsystem.checkout_asset("/Game/Meshes/SM_Box")
if not ok:
    print("BLOCKED_TOOLING: checkout failed")
```

### checkout_directory

- C++ 签名：`bool CheckoutDirectory(FString DirectoryPath, bool bRecursive = true)`（BlueprintCallable）
- Python：`checkout_directory(directory_path, b_recursive=True) -> bool`
- 说明：Checkout 目录内全部资产，需要时先加载；`b_recursive=True` 时递归子目录。
- 示例：

```python
ok = editor_asset_subsystem.checkout_directory("/Game/Meshes", b_recursive=True)
```

### set_dirty_flag

- C++ 签名：`bool SetDirtyFlag(UObject* Object, const bool bDirtyState)`（BlueprintCallable）
- Python：`set_dirty_flag(object, b_dirty_state) -> bool`
- 说明：设置资产 Package 的 dirty 状态；`True` 表示该包需要保存。
- 示例：

```python
ok = editor_asset_subsystem.set_dirty_flag(mesh, True)
```

## 保存

### save_loaded_asset

- C++ 签名：`bool SaveLoadedAsset(UObject* AssetToSave, bool bOnlyIfIsDirty = true)`（BlueprintCallable）
- Python：`save_loaded_asset(asset_to_save, b_only_if_is_dirty=True) -> bool`
- 说明：保存资产所在 Package（包内全部对象），会尝试 Checkout 文件；默认只保存 dirty 资产。
- 示例：

```python
ok = editor_asset_subsystem.save_loaded_asset(dup, b_only_if_is_dirty=False)
```

### save_loaded_assets

- C++ 签名：`bool SaveLoadedAssets(TArray<UObject*> AssetsToSave, bool bOnlyIfIsDirty = true)`（BlueprintCallable）
- Python：`save_loaded_assets(assets_to_save, b_only_if_is_dirty=True) -> bool`
- 说明：批量保存已加载资产所在 Package。
- 示例：

```python
ok = editor_asset_subsystem.save_loaded_assets(assets, b_only_if_is_dirty=True)
```

### save_asset

- C++ 签名：`bool SaveAsset(FString AssetToSave, bool bOnlyIfIsDirty = true)`（BlueprintCallable）
- Python：`save_asset(asset_to_save, b_only_if_is_dirty=True) -> bool`
- 说明：按路径保存资产所在 Package，保存前加载资产并尝试 Checkout。
- 示例：

```python
ok = editor_asset_subsystem.save_asset("/Game/Meshes/SM_Box", b_only_if_is_dirty=True)
```

### save_directory

- C++ 签名：`bool SaveDirectory(FString DirectoryPath, bool bOnlyIfIsDirty = true, bool bRecursive = true)`（BlueprintCallable）
- Python：`save_directory(directory_path, b_only_if_is_dirty=True, b_recursive=True) -> bool`
- 说明：保存目录内全部资产所在 Package，保存前加载并尝试 Checkout；可递归子目录。
- 示例：

```python
ok = editor_asset_subsystem.save_directory("/Game/Meshes", b_recursive=True)
```

## 目录

### does_directory_exist

- C++ 签名：`bool DoesDirectoryExist(FString DirectoryPath)`（BlueprintCallable）
- Python：`does_directory_exist(directory_path) -> bool`
- 说明：检查目录是否存在且有效。
- 示例：

```python
if not editor_asset_subsystem.does_directory_exist("/Game/Meshes"):
    print("BLOCKED_INPUT: directory missing")
```

### does_directory_contain_assets

- C++ 签名：`bool DoesDirectoryContainAssets(FString DirectoryPath, bool bRecursive = true)`（BlueprintCallable）
- Python：`does_directory_contain_assets(directory_path, b_recursive=True) -> bool`
- 说明：检查目录内是否含有资产。
- 示例：

```python
has_any = editor_asset_subsystem.does_directory_contain_assets("/Game/Meshes")
```

### make_directory

- C++ 签名：`bool MakeDirectory(FString DirectoryPath)`（BlueprintCallable）
- Python：`make_directory(directory_path) -> bool`
- 说明：在磁盘创建目录。
- 示例：

```python
ok = editor_asset_subsystem.make_directory("/Game/Meshes/New")
```

### list_assets

- C++ 签名：`TArray<FString> ListAssets(FString DirectoryPath, bool bRecursive = true, bool bIncludeFolder = false)`（BlueprintCallable）
- Python：`list_assets(directory_path, b_recursive=True, b_include_folder=False) -> Array[str]`
- 说明：返回目录下资产路径列表；`b_include_folder=True` 时结果包含文件夹名。
- 示例：

```python
paths = editor_asset_subsystem.list_assets("/Game/Meshes", b_recursive=True)
print("asset count:", len(paths))
```

### list_assets_by_tag_value

- C++ 签名：`TArray<FString> ListAssetsByTagValue(FName TagName, const FString& TagValue)`（BlueprintCallable）
- Python：`list_assets_by_tag_value(tag_name, tag_value) -> Array[str]`
- 说明：返回 Asset Registry 中具有指定 Tag/Value 对的所有资产路径。
- 示例：

```python
paths = editor_asset_subsystem.list_assets_by_tag_value("AssetType", "hero_prop")
```

## 元数据与标签

### get_tag_values

- C++ 签名：`TMap<FName, FString> GetTagValues(FString AssetPath)`（BlueprintCallable）
- Python：`get_tag_values(asset_path) -> Dict[str, str]`
- 说明：从 Asset Registry 获取（可能未加载的）资产的全部 Tag 值，按字符串返回。
- 示例：

```python
tags = editor_asset_subsystem.get_tag_values("/Game/Meshes/SM_Box")
for k, v in tags.items():
    print(k, v)
```

### get_metadata_tag_values

- C++ 签名：`TMap<FName, FString> GetMetadataTagValues(UObject* Object)`（BlueprintCallable）
- Python：`get_metadata_tag_values(object) -> Dict[str, str]`
- 说明：获取已加载资产元数据的全部 Tag/Value。
- 示例：

```python
meta = editor_asset_subsystem.get_metadata_tag_values(asset)
```

### get_metadata_tag

- C++ 签名：`FString GetMetadataTag(UObject* Object, FName Tag)`（BlueprintCallable）
- Python：`get_metadata_tag(object, tag) -> str`
- 说明：获取已加载资产指定元数据 Tag 的值；Tag 不存在时返回空字符串。
- 示例：

```python
value = editor_asset_subsystem.get_metadata_tag(asset, "SourceScan")
```

### set_metadata_tag

- C++ 签名：`void SetMetadataTag(UObject* Object, FName Tag, const FString& Value)`（BlueprintCallable）
- Python：`set_metadata_tag(object, tag, value) -> None`
- 说明：设置已加载资产元数据 Tag 的值（元数据写入，修改资产生命周期状态）。
- 示例：

```python
editor_asset_subsystem.set_metadata_tag(asset, "SourceScan", "auto")
```

### remove_metadata_tag

- C++ 签名：`void RemoveMetadataTag(UObject* Object, FName Tag)`（BlueprintCallable）
- Python：`remove_metadata_tag(object, tag) -> None`
- 说明：删除已加载资产上的元数据 Tag。
- 示例：

```python
editor_asset_subsystem.remove_metadata_tag(asset, "SourceScan")
```

### get_all_assets_by_meta_data_tags

- C++ 签名：`TArray<FAssetData> GetAllAssetsByMetaDataTags(const TSet<FName>& RequiredTags, const TSet<UClass*>& AllowedClasses)`（BlueprintCallable）
- Python：`get_all_assets_by_meta_data_tags(required_tags, allowed_classes) -> Array[AssetData]`
- 说明：返回同时具有全部给定 Tag、且类在允许集合内的资产。Python 中集合用 `set`，类集合用 `unreal.load_class` 结果。
- 示例：

```python
data = editor_asset_subsystem.get_all_assets_by_meta_data_tags(
    {"hero_prop"},
    {unreal.load_class("/Script/Engine.StaticMesh")},
)
```

### sort_by_meta_data

- C++ 签名：`bool SortByMetaData(UPARAM(Ref) TArray<FAssetData>& Assets, FName MetaDataTag, EEditorAssetMetaDataSortType MetaDataType, EEditorAssetSortOrder SortOrder)`（BlueprintCallable）
- Python：`sort_by_meta_data(assets, meta_data_tag, meta_data_type, sort_order) -> (bool, Array[AssetData])`
- 说明：按元数据值类型对资产列表排序（支持字符串/数值/日期时间），`Assets` 为 Ref 输入输出参数；原列表有资产缺少该 Tag 时返回 `False` 且不排序。按返回值+Out 约定返回元组。
- 示例：

```python
items = editor_asset_subsystem.list_assets("/Game/Props", b_recursive=True)
if not items:
    print("BLOCKED_INPUT: no assets")
    raise SystemExit(1)

data_list = []
for p in items:
    d = editor_asset_subsystem.find_asset_data(p)
    if d.is_valid():
        data_list.append(d)

sorted_ok, data_list = editor_asset_subsystem.sort_by_meta_data(
    data_list,
    "Priority",
    unreal.EditorAssetMetaDataSortType.NUMERIC,
    unreal.EditorAssetSortOrder.DESCENDING,
)
print("sorted:", sorted_ok)
```

## Cook 辅助

### get_asset_filename_length_for_cooking

- C++ 签名：`int32 GetAssetFilenameLengthForCooking(FString AssetPath)`（BlueprintCallable）
- Python：`get_asset_filename_length_for_cooking(asset_path) -> int`
- 说明：返回按路径资产的烹饪包名与路径计算长度。
- 示例：

```python
length = editor_asset_subsystem.get_asset_filename_length_for_cooking("/Game/Meshes/SM_Box")
```

### get_loaded_asset_filename_length_for_cooking

- C++ 签名：`int32 GetLoadedAssetFilenameLengthForCooking(const UObject* Asset)`（BlueprintCallable）
- Python：`get_loaded_asset_filename_length_for_cooking(asset) -> int`
- 说明：返回已加载对象的烹饪包名与路径计算长度。
- 示例：

```python
length = editor_asset_subsystem.get_loaded_asset_filename_length_for_cooking(mesh)
```

## 事件挂钩

### add_on_extract_asset_from_file

- C++ 签名：`void AddOnExtractAssetFromFile(FOnExtractAssetFromFileDynamic Delegate)`（BlueprintCallable）
- Python：`add_on_extract_asset_from_file(delegate) -> None`
- 说明：注册回调以从文件（如拖放操作）提取资产；回调参数为 `(Array[str] Files, Array[AssetData] AssetDataArray)`。
- 示例：

```python
def on_extract(files, asset_data_array):
    print("extract from:", files)

editor_asset_subsystem.add_on_extract_asset_from_file(static_method(on_extract))
```

### remove_on_extract_asset_from_file

- C++ 签名：`void RemoveOnExtractAssetFromFile(FOnExtractAssetFromFileDynamic Delegate)`（BlueprintCallable）
- Python：`remove_on_extract_asset_from_file(delegate) -> None`
- 说明：移除之前注册的提取回调。
- 示例：

```python
editor_asset_subsystem.remove_on_extract_asset_from_file(static_method(on_extract))
```

## 完整示例：目录拷贝加元数据标注

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.EditorAssetSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "EditorAssetSubsystem 不可用"})
        return

    src = "/Game/Imports/Characters"
    dst = "/Game/Ready/Characters"

    if not api.does_directory_exist(src):
        print({"status": "BLOCKED_INPUT", "reason": f"missing dir: {src}"})
        return

    if not api.duplicate_directory(src, dst):
        print({"status": "BLOCKED_TOOLING", "reason": "duplicate_directory failed"})
        return

    copied = api.list_assets(dst, b_recursive=True)
    if not copied:
        print({"status": "BLOCKED_TOOLING", "reason": "no assets copied"})
        return

    objects = []
    for p in copied:
        obj = api.load_asset(p)
        if obj is not None:
            api.set_metadata_tag(obj, "Approved", "pending")
            objects.append(obj)

    api.save_loaded_assets(objects, b_only_if_is_dirty=False)
    print({"status": "OK", "copied": len(copied)})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（资产路径、目录路径、必需 Tag 等）。
- `BLOCKED_TOOLING`：子系统或编辑器上下文不可用，或修订控制 Checkout 不可用导致无法执行。
- 删除/合并（Force Delete）、重命名/移动、复制、目录操作与元数据写入均修改资产生命周期：内容写入由 `game-asset-production-manager` 管理，`asset-compliance-auditor`/`qa-test-specialist` 独立验收；未经验收前不得声称资产已完成。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。