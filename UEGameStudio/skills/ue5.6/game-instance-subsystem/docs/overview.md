# GameInstanceSubsystem - 概述（UE 5.6）

## 库功能概述

`UGameInstanceSubsystem` 是 UE 5.6 中所有 Game Instance 子系统的基类，提供了一套完整的生命周期管理与全局状态持久化能力。所有继承自 `UGameInstanceSubsystem` 的子类实例都与 `UGameInstance` 绑定，在 Game Instance 创建时自动初始化，在 Game Instance 销毁时自动清理，确保数据跨关卡、跨关卡旅行保持持久。

Game Instance Subsystem 是 UE 4.26+ 引入的架构模式，用于管理需要在多个关卡间保持的全局状态与服务，替代了 older 版本中的 `UGameUserSettings` 与全局单例模式。

## 核心用途与场景

### 1. 全局状态管理
- **玩家偏好设置**：难度、音量、控制映射、UI 布局
- **持久化游戏数据**：解锁内容、成就、收集品进度
- **跨关卡会话状态**：当前任务、目标、团队配置

### 2. 全局服务提供
- **网络管理**：会话创建、查找、加入
- **存档/读档**：管理持久化数据的读写
- **热更新**：处理运行时 asset 更新

### 3. 多玩家会话支持
- **本地玩家状态**：每个本地玩家的独立状态
- **多人会话数据**：房间设置、队伍分配、队伍状态
- **跨玩家数据同步**：共享游戏内信息

## 更多使用示例

### 示例 1：创建自定义 GameInstanceSubsystem
```python
import unreal

# 定义 GameInstanceSubsystem 子类
class MyGameInstanceSubsystem(unreal.GameInstanceSubsystem):
    def __init__(self):
        super().__init__()
        self.player_preferences = {
            "volume_music": 0.8,
            "volume_sfx": 0.7,
            "difficulty": "Normal",
            "last_save_slot": None
        }
        self.persistent_data = {}
    
    @unreal.ufunction
    def initialize(self):
        """Game Instance 初始化时调用"""
        print("MyGameInstanceSubsystem initialized")
        self.load_preferences()
        self.load_persistent_data()
    
    @unreal.ufunction
    def deinitialize(self):
        """Game Instance 销毁时调用"""
        print("MyGameInstanceSubsystem deinitialize")
        self.save_preferences()
        self.save_persistent_data()
    
    @unreal.ufunction(BlueprintCallable)
    def set_volume_music(self, volume):
        """设置音乐音量"""
        self.player_preferences["volume_music"] = volume
        # 应用到音频系统
        # unreal.AudioMixerBlueprintLibrary.set_master_bus_volume(volume)
    
    @unreal.ufunction(BlueprintCallable)
    def set_volume_sfx(self, volume):
        """设置音效音量"""
        self.player_preferences["volume_sfx"] = volume
    
    @unreal.ufunction(BlueprintCallable)
    def set_difficulty(self, difficulty):
        """设置游戏难度"""
        self.player_preferences["difficulty"] = difficulty
    
    @unreal.ufunction(BlueprintCallable)
    def save_progress(self, save_slot):
        """保存游戏进度"""
        self.player_preferences["last_save_slot"] = save_slot
        self.persistent_data["save_slot"] = save_slot
        self.persistent_data["timestamp"] = unreal.DateTime.now().to_unix_timestamp()
        # 调用保存系统
        # unreal.GameplayStatics.save_game_to_slot(...)
    
    def load_preferences(self):
        """加载用户偏好设置"""
        # 实际实现：从配置文件或注册表读取
        pass
    
    def save_preferences(self):
        """保存用户偏好设置"""
        # 实际实现：写入配置文件或注册表
        pass
    
    def load_persistent_data(self):
        """加载持久化数据"""
        # 实际实现：从保存文件读取
        self.persistent_data = {"save_slot": "save_001"}
    
    def save_persistent_data(self):
        """保存持久化数据"""
        # 实际实现：写入保存文件
        pass
```

### 示例 2：获取与使用 GameInstanceSubsystem
```python
import unreal

def use_game_instance_subsystem():
    """获取并使用 GameInstanceSubsystem"""
    # 获取 Game Instance
    game_instance = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    if game_instance is None:
        return {"status": "BLOCKED_TOOLING", "reason": "Game Instance not available"}
    
    # 获取子系统实例
    try:
        my_subsystem = game_instance.get_subsystem(unreal.MyGameInstanceSubsystem)
        
        if my_subsystem is None:
            return {"status": "BLOCKED_INPUT", "reason": "Subsystem not instantiated"}
        
        # 调用子系统方法
        my_subsystem.set_volume_music(0.6)
        my_subsystem.set_volume_sfx(0.5)
        my_subsystem.set_difficulty("Hard")
        my_subsystem.save_progress("save_002")
        
        return {"status": "OK", "preferences": my_subsystem.player_preferences}
    
    except Exception as e:
        return {"status": "ERROR", "reason": str(e)}
```

### 示例 3：跨关卡状态保持
```python
import unreal

class LevelProgressSubsystem(unreal.GameInstanceSubsystem):
    """关卡进度子系统 - 跨关卡保持"""
    
    def __init__(self):
        super().__init__()
        self.current_level = None
        self.completed_levels = []
        self.total_score = 0
    
    @unreal.ufunction
    def on_primary_asset_ready(self, primary_asset_id):
        """Primary Asset 准备就绪时"""
        # 处理资产加载完成后的逻辑
        pass
    
    @unreal.ufunction(BlueprintCallable)
    def level_completed(self, level_name, score):
        """关卡完成回调"""
        if level_name not in self.completed_levels:
            self.completed_levels.append(level_name)
        self.total_score += score
        print(f"Level {level_name} completed, score: {score}, total: {self.total_score}")
    
    @unreal.ufunction(BlueprintCallable)
    def get_level_progress(self):
        """获取关卡进度统计"""
        return {
            "completed_levels": self.completed_levels,
            "total_levels_completed": len(self.completed_levels),
            "total_score": self.total_score
        }

# 使用示例
def track_level_completion(level_name, score):
    game_instance = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    subsystem = game_instance.get_subsystem(unreal.LevelProgressSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    subsystem.level_completed(level_name, score)
    return subsystem.get_level_progress()
```

### 示例 4：多人会话状态管理
```python
import unreal

class SessionManagerSubsystem(unreal.GameInstanceSubsystem):
    """会话管理子系统"""
    
    def __init__(self):
        super().__init__()
        self.current_session = None
        self.session_listeners = []
        self.player_teams = {}
    
    @unreal.ufunction(BlueprintCallable)
    def create_session(self, session_name, max_players=4):
        """创建多人会话"""
        # 实际实现需要调用 OnlineSubsystem
        # self.session_interface.create_session(0, session_name, settings)
        self.current_session = {
            "name": session_name,
            "max_players": max_players,
            "current_players": 1,
            "public": True
        }
        return {"status": "OK", "session": self.current_session}
    
    @unreal.ufunction(BlueprintCallable)
    def join_session(self, session_name):
        """加入指定会话"""
        if self.current_session and self.current_session["name"] == session_name:
            if self.current_session["current_players"] < self.current_session["max_players"]:
                self.current_session["current_players"] += 1
                return {
                    "status": "OK",
                    "session": self.current_session,
                    "player_joined": True
                }
        return {"status": "ERROR", "reason": "Session not found or full"}
    
    @unreal.ufunction(BlueprintCallable)
    def set_player_team(self, player_name, team_name):
        """设置玩家队伍"""
        self.player_teams[player_name] = team_name
        return {"status": "OK", "player": player_name, "team": team_name}
    
    @unreal.ufunction(BlueprintCallable)
    def get_team_members(self, team_name):
        """获取队伍成员列表"""
        return [p for p, t in self.player_teams.items() if t == team_name]

# 使用示例
def manage_multiplayer_session():
    game_instance = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    subsystem = game_instance.get_subsystem(unreal.SessionManagerSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 创建会话
    subsystem.create_session("MyLobby", 4)
    
    # 加入会话（其他玩家）
    subsystem.join_session("MyLobby")
    
    # 设置队伍
    subsystem.set_player_team("Player1", "Red")
    subsystem.set_player_team("Player2", "Blue")
    
    return {"status": "OK", "teams": subsystem.player_teams}
```

## 高级用法与最佳实践

### 1. 子系统注册与初始化
- **自动注册**：继承 `UGameInstanceSubsystem` 并标记 `UCLASS()` 即自动注册
- **类名映射**：Python 中使用去掉 `U` 前缀的类名
- **初始化时机**：在 Game Instance 创建后自动调用 `Initialize()`
- **清理时机**：在 Game Instance 销毁前自动调用 `Deinitialize()`

### 2. 生命周期钩子详解
- **Initialize**：Game Instance 初始化时调用，适合初始化全局服务
- **Deinitialize**：Game Instance 销毁前调用，适合清理资源与保存数据
- **BeginDestroy**：子系统销毁前的最后清理机会
- **OnPrimaryAssetReady**：Primary Asset 加载完成时触发

### 3. 性能优化建议
- **懒加载**：在 `Initialize` 中延迟加载大型资源
- **资源复用**：在子系统中缓存常用资源
- **内存管理**：在 `Deinitialize` 中释放所有分配的资源
- **避免阻塞**：长时间初始化使用异步任务

### 4. 与 WorldSubsystem 的区别
- **GameInstanceSubsystem**：与 `UGameInstance` 绑定，全局持久，跨关卡存活
- **WorldSubsystem**：与 `UWorld` 绑定，按世界隔离，关卡专用
- **选择准则**：数据需跨关卡持久 → GameInstanceSubsystem；仅当前关卡需要 → WorldSubsystem

### 5. 与 PlayerSubsystem 的区别
- **GameInstanceSubsystem**：所有玩家共享，全局一次
- **PlayerSubsystem**：每个玩家独立实例，玩家专属
- **选择准则**：全局配置 → GameInstanceSubsystem；玩家独立状态 → PlayerSubsystem

## 常见问题与注意事项

### 1. 实例获取与生命周期
- **自动创建**：首次 `get_subsystem()` 时自动创建，无需手动 `new`
- **生命周期绑定**：自动随 Game Instance 销毁，无需手动 `delete`
- **空指针检查**：`get_subsystem()` 可能返回 `None`，务必检查
- **PIE 隔离**：PIE 会话有独立的 Game Instance 实例

### 2. 编辑器与运行时环境
- **编辑器主世界**：Game Instance 在编辑器中也存在（用于编辑器行为）
- **PIE 专用**：PIE 有独立的 Game Instance 实例
- **运行时**：打包游戏有独立的 Game Instance 实例

### 3. 子类实现限制
- **UFUNCTION**：仅 BlueprintCallable/BlueprintPure 方法暴露给蓝图和 Python
- **虚函数**：Initialize/Deinitialize 等为虚函数，子类覆盖实现
- **构造函数**：可在 `__init__` 中初始化成员，但资源创建放 `Initialize`

### 4. 多线程与并发
- **游戏线程**：多数操作在游戏线程执行
- **加载线程**：异步加载在加载线程执行
- **线程安全**：跨线程访问需加锁或使用原子操作

### 5. 阻塞状态处理
- `BLOCKED_INPUT`：子系统类名错误、未注册、未实例化
- `BLOCKED_TOOLING`：Game Instance 不可用、运行时上下文不可用
- **最佳实践**：先检查 Game Instance 有效性，再获取子系统，最后调用方法

### 6. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.YourSubclass)` 实测确认
- 个别生命周期钩子可能需在子类中手动声明

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。