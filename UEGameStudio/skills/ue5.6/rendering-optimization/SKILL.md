---
name: rendering-optimization
description: "当用户提到UE5.6性能优化、HLOD生成、Draw Call合并、LOD配置、Niagara预算或贴图压缩时使用。UE5.6渲染性能优化技能：指导HLOD自动生成流程、Draw Call合批策略、LOD链配置、Niagara粒子预算分配和贴图流送压缩，避免HLOD缺失导致的Draw Call激增与帧率回退。"
category: development
risk: critical
---

# 渲染性能优化（UE5.6）

## 概述

本技能提供UE5.6渲染性能优化的标准化流程，覆盖HLOD系统配置、Draw Call合并、LOD链设计、Niagara粒子系统预算与贴图压缩策略。基于UE5.6的最新渲染架构，确保在不损失视觉质量的前提下显著提升帧率与流畅度。

## 何时使用此技能

- 当用户需要生成或检查HLOD（Hierarchical Level of Detail）数据时使用
- 当出现Draw Call过多导致GPU瓶颈时使用
- 当LOD切换不平滑或过度 tessellation 时使用
- 当Niagara粒子系统导致性能回退时使用
- 当贴图内存占用过高或流送卡顿时使用
- 当用户提到 `-run=BuildHLOD`、`HLOD`、`DrawCall`、`LOD`、`NiagaraBudget`、`TextureStreaming` 等关键词时使用

## 示例

### 示例 1：生成HLOD数据（命令行 Cook）

```bash
# 在项目根目录执行（确保UE Editor已关闭，仅用于Cook场景）
"C:\Program Files\Epic Games\UE_5.6\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" "YourProject.uproject" -run=BuildHLOD -platform=PC -cook -buildhoudini -commandlet

# 或在UE Editor中通过Project Settings > Level Design > HLOD启用自动HLOD生成
# 然后通过 File > Cook Content for Windows 生成HLOD数据
```

### 示例 2：LOD配置检查清单（在UE Editor中验证）

1. 打开 **Mesh Asset** → **LOD Settings**
2. 确保 `Screen Size` 链平滑过渡（相邻LOD差异 ≥ 0.1）
3. 多边形面数递减比例保持 ≥ 50%（LOD1 ≤ 50% LOD0, LOD2 ≤ 50% LOD1）
4. 检查 `MinLOD` 不得低于 `4`（避免极远距离过度简化）

### 示例 3：Niagara预算配置（`DefaultNiagara.ini`）

```ini
[/Script/Niagara.NiagaraSystemActor]
+BudgetAllocatorSettings=(AllocatorName="ParticleCount",MinBudget=1000,MaxBudget=10000,Weight=1.0)

[/Script/Niagara.NiagaraComponent]
bEnableSystemBudget=True
SystemBudgetMaxCount=50
```

### 示例 4：贴图压缩与流送配置（`DefaultEngine.ini`）

```ini
[/Script/Engine.TextureStreaming]
TextureGroup=Mobile
MinTextureRes=256
MaxTextureRes=2048
MinLOD=0
MaxLOD=3
LODBias=1

[/Script/Engine.Texture]
CompressionSettings=TC_Default
CompressionNoAlpha=True
CompressionQuality=50
```

## 最佳实践

- ✅ HLOD生成后务必验证 `HLOD Proxy Mesh` 是否被正确应用到关卡（通过 `Alt+H` 切换HLOD视图）
- ✅ Draw Call预算：单个视图 ≤ 500（移动平台 ≤ 200）
- ✅ LOD切换视差角 ≤ 15°（避免切换可见性突变）
- ✅ Niagara粒子预算分配基于帧率目标（60fps需 ≤ 10000 particles, 30fps ≤ 5000）
- ✅ 贴图压缩：PC使用 `TC_Default`，移动端使用 `TC_Mobile`，法线贴图使用 `TC_NormalMAP`

## 限制和注意事项

- ❌ HLOD仅适用于静态网格（Static Mesh），对动态Actor（如Character、Pawn）无效
- ❌ HLOD生成需要完整的关卡Scene Graph，空关卡无法生成有效HLOD数据
- ❌ 自定义Shader（如Custom Depth/Stencil）可能导致HLOD回退到单独渲染
- ❌ Niagara Budget Allocator未正确配置时，粒子系统不会被节流（可能导致帧率骤降）
- ❌ 贴图压缩质量降低可能引入可见artifact（特に法线贴图与透明贴图）
- ❌ 使用 `-run=BuildHLOD` 命令行Cook时，必须确保项目已启用 `HLOD` 插件（或在Build.cs中添加 `PublicDependencyModuleNames.Add("HierarchicalLOD")`）
