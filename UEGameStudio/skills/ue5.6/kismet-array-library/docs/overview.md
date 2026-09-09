---
title: KismetArrayLibrary - 数组工具库
category: UE5.6 Kismet Libraries
---

# KismetArrayLibrary 概述

## 功能概述

`UKismetArrayLibrary` 提供针对数组的实用工具函数，包括按类过滤 Actor 数组、以及多种基本类型数组（字符串/名称/字节/int/int64/double）的排序功能。它是 Blueprint 与 Python 环境中数组操作的核心工具库。

## 核心用途与场景

- **Actor 过滤**：从场景中所有 Actor 过滤出特定类别的 Actor（如所有点光源、可交互对象）
- **数据排序**：对配置列表、分数榜、标签集合等进行升序/降序排列
- **UI 列表准备**：准备排序后的列表供 UI 显示（如按名称排序的物品栏、按分数排序的排行榜）
- **批量操作预处理**：过滤出目标 Actor 后进行批量修改或查询

## 更多使用示例

### 复杂场景过滤

```python
import unreal

karray = unreal.KismetArrayLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

# 获取所有Actor
all_actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)

# 过滤出所有可破坏物
breakable_class = unreal.load_class("/Script/Engine.StaticMeshActor")
breakables = karray.filter_array(all_actors, breakable_class)

# 进一步过滤出带有特定标签的
for actor in breakables:
    if actor.has_tag("Important"):
        print(f"Important breakable found: {actor.get_actor_label()}")
```

### 排序与 UI 集成

```python
# 按名称排序所有关卡
levels = [level.get_name() for level in world.get_levels()]
karray.sort_string_array(levels, sort_order=unreal.EArraySortOrder.ASCENDING)

# 准备下拉列表数据
ui_options = [{"label": name, "value": name} for name in levels]
```

### 多字段排序

```python
# 先按类别过滤，再按名称排序
actors = unreal.GameplayStatics.get_all_actors_of_class(world, unreal.Actor)
light_class = unreal.load_class("/Script/Engine.PointLight")
lights = karray.filter_array(actors, light_class)

# 提取标签用于排序
labels = [actor.get_actor_label() for actor in lights]
karray.sort_string_array(labels)

# 显示排序后的标签
for label in labels:
    print(f"Light: {label}")
```

## 高级用法与最佳实践

### Actor 过滤策略

- **继承过滤**：`filter_array` 支持类的继承关系，子类 Actor 也会被包含
- **性能考虑**：过滤为 O(n) 操作，大规模场景建议先限定范围（如特定区域）
- **结果副本**：`filter_array` 返回新数组，不修改原始数据，保证源数组安全

### 排序最佳实践

- **稳定排序**：`b_stable_sort=True` 保持相同值元素的原始顺序，适合需要可重现排序的场景
- **方向控制**：`sort_order` 参数支持升序/降序，排行榜通常使用降序
- **类型匹配**：确保数组类型与排序方法匹配（`int` 用 `sort_int_array`，`float` 用 `sort_float_array`）

### 大数据集优化

- **分批处理**：超大数组可分批过滤和排序，减少单次操作的内存峰值
- **索引排序**：对于需要保持原始数据结构的场景，可对索引数组排序而非数据本身
- **懒加载**：UI 场景下，仅对当前视图可见的数据进行排序

## 常见问题与注意事项

### 阻塞与错误处理

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| 过滤结果为空 | 类路径错误或场景中无匹配 Actor | 检查 `load_class` 返回值与场景内容 |
| 排序无效 | 传入数组类型与方法不匹配 | 确保 `int32` 数组使用 `sort_int_array` |
| 没有排序结果返回 | `sort_*_array` 就地修改数组，返回 None | 排序后直接读取原变量，而非期待返回值 |

### 类型与安全

- **精确类型匹配**：每种排序方法针对特定类型，跨类型排序需转换
- **引用修改**：排序函数为 `Ref` 参数，直接修改原数组；如需保留原始顺序，先复制数组
- **空数组处理**：空数组调用排序方法不会报错，但无效果

### 最佳实践

- ✅ 排序前检查数组非空
- ✅ 使用 `b_stable_sort=True` 确保排序可重现
- ✅ 过滤前验证类路径有效性
- ✅ 为 UI 显示准备数据时，使用稳定的排序顺序
- ❌ 不要在循环中重复过滤相同数组
- ❌ 不要混用类型（如对 `int` 数组使用 `sort_string_array`）

## 总结

`KismetArrayLibrary` 是 UE 中数组操作的核心工具库，提供 Actor 过滤与多种基本类型排序功能。它在场景查询、数据准备与 UI 集成中广泛使用，适合需要快速过滤或排序 Actor 与基础类型数据的场景。使用时需注意类型匹配、引用修改语义与性能优化策略。
