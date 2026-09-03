---
name: input-device-subsystem
description: UInputDeviceSubsystem（UE 5.6）输入设备属性与设备查询 - 激活/查询/移除输入设备属性、查询用户最近使用的硬件设备与其标识；在 Agent 需要通过 unreal Python 查询输入设备状态或激活设备属性（力反馈/触觉等）时使用
tags: [ue5.6, input, device, haptics, python, subsystem]
---

# InputDeviceSubsystem - 输入设备属性与设备查询（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UInputDeviceSubsystem` 暴露给 Python 的运行时输入设备能力。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/GameFramework/InputDeviceSubsystem.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的成员整理。C++ 函数未声明 `ScriptMethod` meta，Python 方法名按 C++ 函数名转 snake_case；精确 Python 暴露名需实测确认。

## 入口说明

`UInputDeviceSubsystem` 派生自 `UEngineSubsystem`（全局引擎子系统）。从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_engine_subsystem(unreal.InputDeviceSubsystem)
```

- 返回 `None` 表示子系统不可用，按 `BLOCKED_TOOLING` 处理并停止；项目需启用 `InputSettings` 的 `bEnableInputDeviceSubsystem` 标志，否则子系统不创建。
- 用户与设备使用 `unreal.PlatformUserId` / `unreal.InputDeviceId`；属性句柄为 `unreal.InputDevicePropertyHandle`，硬件标识为 `unreal.HardwareDeviceIdentifier`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 激活 | `activate_device_property_of_class(property_class, params=...)` | `FInputDevicePropertyHandle ActivateDevicePropertyOfClass(TSubclassOf<UInputDeviceProperty>, const FActivateDevicePropertyParams&)` | `InputDevicePropertyHandle` |
| 查询 | `get_active_device_property(handle)` | `UInputDeviceProperty* GetActiveDeviceProperty(const FInputDevicePropertyHandle) const` | `InputDeviceProperty` 或 `None` |
| 查询 | `is_property_active(handle)` | `bool IsPropertyActive(const FInputDevicePropertyHandle) const` | `bool` |
| 移除 | `remove_device_property_by_handle(handle_to_remove)` | `void RemoveDevicePropertyByHandle(const FInputDevicePropertyHandle)` | `None` |
| 移除 | `remove_device_property_handles(handles_to_remove)` | `void RemoveDevicePropertyHandles(const TSet<FInputDevicePropertyHandle>&)` | `None` |
| 移除 | `remove_all_device_properties()` | `void RemoveAllDeviceProperties()` | `None` |
| 设备查询 | `get_most_recently_used_hardware_device(in_user_id)` | `FHardwareDeviceIdentifier GetMostRecentlyUsedHardwareDevice(const FPlatformUserId) const` | `HardwareDeviceIdentifier` |
| 设备查询 | `get_most_recently_used_input_device_id(in_user_id, of_type=...)` | `FInputDeviceId GetMostRecentlyUsedInputDeviceId(const FPlatformUserId, const EHardwareDevicePrimaryType)` | `InputDeviceId` |
| 设备查询 | `get_input_device_hardware_identifier(input_device)` | `FHardwareDeviceIdentifier GetInputDeviceHardwareIdentifier(const FInputDeviceId) const` | `HardwareDeviceIdentifier` |

## 快速示例

```python
import unreal

api = unreal.get_engine_subsystem(unreal.InputDeviceSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: InputDeviceSubsystem 不可用")

# 查询某个平台用户最近使用的设备
users = unreal.Platforms.get_platform_user_id_from_index(0)
device_id = api.get_most_recently_used_input_device_id(users)
print("latest device:", device_id)

if device_id != unreal.InputDeviceId.INPUTDEVICE_ID_NONE():
    hw_id = api.get_input_device_hardware_identifier(device_id)
    print("hardware:", hw_id)

# 激活一个默认力反馈属性类
props_class = unreal.load_class("/Script/Engine.InputDeviceProperty")
handle = api.activate_device_property_of_class(props_class)
if api.is_property_active(handle):
    api.remove_device_property_by_handle(handle)
```

## 注意事项

- 本 skill 只提供 Python 调用 API；输入能力归属与具体 Gameplay 输入层所有权在 ue-gameplay-engineer，本 skill 不越界实现输入逻辑。
- 激活/移除属于运行时设备交互，不修改任何项目资产。
- 用户无已知设备时 `get_most_recently_used_input_device_id` 返回 `INPUTDEVICE_ID_NONE`。
- 需要 PIE/运行时输入上下文才能体现效果；纯编辑器无活跃平台用户/输入设备上下文时按 `BLOCKED_TOOLING` 处理。
- 缺必要输入（用户 ID、设备 ID、属性类）时返回 `BLOCKED_INPUT`；子系统不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。