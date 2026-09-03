---
name: editor-asset-subsystem
description: UEditorAssetSubsystem（UE 5.6）资产编辑器原语 - 加载/查找/复制/重命名/移动/删除/合并/另存/修订控制/目录/元数据标签；在 Agent 需要通过 unreal Python 自动化编辑器资产管线操作时使用
tags: [ue5.6, editor, asset, python, subsystem]
---

# EditorAssetSubsystem - Asset Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UEditorAssetSubsystem` 暴露给 Python 的资产编辑器操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Subsystems/EditorAssetSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 `ScriptMethod` 时按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.EditorAssetSubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 资产路径支持四种写法：完整引用 `/Game/MyFolder/MyAsset.MyAsset`、Full Name `StaticMesh /Game/MyFolder/MyAsset.MyAsset`、Path Name `/Game/MyFolder/MyAsset.MyAsset`、Package Name `/Game/MyFolder/MyAsset`。
- 目录路径形如 `/Game/MyNewFolder/` 或 `/Game/MyNewFolder`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 加载/查询 | `load_asset(asset_path)` | `UObject* LoadAsset(FString)` | `Object` 或 `None` |
| 加载/查询 | `load_blueprint_class(asset_path)` | `UClass* LoadBlueprintClass(FString)` | `Class` 或 `None` |
| 加载/查询 | `get_path_name_for_loaded_asset(loaded_asset)` | `FString GetPathNameForLoadedAsset(UObject*)` | `str` |
| 加载/查询 | `find_asset_data(asset_path)` | `FAssetData FindAssetData(FString)` | `AssetData` 或 `None` |
| 加载/查询 | `does_asset_exist(asset_path)` | `bool DoesAssetExist(FString)` | `bool` |
| 加载/查询 | `do_assets_exist(asset_paths)` | `bool DoAssetsExist(TArray<FString>)` | `bool` |
| 加载/查询 | `find_package_referencers_for_asset(asset_path, b_load_assets_to_confirm=False)` | `TArray<FString> FindPackageReferencersForAsset(FString, bool)` | `Array[str]` |
| 复制 | `duplicate_loaded_asset(source_asset, destination_asset_path)` | `UObject* DuplicateLoadedAsset(UObject*, FString)` | `Object` 或 `None` |
| 复制 | `duplicate_asset(source_asset_path, destination_asset_path)` | `UObject* DuplicateAsset(FString, FString)` | `Object` 或 `None` |
| 复制 | `duplicate_directory(source_directory_path, destination_directory_path)` | `bool DuplicateDirectory(FString, FString)` | `bool` |
| 重命名/移动 | `rename_loaded_asset(source_asset, destination_asset_path)` | `bool RenameLoadedAsset(UObject*, FString)` | `bool` |
| 重命名/移动 | `rename_asset(source_asset_path, destination_asset_path)` | `bool RenameAsset(FString, FString)` | `bool` |
| 重命名/移动 | `rename_directory(source_directory_path, destination_directory_path)` | `bool RenameDirectory(FString, FString)` | `bool` |
| 删除/合并 | `delete_loaded_asset(asset_to_delete)` | `bool DeleteLoadedAsset(UObject*)` | `bool` |
| 删除/合并 | `delete_loaded_assets(assets_to_delete)` | `bool DeleteLoadedAssets(TArray<UObject*>)` | `bool` |
| 删除/合并 | `delete_asset(asset_path_to_delete)` | `bool DeleteAsset(FString)` | `bool` |
| 删除/合并 | `delete_directory(directory_path)` | `bool DeleteDirectory(FString)` | `bool` |
| 删除/合并 | `consolidate_assets(asset_to_consolidate_to, assets_to_consolidate)` | `bool ConsolidateAssets(UObject*, TArray<UObject*>)` | `bool` |
| 修订控制 | `checkout_loaded_asset(asset_to_checkout)` | `bool CheckoutLoadedAsset(UObject*)` | `bool` |
| 修订控制 | `checkout_loaded_assets(assets_to_checkout)` | `bool CheckoutLoadedAssets(TArray<UObject*>)` | `bool` |
| 修订控制 | `checkout_asset(asset_to_checkout)` | `bool CheckoutAsset(FString)` | `bool` |
| 修订控制 | `checkout_directory(directory_path, b_recursive=True)` | `bool CheckoutDirectory(FString, bool)` | `bool` |
| 修订控制 | `set_dirty_flag(object, b_dirty_state)` | `bool SetDirtyFlag(UObject*, bool)` | `bool` |
| 保存 | `save_loaded_asset(asset_to_save, b_only_if_is_dirty=True)` | `bool SaveLoadedAsset(UObject*, bool)` | `bool` |
| 保存 | `save_loaded_assets(assets_to_save, b_only_if_is_dirty=True)` | `bool SaveLoadedAssets(TArray<UObject*>, bool)` | `bool` |
| 保存 | `save_asset(asset_to_save, b_only_if_is_dirty=True)` | `bool SaveAsset(FString, bool)` | `bool` |
| 保存 | `save_directory(directory_path, b_only_if_is_dirty=True, b_recursive=True)` | `bool SaveDirectory(FString, bool, bool)` | `bool` |
| 目录 | `does_directory_exist(directory_path)` | `bool DoesDirectoryExist(FString)` | `bool` |
| 目录 | `does_directory_contain_assets(directory_path, b_recursive=True)` | `bool DoesDirectoryContainAssets(FString, bool)` | `bool` |
| 目录 | `make_directory(directory_path)` | `bool MakeDirectory(FString)` | `bool` |
| 目录 | `list_assets(directory_path, b_recursive=True, b_include_folder=False)` | `TArray<FString> ListAssets(FString, bool, bool)` | `Array[str]` |
| 目录 | `list_assets_by_tag_value(tag_name, tag_value)` | `TArray<FString> ListAssetsByTagValue(FName, FString)` | `Array[str]` |
| 元数据/标签 | `get_tag_values(asset_path)` | `TMap<FName, FString> GetTagValues(FString)` | `Dict[str, str]` |
| 元数据/标签 | `get_metadata_tag_values(object)` | `TMap<FName, FString> GetMetadataTagValues(UObject*)` | `Dict[str, str]` |
| 元数据/标签 | `get_metadata_tag(object, tag)` | `FString GetMetadataTag(UObject*, FName)` | `str` |
| 元数据/标签 | `set_metadata_tag(object, tag, value)` | `void SetMetadataTag(UObject*, FName, FString)` | `None` |
| 元数据/标签 | `remove_metadata_tag(object, tag)` | `void RemoveMetadataTag(UObject*, FName)` | `None` |
| 元数据/标签 | `get_all_assets_by_meta_data_tags(required_tags, allowed_classes)` | `TArray<FAssetData> GetAllAssetsByMetaDataTags(TSet<FName>, TSet<UClass*>)` | `Array[AssetData]` |
| 元数据/标签 | `sort_by_meta_data(assets, meta_data_tag, meta_data_type, sort_order)` | `bool SortByMetaData(TArray<FAssetData>&, FName, EEditorAssetMetaDataSortType, EEditorAssetSortOrder)` | `(bool, Array[AssetData])` |
| Cook 辅助 | `get_asset_filename_length_for_cooking(asset_path)` | `int32 GetAssetFilenameLengthForCooking(FString)` | `int` |
| Cook 辅助 | `get_loaded_asset_filename_length_for_cooking(asset)` | `int32 GetLoadedAssetFilenameLengthForCooking(UObject*)` | `int` |
| 事件挂钩 | `add_on_extract_asset_from_file(delegate)` | `void AddOnExtractAssetFromFile(FOnExtractAssetFromFileDynamic)` | `None` |
| 事件挂钩 | `remove_on_extract_asset_from_file(delegate)` | `void RemoveOnExtractAssetFromFile(FOnExtractAssetFromFileDynamic)` | `None` |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.EditorAssetSubsystem)

paths = ["/Game/Meshes/SM_Box", "/Game/Props/P_Stone"]
for path in paths:
    if not api.does_asset_exist(path):
        print({"status": "BLOCKED_INPUT", "reason": f"missing asset: {path}"})
        raise SystemExit(1)

assets = [api.load_asset(p) for p in paths]
api.checkout_loaded_assets(assets)

dup = api.duplicate_asset("/Game/Meshes/SM_Box", "/Game/Meshes/SM_Box_LODCopy")
if dup is not None:
    api.set_metadata_tag(dup, "SourceScan", "auto")
    ok = api.save_loaded_asset(dup, b_only_if_is_dirty=False)
    print({"status": "OK" if ok else "DRAFT_ONLY", "duplicated": dup.get_path_name()})

for a in assets:
    api.remove_metadata_tag(a, "SourceScan")
```

## 注意事项

- 全部删除/合并操作都是 Force Delete：不检查其他关卡或 Actor 的引用，会关闭资产编辑器并可能清空 Undo 历史。
- `consolidate_assets` 会删除 `AssetsToConsolidate` 并留下指向目标资产的 Redirector，成功后自动保存被修改对象。
- 重命名/移动/复制/删除会尝试 Checkout 目标文件；无版本控制时返回 `False`，需按阻塞规则评估。
- 写资产类操作（删除/重命名/移动/复制/合并/元数据写入）属资产生命周期：由 `game-asset-production-manager` 管理内容写入，`asset-compliance-auditor`/`qa-test-specialist` 独立验收；本 skill 不替代审计门禁。
- 无编辑器环境（子系统不可用）→ `BLOCKED_TOOLING`；缺资产/目录路径等必要输入 → `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。