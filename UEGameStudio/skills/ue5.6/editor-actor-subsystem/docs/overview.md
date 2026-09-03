# EditorActorSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/UnrealEd/Public/Subsystems/EditorActorSubsystem.h` 整理 `UEditorActorSubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case。每个成员给出 C++ 签名、Python 参数、返回约定与完整示例；完整示例即调用样板。

## 获取子系统

```python
import unreal

editor_actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
if editor_actor_subsystem is None:
    raise RuntimeError("BLOCKED_TOOLING: EditorActorSubsystem 不可用")
```

## 通用约定

- 需要 `UWorld` 参数的方法传入编辑器主世界：

```python
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
```

- 坐标类型必须使用 `unreal.Vector` / `unreal.Rotator` / `unreal.Transform`，禁止传元组/列表。
- 返回 `None` 视为失败；空数组视为没有候选或失败，按阻塞规则处理。

## 列举与查询

### get_all_level_actors

- C++ 签名：`TArray<AActor*> GetAllLevelActors()`
- Python：`get_all_level_actors() -> Array[Actor]`
- 说明：返回当前已加载关卡的全部 Actor；不包含 PendingKill、PIE、PreviewEditor 中的对象。
- 示例：

```python
actors = editor_actor_subsystem.get_all_level_actors()
print("actor count:", len(actors))
for a in actors:
    print(a.get_actor_label())
```

### get_all_level_actors_components

- C++ 签名：`TArray<UActorComponent*> GetAllLevelActorsComponents()`
- Python：`get_all_level_actors_components() -> Array[ActorComponent]`
- 说明：返回所有已加载 Actor 的组件列表。
- 示例：

```python
components = editor_actor_subsystem.get_all_level_actors_components()
scene_components = [c for c in components if isinstance(c, unreal.SceneComponent)]
```

### get_selected_level_actors

- C++ 签名：`TArray<AActor*> GetSelectedLevelActors()`
- Python：`get_selected_level_actors() -> Array[Actor]`
- 说明：返回当前编辑器选择集。
- 示例：

```python
selected = editor_actor_subsystem.get_selected_level_actors()
print("selection count:", len(selected))
```

### get_actor_reference

- C++ 签名：`AActor* GetActorReference(FString PathToActor)`（BlueprintPure）
- Python：`get_actor_reference(path_to_actor) -> Actor`
- 说明：按对象路径查找 Actor，路径形如 `PersistentLevel.PlayerStart`；未找到返回 `None`。
- 示例：

```python
player_start = editor_actor_subsystem.get_actor_reference("PersistentLevel.PlayerStart")
if player_start is None:
    print("BLOCKED_INPUT: actor reference not found")
```

## 生成

### spawn_actor_from_object

- C++ 签名：`AActor* SpawnActorFromObject(UObject* ObjectToUse, FVector Location, FRotator Rotation, bool bTransient)`
- Python：`spawn_actor_from_object(object_to_use, location, rotation=unreal.Rotator(0,0,0), b_transient=False) -> Actor`
- 说明：从资产、Archetype、类或 Factory 生成 Actor 并放入当前关卡，生成后自动选中。
- 示例：

```python
asset = unreal.EditorAssetLibrary.load_asset("/Game/Meshes/SM_Box")
if asset is not None:
    box = editor_actor_subsystem.spawn_actor_from_object(
        asset,
        unreal.Vector(0.0, 0.0, 100.0),
        rotation=unreal.Rotator(0.0, 30.0, 0.0),
    )
```

### spawn_actor_from_class

- C++ 签名：`AActor* SpawnActorFromClass(TSubclassOf<AActor> ActorClass, FVector Location, FRotator Rotation, bool bTransient)`
- Python：`spawn_actor_from_class(actor_class, location, rotation=unreal.Rotator(0,0,0), b_transient=False) -> Actor`
- 说明：按类生成 Actor 并放入当前关卡；生成失败返回 `None`。
- 示例：

```python
prop_class = unreal.load_class("/Game/Blueprints/BP_Prop")
if prop_class is None:
    print("BLOCKED_INPUT: class path not loadable")
else:
    prop = editor_actor_subsystem.spawn_actor_from_class(
        prop_class,
        unreal.Vector(100.0, 200.0, 0.0),
        rotation=unreal.Rotator(0.0, 90.0, 0.0),
    )
```

## 复制

### duplicate_actor

- C++ 签名：`AActor* DuplicateActor(AActor* ActorToDuplicate, UWorld* ToWorld, FVector Offset)`
- Python：`duplicate_actor(actor_to_duplicate, to_world=None, offset=unreal.Vector(0,0,0)) -> Actor`
- 说明：复制单个 Actor，可选指定目标世界与平移偏移；失败返回 `None`。
- 示例：

```python
copy = editor_actor_subsystem.duplicate_actor(
    source_actor,
    offset=unreal.Vector(500.0, 0.0, 0.0),
)
if copy is None:
    print("BLOCKED_TOOLING: duplicate failed")
```

### duplicate_actors

- C++ 签名：`TArray<AActor*> DuplicateActors(const TArray<AActor*>& ActorsToDuplicate, UWorld* ToWorld, FVector Offset)`
- Python：`duplicate_actors(actors_to_duplicate, to_world=None, offset=...) -> Array[Actor]`
- 说明：批量复制，全部成功返回复制结果数组；失败返回空数组。
- 示例：

```python
copies = editor_actor_subsystem.duplicate_actors(
    sources,
    offset=unreal.Vector(1000.0, 0.0, 0.0),
)
if not copies:
    print("duplicate batch failed")
```

### duplicate_selected_actors

- C++ 签名：`void DuplicateSelectedActors(UWorld* InWorld)`
- Python：`duplicate_selected_actors(in_world) -> None`
- 说明：复制当前选择集，需要 `UWorld`。
- 示例：

```python
editor_actor_subsystem.duplicate_selected_actors(world)
```

## 销毁

### destroy_actor

- C++ 签名：`bool DestroyActor(AActor* ActorToDestroy)`
- Python：`destroy_actor(actor_to_destroy) -> bool`
- 说明：销毁单个 Actor 并通知编辑器。
- 示例：

```python
ok = editor_actor_subsystem.destroy_actor(target_actor)
if not ok:
    print("destroy failed")
```

### destroy_actors

- C++ 签名：`bool DestroyActors(const TArray<AActor*>& ActorsToDestroy)`
- Python：`destroy_actors(actors_to_destroy) -> bool`
- 说明：批量销毁，全部成功返回 `True`。
- 示例：

```python
all_done = editor_actor_subsystem.destroy_actors(target_actors)
if not all_done:
    print("partially failed")
```

### delete_selected_actors

- C++ 签名：`void DeleteSelectedActors(UWorld* InWorld)`
- Python：`delete_selected_actors(in_world) -> None`
- 说明：删除选中集合，需要 `UWorld`。
- 示例：

```python
editor_actor_subsystem.set_selected_level_actors(targets)
editor_actor_subsystem.delete_selected_actors(world)
```

## 选择

### set_selected_level_actors

- C++ 签名：`void SetSelectedLevelActors(const TArray<AActor*>& ActorsToSelect)`
- Python：`set_selected_level_actors(actors_to_select) -> None`
- 说明：清空当前选择并选中给定 Actor 列表。
- 示例：

```python
editor_actor_subsystem.set_selected_level_actors([actor_a, actor_b])
```

### clear_actor_selection_set

- C++ 签名：`void ClearActorSelectionSet()`
- Python：`clear_actor_selection_set() -> None`
- 说明：从选择集中移除全部 Actor。
- 示例：

```python
editor_actor_subsystem.clear_actor_selection_set()
```

### select_nothing

- C++ 签名：`void SelectNothing()`
- Python：`select_nothing() -> None`
- 说明：另一种方式清空选择。
- 示例：

```python
editor_actor_subsystem.select_nothing()
```

### set_actor_selection_state

- C++ 签名：`void SetActorSelectionState(AActor* Actor, bool bShouldBeSelected)`
- Python：`set_actor_selection_state(actor, b_should_be_selected) -> None`
- 说明：设置单个 Actor 的选中状态。
- 示例：

```python
editor_actor_subsystem.set_actor_selection_state(actor_item, True)
```

### invert_selection

- C++ 签名：`void InvertSelection(UWorld* InWorld)`
- Python：`invert_selection(in_world) -> None`
- 说明：反转指定世界的选择集。
- 示例：

```python
editor_actor_subsystem.invert_selection(world)
```

### select_all

- C++ 签名：`void SelectAll(UWorld* InWorld)`
- Python：`select_all(in_world) -> None`
- 说明：选中所有未隐藏的 Actor 与 BSP 模型。
- 示例：

```python
editor_actor_subsystem.select_all(world)
```

### select_all_children

- C++ 签名：`void SelectAllChildren(bool bRecurseChildren)`
- Python：`select_all_children(b_recurse_children) -> None`
- 说明：选中当前选择集中所有子 Actor；`True` 时递归全部后代。
- 示例：

```python
editor_actor_subsystem.select_all_children(True)
```

## 转换

### convert_actors

- C++ 签名：`TArray<AActor*> ConvertActors(const TArray<AActor*>& Actors, TSubclassOf<AActor> ActorClass, const FString& StaticMeshPackagePath)`
- Python：`convert_actors(actors, actor_class, static_mesh_package_path) -> Array[Actor]`
- 说明：将一组 Actor 转换为新类 Actor 并销毁原 Actor；如原列表含 Brush 且转为 StaticMesh，`static_mesh_package_path` 指定 StaticMesh 包目录（如 `/Game/MyFolder/`）。
- 示例：

```python
converted = editor_actor_subsystem.convert_actors(
    brush_actors,
    unreal.load_class("/Script/Engine.StaticMeshActor"),
    "/Game/Meshes/",
)
```

## 变换

### set_actor_transform

- C++ 签名：`bool SetActorTransform(AActor* InActor, const FTransform& InWorldTransform)`
- Python：`set_actor_transform(actor, world_transform) -> bool`
- 说明：设置 Actor 世界变换，成功返回 `True`。
- 示例：

```python
ok = editor_actor_subsystem.set_actor_transform(
    target_actor,
    unreal.Transform(
        location=unreal.Vector(0.0, 0.0, 200.0),
        rotation=unreal.Rotator(0.0, 45.0, 0.0),
        scale3d=unreal.Vector(1.0, 1.0, 1.0),
    ),
)
if not ok:
    print("transform not applied")
```

### set_component_transform

- C++ 签名：`bool SetComponentTransform(USceneComponent* InSceneComponent, const FTransform& InWorldTransform)`
- Python：`set_component_transform(scene_component, world_transform) -> bool`
- 说明：设置组件世界变换，成功返回 `True`。
- 示例：

```python
sc = actor.get_editor_property("root_component")
ok = editor_actor_subsystem.set_component_transform(
    sc,
    unreal.Transform(
        location=unreal.Vector(50.0, 50.0, 0.0),
        rotation=unreal.Rotator(0.0, 0.0, 0.0),
        scale3d=unreal.Vector(1.0, 1.0, 1.0),
    ),
)
```

## 完整示例：批量生成并放置

```python
import unreal

def main():
    editor_actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    if editor_actor_subsystem is None:
        print({"status": "BLOCKED_TOOLING", "reason": "EditorActorSubsystem 不可用"})
        return

    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

    prop_class = unreal.load_class("/Game/Blueprints/BP_Prop")
    if prop_class is None:
        print({"status": "BLOCKED_INPUT", "reason": "class path 无法加载"})
        return

    placed = []
    for x in range(0, 500, 100):
        actor = editor_actor_subsystem.spawn_actor_from_class(
            prop_class,
            unreal.Vector(float(x), 0.0, 0.0),
        )
        placed.append(actor)

    editor_actor_subsystem.set_selected_level_actors(placed)
    editor_actor_subsystem.select_all_children(True)

    print({"status": "OK", "placed": len(placed), "selected": len(editor_actor_subsystem.get_selected_level_actors())})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（类路径、`UWorld` 等）。
- `BLOCKED_TOOLING`：子系统或编辑器上下文不可用，无法执行。
- 生成/复制/销毁/转换/变换会修改关卡内容：必须经编辑器接口保存（`unreal.EditorLoadingAndSavingUtils` / 关卡保存）并由审计/QA 独立验收；未验证前不得声称已完成。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。