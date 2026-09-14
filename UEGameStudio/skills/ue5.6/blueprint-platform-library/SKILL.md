---
name: blueprint-platform-library
description: UBlueprintPlatformLibrary（UE 5.6）平台与本地通知 Function Library - 设备屏幕方向查询与设置、本地通知调度/取消/启动通知查询；在 Agent 需要从 Python 处理移动平台屏幕方向与本地通知调度时使用
risk: safe
category: development
tags: [ue5.6, python, platform, mobile, notification, function-library]
---

# BlueprintPlatformLibrary - Platform Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要从 Python 处理移动平台屏幕方向与本地通知调度时使用本 skill（description 触发场景）。
- 本 skill 只在与 blueprint-platform-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UBlueprintPlatformLibrary` 暴露给 Python 的平台与本地通知方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintPlatformLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理。

## 入口说明

Python 反射类名为去掉 U 前缀的 `unreal.BlueprintPlatformLibrary`，本类全部成员为 static，以类方法形式直接调用，无需实例化：

```python
import unreal
api = unreal.BlueprintPlatformLibrary

print(api.get_device_orientation())
```

- 命名约定：Python 方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case；无则按 C++ 函数名转 snake_case。本类头文件未声明 `ScriptMethod` 元数据，故全部按 C++ 函数名转换。精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。
- Out/ByRef 参数返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回（返回值在首位）；无 Out 且无返回值则返回 `None`。
- 屏幕方向参数/返回值类型为 BlueprintType 枚举，Python 侧为 `unreal.EScreenOrientation`（值的 Python 名如 `PORTRAIT`、`LANDSCAPE_LEFT` 需实测确认）。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 本地通知 | `clear_all_local_notifications()` | `void ClearAllLocalNotifications()` | `None` |
| 本地通知 | `schedule_local_notification_at_time(fire_date_time, local_time, title, body, action, activation_event)` | `int32 ScheduleLocalNotificationAtTime(const FDateTime&, bool, const FText&, const FText&, const FText&, const FString&)` | `int`（通知 ID） |
| 本地通知 | `schedule_local_notification_from_now(in_seconds_from_now, title, body, action, activation_event)` | `int32 ScheduleLocalNotificationFromNow(int32, const FText&, const FText&, const FText&, const FString&)` | `int`（通知 ID） |
| 本地通知 | `schedule_local_notification_badge_at_time(fire_date_time, local_time, activation_event)` | `int32 ScheduleLocalNotificationBadgeAtTime(const FDateTime&, bool, const FString&)` | `int`（通知 ID） |
| 本地通知 | `schedule_local_notification_badge_from_now(in_seconds_from_now, activation_event)` | `void ScheduleLocalNotificationBadgeFromNow(int32, const FString&)` | `None` |
| 本地通知 | `cancel_local_notification(activation_event)` | `void CancelLocalNotification(const FString&)` | `None` |
| 本地通知 | `cancel_local_notification_by_id(notification_id)` | `void CancelLocalNotificationById(int32)` | `None` |
| 本地通知 | `get_launch_notification()` | `void GetLaunchNotification(bool& NotificationLaunchedApp, FString& ActivationEvent, int32& FireDate)` | `Tuple[bool, str, int]` |
| 屏幕方向 | `get_device_orientation()` | `EScreenOrientation::Type GetDeviceOrientation()` | `unreal.EScreenOrientation` |
| 屏幕方向 | `get_allowed_device_orientation()` | `EScreenOrientation::Type GetAllowedDeviceOrientation()` | `unreal.EScreenOrientation` |
| 屏幕方向 | `set_allowed_device_orientation(new_allowed_device_orientation)` | `void SetAllowedDeviceOrientation(EScreenOrientation::Type NewAllowedDeviceOrientation)` | `None` |

## 示例

```python
import unreal

api = unreal.BlueprintPlatformLibrary

orientation = api.get_device_orientation()
print("device orientation:", orientation)

api.set_allowed_device_orientation(unreal.EScreenOrientation.PORTRAIT)

nid = api.schedule_local_notification_from_now(
    3600,
    title=unreal.Text("副本刷新"),
    body=unreal.Text("每日资源已就绪"),
    action=unreal.Text("查看"),
    activation_event="DailyRefresh",
)
print("notification id:", nid)

api.cancel_local_notification_by_id(nid)

launched, activation_event, fire_date = api.get_launch_notification()
print("launched by notification:", launched)
```

## 限制和注意事项

- 本地通知与屏幕方向多为移动平台能力；在桌面编辑器中行为有限（如通知无实际表现、方向查询受限），不得以桌面空返回断言移动端成功。
- 通知调度/取消与屏幕方向设置属设备副作用，执行后必须在目标平台实测确认；未实测不声称已验证。
- `get_launch_notification` 仅当应用由通知唤起时提供有效信息。
- 缺必要输入（空激活事件、非法时间等）返回 `BLOCKED_INPUT`；平台服务不可用（无通知服务、不支持旋转锁定、库不可用）返回 `BLOCKED_TOOLING`。
- `FDateTime` 参数 Python 侧为 `unreal.DateTime`，`FText` 为 `unreal.Text`，禁止传原生 `datetime` / `str` 冒充。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言；精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。

详细 API 与完整示例见 `docs/overview.md`。