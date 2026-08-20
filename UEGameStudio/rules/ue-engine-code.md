# ue-engine-code — 引擎代码路径规则

> 路径作用域：`Source/<GameModule>/Core/**`（如 `Source/MyGame/Core/`，游戏内引擎级/核心子系统）。该路径下所有代码自动受此规则约束。

## 强制要点

- **热路径零分配**：每帧执行路径不得做堆分配（用缓存/对象池/栈变量）。
- API 线程安全需显式声明与保证。
- **引擎绝不依赖 gameplay**：core 层不得反向引用 gameplay 类型。
- API 变更需要弃用期（`UE_DEPRECATED`），不得直接删除公开接口。

## 反例（违规信号）

- Tick 内 `NewObject` / `TArray::Add` 无预留导致反复分配。
- core 模块 `#include` gameplay 头文件。
- 公开 API 破坏性变更未标记弃用期。

## 来源

业界游戏工作室路径作用域编码规则。
