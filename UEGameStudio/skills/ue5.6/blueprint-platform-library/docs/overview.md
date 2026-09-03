# BlueprintPlatformLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintPlatformLibrary.h` 整理 `UBlueprintPlatformLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可经 Python 调用的成员，覆盖该头文件全部 UFUNCTION 成员。Python 类名为 `unreal.BlueprintPlatformLibrary`。Python 方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case；无则按 C++ 函数名转 snake_case（本类头文件全部未声明 `ScriptMethod`，故一律按 C++ 函数名转换）。精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。

## 入口与通用约定

```python
import unreal

api = unreal.BlueprintPlatformLibrary
```

- 本类全部成员为 static UFUNCTION，以类方法形式调用，无需实例化。
- Out/ByRef 参数返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回（返回值在首位）；无 Out 且无返回值则返回 `None`。
- `FDateTime` 参数在 Python 侧为 `unreal.DateTime`，`FText` 为 `unreal.Text`，`FString` 为 `str`。
- 屏幕方向类型为 `unreal.EScreenOrientation`（枚举值如 `UNKNOWN`、`PORTRAIT`、`PORTRAIT_UPSIDE_DOWN`、`LANDSCAPE_LEFT`、`LANDSCAPE_RIGHT`、`FACE_UP`、`FACE_DOWN`、`PORTRAIT_SENSOR`、`LANDSCAPE_SENSOR`、`FULL_SENSOR`，精确枚举名需实测确认）。

## 本地通知

### clear_all_local_notifications

- C++ 签名：`void ClearAllLocalNotifications()`
- Python：`clear_all_local_notifications() -> None`
- 说明：清除全部待发本地通知。通常用于重新调度前（例如应用进入后台时）。
- 示例：

```python
api.clear_all_local_notifications()
```

### schedule_local_notification_at_time

- C++ 签名：`int32 ScheduleLocalNotificationAtTime(const FDateTime& FireDateTime, bool LocalTime, const FText& Title, const FText& Body, const FText& Action, const FString& ActivationEvent)`
- Python：`schedule_local_notification_at_time(fire_date_time, local_time, title, body, action, activation_event) -> int`
- 说明：在指定时间调度本地通知。`local_time=True` 表示本地时区时间，`False` 表示 UTC；`activation_event` 是用户激活通知回调时传入的字符串。返回通知 ID。
- 示例：

```python
fire = unreal.DateTime(2026, 9, 1, 9, 0, 0)
nid = api.schedule_local_notification_at_time(
    fire,
    True,
    title=unreal.Text("提醒"),
    body=unreal.Text("每日产出待确认"),
    action=unreal.Text("查看"),
    activation_event="DailyReminder",
)
print("notification id:", nid)
```

### schedule_local_notification_from_now

- C++ 签名：`int32 ScheduleLocalNotificationFromNow(int32 inSecondsFromNow, const FText& Title, const FText& Body, const FText& Action, const FString& ActivationEvent)`
- Python：`schedule_local_notification_from_now(in_seconds_from_now, title, body, action, activation_event) -> int`
- 说明：从当前时刻起延迟 `in_seconds_from_now` 秒调度本地通知。返回通知 ID。
- 示例：

```python
nid = api.schedule_local_notification_from_now(
    1800,
    title=unreal.Text("维护提醒"),
    body=unreal.Text("服务器将进入维护"),
    action=unreal.Text("查看"),
    activation_event="ServerMaintenance",
)
print("notification id:", nid)
```

### schedule_local_notification_badge_at_time

- C++ 签名：`int32 ScheduleLocalNotificationBadgeAtTime(const FDateTime& FireDateTime, bool LocalTime, const FString& ActivationEvent)`
- Python：`schedule_local_notification_badge_at_time(fire_date_time, local_time, activation_event) -> int`
- 说明：在指定时间调度本地徽章通知。返回通知 ID。
- 示例：

```python
nid = api.schedule_local_notification_badge_at_time(
    unreal.DateTime(2026, 9, 1, 9, 0, 0),
    True,
    activation_event="BadgeDaily",
)
print("badge notification id:", nid)
```

### schedule_local_notification_badge_from_now

- C++ 签名：`void ScheduleLocalNotificationBadgeFromNow(int32 inSecondsFromNow, const FString& ActivationEvent)`
- Python：`schedule_local_notification_badge_from_now(in_seconds_from_now, activation_event) -> None`
- 说明：从当前时刻起延迟 `in_seconds_from_now` 秒调度本地徽章通知。
- 示例：

```python
api.schedule_local_notification_badge_from_now(60, "BadgeCheckIn")
```

### cancel_local_notification

- C++ 签名：`void CancelLocalNotification(const FString& ActivationEvent)`
- Python：`cancel_local_notification(activation_event) -> None`
- 说明：按调度时传入的 `activation_event` 取消本地通知。
- 示例：

```python
api.cancel_local_notification("DailyReminder")
```

### cancel_local_notification_by_id

- C++ 签名：`void CancelLocalNotificationById(int32 NotificationId)`
- Python：`cancel_local_notification_by_id(notification_id) -> None`
- 说明：按调度函数返回的通知 ID 取消本地通知。
- 示例：

```python
nid = api.schedule_local_notification_from_now(
    3600,
    title=unreal.Text("提醒"),
    body=unreal.Text("稍后处理"),
    action=unreal.Text("打开"),
    activation_event="Snooze",
)
api.cancel_local_notification_by_id(nid)
```

### get_launch_notification

- C++ 签名：`void GetLaunchNotification(bool& NotificationLaunchedApp, FString& ActivationEvent, int32& FireDate)`
- Python：`get_launch_notification() -> Tuple[bool, str, int]`
- 说明：返回用于启动应用的通知信息。返回 `(是否由通知启动, 激活事件名, 点火时间)`；应用不是由通知启动时首位为 `False`。
- 示例：

```python
launched, activation_event, fire_date = api.get_launch_notification()
if launched:
    print("launched by notification:", activation_event, fire_date)
else:
    print("app was not launched by a notification")
```

## 屏幕方向

### get_device_orientation

- C++ 签名：`EScreenOrientation::Type GetDeviceOrientation()`
- Python：`get_device_orientation() -> unreal.EScreenOrientation`
- 说明：返回设备当前方向，通常为 `PORTRAIT`、`LANDSCAPE_LEFT`、`PORTRAIT_UPSIDE_DOWN` 或 `LANDSCAPE_RIGHT`。
- 示例：

```python
orientation = api.get_device_orientation()
print("device orientation:", orientation)
```

### get_allowed_device_orientation

- C++ 签名：`EScreenOrientation::Type GetAllowedDeviceOrientation()`
- Python：`get_allowed_device_orientation() -> unreal.EScreenOrientation`
- 说明：返回设备允许的方向。与 `GetDeviceOrientation` 不同：它限定设备可拥有的方向（例如 `LANDSCAPE_SENSOR` 实际限制为 `LANDSCAPE_LEFT` 或 `LANDSCAPE_RIGHT` 之一）。
- 示例：

```python
allowed = api.get_allowed_device_orientation()
print("allowed orientation:", allowed)
```

### set_allowed_device_orientation

- C++ 签名：`void SetAllowedDeviceOrientation(EScreenOrientation::Type NewAllowedDeviceOrientation)`
- Python：`set_allowed_device_orientation(new_allowed_device_orientation) -> None`
- 说明：设置设备允许的方向。
- 示例：

```python
api.set_allowed_device_orientation(unreal.EScreenOrientation.LANDSCAPE_LEFT)
print("allowed now:", api.get_allowed_device_orientation())
```

## 平台事件接收

头文件中的 `UPlatformGameInstance`（`UGameInstance` 子类）以 `UPROPERTY(BlueprintAssignable)` 代理属性暴露应用生命周期与通知事件，包括：

- `ApplicationWillDeactivateDelegate` / `ApplicationHasReactivatedDelegate`
- `ApplicationWillEnterBackgroundDelegate` / `ApplicationHasEnteredForegroundDelegate`
- `ApplicationWillTerminateDelegate` / `ApplicationShouldUnloadResourcesDelegate`
- `ApplicationReceivedStartupArgumentsDelegate`
- `ApplicationRegisteredForRemoteNotificationsDelegate` / `ApplicationRegisteredForUserNotificationsDelegate`
- `ApplicationFailedToRegisterForRemoteNotificationsDelegate`
- `ApplicationReceivedRemoteNotificationDelegate` / `ApplicationReceivedLocalNotificationDelegate`
- `ApplicationReceivedScreenOrientationChangedNotificationDelegate`

这些事件通过游戏实例的代理属性接收，属 BlueprintAssignable 属性而非 UFUNCTION 方法，不在上方函数清单内。具体绑定方式（如以处理函数挂到代理属性）需在目标 5.6 编辑器实测确认。以下为获取游戏实例的示例：

```python
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
game_instance = unreal.GameplayStatics.get_game_instance(world)
print("game instance:", game_instance)
```

## 完整端到端示例

```python
import unreal

def main():
    api = unreal.BlueprintPlatformLibrary

    try:
        api.clear_all_local_notifications()
    except Exception as exc:
        print({"status": "BLOCKED_TOOLING", "reason": "notification service unavailable: %s" % exc})
        return

    nid = api.schedule_local_notification_badge_from_now(1800, "ServerMaintenance")
    api.set_allowed_device_orientation(unreal.EScreenOrientation.LANDSCAPE_LEFT)

    launched, activation_event, fire_date = api.get_launch_notification()

    print({"status": "OK",
           "notification_id": nid,
           "launched_by_notification": launched,
           "device_orientation": str(api.get_device_orientation()),
           "allowed_orientation": str(api.get_allowed_device_orientation())})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（空激活事件、非法时间或方向枚举值等）。
- `BLOCKED_TOOLING`：平台服务不可用（无通知服务、桌面环境不支持、方向锁定不受支持、类库不可用），无法执行。
- 通知调度/取消与屏幕方向设置会对设备产生副作用，必须在目标平台实测确认后才能断言成功；桌面编辑器的空返回不代表移动端行为。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言；精确 Python 暴露名与枚举值名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。
- 本文件覆盖 `BlueprintPlatformLibrary.h` 中全部带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员。