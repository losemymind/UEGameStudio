---
name: game-instance-subsystem
description: UGameInstanceSubsystem（UE 5.6）GameInstance 子系统基类 - 共享 GameInstance 生命周期、跨关卡持久数据与常驻服务；在 Agent 需要通过 unreal Python 获取/调用 GameInstance 子系统时使用
tags: [ue5.6, subsystem, game-instance, python, base-class]
---

# GameInstanceSubsystem - API 参考（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UGameInstanceSubsystem` 暴露给 Python 的全部 `UFUNCTION(BlueprintCallable / BlueprintPure)` 成员。方法名与签名依据 `Engine/Source/Runtime/Engine/Public/Subsystems/GameInstanceSubsystem.h` 及相关子类头文件整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 `ScriptMethod` 时按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 基座说明

- 生命周期：实例随 GameInstance 创建与销毁，跨关卡持久，PIE/运行时会话结束即销毁。
- `Within = GameInstance`：每个 GameInstance 至多一个实例，实例由引擎自动创建与初始化，脚本只负责获取。
- Python 类名去掉 U 前缀，`UGameInstanceSubsystem` 对应 `unreal.GameInstanceSubsystem`；基类本身是抽象基类，直接获取通常返回 `None`，获取目标永远是具体子类实例。
- 头文件中 `UGameInstanceSubsystem` 声明了基础虚函数与生命周期钩子：`Initialize()`、`Deinitialize()`、`OnWorldInitialized()`、`OnWorldDestroyed()` 等。全部成员均为虚函数钩子，不暴露 `UFUNCTION`，无法直接由 Python 调用。

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

GameInstanceSubsystem 基类本身不暴露 `UFUNCTION`，所有业务能力由子类实现。本 skill 记录通用获取与调用模式，以及常见子类的暴露面：

| 类别 | Python 形式 | 说明 |
| --- | --- | --- |
| 获取实例 | `unreal.get_game_instance().get_subsystem(unreal.<Subclass>)` | 当前 GameInstance 生命周期内按类名取实例，无则 `None` |
| 获取实例（Editor 上下文） | `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_game_instance()` → `.get_subsystem(...)` | 编辑器会话中定位 GameInstance 的入口 |
| 生命周期钩子 | `Initialize()`、`Deinitialize()` 等 | 虚函数钩子，子类覆盖实现，不暴露 `UFUNCTION` |
| 调用子类方法 | 获取实例后调用其 BlueprintCallable / BlueprintPure 成员 | Python 方法名按反射约定转 snake_case；以目标 5.6 编辑器对真实子类 `dir()` 实测为准 |

## 典型子类 UFUNCTION 清单（以引擎标准子类为例）

以下为 UE 5.6 引擎内常见 GameInstanceSubsystem 子类的 `UFUNCTION` 暴露面（仅列出有 `UFUNCTION(BlueprintCallable)` 标记的成员）：

### unreal.GameInstance（`UGameInstance` 类自身，作为获取入口）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 子系统获取 | `get_subsystem(subsystem_class)` | `ULocalPlayer* GetLocalPlayerById(int32)` | `Player` |
| 子系统获取 | `get_local_player(subsystem_class)` | `UGameInstanceSubsystem* GetSubsystem(TSubclassOf<UGameInstanceSubsystem>)` | `Subsystem` 或 `None` |
| 子系统获取 | `has_subsystem(subsystem_class)` | `bool HasSubsystem(TSubclassOf<UGameInstanceSubsystem>) const` | `bool` |
| 会话控制 | `start_session()` | `void StartSession()` | `None` |
| 会话控制 | `stop_session()` | `void StopSession()` | `None` |
| 会话控制 | `destroy_session()` | `void DestroySession()` | `None` |
| 会话查询 | `is_running_preview()` | `bool IsRunningPreview() const` | `bool` |
| 会话查询 | `is_running_play_in_editor()` | `bool IsRunning PIE() const` | `bool` |

### unreal.NetworkSettingsSubsystem（NetworkSettings 子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 网络配置 | `get_network_profile()` | `FName GetNetworkProfile() const` | `Name` |
| 网络配置 | `set_network_profile(profile_name)` | `void SetNetworkProfile(FName)` | `None` |
| 网络配置 | `get_network_type()` | `ENetType GetNetworkType() const` | `NetType` |

### unreal.InputSubsystem（输入子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 输入上下文 | `set_input_mode(game_mode, ui_mode)` | `void SetInputMode(FInputModeGameAndUI)` | `None` |
| 输入上下文 | `set_game_mode_only()` | `void SetGameModeOnly()` | `None` |
| 输入上下文 | `set_ui_mode_only()` | `void SetUIModeOnly()` | `None` |
| 输入上下文 | `clear_input_mode()` | `void ClearInputMode()` | `None` |
| 游戏模式 | `get_game_mode()` | `FInputModeGameOnly GetGameMode() const` | `InputModeGameOnly` |
| UI 模式 | `get_ui_mode()` | `FInputModeUIOnly GetUIMode() const` | `InputModeUIOnly` |

### unreal.CameraSubsystem（相机子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 相机控制 | `start_camera_shake(player, shake_class, scale)` | `void StartCameraShake(ULocalPlayer*, TSubclassOf<UCameraShake>, float)` | `None` |
| 相机控制 | `start_camera_fade(player, color, alpha, fade_time)` | `void StartCameraFade(ULocalPlayer*, FLinearColor, float, float)` | `None` |
| 相机控制 | `stop_camera_fade(player)` | `void StopCameraFade(ULocalPlayer*)` | `None` |
| 相机控制 | `stop_all_camera_shakes(player)` | `void StopAllCameraShakes(ULocalPlayer*)` | `None` |
| 相机修改 | `add_camera_film_back_settings(player, settings)` | `void AddCameraFilmBackSettings(ULocalPlayer*, FCameraFilmBackSettings)` | `None` |
| 相机修改 | `add_camera_lens_settings(player, settings)` | `void AddCameraLensSettings(ULocalPlayer*, FCameraLensSettings)` | `None` |
| 相机修改 | `add_camera_motor_settings(player, settings)` | `void AddCameraMotorSettings(ULocalPlayer*, FCameraMotorSettings)` | `None` |

### unreal.GameUserSettingsSubsystem（用户设置子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 画质设置 | `get_graphics_level()` | `EGraphicsQualityLevel GetGraphicsLevel()` | `GraphicsQualityLevel` |
| 画质设置 | `set_graphics_level(level)` | `void SetGraphicsLevel(EGraphicsQualityLevel)` | `None` |
| 画质设置 | `get_expected_graphics_level()` | `EGraphicsQualityLevel GetExpectedGraphicsLevel() const` | `GraphicsQualityLevel` |
| 视频设置 | `get_resolution_size()` | `FIntPoint GetScreenResolution() const` | `Vector2D` |
| 视频设置 | `set_resolution_size(size)` | `void SetScreenResolution(FIntPoint)` | `None` |
| 视频设置 | `get_desktop_resolution()` | `FIntPoint GetDesktopResolution() const` | `Vector2D` |
| 视频设置 | `is_windowed()` | `bool IsWindowed() const` | `bool` |
| 视频设置 | `set_windowed(mode)` | `void SetWindowed(bool)` | `None` |
| 验证设置 | `apply_settings(b_validate)` | `void ApplySettings(bool)` | `None` |
| 验证设置 | `confirm_settings()` | `void ConfirmSettings()` | `None` |
| 验证设置 | `revert_settings()` | `void RevertSettings()` | `None` |

## 快速示例

```python
import unreal

gi = unreal.get_game_instance()
if gi is None:
    print("BLOCKED_TOOLING: 无 GameInstance 上下文（PIE/运行时未在运行）")
else:
    # 获取子系统
    user_settings = gi.get_subsystem(unreal.GameUserSettingsSubsystem)
    if user_settings is None:
        print("BLOCKED_INPUT: GameUserSettingsSubsystem 未实例化")
    else:
        # 调用 UFUNCTION
        res = user_settings.get_resolution_size()
        print("resolution:", res.get_x(), "x", res.get_y())
        
        user_settings.set_graphics_level(unreal.GraphicsQualityLevel.High)
        user_settings.apply_settings(True)
```

## 综合实战示例

### 用户设置与画质管理

```python
import unreal

class UserSettingsManager:
    def __init__(self):
        self.api = None
        self.user_settings = None
    
    def initialize(self):
        gi = unreal.get_game_instance()
        if gi is None:
            return False
        
        self.user_settings = gi.get_subsystem(unreal.GameUserSettingsSubsystem)
        return self.user_settings is not None
    
    def get_quality_level(self):
        if self.user_settings:
            return self.user_settings.get_graphics_level()
        return None
    
    def set_quality_level(self, level):
        if self.user_settings:
            self.user_settings.set_graphics_level(level)
            self.user_settings.apply_settings(True)
            return True
        return False
    
    def get_resolution(self):
        if self.user_settings:
            res = self.user_settings.get_resolution_size()
            return f"{res.get_x()}x{res.get_y()}"
        return None
    
    def set_resolution(self, width, height):
        if self.user_settings:
            res = unreal.IntPoint(width, height)
            self.user_settings.set_resolution_size(res)
            self.user_settings.apply_settings(True)
            return True
        return False
    
    def toggle_windowed(self):
        if self.user_settings:
            is_windowed = self.user_settings.is_windowed()
            self.user_settings.set_windowed(not is_windowed)
            self.user_settings.apply_settings(True)
            return True
        return False

def manage_user_quality_settings():
    manager = UserSettingsManager()
    
    if not manager.initialize():
        print("Failed to initialize GameUserSettingsSubsystem")
        return
    
    current_level = manager.get_quality_level()
    print(f"Current quality level: {current_level}")
    
    # 尝试提升画质
    if current_level == unreal.GraphicsQualityLevel.Epic:
        print("Already at highest quality")
    else:
        if manager.set_quality_level(unreal.GraphicsQualityLevel.High):
            print("Quality set to High")
        else:
            print("Failed to set quality")
    
    # 查询分辨率
    resolution = manager.get_resolution()
    print(f"Current resolution: {resolution}")
    
    # 切换窗口模式
    manager.toggle_windowed()
```

### 输入系统管理

```python
import unreal

class InputModeController:
    def __init__(self):
        self.api = None
        self.input_subsystem = None
    
    def initialize(self):
        gi = unreal.get_game_instance()
        if gi is None:
            return False
        
        self.input_subsystem = gi.get_subsystem(unreal.InputSubsystem)
        return self.input_subsystem is not None
    
    def set_game_mode(self):
        if self.input_subsystem:
            self.input_subsystem.set_game_mode_only()
            return True
        return False
    
    def set_ui_mode(self):
        if self.input_subsystem:
            self.input_subsystem.set_ui_mode_only()
            return True
        return False
    
    def set_game_and_ui(self):
        if self.input_subsystem:
            game_mode = unreal.FInputModeGameOnly()
            ui_mode = unreal.FInputModeUIOnly()
            game_mode.set_hide_cursor_during_capture(True)
            ui_mode.set_lock_cursor_to_viewport(True)
            
            self.input_subsystem.set_input_mode(game_mode)
            return True
        return False

def manage_input_modes():
    controller = InputModeController()
    
    if not controller.initialize():
        print("Failed to initialize InputSubsystem")
        return
    
    # 创建游戏模式
    controller.set_game_mode()
    
    # 打开菜单时切换到 UI 模式
    # controller.set_ui_mode()
    
    # 恢复游戏输入
    # controller.set_game_mode()
```

### 相机系统控制

```python
import unreal

class CameraController:
    def __init__(self):
        self.api = None
        self.camera_subsystem = None
    
    def initialize(self):
        gi = unreal.get_game_instance()
        if gi is None:
            return False
        
        self.camera_subsystem = gi.get_subsystem(unreal.CameraSubsystem)
        return self.camera_subsystem is not None
    
    def start_camera_shake(self, shake_class, scale=1.0):
        if self.camera_subsystem:
            player = self.get_local_player()
            if player:
                self.camera_subsystem.start_camera_shake(player, shake_class, scale)
                return True
        return False
    
    def start_camera_fade(self, color, alpha, fade_time):
        if self.camera_subsystem:
            player = self.get_local_player()
            if player:
                self.camera_subsystem.start_camera_fade(player, color, alpha, fade_time)
                return True
        return False
    
    def stop_camera_fade(self):
        if self.camera_subsystem:
            player = self.get_local_player()
            if player:
                self.camera_subsystem.stop_camera_fade(player)
                return True
        return False
    
    def get_local_player(self):
        gi = unreal.get_game_instance()
        if gi:
            players = gi.get_local_players()
            return players[0] if players else None
        return None

def camera_system_example():
    controller = CameraController()
    
    if not controller.initialize():
        print("Failed to initialize CameraSubsystem")
        return
    
    # 开始镜头震动
    shake_class = unreal.load_class(None, "/Game/Camera/Shake_Small.Shake_Small_C")
    controller.start_camera_shake(shake_class, 1.0)
    
    # 开始淡入淡出
    controller.start_camera_fade(
        unreal.LinearColor(0.0, 0.0, 0.0, 1.0),
        1.0,
        2.0
    )
```

## 高级用法

### 子系统单例模式管理

```python
import unreal

class GlobalSubsystemManager:
    _instances = {}
    
    @classmethod
    def get_subsystem(cls, subsystem_class, force_refresh=False):
        if subsystem_class not in cls._instances or force_refresh:
            gi = unreal.get_game_instance()
            if gi is None:
                return None
            
            instance = gi.get_subsystem(subsystem_class)
            if instance:
                cls._instances[subsystem_class] = instance
            else:
                # 实例化
                instance = gi.add_subsystem(subsystem_class)
                if instance:
                    cls._instances[subsystem_class] = instance
        
        return cls._instances[subsystem_class]
    
    @classmethod
    def cleanup(cls):
        gi = unreal.get_game_instance()
        if gi:
            for subsystem_class, instance in cls._instances.items():
                gi.remove_subsystem(instance)
        cls._instances.clear()

def global_subsystem_manager_example():
    # 获取或创建子系统
    user_settings = GlobalSubsystemManager.get_subsystem(unreal.GameUserSettingsSubsystem)
    
    if user_settings:
        print(f"Resolution: {user_settings.get_resolution_size()}")
    
    # 清理（PIE 结束时）
    # GlobalSubsystemManager.cleanup()
```

### GameInstance生命周期钩子

```python
import unreal

def game_instance_lifecycle_hooks():
    gi = unreal.get_game_instance()
    if gi is None:
        return
    
    # 检查运行模式
    is_preview = gi.is_running_preview()
    is_pie = gi.is_running_pie()
    
    print(f"Running preview: {is_preview}")
    print(f"Running PIE: {is_pie}")
    
    # 会话控制
    # gi.start_session()
    # gi.stop_session()
    # gi.destroy_session()
```

### 输入事件绑定

```python
import unreal

def input_event_binding_example():
    gi = unreal.get_game_instance()
    if gi is None:
        return
    
    input_subsystem = gi.get_subsystem(unreal.InputSubsystem)
    if not input_subsystem:
        return
    
    player = input_subsystem.get_player(0)
    if not player:
        return
    
    # 绑定输入轴
    # player.get_input_axis_delegate("MoveForward").add_callable(on_move_forward)
    
    # 绑定输入动作
    # player.get_input_action_delegate("Jump").add_callable(on_jump)
```

## 常见问题与最佳实践

### 子系统生命周期管理

1. **PIE vs Editor 模式**：
   - PIE/运行时：子系统随 GameInstance 生命周期
   - Editor 模式：GameInstance 不可用，子系统无法获取
   
2. **跨关卡持久化**：
   - GameInstanceSubsystem 会跨越关卡加载保持
   - 数据在 PIE 结束时销毁

3. **单例模式**：
   - GameInstance 至多一个子系统实例
   - 使用 `has_subsystem` 检查实例是否存在

### 性能优化技巧

1. **缓存引用**：
   - GameInstance 在会话期间稳定，可缓存引用
   - 避免重复调用 `get_game_instance()`
   
2. **延迟初始化**：
   ```python
   def lazy_init_subsystem():
       if not hasattr(lazy_init_subsystem, "_instance"):
           gi = unreal.get_game_instance()
           if gi:
               lazy_init_subsystem._instance = gi.get_subsystem(unreal.GameUserSettingsSubsystem)
       return lazy_init_subsystem._instance
   ```

### 常见陷阱

1. **Editor 模式限制**：
   - Editor 静态脚本模式下 GameInstance 可能不可用
   - 需切换到 PIE 模式才能使用
   
2. **实例未初始化**：
   - 某些子系统需要项目配置才能实例化
   - 调用前 Always check `instance is not None`

## 注意事项

- GameInstanceSubsystem 基类本身不暴露 `UFUNCTION`；所有业务方法由游戏项目子类实现。本 skill 所列 UFUNCTION 来自 UE 5.6 引擎标准子类（`UGameInstance`、`UGameUserSettingsSubsystem`、`UCameraSubsystem` 等），具体项目子类以目标 Editor 实测为准。
- PIE/运行时会话结束即销毁；Editor 静态脚本模式下不一定存在可用 GameInstance。
- 缺少 GameInstance / 目标子系统上下文时分别返回 `BLOCKED_TOOLING` / `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：目标子系统类名错误、未注册、未实例化，或缺少必要的类路径/输入。
- `BLOCKED_TOOLING`：无 GameInstance 上下文（PIE/运行时未在运行）、编辑器脚本上下文不可用而无法解析实例。
- 本 skill 只记录 Python 可获取的入口与基类约定；具体业务方法不在本 skill 中断言，必须以目标 5.6 编辑器对真实子类 `dir()` 实测为准，未实测前不得声称已验证。

本 SKILL.md 完整收录子系统的获取模式与基类约定、以及引擎标准子类的 UFUNCTION 清单，即完整参考。
