---
name: world-optimization
description: "当用户提到UE5.6关卡性能、WorldPartition流送、Data Layer配置、PCG实例化或Foliage性能时使用。UE5.6世界性能优化技能：指导WorldPartition Streaming策略配置、Data Layer组织、PCG（Procedural Content Generator）实例化优化与Foliage Actor vs Mass Entity选择，避免流送卡顿与内存峰值。"
category: development
risk: critical
---

# 世界性能优化（UE5.6）

## 概述

本技能提供UE5.6世界（World）性能优化的标准化流程，覆盖大型开放世界项目的流送系统配置、Data Layer管理、PCG内容生成优化与植被系统（Foliage）性能调优。基于UE5.6的WorldPartition架构，确保在快速移动场景下保持稳定帧率与 seamless 加载体验。

## 何时使用此技能

- 当用户需要配置WorldPartition Streaming Policy时使用
- 当出现关卡流送延迟或卡顿（TTC: Time To Cook ≥ 50ms）时使用
- 当Data Layer组织混乱导致内存占用过高时使用
- 当PCG生成的Actor导致性能回退时使用
- 当Foliage实例过多导致Draw Call或GPU负载过高时使用
- 当用户提到 `WorldPartition`、`StreamingPolicy`、`DataLayer`、`PCG`、`Foliage` 等关键词时使用

## 示例

### 示例 1：WorldPartition Streaming Policy配置（`DefaultWorldPartition.ini`）

```ini
[/Script/WorldPartition.WorldPartition]
bEnableWorldPartition=True

[/Script/WorldPartition.WorldPartitionComponent]
StreamingPolicyClassName=/Game/MyProject/StreamingPolicies/MyStreamingPolicy.MyStreamingPolicy_C

[/Script/WorldPartition.StreamingPolicy]
CellSize=1024.0
ViewDistance=5000.0
RenderDistance=8000.0
StreamingDistance=3000.0
LODDistance=10000.0
```

### 示例 2：Data Layer组织示例（按场景与功能分层）

```text
Data Layers Structure:
├── Game
│   ├── Level1
│   │   ├── StaticGeometry.uasset
│   │   └── DynamicActors.uasset
│   ├── Level2
│   │   └── ...
│   └── Shared
│       ├── Lighting.uasset
│       └── Skybox.uasset
└── Gameplay
    ├── Characters.uasset
    ├── Vehicles.uasset
    └── Interactables.uasset
```

### 示例 3：PCG Actor实例化优化（`PCGSettings.ini`）

```ini
[PCG]
bEnablePCG=True
MaxInstancesPerBatch=100
InstanceSpacing=50.0
Seed=12345

[PCG.Performance]
bEnableCulling=True
CullingBoxSize=2000.0
bEnableLevelStreaming=true
```

### 示例 4：FoliageActor vs Mass Entity选择指南

| 场景 | 推荐方案 | 理由 |
|------|---------|------|
| 静态植被（树木/草），数量 ≥ 10,000 | Mass Foliage | GPU Instancing， Draw Call ≤ 10 |
| 动态交互植被（踩踏/破坏） | Foliage Actor（BP） | 需要Tick与碰撞响应 |
| 少量高性能植被（≤ 500） |静态网格Actor | 简单场景，无需Mass复杂度 |

## 最佳实践

- ✅ StreamingPolicy的 `ViewDistance` 应基于 gameplay需求（开放世界 ≥ 5000，竞速游戏 ≥ 8000）
- ✅ Data Layer按功能划分而非物理位置，避免单个Layer含多个不相关关卡
- ✅ PCG生成前先 `Pre-Spawn` 核心Actor（避免运行时动态生成卡顿）
- ✅ Foliage Actor仅用于需要Tick的实例，其余使用 `Mass Foliage`（UE5.6新增）
- ✅ 定期运行 `Window > Developer Tools > profiling > Streaming` 检查流送命中率（目标 ≥ 95%）

## 限制和注意事项

- ❌ WorldPartition不支持单个Actor跨越多个Cell（会切片成多个Part）
- ❌ Data Layer切换需要 `Reload Data Layer`，不能热重载（开发周期较长）
- ❌ PCG的 `Seed` 变更会导致全部缓存失效（建议固定Seed用于Production）
- ❌ Mass Foliage需启用 `MassRepresentation` 模块（在Build.cs中添加 `PublicDependencyModuleNames.Add("MassRepresentation")`）
- ❌ Foliage Actor的`OnActorEndOverlap`响应在高密度场景下可能滞后（建议用 `OnActorBeginOverlap` 替代）
- ❌ StreamingPolicy配置错误会导致关卡无限加载（务必在Small Map中先验证）
