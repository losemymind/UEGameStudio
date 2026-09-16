---
name: network-optimization
description: "当用户提到UE5.6网络性能、Replication Graph、Bandwidth Budget、角色预测回滚或Interest Overlap时使用。UE5.6网络系统优化技能：指导Replication Graph配置、Bandwidth Budget设置、角色预测与回滚（Prediction & Rollback）优化、Interest Overlap计算，避免Bandwidth超限导致的玩家卡顿与输入延迟。"
category: development
risk: critical
---

# 网络性能优化（UE5.6）

## 概述

本技能提供UE5.6网络系统（Netcode）性能优化的标准化流程，覆盖Replication Graph配置与调优、Bandwidth Budget分配、角色预测回滚（Prediction & Rollback）机制、Interest Overlap计算与优化。确保在多人在线游戏（MMO/MOBA/TPS）中实现低延迟、高吞吐、稳定的网络通信。

## 何时使用此技能

- 当用户需要优化Replication Graph以减少网络流量时使用
- 当Bandwidth超限导致玩家卡顿或输入延迟时使用
- 当角色预测回滚（Prediction & Rollback）导致动画抖动时使用
- 当Interest Overlap计算导致服务器CPU峰值时使用
- 当用户提到 `ReplicationGraph`, `BandwidthBudget`, `Prediction`, `Rollback`, `Interest`, `NetCullDistanceSquared` 等关键词时使用

## 示例

### 示例 1：Replication Graph配置（C++）

```cpp
// MyRepGraph.h
UCLASS()
class MYPROJECT_API UMyRepGraph : public UReplicationGraph
{
    GENERATED_BODY()
public:
    virtual void InitGraph(UWorld* InWorld, UReplicationDriver* InDriver) override;
    virtual void GatherActorListsForConnection(const FConnectionGatherActorListsParameters& Params) override;
};

// MyRepGraph.cpp
void UMyRepGraph::InitGraph(UWorld* InWorld, UReplicationDriver* InDriver)
{
    Super::InitGraph(InWorld, InDriver);
    
    // 创建Replication Nodes
    AlwaysRelevantForPlayerNode = NewObject<UMyAlwaysRelevantNode>(this);
    AlwaysRelevantForPlayerNode->Init(this);
    
    DistanceBasedNode = NewObject<UMyDistanceBasedNode>(this);
    DistanceBasedNode->Init(this);
}

void UMyRepGraph::GatherActorListsForConnection(const FConnectionGatherActorListsParameters& Params)
{
    // 受益玩家的AlwaysRelevant Actors
    Params.OutAlwaysRelevant.AddArray(AlwaysRelevantActors);
    
    // 基于距离的Actor
    for (AActor* Actor : ReplicatedActors)
    {
        if (FMath::Square(Params.Connection->PlayerController->GetDistanceTo(Actor)) < NetCullDistanceSquared)
        {
            Params.OutAlwaysRelevant.Add(Actor);
        }
    }
}
```

### 示例 2：Bandwidth Budget配置（`DefaultEngine.ini`）

```ini
[/Script/Engine.NetworkSettings]
n.BufferSize=1048576
n.MaxBandwidth=100000
n.MaxClientBandwidth=50000
n.ConnectionTimeout=10.0
n.InitialConnectTimeout=30.0

[/Script/Engine.NetDriver]
NetConnectionClass=/Script/EnginepNetConnection
NetClientConnectionClass=/Script/EnginepNetClientConnection
NetServerConnectionClass=/Script/EnginepNetServerConnection
```

### 示例 3：角色预测回滚优化（C++）

```cpp
// MyCharacter.h
class AMyCharacter : public ACharacter
{
    UPROPERTY(ReplicatedUsing=OnRep_ServerPosition)
    FVector ServerPosition;
    
    UPROPERTY()
    FTimerHandle PredictionRollbackHandle;
    
    virtual void Tick(float DeltaTime) override;
    void OnRep_ServerPosition();
};

// MyCharacter.cpp
void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    // Prediction（本地预测）
    if (Role == ROLE_AutonomousProxy)
    {
        FVector PredictedLocation = GetActorLocation() + GetVelocity() * DeltaTime;
        ServerPosition = PredictedLocation;
    }
    
    // Rollback（服务器回滚）
    if (Role == ROLE_Authority)
    {
        // 保存当前状态
        FTransform SavedTransform = GetActorTransform();
        
        // 回滚到客户端报告的State
        SetActorTransform(ClientState.Transform);
        
        // 重放客户端输入
        for (FInputState& Input : ClientState.InputBuffer)
        {
            ExecuteInput(Input);
        }
        
        // 比较最终状态，计算Rollback误差
        float RollbackError = (GetActorLocation() - SavedTransform.GetLocation()).SizeSquared();
        
        // 如果误差过大（≥ 100cm），丢弃当前帧
        if (RollbackError > 10000.0f)
        {
            SetActorTransform(SavedTransform);
        }
    }
}

void AMyCharacter::OnRep_ServerPosition()
{
    // 插值回滚（可选：使用AnimBP的Rollback动画）
    if (RollbackAnimationCurve)
    {
        PlayRate = 2.0f; // 加速回放
    }
}
```

### 示例 4：Interest Overlap计算优化（`DefaultEngine.ini`）

```ini
[/Script/Engine.NetDriver]
NetServerMaxTickRate=60
NetClientMaxTickRate=60
MaxNetTickRate=120

[/Script/Engine.WorldSettings]
NetPerformance=0.8
NetCullDistanceSquared=9000000.0
NetDormancy=NETDORM_DormantAll
```

## 最佳实践

- ✅ Replication Graph的 `AlwaysRelevant` Actors应仅包含核心游戏对象（如PlayerController、GameMode）
- ✅ Bandwidth Budget的 `MaxBandwidth` 应 ≤ 客户端上行带宽 × 0.8（冗余因子）
- ✅ 预测回滚的 `RollbackError` 阈值应 ≥ 50cm（避免动画抖动）
- ✅ Interest Overlap计算频率应 ≤ 10 Hz（避免服务器CPU过载）
- ✅ 每帧Replication的Actors数量 ≤ 500（避免网络拥塞）

## 限制和注意事项

- ❌ Replication Graph不支持 `NetDormancy`（必须使用 `Dormant` 属性替代）
- ❌ Bandwidth Budget无法动态调整（必须重启服务器或手动调用 `SetMaxBandwidth()`）
- ❌ 预测回滚会导致输入延迟增加（建议仅用于关键 gameplay对象，如Player Character）
- ❌ Interest Overlap计算在高密度场景下（≥ 1000 players）可能导致服务器OOM
- ❌ `ReplicatedUsing` 无法触发 `OnRep_XXX`（必须显式调用 `MarkNetDirty()`）
- ❌ 高频Rollback（≥ 5次/秒）会导致动画同步失败（建议使用 `Interpolation` 替代）
