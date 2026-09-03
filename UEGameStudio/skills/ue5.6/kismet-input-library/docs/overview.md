# KismetInputLibrary - API 参考与完整示例（UE 5.6）

本文件依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetInputLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理 `UKismetInputLibrary` 的可调用输入工具。方法名由 C++ 函数名按反射约定转 snake_case；全部为 static，以类方法形式调用。每个成员给出 C++ 签名、Python 签名、返回约定与示例。

## 入口

```python
import unreal

if not hasattr(unreal, "KismetInputLibrary"):
    raise RuntimeError("BLOCKED_TOOLING: KismetInputLibrary 不可用")

api = unreal.KismetInputLibrary
```

## 通用约定

- 本库为无状态读取/判定工具，不生成事件、不构造 Key。
- Key/输入事件 struct 作为纯数据入参传入；构造需通过对应封装类型与真实输入渠道获得（本库无 exec+Out 构造入口）。
- 返回约定：带返回值函数直接返回结果；`void` 函数返回 `None`；本库无单 Out 与返回值+Out 组合。
- 本库无 `meta=(ScriptMethod=...)` 成员，方法名全部按 C++ 函数名转 snake_case。
- `PointerEvent` 系列参数为 `unreal.PointerEvent`，KeyEvent 系列为 `unreal.KeyEvent`，AnalogEvent 为 `unreal.AnalogInputEvent`。

## Key 判定

### equal_equal_key_key

- C++ 签名：`bool EqualEqual_KeyKey(FKey A, FKey B)`
- Python：`equal_equal_key_key(a, b) -> bool`


```python
same = api.equal_equal_key_key(key_a, key_b)
```

### equal_equal_input_chord_input_chord

- C++ 签名：`bool EqualEqual_InputChordInputChord(FInputChord A, FInputChord B)`
- Python：`equal_equal_input_chord_input_chord(a, b) -> bool`
- 说明：输入和弦（按键组合，如 Ctrl+G）相等判定。

```python
chord_a = unreal.InputChord([unreal.Key("Ctrl")], unreal.Key("G"))
chord_b = unreal.InputChord([unreal.Key("Ctrl")], unreal.Key("G"))
same = api.equal_equal_input_chord_input_chord(chord_a, chord_b)
```

### key_is_modifier_key

- C++ 签名：`bool Key_IsModifierKey(const FKey& Key)`
- Python：`key_is_modifier_key(key) -> bool`
- 说明：是否为修饰键（Ctrl、Command、Alt、Shift）。

```python
if api.key_is_modifier_key(some_key):
    ...
```

### key_is_gamepad_key

- C++ 签名：`bool Key_IsGamepadKey(const FKey& Key)`
- Python：`key_is_gamepad_key(key) -> bool`
- 说明：是否为手柄按键。

### key_is_mouse_button

- C++ 签名：`bool Key_IsMouseButton(const FKey& Key)`
- Python：`key_is_mouse_button(key) -> bool`
- 说明：是否为鼠标按键。

### key_is_keyboard_key

- C++ 签名：`bool Key_IsKeyboardKey(const FKey& Key)`
- Python：`key_is_keyboard_key(key) -> bool`
- 说明：是否为键盘按键。

### key_is_axis1d

- C++ 签名：`bool Key_IsAxis1D(const FKey& Key)`
- Python：`key_is_axis1d(key) -> bool`
- 说明：是否为一维（float）轴。

### key_is_axis2d

- C++ 签名：`bool Key_IsAxis2D(const FKey& Key)`
- Python：`key_is_axis2d(key) -> bool`
- 说明：是否为二维（vector）轴。

### key_is_axis3d

- C++ 签名：`bool Key_IsAxis3D(const FKey& Key)`
- Python：`key_is_axis3d(key) -> bool`
- 说明：是否为三维（vector）轴。

### key_is_button_axis

- C++ 签名：`bool Key_IsButtonAxis(const FKey& Key)`
- Python：`key_is_button_axis(key) -> bool`
- 说明：是否为模拟数字键按压的一维轴。

### key_is_analog

- C++ 签名：`bool Key_IsAnalog(const FKey& Key)`
- Python：`key_is_analog(key) -> bool`
- 说明：是否为模拟轴（有连续量程）。

### key_is_digital

- C++ 签名：`bool Key_IsDigital(const FKey& Key)`
- Python：`key_is_digital(key) -> bool`
- 说明：是否为数字按键（0/1 量程）。

### key_is_valid

- C++ 签名：`bool Key_IsValid(const FKey& Key)`
- Python：`key_is_valid(key) -> bool`
- 说明：Key 是否为有效键。

```python
if not api.key_is_valid(key):
    raise RuntimeError("BLOCKED_INPUT: key 无效")
```

## Key 查询

### key_get_navigation_action

- C++ 签名：`EUINavigationAction Key_GetNavigationAction(const FKey& InKey)`
- Python：`key_get_navigation_action(in_key) -> EUINavigationAction`
- 说明：已标注 `DeprecatedFunction`，请改用 `key_get_navigation_action_from_key`。

### key_get_display_name

- C++ 签名：`FText Key_GetDisplayName(const FKey& Key, bool bLongDisplayName = true)`
- Python：`key_get_display_name(key, b_long_display_name=True) -> Text`
- 说明：返回按键显示名；`b_long_display_name` 为 `True` 时返回长显示名。

```python
display = api.key_get_display_name(unreal.Key("Gamepad_FaceButton_Bottom"))
```

### input_chord_get_display_name

- C++ 签名：`FText InputChord_GetDisplayName(const FInputChord& Key)`
- Python：`input_chord_get_display_name(key) -> Text`
- 说明：返回输入和弦显示名。

```python
label = api.input_chord_get_display_name(chord_a)
```

### get_modifier_keys_state

- C++ 签名：`FSlateModifierKeysState GetModifierKeysState()`
- Python：`get_modifier_keys_state() -> SlateModifierKeysState`
- 说明：获取应用当前缓存的修饰键状态快照，供 `modifier_keys_state_*` 判定。

```python
state = api.get_modifier_keys_state()
if state is None:
    raise RuntimeError("BLOCKED_TOOLING: 修饰键状态不可用")
```

## 事件导航

### key_get_navigation_action_from_key

- C++ 签名：`EUINavigationAction Key_GetNavigationActionFromKey(const FKeyEvent& InKeyEvent)`
- Python：`key_get_navigation_action_from_key(in_key_event) -> EUINavigationAction`
- 说明：返回对应按键的导航动作，未命中返回 `Invalid`。

### key_get_navigation_direction_from_key

- C++ 签名：`EUINavigation Key_GetNavigationDirectionFromKey(const FKeyEvent& InKeyEvent)`
- Python：`key_get_navigation_direction_from_key(in_key_event) -> EUINavigation`
- 说明：返回对应按键的导航方向，未命中返回 `Invalid`。

### key_get_navigation_direction_from_analog

- C++ 签名：`EUINavigation Key_GetNavigationDirectionFromAnalog(const FAnalogInputEvent& InAnalogEvent)`
- Python：`key_get_navigation_direction_from_analog(in_analog_event) -> EUINavigation`
- 说明：返回模拟输入事件对应的导航方向，未命中返回 `Invalid`。

```python
nav = api.key_get_navigation_direction_from_key(key_event)
if nav is unreal.EUINavigation.INVALID:
    print("no navigation mapping")
```

## 输入事件判定

下列成员参数为 `unreal.InputEvent`（或其派生 `KeyEvent`/`AnalogInputEvent`），返回 `bool`。

| Python 方法名 | C++ 签名 | 说明 |
| --- | --- | --- |
| `input_event_is_repeat(input)` | `bool InputEvent_IsRepeat(const FInputEvent&)` | 是否为自动重复击键 |
| `input_event_is_shift_down(input)` | `bool InputEvent_IsShiftDown(const FInputEvent&)` | Shift 任意一侧按下 |
| `input_event_is_left_shift_down(input)` | `bool InputEvent_IsLeftShiftDown(const FInputEvent&)` | 左 Shift 按下 |
| `input_event_is_right_shift_down(input)` | `bool InputEvent_IsRightShiftDown(const FInputEvent&)` | 右 Shift 按下 |
| `input_event_is_control_down(input)` | `bool InputEvent_IsControlDown(const FInputEvent&)` | Control 任意一侧按下 |
| `input_event_is_left_control_down(input)` | `bool InputEvent_IsLeftControlDown(const FInputEvent&)` | 左 Control 按下 |
| `input_event_is_right_control_down(input)` | `bool InputEvent_IsRightControlDown(const FInputEvent&)` | 右 Control 按下 |
| `input_event_is_alt_down(input)` | `bool InputEvent_IsAltDown(const FInputEvent&)` | Alt 任意一侧按下 |
| `input_event_is_left_alt_down(input)` | `bool InputEvent_IsLeftAltDown(const FInputEvent&)` | 左 Alt 按下 |
| `input_event_is_right_alt_down(input)` | `bool InputEvent_IsRightAltDown(const FInputEvent&)` | 右 Alt 按下 |
| `input_event_is_command_down(input)` | `bool InputEvent_IsCommandDown(const FInputEvent&)` | Command 任意一侧按下 |
| `input_event_is_left_command_down(input)` | `bool InputEvent_IsLeftCommandDown(const FInputEvent&)` | 左 Command 按下 |
| `input_event_is_right_command_down(input)` | `bool InputEvent_IsRightCommandDown(const FInputEvent&)` | 右 Command 按下 |

```python
if api.input_event_is_repeat(key_event):
    print("auto-repeat keystroke")
```

## 修饰键状态判定

| Python 方法名 | C++ 签名 | 说明 |
| --- | --- | --- |
| `modifier_keys_state_is_shift_down(keys_state)` | `bool ModifierKeysState_IsShiftDown(const FSlateModifierKeysState&)` | 捕获时刻 Shift 任意一侧按下 |
| `modifier_keys_state_is_control_down(keys_state)` | `bool ModifierKeysState_IsControlDown(const FSlateModifierKeysState&)` | 捕获时刻 Control 任意一侧按下 |
| `modifier_keys_state_is_alt_down(keys_state)` | `bool ModifierKeysState_IsAltDown(const FSlateModifierKeysState&)` | 捕获时刻 Alt 任意一侧按下 |
| `modifier_keys_state_is_command_down(keys_state)` | `bool ModifierKeysState_IsCommandDown(const FSlateModifierKeysState&)` | 捕获时刻 Command 任意一侧按下 |

```python
if api.modifier_keys_state_is_shift_down(state):
    print("shift held at capture time")
```

## KeyEvent / AnalogEvent 读取

### get_key

- C++ 签名：`FKey GetKey(const FKeyEvent& Input)`
- Python：`get_key(input) -> Key`
- 说明：事件的按键名。

```python
key = api.get_key(key_event)
```

### get_user_index

- C++ 签名：`int32 GetUserIndex(const FKeyEvent& Input)`
- Python：`get_user_index(input) -> int`
- 说明：事件对应的用户索引。

```python
user = api.get_user_index(key_event)
```

### get_analog_value

- C++ 签名：`float GetAnalogValue(const FAnalogInputEvent& Input)`
- Python：`get_analog_value(input) -> float`
- 说明：模拟输入事件的连续值（轴量）。

```python
value = api.get_analog_value(analog_event)
```

## PointerEvent 读取与判定

| Python 方法名 | C++ 签名 | 返回类型 | 说明 |
| --- | --- | --- | --- |
| `pointer_event_get_screen_space_position(input)` | `FVector2D PointerEvent_GetScreenSpacePosition(const FPointerEvent&)` | `Vector2D` | 光标屏幕空间位置 |
| `pointer_event_get_last_screen_space_position(input)` | `FVector2D PointerEvent_GetLastScreenSpacePosition(const FPointerEvent&)` | `Vector2D` | 上次处理事件时的光标位置 |
| `pointer_event_get_cursor_delta(input)` | `FVector2D PointerEvent_GetCursorDelta(const FPointerEvent&)` | `Vector2D` | 距上次事件的鼠标位移 |
| `pointer_event_is_mouse_button_down(input, mouse_button)` | `bool PointerEvent_IsMouseButtonDown(const FPointerEvent&, FKey MouseButton)` | `bool` | 指定鼠标键当前按下 |
| `pointer_event_get_effecting_button(input)` | `FKey PointerEvent_GetEffectingButton(const FPointerEvent&)` | `Key` | 触发事件的按键（可能为 `FKey::Invalid`） |
| `pointer_event_get_wheel_delta(input)` | `float PointerEvent_GetWheelDelta(const FPointerEvent&)` | `float` | 距上次事件的滚轮增量 |
| `pointer_event_get_user_index(input)` | `int32 PointerEvent_GetUserIndex(const FPointerEvent&)` | `int` | 事件用户索引 |
| `pointer_event_get_pointer_index(input)` | `int32 PointerEvent_GetPointerIndex(const FPointerEvent&)` | `int` | 指针唯一标识（如手指序号） |
| `pointer_event_get_touchpad_index(input)` | `int32 PointerEvent_GetTouchpadIndex(const FPointerEvent&)` | `int` | 触控板索引（多触控板平台） |
| `pointer_event_is_touch_event(input)` | `bool PointerEvent_IsTouchEvent(const FPointerEvent&)` | `bool` | 是否触控事件（而非鼠标） |
| `pointer_event_get_gesture_type(input)` | `ESlateGesture PointerEvent_GetGestureType(const FPointerEvent&)` | `ESlateGesture` | 触摸手势类型 |
| `pointer_event_get_gesture_delta(input)` | `FVector2D PointerEvent_GetGestureDelta(const FPointerEvent&)` | `Vector2D` | 同类手势事件间的变化量 |

```python
if api.pointer_event_is_touch_event(pointer_event):
    print("touch, point:", api.pointer_event_get_pointer_index(pointer_event))
else:
    pos = api.pointer_event_get_screen_space_position(pointer_event)
    print("mouse at:", pos)
```

## 动作

### calibrate_tilt

- C++ 签名：`void CalibrateTilt()`
- Python：`calibrate_tilt() -> None`
- 说明：校准输入设备的倾斜传感器，属有副作用动作，返回 `None`。

```python
api.calibrate_tilt()
```

## 完整示例：按键输入分派

```python
import unreal

def classify_key_event(api, key_event):
    if not api.key_is_valid(api.get_key(key_event)):
        return {"status": "BLOCKED_INPUT", "reason": "key 无效"}

    key = api.get_key(key_event)
    result = {
        "key": str(key),
        "user": api.get_user_index(key_event),
        "repeat": api.input_event_is_repeat(key_event),
        "shift": api.input_event_is_shift_down(key_event),
        "control": api.input_event_is_control_down(key_event),
        "alt": api.input_event_is_alt_down(key_event),
        "command": api.input_event_is_command_down(key_event),
        "gamepad": api.key_is_gamepad_key(key),
        "mouse": api.key_is_mouse_button(key),
        "keyboard": api.key_is_keyboard_key(key),
        "axis1d": api.key_is_axis1d(key),
        "analog": api.key_is_analog(key),
        "digital": api.key_is_digital(key),
    }
    return {"status": "OK", **result}

def main():
    try:
        api = unreal.KismetInputLibrary
    except AttributeError:
        print({"status": "BLOCKED_TOOLING", "reason": "KismetInputLibrary 不可用"})
        return

    # 触控/指针采样示例
    pointer = ...  # 需来自真实输入渠道的 PointerEvent
    if pointer is not None:
        print({
            "status": "OK",
            "screen": str(api.pointer_event_get_screen_space_position(pointer)),
            "delta": str(api.pointer_event_get_cursor_delta(pointer)),
            "touch": api.pointer_event_is_touch_event(pointer),
            "gesture": api.pointer_event_get_gesture_type(pointer),
        })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_TOOLING`：Editor/Python 上下文或 `unreal.KismetInputLibrary` 不可用；Key/事件 struct 无法从真实输入渠道获取时同样按阻塞处理。
- `BLOCKED_INPUT`：缺少必要输入（如无效 Key、缺失事件对象）；无法在纯文本编排中凭空构造真实 `KeyEvent`/`PointerEvent`。
- Key/输入事件 struct 的构造与传入方式、`FSlateModifierKeysState` 的 Python 类型名（`unreal.SlateModifierKeysState`）需在目标 UE 5.6 Editor 实测确认，未实测不声明已验证。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员。