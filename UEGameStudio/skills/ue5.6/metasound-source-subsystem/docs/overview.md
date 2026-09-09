# UMetasoundSourceSubsystem API 参考（UE 5.6）

本页列出 `UMetasoundSourceSubsystem` 的完整 Python 方法映射表，按功能分组。

## 图管理（Graph Management）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `create_audio_graph()` | `UAudioGraph* CreateAudioGraph()` | `AudioGraph` |
| `create_empty_audio_graph()` | `UAudioGraph* CreateEmptyAudioGraph()` | `AudioGraph` |
| `load_audio_graph(graph_path)` | `UAudioGraph* LoadAudioGraph(const FString&)` | `AudioGraph` 或 `None` |
| `get_audio_graph(graph_path)` | `UAudioGraph* GetAudioGraph(const FString&)` | `AudioGraph` 或 `None` |
| `save_audio_graph(audio_graph)` | `bool SaveAudioGraph(UAudioGraph*)` | `bool` |
| `save_audio_graph_as(audio_graph, new_path)` | `bool SaveAudioGraphAs(UAudioGraph*, const FString&)` | `bool` |
| `remove_audio_graph(graph_path)` | `bool RemoveAudioGraph(const FString&)` | `bool` |

## 节点创建（Node Creation）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `create_node(audio_graph, node_class, node_name)` | `UMetasoundNode* CreateNode(UAudioGraph*, UClass*, const FString&)` | `MetasoundNode` |
| `create_node_by_name(audio_graph, node_class_name, node_name)` | `UMetasoundNode* CreateNodeByName(UAudioGraph*, const FString&, const FString&)` | `MetasoundNode` |
| `create_constant_node(audio_graph, node_class, node_name, value)` | `UMetasoundNode* CreateConstantNode(UAudioGraph*, UClass*, const FString&, const FMetasoundFrontendLiteral&)` | `MetasoundNode` |
| `create_input_node(audio_graph, node_name, input_type)` | `UMetasoundNode* CreateInputNode(UAudioGraph*, const FString&, EMetasoundFrontendNodeType)` | `MetasoundNode` |
| `create_output_node(audio_graph, node_name, output_type)` | `UMetasoundNode* CreateOutputNode(UAudioGraph*, const FString&, EMetasoundFrontendNodeType)` | `MetasoundNode` |
| `remove_node(audio_graph, metasound_node)` | `bool RemoveNode(UAudioGraph*, UMetasoundNode*)` | `bool` |

## 参数设置（Parameter Setting）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `set_node_input(audio_graph, metasound_node, input_name, value)` | `bool SetNodeInput(UAudioGraph*, UMetasoundNode*, const FString&, const FMetasoundFrontendLiteral&)` | `bool` |
| `set_node_output(audio_graph, metasound_node, output_name, value)` | `bool SetNodeOutput(UAudioGraph*, UMetasoundNode*, const FString&, const FMetasoundFrontendLiteral&)` | `bool` |
| `connect_nodes(audio_graph, source_node, source_output, target_node, target_input)` | `bool ConnectNodes(UAudioGraph*, UMetasoundNode*, const FString&, UMetasoundNode*, const FString&)` | `bool` |
| `disconnect_nodes(audio_graph, source_node, source_output, target_node, target_input)` | `bool DisconnectNodes(UAudioGraph*, UMetasoundNode*, const FString&, UMetasoundNode*, const FString&)` | `bool` |

## 音频图求值（Audio Graph Evaluation）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `evaluate_audio_graph(audio_graph)` | `bool EvaluateAudioGraph(UAudioGraph*)` | `bool` |
| `evaluate_audio_graph_with_inputs(audio_graph, inputs)` | `bool EvaluateAudioGraphWithInputs(UAudioGraph*, const TArray<FMetasoundFrontendLiteral>&)` | `bool` |
| `get_evaluation_result(audio_graph, output_name)` | `FMetasoundFrontendLiteral GetEvaluationResult(UAudioGraph*, const FString&)` | `MetasoundFrontendLiteral` |

## 辅助（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_all_audio_graphs()` | `TArray<UAudioGraph*> GetAllAudioGraphs()` | `Array[AudioGraph]` |
| `get_graph_path(audio_graph)` | `FString GetGraphPath(UAudioGraph*)` | `str` |
| `get_all_nodes(audio_graph)` | `TArray<UMetasoundNode*> GetAllNodes(UAudioGraph*)` | `Array[MetasoundNode]` |
| `get_node_class(node)` | `UClass* GetNodeClass(UMetasoundNode*)` | `Class` |
| `get_node_name(node)` | `FString GetNodeName(UMetasoundNode*)` | `str` |
