# WorldSubsystem - 概述（UE 5.6）

## 库功能概述

`UWorldSubsystem` 是 UE 5.6 引擎中所有 World 子系统的基类，提供了一套完整的生命周期管理与世界隔离机制。所有继承自 `UWorldSubsystem` 的子类实例都与特定的 `UWorld` 实例绑定，在世界创建时自动初始化，在世界销毁时自动清理，确保数据作用域与世界生命周期一致。

World 子系统是 UE 5 引入的架构模式，替代了 older 版本中的 `UGameInstanceSubsystem` 和 `UPlayerSubsystem`，提供了更清晰的职责划分与更好的多世界支持（如 PIE、编辑器、异步关卡流送）。

## 核心用途与场景

### 1. 世界范围的数据管理
- **关卡状态**：存储与特定关卡相关的数据（如任务完成状态、环境变量）
- **全局服务**：提供世界范围的服务（如音效混音管理、网络同步服务）
- **临时数据缓存**：缓存当前世界的计算结果，避免重复计算

### 2. 生命周期钩子
- **Initialize/Deinitialize**：在世界初始化/销毁时执行自定义逻辑
- **OnWorldInitializedName**：当世界获得名字时触发
- **OnWorldBeginTravel**/**OnWorldEndTravel**：关卡旅行（加载/卸载）时触发

### 3. 多世界支持
- **独立实例**：每个 `UWorld` 有自己的子系统实例
- **PIE 专用**：PIE 会话有独立的实例，不与编辑器主世界冲突
- **异步流送**：支持异步加载的关卡具有独立的子系统状态

## 更多使用示例

### 示例 1：创建自定义 WorldSubsystem
```python
import unreal

# 定义 WorldSubsystem 子类
class MyCustomWorldSubsystem(unreal.WorldSubsystem):
    def __init__(self):
        super().__init__()
        self.custom_data = {}
    
    @unreal.ufunction
    def initialize(self):
        """世界初始化时调用"""
        self.custom_data["initialized_at"] = unreal.DateTime.now().to_unix_timestamp()
        print(f"MyCustomWorldSubsystem initialized at {self.custom_data['initialized_at']}")
    
    @unreal.ufunction
    def deinitialize(self):
        """世界销毁时调用"""
        print("MyCustomWorldSubsystem deinitialized")
    
    @unreal.ufunction(BlueprintCallable)
    def add_game_event(self, event_name):
        """记录游戏事件"""
        if "events" not in self.custom_data:
            self.custom_data["events"] = []
        self.custom_data["events"].append(event_name)
    
    @unreal.ufunction(BlueprintCallable)
    def get_game_events(self):
        """获取所有记录的事件"""
        return self.custom_data.get("events", [])
```

### 示例 2：获取与使用 WorldSubsystem
```python
import unreal

def use_world_subsystem():
    """获取并使用 WorldSubsystem"""
    # 获取编辑器世界
    editor_subsystem = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
    world = editor_subsystem.get_editor_world()
    
    if world is None:
        return {"status": "BLOCKED_TOOLING", "reason": "Editor world not available"}
    
    # 获取子系统实例
    try:
        my_subsystem = world.get_subsystem(unreal.MyCustomWorldSubsystem)
        
        if my_subsystem is None:
            return {"status": "BLOCKED_INPUT", "reason": "Subsystem not instantiated"}
        
        # 调用子系统方法
        my_subsystem.add_game_event("LevelStart")
        my_subsystem.add_game_event("PlayerSpawn")
        
        events = my_subsystem.get_game_events()
        
        return {"status": "OK", "events": events}
    
    except Exception as e:
        return {"status": "ERROR", "reason": str(e)}
```

### 示例 3：PIE 专用实例管理
```python
import unreal

def check_pie_instance_separation():
    """验证 PIE 与编辑器实例的隔离性"""
    editor_world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    # 编辑器世界实例
    my_subsystem_editor = editor_world.get_subsystem(unreal.MyCustomWorldSubsystem)
    
    if my_subsystem_editor:
        my_subsystem_editor.add_game_event("EditorSession")
    
    # PIE 世界实例（需要运行 PIE）
    # 注意：在非 PIE 环境下，PIE world 为 None
    
    return {
        "editor_instance": my_subsystem_editor is not None,
        "editor_events": my_subsystem_editor.get_game_events() if my_subsystem_editor else []
    }
```

### 示例 4：异步关卡流送支持
```python
import unreal

class LevelStreamManager(unreal.WorldSubsystem):
    """关卡流送管理器"""
    
    def __init__(self):
        super().__init__()
        self.loaded_levels = {}
    
    @unreal.ufunction
    def on_world_begin_travel(self, level_name):
        """关卡开始流送时"""
        print(f"Streaming begin: {level_name}")
        self.loaded_levels[level_name] = False
    
    @unreal.ufunction
    def on_world_end_travel(self, level_name):
        """关卡流送完成"""
        print(f"Streaming complete: {level_name}")
        self.loaded_levels[level_name] = True
    
    @unreal.ufunction(BlueprintCallable)
    def is_level_loaded(self, level_name):
        return self.loaded_levels.get(level_name, False)
```

### 示例 5：世界数据持久化
```python
import unreal

class persistent_state_system(unreal.WorldSubsystem):
    """持久化状态系统"""
    
    def __init__(self):
        super().__init__()
        self.save_data = {}
        self.load_data = {}
    
    @unreal.ufunction
    def initialize(self):
        # 加载保存的数据
        self.save_data = self.load_from_save()
    
    @unreal.ufunction
    def deinitialize(self):
        # 保存数据到磁盘
        self.save_to_save()
    
    def load_from_save(self):
        """从保存中加载数据"""
        # 实际实现需要结合 SaveGame 系统
        return {"level": 1, "score": 0}
    
    def save_to_save(self):
        """保存数据到磁盘"""
        # 实际实现需要结合 SaveGame 系统
        print(f"Saving state: {self.save_data}")
    
    @unreal.ufunction(BlueprintCallable)
    def update_state(self, key, value):
        self.save_data[key] = value
    
    @unreal.ufunction(BlueprintCallable)
    def get_state(self, key):
        return self.save_data.get(key, None)
```

## 高级用法与最佳实践

### 1. 子系统注册与配置
- **自动注册**：继承 `UWorldSubsystem` 并标记 `UCLASS()` 即自动注册
- **类名映射**：Python 中使用去掉 `U` 前缀的类名（`UWorldSubsystem` → `unreal.WorldSubsystem`）
- **子类查询**：使用 `world.get_subsystem(unreal.YourSubclass)` 获取实例

### 2. 生命周期钩子详解
- **Initialize**：世界创建后、第一次使用前调用，适合初始化资源
- **Deinitialize**：世界销毁前调用，适合清理资源
- **OnWorldInitializedName**：世界获得名字时触发，适合依赖场景名的逻辑
- **OnWorldBeginTravel/EndTravel**：关卡流送时触发，适合流送状态管理

### 3. 性能优化建议
- **懒加载**：在 `Initialize` 中延迟加载大型资源
- **资源复用**：在子系统中缓存常用资源（ textures、sounds、materials）
- **内存管理**：在 `Deinitialize` 中释放所有分配的资源

### 4. 与 GameInstanceSubsystem 的区别
- **WorldSubsystem**：与 `UWorld` 绑定，多世界隔离，关卡专用
- **GameInstanceSubsystem**：与 `UGameInstance` 绑定，全局持久，跨关卡存活
- **选择准则**：数据仅当前关卡需要 → WorldSubsystem；需跨关卡持久 → GameInstanceSubsystem

### 5. 与 PlayerSubsystem 的区别
- **WorldSubsystem**：所有玩家共享，世界范围
- **PlayerSubsystem**：每个玩家独立实例，玩家专属
- **选择准则**：玩家独立状态 → PlayerSubsystem；全局状态 → WorldSubsystem

## 常见问题与注意事项

### 1. 实例获取与生命周期
- **自动创建**：首次 `get_subsystem()` 时自动创建，无需手动 `new`
- **生命周期绑定**：自动随世界销毁，无需手动 `delete`
- **空指针检查**：`get_subsystem()` 可能返回 `None`，务必检查

### 2. 编辑器与运行时环境
- **PIE 隔离**：PIE 有独立的实例，不与编辑器冲突
- **编辑器主世界**：使用 `unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()` 获取
- **运行时世界**：传入运行时的 `UWorld` 对象

### 3. 子类实现限制
- **UFUNCTION**：仅 BlueprintCallable/BlueprintPure 方法暴露给蓝图和 Python
- **虚函数**：Initialize/Deinitialize 等为虚函数，子类覆盖实现
- **构造函数**：可在 `__init__` 中初始化成员，但资源创建放 `Initialize`

### 4. 多线程与并发
- **编辑器线程**：多数操作在编辑器线程执行
- **游戏线程**：运行时操作在游戏线程执行
- **线程安全**：跨线程访问需加锁或使用原子操作

### 5. 阻塞状态处理
- `BLOCKED_INPUT`：子系统类名错误、未注册、未实例化
- `BLOCKED_TOOLING`：世界不可用、编辑器子系统不可用、PIE 未运行
- **最佳实践**：先检查世界有效性，再获取子系统，最后调用方法

### 6. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.YourSubclass)` 实测确认
- 个别生命周期钩子（如 `OnActorAddedToWorld`）可能需在子类中手动声明

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。