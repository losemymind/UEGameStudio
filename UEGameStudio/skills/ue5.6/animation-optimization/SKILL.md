---
name: animation-optimization
description: "当用户提到UE5.6动画性能、AnimBP压缩、Motion Warping预算、Animation Shared Plugin或Animation Budget Allocator时使用。UE5.6动画系统优化技能：指导AnimBP压缩配置、 Motion Warping参数调整、Animation Shared Plugin（Skeleton/Slot/Slot Animations）优化与Budget分配器设置，避免Budget未配置导致的动画帧率回退。"
category: development
risk: critical
---

# 动画性能优化（UE5.6）

## 概述

本技能提供UE5.6动画系统（Animation System）性能优化的标准化流程，覆盖AnimBP（Animation Blueprint）压缩策略、Motion Warping预算控制、Animation Shared Plugin配置（Skeleton/Slot/Slot Animations）与Animation Budget Allocator设置。确保在维持高精度动画效果的同时，最大化CPU/GPU资源利用效率。

## 何时使用此技能

- 当用户需要压缩AnimBP以降低CPU负载时使用
- 当Motion Warping导致角色位置偏移过大时使用
- 当Animation Shared Plugin（骨骼/插槽/插槽动画）引发性能回退时使用
- 当动画Budget Allocator未配置导致帧率骤降时使用
- 当用户提到 `AnimBP`, `MotionWarping`, `SkeletonPlugin`, `SlotAnimation`, `AnimationBudgetAllocator`, `AnimCompression` 等关键词时使用

## 示例

### 示例 1：AnimBP压缩配置（`DefaultEngine.ini`）

```ini
[/Script/Engine.AnimationCompression]
bEnableCompression=True
CompressionLevel=5
AllowAnimScaleCompression=True
RemoveLinearKeys=False

[/Script/Engine.AnimSet]
AnimCompressionRatio=0.7
bCompressAnimData=True
```

### 示例 2：Motion Warping预算配置（C++）

```cpp
// MyCharacter.h
class AMyCharacter : public ACharacter
{
    UPROPERTY(EditAnywhere, Category="MotionWarping")
    float WarpPositionThreshold = 50.0f;
    
    UPROPERTY(EditAnywhere, Category="MotionWarping")
    float WarpRotationThreshold = 30.0f;
};

// MyCharacter.cpp
void AMyCharacter::OnMovementWarpStart()
{
    if (GetDistanceTo(WarpTarget) > WarpPositionThreshold)
    {
        MotionWarpingComponent->AddWarpTarget(WarpTarget);
    }
}

void AMyCharacter::OnWarpUpdate()
{
    if (MotionWarpingComponent->IsWarping())
    {
        MotionWarpingComponent->UpdateWarping(0.1f); // 每帧更新间隔 ≤ 0.1s
    }
}
```

### 示例 3：Animation Shared Plugin配置（`DefaultAnimationShared.ini`）

```ini
[/Script/AnimationSharedPlugin.AnimationSharedPlugin]
bEnablePlugin=True
SkeletonPluginName="MySkeletonPlugin"
SlotAnimationPluginName="MySlotAnimPlugin"

[/Script/AnimationSharedPlugin.SkeletonPlugin]
MaxCacheSizeMB=256
bEnableAsyncLoading=True

[/Script/AnimationSharedPlugin.SlotAnimationPlugin]
MaxInstanceCount=1000
bEnableCulling=True
CullingBoxSize=5000.0
```

### 示例 4：Animation Budget Allocator配置（`DefaultEngine.ini`）

```ini
[/Script/Engine.AnimationBudgetAllocator]
bEnableBudgetAllocator=True
BudgetType=ABDT_Components
MaxComponents=500
MaxCPUmsPerFrame=10.0
MaxGPUmsPerFrame=5.0

[/Script/Engine.AnimationBudgetSettings]
ComponentBudget=500
ActorBudget=100
LODBias=1
```

## 最佳实践

- ✅ AnimBP压缩级别 ≤ 5（过高会导致动画回放抖动）
- ✅ Motion Warping的 `WarpPositionThreshold` 应 ≥ 3×角色半径（避免过度修正）
- ✅ Skeleton Plugin的 `MaxCacheSizeMB` 应 ≥ 骨骼总数 × 10 KB（估算公式）
- ✅ Animation Budget Allocator的 `MaxComponents` 应 ≥ 场景最大动画Actor数量 × 1.2（冗余因子）
- ✅ Slot Animation每帧实例数 ≤ 100（避免GPU Instancing溢出）

## 限制和注意事项

- ❌ AnimBP压缩后无法在动画图（AnimGraph）中直接编辑节点（需先解压）
- ❌ Motion Warping不支持 `Root Motion` 模式（Root Motion必须禁用Warping）
- ❌ Skeleton Plugin的 `MaxCacheSizeMB` 超出物理内存会导致Swap（帧率回退）
- ❌ Animation Budget Allocator未启用时，所有动画Actor无条件更新（即使不可见）
- ❌ Slot Animation Plugin无法处理 `Nativize` 类型的Blueprint Asset
- ❌ 运行时动态修改Budget Allocator参数需要调用 `AnimationBudgetAllocator->UpdateConfiguration()`（否则不生效）
