# UPaperZDActorEditorSubsystem API 参考（UE 5.6）

本页列出 `UPaperZDActorEditorSubsystem` 的完整 Python 方法映射表，按功能分组。

## Actor 选择与管理（Actor Selection & Management）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_selected_actors()` | `TArray<AActor*> GetSelectedActors()` | `Array[Actor]` |
| `is_actor_selected(actor)` | `bool IsActorSelected(AActor*)` | `bool` |
| `select_actors(actors, b_deselect_others)` | `void SelectActors(const TArray<AActor*>&, bool)` | `None` |
| `deselect_all_actors()` | `void DeselectAllActors()` | `None` |

## 图层管理（Layer Management）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_layer_count(paper_zd_comp)` | `int GetLayerCount(UPaperZDActorComponent*)` | `int` |
| `get_layer_name(paper_zd_comp, layer_index)` | `FString GetLayerName(UPaperZDActorComponent*, int)` | `str` |
| `set_layer_name(paper_zd_comp, layer_index, name)` | `bool SetLayerName(UPaperZDActorComponent*, int, const FString&)` | `bool` |
| `add_layer(paper_zd_comp, layer_name)` | `int AddLayer(UPaperZDActorComponent*, const FString&)` | `int` |
| `remove_layer(paper_zd_comp, layer_index)` | `bool RemoveLayer(UPaperZDActorComponent*, int)` | `bool` |
| `move_layer(paper_zd_comp, from_index, to_index)` | `bool MoveLayer(UPaperZDActorComponent*, int, int)` | `bool` |
| `get_all_layers(paper_zd_comp)` | `TArray<FString> GetAllLayers(UPaperZDActorComponent*)` | `Array[str]` |

## 关键帧操作（Keyframe Operations）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_key_count(paper_zd_comp, layer_index, property_name)` | `int GetKeyCount(UPaperZDActorComponent*, int, const FString&)` | `int` |
| `get_key_time(paper_zd_comp, layer_index, property_name, key_index)` | `float GetKeyTime(UPaperZDActorComponent*, int, const FString&, int)` | `float` |
| `get_key_value(paper_zd_comp, layer_index, property_name, key_index)` | `FString GetKeyValue(UPaperZDActorComponent*, int, const FString&, int)` | `str` |
| `add_key(paper_zd_comp, layer_index, property_name, time, value)` | `bool AddKey(UPaperZDActorComponent*, int, const FString&, float, const FString&)` | `bool` |
| `remove_key(paper_zd_comp, layer_index, property_name, key_index)` | `bool RemoveKey(UPaperZDActorComponent*, int, const FString&, int)` | `bool` |
| `set_key_time(paper_zd_comp, layer_index, property_name, key_index, time)` | `bool SetKeyTime(UPaperZDActorComponent*, int, const FString&, int, float)` | `bool` |
| `set_key_value(paper_zd_comp, layer_index, property_name, key_index, value)` | `bool SetKeyValue(UPaperZDActorComponent*, int, const FString&, int, const FString&)` | `bool` |
| `get_all_keys(paper_zd_comp, layer_index, property_name)` | `TArray<float> GetAllKeys(UPaperZDActorComponent*, int, const FString&)` | `Array[float]` |

## 序列化与导入/导出（Serialization & Import/Export）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `serialize_to_json(paper_zd_comp)` | `FString SerializeToJSON(UPaperZDActorComponent*)` | `str` |
| `deserialize_from_json(paper_zd_comp, json_string)` | `bool DeserializeFromJSON(UPaperZDActorComponent*, const FString&)` | `bool` |
| `save_to_file(paper_zd_comp, file_path)` | `bool SaveToFile(UPaperZDActorComponent*, const FString&)` | `bool` |
| `load_from_file(paper_zd_comp, file_path)` | `bool LoadFromFile(UPaperZDActorComponent*, const FString&)` | `bool` |

## 辅助（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_paper_zd_actor_components()` | `TArray<UPaperZDActorComponent*> GetPaperZDActorComponents()` | `Array[PaperZDActorComponent]` |
| `get_actor_from_paper_zd_comp(paper_zd_comp)` | `AActor* GetActorFromPaperZDComp(UPaperZDActorComponent*)` | `Actor` |
| `is_valid_paper_zd_comp(paper_zd_comp)` | `bool IsValidPaperZDComp(UPaperZDActorComponent*)` | `bool` |
| `get_all_properties(paper_zd_comp, layer_index)` | `TArray<FString> GetAllProperties(UPaperZDActorComponent*, int)` | `Array[str]` |
| `get_property_default_value(paper_zd_comp, property_name)` | `FString GetPropertyDefaultValue(UPaperZDActorComponent*, const FString&)` | `str` |
