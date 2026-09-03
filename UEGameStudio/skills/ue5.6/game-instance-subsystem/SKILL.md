---
name: game-instance-subsystem
description: UGameInstanceSubsystem（UE 5.6）基类 - 共享 GameInstance 生命周期、跨关卡持久数据与常驻服务的子系统获取模式；在 Agent 需要通过 unreal Python 获取/调用 GameInstance 生命周期子系统时使用
tags: [ue5.6, subsystem, game-instance, python, base-class]
---

# GameInstanceSubsystem - 获取与调用模式（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UGameInstanceSubsystem` 这一类**基类**的获取模式与调用约定。`UGameInstanceSubsystem` 是自动实例化、随 GameInstance 生命周期存活的子系统基类，声明为 `UCLASS(Abstract, Within = GameInstance)`；其头文件 `Engine/Source/Runtime/Engine/Public/Subsystems/GameInstanceSubsystem.h` 仅声明构造函数与 `GetGameInstance()`（非 `UFUNCTION`），不暴露任何 Python 可直接调用的业务方法。本 skill 记录的是**如何从 Python 定位并获取这类子系统的通用模式**，以及获取后调用其子类暴露方法的通则。

## 基座说明

- 生命周期：实例随 GameInstance 创建与销毁，跨关卡持久，不依赖具体关卡加载；PIE/运行时会话结束即销毁。
- `Within = GameInstance`：每个 GameInstance 至多一个实例，实例由引擎自动创建与初始化，脚本只负责获取。
- Python 类名去掉 U 前缀，`UGameInstanceSubsystem` 对应 `unreal.GameInstanceSubsystem`；基类本身是抽象基类，直接获取通常返回 `None`，获取目标永远是具体子类实例。

## 入口说明

从 UE Python 获取一个 GameInstance 子系统实例：

```python
import unreal

subsystem = unreal.get_game_instance().get_subsystem(unreal.YourGameInstanceSubsystem)
```

- `unreal.get_game_instance()` 获取当前 GameInstance；脚本上下文不可用（PIE 未运行、无游戏会话）时返回 `None`，按 `BLOCKED_TOOLING` 处理并停止。
- `unreal.YourGameInstanceSubsystem` 填写**实际游戏项目的子系统子类名**（去 U 前缀的反射类）。
- `get_subsystem()` 找不到对应实例时返回 `None`，按阻塞规则处理。

## 可用入口

| 类别 | Python 形式 | 说明 |
| --- | --- | --- |
| 获取实例 | `unreal.get_game_instance().get_subsystem(unreal.<Subclass>)` | 当前 GameInstance 生命周期内按类名取实例，无则 `None` |
| 获取实例（Editor 上下文） | `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_game_instance()` → `.get_subsystem(...)` | 编辑器会话中定位 GameInstance 的入口 |
| 生命周期 | 实例随 GameInstance 创建/销毁 | 跨关卡持久，PIE 会话结束即销毁 |
| 调用子类方法 | 获取实例后调用其 BlueprintCallable / BlueprintPure 成员 | Python 方法名按反射约定转 snake_case；以目标 5.6 编辑器对真实子类 `dir()` 实测为准 |

## 快速示例

### 运行时 / PIE 会话

```python
import unreal

gi = unreal.get_game_instance()
if gi is None:
    print("BLOCKED_TOOLING: 无 GameInstance 上下文（PIE/运行时未在运行）")
else:
    svc = gi.get_subsystem(unreal.YourGameInstanceSubsystem)
    if svc is None:
        print("BLOCKED_INPUT: 目标子系统未注册/未实例化")
    else:
        print("subsystem:", svc.get_class().get_name())
```

### 编辑器上下文

编辑器会话中先取得 GameInstance 再取子系统：

```python
import unreal

ubs = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
if ubs is None:
    print("BLOCKED_TOOLING: 编辑器子系统上下文不可用")
else:
    gi = ubs.get_game_instance()
    if gi is None:
        print("BLOCKED_TOOLING: 无 GameInstance 上下文（PIE/运行时未在运行）")
    else:
        svc = gi.get_subsystem(unreal.YourGameInstanceSubsystem)
        if svc is None:
            print("BLOCKED_INPUT: 目标子系统未注册/未实例化")
        else:
            print("subsystem:", svc.get_class().get_name())
```

## 完整端到端示例

```python
import unreal

def main():
    gi = unreal.get_game_instance()
    if gi is None:
        print({"status": "BLOCKED_TOOLING", "reason": "无 GameInstance 上下文（PIE/运行时未在运行）"})
        return

    svc = gi.get_subsystem(unreal.YourGameInstanceSubsystem)
    if svc is None:
        print({"status": "BLOCKED_INPUT", "reason": "目标子系统未注册/未实例化"})
        return

    methods = [m for m in dir(svc) if not m.startswith("_")]
    print({"status": "OK", "subsystem": svc.get_class().get_name(), "methods": methods})

if __name__ == "__main__":
    main()
```

## 注意事项

- 本 skill 记录获取与调用模式，不是业务方法清单：子类的具体 `BlueprintCallable` 方法需在目标 5.6 编辑器对真实子类执行 `dir()` 实测确认后才能断言。
- 编辑器静态脚本模式下不一定存在可用 GameInstance；PIE 或运行时世界开始后才有可用实例。
- 缺少 GameInstance / 目标子系统上下文时分别返回 `BLOCKED_TOOLING` / `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：目标子系统类名错误、未注册、未实例化，或缺少必要的类路径/输入。
- `BLOCKED_TOOLING`：无 GameInstance 上下文（PIE/运行时未在运行）、编辑器脚本上下文不可用而无法解析实例。
- 本 skill 只记录 Python 可获取的入口与基类约定；具体业务方法不在本 skill 中断言，必须以目标 5.6 编辑器对真实子类 `dir()` 实测为准，未实测前不得声称已验证。

本 SKILL.md 完整收录子系统的获取模式与基座说明，即完整参考。