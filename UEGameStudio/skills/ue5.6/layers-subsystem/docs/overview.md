# LayersSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/UnrealEd/Public/Layers/LayersSubsystem.h` 整理 `ULayersSubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。每个成员给出 C++ 签名、Python 参数、返回约定与示例。

## 获取子系统

```python
import unreal

api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: LayersSubsystem 不可用")
```

## 通用约定

- 层名 `FName` 传 `str` 或 `unreal.Name`；层对象类型为 `unreal.Layer`。
- 需要 `UWorld` / `ULevel` 参数的方法传入当前编辑器世界与关卡：

```python
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
```

- 返回值语义：`None` / 空数组 / `False` 分别表示对象不存在、层内无 Actor、操作未发生；区分错误与正常空结果后再判定阻塞。

## 关卡信息

### add_level_layer_information

- C++ 签名：`void AddLevelLayerInformation(ULevel* Level)`
- Python：`add_level_layer_information(level) -> None`
- 说明：聚合关卡及其内容相关的层信息，加载关卡后调用以同步层数据。
- 示例：

```python
api.add_level_layer_information(world.get_level(0))
```

### remove_level_layer_information

- C++ 签名：`void RemoveLevelLayerInformation(ULevel* Level)`
- Python：`remove_level_layer_information(level) -> None`
- 说明：清除关卡及其内容的层信息，关卡卸载前调用。
- 示例：

```python
api.remove_level_layer_information(world.get_level(0))
```

### get_world

- C++ 签名：`UWorld* GetWorld() const`（备用 `GWorld`）
- Python：`get_world() -> World`
- 说明：返回当前编辑器世界对象，缺省时回退到 `GWorld`。
- 示例：

```python
w = api.get_world()
```

## 单个 Actor

### is_actor_valid_for_layer

- C++ 签名：`bool IsActorValidForLayer(AActor* Actor)`
- Python：`is_actor_valid_for_layer(actor) -> bool`
- 说明：检查 Actor 是否处于可与层交互的状态。
- 示例：

```python
ok = api.is_actor_valid_for_layer(actor_item)
```

### initialize_new_actor_layers

- C++ 签名：`bool InitializeNewActorLayers(AActor* Actor)`
- Python：`initialize_new_actor_layers(actor) -> bool`
- 说明：同步新建 Actor 的层信息到层系统，生成后调用。
- 示例：

```python
api.initialize_new_actor_layers(spawned_actor)
```

### disassociate_actor_from_layers

- C++ 签名：`bool DisassociateActorFromLayers(AActor* Actor)`
- Python：`disassociate_actor_from_layers(actor) -> bool`
- 说明：将 Actor 与层系统解除关联，一般在删除 Actor 前调用。
- 示例：

```python
api.disassociate_actor_from_layers(actor_item)
```

### add_actor_to_layer

- C++ 签名：`bool AddActorToLayer(AActor* Actor, const FName& LayerName)`
- Python：`add_actor_to_layer(actor, layer_name) -> bool`
- 说明：把 Actor 加入命名层；Actor 已属于该层时返回 `False`。
- 示例：

```python
added = api.add_actor_to_layer(actor_item, "L_Props")
```

### add_actor_to_layers

- C++ 签名：`bool AddActorToLayers(AActor* Actor, const TArray<FName>& LayerNames)`
- Python：`add_actor_to_layers(actor, layer_names) -> bool`
- 说明：把 Actor 加入多个命名层；至少加入一个层返回 `True`。
- 示例：

```python
added = api.add_actor_to_layers(actor_item, ["L_Props", "L_Interior"])
```

### remove_actor_from_layer

- C++ 签名：`bool RemoveActorFromLayer(AActor* Actor, const FName& LayerToRemove, const bool bUpdateStats = true)`
- Python：`remove_actor_from_layer(actor, layer_to_remove, b_update_stats=True) -> bool`
- 说明：把 Actor 移出指定层；Actor 原本不属于该层时返回 `False`。
- 示例：

```python
removed = api.remove_actor_from_layer(actor_item, "L_Props")
```

### remove_actor_from_layers

- C++ 签名：`bool RemoveActorFromLayers(AActor* Actor, const TArray<FName>& LayerNames, const bool bUpdateStats = true)`
- Python：`remove_actor_from_layers(actor, layer_names, b_update_stats=True) -> bool`
- 说明：把 Actor 移出多个命名层；至少移出一个层返回 `True`。
- 示例：

```python
removed = api.remove_actor_from_layers(actor_item, ["L_Props", "L_Interior"])
```

## 批量 Actor

### add_actors_to_layer

- C++ 签名：`bool AddActorsToLayer(const TArray<AActor*>& Actors, const FName& LayerName)`
- Python：`add_actors_to_layer(actors, layer_name) -> bool`
- 说明：把多个 Actor 加入命名层；全部已属于该层时返回 `False`。
- 示例：

```python
added = api.add_actors_to_layer(actors_list, "L_Props")
```

### add_actors_to_layers

- C++ 签名：`bool AddActorsToLayers(const TArray<AActor*>& Actors, const TArray<FName>& LayerNames)`
- Python：`add_actors_to_layers(actors, layer_names) -> bool`
- 说明：把多个 Actor 加入多个命名层；至少一个 Actor 加入至少一个层返回 `True`。
- 示例：

```python
added = api.add_actors_to_layers(actors_list, ["L_Props", "L_Interior"])
```

### disassociate_actors_from_layers

- C++ 签名：`bool DisassociateActorsFromLayers(const TArray<AActor*>& Actors)`
- Python：`disassociate_actors_from_layers(actors) -> bool`
- 说明：批量解除 Actor 与层系统的关联，批量删除前调用。
- 示例：

```python
api.disassociate_actors_from_layers(actors_to_delete)
```

### remove_actors_from_layer

- C++ 签名：`bool RemoveActorsFromLayer(const TArray<AActor*>& Actors, const FName& LayerName, const bool bUpdateStats = true)`
- Python：`remove_actors_from_layer(actors, layer_name, b_update_stats=True) -> bool`
- 说明：把多个 Actor 移出指定层；全部本不属于该层时返回 `False`。
- 示例：

```python
removed = api.remove_actors_from_layer(actors_list, "L_Props")
```

### remove_actors_from_layers

- C++ 签名：`bool RemoveActorsFromLayers(const TArray<AActor*>& Actors, const TArray<FName>& LayerNames, const bool bUpdateStats = true)`
- Python：`remove_actors_from_layers(actors, layer_names, b_update_stats=True) -> bool`
- 说明：把多个 Actor 移出多个命名层；至少一个人移出一个层返回 `True`。
- 示例：

```python
removed = api.remove_actors_from_layers(actors_list, ["L_Props", "L_Interior"])
```

## 选中 Actor

### get_selected_actors

- C++ 签名：`TArray<AActor*> GetSelectedActors() const`
- Python：`get_selected_actors() -> Array[Actor]`
- 说明：返回当前编辑器选择集。
- 示例：

```python
selected = api.get_selected_actors()
```

### add_selected_actors_to_layer

- C++ 签名：`bool AddSelectedActorsToLayer(const FName& LayerName)`
- Python：`add_selected_actors_to_layer(layer_name) -> bool`
- 说明：把选中 Actor 加入命名层；没有选中或全部已属于该层时返回 `False`。
- 示例：

```python
api.add_selected_actors_to_layer("L_Props")
```

### add_selected_actors_to_layers

- C++ 签名：`bool AddSelectedActorsToLayers(const TArray<FName>& LayerNames)`
- Python：`add_selected_actors_to_layers(layer_names) -> bool`
- 说明：把选中 Actor 加入多个命名层。
- 示例：

```python
api.add_selected_actors_to_layers(["L_Props", "L_Interior"])
```

### remove_selected_actors_from_layer

- C++ 签名：`bool RemoveSelectedActorsFromLayer(const FName& LayerName)`
- Python：`remove_selected_actors_from_layer(layer_name) -> bool`
- 说明：把选中 Actor 从命名层移出。
- 示例：

```python
api.remove_selected_actors_from_layer("L_Props")
```

### remove_selected_actors_from_layers

- C++ 签名：`bool RemoveSelectedActorsFromLayers(const TArray<FName>& LayerNames)`
- Python：`remove_selected_actors_from_layers(layer_names) -> bool`
- 说明：把选中 Actor 从多个命名层移出。
- 示例：

```python
api.remove_selected_actors_from_layers(["L_Props", "L_Interior"])
```

## 层内选择

### select_actors_in_layer

- C++ 签名：`bool SelectActorsInLayer(const FName& LayerName, const bool bSelect, const bool bNotify, const bool bSelectEvenIfHidden = false)`
- Python：`select_actors_in_layer(layer_name, b_select, b_notify, b_select_even_if_hidden=False) -> bool`
- 说明：按层名选中/取消选中该层 Actor；`b_notify=True` 通知编辑器选择变更；`b_select_even_if_hidden=True` 时隐藏 Actor 也参与选择。
- 示例：

```python
done = api.select_actors_in_layer("L_Props", True, True)
```

### select_actors_in_layers

- C++ 签名：`bool SelectActorsInLayers(const TArray<FName>& LayerNames, const bool bSelect, const bool bNotify, const bool bSelectEvenIfHidden = false)`
- Python：`select_actors_in_layers(layer_names, b_select, b_notify, b_select_even_if_hidden=False) -> bool`
- 说明：按多个层名批量选中/取消选中；至少一个 Actor 发生状态变化返回 `True`。
- 示例：

```python
done = api.select_actors_in_layers(["L_Props", "L_Character"], True, True)
```

## 层内查询

### get_actors_from_layer

- C++ 签名：`TArray<AActor*> GetActorsFromLayer(const FName& LayerName) const`
- Python：`get_actors_from_layer(layer_name) -> Array[Actor]`
- 说明：返回指定层的全部 Actor；层不存在时返回空数组。
- 示例：

```python
prop_actors = api.get_actors_from_layer("L_Props")
```

### get_actors_from_layers

- C++ 签名：`TArray<AActor*> GetActorsFromLayers(const TArray<FName>& LayerNames) const`
- Python：`get_actors_from_layers(layer_names) -> Array[Actor]`
- 说明：返回任意指定层包含的全部 Actor。
- 示例：

```python
combined = api.get_actors_from_layers(["L_Props", "L_Character"])
```

### append_actors_from_layer

- C++ 签名：`void AppendActorsFromLayer(const FName& LayerName, TArray<AActor*>& InOutActors) const`
- Python：`append_actors_from_layer(layer_name) -> Array[Actor]`（Out 参数直接返回）
- 说明：把层内 Actor 追加到返回列表，累积到已有集合再补查时使用。
- 示例：

```python
acc = api.append_actors_from_layer("L_Props")
```

### append_actors_from_layers

- C++ 签名：`void AppendActorsFromLayers(const TArray<FName>& LayerNames, TArray<AActor*>& InOutActors) const`
- Python：`append_actors_from_layers(layer_names) -> Array[Actor]`（Out 参数直接返回）
- 说明：把任意指定层的 Actor 追加到返回列表。
- 示例：

```python
acc = api.append_actors_from_layers(["L_Props", "L_Character"])
```

## 层可见性

### set_layer_visibility

- C++ 签名：`void SetLayerVisibility(const FName& LayerName, const bool bIsVisible)`
- Python：`set_layer_visibility(layer_name, b_is_visible) -> None`
- 说明：设置单层可见性。
- 示例：

```python
api.set_layer_visibility("L_Props", False)
```

### set_layers_visibility

- C++ 签名：`void SetLayersVisibility(const TArray<FName>& LayerNames, const bool bIsVisible)`
- Python：`set_layers_visibility(layer_names, b_is_visible) -> None`
- 说明：批量设置层可见性。
- 示例：

```python
api.set_layers_visibility(["L_Props", "L_Interior"], False)
```

### toggle_layer_visibility

- C++ 签名：`void ToggleLayerVisibility(const FName& LayerName)`
- Python：`toggle_layer_visibility(layer_name) -> None`
- 说明：切换单层可见性。
- 示例：

```python
api.toggle_layer_visibility("L_Props")
```

### toggle_layers_visibility

- C++ 签名：`void ToggleLayersVisibility(const TArray<FName>& LayerNames)`
- Python：`toggle_layers_visibility(layer_names) -> None`
- 说明：切换多个层的可见性。
- 示例：

```python
api.toggle_layers_visibility(["L_Props", "L_Character"])
```

### make_all_layers_visible

- C++ 签名：`void MakeAllLayersVisible()`
- Python：`make_all_layers_visible() -> None`
- 说明：把全部层设为可见。
- 示例：

```python
api.make_all_layers_visible()
```

## 视口刷新

### update_all_view_visibility

- C++ 签名：`void UpdateAllViewVisibility(const FName& LayerThatChanged)`
- Python：`update_all_view_visibility(layer_that_changed) -> None`
- 说明：更新所有视图中所有 Actor 的可见性；`layer_that_changed` 限定只更新受影响层相关 Actor。
- 示例：

```python
api.update_all_view_visibility("L_Props")
```

### update_actor_all_views_visibility

- C++ 签名：`void UpdateActorAllViewsVisibility(AActor* Actor)`
- Python：`update_actor_all_views_visibility(actor) -> None`
- 说明：在所有视图中更新单个 Actor 的可见性。
- 示例：

```python
api.update_actor_all_views_visibility(actor_item)
```

### update_actor_visibility

- C++ 签名：`bool UpdateActorVisibility(AActor* Actor, bool& bOutSelectionChanged, bool& bOutActorModified, const bool bNotifySelectionChange, const bool bRedrawViewports)`
- Python：`update_actor_visibility(actor, b_notify_selection_change, b_redraw_viewports) -> tuple[bool, bool, bool]`
- 说明：更新 Actor 在视口中的可见性；返回 `(成功, b_out_selection_changed, b_out_actor_modified)`，Out 参数并入元组。
- 示例：

```python
ok, sel_changed, actor_modified = api.update_actor_visibility(actor_item, True, True)
```

### update_all_actors_visibility

- C++ 签名：`bool UpdateAllActorsVisibility(const bool bNotifySelectionChange, const bool bRedrawViewports)`
- Python：`update_all_actors_visibility(b_notify_selection_change, b_redraw_viewports) -> bool`
- 说明：更新全部 Actor 在视口中的可见性。
- 示例：

```python
ok = api.update_all_actors_visibility(True, True)
```

## 层对象管理

### is_layer

- C++ 签名：`bool IsLayer(const FName& LayerName)`
- Python：`is_layer(layer_name) -> bool`
- 说明：检查命名层对象是否存在。
- 示例：

```python
if api.is_layer("L_Props"):
    pass
```

### get_layer

- C++ 签名：`ULayer* GetLayer(const FName& LayerName) const`
- Python：`get_layer(layer_name) -> Layer`
- 说明：返回命名层的 `ULayer` 对象；不存在返回 `None`。
- 示例：

```python
layer_obj = api.get_layer("L_Props")
```

### try_get_layer

- C++ 签名：`bool TryGetLayer(const FName& LayerName, ULayer*& OutLayer)`
- Python：`try_get_layer(layer_name) -> tuple[bool, Layer]`
- 说明：尝试取层对象；存在返回 `(True, layer)`，不存在返回 `(False, None)`。
- 示例：

```python
found, layer_obj = api.try_get_layer("L_Props")
```

### create_layer

- C++ 签名：`ULayer* CreateLayer(const FName& LayerName)`
- Python：`create_layer(layer_name) -> Layer`
- 说明：创建命名层对象并返回；创建失败返回 `None`。
- 示例：

```python
new_layer = api.create_layer("L_Props")
if new_layer is None:
    print({"status": "BLOCKED_INPUT", "reason": "layer 创建失败"})
```

### delete_layer

- C++ 签名：`void DeleteLayer(const FName& LayerToDelete)`
- Python：`delete_layer(layer_to_delete) -> None`
- 说明：删除单层，并把其中 Actor 与该层解除关联。
- 示例：

```python
api.delete_layer("L_Props")
```

### delete_layers

- C++ 签名：`void DeleteLayers(const TArray<FName>& LayersToDelete)`
- Python：`delete_layers(layers_to_delete) -> None`
- 说明：删除多层，批量解除 Actor 关联。
- 示例：

```python
api.delete_layers(["L_Props", "L_Interior"])
```

### rename_layer

- C++ 签名：`bool RenameLayer(const FName& OriginalLayerName, const FName& NewLayerName)`
- Python：`rename_layer(original_layer_name, new_layer_name) -> bool`
- 说明：把原层重命名为新名；重命名失败（例如目标名已存在）返回 `False`。
- 示例：

```python
ok = api.rename_layer("L_Props", "L_Props_Propaganda")
```

### add_all_layer_names_to

- C++ 签名：`void AddAllLayerNamesTo(TArray<FName>& OutLayerNames) const`
- Python：`add_all_layer_names_to() -> Array[Name]`（Out 参数直接返回）
- 说明：返回全部已知层名。
- 示例：

```python
all_names = api.add_all_layer_names_to()
```

### add_all_layers_to

- C++ 签名：`void AddAllLayersTo(TArray<ULayer*>& OutLayers) const`
- Python：`add_all_layers_to() -> Array[Layer]`（Out 参数直接返回）
- 说明：返回全部已知 `ULayer` 对象。
- 示例：

```python
all_layers = api.add_all_layers_to()
```

## 刷新钩子

### editor_map_change

- C++ 签名：`void EditorMapChange()`
- Python：`editor_map_change() -> None`
- 说明：地图变更委托处理器，内部广播层变更事件。
- 示例：

```python
api.editor_map_change()
```

### editor_refresh_layer_browser

- C++ 签名：`void EditorRefreshLayerBrowser()`
- Python：`editor_refresh_layer_browser() -> None`
- 说明：刷新 Layer 浏览器委托处理器，内部更新各层 Actor 可见性。
- 示例：

```python
api.editor_refresh_layer_browser()
```

## 完整示例：按层组织场景 Actor

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "LayersSubsystem 不可用"})
        return

    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

    layer = api.create_layer("L_Props")
    if layer is None:
        print({"status": "BLOCKED_INPUT", "reason": "创建层失败"})
        return

    actor_class = unreal.load_class("/Script/Engine.StaticMeshActor")
    if actor_class is None:
        print({"status": "BLOCKED_INPUT", "reason": "actor class 无法加载"})
        api.delete_layer("L_Props")
        return

    editor_actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    spawned = []
    for x in range(0, 300, 100):
        a = editor_actor_subsystem.spawn_actor_from_class(
            actor_class,
            unreal.Vector(float(x), 0.0, 0.0),
        )
        if a is not None:
            spawned.append(a)

    added = api.add_actors_to_layer(spawned, "L_Props")
    inside = api.get_actors_from_layer("L_Props")
    api.set_layer_visibility("L_Props", False)

    print({"status": "OK", "added": added, "in_layer": len(inside)})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（层名、`AActor`、`ULevel` 等），或层/Actor 不存在且无法自动判定。
- `BLOCKED_TOOLING`：`LayersSubsystem` 或编辑器脚本上下文不可用，无法执行。
- 层（Layer）是关卡组织数据，配合世界构建流程使用；创建/删除/重命名层与可见性修改会改变关卡组织，必须经编辑器接口保存（`unreal.EditorLoadingAndSavingUtils` / 关卡保存）并由审计/QA 独立验收；未验证前不得声称已完成。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。