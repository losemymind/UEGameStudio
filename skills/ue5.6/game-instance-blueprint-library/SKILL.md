# UGameInstanceBlueprintLibrary — UE 5.6 蓝图游戏实例函数库

## 概述

`UGameInstanceBlueprintLibrary` 是 Unreal Engine 5.6 中的蓝图可调用函数库，用于访问和操作游戏实例（GameInstance）的核心功能。此类继承自 `UBlueprintFunctionLibrary`，所有函数均为静态蓝图可调用函数。

**头文件**: `Engine/Source/Runtime/Engine/Classes/Kismet/GameInstanceBlueprintLibrary.h`  
**模块**: Engine  
**蓝图可调用**: 是  
**蓝图纯函数**: 部分  

---

## 函数列表统计

**当前版本函数数量**: 0 个 UFUNCTION

> **注意**: UE 5.6 的 `UGameInstanceBlueprintLibrary` 当前为空实现，未包含任何蓝图可调用函数。所有游戏实例相关功能应通过 `UGameInstance` 类的实例方法或 `UGameplayStatics` 提供的静态方法访问。

---

## 函数参考

### 无可用函数

当前版本暂无可用函数。建议使用以下替代方案：

| 功能需求 | 推荐替代 |
|---------|---------|
| 获取本地玩家 | `UGameplayStatics::GetLocalPlayerController()` |
| 获取世界 | `UGameplayStatics::GetWorld()` |
| 获取游戏状态 | `UGameplayStatics::GetGameState()` |
| 游戏实例操作 | 直接访问 `UGameInstance` 实例 |

---

## 使用示例

### 示例 1：获取本地玩家控制器

```blueprint
// 蓝图中调用
UGameplayStatics::GetLocalPlayerController(WorldContextObject, PlayerIndex)
```

### 示例 2：获取当前游戏世界

```blueprint
// 蓝图中调用
UGameplayStatics::GetWorld()
```

---

## 注意事项

1. **类状态**: `UGameInstanceBlueprintLibrary` 在 UE 5.6 中为空实现
2. **向后兼容**: 建议使用 `UGameplayStatics` 作为主要的游戏实例访问方式
3. **未来版本**: 未来版本可能会在此类中添加新函数，请关注官方更新说明

---

## 参考链接

- [UE 5.6 官方文档](https://docs.unrealengine.com/5.6/)
- [UGameInstance 类参考](https://docs.unrealengine.com/5.6/en-US/API/Runtime/Engine/Engine/UGameInstance/)
- [UGameplayStatics 类参考](https://docs.unrealengine.com/5.6/en-US/API/Runtime/Engine/Kismet/UGameplayStatics/)

---

*本文档基于 Unreal Engine 5.6 公开文档及源码分析生成，最后更新于 2026-09-09*
