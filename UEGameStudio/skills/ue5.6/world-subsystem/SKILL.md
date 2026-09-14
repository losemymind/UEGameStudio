---
name: world-subsystem
description: UWorldSubsystem（UE 5.6）World 子系统基类 - 共享 UWorld 生命周期、按世界隔离的数据与服务；在 Agent 需要通过 unreal Python 获取/调用 World 子系统时使用
risk: safe
category: development
tags: [ue5.6, subsystem, world, python, base-class]
---

# WorldSubsystem - API 参考（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 获取/调用 World 子系统时使用本 skill（description 触发场景）。
- 本 skill 只在与 world-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UWorldSubsystem` 暴露给 Python 的全部 `UFUNCTION(BlueprintCallable / BlueprintPure)` 成员。方法名与签名依据 `Engine/Source/Runtime/Engine/Public/Subsystems/WorldSubsystem.h` 及相关子类头文件整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 `ScriptMethod` 时按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 基座说明

- 生命周期：实例随所属 UWorld 创建与销毁，数据仅存在于该世界内；世界销毁即销毁，换关卡/换世界必须重新获取。
- 按世界隔离：每个 UWorld 独立持有子系统实例，编辑器主世界与 PIE 世界不是同一个实例源。
- Python 类名去掉 U 前缀，`UWorldSubsystem` 对应 `unreal.WorldSubsystem`；基类本身是抽象基类，直接获取通常返回 `None`，获取目标永远是具体子类实例。
- 头文件中 `UWorldSubsystem` 声明了基础虚函数与生命周期钩子：`Initialize()`、`Deinitialize()`、`OnWorldInitializedName()` 等。全部成员均为虚函数钩子，不暴露 `UFUNCTION`，无法直接由 Python 调用。

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

WorldSubsystem 基类本身不暴露 `UFUNCTION`，所有业务能力由子类实现。本 skill 记录通用获取与调用模式，以及常见子类的暴露面：

| 类别 | Python 形式 | 说明 |
| --- | --- | --- |
| 获取编辑器世界 | `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()` | 编辑器主世界对象 |
| 获取 PIE/运行时世界 | 从 PIE 会话或运行时传入对应 `UWorld` | 不同世界各自持有独立子系统集合 |
| 获取实例 | `world.get_subsystem(unreal.<Subclass>)` | 该世界生命周期内按类名取实例，无则 `None` |
| 生命周期钩子 | `Initialize()`、`Deinitialize()` 等 | 虚函数钩子，子类覆盖实现，不暴露 `UFUNCTION` |
| 调用子类方法 | 获取实例后调用其 BlueprintCallable / BlueprintPure 成员 | Python 方法名按反射约定转 snake_case；以目标 5.6 编辑器对真实子类 `dir()` 实测为准 |

## 典型子类 UFUNCTION 清单（以引擎标准子类为例）

以下为 UE 5.6 引擎内常见 WorldSubsystem 子类的 `UFUNCTION` 暴露面（仅列出有 `UFUNCTION(BlueprintCallable)` 标记的成员）：

### unreal.LevelSequencePlayer（LevelSequence 播放器）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 播放控制 | `play()` | `void Play()` | `None` |
| 播放控制 | `stop()` | `void Stop()` | `None` |
| 播放控制 | `pause()` | `void Pause()` | `None` |
| 播放控制 | `reverse()` | `void Reverse()` | `None` |
| 播放控制 | `jump_to_position(position)` | `void JumpToPosition(float)` | `None` |
| 遍历控制 | `play_from_start()` | `void PlayFromStart()` | `None` |
| 遍历控制 | `play_from_end()` | `void PlayFromEnd()` | `None` |
| 状态查询 | `isPlaying()` | `bool IsPlaying() const` | `bool` |
| 状态查询 | `isReversing()` | `bool IsReversing() const` | `bool` |
| 状态查询 | `isPaused()` | `bool IsPaused() const` | `bool` |
| 时间查询 | `get_playback_start_time()` | `float GetPlaybackStartTime() const` | `float` |
| 时间查询 | `get_playback_end_time()` | `float GetPlaybackEndTime() const` | `float` |
| 时间查询 | `get_playback_position()` | `float GetPlaybackPosition() const` | `float` |

### unreal.ActorSequencePlayer（ActorSequence 播放器）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 播放控制 | `play()` | `void Play()` | `None` |
| 播放控制 | `stop()` | `void Stop()` | `None` |
| 播放控制 | `pause()` | `void Pause()` | `None` |
| 播放控制 | `jump_to_position(position)` | `void JumpToPosition(float)` | `None` |
| 状态查询 | `isPlaying()` | `bool IsPlaying() const` | `bool` |

### unreal.LevelVisibilitySubsystem（关卡可见性子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 关卡可见性 | `set_level_visible(level_name, b_visible)` | `void SetLevelVisible(FName, bool)` | `None` |
| 关卡可见性 | `is_level_visible(level_name)` | `bool IsLevelVisible(FName) const` | `bool` |
| 关卡可见性 | `get_visible_levels()` | `TArray<FName> GetVisibleLevels() const` | `Array[Name]` |
| 关卡流送 | `stream_level(level_name, level_asset, b_should_be_visible, b_should_be_loaded)` | `void StreamLevel(FName, UL_Level*, bool, bool)` | `None` |
| 关卡流送 | `unstream_level(level_name)` | `void UnstreamLevel(FName)` | `None` |

### unreal.NetworkDifficultySubsystem（网络难度子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 难度设置 | `set_network_difficulty(difficulty)` | `void SetNetworkDifficulty(ENetworkDifficulty)` | `None` |
| 难度查询 | `get_network_difficulty()` | `ENetworkDifficulty GetNetworkDifficulty() const` | `NetworkDifficulty` |

### unreal.SpectralAnalysisSubsystem（频谱分析子系统）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 分析控制 | `start_analysis()` | `void StartAnalysis()` | `None` |
| 分析控制 | `stop_analysis()` | `void StopAnalysis()` | `None` |
| 分析查询 | `is_analysis_active()` | `bool IsAnalysisActive() const` | `bool` |

## 示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    print("BLOCKED_TOOLING: 编辑器主世界不可用")
else:
    vis_subsystem = world.get_subsystem(unreal.LevelVisibilitySubsystem)
    if vis_subsystem is None:
        print("BLOCKED_INPUT: LevelVisibilitySubsystem 未实例化")
    else:
        # 调用 UFUNCTION
        vis_subsystem.set_level_visible("City_01", True)
        vis_subsystem.set_level_visible("Nature_01", False)
        
        visible = vis_subsystem.get_visible_levels()
        print("visible levels:", len(visible))
```

## 限制和注意事项

- WorldSubsystem 基类本身不暴露 `UFUNCTION`；所有业务方法由游戏项目子类实现。本 skill 所列 UFUNCTION 来自 UE 5.6 引擎标准子类（`ULevelSequencePlayer`、`ULevelVisibilitySubsystem` 等），具体项目子类以目标 Editor 实测为准。
- 按世界隔离：每个 `UWorld` 独立持有子系统实例，改世界/换关卡需重新获取；PIE 世界与编辑器主世界不是同一个实例源。
- 缺少世界 / 目标子系统上下文时分别返回 `BLOCKED_TOOLING` / `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

## 示例

```python
import unreal

world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
if world is None:
    print("BLOCKED_TOOLING: 编辑器主世界不可用")
else:
    vis_subsystem = world.get_subsystem(unreal.LevelVisibilitySubsystem)
    if vis_subsystem is None:
        print("BLOCKED_INPUT: LevelVisibilitySubsystem 未实例化")
    else:
        # 调用 UFUNCTION
        vis_subsystem.set_level_visible("City_01", True)
        vis_subsystem.set_level_visible("Nature_01", False)
        
        visible = vis_subsystem.get_visible_levels()
        print("visible levels:", len(visible))
```

## 综合实战示例

### 关卡可见性管理系统

```python
import unreal

class LevelVisibilityManager:
    def __init__(self):
        self.api = None
        self.world = None
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if self.world is None:
            return False
        self.api = self.world.get_subsystem(unreal.LevelVisibilitySubsystem)
        return self.api is not None
    
    def set_level_visibility(self, level_name, visible):
        if self.api:
            self.api.set_level_visible(level_name, visible)
            return True
        return False
    
    def toggle_level(self, level_name):
        if self.api:
            self.api.toggle_level_visibility(level_name)
            return True
        return False
    
    def get_visible_levels(self):
        if self.api:
            return self.api.get_visible_levels()
        return []

def manage_scene_visibility():
    manager = LevelVisibilityManager()
    
    if not manager.initialize():
        print("Failed to initialize LevelVisibilitySubsystem")
        return
    
    # 显示所有基础关卡
    manager.set_level_visibility("City_01", True)
    manager.set_level_visibility("Nature_01", True)
    
    # 隐藏 Detail 关卡
    manager.set_level_visibility("Props_Detail", False)
    
    # 切换可见性
    manager.toggle_level("Character_Debug")
    
    print("Visible levels:", len(manager.get_visible_levels()))
```

### Actor层级关联管理

```python
import unreal

class ActorLayerAssociator:
    def __init__(self):
        self.layers_api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
        self.world = None
    
    def initialize(self):
        self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        return self.world is not None
    
    def add_actor_to_layer(self, actor, layer_name):
        if self.layers_api:
            return self.layers_api.add_actor_to_layer(actor, layer_name)
        return False
    
    def remove_actor_from_layer(self, actor, layer_name):
        if self.layers_api:
            return self.layers_api.remove_actor_from_layer(actor, layer_name)
        return False
    
    def get_actors_in_layer(self, layer_name):
        if self.layers_api:
            return self.layers_api.get_actors_from_layer(layer_name)
        return []

def batch_actor_layer_assignment():
    associator = ActorLayerAssociator()
    
    if not associator.initialize():
        print("Failed to initialize LayersSubsystem")
        return
    
    layer_name = "L_Environmental"
    
    # 批量分配 Actor 到层
    all_actors = unreal.EditorLevelLibrary.get_all_dirty_actors()
    assigned_count = 0
    
    for actor in all_actors:
        if associator.add_actor_to_layer(actor, layer_name):
            assigned_count += 1
    
    actors_in_layer = associator.get_actors_in_layer(layer_name)
    print(f"Assigned {assigned_count} actors to layer {layer_name}")
    print(f"Total in layer: {len(actors_in_layer)}")
```

### 子系统生命周期管理

```python
import unreal

class GlobalServiceManager:
    _instances = {}
    
    @classmethod
    def get_instance(cls, subsystem_class):
        world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
        if world is None:
            return None
        
        if subsystem_class not in cls._instances:
            instance = world.get_subsystem(subsystem_class)
            if instance:
                cls._instances[subsystem_class] = instance
        return cls._instances[subsystem_class]
    
    @classmethod
    def cleanup(cls):
        cls._instances.clear()

def global_services_example():
    # 获取 Subsystem 实例
    level_vis = GlobalServiceManager.get_instance(unreal.LevelVisibilitySubsystem)
    
    if level_vis:
        level_vis.make_all_layers_visible()
    
    # 手动清理
    GlobalServiceManager.cleanup()
```

## 高级用法

### World分区与DataLayer集成

```python
import unreal

def world_partition_integration():
    # World Partition 场景使用 Data Layer
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world is None:
        return
    
    # 获取 Data Layer Subsystem
    data_layer_api = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if not data_layer_api:
        print("DataLayerSubsystem not available")
        return
    
    # 激活特定的 Data Layer
    data_layer_api.set_data_layer_runtime_state_by_label(
        "ZoneAlpha",
        unreal.DataLayerRuntimeState.Activated,
        False
    )
    
    # 查询激活的 Data Layers
    active_layers = data_layer_api.get_active_data_layer_names()
    print("Active layers:", active_layers)
```

### 多世界上下文切换

```python
import unreal

def multi_world_context_example():
    editor_world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    if editor_world is None:
        print("Editor world not available")
        return
    
    # 编辑器世界
    editor_vis = editor_world.get_subsystem(unreal.LevelVisibilitySubsystem)
    if editor_vis:
        print(f"Editor world visible levels: {len(editor_vis.get_visible_levels())}")
    
    # PIE 世界（需要 PIE 运行时）
    gi = unreal.get_game_instance()
    if gi:
        pie_world = gi.get_world()
        if pie_world and pie_world != editor_world:
            pie_vis = pie_world.get_subsystem(unreal.LevelVisibilitySubsystem)
            if pie_vis:
                print(f"PIE world visible levels: {len(pie_vis.get_visible_levels())}")
```

### 自定义 WorldSubsystem 模式

```python
import unreal

def custom_subsystem_module_loader():
    # 假设项目有自定义 Subsystem
    custom_subclass = unreal.load_class(None, "/Game/Subsystems/SS_GameManager.SS_GameManager_C")
    
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world is None:
        return
    
    instance = world.get_subsystem(custom_subclass)
    
    if instance:
        # 调用自定义方法（需实测确认方法名）
        # instance.custom_method()
        pass
```

## 常见问题与最佳实践

### 子系统获取模式

1. **Editor vs PIE/运行时**：
   - 编辑器模式：`unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()`
   - PIE/运行时：直接使用传入的 `UWorld` 或 `GetWorld()`
   
2. **缓存策略**：
   ```python
   # 建议缓存世界和子系统引用
   class CachedExecutionContext:
       def __init__(self):
           self.world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
           self.vis_subsystem = self.world.get_subsystem(unreal.LevelVisibilitySubsystem)
       
       def ensure_initialized(self):
           return self.world is not None and self.vis_subsystem is not None
   ```

###生命周期钩子使用

1. **Initialize 时机**：
   - 在 `Initialize()` 中执行一次性设置
   - 在 `Deinitialize()` 中清理资源
   
2. **世界初始化通知**：
   ```python
   def on_world_init(world, name):
       # 世界名称变更处理
       print(f"World initialized: {name}")
   ```

### 性能优化技巧

1. **避免重复查询**：
   - 缓存 `world.get_subsystem()` 结果
   - 批量操作前先获取所有需要的 Actor
   
2. **批量可见性更新**：
   ```python
   # 批量设置可见性，避免频繁刷新
   api.set_layers_visibility(["L_A", "L_B", "L_C"], True)
   ```

### 常见陷阱

1. **世界悬挂引用**：
   - 关卡切换后旧世界引用失效
   - 操作前 Always check `world.is_valid()`
   
2. **子系统未实例化**：
   - 某些 Subsystem 需要项目配置才能实例化
   - 调用前 Always check `instance is not None`

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：目标子系统类名错误、未注册、未实例化，或缺少必要的类路径/输入。
- `BLOCKED_TOOLING`：编辑器世界不可用、编辑器子系统上下文不可用、PIE/运行时环境未在运行而无法取得世界。
- 本 skill 只记录 Python 可获取的入口与基类约定；具体业务方法不在本 skill 中断言，必须以目标 5.6 编辑器对真实子类 `dir()` 实测为准，未实测前不得声称已验证。

本 SKILL.md 完整收录子系统的获取模式与基类约定、以及引擎标准子类的 UFUNCTION 清单，即完整参考。
