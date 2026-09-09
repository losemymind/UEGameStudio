# InputDeviceSubsystem - 概述（UE 5.6）

## 库功能概述

`UInputDeviceSubsystem` 是 UE 5.6 中专门管理输入设备状态与配置的核心子系统。该子系统提供了对各种输入设备（键盘、鼠标、手柄、触摸屏、VR 控制器等）的统一访问接口，支持设备枚举、状态查询、输入绑定、设备热插拔事件监听等功能。

从 UE 5 开始，输入系统进行了重大重构，`UInputDeviceSubsystem` 成为新的输入管理核心，替代了 older 版本中的 `IInputInterface` 与 `UPlayerInput` 的部分功能，提供了更现代、更灵活的输入管理体验。

## 核心用途与场景

### 1. 多设备支持与切换
- **设备枚举**：列出系统中连接的所有输入设备
- **设备切换**：在键盘+鼠标、手柄、触摸等输入方式间切换
- **多设备并存**：支持多个相同类型设备同时连接（如多个手柄）

### 2. 输入状态查询
- **按键状态**：查询按键是否按下、释放、当前帧按下等
- **模拟输入**：读取摇杆、扳机等模拟轴的数值
- **触摸轨迹**：获取触摸屏的多点触控与滑动轨迹

### 3. 输入绑定管理
- **动态绑定**：运行时修改输入映射与动作映射
- **输入上下文**：管理不同的输入上下文（游戏、菜单、编辑器）
- **优先级控制**：设置输入绑定的优先级与竞争处理

### 4. 输入设备配置
- **设备校准**：手柄摇杆死区、触摸屏校准
- **设备功能**：获取设备支持的输入功能（如手柄触控板、VR 作用力反馈）
- **设备事件**：监听设备连接/断开事件

## 更多使用示例

### 示例 1：获取 InputDeviceSubsystem
```python
import unreal

def get_input_device_subsystem():
    """获取 InputDeviceSubsystem 实例"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING", "reason": "InputDeviceSubsystem not available in this world"}
    
    return {"status": "OK", "subsystem": subsystem}
```

### 示例 2：枚举连接的输入设备
```python
import unreal

def list_input_devices():
    """列出所有连接的输入设备"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取所有输入设备 ID
    device_ids = subsystem.get_all_input_devices()
    
    devices = []
    for device_id in device_ids:
        device_info = {
            "device_id": device_id,
            "device_type": "Unknown"
        }
        
        # 获取设备类型
        # device_type = subsystem.get_input_device_type(device_id)
        # device_info["device_type"] = device_type.name if device_type else "Unknown"
        
        # 获取设备名称
        # device_name = subsystem.get_input_device_name(device_id)
        # device_info["device_name"] = device_name
        
        devices.append(device_info)
    
    return {
        "status": "OK",
        "device_count": len(devices),
        "devices": devices
    }

def get_connected_gamepads():
    """获取所有连接的手柄设备"""
    all_devices = list_input_devices()
    
    gamepads = []
    for device in all_devices.get("devices", []):
        if device.get("device_type") == "Gamepad":
            gamepads.append(device)
    
    return {
        "status": "OK",
        "gamepad_count": len(gamepads),
        "devices": gamepads
    }
```

### 示例 3：查询输入状态
```python
import unreal

def query_input_state(device_id, input_type, input_name):
    """查询指定设备的输入状态"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    if not subsystem.is_valid_device_id(device_id):
        return {"status": "ERROR", "reason": "Invalid device ID"}
    
    # 查询按下状态
    is_pressed = subsystem.is_button_pressed(device_id, input_name)
    
    # 查询轴心值（模拟输入）
    axis_value = subsystem.get_axis_value(device_id, input_name)
    
    return {
        "status": "OK",
        "device_id": device_id,
        "input_type": input_type,
        "input_name": input_name,
        "is_pressed": is_pressed,
        "axis_value": axis_value
    }

# 使用示例
def check_gamepad_controls(gamepad_id):
    """检查手柄控制输入"""
    results = {
        "status": "OK",
        "device_id": gamepad_id,
        "controls": {}
    }
    
    # 按键状态
    results["controls"]["A"] = query_input_state(gamepad_id, "Button", "Gamepad_FaceButton_Bottom")
    results["controls"]["B"] = query_input_state(gamepad_id, "Button", "Gamepad_FaceButton_Right")
    results["controls"]["X"] = query_input_state(gamepad_id, "Button", "Gamepad_FaceButton_Left")
    results["controls"]["Y"] = query_input_state(gamepad_id, "Button", "Gamepad_FaceButton_Top")
    
    # 摇杆轴值
    results["controls"]["LeftStick_X"] = query_input_state(gamepad_id, "Axis", "Gamepad_LeftX")
    results["controls"]["LeftStick_Y"] = query_input_state(gamepad_id, "Axis", "Gamepad_LeftY")
    results["controls"]["RightStick_X"] = query_input_state(gamepad_id, "Axis", "Gamepad_RightX")
    results["controls"]["RightStick_Y"] = query_input_state(gamepad_id, "Axis", "Gamepad_RightY")
    
    # 扳机轴值
    results["controls"]["LeftTrigger"] = query_input_state(gamepad_id, "Axis", "Gamepad_LeftTrigger")
    results["controls"]["RightTrigger"] = query_input_state(gamepad_id, "Axis", "Gamepad_RightTrigger")
    
    return results
```

### 示例 4：监听设备事件
```python
import unreal

class InputDeviceEventListener:
    """输入设备事件监听器"""
    
    def __init__(self):
        self.device_connected_callback = None
        self.device_disconnected_callback = None
    
    def start_listening(self):
        """开始监听设备事件"""
        world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
        subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
        
        if subsystem is None:
            return {"status": "BLOCKED_TOOLING"}
        
        # 注册设备连接事件
        self.device_connected_callback = unreal.OnInputDeviceConnected()
        self.device_connected_callback.bind(self.on_device_connected)
        subsystem.add_on_input_device_connected_delegate(self.device_connected_callback)
        
        # 注册设备断开事件
        self.device_disconnected_callback = unreal.OnInputDeviceDisconnected()
        self.device_disconnected_callback.bind(self.on_device_disconnected)
        subsystem.add_on_input_device_disconnected_delegate(self.device_disconnected_callback)
        
        return {"status": "OK", "listener_registered": True}
    
    def stop_listening(self):
        """停止监听设备事件"""
        world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
        subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
        
        if subsystem is None:
            return {"status": "BLOCKED_TOOLING"}
        
        # 移除回调
        if self.device_connected_callback:
            subsystem.remove_on_input_device_connected_delegate(self.device_connected_callback)
        if self.device_disconnected_callback:
            subsystem.remove_on_input_device_disconnected_delegate(self.device_disconnected_callback)
        
        return {"status": "OK", "listener_removed": True}
    
    def on_device_connected(self, device_id, device_type):
        """设备连接回调"""
        print(f"Device connected: ID={device_id}, Type={device_type}")
    
    def on_device_disconnected(self, device_id, device_type):
        """设备断开回调"""
        print(f"Device disconnected: ID={device_id}, Type={device_type}")

# 使用示例
def setup_input_device_listener():
    listener = InputDeviceEventListener()
    return listener.start_listening()
```

### 示例 5：动态输入绑定
```python
import unreal

def modify_input_binding():
    """修改输入绑定（简化示例）"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 动态添加轴映射
    # note: 实际实现需要通过 PlayerInput 或 InputMappingContext
    
    return {
        "status": "OK",
        "note": "动态输入绑定需要通过 PlayerInput 或 InputMappingContext",
        "reference": "unreal.InputMappingContext, unreal.PlayerInput"
    }

def set_deadzone_for_gamepad(device_id, axis_name, deadzone):
    """设置手柄摇杆死区"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 设置死区值
    # note: 实际实现需要通过 InputSettings
    subsystem.set_axis_deadzone(device_id, axis_name, deadzone)
    
    return {
        "status": "OK",
        "device_id": device_id,
        "axis_name": axis_name,
        "deadzone": deadzone
    }
```

## 高级用法与最佳实践

### 1. 多输入上下文管理
- **输入上下文优先级**：使用 `InputMappingContext` 管理不同游戏状态的输入映射
- **上下文切换**：在游戏/菜单/编辑器模式间平滑切换输入绑定
- **优先级冲突解决**：设置输入绑定的优先级处理竞争情况

### 2. 输入事件优化
- **批量查询**：需要多个输入状态时，批量查询比单独查询更高效
- **状态缓存**：缓存输入状态，避免每帧重复查询
- **帧差分**：使用 `is_button_pressed` 与 `is_button_released` 实现帧触发事件

### 3. 与 VR/AR 系统集成
```python
import unreal

def integrate_with_vr_system():
    """与 VR 系统集成"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.InputDeviceSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取 VR 控制器设备
    vr_controllers = []
    for device_id in subsystem.get_all_input_devices():
        # device_type = subsystem.get_input_device_type(device_id)
        # if device_type in ["VRControllerRight", "VRControllerLeft"]:
        #     vr_controllers.append(device_id)
        pass
    
    return {
        "status": "OK",
        "vr_controllers": vr_controllers,
        "note": "VR 输入需要 OpenXR 或 Oculus 插件"
    }
```

## 常见问题与注意事项

### 1. 运行时环境限制
- **仅运行时支持**：InputDeviceSubsystem 仅在 PIE/Play 会话中可用，编辑器主世界不支持
- **世界上下文**：需要有效的 `UWorld` 实例获取子系统
- **设备初始化**：设备枚举在第一次调用时可能返回空数组，等待设备枚举完成

### 2. 设备类型与名称
- **设备类型枚举**：使用 `EInputDeviceType` 枚举（Gamepad、Keyboard、Mouse、Touchscreen、VRController 等）
- **输入名称常量**：使用预定义的输入名称常量（如 "Gamepad_FaceButton_Bottom"）
- **自定义设备**：VR/AR 设备类型取决于启用的插件

### 3. 常见错误
- `BLOCKED_TOOLING`：世界不支持 InputDeviceSubsystem（非运行时环境）
- `BLOCKED_INPUT`：设备 ID 无效、输入名称无效
- **空数组**：设备枚举返回空数组，等待设备连接或枚举完成

### 4. 性能考虑
- **查询频率**：避免每帧查询大量设备状态，考虑缓存
- **事件回调**：设备连接/断开事件使用委托（Delegate）而非轮询
- **批量操作**：需要多次查询时，批量获取数据比多次单独查询更高效

### 5. 与老版本的区别
- **旧版本**：使用 `PlayerInput`、`InputComponent` 管理输入
- **5.x 版本**：`InputDeviceSubsystem` 统一管理输入设备状态
- **向后兼容**：旧的 `PlayerInput` API 仍然可用，但推荐使用新系统

### 6. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.InputDeviceSubsystem)` 实测确认
- 个别高级方法（如 `set_axis_deadzone`）可能需要通过 InputSettings 实现

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。