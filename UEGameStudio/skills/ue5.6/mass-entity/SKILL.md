---
name: mass-entity
description: "当用户提到UE5.6 Mass Entity、Actor Distributor、Entity Descriptor或Mass与Gameplay Actor集成时使用。UE5.6 Mass Entity系统技能：指导Mass Architecture设计、Actor Distributor映射、Entity Descriptor配置与Cook流程，避免Mass数据未Cook导致的运行时崩溃。"
category: development
risk: critical
---

# Mass Entity系统（UE5.6）

## 概述

本技能提供UE5.6 Mass Entity架构的标准化实施流程，覆盖Mass核心概念（Actor Distributor、Entity Descriptor、Cooker）、Mass与Gameplay Actor集成、以及运行时数据一致性保障。基于ECS（Entity Component System）模式，大幅提升大批量实体（≥ 10,000）的更新性能与内存效率。

## 何时使用此技能

- 当用户需要将传统Actor迁移到Mass Entity时使用
- 当出现运行时崩溃 `Mass has not been cooked` 或 `Missing Entity Descriptor` 时使用
- 当需要配置Actor Distributor映射到Mass Data时使用
- 当需要优化大量实体（如敌人/粒子/ foliage）的 update performance 时使用
- 当用户提到 `MassActor`, `MassEntity`, `ActorDistributor`, `EntityDescriptor`, `MassCook` 等关键词时使用

## 示例

### 示例 1：Actor Distributor配置（C++）

```cpp
// MyDistributor.h
UCLASS()
class MYPROJECT_API UMyDistributor : public UMassActorDistributor
{
    GENERATED_BODY()
public:
    virtual void Initialize(UWorld* World) override;
    virtual void ConfigureQueries() override;
};

// MyDistributor.cpp
void UMyDistributor::Initialize(UWorld* World)
{
    Super::Initialize(World);
    
    FMassEntityQuery& Query = ConfigureQuery();
    Query.AddRequirement<FMyComponent>(EMassFragmentAccess::ReadWrite);
    Query.AddRequirement<FTransformFragment>(EMassFragmentAccess::ReadWrite);
}

// 注册Distributor（在Module.cpp中）
UMassEntitySystem* EntitySystem = GetEditorWorld()->GetEntitySystem();
EntitySystem->RegisterDistributor<UMyDistributor>();
```

### 示例 2：Entity Descriptor定义（Data Asset）

```uasset
// EntityDescriptor_UObject.uasset
ObjectVersion=4
EntityDescriptor=(
    Components=(
        (Name="MyProject.MyComponent",Type=EMassDataType::Static),
        (Name="MassRepresentationSubsystem.StaticMeshInstanceData",Type=EMassDataType::Shared)
    ),
    Tags=("MyTag",),
    bIsEnabled=True
)
```

### 示例 3：Cook Mass数据（命令行）

```bash
# 在 UE Editor 中通过Project Settings > Packaging 勾选 "Cook Mass Data"
# 或通过命令行手动Cook：
"C:\Program Files\Epic Games\UE_5.6\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" "YourProject.uproject" ^
  -run=Cook -project="YourProject.uproject" ^
  -platform=PC -cookall -unattended -nocompile -nosign -abslog=CookLog.txt
```

### 示例 4：Mass与Gameplay Actor混合集成（Blueprint）

```blueprint
Event BeginPlay
├── Create Mass Entity from Descriptor
│   └── EntityDescriptor: /Game/MyProject/EntityDescriptors/MyEntityDescriptor.MyEntityDescriptor
├── Spawn Mass Actor
│   └── ActorClass: MyMassActor_BP
│   └── Location: Get Actor Location
│   └── Rotation: Get Actor Rotation
└── Bind Mass Data to Actor
    └── MassActorDistributor: MyDistributor
    └── ComponentName: "MyComponent"
```

## 最佳实践

- ✅ 每个Actor类必须对应唯一Actor Distributor（避免多Distributor竞争同一Actor）
- ✅ Entity Descriptor必须在 `Editor Settings > Plugins > Mass > Entity Descriptors` 中注册
- ✅ Cook前运行 `Window > Developer Tools > Mass > Validate Mass Data` 检查数据完整性
- ✅ 运行时动态Spawn Mass Actor前，确保 `MassRepresentationSubsystem` 已初始化
- ✅ 大量Entity更新时，使用 `FMassEntityQuery::ForEachEntityChunk` 分批处理（避免单Frame过载）

## 限制和注意事项

- ❌ Mass Entity不支持 `Tick` 函数（需改用 `FMassEntityTask`）
- ❌ Actor Distributor无法直接映射带有 `UMG Widget` 的Actor
- ❌ Mass Cooked数据无法热重载（变更后必须重新Cook）
- ❌ `MassActor` 子类不能直接继承 `AActor`（需使用 `UMassEntityTemplate`）
- ❌ Entity Descriptor中 `Tags` 字段是大小写敏感的（`"mytag"` ≠ `"MyTag"`）
- ❌ 运行时缺少Mass Cooked数据会导致 `FError::Throw`（必须提前检查 `MassEntitySubsystem->IsCooked()`）
