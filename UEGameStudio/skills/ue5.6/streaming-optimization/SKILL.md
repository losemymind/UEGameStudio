---
name: streaming-optimization
description: "当用户提到UE5.6关卡流送、异步加载、Texture Streaming或内存池设计时使用。UE5.6流送与内存优化技能：指导关卡流送策略、异步加载Actor配置、Texture Streaming预算分配与自定义内存池设计，避免内存泄漏导致OOM。"
category: development
risk: critical
---

# 流送与内存优化（UE5.6）

## 概述

本技能提供UE5.6流送（Streaming）与内存管理优化的标准化流程，覆盖关卡流送（Level Streaming）、异步加载（Async Loading）、Texture Streaming配置与内存池（Memory Pool）设计。确保在大型开放世界项目中保持稳定帧率、流畅加载体验与可控内存占用。

## 何时使用此技能

- 当用户需要配置关卡流送（Level Streaming）以避免卡顿时使用
- 当异步加载Actor导致加载时间过长时使用
- 当Texture Streaming导致画面模糊或闪烁时使用
- 当内存池泄漏导致OOM（Out of Memory）时使用
- 当用户提到 `LevelStreaming`, `AsyncLoad`, `TextureStreaming`, `MemoryPool`, `StreamIn`, `StreamOut` 等关键词时使用

## 示例

### 示例 1：关卡流送配置（UMG地图加载器蓝图）

```blueprint
Event BeginPlay
├── Create Streaming Level
│   └── PackageName: "Level_02"
│   └── bShouldBeVisible: False
│   └── bShouldBeLoaded: False
└── StreamIn Level
    ├── StreamingLevel: Level_02
    ├── TimeoutInSeconds: 5.0
    └── OnStreamInCompleted:
        ├── Set Level Visible: True
        └── Play Loading Animation: False
```

### 示例 2：异步加载Actor配置（C++）

```cpp
// MyAsyncLoader.h
UCLASS()
class MYPROJECT_API UMyAsyncLoader : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    void LoadActorAsync(FString ActorPath, F_onActorLoaded OnLoaded);
    
private:
    FAsyncLoadHandle AsyncLoadHandle;
    void OnAsyncLoadComplete(FAsyncLoadHandle Handle);
};

// MyAsyncLoader.cpp
void UMyAsyncLoader::LoadActorAsync(FString ActorPath, F_onActorLoaded OnLoaded)
{
    FStreamableManager Streamable;
    Streamable.AsyncLoad(ActorPath, [&](TWeakObjectPtr<UObject> LoadedObject)
    {
        if (LoadedObject.IsValid())
        {
            OnLoaded.Broadcast(LoadedObject);
        }
    }, FStreamableManager::FStreamableDelegate(), false, -1, "");
}

void UMyAsyncLoader::OnAsyncLoadComplete(FAsyncLoadHandle Handle)
{
    // 处理加载完成后的Actor Spawn逻辑
    FGlobalLoadedObjectList::HandleAsyncLoading();
}
```

### 示例 3：Texture Streaming预算配置（`DefaultEngine.ini`）

```ini
[/Script/Engine.TextureStreaming]
bEnableTextureStreaming=True
MaxAnisotropy=8
MinTextureRes=256
MaxTextureRes=4096
MinLOD=0
MaxLOD=5
LODBias=0
TextureGroup=Mobile
StreamingCoordChannel=0
MaxStreamingTextureSize=2048
```

### 示例 4：内存池设计（C++模板）

```cpp
// MemoryPool.h
template<typename T>
class TMemoryPool
{
public:
    TMemoryPool(int32 InitialCapacity = 64)
        : Pool(MaxCapacity), AvailableIndices(InitialCapacity), NextIndex(0)
    {
        Pool.SetNumUninitialized(InitialCapacity);
        for (int32 i = 0; i < InitialCapacity; ++i)
        {
            AvailableIndices.Emplace(i);
        }
    }
    
    T* Allocate()
    {
        if (AvailableIndices.IsEmpty())
        {
            ExpandPool(Pool.Num() * 2);
        }
        
        int32 Index = AvailableIndices.Pop();
        return &Pool[Index];
    }
    
    void Release(T* Item)
    {
        int32 Index = Item - Pool.GetData();
        check(Index >= 0 && Index < Pool.Num());
        AvailableIndices.Emplace(Index);
    }

private:
    void ExpandPool(int32 NewCapacity)
    {
        int32 OldCapacity = Pool.Num();
        Pool.SetNumUninitialized(NewCapacity);
        for (int32 i = OldCapacity; i < NewCapacity; ++i)
        {
            AvailableIndices.Emplace(i);
        }
    }
    
    TArray<T> Pool;
    TArray<int32> AvailableIndices;
    int32 NextIndex;
    const int32 MaxCapacity = 65536;
};
```

## 最佳实践

- ✅ 关卡流送的 `StreamingDistance` 应基于 gameplay需求（开放世界 ≥ 5000，竞速游戏 ≥ 8000）
- ✅ 异步加载Actor的 `TimeoutInSeconds` 应 ≤ 30秒（避免玩家无限等待）
- ✅ Texture Streaming的 `MaxStreamingTextureSize` 应 ≤ 显存带宽限制（PC ≥ 2048，移动端 ≥ 1024）
- ✅ 内存池的 `MaxCapacity` 应 ≥ 场景最大对象数 × 1.5（冗余因子）
- ✅ 每帧StreamIn/StreamOut的关卡数量 ≤ 3（避免帧率抖动）

## 限制和注意事项

- ❌ 关卡流送无法跨World实例（必须在同一World中加载）
- ❌ 异步加载的Actor无法在 `BeginPlay` 前访问（需等待 `OnActorLoaded` 回调）
- ❌ Texture Streaming不支持 `Decal` 类型的Texture（必须手动管理Decal流送）
- ❌ 内存池未调用 `Release()` 会导致内存泄漏（务必在 `OnComponentDestroyed` 中释放）
- ❌ Texture Group设置为 `TG__Default` 的贴图不会被Streaming管理（必须显式指定）
- ❌ 内存池的 `ExpandPool()` 是线程不安全的（多线程场景需加锁保护）
