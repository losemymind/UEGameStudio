---
name: collection-manager-scripting-subsystem
description: UCollectionManagerScriptingSubsystem（UE 5.6）资产集合管理子系统 - 创建/删除/重命名/重挂集合、添加/移除/查询集合内资产与资产所属集合；在 Agent 需要通过 unreal Python 管理资产集合时使用
risk: critical
category: development
tags: [ue5.6, editor, collection, python, subsystem]
---

# CollectionManagerScriptingSubsystem - Collection Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 管理资产集合时使用本 skill（description 触发场景）。
- 本 skill 只在与 collection-manager-scripting-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UCollectionManagerScriptingSubsystem` 暴露给 Python 的资产集合（Collection）管理操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Subsystems/CollectionManagerScriptingSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case（该头文件成员未声明 `ScriptMethod` 覆盖），精确 Python 暴露名需实测确认。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.CollectionManagerSubsystem)
```

- `UCollectionManagerScriptingSubsystem` 继承自 `UEditorSubsystem`（头文件声明，非 `UEngineSubsystem`），用 `get_editor_subsystem` 获取；Python 类名取 UCLASS 的 `ScriptName` meta（`CollectionManagerSubsystem`）。返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 集合对象为 `unreal.Collection`（`FCollectionScriptingRef`，脚本名为 `Collection`），承载：`container`（所属容器）、`name`（集合名）、`share_type`（分享类型）。
- 容器对象为 `unreal.CollectionContainerSource`（`FCollectionScriptingContainerSource`），承载：`name`（容器名）、`title`。
- 分享类型枚举为 `unreal.CollectionShareType`（`ECollectionScriptingShareType`）：`LOCAL`、`PRIVATE`、`SHARED`。
- 资产引用形参同时接受路径对象（`unreal.SoftObjectPath`）、`unreal.AssetData` 与资产对象（`UObject`），对应三种添加/移除/查询变体。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 容器 | `get_collection_containers()` | `TArray<FCollectionScriptingContainerSource> GetCollectionContainers()` | `Array[CollectionContainerSource]` |
| 容器 | `get_base_game_collection_container()` | `FCollectionScriptingContainerSource GetBaseGameCollectionContainer() const` | `CollectionContainerSource` |
| 查询 | `collection_exists(container, collection, share_type)` | `bool CollectionExists(const FCollectionScriptingContainerSource, FName, ECollectionScriptingShareType)` | `bool` |
| 查询 | `get_collections(container)` | `bool GetCollections(const FCollectionScriptingContainerSource, TArray<FCollectionScriptingRef>&)` | `Tuple[bool, Array[Collection]]` |
| 查询 | `get_collections_by_name(container, collection)` | `bool GetCollectionsByName(const FCollectionScriptingContainerSource, FName, TArray<FCollectionScriptingRef>&)` | `Tuple[bool, Array[Collection]]` |
| 创建 | `create_collection(container, collection, share_type)` | `bool CreateCollection(const FCollectionScriptingContainerSource, FName, ECollectionScriptingShareType, FCollectionScriptingRef&)` | `Tuple[bool, Collection]` |
| 创建 | `create_or_empty_collection(container, collection, share_type)` | `bool CreateOrEmptyCollection(const FCollectionScriptingContainerSource, FName, ECollectionScriptingShareType, FCollectionScriptingRef&)` | `Tuple[bool, Collection]` |
| 修改 | `rename_collection(collection, new_name, new_share_type)` | `bool RenameCollection(const FCollectionScriptingRef&, FName, ECollectionScriptingShareType)` | `bool` |
| 修改 | `reparent_collection(collection, new_parent_collection)` | `bool ReparentCollection(const FCollectionScriptingRef&, FCollectionScriptingRef)` | `bool` |
| 修改 | `empty_collection(collection)` | `bool EmptyCollection(const FCollectionScriptingRef&)` | `bool` |
| 删除 | `destroy_collection(collection)` | `bool DestroyCollection(const FCollectionScriptingRef&)` | `bool` |
| 添加 | `add_asset_to_collection(collection, asset_path)` | `bool AddAssetToCollection(const FCollectionScriptingRef&, FSoftObjectPath)` | `bool` |
| 添加 | `add_asset_data_to_collection(collection, asset_data)` | `bool AddAssetDataToCollection(const FCollectionScriptingRef&, FAssetData)` | `bool` |
| 添加 | `add_asset_ptr_to_collection(collection, asset_ptr)` | `bool AddAssetPtrToCollection(const FCollectionScriptingRef&, const UObject*)` | `bool` |
| 添加 | `add_assets_to_collection(collection, asset_paths)` | `bool AddAssetsToCollection(const FCollectionScriptingRef&, TArray<FSoftObjectPath>)` | `bool` |
| 添加 | `add_asset_datas_to_collection(collection, asset_datas)` | `bool AddAssetDatasToCollection(const FCollectionScriptingRef&, TArray<FAssetData>)` | `bool` |
| 添加 | `add_asset_ptrs_to_collection(collection, asset_ptrs)` | `bool AddAssetPtrsToCollection(const FCollectionScriptingRef&, TArray<const UObject*>)` | `bool` |
| 移除 | `remove_asset_from_collection(collection, asset_path)` | `bool RemoveAssetFromCollection(const FCollectionScriptingRef&, FSoftObjectPath)` | `bool` |
| 移除 | `remove_asset_data_from_collection(collection, asset_data)` | `bool RemoveAssetDataFromCollection(const FCollectionScriptingRef&, FAssetData)` | `bool` |
| 移除 | `remove_asset_ptr_from_collection(collection, asset_ptr)` | `bool RemoveAssetPtrFromCollection(const FCollectionScriptingRef&, const UObject*)` | `bool` |
| 移除 | `remove_assets_from_collection(collection, asset_paths)` | `bool RemoveAssetsFromCollection(const FCollectionScriptingRef&, TArray<FSoftObjectPath>)` | `bool` |
| 移除 | `remove_asset_datas_from_collection(collection, asset_datas)` | `bool RemoveAssetDatasFromCollection(const FCollectionScriptingRef&, TArray<FAssetData>)` | `bool` |
| 移除 | `remove_asset_ptrs_from_collection(collection, asset_ptrs)` | `bool RemoveAssetPtrsFromCollection(const FCollectionScriptingRef&, TArray<const UObject*>)` | `bool` |
| 查询资产 | `get_assets_in_collection(collection)` | `bool GetAssetsInCollection(const FCollectionScriptingRef&, TArray<FAssetData>&)` | `Tuple[bool, Array[AssetData]]` |
| 查询资产 | `get_collections_containing_asset(container, asset_path)` | `bool GetCollectionsContainingAsset(const FCollectionScriptingContainerSource, FSoftObjectPath, TArray<FCollectionScriptingRef>&)` | `Tuple[bool, Array[Collection]]` |
| 查询资产 | `get_collections_containing_asset_data(container, asset_data)` | `bool GetCollectionsContainingAssetData(const FCollectionScriptingContainerSource, FAssetData, TArray<FCollectionScriptingRef>&)` | `Tuple[bool, Array[Collection]]` |
| 查询资产 | `get_collections_containing_asset_ptr(container, asset_ptr)` | `bool GetCollectionsContainingAssetPtr(const FCollectionScriptingContainerSource, const UObject*, TArray<FCollectionScriptingRef>&)` | `Tuple[bool, Array[Collection]]` |

## 示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.CollectionManagerSubsystem)

container = api.get_base_game_collection_container()
created, collection = api.create_collection(
    container, "Levels_Playable", unreal.CollectionShareType.LOCAL
)
if not created:
    print("BLOCKED_TOOLING: create collection failed")

path = unreal.SoftObjectPath("/Game/Maps/Main.Main")
added = api.add_asset_to_collection(collection, path)
if added:
    ok, assets = api.get_assets_in_collection(collection)
    print("assets in collection:", len(assets))

api.remove_asset_from_collection(collection, path)
api.destroy_collection(collection)
```

## 限制和注意事项

- 容器与集合名使用 `unreal.Name` 语义（Python 直接传字符串）；"None" 容器缺省为基类游戏容器。
- 添加/移除/查询的资产变体对应三种引用形式：路径（`unreal.SoftObjectPath`）、`unreal.AssetData`、资产对象（`unreal.Object` / `unreal.ObjectPtr`）。
- 带 Out 参数的成员按元组返回：`(成功标志, Out 结果)`；单出参且 `void` 返回时直接返回该出参（本子系统无此类成员）。
- 集合是资产组织与 Cook 范围的重要输入：集合变更后需将集合状态交由 `asset-compliance-auditor` 做 Cook 范围合规检查，不自行断言范围合规。
- 无编辑器上下文时返回 `BLOCKED_TOOLING`；缺容器名/集合名/资产路径等必要输入时返回 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。