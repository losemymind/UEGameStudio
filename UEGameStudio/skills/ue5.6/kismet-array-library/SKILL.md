---
name: kismet-array-library
description: UKismetArrayLibrary（UE 5.6）BP 数组工具库 Python 可调用子集 - 按类过滤 Actor 数组与字符串/名称/字节/int/int64/double 数组排序；在 Agent 需要通过 unreal Python 调用数组工具库时使用
tags: [ue5.6, kismet, array, python, blueprint]
---

# KismetArrayLibrary - Array Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetArrayLibrary` 中可由 Python 调用的静态成员，签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetArrayLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。本 skill 只记录可由 Python 调用的成员。

## 入口说明

该库全部为 static 方法，以类方法形式调用，无需实例：

```python
import unreal

karray = unreal.KismetArrayLibrary
```

- 类对象直接可用，无需获取子系统实例。
- 引擎 Python 上下文可用即可调用；不依赖编辑器子系统或 `UWorld`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 过滤 | `filter_array(target_array, filter_class)` | `void FilterArray(const TArray<AActor*>&, TSubclassOf<AActor>, TArray<AActor*>&)` | `Array[Actor]` |
| 排序 | `sort_string_array(target_array, b_stable_sort=False, sort_order=ASCENDING)` | `void SortStringArray(Ref TArray<FString>&, bool, EArraySortOrder)` | `None` |
| 排序 | `sort_name_array(target_array, b_stable_sort=False, b_lexical_sort=True, sort_order=ASCENDING)` | `void SortNameArray(Ref TArray<FName>&, bool, bool, EArraySortOrder)` | `None` |
| 排序 | `sort_byte_array(target_array, b_stable_sort=False, sort_order=ASCENDING)` | `void SortByteArray(Ref TArray<uint8>&, bool, EArraySortOrder)` | `None` |
| 排序 | `sort_int_array(target_array, b_stable_sort=False, sort_order=ASCENDING)` | `void SortIntArray(Ref TArray<int32>&, bool, EArraySortOrder)` | `None` |
| 排序 | `sort_int64_array(target_array, b_stable_sort=False, sort_order=ASCENDING)` | `void SortInt64Array(Ref TArray<int64>&, bool, EArraySortOrder)` | `None` |
| 排序 | `sort_float_array(target_array, b_stable_sort=False, sort_order=ASCENDING)` | `void SortFloatArray(Ref TArray<double>&, bool, EArraySortOrder)` | `None` |

- `sort_order` 枚举 `unreal.EArraySortOrder`：`ASCENDING` / `DESCENDING`。
- `filter_class` 使用 `unreal.load_class(...)` 加载的类对象。

## 快速示例

```python
import unreal

karray = unreal.KismetArrayLibrary

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)

light_class = unreal.load_class("/Script/Engine.PointLight")
lights = karray.filter_array(actors, light_class)
print("lights in level:", len(lights))

scores = [30, 10, 20]
karray.sort_int_array(
    scores,
    sort_order=unreal.EArraySortOrder.DESCENDING,
)
print("scores desc:", scores)

labels = [a.get_actor_label() for a in lights]
karray.sort_string_array(labels)
print("labels sorted:", labels)
```

## 注意事项

- `filter_array` 不修改原数组，返回过滤后的新数组；结果类型随 `FilterClass` 动态指定。
- 排序函数就地修改传入数组（Ref 参数），返回 `None`，结果从原变量读取。
- `sort_float_array` 作用于 `TArray<double>`（UE double，对应 Python float）。
- 缺类路径、待排序数组等必要输入时返回 `BLOCKED_INPUT`；引擎 Python 上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。