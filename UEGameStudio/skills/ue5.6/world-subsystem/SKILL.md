---
name: world-subsystem
description: UWorldSubsystem（UE 5.6）基类 - 共享 UWorld 生命周期、按世界隔离的数据与服务子系统获取模式；在 Agent 需要通过 unreal Python 获取/调用 World 生命周期子系统时使用
tags: [ue5.6, subsystem, world, python, base-class]
---

# WorldSubsystem - 获取与调用模式（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UWorldSubsystem` 这一类**基类**的获取模式与调用约定。`UWorldSubsystem` 是自动实例化、随 UWorld 生命周期存活的子系统基类，声明为 `UCLASS(Abstract)`；其头文件 `Engine/Source/Runtime/Engine/Public/Subsystems/WorldSubsystem.h` 仅声明构造函数、`GetWorld()` 等非 `UFUNCTION` 成员与若干生命周期虚函数，不暴露任何 Python 可直接调用的业务方法。本 skill 记录的是**如何从 Python 定位并获取这类子系统的通用模式**，以及获取后调用其子类暴露方法的通则。

## 基座说明

- 生命周期：实例随所属 UWorld 创建与销毁，数据仅存在于该世界内；世界销毁即销毁，换关卡/换世界必须重新获取。
- 按世界隔离：每个 UWorld 独立持有子系统实例，编辑器主世界与 PIE 世界不是同一个实例源。
- Python 类名去掉 U 前缀，`UWorldSubsystem` 对应 `unreal.WorldSubsystem`；基类本身是抽象基类，直接获取通常返回 `None`，获取目标永远是具体子类实例。

## 入口说明

从 UE Python 获取一个 World 子系统实例：

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
subsystem = world.get_subsystem(unreal.YourWorldSubsystem)
```

- 世界来源二选一：编辑器主世界用 `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()`；PIE/运行时世界传入对应运行的 `UWorld`。
- `world` 为 `None`（编辑器上下文不可用或世界未就绪）时按 `BLOCKED_TOOLING` 处理并停止。
- `unreal.YourWorldSubsystem` 填写**实际游戏项目的子系统子类名**（去 U 前缀的反射类）。
- `get_subsystem()` 找不到对应实例时返回 `None`，按阻塞规则处理。

## 可用入口

| 类别 | Python 形式 | 说明 |
| --- | --- | --- |
| 获取编辑器世界 | `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()` | 编辑器主世界对象 |
| 获取 PIE/运行时世界 | 从 PIE 会话或运行时传入对应 `UWorld` | 不同世界各自持有独立子系统集合 |
| 获取实例 | `world.get_subsystem(unreal.<Subclass>)` | 该世界生命周期内按类名取实例，无则 `None` |
| 生命周期 | 实例随所属 UWorld 创建/销毁 | 世界销毁即销毁，数据仅存在于该世界 |
| 调用子类方法 | 获取实例后调用其 BlueprintCallable / BlueprintPure 成员 | Python 方法名按反射约定转 snake_case；以目标 5.6 编辑器对真实子类 `dir()` 实测为准 |

## 快速示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    print("BLOCKED_TOOLING: 编辑器主世界不可用")
else:
    svc = world.get_subsystem(unreal.YourWorldSubsystem)
    if svc is None:
        print("BLOCKED_INPUT: 目标子系统未注册/未实例化")
    else:
        print("subsystem:", svc.get_class().get_name())
```

## 完整端到端示例

```python
import unreal

def main():
    ubs = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
    if ubs is None:
        print({"status": "BLOCKED_TOOLING", "reason": "编辑器子系统上下文不可用"})
        return

    world = ubs.get_editor_world()
    if world is None:
        print({"status": "BLOCKED_TOOLING", "reason": "编辑器主世界不可用"})
        return

    svc = world.get_subsystem(unreal.YourWorldSubsystem)
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
- 按世界隔离：每个 `UWorld` 独立持有子系统实例，改世界/换关卡需重新获取；PIE 世界与编辑器主世界不是同一个实例源。
- 缺少世界 / 目标子系统上下文时分别返回 `BLOCKED_TOOLING` / `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：目标子系统类名错误、未注册、未实例化，或缺少必要的类路径/输入。
- `BLOCKED_TOOLING`：编辑器世界不可用、编辑器子系统上下文不可用、PIE/运行时环境未在运行而无法取得世界。
- 本 skill 只记录 Python 可获取的入口与基类约定；具体业务方法不在本 skill 中断言，必须以目标 5.6 编辑器对真实子类 `dir()` 实测为准，未实测前不得声称已验证。

本 SKILL.md 完整收录子系统的获取模式与基座说明，即完整参考。