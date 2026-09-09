# Interchange 插件 - 完整 API 参考（UE 5.6）

**插件：** Interchange  
**要求：** 需在UE编辑器中启用 Interchange 插件  
**运行时：** 仅编辑器 Python（`WITH_EDITOR`）  
**未实测声明：** 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言

---

## 一、管道创建（Pipeline Creation）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `create_import_pipeline()` | `UInterchangeBaseImporterPipeline* CreateImportPipeline()`（WITH_EDITOR） | `Pipeline \| None` |
| `create_export_pipeline()` | `UInterchangeBaseExporterPipeline* CreateExportPipeline()`（WITH_EDITOR） | `Pipeline \| None` |
| `create_base_pipeline(pipeline_type)` | `UInterchangeBasePipeline* CreateBasePipeline(EInterchangePipelineType::Type)`（WITH_EDITOR） | `Pipeline \| None` |

---

## 二、管道设置（Pipeline Configuration）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `set_pipeline_source_file(pipeline, file_path)` | `void SetPipelineSourceFile(UInterchangeBasePipeline*, const FString&)`（WITH_EDITOR） | `None` |
| `set_pipeline_source_data(pipeline, data, size)` | `void SetPipelineSourceData(UInterchangeBasePipeline*, const uint8*, int32)`（WITH_EDITOR） | `None` |
| `set_pipeline_root_nodes(pipeline, nodes)` | `void SetPipelineRootNodes(UInterchangeBasePipeline*, const TArray<FString>&)`（WITH_EDITOR） | `None` |
| `set_pipeline_option(pipeline, option_name, value)` | `void SetPipelineOption(UInterchangeBasePipeline*, const FString&, const FString&)`（WITH_EDITOR） | `None` |
| `set_pipeline_option_int(pipeline, option_name, value)` | `void SetPipelineOptionInt(UInterchangeBasePipeline*, const FString&, int32)`（WITH_EDITOR） | `None` |
| `set_pipeline_option_float(pipeline, option_name, value)` | `void SetPipelineOptionFloat(UInterchangeBasePipeline*, const FString&, float)`（WITH_EDITOR） | `None` |
| `set_pipeline_option_bool(pipeline, option_name, value)` | `void SetPipelineOptionBool(UInterchangeBasePipeline*, const FString&, bool)`（WITH_EDITOR） | `None` |
| `set_pipeline_option_color(pipeline, option_name, color)` | `void SetPipelineOptionColor(UInterchangeBasePipeline*, const FString&, const FColor&)`（WITH_EDITOR） | `None` |

---

## 三、管道执行（Pipeline Execution）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `execute_pipeline(pipeline)` | `bool ExecutePipeline(UInterchangeBasePipeline*)`（WITH_EDITOR） | `bool` |
| `execute_pipeline_async(pipeline)` | `void ExecutePipelineAsync(UInterchangeBasePipeline*)`（WITH_EDITOR） | `None` |
| `is_pipeline_execution_complete(pipeline)` | `bool IsPipelineExecutionComplete(const UInterchangeBasePipeline*)` | `bool` |

---

## 四、节点与源查询（Node & Source Query）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_pipeline_source_count(pipeline)` | `int32 GetPipelineSourceCount(const UInterchangeBasePipeline*)` | `int` |
| `get_pipeline_source_info(pipeline, index)` | `const FInterchangeSource* GetPipelineSourceInfo(const UInterchangeBasePipeline*, int32)` | `SourceInfo` |
| `get_pipeline_node_count(pipeline)` | `int32 GetPipelineNodeCount(const UInterchangeBasePipeline*)` | `int` |
| `get_pipeline_node_data(pipeline, node_key)` | `const FInterchangeNode* GetPipelineNodeData(const UInterchangeBasePipeline*, const FString&)` | `NodeData` |
| `get_pipeline_node_keys(pipeline)` | `TArray<FString> GetPipelineNodeKeys(const UInterchangeBasePipeline*)` | `Array[str]` |
| `get_pipeline_node_child_count(pipeline, node_key)` | `int32 GetPipelineNodeChildCount(const UInterchangeBasePipeline*, const FString&)` | `int` |
| `get_pipeline_node_child(pipeline, node_key, child_index)` | `FString GetPipelineNodeChild(const UInterchangeBasePipeline*, const FString&, int32)` | `str` |
| `get_pipeline_node_attribute_count(pipeline, node_key)` | `int32 GetPipelineNodeAttributeCount(const UInterchangeBasePipeline*, const FString&)` | `int` |
| `get_pipeline_node_attribute_name(pipeline, node_key, attr_index)` | `FString GetPipelineNodeAttributeName(const UInterchangeBasePipeline*, const FString&, int32)` | `str` |
| `get_pipeline_node_attribute_value(pipeline, node_key, attr_name)` | `FString GetPipelineNodeAttributeValue(const UInterchangeBasePipeline*, const FString&, const FString&)` | `str` |

---

## 五、工具函数（Utilities）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `convert_import_path(source_path)` | `FString ConvertImportPath(const FString&)`（WITH_EDITOR） | `str` |
| `get_supported_import_formats()` | `TArray<FString> GetSupportedImportFormats()` | `Array[str]` |
| `get_supported_export_formats()` | `TArray<FString> GetSupportedExportFormats()` | `Array[str]` |
| `get_pipeline_type(pipeline)` | `EInterchangePipelineType::Type GetPipelineType(const UInterchangeBasePipeline*)` | `int` |

---

## 六、导入结果（Import Results）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_import_pipeline_imported_nodes(import_pipeline)` | `TArray<UObject*> GetImportPipelineImportedNodes(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Array[Object]` |
| `get_import_pipeline_imported_graph(import_pipeline)` | `UInterchangeBaseGraph* GetImportPipelineImportedGraph(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Graph \| None` |

---

## 七、导入器设置（Importers）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_fbx_importer(import_pipeline)` | `UInterchangeFbxImporter* GetFbxImporter(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Importer \| None` |
| `get_usd_importer(import_pipeline)` | `UInterchangeUsdImporter* GetUsdImporter(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Importer \| None` |

---

## 八、导出器设置（Exporters）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_fbx_exporter(export_pipeline)` | `UInterchangeFbxExporter* GetFbxExporter(UInterchangeBaseExporterPipeline*)`（WITH_EDITOR） | `Exporter \| None` |
| `get_usd_exporter(export_pipeline)` | `UInterchangeUsdExporter* GetUsdExporter(UInterchangeBaseExporterPipeline*)`（WITH_EDITOR） | `Exporter \| None` |

---

## 九、UFUNCTION 对应的 Python 方法清单

**所有 `UInterchangeUtilityLibrary` 类的 `UFUNCTION()` 成员方法：**

1. `CreateImportPipeline`
2. `CreateExportPipeline`
3. `CreateBasePipeline`
4. `SetPipelineSourceFile`
5. `SetPipelineSourceData`
6. `SetPipelineRootNodes`
7. `SetPipelineOption`
8. `SetPipelineOptionInt`
9. `SetPipelineOptionFloat`
10. `SetPipelineOptionBool`
11. `SetPipelineOptionColor`
12. `ExecutePipeline`
13. `ExecutePipelineAsync`
14. `IsPipelineExecutionComplete`
15. `GetPipelineSourceCount`
16. `GetPipelineSourceInfo`
17. `GetPipelineNodeCount`
18. `GetPipelineNodeData`
19. `GetPipelineNodeKeys`
20. `GetPipelineNodeChildCount`
21. `GetPipelineNodeChild`
22. `GetPipelineNodeAttributeCount`
23. `GetPipelineNodeAttributeName`
24. `GetPipelineNodeAttributeValue`
25. `ConvertImportPath`
26. `GetSupportedImportFormats`
27. `GetSupportedExportFormats`
28. `GetPipelineType`
29. `GetImportPipelineImportedNodes`
30. `GetImportPipelineImportedGraph`
31. `GetFbxImporter`
32. `GetUsdImporter`
33. `GetFbxExporter`
34. `GetUsdExporter`

**说明：**
- `WITH_EDITOR` 限定方法仅编辑器 Python 可用
- 实际暴露的方法以目标编辑器 `help(unreal.InterchangeUtilityLibrary)` 输出为准

---

## 十、支持的导入/导出格式

**导入格式（典型）：**
- FBX (*.fbx)
- DAE (*.dae)
- USD/USDA/USDC (*.usd, *.usda, *.usdc)
- OBJ (*.obj)
- PLY (*.ply)
- GLTF/GLB (*.gltf, *.glb)

**导出格式（典型）：**
- FBX (*.fbx)
- USD/USDA/USDC (*.usd, *.usda, *.usdc)

**注意：**实际支持格式因插件版本与项目配置而异，务必通过 `get_supported_import_formats()` 与 `get_supported_export_formats()` 在目标环境验证。

---

## 十一、使用限制与要求

- **插件依赖：** 项目必须在 Edit > Plugins > Interchange 中启用插件并重载
- **编辑器限制：** 全部方法需在编辑器 Python 中调用（`unreal.System.is_running_in_editor() == True`）
- **BLOCKED_TOOLING：** 项目未启用 Interchange 插件或非编辑器环境返回 `BLOCKED_TOOLING`
- **BLOCKED_INPUT：** 缺少源文件路径、管道创建失败或文件不存在返回 `BLOCKED_INPUT`
- **写入持久化：** 导入的资产需调用 `unreal.EditorAssetLibrary.save_asset()` 固化
- **未实测调用：** 本表未在真实 UE 5.6 Editor 中实测，调用前需在目标 5.6 环境验证
