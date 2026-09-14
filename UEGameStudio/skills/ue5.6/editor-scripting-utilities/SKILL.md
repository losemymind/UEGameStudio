---
name: editor-scripting-utilities
description: UEditorScriptingUtilities（UE 5.6）编辑器脚本工具库 - Actor/ActorLabel管理、命名冲突检测、批量重命名、资产路径操作；在 Agent 需要通过 unreal Python 对编辑器执行脚本化资产操作时使用
risk: critical
category: development
tags: [ue5.6, editor, scripting, python, statics]
---

# EditorScriptingUtilities - 编辑器脚本工具库（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 对编辑器执行脚本化资产操作时使用本 skill（description 触发场景）。
- 本 skill 只在与 editor-scripting-utilities 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UEditorScriptingUtilities`（`UObject` 派生，**静态类**）通过 Python 可调用的类方法。方法名与签名依据 `EditorScriptingUtilities/Classes/EditorScriptingUtilities.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UEditorScriptingUtilities` 在 Python 中以类方法形式暴露在 `unreal.EditorScriptingUtilities` 上：

```python
import unreal

# 示例：批量重命名 Actor
actor_list = [actor1, actor2, actor3]
unreal.EditorScriptingUtilities.rename_actor(actor, "NewName")
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.EditorScriptingUtilities)` 核对）。
- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用会失败。
- 大部分方法需要选中的 Actor 或明确的 Actor 引用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **Actor 重命名** | | | |
| 重命名 | `rename_actor(actor, new_name, b_force)` | `bool RenameActor(const AActor*, const FString&, bool)` | `bool` |
| 重命名 | `rename_selected_actors(new_name_prefix, new_name_suffix)` | `int32 RenameSelectedActors(const FString&, const FString&)` | `int` |
| 重命名 | `get_actor_label(actor)` | `FString GetActorLabel(const AActor*)` | `str` |
| 重命名 | `set_actor_label(actor, new_label, b_force)` | `bool SetActorLabel(const AActor*, const FString&, bool)` | `bool` |
| **冲突检测** | | | |
| 冲突 | `get_all_actor_labels()` | `TArray<FString> GetAllActorLabels()` | `Array[str]` |
| 冲突 | `get_actor_by_label(world_context, label)` | `AActor* GetActorByLabel(..., const FString&)` | `Actor` 或 `None` |
| 冲突 | `get_actors_with_label(world_context, label)` | `void GetActorsWithLabel(..., TArray<AActor*>&)` | `Array[Actor]` |
| 冲突 | `has_conflicting_actor_labels(world_context, out_conflicts)` | `bool HasConflictingActorLabels(..., TArray<FString>&)` | `(bool, Array[str])` |
| **路径与资产** | | | |
| 路径 | `get_actor_path_name(actor)` | `FString GetActorPathName(const AActor*)` | `str` |
| 路径 | `get_actor_world_name(actor)` | `FString GetActorWorldName(const AActor*)` | `str` |
| 资产 | `get_selected_assets()` | `TArray<UObject*> GetSelectedAssets()` | `Array[Object]` |
| 资产 | `get_selected_actors(b_include_selected_in_viewport, b_include_all_in_level)` | `TArray<AActor*> GetSelectedActors(...)` | `Array[Actor]` |
| 资产 | `get_selected_actors_in_level(level_name)` | `TArray<AActor*> GetSelectedActorsInLevel(const FString&)` | `Array[Actor]` |
| 辅助 | `clear_selection_set()` | `void ClearSelectionSet()` | `None` |
| 辅助 | `select_assets(assets_to_select, b_replace)` | `void SelectAssets(const TArray<UObject*>&, bool)` | `None` |
| 辅助 | `select_actors(actors_to_select, b_replace)` | `void SelectActors(const TArray<AActor*>&, bool)` | `None` |
| 辅助 | `get_all_actors_in_level(level_name)` | `TArray<AActor*> GetAllActorsInLevel(const FString&)` | `Array[Actor]` |
| 辅助 | `get_all_actors_of_class(world_context, actor_class, level_name)` | `void GetAllActorsOfClass(..., UClass*, const FString&, TArray<AActor*>&)` | `Array[Actor]` |
| 辅助 | `get_all_actors_with_tag(world_context, tag, level_name)` | `void GetAllActorsWithTag(..., const FName&, const FString&, TArray<AActor*>&)` | `Array[Actor]` |
| 辅助 | `find_actor_by_label(world_context, label, b_include_descendants)` | `AActor* FindActorByLabel(..., const FString&, bool)` | `Actor` 或 `None` |

## 示例

```python
import unreal

def script_editor():
    api = unreal.EditorScriptingUtilities
    
    # 批量重命名选中的 Actor
    count = api.rename_selected_actors("BP_", "_Actor")
    print("renamed", count, "actors")
    
    # 查询 Actor label
    selected_actors = api.get_selected_actors(True, True)
    for actor in selected_actors:
        label = api.get_actor_label(actor)
        print("actor label:", label)
    
    # 检测命名冲突
    has_conflict, conflicts = api.has_conflicting_actor_labels(None)
    if has_conflict:
        print("conflicting labels:", conflicts)
    
    # 清除选择
    api.clear_selection_set()

if __name__ == "__main__":
    script_editor()
```

## 限制和注意事项

- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用返回 `BLOCKED_TOOLING`。
- `RenameSelectedActors` 的 `b_force` 参数决定是否强制重命名（覆盖已有名称）；`false` 时保留原始名称。
- `HasConflictingActorLabels` 查找同 Level 内重复的 Actor Label，返回冲突的 Label 数组。
- `GetActorByLabel` / `FindActorByLabel` 按 Actor Label（非 Asset Path）查询；区分大小写。
- `SelectAssets` / `SelectActors` 的 `b_replace` 参数决定是替换当前选择（`true`）还是追加（`false`）。
- 缺 Actor、Level 名、资产路径等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
