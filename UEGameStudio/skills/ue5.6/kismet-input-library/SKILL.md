---
name: kismet-input-library
description: UKismetInputLibrary（UE 5.6）输入蓝图函数库 - Key/键盘/鼠标/按键轴判定、KeyEvent 与 PointerEvent 读取、修饰键状态、模拟事件导航；在 Agent 需要通过 unreal Python 判断输入键类型或读取键/输入事件信息时使用
tags: [ue5.6, kismet, input, key, python, blueprint-function-library]
---

# KismetInputLibrary - 输入工具（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetInputLibrary` 暴露给 Python 的输入静态工具函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetInputLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case（该库头部无 `meta=(ScriptMethod=...)` 成员）。

## 入口说明

所有函数均为 static，以类方法形式调用：

```python
import unreal
api = unreal.KismetInputLibrary
```

- 无子类示例之外的实例化或编辑器上下文要求；函数为无状态读取/判定工具。库不可用时按 `BLOCKED_TOOLING` 处理。
- 参数类型：`unreal.Key`、`unreal.InputChord`、`unreal.InputEvent`、`unreal.KeyEvent`、`unreal.AnalogInputEvent`、`unreal.PointerEvent`、`unreal.SlateModifierKeysState`。
- Key/输入事件 struct 参数需经对应封装构造函数产生（本库不提供构造入口，全部为读取/判定函数）；构造方式需在目标 UE 5.6 Editor 实测确认。
- 精确暴露名需在目标 UE 5.6 Editor 实测确认。

## 可用操作

### Key 判定

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| Key 判定 | `equal_equal_key_key(a, b)` | `bool EqualEqual_KeyKey(FKey, FKey)` | `bool` |
| Key 判定 | `equal_equal_input_chord_input_chord(a, b)` | `bool EqualEqual_InputChordInputChord(FInputChord, FInputChord)` | `bool` |
| Key 判定 | `key_is_modifier_key(key)` | `bool Key_IsModifierKey(const FKey&)` | `bool` |
| Key 判定 | `key_is_gamepad_key(key)` | `bool Key_IsGamepadKey(const FKey&)` | `bool` |
| Key 判定 | `key_is_mouse_button(key)` | `bool Key_IsMouseButton(const FKey&)` | `bool` |
| Key 判定 | `key_is_keyboard_key(key)` | `bool Key_IsKeyboardKey(const FKey&)` | `bool` |
| Key 判定 | `key_is_axis1d(key)` | `bool Key_IsAxis1D(const FKey&)` | `bool` |
| Key 判定 | `key_is_axis2d(key)` | `bool Key_IsAxis2D(const FKey&)` | `bool` |
| Key 判定 | `key_is_axis3d(key)` | `bool Key_IsAxis3D(const FKey&)` | `bool` |
| Key 判定 | `key_is_button_axis(key)` | `bool Key_IsButtonAxis(const FKey&)` | `bool` |
| Key 判定 | `key_is_analog(key)` | `bool Key_IsAnalog(const FKey&)` | `bool` |
| Key 判定 | `key_is_digital(key)` | `bool Key_IsDigital(const FKey&)` | `bool` |
| Key 判定 | `key_is_valid(key)` | `bool Key_IsValid(const FKey&)` | `bool` |
| Key 查询 | `key_get_navigation_action(in_key)`（Deprecated） | `EUINavigationAction Key_GetNavigationAction(const FKey&)` | `EUINavigationAction` |
| Key 查询 | `key_get_display_name(key, b_long_display_name=True)` | `FText Key_GetDisplayName(const FKey&, bool)` | `Text` |
| Key 查询 | `input_chord_get_display_name(key)` | `FText InputChord_GetDisplayName(const FInputChord&)` | `Text` |
| Key 查询 | `get_modifier_keys_state()` | `FSlateModifierKeysState GetModifierKeysState()` | `SlateModifierKeysState` |

### 事件读取与导航

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| KeyEvent 导航 | `key_get_navigation_action_from_key(in_key_event)` | `EUINavigationAction Key_GetNavigationActionFromKey(const FKeyEvent&)` | `EUINavigationAction` |
| KeyEvent 导航 | `key_get_navigation_direction_from_key(in_key_event)` | `EUINavigation Key_GetNavigationDirectionFromKey(const FKeyEvent&)` | `EUINavigation` |
| AnalogEvent 导航 | `key_get_navigation_direction_from_analog(in_analog_event)` | `EUINavigation Key_GetNavigationDirectionFromAnalog(const FAnalogInputEvent&)` | `EUINavigation` |
| KeyEvent 读取 | `get_key(input)` | `FKey GetKey(const FKeyEvent&)` | `Key` |
| KeyEvent 读取 | `get_user_index(input)` | `int32 GetUserIndex(const FKeyEvent&)` | `int` |
| AnalogEvent 读取 | `get_analog_value(input)` | `float GetAnalogValue(const FAnalogInputEvent&)` | `float` |
| InputEvent 判定 | `input_event_is_repeat(input)` | `bool InputEvent_IsRepeat(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_shift_down(input)` | `bool InputEvent_IsShiftDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_left_shift_down(input)` | `bool InputEvent_IsLeftShiftDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_right_shift_down(input)` | `bool InputEvent_IsRightShiftDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_control_down(input)` | `bool InputEvent_IsControlDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_left_control_down(input)` | `bool InputEvent_IsLeftControlDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_right_control_down(input)` | `bool InputEvent_IsRightControlDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_alt_down(input)` | `bool InputEvent_IsAltDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_left_alt_down(input)` | `bool InputEvent_IsLeftAltDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_right_alt_down(input)` | `bool InputEvent_IsRightAltDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_command_down(input)` | `bool InputEvent_IsCommandDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_left_command_down(input)` | `bool InputEvent_IsLeftCommandDown(const FInputEvent&)` | `bool` |
| InputEvent 判定 | `input_event_is_right_command_down(input)` | `bool InputEvent_IsRightCommandDown(const FInputEvent&)` | `bool` |

### ModifierKeysState 判定与 PointerEvent 读取

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| ModifierKeys 判定 | `modifier_keys_state_is_shift_down(keys_state)` | `bool ModifierKeysState_IsShiftDown(const FSlateModifierKeysState&)` | `bool` |
| ModifierKeys 判定 | `modifier_keys_state_is_control_down(keys_state)` | `bool ModifierKeysState_IsControlDown(const FSlateModifierKeysState&)` | `bool` |
| ModifierKeys 判定 | `modifier_keys_state_is_alt_down(keys_state)` | `bool ModifierKeysState_IsAltDown(const FSlateModifierKeysState&)` | `bool` |
| ModifierKeys 判定 | `modifier_keys_state_is_command_down(keys_state)` | `bool ModifierKeysState_IsCommandDown(const FSlateModifierKeysState&)` | `bool` |
| PointerEvent 读取 | `pointer_event_get_screen_space_position(input)` | `FVector2D PointerEvent_GetScreenSpacePosition(const FPointerEvent&)` | `Vector2D` |
| PointerEvent 读取 | `pointer_event_get_last_screen_space_position(input)` | `FVector2D PointerEvent_GetLastScreenSpacePosition(const FPointerEvent&)` | `Vector2D` |
| PointerEvent 读取 | `pointer_event_get_cursor_delta(input)` | `FVector2D PointerEvent_GetCursorDelta(const FPointerEvent&)` | `Vector2D` |
| PointerEvent 判定 | `pointer_event_is_mouse_button_down(input, mouse_button)` | `bool PointerEvent_IsMouseButtonDown(const FPointerEvent&, FKey)` | `bool` |
| PointerEvent 读取 | `pointer_event_get_effecting_button(input)` | `FKey PointerEvent_GetEffectingButton(const FPointerEvent&)` | `Key` |
| PointerEvent 读取 | `pointer_event_get_wheel_delta(input)` | `float PointerEvent_GetWheelDelta(const FPointerEvent&)` | `float` |
| PointerEvent 读取 | `pointer_event_get_user_index(input)` | `int32 PointerEvent_GetUserIndex(const FPointerEvent&)` | `int` |
| PointerEvent 读取 | `pointer_event_get_pointer_index(input)` | `int32 PointerEvent_GetPointerIndex(const FPointerEvent&)` | `int` |
| PointerEvent 读取 | `pointer_event_get_touchpad_index(input)` | `int32 PointerEvent_GetTouchpadIndex(const FPointerEvent&)` | `int` |
| PointerEvent 判定 | `pointer_event_is_touch_event(input)` | `bool PointerEvent_IsTouchEvent(const FPointerEvent&)` | `bool` |
| PointerEvent 读取 | `pointer_event_get_gesture_type(input)` | `ESlateGesture PointerEvent_GetGestureType(const FPointerEvent&)` | `ESlateGesture` |
| PointerEvent 读取 | `pointer_event_get_gesture_delta(input)` | `FVector2D PointerEvent_GetGestureDelta(const FPointerEvent&)` | `Vector2D` |
| 动作 | `calibrate_tilt()` | `void CalibrateTilt()` | `None` |

## 快速示例

```python
import unreal

if not hasattr(unreal, "KismetInputLibrary"):
    raise RuntimeError("BLOCKED_TOOLING: KismetInputLibrary 不可用")

api = unreal.KismetInputLibrary

key = unreal.Key("LeftMouseButton")
print("mouse:", api.key_is_mouse_button(key))
print("valid:", api.key_is_valid(key))

state = api.get_modifier_keys_state()
if state is not None:
    print("shift:", api.modifier_keys_state_is_shift_down(state))

chord = unreal.InputChord([unreal.Key("Ctrl")], unreal.Key("G"))
print("chord:", api.input_chord_get_display_name(chord))
```

## 注意事项

- 返回值约定：带返回值的函数直接返回结果；无返回值（`void`）返回 `None`。本库不含返回值 + Out 组合与单个 Out 参数。
- `key_get_navigation_action` 已标注 `DeprecatedFunction`，应改用 `key_get_navigation_action_from_key`。
- Key/输入事件 struct（`Key`、`InputChord`、`InputEvent`、`KeyEvent`、`AnalogInputEvent`、`PointerEvent`、`SlateModifierKeysState`）作为纯数据入参传入；本库无构造入口。
- `pointer_event_get_effecting_button` 在无按钮触发事件时可能返回 `FKey::Invalid`。
- 无编辑器环境或库不可用时返回 `BLOCKED_TOOLING`；缺少必要输入返回 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。