---
name: world-partition-subsystem
description: UWorldPartitionSubsystem（UE 5.6）世界分区运行时子系统 - World Partition 流送与运行状态查询（全量完成、按单元格状态与查询源）；在 Agent 需要从 unreal Python 获取/调用世界分区流送运行状态查询时使用，是大型开放世界流送的高频入口
tags: [ue5.6, world-partition, streaming, subsystem, python]
---

# WorldPartitionSubsystem - 世界分区流送子系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UWorldPartitionSubsystem` 暴露给 Python 的运行时能力。头文件 `Engine/Source/Runtime/Engine/Public/WorldPartition/WorldPartitionSubsystem.h`。该类派生自 `UTickableWorldSubsystem`（继承自 `UWorldSubsystem`）并实现 `IStreamingWorldSubsystemInterface`，负责大世界 World Partition 的流送推进与状态查询；Agent 在开放世界项目中进行流送完成度/单元格状态轮询时以此为高频入口。

## 入口说明

`UWorldPartitionSubsystem` 属于 World 子系统，按世界隔离，从对应 `UWorld` 获取：

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
api = world.get_subsystem(unreal.WorldPartitionSubsystem)
```

- Python 类名为去 U 前缀的反射类 `unreal.WorldPartitionSubsystem`。
- 世界来源二选一：编辑器主世界用 `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()`；PIE/运行时世界传入对应运行的 `UWorld`。
- `world` 为 `None`（编辑器/运行时世界上下文不可用）时按 `BLOCKED_TOOLING` 处理并停止；`api` 为 `None`（子系统未实例化）时按 `BLOCKED_INPUT` 处理。
- Python 方法名按反射约定转 snake_case：本类两个方法均未声明 `ScriptMethod` meta，取 C++ 函数名转 snake_case；精确 Python 暴露名需实测确认。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 流送状态 | `is_all_streaming_completed()` | `bool IsAllStreamingCompleted()` | `bool` |
| 流送状态 | `is_streaming_completed(query_state, query_sources, exact_state)` | `bool IsStreamingCompleted(EWorldPartitionRuntimeCellState, const TArray<FWorldPartitionStreamingQuerySource>&, bool) const` | `bool` |

- `query_state`：目标单元格运行状态枚举 `EWorldPartitionRuntimeCellState`。
- `query_sources`：流送查询源数组 `FWorldPartitionStreamingQuerySource`；传空数组即针对全部流送范围。
- `exact_state`：是否要求与 `query_state` 严格精确匹配（`False` 时允许已达到或越过该状态的单元格）。
- 本类不含任何带 Out/ByRef 参数的方法，均为直接返回值。

## 快速示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    print("BLOCKED_TOOLING: 世界上下文不可用")
else:
    api = world.get_subsystem(unreal.WorldPartitionSubsystem)
    if api is None:
        print("BLOCKED_INPUT: WorldPartitionSubsystem 未实例化")
    else:
        print("all completed:", api.is_all_streaming_completed())
        done = api.is_streaming_completed(
            unreal.WorldPartitionRuntimeCellState.Activated,  # 枚举常量拼写以目标 5.6 编辑器实测为准
            [],
            False)
        print("query completed:", done)
```

## 注意事项

- 本 skill 只记录 Python 可调用的 API：World Partition 流送推进由 `UWorldPartition` 数据（LoadingRange、流送策略）驱动，本子系统提供的是流送运行状态查询入口。
- 按世界隔离：每个 `UWorld` 独立持有实例；编辑器主世界、PIE 世界与各加载世界分别独立查询。
- 无 PIE/世界上下文按 `BLOCKED_TOOLING`；目标世界未配置 World Partition（缺 World Partition 资产）时查询无意义，按 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 环境中实测的精确暴露名、枚举常量与结构体字段名不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。