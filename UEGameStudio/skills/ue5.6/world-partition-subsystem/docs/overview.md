# WorldPartitionSubsystem - 概述（UE 5.6）

## 库功能概述

`UWorldPartitionSubsystem` 是 UE 5.6 中专门用于处理世界分区（World Partition）系统的核心子系统。世界分区是 UE 5 引入的大型开放世界管理技术，将整个游戏世界分割为无数个统一大小的 Grid Cell，支持按需加载与卸载，实现超大地图的流畅运行。

该子系统提供了对世界分区数据的查询、加载状态监控、Cell 管理等能力，是开发大型开放世界游戏不可或缺的基础设施。

## 核心用途与场景

### 1. 大型开放世界管理
- **Cell 加载控制**：根据玩家位置动态加载/卸载地图区域
- **流送优化**：预加载远处区域，减少卡顿
- **内存管理**：自动卸载远离玩家的 Grid Cell，控制内存占用

### 2. 分级细节（LOD）支持
- **网格细节切换**：根据距离自动切换模型细节层级（LOD）
- **纹理流式加载**：按需加载高分辨率纹理
- **粒子系统管理**：控制远处粒子性能

### 3. 世界查询与遍历
- **区域内 Actors 查询**：查询特定区域内的所有 Actor
- **网格遍历**：遍历当前加载的所有 Grid Cell
- **空间查询**：射线检测、体积查询等

## 更多使用示例

### 示例 1：获取 WorldPartitionSubsystem
```python
import unreal

def get_world_partition_subsystem():
    """获取 WorldPartitionSubsystem 实例"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    if world is None:
        return {"status": "BLOCKED_TOOLING", "reason": "World not available"}
    
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_INPUT", "reason": "WorldPartitionSubsystem not enabled"}
    
    return {"status": "OK", "subsystem": subsystem}
```

### 示例 2：查询区域内 Actors
```python
import unreal

def query_actors_in_radius(center, radius):
    """查询指定半径内的所有 Actors"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 执行空间查询
    actors = subsystem.get_actors_in_box(
        unreal.Box(center - unreal.Vector(radius, radius, radius),
                   center + unreal.Vector(radius, radius, radius))
    )
    
    return {
        "status": "OK",
        "center": center,
        "radius": radius,
        "actor_count": len(actors),
        "actors": [a.get_actor_label() for a in actors[:10]]  # 限制返回数量
    }

# 使用示例
result = query_actors_in_radius(unreal.Vector(0.0, 0.0, 0.0), 1000.0)
```

### 示例 3：监控 Cell 加载状态
```python
import unreal

def check_cell_loading_status():
    """检查当前加载的 Grid Cell"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取当前加载的 Cell
    loaded_cells = subsystem.get_loaded_operative_cells()
    
    return {
        "status": "OK",
        "loaded_cell_count": len(loaded_cells),
        "cells": [f"Cell_{i}" for i in range(min(5, len(loaded_cells)))]  # 示例格式
    }

def check_cell_performance():
    """检查 Cell 性能数据"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取性能统计
    stats = subsystem.get_world_partition_stats()
    
    return {
        "status": "OK",
        "total_cells": stats.get_total_cells(),
        "loaded_cells": stats.get_loaded_operative_cells_count(),
        "visible_cells": stats.get_visible_cells_count(),
        " streaming_time_ms": stats.get_streaming_time_ms() if hasattr(stats, 'get_streaming_time_ms') else None
    }
```

### 示例 4：手动加载/卸载 Cell
```python
import unreal

def manually_stream_cell(cell_coordinate):
    """手动控制 Cell 的加载与卸载"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取 Cell 渲染网格坐标
    # 通常从 WorldPartitionActor 获取或使用 WorldPartitionRuntimeSettings
    # 这里为示例值，实际需根据项目配置计算
    # grid_coord = unreal.IntVector(x, y, z)
    
    # 手动加载
    # subsystem.stream_level_by_name("Cell_X_Y_Z", True, True)
    
    return {
        "status": "OK",
        "action": "manual_stream",
        "note": "具体坐标计算需根据项目 WorldPartition 配置"
    }

def force_reload_all_cells():
    """强制重新加载所有 Cell"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 强制重新流送
    subsystem.force_restream_all()
    
    return {"status": "OK", "action": "force_restream"}
```

### 示例 5：世界分区调试
```python
import unreal

def debug_world_partition():
    """输出世界分区调试信息"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取配置信息
    settings = unreal.get_default_object(unreal.WorldPartitionSettings)
    
    info = {
        "status": "OK",
        "grid_size": settings.get_grid_size(),
        "cell_extent": settings.get_cell_extent(),
        "compression_cell_extent": settings.get_compression_cell_extent(),
        "actor_batch_query_size": settings.get_actor_batch_query_size(),
        "perf_measurement_period": settings.get_perf_measurement_period(),
        "streaming_distance": settings.get_streaming_distance(),
    }
    
    # 获取运行时状态
    stats = subsystem.get_world_partition_stats()
    info["loaded_cells"] = stats.get_loaded_operative_cells_count()
    info["visible_cells"] = stats.get_visible_cells_count()
    
    return info
```

## 高级用法与最佳实践

### 1. 性能监控与优化
- **实时监控**：定期查询 `get_world_partition_stats()` 监控加载性能
- **内存追踪**：监控 `get_loaded_cells_count()` 与内存使用 correlate
- **流送压力测试**：通过 `force_restream_all()` 进行压力测试

### 2. 自定义流送策略
- **玩家位置跟踪**：监听玩家位置变化，预加载前方区域
- **LOD 切换控制**：根据距离动态调整 Actor 的 LOD 级别
- **优先级管理**：为重要区域设置更高加载优先级

### 3. 异步加载支持
- **异步流送**：使用 `AsyncLoad` API 实现非阻塞加载
- **进度反馈**：监控流送进度，向用户显示加载界面
- **断点续载**：支持暂停与恢复流送过程

### 4. 与 Editor Utility 集成
```python
import unreal

def batch_verify_cells():
    """批量验证所有 Cell 的完整性"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.WorldPartitionSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取所有 Cell
    all_cells = subsystem.get_all_cells()
    
    # 验证每个 Cell
    valid_cells = []
    for cell in all_cells:
        if cell.is_valid():
            valid_cells.append(cell)
    
    return {
        "status": "OK",
        "total": len(all_cells),
        "valid": len(valid_cells),
        "invalid": len(all_cells) - len(valid_cells)
    }
```

## 常见问题与注意事项

### 1. 启用条件
- **项目设置**：必须在 Project Settings > Maps & Modes > World Partition 中启用
- **关卡格式**：世界必须使用 World Partition 格式（.umap 打开时选择 "World Partition"）
- **子类检查**：并非所有关卡都支持 WorldPartitionSubsystem

### 2. 性能考虑
- **查询频率**：避免每帧调用昂贵的查询（如 `get_actors_in_box`）
- **缓存结果**：缓存查询结果，减少重复查询
- **异步处理**：长期运行的查询使用异步任务

### 3. 多世界支持
- **PIE 隔离**：PIE 会话有独立的 WorldPartitionSubsystem 实例
- **编辑器主世界**：编辑器主世界也有独立实例（当启用 World Partition 时）
- **坐标系统**：注意不同世界的坐标系是否一致

### 4. 常见错误
- `BLOCKED_TOOLING`：World Partition 未启用或世界不支持
- `BLOCKED_INPUT`：世界或子系统实例为空
- **空查询**：查询区域内无 Actors 时返回空数组

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.WorldPartitionSubsystem)` 实测确认
- 个别高级方法（如 `get_cell_by_coordinate`、`get_cells_in_radius`）可能因插件而异

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。