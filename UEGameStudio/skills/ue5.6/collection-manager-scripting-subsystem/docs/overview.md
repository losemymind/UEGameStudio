# CollectionManagerScriptingSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/UnrealEd/Public/Subsystems/CollectionManagerScriptingSubsystem.h` 整理 `UCollectionManagerScriptingSubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case。每个成员给出 C++ 签名、Python 参数与返回约定；完整示例即调用样板。

## 获取子系统

```python
import unreal

collection_subsystem = unreal.get_editor_subsystem(unreal.CollectionManagerSubsystem)
if collection_subsystem is None:
    raise RuntimeError("BLOCKED_TOOLING: CollectionManagerSubsystem 不可用")
```

`UCollectionManagerScriptingSubsystem` 继承自 `UEditorSubsystem`（头文件声明，非 `UEngineSubsystem`），Python 中用 `unreal.get_editor_subsystem(...)` 获取；Python 类名遵循 UCLASS 的 `ScriptName` meta（`CollectionManagerSubsystem`）。

## 返回约定

- **Out/ByRef 返回**：带 `FCollectionScriptingRef&` / `TArray<...>&` 出参的成员按元组返回 `(bool, Out 结果)`。
- **直返**：无出参成员直接返回 `bool`、`int` 或结构体。
- C++ 签名中的 `&`（by-ref）与参数默认值按 Python 绑定约定省略；参数名取 C++ 参数名的 snake_case。

## 容器与枚举

容器对象 `unreal.CollectionContainerSource`（脚本名 `CollectionContainerSource`）承载 `name` 与 `title`；集合对象 `unreal.Collection`（脚本名 `Collection`）承载 `container`、`name`、`share_type`；分享类型枚举 `unreal.CollectionShareType` 取值 `LOCAL` / `PRIVATE` / `SHARED`。

### get_collection_containers

- C++ 签名：`TArray<FCollectionScriptingContainerSource> GetCollectionContainers()`
- Python：`get_collection_containers() -> Array[CollectionContainerSource]`
- 说明：返回全部可用集合容器。
- 示例：

```python
containers = collection_subsystem.get_collection_containers()
for c in containers:
    print(c.name, c.title)
```

### get_base_game_collection_container

- C++ 签名：`FCollectionScriptingContainerSource GetBaseGameCollectionContainer() const`
- Python：`get_base_game_collection_container() -> CollectionContainerSource`
- 说明：返回基类游戏（本工程）的集合容器，常用于创建/查询时的缺省容器。
- 示例：

```python
base = collection_subsystem.get_base_game_collection_container()
print("game container:", base.name)
```

## 集合查询

### collection_exists

- C++ 签名：`bool CollectionExists(const FCollectionScriptingContainerSource Container, const FName Collection, const ECollectionScriptingShareType ShareType)`
- Python：`collection_exists(container, collection, share_type) -> bool`
- 说明：判断容器内是否存在名称与分享类型都匹配的集合。
- 示例：

```python
exists = collection_subsystem.collection_exists(base, "Core", unreal.CollectionShareType.SHARED)
if not exists:
    print("BLOCKED_INPUT: collection not found")
```

### get_collections

- C++ 签名：`bool GetCollections(const FCollectionScriptingContainerSource Container, TArray<FCollectionScriptingRef>& OutCollections)`
- Python：`get_collections(container) -> Tuple[bool, Array[Collection]]`
- 说明：列出指定容器内的全部集合。
- 示例：

```python
ok, collections = collection_subsystem.get_collections(base)
if not ok:
    print("BLOCKED_TOOLING: list collections failed")
for col in collections:
    print(col.name, col.share_type)
```

### get_collections_by_name

- C++ 签名：`bool GetCollectionsByName(const FCollectionScriptingContainerSource Container, const FName Collection, TArray<FCollectionScriptingRef>& OutCollections)`
- Python：`get_collections_by_name(container, collection) -> Tuple[bool, Array[Collection]]`
- 说明：按名称（不比对分享类型）查找集合；同名的不同分享类型集合都会返回。
- 示例：

```python
ok, matched = collection_subsystem.get_collections_by_name(base, "Core")
```

## 集合创建

### create_collection

- C++ 签名：`bool CreateCollection(const FCollectionScriptingContainerSource Container, const FName Collection, const ECollectionScriptingShareType ShareType, FCollectionScriptingRef& OutNewCollection)`
- Python：`create_collection(container, collection, share_type) -> Tuple[bool, Collection]`
- 说明：在指定容器内创建新集合；`OutNewCollection` 为新建集合。"None" 容器缺省为基类游戏容器。
- 示例：

```python
created, new_collection = collection_subsystem.create_collection(
    base, "Levels_Playable", unreal.CollectionShareType.LOCAL
)
if not created:
    print("BLOCKED_TOOLING: create failed, see Output Log")
```

### create_or_empty_collection

- C++ 签名：`bool CreateOrEmptyCollection(const FCollectionScriptingContainerSource Container, const FName Collection, const ECollectionScriptingShareType ShareType, FCollectionScriptingRef& OutNewOrEmptyCollection)`
- Python：`create_or_empty_collection(container, collection, share_type) -> Tuple[bool, Collection]`
- 说明：集合不存在则创建；已存在则清空其内容，并返回该（新或清空后的）集合。
- 示例：

```python
ready, target = collection_subsystem.create_or_empty_collection(
    base, "Levels_Playable", unreal.CollectionShareType.LOCAL
)
if not ready:
    print("BLOCKED_TOOLING: create/empty failed")
```

## 集合修改

### rename_collection

- C++ 签名：`bool RenameCollection(const FCollectionScriptingRef& Collection, const FName NewName, const ECollectionScriptingShareType NewShareType)`
- Python：`rename_collection(collection, new_name, new_share_type) -> bool`
- 说明：重命名并（或）修改集合的分享类型。
- 示例：

```python
renamed = collection_subsystem.rename_collection(
    target, "Levels_Published", unreal.CollectionShareType.SHARED
)
```

### reparent_collection

- C++ 签名：`bool ReparentCollection(const FCollectionScriptingRef& Collection, const FCollectionScriptingRef NewParentCollection)`
- Python：`reparent_collection(collection, new_parent_collection) -> bool`
- 说明：将集合挂到指定父集合下；父集合为"None"（空）时成为根集合。
- 示例：

```python
reparented = collection_subsystem.reparent_collection(target, parent_collection)
```

### empty_collection

- C++ 签名：`bool EmptyCollection(const FCollectionScriptingRef& Collection)`
- Python：`empty_collection(collection) -> bool`
- 说明：移除集合内全部资产。
- 示例：

```python
emptied = collection_subsystem.empty_collection(target)
```

### destroy_collection

- C++ 签名：`bool DestroyCollection(const FCollectionScriptingRef& Collection)`
- Python：`destroy_collection(collection) -> bool`
- 说明：销毁给定集合。
- 示例：

```python
destroyed = collection_subsystem.destroy_collection(target)
if not destroyed:
    print("BLOCKED_TOOLING: destroy failed")
```

## 向集合添加资产

### add_asset_to_collection

- C++ 签名：`bool AddAssetToCollection(const FCollectionScriptingRef& Collection, const FSoftObjectPath& AssetPath)`
- Python：`add_asset_to_collection(collection, asset_path) -> bool`
- 说明：按资产路径（如 `/Game/MyFolder/MyAsset.MyAsset`）添加单个资产。
- 示例：

```python
path = unreal.SoftObjectPath("/Game/Maps/Main.Main")
added = collection_subsystem.add_asset_to_collection(target, path)
if not added:
    print("BLOCKED_INPUT: asset add failed")
```

### add_asset_data_to_collection

- C++ 签名：`bool AddAssetDataToCollection(const FCollectionScriptingRef& Collection, const FAssetData& AssetData)`
- Python：`add_asset_data_to_collection(collection, asset_data) -> bool`
- 说明：按 `unreal.AssetData` 添加单个资产。
- 示例：

```python
registry = unreal.AssetRegistryHelpers.get_asset_registry()
asset_data = registry.get_asset_by_object_path(unreal.SoftObjectPath("/Game/Maps/Main.Main"))
collection_subsystem.add_asset_data_to_collection(target, asset_data)
```

### add_asset_ptr_to_collection

- C++ 签名：`bool AddAssetPtrToCollection(const FCollectionScriptingRef& Collection, const UObject* AssetPtr)`
- Python：`add_asset_ptr_to_collection(collection, asset_ptr) -> bool`
- 说明：按资产对象（已加载 `UObject`）添加单个资产。
- 示例：

```python
asset = unreal.EditorAssetLibrary.load_asset("/Game/Maps/Main")
collection_subsystem.add_asset_ptr_to_collection(target, asset)
```

### add_assets_to_collection

- C++ 签名：`bool AddAssetsToCollection(const FCollectionScriptingRef& Collection, const TArray<FSoftObjectPath>& AssetPaths)`
- Python：`add_assets_to_collection(collection, asset_paths) -> bool`
- 说明：按路径数组批量添加。
- 示例：

```python
paths = [unreal.SoftObjectPath(p) for p in ["/Game/Maps/A.A", "/Game/Maps/B.B"]]
collection_subsystem.add_assets_to_collection(target, paths)
```

### add_asset_datas_to_collection

- C++ 签名：`bool AddAssetDatasToCollection(const FCollectionScriptingRef& Collection, const TArray<FAssetData>& AssetDatas)`
- Python：`add_asset_datas_to_collection(collection, asset_datas) -> bool`
- 说明：按 `unreal.AssetData` 数组批量添加。

### add_asset_ptrs_to_collection

- C++ 签名：`bool AddAssetPtrsToCollection(const FCollectionScriptingRef& Collection, const TArray<UObject*>& AssetPtrs)`
- Python：`add_asset_ptrs_to_collection(collection, asset_ptrs) -> bool`
- 说明：按资产对象数组批量添加。
- 示例：

```python
assets = [unreal.EditorAssetLibrary.load_asset(p) for p in ["/Game/Maps/A", "/Game/Maps/B"]]
collection_subsystem.add_asset_ptrs_to_collection(target, assets)
```

## 从集合移除资产

### remove_asset_from_collection

- C++ 签名：`bool RemoveAssetFromCollection(const FCollectionScriptingRef& Collection, const FSoftObjectPath& AssetPath)`
- Python：`remove_asset_from_collection(collection, asset_path) -> bool`
- 说明：按路径移除单个资产。
- 示例：

```python
removed = collection_subsystem.remove_asset_from_collection(target, path)
```

### remove_asset_data_from_collection

- C++ 签名：`bool RemoveAssetDataFromCollection(const FCollectionScriptingRef& Collection, const FAssetData& AssetData)`
- Python：`remove_asset_data_from_collection(collection, asset_data) -> bool`
- 说明：按 `unreal.AssetData` 移除单个资产。

### remove_asset_ptr_from_collection

- C++ 签名：`bool RemoveAssetPtrFromCollection(const FCollectionScriptingRef& Collection, const UObject* AssetPtr)`
- Python：`remove_asset_ptr_from_collection(collection, asset_ptr) -> bool`
- 说明：按资产对象移除单个资产。

### remove_assets_from_collection

- C++ 签名：`bool RemoveAssetsFromCollection(const FCollectionScriptingRef& Collection, const TArray<FSoftObjectPath>& AssetPaths)`
- Python：`remove_assets_from_collection(collection, asset_paths) -> bool`
- 说明：按路径数组批量移除。

### remove_asset_datas_from_collection

- C++ 签名：`bool RemoveAssetDatasFromCollection(const FCollectionScriptingRef& Collection, const TArray<FAssetData>& AssetDatas)`
- Python：`remove_asset_datas_from_collection(collection, asset_datas) -> bool`
- 说明：按 `unreal.AssetData` 数组批量移除。

### remove_asset_ptrs_from_collection

- C++ 签名：`bool RemoveAssetPtrsFromCollection(const FCollectionScriptingRef& Collection, const TArray<UObject*>& AssetPtrs)`
- Python：`remove_asset_ptrs_from_collection(collection, asset_ptrs) -> bool`
- 说明：按资产对象数组批量移除。

## 查询集合与资产关系

### get_assets_in_collection

- C++ 签名：`bool GetAssetsInCollection(const FCollectionScriptingRef& Collection, TArray<FAssetData>& OutAssets)`
- Python：`get_assets_in_collection(collection) -> Tuple[bool, Array[AssetData]]`
- 说明：返回集合内全部资产。
- 示例：

```python
ok, assets = collection_subsystem.get_assets_in_collection(target)
if ok:
    for ad in assets:
        print(ad.get_full_name())
```

### get_collections_containing_asset

- C++ 签名：`bool GetCollectionsContainingAsset(const FCollectionScriptingContainerSource Container, const FSoftObjectPath& AssetPath, TArray<FCollectionScriptingRef>& OutCollections)`
- Python：`get_collections_containing_asset(container, asset_path) -> Tuple[bool, Array[Collection]]`
- 说明：返回指定容器内包含给定资产的集合。
- 示例：

```python
ok, containing = collection_subsystem.get_collections_containing_asset(base, path)
```

### get_collections_containing_asset_data

- C++ 签名：`bool GetCollectionsContainingAssetData(const FCollectionScriptingContainerSource Container, const FAssetData& AssetData, TArray<FCollectionScriptingRef>& OutCollections)`
- Python：`get_collections_containing_asset_data(container, asset_data) -> Tuple[bool, Array[Collection]]`
- 说明：按 `unreal.AssetData` 版包含查询。

### get_collections_containing_asset_ptr

- C++ 签名：`bool GetCollectionsContainingAssetPtr(const FCollectionScriptingContainerSource Container, const UObject* AssetPtr, TArray<FCollectionScriptingRef>& OutCollections)`
- Python：`get_collections_containing_asset_ptr(container, asset_ptr) -> Tuple[bool, Array[Collection]]`
- 说明：按资产对象版包含查询。

## 完整示例：为 Cook 范围建立集合并验证

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.CollectionManagerSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "CollectionManagerSubsystem 不可用"})
        return

    base = api.get_base_game_collection_container()
    created, collection = api.create_or_empty_collection(
        base, "Cook_Scope_Playable", unreal.CollectionShareType.LOCAL
    )
    if not created:
        print({"status": "BLOCKED_TOOLING", "reason": "create collection failed"})
        return

    map_paths = [
        unreal.SoftObjectPath("/Game/Maps/Main.Main"),
        unreal.SoftObjectPath("/Game/Maps/LevelB.LevelB"),
    ]
    added = api.add_assets_to_collection(collection, map_paths)
    if not added:
        print({"status": "BLOCKED_INPUT", "reason": "add assets failed"})
        return

    ok, assets = api.get_assets_in_collection(collection)
    if not ok:
        print({"status": "BLOCKED_TOOLING", "reason": "query assets failed"})
        return

    # 集合是 Cook 范围输入：最终范围合规由 asset-compliance-auditor 独立校验
    print({"status": "OK", "collection": collection.name, "assets": len(assets)})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺容器名、集合名、资产路径/资产数据等必要输入，或指定资产不存在。
- `BLOCKED_TOOLING`：子系统或编辑器脚本上下文不可用，无法执行集合操作。
- 集合自身由编辑器管理，不直接修改 `.uasset` 二进制内容；但其成员关系是资产组织与 Cook 范围输入，集合变更后的范围合规必须交由 `asset-compliance-auditor` 独立验收。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。