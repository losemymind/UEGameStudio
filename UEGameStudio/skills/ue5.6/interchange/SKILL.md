---
name: interchange
description: "UE Interchange插件（资产导入导出） - 多格式导入管道、资产转换与格式支持；支持FBX、DAE、USD等；需在UE中启用Interchange插件"
tags: [ue5.6, interchange, import, export, fbx, usd, python, plugin]
---

# Interchange - 资产导入导出系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `Interchange` 插件（需在UE编辑器中启用）通过 Python 可调用的类与函数。方法名与签名依据 `Interchange/Source/Interchange/Classes/Interchange.h` 中带 `UFUNCTION()` 标记的成员整理；Python 方法名按反射约定转 snake_case。

## 入口说明

```python
import unreal

# 创建导入管道示例（需编辑器环境）
pipeline = unreal.InterchangePipelineFactory.create_import_pipeline()
unreal.InterchangeUtilityLibrary.set_pipeline_source_file(pipeline, "C:/path/to/fbx")

# 执行导入
result = unreal.InterchangePipelineFactory.execute_pipeline(pipeline)
```

**实测要求：**
- 编辑器 Python 环境（非运行时）
- 项目已启用 `Interchange` 插件（Edit > Plugins > Interchange > Enabled + 重载）
- 带 `WITH_EDITOR` 限定的方法仅编辑器可用

**BLOCKED_TOOLING 处理：**
```python
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "Interchange 仅编辑器 Python 可用"})
    raise SystemExit(1)

interchange_plugin = unreal.EditorPluginUtil.is_plugin_enabled("Interchange")
if not interchange_plugin:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 Interchange 插件"})
    raise SystemExit(1)
```

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **管道创建** | | | |
| 创建导入管道 | `create_import_pipeline()` | `UInterchangeBaseImporterPipeline* CreateImportPipeline()`（WITH_EDITOR） | `Pipeline` 或 `None` |
| 创建导出管道 | `create_export_pipeline()` | `UInterchangeBaseExporterPipeline* CreateExportPipeline()`（WITH_EDITOR） | `Pipeline` 或 `None` |
| 创建基础管道 | `create_base_pipeline(pipeline_type)` | `UInterchangeBasePipeline* CreateBasePipeline(EInterchangePipelineType::Type)`（WITH_EDITOR） | `Pipeline` 或 `None` |
| **管道设置** | | | |
| 设置源文件 | `set_pipeline_source_file(pipeline, file_path)` | `void SetPipelineSourceFile(UInterchangeBasePipeline*, const FString&)`（WITH_EDITOR） | `None` |
| 设置源数据 | `set_pipeline_source_data(pipeline, data, size)` | `void SetPipelineSourceData(UInterchangeBasePipeline*, const uint8*, int32)`（WITH_EDITOR） | `None` |
| 设置根节点 | `set_pipeline_root_nodes(pipeline, nodes)` | `void SetPipelineRootNodes(UInterchangeBasePipeline*, const TArray<FString>&)`（WITH_EDITOR） | `None` |
| 设置选项 | `set_pipeline_option(pipeline, option_name, value)` | `void SetPipelineOption(UInterchangeBasePipeline*, const FString&, const FString&)`（WITH_EDITOR） | `None` |
| 设置选项（整数） | `set_pipeline_option_int(pipeline, option_name, value)` | `void SetPipelineOptionInt(UInterchangeBasePipeline*, const FString&, int32)`（WITH_EDITOR） | `None` |
| 设置选项（浮点） | `set_pipeline_option_float(pipeline, option_name, value)` | `void SetPipelineOptionFloat(UInterchangeBasePipeline*, const FString&, float)`（WITH_EDITOR） | `None` |
| 设置选项（布尔） | `set_pipeline_option_bool(pipeline, option_name, value)` | `void SetPipelineOptionBool(UInterchangeBasePipeline*, const FString&, bool)`（WITH_EDITOR） | `None` |
| 设置选项（颜色） | `set_pipeline_option_color(pipeline, option_name, color)` | `void SetPipelineOptionColor(UInterchangeBasePipeline*, const FString&, const FColor&)`（WITH_EDITOR） | `None` |
| **管道执行** | | | |
| 执行管道 | `execute_pipeline(pipeline)` | `bool ExecutePipeline(UInterchangeBasePipeline*)`（WITH_EDITOR） | `bool` |
| 执行管道（异步） | `execute_pipeline_async(pipeline)` | `void ExecutePipelineAsync(UInterchangeBasePipeline*)`（WITH_EDITOR） | `None` |
| 检查执行状态 | `is_pipeline_execution_complete(pipeline)` | `bool IsPipelineExecutionComplete(const UInterchangeBasePipeline*)` | `bool` |
| **节点与源** | | | |
| 获取源数量 | `get_pipeline_source_count(pipeline)` | `int32 GetPipelineSourceCount(const UInterchangeBasePipeline*)` | `int` |
| 获取源信息 | `get_pipeline_source_info(pipeline, index)` | `const FInterchangeSource* GetPipelineSourceInfo(const UInterchangeBasePipeline*, int32)` | `SourceInfo` |
| 获取节点数量 | `get_pipeline_node_count(pipeline)` | `int32 GetPipelineNodeCount(const UInterchangeBasePipeline*)` | `int` |
| 获取节点数据 | `get_pipeline_node_data(pipeline, node_key)` | `const FInterchangeNode* GetPipelineNodeData(const UInterchangeBasePipeline*, const FString&)` | `NodeData` |
| 获取节点键列表 | `get_pipeline_node_keys(pipeline)` | `TArray<FString> GetPipelineNodeKeys(const UInterchangeBasePipeline*)` | `Array[str]` |
| 获取节点子节点数 | `get_pipeline_node_child_count(pipeline, node_key)` | `int32 GetPipelineNodeChildCount(const UInterchangeBasePipeline*, const FString&)` | `int` |
| 获取节点子节点 | `get_pipeline_node_child(pipeline, node_key, child_index)` | `FString GetPipelineNodeChild(const UInterchangeBasePipeline*, const FString&, int32)` | `str` |
| 获取节点属性数 | `get_pipeline_node_attribute_count(pipeline, node_key)` | `int32 GetPipelineNodeAttributeCount(const UInterchangeBasePipeline*, const FString&)` | `int` |
| 获取节点属性名 | `get_pipeline_node_attribute_name(pipeline, node_key, attr_index)` | `FString GetPipelineNodeAttributeName(const UInterchangeBasePipeline*, const FString&, int32)` | `str` |
| 获取节点属性值 | `get_pipeline_node_attribute_value(pipeline, node_key, attr_name)` | `FString GetPipelineNodeAttributeValue(const UInterchangeBasePipeline*, const FString&, const FString&)` | `str` |
| **工具函数** | | | |
| 转换路径 | `convert_import_path(source_path)` | `FString ConvertImportPath(const FString&)`（WITH_EDITOR） | `str` |
| 获取支持格式 | `get_supported_import_formats()` | `TArray<FString> GetSupportedImportFormats()` | `Array[str]` |
| 获取支持导出格式 | `get_supported_export_formats()` | `TArray<FString> GetSupportedExportFormats()` | `Array[str]` |
| 获取管道类型 | `get_pipeline_type(pipeline)` | `EInterchangePipelineType::Type GetPipelineType(const UInterchangeBasePipeline*)` | `int` |
| **导入结果** | | | |
| 获取导入节点 | `get_import_pipeline_imported_nodes(import_pipeline)` | `TArray<UObject*> GetImportPipelineImportedNodes(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Array[Object]` |
| 获取导入图 | `get_import_pipeline_imported_graph(import_pipeline)` | `UInterchangeBaseGraph* GetImportPipelineImportedGraph(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Graph` 或 `None` |
| **导入器设置** | | | |
| 获取 FBX 导入器 | `get_fbx_importer(import_pipeline)` | `UInterchangeFbxImporter* GetFbxImporter(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Importer` 或 `None` |
| 获取 USD 导入器 | `get_usd_importer(import_pipeline)` | `UInterchangeUsdImporter* GetUsdImporter(UInterchangeBaseImporterPipeline*)`（WITH_EDITOR） | `Importer` 或 `None` |
| **导出器设置** | | | |
| 获取 FBX 导出器 | `get_fbx_exporter(export_pipeline)` | `UInterchangeFbxExporter* GetFbxExporter(UInterchangeBaseExporterPipeline*)`（WITH_EDITOR） | `Exporter` 或 `None` |
| 获取 USD 导出器 | `get_usd_exporter(export_pipeline)` | `UInterchangeUsdExporter* GetUsdExporter(UInterchangeBaseExporterPipeline*)`（WITH_EDITOR） | `Exporter` 或 `None` |

## 快速示例

```python
import unreal

# 1. 验证插件与环境
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "Interchange 仅编辑器可用"})
    raise SystemExit(1)

plugin_enabled = unreal.EditorPluginUtil.is_plugin_enabled("Interchange")
if not plugin_enabled:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 Interchange 插件"})
    raise SystemExit(1)

# 2. 创建导入管道
pipeline = unreal.InterchangePipelineFactory.create_import_pipeline()
if pipeline is None:
    print("BLOCKED_TOOLING: Failed to create import pipeline")
    raise SystemExit(1)

# 3. 设置源文件
source_path = "C:/Assets/Character.fbx"
if not unreal.Paths.file_exists(source_path):
    print(f"BLOCKED_INPUT: Source file not found: {source_path}")
    raise SystemExit(1)

unreal.InterchangeUtilityLibrary.set_pipeline_source_file(pipeline, source_path)

# 4. 设置导入选项（以 FBX 为例）
unreal.InterchangeUtilityLibrary.set_pipeline_option(pipeline, "ImportAsSkeletal", "true")
unreal.InterchangeUtilityLibrary.set_pipeline_option(pipeline, "ImportAnimations", "true")
unreal.InterchangeUtilityLibrary.set_pipeline_option_int(pipeline, "AnimationImportFPS", 30)

# 5. 执行导入
success = unreal.InterchangePipelineFactory.execute_pipeline(pipeline)
if not success:
    print("BLOCKED_TOOLING: Pipeline execution failed")
    raise SystemExit(1)

# 6. 获取导入结果
imported_nodes = unreal.InterchangeUtilityLibrary.get_import_pipeline_imported_nodes(pipeline)
print(f"Imported {len(imported_nodes)} nodes")

# 7. 获取管道类型
pipeline_type = unreal.InterchangeUtilityLibrary.get_pipeline_type(pipeline)
print(f"Pipeline type: {pipeline_type}")

# 8. 获取支持格式
supported_formats = unreal.InterchangeUtilityLibrary.get_supported_import_formats()
print("Supported formats:", supported_formats)
```

## 注意事项

- **阻塞处理：**
  - 缺少文件路径、管道创建失败等返回 `BLOCKED_INPUT`
  - 无编辑器环境或插件未启用返回 `BLOCKED_TOOLING`
  - `WITH_EDITOR` 限定方法仅编辑器 Python 可用；非编辑器环境调用失败

- **返回值约定：**
  - `void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位
  - `UObject*` / `UClass*` 返回对应 Python 对象或 `None`
  - `const FInterchangeSource*` / `const FInterchangeNode*` 为只读引用

- **支持格式：**
  - **导入：** FBX、DAE、USD、OBJ、PLY、GLTF 等（取决于插件版本）
  - **导出：** FBX、USD 等
  - 实际支持格式以目标编辑器 `get_supported_import_formats()` 输出为准

- **管道类型：**
  - `EInterchangePipelineType::IMPORT` - 导入管道
  - `EInterchangePipelineType::EXPORT` - 导出管道
  - `EInterchangePipelineType::BASE` - 基础管道

- **持久化：**
  - 导入/导出完成后，导入的资产需调用 `unreal.EditorAssetLibrary.save_asset()` 持久化
  - 修改 pipeline 选项后重新执行才能生效

- **未实测声明：**
  - 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言
  - 方法名、签名、返回值类型需在 5.6 实际环境中通过 `dir(unreal.InterchangeUtilityLibrary)`、`help()` 核对确认

详细 API 与完整示例见 `docs/overview.md`。
