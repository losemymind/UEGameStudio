# ReflectionMixerBlueprintLibrary - 概述（UE 5.6）

## 库功能概述

`UReflectionMixerBlueprintLibrary` 是 UE 5.6 中专门用于音频反射混合（Audio Reflection Mixer）处理的蓝图函数库。该库提供了对音频反射路径（Reflection Paths）的控制、混音、空间化等高级音频效果的 API，特别是在使用 Wwise 或其他高级音频系统时非常有用。

音频反射系统模拟声音在环境中的反射行为，通过镜像源（Image Sources）与反射声学路径，实现更逼真的空间音频效果。该库允许开发者动态控制反射路径的数量、混音、增益与空间位置。

## 核心用途与场景

### 1. 空间音频效果增强
- **反射路径控制**：调整环境反射的数量与质量
- **混音平衡**：控制直达声与反射声的比例
- **空间位置同步**：使反射声与视觉场景同步

### 2. 性能优化
- **动态反射切换**：根据性能等级调整反射复杂度
- **远距离反射衰减**：远处声音使用较少反射路径
- **选择性反射**：仅对关键声音源启用反射

### 3. 交互式音频系统
- **动态环境变化**：房间大小、材质改变时更新反射
- **触发器响应**：玩家进入特定区域时改变反射效果
- **音频混合切换**：在不同场景间平滑过渡反射配置

## 更多使用示例

### 示例 1：设置反射路径数量
```python
import unreal

def set_num_reflection_paths(path_count):
    """设置最大反射路径数量"""
    # 使用 ReflectionMixerBlueprintLibrary
    result = unreal.ReflectionMixerBlueprintLibrary.set_num_reflection_paths(path_count)
    
    return {
        "status": "OK" if result else "ERROR",
        "configured_paths": path_count
    }

def get_current_reflection_paths():
    """获取当前反射路径配置"""
    max_paths = unreal.ReflectionMixerBlueprintLibrary.get_max_reflection_paths()
    current_paths = unreal.ReflectionMixerBlueprintLibrary.get_current_reflection_paths()
    
    return {
        "max_paths": max_paths,
        "current_paths": current_paths,
        "usage_percent": (current_paths / max_paths * 100) if max_paths > 0 else 0
    }
```

### 示例 2：混音增益控制
```python
import unreal

def set_reflection_gain(gain_db):
    """设置反射混音增益（分贝）"""
    result = unreal.ReflectionMixerBlueprintLibrary.set_reflection_gain(gain_db)
    
    return {
        "status": "OK" if result else "ERROR",
        "gain_db": gain_db
    }

def set_direct_vs_reflection_ratio(ratio):
    """设置直达声与反射声比例"""
    # ratio: 0.0 = only reflections, 1.0 = only direct sound
    result = unreal.ReflectionMixerBlueprintLibrary.set_direct_vs_reflection_ratio(ratio)
    
    return {
        "status": "OK" if result else "ERROR",
        "ratio": ratio,
        "direct_ratio_percent": ratio * 100,
        "reflection_ratio_percent": (1 - ratio) * 100
    }
```

### 示例 3：空间位置同步
```python
import unreal

def sync_reflection_position(sound_attenuation, listener_pos):
    """同步反射源位置与监听器"""
    # 获取当前声音源位置
    source_pos = sound_attenuation.get_origin()
    
    # 计算反射位置（简化示例）
    reflection_pos = source_pos + unreal.Vector(0.0, 0.0, 100.0)  # 示例偏移
    
    # 设置反射位置
    unreal.ReflectionMixerBlueprintLibrary.set_reflection_position(reflection_pos, listener_pos)
    
    return {
        "status": "OK",
        "source_pos": source_pos,
        "reflection_pos": reflection_pos,
        "listener_pos": listener_pos
    }

def reset_reflection_position():
    """重置反射位置到默认值"""
    result = unreal.ReflectionMixerBlueprintLibrary.reset_reflection_position()
    
    return {"status": "OK" if result else "ERROR"}
```

### 示例 4：动态环境反射切换
```python
import unreal

class DynamicReflectionManager:
    """动态反射管理器"""
    
    def __init__(self):
        self.reflection_settings = {}
        self.current_environment = None
    
    def register_environment(self, env_name, settings):
        """注册新环境的反射配置"""
        self.reflection_settings[env_name] = settings
        print(f"Registered environment: {env_name}")
    
    def switch_environment(self, env_name, listener_pos):
        """切换到指定环境"""
        if env_name not in self.reflection_settings:
            return {"status": "ERROR", "reason": "Unknown environment"}
        
        settings = self.reflection_settings[env_name]
        
        # 应用反射配置
        unreal.ReflectionMixerBlueprintLibrary.set_num_reflection_paths(settings["num_paths"])
        unreal.ReflectionMixerBlueprintLibrary.set_reflection_gain(settings["gain_db"])
        unreal.ReflectionMixerBlueprintLibrary.set_direct_vs_reflection_ratio(settings["direct_ratio"])
        
        self.current_environment = env_name
        
        return {
            "status": "OK",
            "environment": env_name,
            "settings": settings
        }

# 使用示例
def setup_reflection_environments():
    manager = DynamicReflectionManager()
    
    # 注册不同环境
    manager.register_environment("cave", {
        "num_paths": 16,
        "gain_db": -6.0,
        "direct_ratio": 0.3,
        "reverb_time": 2.0
    })
    
    manager.register_environment("hall", {
        "num_paths": 8,
        "gain_db": -3.0,
        "direct_ratio": 0.6,
        "reverb_time": 1.5
    })
    
    manager.register_environment("forest", {
        "num_paths": 4,
        "gain_db": -9.0,
        "direct_ratio": 0.8,
        "reverb_time": 0.5
    })
    
    return {"status": "OK", "environments": list(manager.reflection_settings.keys())}

def change_environment_to_cave():
    manager = DynamicReflectionManager()
    result = manager.switch_environment("cave", unreal.Vector(0.0, 0.0, 0.0))
    return result
```

### 示例 5：性能自适应反射
```python
import unreal

class PerformanceAdaptiveReflection:
    """性能自适应反射管理器"""
    
    def __init__(self):
        self.quality_settings = {
            "high": {"num_paths": 32, "gain_db": -2.0, "direct_ratio": 0.7},
            "medium": {"num_paths": 16, "gain_db": -4.0, "direct_ratio": 0.6},
            "low": {"num_paths": 8, "gain_db": -6.0, "direct_ratio": 0.5},
            "min": {"num_paths": 4, "gain_db": -9.0, "direct_ratio": 0.4}
        }
    
    def determine_quality_level(self):
        """根据性能指标确定质量等级"""
        # 实际实现需要检查系统性能
        # 这里简化为根据帧率判断
        delta_time = unreal.GEngine.get_delta_seconds()
        fps = 60.0 if delta_time == 0 else 1.0 / delta_time
        
        if fps >= 110:
            return "high"
        elif fps >= 50:
            return "medium"
        elif fps >= 30:
            return "low"
        else:
            return "min"
    
    def update_reflection_quality(self):
        """根据性能更新反射质量"""
        quality = self.determine_quality_level()
        settings = self.quality_settings[quality]
        
        unreal.ReflectionMixerBlueprintLibrary.set_num_reflection_paths(settings["num_paths"])
        unreal.ReflectionMixerBlueprintLibrary.set_reflection_gain(settings["gain_db"])
        unreal.ReflectionMixerBlueprintLibrary.set_direct_vs_reflection_ratio(settings["direct_ratio"])
        
        return {
            "status": "OK",
            "quality_level": quality,
            "settings": settings
        }

def test_performance_adaptive():
    manager = PerformanceAdaptiveReflection()
    return manager.update_reflection_quality()
```

## 高级用法与最佳实践

### 1. 性能监控与优化
- **实时监控**：定期调用 `get_current_reflection_paths()` 监控使用情况
- **动态调整**：根据帧率与内存使用动态调整反射路径数量
- **卸载控制**：在性能紧张时临时禁用反射效果

### 2. 资源管理
- **内存占用**：每个反射路径占用一定内存，注意总量控制
- **GPU 负载**：反射计算可能占用 GPU，注意与渲染负载平衡
- **音频通道**：多个反射路径占用音频通道，注意并发限制

### 3. 与 Wwise 集成（如果使用）
```python
import unreal

def integrate_with_wwise():
    """与 Wwise 高级音频引擎集成"""
    # 设置 Wwise 事件参数
    # unreal.ReflectionMixerBlueprintLibrary.set_wwise_reflection_event("RTPC_Reflection_Path_Count")
    
    # 同步 Wwise RTPC（运行时参数控制）
    # unreal.ReflectionMixerBlueprintLibrary.sync_wwise_rtpc("ReverbWetness", 0.8)
    
    return {"status": "OK", "integration": "Wwise"}
```

## 常见问题与注意事项

### 1. 音频系统要求
- **Wwise 依赖**：某些方法可能依赖 Wwise 音频系统
- **插件启用**：确保 Audio Reflection Mixer 插件已启用
- **平台支持**：不同平台的反射效果可能有差异

### 2. 性能影响
- **CPU 负载**：反射计算占用 CPU 资源
- **内存占用**：每个反射路径占用音频资源
- **并发限制**：注意同时运行的声音源数量

### 3. 阻塞状态处理
- `BLOCKED_TOOLING`：缺少音频系统支持、Wwise 未初始化
- `BLOCKED_INPUT`：无效的反射路径数量、增益值范围错误
- **验证策略**：检查音频系统初始化状态与输入参数合法性

### 4. 数值范围
- **增益范围**：通常 -60dB 到 +20dB，过高的增益可能导致失真
- **路径数量**：受音频通道限制，过大的值可能被引擎限制
- **比例范围**：直达/反射比例应在 0.0 到 1.0 之间

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.ReflectionMixerBlueprintLibrary)` 实测确认
- 个别高级方法（如 `set_wwise_reflection_event`）可能仅在启用 Wwise 插件时可用

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。