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

## 综合实战示例

### 批量关卡组织管理系统

```python
import unreal

class LayerOrganizer:
    def __init__(self):
        self.api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        self.layer_categories = {
            "L_Environmental": ["Nature_01", "Nature_02"],
            "L_Props": ["Props_Detail", "Props_Buildings"],
            "L_Character": ["Character_Debug", "Character_AI"],
            "L_VisualFX": ["VFX_Environment", "VFX_Explosion"]
        }
    
    def ensure_layer(self, layer_name):
        if not self.api.is_layer(layer_name):
            layer = self.api.create_layer(layer_name)
            return layer is not None
        return True
    
    def batch_create_layers(self, layer_names):
        created = []
        for name in layer_names:
            if self.ensure_layer(name):
                created.append(name)
        return created
    
    def assign_actors_to_layer(self, actor_list, layer_name):
        if not actor_list or not self.ensure_layer(layer_name):
            return False
        return self.api.add_actors_to_layer(actor_list, layer_name)
    
    def get_actors_by_category(self, category):
        layer_names = self.layer_categories.get(category, [])
        all_actors = []
        for layer_name in layer_names:
            actors = self.api.get_actors_from_layer(layer_name)
            all_actors.extend(actors)
        return all_actors

def organize_large_scene():
    organizer = LayerOrganizer()
    
    # 创建所有层
    all_layers = []
    for category, layers in organizer.layer_categories.items():
        all_layers.extend(layers)
    
    created = organizer.batch_create_layers(all_layers)
    print(f"Created {len(created)} layers")
    
    # 批量分配 Actor
    all_actors = unreal.EditorLevelLibrary.get_all_dirty_actors()
    environmental_actors = all_actors[:len(all_actors)//4]
    props_actors = all_actors[len(all_actors)//4:len(all_actors)//2]
    
    organizer.assign_actors_to_layer(environmental_actors, "L_Environmental")
    organizer.assign_actors_to_layer(props_actors, "L_Props")
    
    print("L_Environmental actors:", len(organizer.get_actors_by_category("L_Environmental")))
```

### 视口同步与层选择

```python
import unreal

def viewport_layer_selection():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # 按层选择 Actor
    api.select_actors_in_layer("L_Character", True, True, False)
    
    # 批量选择多层
    api.select_actors_in_layers(["L_Character", "L_VisualFX"], True, True, False)
    
    # 撤销选择
    api.select_actors_in_layer("L_Character", False, True, False)
    
    # 获取选中的 Actor
    selected = api.get_selected_actors()
    print(f"Selected actors: {len(selected)}")
    
    # 取消选择并添加到新层
    api.remove_selected_actors_from_layer("OldLayer")
    api.add_selected_actors_to_layer("NewLayer")
```

### 层统计与可视化

```python
import unreal

def layer_statistics():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # 获取所有层
    all_layer_names = []
    api.add_all_layer_names_to(all_layer_names)
    
    stats = {}
    for layer_name in all_layer_names:
        actors = api.get_actors_from_layer(layer_name)
        stats[layer_name] = {
            "count": len(actors),
            "visible": api.is_level_visible(layer_name) if hasattr(api, 'is_level_visible') else True,
            "actors": [a.get_actor_label() for a in actors[:5]]  # 示例：只取前5个
        }
    
    # 打印统计
    for layer_name, info in stats.items():
        print(f"{layer_name}: {info['count']} actors, visible={info['visible']}")
    
    return stats

def toggle_all_layers_visibility(visible):
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    all_layer_names = []
    api.add_all_layer_names_to(all_layer_names)
    
    api.set_layers_visibility(all_layer_names, visible)
    api.update_all_view_visibility(None)
```

## 高级用法

### 层可见性与性能优化

```python
import unreal

def layer_culling_system():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    camera_location = unreal.Vector(0.0, 0.0, 0.0)  # 示例：相机位置
    
    # 简单视锥体剔除
    def is_layer_in_viewport(layer_name, camera_loc, view_distance=5000.0):
        actors = api.get_actors_from_layer(layer_name)
        if not actors:
            return False
        
        for actor in actors:
            loc = actor.get_actor_location()
            distance = unreal.KismetMathLibrary.length(
                unreal.KismetMathLibrary.subtract(loc, camera_loc)
            )
            if distance < view_distance:
                return True
        return False
    
    # 动态可见性
    def update_layer_visibility_based_on_camera():
        camera_pos = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world().get_actors()[0].get_actor_location() if unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world().get_actors() else unreal.Vector(0.0, 0.0, 0.0)
        
        all_layers = []
        api.add_all_layer_names_to(all_layers)
        
        for layer_name in all_layers:
            in_view = is_layer_in_viewport(layer_name, camera_pos)
            api.set_layer_visibility(layer_name, in_view)
    
    update_layer_visibility_based_on_camera()
```

### 层标签系统

```python
import unreal

def layer_tag_system():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # 为层添加元数据
    layer_metadata = {}
    
    def set_layer_metadata(layer_name, key, value):
        if layer_name not in layer_metadata:
            layer_metadata[layer_name] = {}
        layer_metadata[layer_name][key] = value
    
    def get_layer_metadata(layer_name, key, default=None):
        return layer_metadata.get(layer_name, {}).get(key, default)
    
    # 使用示例
    all_layers = []
    api.add_all_layer_names_to(all_layers)
    
    for layer_name in all_layers:
        actors = api.get_actors_from_layer(layer_name)
        
        set_layer_metadata(layer_name, "actor_count", len(actors))
        set_layer_metadata(layer_name, "is_visual", "VFX" in layer_name or "FX" in layer_name)
        set_layer_metadata(layer_name, "is_geometry", "Environment" in layer_name or "Props" in layer_name)
    
    # 查询
    for layer_name in all_layers:
        count = get_layer_metadata(layer_name, "actor_count", 0)
        is_visual = get_layer_metadata(layer_name, "is_visual", False)
        print(f"{layer_name}: {count} actors, visual={is_visual}")
```

### 层版本控制与冲突解决

```python
import unreal

def layer_conflict_resolver():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # 检测跨层重复Actor
    def detect_actor_duplicate_across_layers():
        all_layers = []
        api.add_all_layer_names_to(all_layers)
        
        actor_to_layers = {}
        
        for layer_name in all_layers:
            actors = api.get_actors_from_layer(layer_name)
            for actor in actors:
                actor_name = actor.get_name()
                if actor_name not in actor_to_layers:
                    actor_to_layers[actor_name] = []
                actor_to_layers[actor_name].append(layer_name)
        
        duplicates = {
            actor: layers 
            for actor, layers in actor_to_layers.items() 
            if len(layers) > 1
        }
        
        return duplicates
    
    # 合并层
    def merge_layers(source_layers, target_layer):
        for source_layer in source_layers:
            actors = api.get_actors_from_layer(source_layer)
            if actors:
                api.add_actors_to_layer(actors, target_layer)
                api.remove_actors_from_layer(actors, source_layer)
        
        # 删除源层
        for source_layer in source_layers:
            api.delete_layer(source_layer)
```

## 常见问题与最佳实践

### 层命名约定

1. **推荐前缀**：
   - `L_`：基础层（L_Environmental, L_Props）
   - `VFX_`：视觉特效层（VFX_Environment, VFX_Explosion）
   - `Debug_`：调试层（Debug_Camera, Debug_AI）

2. **避免冲突**：
   - 不同功能使用不同前缀
   - 考虑语言环境（中文项目可用拼音前缀）

### 批量操作性能优化

1. **使用批量方法**：
   - `add_actors_to_layers` 替代循环调用 `add_actor_to_layer`
   - `set_layers_visibility` 替代循环调用 `set_layer_visibility`

2. **减少视口刷新**：
   - 批量操作完成后统一调用 `update_all_view_visibility`
   - 避免在循环中频繁刷新

### 常见陷阱

1. **层不存在时的操作**：
   - `add_actor_to_layer` 返回 False 表示层不存在
   - `get_actors_from_layer` 返回空数组而非 None
   
2. **Actor所有权**：
   - Actor 可同时属于多个层
   - `remove_*` 系列方法只移除单次关联

## 注意事项

- 层（Layer）是关卡组织数据，配合世界构建流程使用；创建/删除/重命名层与可见性修改会改变关卡组织，写入后必须经编辑器接口保存（`unreal.EditorLoadingAndSavingUtils.save_dirty_packages` 等）并由审计/QA 独立验收。
- `add_actor_to_layer` 等加入方法：Actor 已属于该层时返回 `False`；`remove_*` 在 Actor 原本不属于层时返回 `False`。
- `disassociate_actor_from_layers` / `disassociate_actors_from_layers` 一般用于删除 Actor 前解除关联，避免误删层数据。
- 批量与单个操作语义等价，批量方法不保证全部成功才算真；按返回值判定至少一个成功。
- 层不存在时 `get_layer` 返回 `None`，`get_actors_from_layer` 返回空数组，`IsLayer` 返回 `False`。
- 缺层名、`ULayer`、`AActor` 等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。