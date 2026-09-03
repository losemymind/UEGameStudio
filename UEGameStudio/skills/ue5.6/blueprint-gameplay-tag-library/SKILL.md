---
name: blueprint-gameplay-tag-library
description: UBlueprintGameplayTagLibrary（UE 5.6）GameplayTag 查询库 - 标签匹配、容器增删查改、TagQuery 构造与判定、GameplayTagAssetInterface 读取、按 Tag Query 检索 Actor；在 Agent 需要通过 unreal Python 使用 GameplayTag/GameplayTagContainer/GameplayTagQuery API 时使用
tags: [ue5.6, gameplaytags, python, blueprint-function-library]
---

# BlueprintGameplayTagLibrary - GameplayTag 操作（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UBlueprintGameplayTagLibrary` 暴露给 Python 的静态方法，依据 `Engine/Source/Runtime/GameplayTags/Classes/BlueprintGameplayTagLibrary.h` 中带 `UFUNCTION(BlueprintCallable/BlueprintPure)` 标记的成员整理。覆盖标签匹配、容器查询与编辑、TagQuery 构造与判定、GameplayTagAssetInterface 读取和按 Tag Query 检索 Actor。GameplayTag 是 Gameplay 系统（GAS、AI 感知、任务条件）的基础，`game-ai-engineer` / `ue-gameplay-engineer` 均依赖本库。

## 入口说明

```python
import unreal
lib = unreal.BlueprintGameplayTagLibrary
```

- Python 类名取 UCLASS 类名 `UBlueprintGameplayTagLibrary` 去掉 U 前缀：`unreal.BlueprintGameplayTagLibrary`。
- 静态方法直接用类调用，无需实例；仅 `get_all_actors_of_class_matching_tag_query` 需要世界上下文对象。
- Python 类型对应：`FGameplayTag` → `unreal.GameplayTag`，`FGameplayTagContainer` → `unreal.GameplayTagContainer`，`FGameplayTagQuery` → `unreal.GameplayTagQuery`。
- 命名约定：本头文件未声明 `ScriptMethod`，方法名按 C++ 函数名转 snake_case 推定（如 `MatchesTag` → `matches_tag`）；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- Out/ByRef 返回约定：`void`+单 Out 直接返回；返回值+Out 按元组返回（返回值在首位）；无 Out 无返回值则 `None`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 匹配 | `matches_tag(tag_one, tag_two, b_exact_match)` | `bool MatchesTag(FGameplayTag, FGameplayTag, bool)` | `bool` |
| 匹配 | `matches_any_tags(tag_one, other_container, b_exact_match)` | `bool MatchesAnyTags(FGameplayTag, const FGameplayTagContainer&, bool)` | `bool` |
| 匹配 | `equal_equal_gameplay_tag(a, b)` | `bool EqualEqual_GameplayTag(FGameplayTag, FGameplayTag)` | `bool` |
| 匹配 | `not_equal_gameplay_tag(a, b)` | `bool NotEqual_GameplayTag(FGameplayTag, FGameplayTag)` | `bool` |
| 验证 | `is_gameplay_tag_valid(gameplay_tag)` | `bool IsGameplayTagValid(FGameplayTag)` | `bool` |
| 验证 | `get_tag_name(gameplay_tag)` | `FName GetTagName(const FGameplayTag&)` | `Name` |
| 构造 | `make_literal_gameplay_tag(value)` | `FGameplayTag MakeLiteralGameplayTag(FGameplayTag)` | `GameplayTag` |
| 构造 | `make_literal_gameplay_tag_container(value)` | `FGameplayTagContainer MakeLiteralGameplayTagContainer(FGameplayTagContainer)` | `GameplayTagContainer` |
| 构造 | `make_gameplay_tag_container_from_array(gameplay_tags)` | `FGameplayTagContainer MakeGameplayTagContainerFromArray(const TArray<FGameplayTag>&)` | `GameplayTagContainer` |
| 构造 | `make_gameplay_tag_container_from_tag(single_tag)` | `FGameplayTagContainer MakeGameplayTagContainerFromTag(FGameplayTag)` | `GameplayTagContainer` |
| 构造 | `break_gameplay_tag_container(gameplay_tag_container)` | `void BreakGameplayTagContainer(const FGameplayTagContainer&, TArray<FGameplayTag>&)` | `Array[GameplayTag]`（单 Out 直接返回） |
| 容器查询 | `get_num_gameplay_tags_in_container(tag_container)` | `int32 GetNumGameplayTagsInContainer(const FGameplayTagContainer&)` | `int` |
| 容器查询 | `has_tag(tag_container, tag, b_exact_match)` | `bool HasTag(const FGameplayTagContainer&, FGameplayTag, bool)` | `bool` |
| 容器查询 | `has_any_tags(tag_container, other_container, b_exact_match)` | `bool HasAnyTags(const FGameplayTagContainer&, const FGameplayTagContainer&, bool)` | `bool` |
| 容器查询 | `has_all_tags(tag_container, other_container, b_exact_match)` | `bool HasAllTags(const FGameplayTagContainer&, const FGameplayTagContainer&, bool)` | `bool` |
| 容器查询 | `filter(tag_container, other_container, b_exact_match)` | `FGameplayTagContainer Filter(const FGameplayTagContainer&, const FGameplayTagContainer&, bool)` | `GameplayTagContainer` |
| 容器编辑 | `add_gameplay_tag(tag_container, tag)` | `void AddGameplayTag(UPARAM(ref) FGameplayTagContainer&, FGameplayTag)` | `GameplayTagContainer`（ref 作 Out 返回） |
| 容器编辑 | `remove_gameplay_tag(tag_container, tag)` | `bool RemoveGameplayTag(UPARAM(ref) FGameplayTagContainer&, FGameplayTag)` | `(bool, GameplayTagContainer)` |
| 容器编辑 | `append_gameplay_tag_containers(in_out_tag_container, in_tag_container)` | `void AppendGameplayTagContainers(UPARAM(ref) FGameplayTagContainer&, const FGameplayTagContainer&)` | `GameplayTagContainer`（ref 作 Out 返回） |
| 容器比较 | `equal_equal_gameplay_tag_container(a, b)` | `bool EqualEqual_GameplayTagContainer(const FGameplayTagContainer&, const FGameplayTagContainer&)` | `bool` |
| 容器比较 | `not_equal_gameplay_tag_container(a, b)` | `bool NotEqual_GameplayTagContainer(const FGameplayTagContainer&, const FGameplayTagContainer&)` | `bool` |
| 容器比较 | `not_equal_tag_tag(a, b)` | `bool NotEqual_TagTag(FGameplayTag, FString)` | `bool` |
| 容器比较 | `not_equal_tag_container_tag_container(a, b)` | `bool NotEqual_TagContainerTagContainer(FGameplayTagContainer, FString)` | `bool` |
| TagQuery | `is_tag_query_empty(tag_query)` | `bool IsTagQueryEmpty(const FGameplayTagQuery&)` | `bool` |
| TagQuery | `does_container_match_tag_query(tag_container, tag_query)` | `bool DoesContainerMatchTagQuery(const FGameplayTagContainer&, const FGameplayTagQuery&)` | `bool` |
| TagQuery | `make_gameplay_tag_query(tag_query)` | `FGameplayTagQuery MakeGameplayTagQuery(FGameplayTagQuery)` | `GameplayTagQuery` |
| TagQuery | `make_gameplay_tag_query_match_any_tags(in_tags)` | `FGameplayTagQuery MakeGameplayTagQuery_MatchAnyTags(const FGameplayTagContainer&)` | `GameplayTagQuery` |
| TagQuery | `make_gameplay_tag_query_match_all_tags(in_tags)` | `FGameplayTagQuery MakeGameplayTagQuery_MatchAllTags(const FGameplayTagContainer&)` | `GameplayTagQuery` |
| TagQuery | `make_gameplay_tag_query_match_no_tags(in_tags)` | `FGameplayTagQuery MakeGameplayTagQuery_MatchNoTags(const FGameplayTagContainer&)` | `GameplayTagQuery` |
| 接口 | `has_all_matching_gameplay_tags(tag_container_interface, other_container)` | `bool HasAllMatchingGameplayTags(TScriptInterface<IGameplayTagAssetInterface>, const FGameplayTagContainer&)` | `bool` |
| 接口 | `does_tag_asset_interface_have_tag(tag_container_interface, tag)` | `bool DoesTagAssetInterfaceHaveTag(TScriptInterface<IGameplayTagAssetInterface>, FGameplayTag)` | `bool` |
| 接口 | `get_owned_gameplay_tags(tag_container_interface)` | `FGameplayTagContainer GetOwnedGameplayTags(TScriptInterface<IGameplayTagAssetInterface>)` | `GameplayTagContainer` |
| 接口 | `conv_object_to_gameplay_tag_asset_interface(in_object)` | `TScriptInterface<IGameplayTagAssetInterface> Conv_ObjectToGameplayTagAssetInterface(UObject*)` | `对象` |
| 世界查询 | `get_all_actors_of_class_matching_tag_query(world_context_object, actor_class, gameplay_tag_query)` | `void GetAllActorsOfClassMatchingTagQuery(UObject*, TSubclassOf<AActor>, const FGameplayTagQuery&, TArray<AActor*>&)` | `Array[Actor]`（单 Out 直接返回） |
| 调试 | `get_debug_string_from_gameplay_tag_container(tag_container)` | `FString GetDebugStringFromGameplayTagContainer(const FGameplayTagContainer&)` | `str` |
| 调试 | `get_debug_string_from_gameplay_tag(gameplay_tag)` | `FString GetDebugStringFromGameplayTag(FGameplayTag)` | `str` |

## 快速示例

```python
import unreal

lib = unreal.BlueprintGameplayTagLibrary

# 构造容器并在 Python 侧挂标签
container = unreal.GameplayTagContainer()
container.add_tag(unreal.GameplayTag.request_gameplay_tag("Gameplay.Cooking"))
container.add_tag(unreal.GameplayTag.request_gameplay_tag("Combat.Melee"))

# 匹配判定
parent = unreal.GameplayTag.request_gameplay_tag("Gameplay")
print(lib.matches_tag(unreal.GameplayTag.request_gameplay_tag("Gameplay.Cooking"), parent, b_exact_match=False))  # True
print(lib.is_gameplay_tag_valid(parent))  # True
print(lib.get_num_gameplay_tags_in_container(container))  # 2
print(lib.has_tag(container, parent, b_exact_match=False))  # True

# 编辑容器（ref 参数按返回接收）
updated = lib.add_gameplay_tag(container, unreal.GameplayTag.request_gameplay_tag("Status.Burning"))
removed_ok, after = lib.remove_gameplay_tag(updated, unreal.GameplayTag.request_gameplay_tag("Status.Burning"))

# TagQuery 判定
query = lib.make_gameplay_tag_query_match_any_tags(container)
print(lib.does_container_match_tag_query(container, query))  # True

# 按 Tag Query 检索场景 Actor（需要世界上下文对象）
actors = lib.get_all_actors_of_class_matching_tag_query(world, unreal.Actor, query)
print("matched actors:", len(actors))
```

## 注意事项

- 容器类是值类型：`add/remove` 的 `UPARAM(ref)` 参数按 Out 约定从返回值接收，不要忽略返回结果。
- `b_exact_match=True` 要求完全一致的显式标签；`False` 时父级标签参与匹配（`Gameplay.Cooking` 匹配 `Gameplay` 与自身）。
- 接口族方法接受实现了 `GameplayTagAssetInterface` 的对象（Actor、AbilitySystemComponent 等），`DefaultToSelf` 自动绑定仅作用于 Blueprint 图表，Python 侧需显式传参。
- 缺 Tag 字符串/容器/查询等必要输入时返回 `BLOCKED_INPUT`；无可用 Python/Editor 环境时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。