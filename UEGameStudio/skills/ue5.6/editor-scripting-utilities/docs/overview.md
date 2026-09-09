# UEditorScriptingUtilities API 参考（UE 5.6）

本页列出 `UEditorScriptingUtilities` 的完整 Python 方法映射表，按功能分组。

## Actor 重命名（Actor Renaming）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `rename_actor(actor, new_name, b_force)` | `bool RenameActor(const AActor*, const FString&, bool)` | `bool` |
| `rename_selected_actors(new_name_prefix, new_name_suffix)` | `int32 RenameSelectedActors(const FString&, const FString&)` | `int` |
| `get_actor_label(actor)` | `FString GetActorLabel(const AActor*)` | `str` |
| `set_actor_label(actor, new_label, b_force)` | `bool SetActorLabel(const AActor*, const FString&, bool)` | `bool` |

## 冲突检测（Conflict Detection）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_all_actor_labels()` | `TArray<FString> GetAllActorLabels()` | `Array[str]` |
| `get_actor_by_label(world_context, label)` | `AActor* GetActorByLabel(..., const FString&)` | `Actor` 或 `None` |
| `get_actors_with_label(world_context, label)` | `void GetActorsWithLabel(..., TArray<AActor*>&)` | `Array[Actor]` |
| `has_conflicting_actor_labels(world_context, out_conflicts)` | `bool HasConflictingActorLabels(..., TArray<FString>&)` | `(bool, Array[str])` |

## 路径与资产（Path & Assets）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_actor_path_name(actor)` | `FString GetActorPathName(const AActor*)` | `str` |
| `get_actor_world_name(actor)` | `FString GetActorWorldName(const AActor*)` | `str` |
| `get_selected_assets()` | `TArray<UObject*> GetSelectedAssets()` | `Array[Object]` |
| `get_selected_actors(b_include_selected_in_viewport, b_include_all_in_level)` | `TArray<AActor*> GetSelectedActors(...)` | `Array[Actor]` |
| `get_selected_actors_in_level(level_name)` | `TArray<AActor*> GetSelectedActorsInLevel(const FString&)` | `Array[Actor]` |
| `clear_selection_set()` | `void ClearSelectionSet()` | `None` |
| `select_assets(assets_to_select, b_replace)` | `void SelectAssets(const TArray<UObject*>&, bool)` | `None` |
| `select_actors(actors_to_select, b_replace)` | `void SelectActors(const TArray<AActor*>&, bool)` | `None` |
| `get_all_actors_in_level(level_name)` | `TArray<AActor*> GetAllActorsInLevel(const FString&)` | `Array[Actor]` |
| `get_all_actors_of_class(world_context, actor_class, level_name)` | `void GetAllActorsOfClass(..., UClass*, const FString&, TArray<AActor*>&)` | `Array[Actor]` |
| `get_all_actors_with_tag(world_context, tag, level_name)` | `void GetAllActorsWithTag(..., const FName&, const FString&, TArray<AActor*>&)` | `Array[Actor]` |
| `find_actor_by_label(world_context, label, b_include_descendants)` | `AActor* FindActorByLabel(..., const FString&, bool)` | `Actor` 或 `None` |
