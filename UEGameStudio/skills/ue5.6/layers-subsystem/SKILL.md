---
name: layers-subsystem
description: ULayersSubsystem（UE 5.6）关卡层（Layers）组织数据 - 创建/删除/重命名层、Actor 加入/移出层、按层查询与层可见性；在 Agent 需要通过 unreal Python 管理关卡分层组织时使用
tags: [ue5.6, editor, layers, world, python, subsystem]
---

# LayersSubsystem - Layer Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `ULayersSubsystem` 暴露给 Python 的关卡层（Layers）操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Layers/LayersSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 依赖当前已加载关卡（Level）与编辑器主世界；层（Layer）是关卡组织数据，配合世界构建流程使用。
- 层名为 `FName`，Python 侧传 `str` 或 `unreal.Name`。
- 方法名由 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- Out 参数约定：`void` + 单个 Out 参数直接作为返回值返回；返回类型 + Out 参数按元组 `(返回值, Out...)` 返回。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 关卡信息 | `add_level_layer_information(level)` | `void AddLevelLayerInformation(ULevel*)` | `None` |
| 关卡信息 | `remove_level_layer_information(level)` | `void RemoveLevelLayerInformation(ULevel*)` | `None` |
| 关卡信息 | `get_world()` | `UWorld* GetWorld() const` | `World` |
| 单个 Actor | `is_actor_valid_for_layer(actor)` | `bool IsActorValidForLayer(AActor*)` | `bool` |
| 单个 Actor | `initialize_new_actor_layers(actor)` | `bool InitializeNewActorLayers(AActor*)` | `bool` |
| 单个 Actor | `disassociate_actor_from_layers(actor)` | `bool DisassociateActorFromLayers(AActor*)` | `bool` |
| 单个 Actor | `add_actor_to_layer(actor, layer_name)` | `bool AddActorToLayer(AActor*, const FName&)` | `bool` |
| 单个 Actor | `add_actor_to_layers(actor, layer_names)` | `bool AddActorToLayers(AActor*, const TArray<FName>&)` | `bool` |
| 单个 Actor | `remove_actor_from_layer(actor, layer_to_remove, b_update_stats=True)` | `bool RemoveActorFromLayer(AActor*, const FName&, const bool)` | `bool` |
| 单个 Actor | `remove_actor_from_layers(actor, layer_names, b_update_stats=True)` | `bool RemoveActorFromLayers(AActor*, const TArray<FName>&, const bool)` | `bool` |
| 批量 Actor | `add_actors_to_layer(actors, layer_name)` | `bool AddActorsToLayer(const TArray<AActor*>&, const FName&)` | `bool` |
| 批量 Actor | `add_actors_to_layers(actors, layer_names)` | `bool AddActorsToLayers(const TArray<AActor*>&, const TArray<FName>&)` | `bool` |
| 批量 Actor | `disassociate_actors_from_layers(actors)` | `bool DisassociateActorsFromLayers(const TArray<AActor*>&)` | `bool` |
| 批量 Actor | `remove_actors_from_layer(actors, layer_name, b_update_stats=True)` | `bool RemoveActorsFromLayer(const TArray<AActor*>&, const FName&, const bool)` | `bool` |
| 批量 Actor | `remove_actors_from_layers(actors, layer_names, b_update_stats=True)` | `bool RemoveActorsFromLayers(const TArray<AActor*>&, const TArray<FName>&, const bool)` | `bool` |
| 选中 Actor | `get_selected_actors()` | `TArray<AActor*> GetSelectedActors() const` | `Array[Actor]` |
| 选中 Actor | `add_selected_actors_to_layer(layer_name)` | `bool AddSelectedActorsToLayer(const FName&)` | `bool` |
| 选中 Actor | `add_selected_actors_to_layers(layer_names)` | `bool AddSelectedActorsToLayers(const TArray<FName>&)` | `bool` |
| 选中 Actor | `remove_selected_actors_from_layer(layer_name)` | `bool RemoveSelectedActorsFromLayer(const FName&)` | `bool` |
| 选中 Actor | `remove_selected_actors_from_layers(layer_names)` | `bool RemoveSelectedActorsFromLayers(const TArray<FName>&)` | `bool` |
| 层内选择 | `select_actors_in_layer(layer_name, b_select, b_notify, b_select_even_if_hidden=False)` | `bool SelectActorsInLayer(const FName&, const bool, const bool, const bool)` | `bool` |
| 层内选择 | `select_actors_in_layers(layer_names, b_select, b_notify, b_select_even_if_hidden=False)` | `bool SelectActorsInLayers(const TArray<FName>&, const bool, const bool, const bool)` | `bool` |
| 层内查询 | `get_actors_from_layer(layer_name)` | `TArray<AActor*> GetActorsFromLayer(const FName&) const` | `Array[Actor]` |
| 层内查询 | `get_actors_from_layers(layer_names)` | `TArray<AActor*> GetActorsFromLayers(const TArray<FName>&) const` | `Array[Actor]` |
| 层内查询 | `append_actors_from_layer(layer_name)` | `void AppendActorsFromLayer(const FName&, TArray<AActor*>&) const` | `Array[Actor]` |
| 层内查询 | `append_actors_from_layers(layer_names)` | `void AppendActorsFromLayers(const TArray<FName>&, TArray<AActor*>&) const` | `Array[Actor]` |
| 层可见性 | `set_layer_visibility(layer_name, b_is_visible)` | `void SetLayerVisibility(const FName&, const bool)` | `None` |
| 层可见性 | `set_layers_visibility(layer_names, b_is_visible)` | `void SetLayersVisibility(const TArray<FName>&, const bool)` | `None` |
| 层可见性 | `toggle_layer_visibility(layer_name)` | `void ToggleLayerVisibility(const FName&)` | `None` |
| 层可见性 | `toggle_layers_visibility(layer_names)` | `void ToggleLayersVisibility(const TArray<FName>&)` | `None` |
| 层可见性 | `make_all_layers_visible()` | `void MakeAllLayersVisible()` | `None` |
| 视口刷新 | `update_all_view_visibility(layer_that_changed)` | `void UpdateAllViewVisibility(const FName&)` | `None` |
| 视口刷新 | `update_actor_all_views_visibility(actor)` | `void UpdateActorAllViewsVisibility(AActor*)` | `None` |
| 视口刷新 | `update_actor_visibility(actor, b_notify_selection_change, b_redraw_viewports)` | `bool UpdateActorVisibility(AActor*, bool&, bool&, const bool, const bool)` | `tuple[bool, bool, bool]` |
| 视口刷新 | `update_all_actors_visibility(b_notify_selection_change, b_redraw_viewports)` | `bool UpdateAllActorsVisibility(const bool, const bool)` | `bool` |
| 层对象 | `is_layer(layer_name)` | `bool IsLayer(const FName&)` | `bool` |
| 层对象 | `get_layer(layer_name)` | `ULayer* GetLayer(const FName&) const` | `Layer` 或 `None` |
| 层对象 | `try_get_layer(layer_name)` | `bool TryGetLayer(const FName&, ULayer*&)` | `tuple[bool, Layer]` |
| 层对象 | `create_layer(layer_name)` | `ULayer* CreateLayer(const FName&)` | `Layer` 或 `None` |
| 层对象 | `delete_layer(layer_to_delete)` | `void DeleteLayer(const FName&)` | `None` |
| 层对象 | `delete_layers(layers_to_delete)` | `void DeleteLayers(const TArray<FName>&)` | `None` |
| 层对象 | `rename_layer(original_layer_name, new_layer_name)` | `bool RenameLayer(const FName&, const FName&)` | `bool` |
| 层对象 | `add_all_layer_names_to()` | `void AddAllLayerNamesTo(TArray<FName>&) const` | `Array[Name]` |
| 层对象 | `add_all_layers_to()` | `void AddAllLayersTo(TArray<ULayer*>&) const` | `Array[Layer]` |
| 刷新钩子 | `editor_map_change()` | `void EditorMapChange()` | `None` |
| 刷新钩子 | `editor_refresh_layer_browser()` | `void EditorRefreshLayerBrowser()` | `None` |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

layer = api.create_layer("L_Props")
print("layer created:", layer.get_name())

spawned = api.add_actors_to_layer(
    unreal.EditorActorSubsystem_get().spawn_class(  # 示意：先有 Actor 列表
        unreal.load_class("/Script/Engine.StaticMeshActor"),
        unreal.Vector(0.0, 0.0, 0.0),
    ),
    "L_Props",
)
print("actors in layer:", len(api.get_actors_from_layer("L_Props")))

api.set_layer_visibility("L_Props", False)
api.rename_layer("L_Props", "L_Props_Propaganda")
api.delete_layer("L_Props_Propaganda")
```

## 注意事项

- 层（Layer）是关卡组织数据，配合世界构建流程使用；创建/删除/重命名层与可见性修改会改变关卡组织，写入后必须经编辑器接口保存（`unreal.EditorLoadingAndSavingUtils.save_dirty_packages` 等）并由审计/QA 独立验收。
- `add_actor_to_layer` 等加入方法：Actor 已属于该层时返回 `False`；`remove_*` 在 Actor 原本不属于层时返回 `False`。
- `disassociate_actor_from_layers` / `disassociate_actors_from_layers` 一般用于删除 Actor 前解除关联，避免误删层数据。
- 批量与单个操作语义等价，批量方法不保证全部成功才算真；按返回值判定至少一个成功。
- 层不存在时 `get_layer` 返回 `None`，`get_actors_from_layer` 返回空数组，`IsLayer` 返回 `False`。
- 缺层名、`ULayer`、`AActor` 等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。