# BlueprintGameplayTagLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/GameplayTags/Classes/BlueprintGameplayTagLibrary.h` 整理 `UBlueprintGameplayTagLibrary` 中带 `UFUNCTION(BlueprintPure / BlueprintCallable)` 标记、可由 Python 调用的静态成员。方法名由 C++ 函数名按反射约定转 snake_case（本头文件未声明 `ScriptMethod`）。每个成员给出 C++ 签名、Python 参数与返回约定及示例；完整示例即调用样板。

## 通用约定

```python
import unreal
lib = unreal.BlueprintGameplayTagLibrary
```

- Python 类名：`unreal.BlueprintGameplayTagLibrary`（UCLASS 名 `UBlueprintGameplayTagLibrary` 去 U 前缀）。
- 类型对应：`FGameplayTag` → `unreal.GameplayTag`；`FGameplayTagContainer` → `unreal.GameplayTagContainer`；`FGameplayTagQuery` → `unreal.GameplayTagQuery`。
- 构造 Tag / 容器：

```python
tag = unreal.GameplayTag.request_gameplay_tag("Gameplay.Cooking")
container = unreal.GameplayTagContainer()
container.add_tag(tag)
container.add_tag(unreal.GameplayTag.request_gameplay_tag("Combat.Melee"))
```

- Out/ByRef 返回约定：`void`+单 Out 直接返回；返回值+Out 按元组返回（返回值在首位）；无 Out 无返回值则 `None`。
- 标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。

## 标签匹配

### matches_tag

- C++ 签名：`bool MatchesTag(FGameplayTag TagOne, FGameplayTag TagTwo, bool bExactMatch)`（BlueprintPure）
- Python：`matches_tag(tag_one, tag_two, b_exact_match) -> bool`
- 说明：判断 `TagOne` 是否匹配 `TagTwo`；`b_exact_match=True` 要求显式相同，`False` 时父级标签参与匹配。
- 示例：

```python
combat = unreal.GameplayTag.request_gameplay_tag("Combat")
ok = lib.matches_tag(unreal.GameplayTag.request_gameplay_tag("Combat.Melee"), combat, b_exact_match=False)
```

### matches_any_tags

- C++ 签名：`bool MatchesAnyTags(FGameplayTag TagOne, const FGameplayTagContainer& OtherContainer, bool bExactMatch)`（BlueprintPure）
- Python：`matches_any_tags(tag_one, other_container, b_exact_match) -> bool`
- 说明：判断 `TagOne` 是否匹配容器中任一显式声明的标签。
- 示例：

```python
hits = lib.matches_any_tags(combat, container, b_exact_match=False)
```

### equal_equal_gameplay_tag

- C++ 签名：`bool EqualEqual_GameplayTag(FGameplayTag A, FGameplayTag B)`（BlueprintPure）
- Python：`equal_equal_gameplay_tag(a, b) -> bool`
- 说明：标签相等比较（A == B）。
- 示例：

```python
same = lib.equal_equal_gameplay_tag(tag_a, tag_b)
```

### not_equal_gameplay_tag

- C++ 签名：`bool NotEqual_GameplayTag(FGameplayTag A, FGameplayTag B)`（BlueprintPure）
- Python：`not_equal_gameplay_tag(a, b) -> bool`
- 说明：标签不等比较（A != B）。
- 示例：

```python
if lib.not_equal_gameplay_tag(current_tag, target_tag):
    print("tag changed")
```

## 标签验证与命名

### is_gameplay_tag_valid

- C++ 签名：`bool IsGameplayTagValid(FGameplayTag GameplayTag)`（BlueprintPure）
- Python：`is_gameplay_tag_valid(gameplay_tag) -> bool`
- 说明：判断传入标签是否为有效（非空）标签。
- 示例：

```python
if not lib.is_gameplay_tag_valid(unreal.GameplayTag.request_gameplay_tag("Invalid.Tag")):
    print("BLOCKED_INPUT: tag string invalid")
```

### get_tag_name

- C++ 签名：`FName GetTagName(const FGameplayTag& GameplayTag)`（BlueprintPure）
- Python：`get_tag_name(gameplay_tag) -> Name`
- 说明：返回标签的完整 FName（含路径层级，如 `Gameplay.Cooking`）。
- 示例：

```python
name = lib.get_tag_name(tag)
print(name)
```

## 字面量与容器构造

### make_literal_gameplay_tag

- C++ 签名：`FGameplayTag MakeLiteralGameplayTag(FGameplayTag Value)`（BlueprintPure）
- Python：`make_literal_gameplay_tag(value) -> GameplayTag`
- 说明：构造 GameplayTag 字面量。
- 示例：

```python
tag = lib.make_literal_gameplay_tag(unreal.GameplayTag.request_gameplay_tag("Gameplay.Cooking"))
```

### make_literal_gameplay_tag_container

- C++ 签名：`FGameplayTagContainer MakeLiteralGameplayTagContainer(FGameplayTagContainer Value)`（BlueprintPure）
- Python：`make_literal_gameplay_tag_container(value) -> GameplayTagContainer`
- 说明：构造容器字面量。
- 示例：

```python
c = lib.make_literal_gameplay_tag_container(container)
```

### make_gameplay_tag_container_from_array

- C++ 签名：`FGameplayTagContainer MakeGameplayTagContainerFromArray(const TArray<FGameplayTag>& GameplayTags)`（BlueprintPure）
- Python：`make_gameplay_tag_container_from_array(gameplay_tags) -> GameplayTagContainer`
- 说明：由 Tag 数组构造容器。
- 示例：

```python
container = lib.make_gameplay_tag_container_from_array([
    unreal.GameplayTag.request_gameplay_tag("Combat.Melee"),
    unreal.GameplayTag.request_gameplay_tag("Movement"),
])
```

### make_gameplay_tag_container_from_tag

- C++ 签名：`FGameplayTagContainer MakeGameplayTagContainerFromTag(FGameplayTag SingleTag)`（BlueprintPure）
- Python：`make_gameplay_tag_container_from_tag(single_tag) -> GameplayTagContainer`
- 说明：由单个标签构造只含该标签的容器。
- 示例：

```python
single = lib.make_gameplay_tag_container_from_tag(tag)
```

### break_gameplay_tag_container

- C++ 签名：`void BreakGameplayTagContainer(const FGameplayTagContainer& GameplayTagContainer, TArray<FGameplayTag>& GameplayTags)`（BlueprintPure）
- Python：`break_gameplay_tag_container(gameplay_tag_container) -> Array[GameplayTag]`
- 说明：将容器展开为显式标签数组（单 Out，直接返回）。
- 示例：

```python
tags = lib.break_gameplay_tag_container(container)
print([lib.get_tag_name(t) for t in tags])
```

## 容器查询

### get_num_gameplay_tags_in_container

- C++ 签名：`int32 GetNumGameplayTagsInContainer(const FGameplayTagContainer& TagContainer)`（BlueprintPure）
- Python：`get_num_gameplay_tags_in_container(tag_container) -> int`
- 说明：返回容器中的标签数量。
- 示例：

```python
n = lib.get_num_gameplay_tags_in_container(container)
```

### has_tag

- C++ 签名：`bool HasTag(const FGameplayTagContainer& TagContainer, FGameplayTag Tag, bool bExactMatch)`（BlueprintPure，Keywords=DoesContainerHaveTag）
- Python：`has_tag(tag_container, tag, b_exact_match) -> bool`
- 说明：判断容器是否包含指定标签；`b_exact_match=False` 时父级标签计入。
- 示例：

```python
has = lib.has_tag(container, combat, b_exact_match=False)
```

### has_any_tags

- C++ 签名：`bool HasAnyTags(const FGameplayTagContainer& TagContainer, const FGameplayTagContainer& OtherContainer, bool bExactMatch)`（BlueprintPure）
- Python：`has_any_tags(tag_container, other_container, b_exact_match) -> bool`
- 说明：判断容器是否与另一容器存在任一匹配标签。
- 示例：

```python
any_hit = lib.has_any_tags(container, query_tags, b_exact_match=False)
```

### has_all_tags

- C++ 签名：`bool HasAllTags(const FGameplayTagContainer& TagContainer, const FGameplayTagContainer& OtherContainer, bool bExactMatch)`（BlueprintPure）
- Python：`has_all_tags(tag_container, other_container, b_exact_match) -> bool`
- 说明：判断容器是否包含另一容器的全部标签；`OtherContainer` 为空时判定成功。
- 示例：

```python
all_hit = lib.has_all_tags(container, required_tags, b_exact_match=False)
```

### filter

- C++ 签名：`FGameplayTagContainer Filter(const FGameplayTagContainer& TagContainer, const FGameplayTagContainer& OtherContainer, bool bExactMatch)`（BlueprintPure）
- Python：`filter(tag_container, other_container, b_exact_match) -> GameplayTagContainer`
- 说明：返回与 `OtherContainer` 任一标签匹配的子集容器。
- 示例：

```python
subset = lib.filter(container, combat_tags, b_exact_match=False)
```

## 容器编辑

### add_gameplay_tag

- C++ 签名：`void AddGameplayTag(UPARAM(ref) FGameplayTagContainer& TagContainer, FGameplayTag Tag)`（BlueprintCallable）
- Python：`add_gameplay_tag(tag_container, tag) -> GameplayTagContainer`
- 说明：向容器追加单个标签；ref 参数按 Out 约定从返回值接收（单 Out 直接返回）。
- 示例：

```python
container = lib.add_gameplay_tag(container, unreal.GameplayTag.request_gameplay_tag("Status.Burning"))
```

### remove_gameplay_tag

- C++ 签名：`bool RemoveGameplayTag(UPARAM(ref) FGameplayTagContainer& TagContainer, FGameplayTag Tag)`（BlueprintCallable）
- Python：`remove_gameplay_tag(tag_container, tag) -> (bool, GameplayTagContainer)`
- 说明：从容器移除单个标签并返回是否找到；返回值与 ref 容器按元组返回（返回值在首位）。
- 示例：

```python
found, container = lib.remove_gameplay_tag(container, some_tag)
if not found:
    print("tag not present to remove")
```

### append_gameplay_tag_containers

- C++ 签名：`void AppendGameplayTagContainers(UPARAM(ref) FGameplayTagContainer& InOutTagContainer, const FGameplayTagContainer& InTagContainer)`（BlueprintCallable）
- Python：`append_gameplay_tag_containers(in_out_tag_container, in_tag_container) -> GameplayTagContainer`
- 说明：将 `InTagContainer` 全部标签追加到 `InOutTagContainer`；ref 按 Out 从返回值接收。
- 示例：

```python
container = lib.append_gameplay_tag_containers(container, extra_tags)
```

## 容器比较

### equal_equal_gameplay_tag_container

- C++ 签名：`bool EqualEqual_GameplayTagContainer(const FGameplayTagContainer& A, const FGameplayTagContainer& B)`（BlueprintPure）
- Python：`equal_equal_gameplay_tag_container(a, b) -> bool`
- 说明：容器相等比较（A == B）。
- 示例：

```python
same = lib.equal_equal_gameplay_tag_container(container, other_container)
```

### not_equal_gameplay_tag_container

- C++ 签名：`bool NotEqual_GameplayTagContainer(const FGameplayTagContainer& A, const FGameplayTagContainer& B)`（BlueprintPure）
- Python：`not_equal_gameplay_tag_container(a, b) -> bool`
- 说明：容器不等比较（A != B）。

### not_equal_tag_tag

- C++ 签名：`bool NotEqual_TagTag(FGameplayTag A, FString B)`（BlueprintPure，PinOptions 类内部辅助）
- Python：`not_equal_tag_tag(a, b) -> bool`
- 说明：标签名与字符串不等比较（为 Blueprint 引脚选项提供）。
- 示例：

```python
if lib.not_equal_tag_tag(tag, "Combat"):
    print("tag name differs from string")
```

### not_equal_tag_container_tag_container

- C++ 签名：`bool NotEqual_TagContainerTagContainer(FGameplayTagContainer A, FString B)`（BlueprintPure，PinOptions 类内部辅助）
- Python：`not_equal_tag_container_tag_container(a, b) -> bool`
- 说明：容器名与字符串不等比较（为 Blueprint 引脚选项提供）。

## TagQuery

### is_tag_query_empty

- C++ 签名：`bool IsTagQueryEmpty(const FGameplayTagQuery& TagQuery)`（BlueprintPure）
- Python：`is_tag_query_empty(tag_query) -> bool`
- 说明：判断 TagQuery 是否为空查询。
- 示例：

```python
if lib.is_tag_query_empty(query):
    print("BLOCKED_INPUT: tag query empty")
```

### does_container_match_tag_query

- C++ 签名：`bool DoesContainerMatchTagQuery(const FGameplayTagContainer& TagContainer, const FGameplayTagQuery& TagQuery)`（BlueprintPure）
- Python：`does_container_match_tag_query(tag_container, tag_query) -> bool`
- 说明：判断容器是否满足 TagQuery 表达式。
- 示例：

```python
matched = lib.does_container_match_tag_query(container, query)
```

### make_gameplay_tag_query

- C++ 签名：`FGameplayTagQuery MakeGameplayTagQuery(FGameplayTagQuery TagQuery)`（BlueprintPure）
- Python：`make_gameplay_tag_query(tag_query) -> GameplayTagQuery`
- 说明：构造 TagQuery 字面量。
- 示例：

```python
query = lib.make_gameplay_tag_query(unreal.GameplayTagQuery())
```

### make_gameplay_tag_query_match_any_tags

- C++ 签名：`FGameplayTagQuery MakeGameplayTagQuery_MatchAnyTags(const FGameplayTagContainer& InTags)`（BlueprintPure）
- Python：`make_gameplay_tag_query_match_any_tags(in_tags) -> GameplayTagQuery`
- 说明：构造预置 AnyTagsMatch 表达式的 TagQuery。
- 示例：

```python
query = lib.make_gameplay_tag_query_match_any_tags(container)
```

### make_gameplay_tag_query_match_all_tags

- C++ 签名：`FGameplayTagQuery MakeGameplayTagQuery_MatchAllTags(const FGameplayTagContainer& InTags)`（BlueprintPure）
- Python：`make_gameplay_tag_query_match_all_tags(in_tags) -> GameplayTagQuery`
- 说明：构造预置 AllTagsMatch 表达式的 TagQuery。

### make_gameplay_tag_query_match_no_tags

- C++ 签名：`FGameplayTagQuery MakeGameplayTagQuery_MatchNoTags(const FGameplayTagContainer& InTags)`（BlueprintPure）
- Python：`make_gameplay_tag_query_match_no_tags(in_tags) -> GameplayTagQuery`
- 说明：构造预置 NoTagsMatch 表达式的 TagQuery。

## GameplayTagAssetInterface 接口查询

### has_all_matching_gameplay_tags

- C++ 签名：`bool HasAllMatchingGameplayTags(TScriptInterface<IGameplayTagAssetInterface> TagContainerInterface, const FGameplayTagContainer& OtherContainer)`（BlueprintPure）
- Python：`has_all_matching_gameplay_tags(tag_container_interface, other_container) -> bool`
- 说明：判断接口对象（Actor/ASC 等）的全部标签是否包含 `OtherContainer` 全部标签（含父级展开）。
- 示例：

```python
if lib.has_all_matching_gameplay_tags(actor, container, ):
    print("actor has all tags")
```

### does_tag_asset_interface_have_tag

- C++ 签名：`bool DoesTagAssetInterfaceHaveTag(TScriptInterface<IGameplayTagAssetInterface> TagContainerInterface, FGameplayTag Tag)`（BlueprintPure）
- Python：`does_tag_asset_interface_have_tag(tag_container_interface, tag) -> bool`
- 说明：判断接口对象是否拥有指定标签。
- 示例：

```python
has = lib.does_tag_asset_interface_have_tag(actor, combat)
```

### get_owned_gameplay_tags

- C++ 签名：`FGameplayTagContainer GetOwnedGameplayTags(TScriptInterface<IGameplayTagAssetInterface> TagContainerInterface)`（BlueprintPure）
- Python：`get_owned_gameplay_tags(tag_container_interface) -> GameplayTagContainer`
- 说明：返回接口对象当前拥有的全部标签容器。
- 示例：

```python
owned = lib.get_owned_gameplay_tags(actor)
```

### conv_object_to_gameplay_tag_asset_interface

- C++ 签名：`TScriptInterface<IGameplayTagAssetInterface> Conv_ObjectToGameplayTagAssetInterface(UObject* InObject)`（BlueprintPure，BlueprintAutocast）
- Python：`conv_object_to_gameplay_tag_asset_interface(in_object) -> 对象`
- 说明：将对象转换为 GameplayTagAssetInterface 后传入接口族方法。
- 示例：

```python
as_interface = lib.conv_object_to_gameplay_tag_asset_interface(actor)
```

## 世界查询

### get_all_actors_of_class_matching_tag_query

- C++ 签名：`void GetAllActorsOfClassMatchingTagQuery(UObject* WorldContextObject, TSubclassOf<AActor> ActorClass, const FGameplayTagQuery& GameplayTagQuery, TArray<AActor*>& OutActors)`（BlueprintCallable，WorldContext=WorldContextObject，单 Out）
- Python：`get_all_actors_of_class_matching_tag_query(world_context_object, actor_class, gameplay_tag_query) -> Array[Actor]`
- 说明：按 TagQuery 检索指定类（或子类）Actor；`WorldContextObject` 提供世界上下文。
- 示例：

```python
world_obj = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
actors = lib.get_all_actors_of_class_matching_tag_query(world_obj, unreal.Actor, query)
print("matched:", len(actors))
```

## 调试

### get_debug_string_from_gameplay_tag_container

- C++ 签名：`FString GetDebugStringFromGameplayTagContainer(const FGameplayTagContainer& TagContainer)`（BlueprintPure）
- Python：`get_debug_string_from_gameplay_tag_container(tag_container) -> str`
- 说明：返回容器全部标签的调试字符串表示。
- 示例：

```python
print(lib.get_debug_string_from_gameplay_tag_container(container))
```

### get_debug_string_from_gameplay_tag

- C++ 签名：`FString GetDebugStringFromGameplayTag(FGameplayTag GameplayTag)`（BlueprintPure）
- Python：`get_debug_string_from_gameplay_tag(gameplay_tag) -> str`
- 说明：返回单个标签的调试字符串表示。
- 示例：

```python
print(lib.get_debug_string_from_gameplay_tag(tag))
```

## 完整示例：按容器查询与编辑

```python
import unreal

lib = unreal.BlueprintGameplayTagLibrary

required = lib.make_gameplay_tag_container_from_array([
    unreal.GameplayTag.request_gameplay_tag("Gameplay.Cooking"),
    unreal.GameplayTag.request_gameplay_tag("Combat.Melee"),
])
owned = lib.get_owned_gameplay_tags(actor)

if not lib.has_all_tags(owned, required, b_exact_match=False):
    print({"status": "BLOCKED_INPUT", "reason": "actor 缺少必要 GameplayTag"})
    return

extra = lib.make_gameplay_tag_container_from_tag(unreal.GameplayTag.request_gameplay_tag("Status.Burning"))
owned = lib.append_gameplay_tag_containers(owned, extra)
found, owned = lib.remove_gameplay_tag(owned, unreal.GameplayTag.request_gameplay_tag("Status.Burning"))

query = lib.make_gameplay_tag_query_match_all_tags(required)
matched_actors = lib.get_all_actors_of_class_matching_tag_query(
    world,
    unreal.Actor,
    query,
)
print({"status": "OK", "matched": len(matched_actors), "owned": str(owned)})
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入——Tag 字符串无效、容器/查询未构造、接口对象为 `None`、缺少世界上下文对象等。
- `BLOCKED_TOOLING`：无可用 Python/Editor 环境，无法执行；不得声称已执行。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。