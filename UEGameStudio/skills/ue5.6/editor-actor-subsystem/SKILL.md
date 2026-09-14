---
name: editor-actor-subsystem
description: UEditorActorSubsystem（UE 5.6）Actor 编辑器原语 - 列举/查询/生成/复制/销毁/选择/转换/设置 Transform；在 Agent 需要通过 unreal Python 自动化编辑器关卡中的 Actor 操作时使用
risk: critical
category: development
tags: [ue5.6, editor, actor, python, subsystem]
---

# EditorActorSubsystem - Actor Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 自动化编辑器关卡中的 Actor 操作时使用本 skill（description 触发场景）。
- 本 skill 只在与 editor-actor-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UEditorActorSubsystem` 暴露给 Python 的 Actor 编辑器操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Subsystems/EditorActorSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 需要 `UWorld` 的方法传入编辑器主世界：`unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()`。
- 坐标为 `unreal.Vector` / `unreal.Rotator` / `unreal.Transform`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 列举 | `get_all_level_actors()` | `TArray<AActor*> GetAllLevelActors()` | `Array[Actor]` |
| 列举 | `get_all_level_actors_components()` | `TArray<UActorComponent*> GetAllLevelActorsComponents()` | `Array[ActorComponent]` |
| 列举 | `get_selected_level_actors()` | `TArray<AActor*> GetSelectedLevelActors()` | `Array[Actor]` |
| 查询 | `get_actor_reference(path_to_actor)` | `AActor* GetActorReference(FString)` | `Actor` 或 `None` |
| 生成 | `spawn_actor_from_object(object_to_use, location, rotation=..., b_transient=False)` | `AActor* SpawnActorFromObject(UObject*, FVector, FRotator, bool)` | `Actor` 或 `None` |
| 生成 | `spawn_actor_from_class(actor_class, location, rotation=..., b_transient=False)` | `AActor* SpawnActorFromClass(TSubclassOf<AActor>, FVector, FRotator, bool)` | `Actor` 或 `None` |
| 复制 | `duplicate_actor(actor_to_duplicate, to_world=None, offset=...)` | `AActor* DuplicateActor(AActor*, UWorld*, FVector)` | `Actor` 或 `None` |
| 复制 | `duplicate_actors(actors_to_duplicate, to_world=None, offset=...)` | `TArray<AActor*> DuplicateActors(const TArray<AActor*>&, UWorld*, FVector)` | `Array[Actor]` |
| 复制 | `duplicate_selected_actors(in_world)` | `void DuplicateSelectedActors(UWorld*)` | `None` |
| 销毁 | `destroy_actor(actor_to_destroy)` | `bool DestroyActor(AActor*)` | `bool` |
| 销毁 | `destroy_actors(actors_to_destroy)` | `bool DestroyActors(const TArray<AActor*>&)` | `bool` |
| 销毁 | `delete_selected_actors(in_world)` | `void DeleteSelectedActors(UWorld*)` | `None` |
| 选择 | `set_selected_level_actors(actors_to_select)` | `void SetSelectedLevelActors(const TArray<AActor*>&)` | `None` |
| 选择 | `clear_actor_selection_set()` | `void ClearActorSelectionSet()` | `None` |
| 选择 | `select_nothing()` | `void SelectNothing()` | `None` |
| 选择 | `set_actor_selection_state(actor, b_should_be_selected)` | `void SetActorSelectionState(AActor*, bool)` | `None` |
| 选择 | `invert_selection(in_world)` | `void InvertSelection(UWorld*)` | `None` |
| 选择 | `select_all(in_world)` | `void SelectAll(UWorld*)` | `None` |
| 选择 | `select_all_children(b_recurse_children)` | `void SelectAllChildren(bool)` | `None` |
| 转换 | `convert_actors(actors, actor_class, static_mesh_package_path)` | `TArray<AActor*> ConvertActors(const TArray<AActor*>&, TSubclassOf<AActor>, const FString&)` | `Array[Actor]` |
| 变换 | `set_actor_transform(actor, world_transform)` | `bool SetActorTransform(AActor*, const FTransform&)` | `bool` |
| 变换 | `set_component_transform(scene_component, world_transform)` | `bool SetComponentTransform(USceneComponent*, const FTransform&)` | `bool` |

## 示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
api = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)

actors = api.get_all_level_actors()
print("actor count:", len(actors))

prop_class = unreal.load_class("/Game/Blueprints/BP_Prop")
prop = api.spawn_actor_from_class(
    prop_class,
    unreal.Vector(1000.0, 2000.0, 0.0),
    rotation=unreal.Rotator(0.0, 90.0, 0.0),
)
ok = api.set_actor_transform(
    prop,
    unreal.Transform(
        location=unreal.Vector(1200.0, 1800.0, 300.0),
        rotation=unreal.Rotator(0.0, 45.0, 0.0),
        scale3d=unreal.Vector(1.0, 1.0, 1.0),
    ),
)
if not ok:
    print("transform not applied")

api.destroy_actor(prop)
```

## 限制和注意事项

- 只操作已加载关卡中的 Actor；`GetAllLevelActors` 不包含 PendingKill、PIE、PreviewEditor 中的对象。
- `get_actor_reference` 的路径形如 `PersistentLevel.PlayerStart`，未找到返回 `None`。
- 批量选择/销毁前先构造选择集（`set_selected_level_actors`），否则作用范围不可预期。
- 生成/复制/销毁属于关卡内容修改，写入后必须经编辑器接口保存并由审计/QA 独立验收。
- 缺类路径、`UWorld` 等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
