# DataLayerSubsystem - 概述（UE 5.6）

## 库功能概述

`UDataLayerSubsystem` 是 UE 5.6 中用于管理 Data Layer（数据层）运行时状态的子系统。Data Layer 是 UE 5 引入的大规模世界组织技术，用于控制不同区域、环境条件、游戏阶段的数据加载与激活。该子系统提供了对 Data Layer 的创建、查询、激活/去激活等运行时状态管理能力。

**重要提示**：根据头文件声明，该类在 UE 5.6 中已被 `UDataLayerManager` 取代，保留的 `UDataLayerSubsystem` 仅用于向后兼容，新实现应优先使用 `UDataLayerManager` 等价 API。

## 核心用途与场景

### 1. 大型开放世界分区控制
- **区域加载管理**：根据玩家位置激活/去激活不同区域的 Data Layer
- **环境阶段控制**：根据游戏进度（白天/黑夜、天气、事件阶段）切换 Data Layer
- **性能优化**：仅加载当前必需的 Data Layer，减少内存与 CPU 负载

### 2. 运行时状态查询
- **激活状态查询**：获取 Data Layer 的当前激活、加载、可用状态
- **有效性检查**：确认 Data Layer 是否已注册、是否可被访问
- **批量查询**：一次性查询多个 Data Layer 的状态

### 3. 状态设置与控制
- **激活指定层**：在运行时激活特定 Data Layer
- **去激活层**：关闭不再需要的 Data Layer
- **递归设置**：控制设置是否影响子层（inheritance）

## 更多使用示例

### 示例 1：获取 DataLayerSubsystem
```python
import unreal

def get_data_layer_subsystem():
    """获取 DataLayerSubsystem 实例"""
    # 编辑器世界
    editor_world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    editor_subsystem = editor_world.get_subsystem(unreal.DataLayerSubsystem)
    
    # PIE/运行时世界
    game_instance = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    runtime_world = game_instance.get_world()
    runtime_subsystem = runtime_world.get_subsystem(unreal.DataLayerSubsystem)
    
    return {
        "editor_world_available": editor_subsystem is not None,
        "runtime_world_available": runtime_subsystem is not None
    }
```

### 示例 2：查询 Data Layer 状态
```python
import unreal

def query_data_layer_state():
    """查询 Data Layer 状态"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 通过资产查询
    # data_layer_asset = unreal.load_object(None, "/Game/DataLayers/Layer_ZoneA.Layer_ZoneA")
    # if data_layer_asset:
    #     state = subsystem.get_data_layer_instance_runtime_state(data_layer_asset)
    
    # 通过名称查询
    layer_instance = subsystem.get_data_layer_from_name("ZoneAlpha")
    if layer_instance:
        state = subsystem.get_data_layer_runtime_state(layer_instance)
    
    return {
        "status": "OK",
        "note": "State values: Unloaded, Activated, Loaded"
    }

def query_active_layers():
    """查询当前激活的 Data Layer 名称"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 注意：在 UE 5.6 中，get_active_data_layer_names() 返回空集合
    # 应使用其他方式查询激活状态
    
    # 通过标签查询所有 layer 名称
    layer_names = []
    # 实际实现需要遍历所有层
    # subsystem.add_all_layer_names_to(layer_names)
    
    return {
        "status": "OK",
        "layer_names": layer_names,
        "note": "UE 5.6 中 get_active_data_layer_names() 已停用"
    }
```

### 示例 3：设置 Data Layer 运行时状态
```python
import unreal

def set_data_layer_state(layer_name, target_state, is_recursive=False):
    """设置 Data Layer 的运行时状态"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 注意：所有 Set 方法带 BlueprintAuthorityOnly，仅权威端可生效
    # 编辑器主世界、非权威客户端调用不会产生预期效果
    
    # 通过名称设置状态
    result = subsystem.set_data_layer_runtime_state_by_label(
        layer_name, 
        target_state, 
        is_recursive
    )
    
    return {
        "status": "OK",
        "layer_name": layer_name,
        "target_state": target_state,
        "is_recursive": is_recursive
    }

def activate_zone(zone_name):
    """激活指定区域的 Data Layer"""
    # 区域状态枚举值需参考目标 5.6 编辑器
    activated_state = unreal.DataLayerRuntimeState.Activated  # 示例
    
    return set_data_layer_state(zone_name, activated_state, False)
```

### 示例 4：批量管理多个 Data Layer
```python
import unreal

def batch_manage_data_layers():
    """批量管理 Data Layer"""
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    subsystem = world.get_subsystem(unreal.DataLayerSubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 激活所有关键区域
    critical_zones = ["Zone_Alpha", "Zone_Beta", "Zone_Gamma"]
    
    results = []
    for zone in critical_zones:
        result = subsystem.set_data_layer_runtime_state_by_label(
            zone,
            unreal.DataLayerRuntimeState.Activated,
            False  # 不递归
        )
        results.append({"zone": zone, "result": result})
    
    # 去激活非关键区域
    non_critical_zones = ["Zone_Delta", "Zone_Epsilon"]
    
    for zone in non_critical_zones:
        result = subsystem.set_data_layer_runtime_state_by_label(
            zone,
            unreal.DataLayerRuntimeState.Unloaded,
            False
        )
        results.append({"zone": zone, "result": result})
    
    return {
        "status": "OK",
        "total_zones": len(critical_zones) + len(non_critical_zones),
        "results": results
    }

def switch_day_night_cycle():
    """切换昼夜循环的 Data Layer"""
    # 白天层
    day_state = unreal.DataLayerRuntimeState.Activated
    night_state = unreal.DataLayerRuntimeState.Unloaded
    
    # 夜晚层
    # day_state = unreal.DataLayerRuntimeState.Unloaded
    # night_state = unreal.DataLayerRuntimeState.Activated
    
    subsystem.set_data_layer_runtime_state_by_label("Layer_Day", day_state, False)
    subsystem.set_data_layer_runtime_state_by_label("Layer_Night", night_state, False)
    
    return {"status": "OK", "cycle": "switched"}
```

### 示例 5：与游戏逻辑集成
```python
import unreal

class DataLayerGameManager:
    """Data Layer 游戏管理器"""
    
    def __init__(self):
        self.current_zone = None
        self.zone_layers = {}
        self.load_layers()
    
    def load_layers(self):
        """加载所有 Zone 的 Data Layer 配置"""
        self.zone_layers = {
            "Town": ["Layer_Town_Day", "Layer_Town_Night"],
            "Forest": ["Layer_Forest_Day", "Layer_Forest_Night"],
            "Cave": ["Layer_Cave_Dark"]
        }
    
    def enter_zone(self, zone_name):
        """进入指定区域，激活对应 Data Layer"""
        if zone_name not in self.zone_layers:
            return {"status": "ERROR", "reason": "Unknown zone"}
        
        previous_zone = self.current_zone
        self.current_zone = zone_name
        
        # 去激活 previous zone layers
        if previous_zone and previous_zone in self.zone_layers:
            for layer in self.zone_layers[previous_zone]:
                subsystem = unreal.LevelVisibilitySubsystem  # 示例
                # subsystem.set_data_layer_runtime_state_by_label(layer, unreal.DataLayerRuntimeState.Unloaded, False)
        
        # 激活 new zone layers
        for layer in self.zone_layers[zone_name]:
            layer_instance = subsystem.get_data_layer_from_name(layer)
            if layer_instance:
                subsystem.set_data_layer_runtime_state(layer_instance, 
                    unreal.DataLayerRuntimeState.Activated, False)
        
        return {"status": "OK", "zone": zone_name, "layers": self.zone_layers[zone_name]}
    
    def change_timeOfDay(self, time_of_day):
        """改变时间（白天/夜晚）"""
        subsystem = unreal.LevelVisibilitySubsystem
        
        for zone_name, layers in self.zone_layers.items():
            for layer in layers:
                if "Day" in layer and time_of_day == "Night":
                    subsystem.set_data_layer_runtime_state_by_label(layer, 
                        unreal.DataLayerRuntimeState.Unloaded, False)
                elif "Night" in layer and time_of_day == "Day":
                    subsystem.set_data_layer_runtime_state_by_label(layer, 
                        unreal.DataLayerRuntimeState.Unloaded, False)
                else:
                    subsystem.set_data_layer_runtime_state_by_label(layer, 
                        unreal.DataLayerRuntimeState.Activated, False)
        
        return {"status": "OK", "time_of_day": time_of_day}

# 使用示例
def game_manager_example():
    manager = DataLayerGameManager()
    manager.enter_zone("Town")
    manager.change_timeOfDay("Night")
    return {"status": "OK", "manager": "initialized"}
```

## 高级用法与最佳实践

### 1. 权威端操作
- **仅服务器/主机**：所有状态设置（Set_*）方法仅在权威端（服务器、PIE 中的主机）生效
- **客户端查询**：客户端可查询状态，但无法修改
- **网络同步**：修改后需通过 RPC 或复制机制同步到客户端

### 2. 性能优化
- **按需加载**：仅在需要时激活 Data Layer，避免过度加载
- **预缓存**：频繁切换的层可提前预加载
- **批量操作**：批量激活/去激活多个层，减少系统调用

### 3. 错误处理
- **层不存在**：查询不存在的层返回 None 或空结果
- **状态冲突**：尝试对已处于目标状态的层设置相同状态通常无副作用
- **递归设置**：启用递归设置时注意影响的层树深度

## 常见问题与注意事项

### 1. 弃用声明
- **已弃用**：该类在 UE 5.6 中已被标记为弃用（DEPRECATED）
- **新 API**：推荐使用 `UDataLayerManager` 及等价 API
- **遗留代码**：仅在迁移尚未完成时使用本库

### 2. 编辑器与运行时
- **运行时概念**：Data Layer 状态是运行时概念，在 PIE/打包运行中才体现真实状态
- **编辑器主世界**：编辑器主世界也可能支持，但状态与 PIE 不同
- **PIE 专用**：运行时操作仅在 PIE / Play 会话中最有效

### 3. 阻塞状态处理
- `BLOCKED_TOOLING`：世界或子系统不可用、编辑器上下文不可用
- `BLOCKED_INPUT`：Data Layer 未配置、未加载资产、层名称无效
- **最佳实践**：先检查世界与子系统，再查询层状态，最后修改状态

### 4. 状态枚举
- **EDataLayerRuntimeState**：Unloaded、Activated、Loaded
- **EDataLayerState**：旧式状态枚举（部分情况下仍可用）
- **Effective 状态**：考虑继承关系后的有效状态

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理
- 状态枚举值、方法名、标签/名称/资产引用需在目标编辑器中实测确认
- `UDataLayerManager` 的等价 API 可能提供更多功能

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。