---
name: metasound-source-subsystem
description: UMetasoundSourceSubsystem（UE 5.6）编辑器 Metasound 音频图子系统 - 音频图管理、节点创建、参数设置、音频图求值；在 Agent 需要通过 unreal Python 动态创建和控制 Metasound 音频图时使用
risk: safe
category: development
tags: [ue5.6, audio, metasound, python, subsystem]
---

# MetasoundSourceSubsystem - Metasound 音频图编辑器子系统（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 动态创建和控制 Metasound 音频图时使用本 skill（description 触发场景）。
- 本 skill 只在与 metasound-source-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UMetasoundSourceSubsystem`（`UEditorSubsystem` 派生）通过 Python 可调用的子系统方法。方法名与签名依据引擎头文件中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UMetasoundSourceSubsystem` 在 Python 中以子系统形式访问：

```python
import unreal

# 获取子系统实例
ms_subsystem = unreal.get_editor_subsystem(unreal.MetasoundSourceSubsystem)

# 示例：创建音频图
audio_graph = ms_subsystem.create_audio_graph()
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.MetasoundSourceSubsystem)` 核对）。
- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用会失败。
- Metasound 音频图编辑功能在 UE 5.6 中需音频模块启用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **图管理** | | | |
| 创建 | `create_audio_graph()` | `UAudioGraph* CreateAudioGraph()` | `AudioGraph` |
| 创建 | `create_empty_audio_graph()` | `UAudioGraph* CreateEmptyAudioGraph()` | `AudioGraph` |
| 加载 | `load_audio_graph(graph_path)` | `UAudioGraph* LoadAudioGraph(const FString&)` | `AudioGraph` 或 `None` |
| 获取 | `get_audio_graph(graph_path)` | `UAudioGraph* GetAudioGraph(const FString&)` | `AudioGraph` 或 `None` |
| 保存 | `save_audio_graph(audio_graph)` | `bool SaveAudioGraph(UAudioGraph*)` | `bool` |
| 保存 | `save_audio_graph_as(audio_graph, new_path)` | `bool SaveAudioGraphAs(UAudioGraph*, const FString&)` | `bool` |
| 删除 | `remove_audio_graph(graph_path)` | `bool RemoveAudioGraph(const FString&)` | `bool` |
| **节点创建** | | | |
| 节点 | `create_node(audio_graph, node_class, node_name)` | `UMetasoundNode* CreateNode(UAudioGraph*, UClass*, const FString&)` | `MetasoundNode` |
| 节点 | `create_node_by_name(audio_graph, node_class_name, node_name)` | `UMetasoundNode* CreateNodeByName(UAudioGraph*, const FString&, const FString&)` | `MetasoundNode` |
| 节点 | `create_constant_node(audio_graph, node_class, node_name, value)` | `UMetasoundNode* CreateConstantNode(UAudioGraph*, UClass*, const FString&, const FMetasoundFrontendLiteral&)` | `MetasoundNode` |
| 节点 | `create_input_node(audio_graph, node_name, input_type)` | `UMetasoundNode* CreateInputNode(UAudioGraph*, const FString&, EMetasoundFrontendNodeType)` | `MetasoundNode` |
| 节点 | `create_output_node(audio_graph, node_name, output_type)` | `UMetasoundNode* CreateOutputNode(UAudioGraph*, const FString&, EMetasoundFrontendNodeType)` | `MetasoundNode` |
| 删除 | `remove_node(audio_graph, metasound_node)` | `bool RemoveNode(UAudioGraph*, UMetasoundNode*)` | `bool` |
| **参数设置** | | | |
| 输入 | `set_node_input(audio_graph, metasound_node, input_name, value)` | `bool SetNodeInput(UAudioGraph*, UMetasoundNode*, const FString&, const FMetasoundFrontendLiteral&)` | `bool` |
| 输出 | `set_node_output(audio_graph, metasound_node, output_name, value)` | `bool SetNodeOutput(UAudioGraph*, UMetasoundNode*, const FString&, const FMetasoundFrontendLiteral&)` | `bool` |
| 连接 | `connect_nodes(audio_graph, source_node, source_output, target_node, target_input)` | `bool ConnectNodes(UAudioGraph*, UMetasoundNode*, const FString&, UMetasoundNode*, const FString&)` | `bool` |
| 断开 | `disconnect_nodes(audio_graph, source_node, source_output, target_node, target_input)` | `bool DisconnectNodes(UAudioGraph*, UMetasoundNode*, const FString&, UMetasoundNode*, const FString&)` | `bool` |
| **音频图求值** | | | |
| 求值 | `evaluate_audio_graph(audio_graph)` | `bool EvaluateAudioGraph(UAudioGraph*)` | `bool` |
| 求值 | `evaluate_audio_graph_with_inputs(audio_graph, inputs)` | `bool EvaluateAudioGraphWithInputs(UAudioGraph*, const TArray<FMetasoundFrontendLiteral>&)` | `bool` |
| 求值 | `get_evaluation_result(audio_graph, output_name)` | `FMetasoundFrontendLiteral GetEvaluationResult(UAudioGraph*, const FString&)` | `MetasoundFrontendLiteral` |
| **辅助** | | | |
| 辅助 | `get_all_audio_graphs()` | `TArray<UAudioGraph*> GetAllAudioGraphs()` | `Array[AudioGraph]` |
| 辅助 | `get_graph_path(audio_graph)` | `FString GetGraphPath(UAudioGraph*)` | `str` |
| 辅助 | `get_all_nodes(audio_graph)` | `TArray<UMetasoundNode*> GetAllNodes(UAudioGraph*)` | `Array[MetasoundNode]` |
| 辅助 | `get_node_class(node)` | `UClass* GetNodeClass(UMetasoundNode*)` | `Class` |
| 辅助 | `get_node_name(node)` | `FString GetNodeName(UMetasoundNode*)` | `str` |

## 示例

```python
import unreal

def create_metasound_graph():
    ms_subsystem = unreal.get_editor_subsystem(unreal.MetasoundSourceSubsystem)
    
    # 创建音频图
    audio_graph = ms_subsystem.create_empty_audio_graph()
    if audio_graph is None:
        print("BLOCKED_TOOLING: 音频图创建失败")
        return
    
    # 创建常量节点
    const_node = ms_subsystem.create_constant_node(
        audio_graph,
        unreal.MetasoundConstantsNode,
        "ConstantValue",
        unreal.MetasoundFrontendLiteral(1.0)
    )
    
    # 创建输入节点
    input_node = ms_subsystem.create_input_node(
        audio_graph,
        "AudioInput",
        unreal.EMetasoundFrontendNodeType.AUDIO
    )
    
    # 创建输出节点
    output_node = ms_subsystem.create_output_node(
        audio_graph,
        "AudioOutput",
        unreal.EMetasoundFrontendNodeType.AUDIO
    )
    
    # 连接节点
    ms_subsystem.connect_nodes(
        audio_graph,
        input_node, "Output",
        output_node, "Input"
    )
    
    # 保存音频图
    ok = ms_subsystem.save_audio_graph_as(audio_graph, "/Game/Metasound/MyGraph")
    print("save success:", ok)
    
    # 评估音频图
    inputs = [unreal.MetasoundFrontendLiteral(0.5)]
    eval_ok = ms_subsystem.evaluate_audio_graph_with_inputs(audio_graph, inputs)
    print("evaluation success:", eval_ok)
    
    # 获取求值结果
    result = ms_subsystem.get_evaluation_result(audio_graph, "Output")
    print("result:", result)

if __name__ == "__main__":
    create_metasound_graph()
```

## 限制和注意事项

- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用返回 `BLOCKED_TOOLING`。
- `CreateAudioGraph` / `CreateEmptyAudioGraph` 创建新的音频图资产；需调用 `SaveAudioGraph` 持久化到磁盘。
- `CreateNode` / `CreateConstantNode` 创建节点并自动添加到音频图；节点类需继承自 `UMetasoundNode`。
- `SetNodeInput` / `SetNodeOutput` 用于设置节点的输入/输出参数；`FMetasoundFrontendLiteral` 包含类型信息和值。
- `ConnectNodes` / `DisconnectNodes` 管理节点间的连接；源输出名与目标输入名需精确匹配。
- `EvaluateAudioGraph` 对音频图进行求值；输入参数按音频图定义的输入顺序传递。
- `GetEvaluationResult` 在求值后获取输出结果；`output_name` 必须是音频图的有效输出端口。
- 缺音频图、节点、连接等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
