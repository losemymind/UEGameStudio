---
name: paper-zd-actor-editor-subsystem
description: UPaperZDActorEditorSubsystem（UE 5.6）Paper 2D 动画 Actor 编辑器子系统 - 2D 动画蓝图编辑、图层管理、关键帧操作、序列化；在 Agent 需要通过 unreal Python 对 Paper ZD 动画资产进行编辑时使用
tags: [ue5.6, paper-zd, 2d-animation, python, subsystem]
---

# PaperZDActorEditorSubsystem - Paper 2D 动画编辑器子系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UPaperZDActorEditorSubsystem`（`UEditorSubsystem` 派生）通过 Python 可调用的子系统方法。方法名与签名依据引擎头文件中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UPaperZDActorEditorSubsystem` 在 Python 中以子系统形式访问：

```python
import unreal

# 获取子系统实例
paper_zd_subsystem = unreal.get_editor_subsystem(unreal.PaperZDActorEditorSubsystem)

# 示例：获取当前选中的 Paper ZD Actor
selected_actors = paper_zd_subsystem.get_selected_actors()
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.PaperZDActorEditorSubsystem)` 核对）。
- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用会失败。
- Paper ZD 为 UE 内置 2D 动画系统；需项目启用 Paper 2D 插件。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **Actor 选择与管理** | | | |
| 选中 | `get_selected_actors()` | `TArray<AActor*> GetSelectedActors()` | `Array[Actor]` |
| 选中 | `is_actor_selected(actor)` | `bool IsActorSelected(AActor*)` | `bool` |
| 选中 | `select_actors(actors, b_deselect_others)` | `void SelectActors(const TArray<AActor*>&, bool)` | `None` |
| 选中 | `deselect_all_actors()` | `void DeselectAllActors()` | `None` |
| **图层管理** | | | |
| 图层 | `get_layer_count(paper_zd_comp)` | `int GetLayerCount(UPaperZDActorComponent*)` | `int` |
| 图层 | `get_layer_name(paper_zd_comp, layer_index)` | `FString GetLayerName(UPaperZDActorComponent*, int)` | `str` |
| 图层 | `set_layer_name(paper_zd_comp, layer_index, name)` | `bool SetLayerName(UPaperZDActorComponent*, int, const FString&)` | `bool` |
| 图层 | `add_layer(paper_zd_comp, layer_name)` | `int AddLayer(UPaperZDActorComponent*, const FString&)` | `int` |
| 图层 | `remove_layer(paper_zd_comp, layer_index)` | `bool RemoveLayer(UPaperZDActorComponent*, int)` | `bool` |
| 图层 | `move_layer(paper_zd_comp, from_index, to_index)` | `bool MoveLayer(UPaperZDActorComponent*, int, int)` | `bool` |
| 图层 | `get_all_layers(paper_zd_comp)` | `TArray<FString> GetAllLayers(UPaperZDActorComponent*)` | `Array[str]` |
| **关键帧操作** | | | |
| 关键帧 | `get_key_count(paper_zd_comp, layer_index, property_name)` | `int GetKeyCount(UPaperZDActorComponent*, int, const FString&)` | `int` |
| 关键帧 | `get_key_time(paper_zd_comp, layer_index, property_name, key_index)` | `float GetKeyTime(UPaperZDActorComponent*, int, const FString&, int)` | `float` |
| 关键帧 | `get_key_value(paper_zd_comp, layer_index, property_name, key_index)` | `FString GetKeyValue(UPaperZDActorComponent*, int, const FString&, int)` | `str` |
| 关键帧 | `add_key(paper_zd_comp, layer_index, property_name, time, value)` | `bool AddKey(UPaperZDActorComponent*, int, const FString&, float, const FString&)` | `bool` |
| 关键帧 | `remove_key(paper_zd_comp, layer_index, property_name, key_index)` | `bool RemoveKey(UPaperZDActorComponent*, int, const FString&, int)` | `bool` |
| 关键帧 | `set_key_time(paper_zd_comp, layer_index, property_name, key_index, time)` | `bool SetKeyTime(UPaperZDActorComponent*, int, const FString&, int, float)` | `bool` |
| 关键帧 | `set_key_value(paper_zd_comp, layer_index, property_name, key_index, value)` | `bool SetKeyValue(UPaperZDActorComponent*, int, const FString&, int, const FString&)` | `bool` |
| 关键帧 | `get_all_keys(paper_zd_comp, layer_index, property_name)` | `TArray<float> GetAllKeys(UPaperZDActorComponent*, int, const FString&)` | `Array[float]` |
| **序列化与导入/导出** | | | |
| 序列化 | `serialize_to_json(paper_zd_comp)` | `FString SerializeToJSON(UPaperZDActorComponent*)` | `str` |
| 序列化 | `deserialize_from_json(paper_zd_comp, json_string)` | `bool DeserializeFromJSON(UPaperZDActorComponent*, const FString&)` | `bool` |
| 序列化 | `save_to_file(paper_zd_comp, file_path)` | `bool SaveToFile(UPaperZDActorComponent*, const FString&)` | `bool` |
| 序列化 | `load_from_file(paper_zd_comp, file_path)` | `bool LoadFromFile(UPaperZDActorComponent*, const FString&)` | `bool` |
| **辅助** | | | |
| 辅助 | `get_paper_zd_actor_components()` | `TArray<UPaperZDActorComponent*> GetPaperZDActorComponents()` | `Array[PaperZDActorComponent]` |
| 辅助 | `get_actor_from_paper_zd_comp(paper_zd_comp)` | `AActor* GetActorFromPaperZDComp(UPaperZDActorComponent*)` | `Actor` |
| 辅助 | `is_valid_paper_zd_comp(paper_zd_comp)` | `bool IsValidPaperZDComp(UPaperZDActorComponent*)` | `bool` |
| 辅助 | `get_all_properties(paper_zd_comp, layer_index)` | `TArray<FString> GetAllProperties(UPaperZDActorComponent*, int)` | `Array[str]` |
| 辅助 | `get_property_default_value(paper_zd_comp, property_name)` | `FString GetPropertyDefaultValue(UPaperZDActorComponent*, const FString&)` | `str` |

## 快速示例

```python
import unreal

def edit_paperzd_animation():
    paper_zd_subsystem = unreal.get_editor_subsystem(unreal.PaperZDActorEditorSubsystem)
    
    # 获取当前选中的 Paper ZD Actor
    selected = paper_zd_subsystem.get_selected_actors()
    if not selected:
        print("No Paper ZD Actor selected")
        return
    
    # 获取组件
    actor = selected[0]
    components = actor.GetComponentsByClass(unreal.PaperZDActorComponent)
    if not components:
        print("No PaperZDActorComponent found")
        return
    
    paper_zd_comp = components[0]
    
    # 图层管理
    layers = paper_zd_subsystem.get_all_layers(paper_zd_comp)
    print("layers:", layers)
    
    # 添加新图层
    new_layer_idx = paper_zd_subsystem.add_layer(paper_zd_comp, "NewLayer")
    print("new layer index:", new_layer_idx)
    
    # 关键帧操作
    key_count = paper_zd_subsystem.get_key_count(paper_zd_comp, 0, "Location.X")
    print("key count:", key_count)
    
    # 添加关键帧
    ok = paper_zd_subsystem.add_key(
        paper_zd_comp, 0, "Location.X", 0.0, "100.0"
    )
    print("add key:", ok)
    
    # 设置关键帧值
    ok = paper_zd_subsystem.set_key_value(
        paper_zd_comp, 0, "Location.X", 0, "200.0"
    )
    print("set key value:", ok)
    
    # 序列化
    json_str = paper_zd_subsystem.serialize_to_json(paper_zd_comp)
    print("json size:", len(json_str))
    
    # 保存到文件
    ok = paper_zd_subsystem.save_to_file(
        paper_zd_comp, "C:/path/to/animation.json"
    )
    print("save:", ok)

if __name__ == "__main__":
    edit_paperzd_animation()
```

## 注意事项

- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用返回 `BLOCKED_TOOLING`。
- `GetSelectedActors` / `SelectActors` 仅影响编辑器当前选中状态；不影响动画数据本身。
- `AddLayer` / `RemoveLayer` / `MoveLayer` 修改图层结构；图层索引从 0 开始。
- `AddKey` / `RemoveKey` / `SetKeyValue` 操作的是字符串化的关键帧值；值格式依赖于属性类型（如 "100.0" 表示 float，"true" 表示 bool）。
- `SerializeToJSON` / `DeserializeFromJSON` 用于序列化整个动画状态；可用于备份或跨项目传输。
- `SaveToFile` / `LoadFromFile` 直接文件持久化；输出路径需要可写权限。
- 缺 Paper ZD Actor、组件、图层索引、关键帧索引等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
