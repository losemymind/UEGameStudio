---
name: reflection-mixer-blueprint-library
description: UReflectionMixerBlueprintLibrary（UE 5.6）反射混音器函数库 - 音频反射路径查询与混音设置；在 Agent 需要通过 unreal Python 查询或控制音频反射混音时使用
risk: safe
category: development
tags: [ue5.6, audio, reflection, blueprint-library, python]
---

# ReflectionMixerBlueprintLibrary - Reflection Mixer Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 查询或控制音频反射混音时使用本 skill（description 触发场景）。
- 本 skill 只在与 reflection-mixer-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UReflectionMixerBlueprintLibrary` 暴露给 Python 的反射混音器工具方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/ReflectionMixerBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.ReflectionMixerBlueprintLibrary` 上：

```python
import unreal

api = unreal.ReflectionMixerBlueprintLibrary

# 获取反射混音器
reflection_mixer = api.get_reflection_mixer()
if reflection_mixer:
    print("reflection mixer:", reflection_mixer.get_name())
```

- **命名约定**：Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无该 meta 的按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- **音频模块依赖**：本库功能依赖音频模块与音轨反射混音器配置；音频系统未启用时返回 `None`。
- **运行时 Only**：本库方法主要在 PIE/运行时可用；编辑器非运行模式下调用可能返回 `None` 或失败。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 运行时 | `get_reflection_mixer()` | `UReflectionMixer* GetReflectionMixer()` | `ReflectionMixer` 或 `None` |
| 运行时 | `is_reflection_mixer_enabled()` | `bool IsReflectionMixerEnabled()` | `bool` |
| 运行时 | `set_reflection_mixer_enabled(b_enabled)` | `void SetReflectionMixerEnabled(bool)` | `None` |
| 运行时 | `set_reflection_mixer_distance(distance_cm)` | `void SetReflectionMixerDistance(float)` | `None` |
| 运行时 | `set_reflection_mixer_order(order)` | `void SetReflectionMixerOrder(int32)` | `None` |
| 运行时 | `get_reflection_mixer_distance()` | `float GetReflectionMixerDistance()` | `float` |
| 运行时 | `get_reflection_mixer_order()` | `int32 GetReflectionMixerOrder()` | `int` |

## 示例

```python
import unreal

api = unreal.ReflectionMixerBlueprintLibrary

# 检查混音器状态
enabled = api.is_reflection_mixer_enabled()
print("enabled:", enabled)

if not enabled:
    api.set_reflection_mixer_enabled(True)

# 设置混音器属性
api.set_reflection_mixer_distance(500.0)  # 5米
api.set_reflection_mixer_order(3)

# 读取当前设置
distance = api.get_reflection_mixer_distance()
order = api.get_reflection_mixer_order()
print({"distance_cm": distance, "order": order})
```

## 限制和注意事项

- 本库方法主要在 PIE/运行时上下文可用；编辑器静态脚本调用时返回 `None` 或失败，按 `BLOCKED_TOOLING` 处理。
- `get_reflection_mixer()` 获取当前音频世界中的反射混音器实例；音频系统未初始化时返回 `None`。
- `set_reflection_mixer_distance` 参数单位为厘米（cm）；默认距离与顺序依据项目音频配置。
- 修改混音器设置后需等待音频系统更新；实时影响范围受音频环境与距离衰减规则约束。
- 缺世界/音频上下文返回 `BLOCKED_TOOLING`；参数无效（负距离、负顺序）按 `BLOCKED_INPUT` 处理。
- 本库为运行时音频查询与设置工具，不修改静态资产或项目配置。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
