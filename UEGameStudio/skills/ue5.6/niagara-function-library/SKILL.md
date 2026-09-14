---
name: niagara-function-library
description: UNiagaraFunctionLibrary（UE 5.6）Niagara特效函数库 - 系统创建/发射/查询、数据接口、特效控制；在 Agent 需要通过 unreal Python 控制 Niagara 特效时使用
risk: safe
category: development
tags: [ue5.6, niagara, particles, python, statics]
---

# NiagaraFunctionLibrary - Niagara特效工具库（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 控制 Niagara 特效时使用本 skill（description 触发场景）。
- 本 skill 只在与 niagara-function-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UNiagaraFunctionLibrary`（`UObject` 派生，**静态类**）通过 Python 可调用的类方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Engine/NIagaraFunctionLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UNiagaraFunctionLibrary` 在 Python 中以类方法形式暴露在 `unreal.NiagaraFunctionLibrary` 上：

```python
import unreal

# 示例：在指定位置发射粒子系统
unreal.NiagaraFunctionLibrary.spawn_system_at_location(
    world_context, unreal.load_asset("/Game/Niagara/Sys_Explosion"),
    unreal.Vector(0.0, 0.0, 100.0), unreal.Rotator(0.0, 0.0, 0.0)
)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.NiagaraFunctionLibrary)` 核对）。
- 大部分方法需要有效的 `WorldContextObject`（如 `get_game_instance()` 或任意已归入世界的 Actor）。
- 带 `WITH_EDITOR` 限定的方法仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **系统创建与发射** | | | |
| 发射 | `spawn_system_at_location(world_context, system_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAtLocation(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_system_around_point(world_context, system_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnSystemAroundPoint(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_emitter_at_location(world_context, emitter_template, location, rotation, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAtLocation(...)` | `NiagaraComponent` 或 `None` |
| 发射 | `spawn_emitter_around_point(world_context, emitter_template, origin, radius, b_random_offset, scale, b_auto_destroy)` | `UNiagaraComponent* SpawnEmitterAroundPoint(...)` | `NiagaraComponent` 或 `None` |
| **查询与控制** | | | |
| 查询 | `get_system_bounds(world_context, system)` | `FBoxSphereBounds GetSystemBounds(...)` | `BoxSphereBounds` |
| 查询 | `get_system_age(world_context, system)` | `float GetSystemAge(...)` | `float` |
| 查询 | `get_emitter_count(world_context, system)` | `int GetEmitterCount(...)` | `int` |
| 查询 | `get_emitter_name(world_context, system, emitter_index)` | `FString GetEmitterName(...)` | `str` |
| 控制 | `set_paused(world_context, system, b_paused)` | `void SetPaused(...)` | `None` |
| 控制 | `is_paused(world_context, system)` | `bool IsPaused(...)` | `bool` |
| 控制 | `set_speed(world_context, system, speed)` | `void SetSpeed(...)` | `None` |
| 控制 | `get_speed(world_context, system)` | `float GetSpeed(...)` | `float` |
| **数据接口** | | | |
| 数据 | `set_vector_param(world_context, system, param_name, value)` | `bool SetVectorParameter(...)` | `bool` |
| 数据 | `set_vector4_param(world_context, system, param_name, value)` | `bool SetVector4Parameter(...)` | `bool` |
| 数据 | `set_color_param(world_context, system, param_name, value)` | `bool SetColorParameter(...)` | `bool` |
| 数据 | `set_scalar_param(world_context, system, param_name, value)` | `bool SetScalarParameter(...)` | `bool` |
| 数据 | `set_bool_param(world_context, system, param_name, value)` | `bool SetBoolParameter(...)` | `bool` |
| 数据 | `set_transform_param(world_context, system, param_name, value, b_only_affect_parent)` | `bool SetTransformParameter(...)` | `bool` |
| 数据 | `set_asset_param(world_context, system, param_name, value)` | `bool SetAssetParameter(...)` | `bool` |
| **其他** | | | |
| 辅助 | `get_scatter_samples(world_context, system, sample_count, out_samples)` | `bool GetScatterSamples(...)` | `(bool, Array[Transform])` |
| 辅助 | `get_emitter_sample_count(world_context, system, emitter_index)` | `int GetEmitterSampleCount(...)` | `int` |

## 示例

```python
import unreal

def control_niagara():
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    api = unreal.NiagaraFunctionLibrary
    
    # 在指定位置发射粒子系统
    system_template = unreal.load_asset("/Game/Niagara/Sys_Explosion")
    system = api.spawn_system_at_location(
        world_context, system_template,
        unreal.Vector(100.0, 0.0, 50.0),
        unreal.Rotator(0.0, 0.0, 0.0),
        unreal.Vector(1.0, 1.0, 1.0),
        True
    )
    
    # 设置系统参数
    api.set_vector_param(world_context, system, "SpawnPosition", unreal.Vector(0.0, 0.0, 0.0))
    api.set_scalar_param(world_context, system, "EmissionRate", 100.0)
    
    # 暂停/恢复
    api.set_paused(world_context, system, True)
    unreal.delay(2.0)
    api.set_paused(world_context, system, False)
    
    # 查询系统年龄
    age = api.get_system_age(world_context, system)
    print("system age:", age)

if __name__ == "__main__":
    control_niagara()
```

## 综合实战示例

### Niagara粒子系统管理系统

```python
import unreal

class NiagaraSystemManager:
    def __init__(self):
        self.api = unreal.NiagaraFunctionLibrary
        self.world = None
        self.systems = []
    
    def initialize(self):
        self.world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
        return self.world is not None
    
    def spawn_system(self, template, location, scale=1.0):
        if self.world:
            system = self.api.spawn_system_at_location(
                self.world,
                template,
                location,
                unreal.Rotator(0.0, 0.0, 0.0),
                unreal.Vector(scale, scale, scale),
                True
            )
            self.systems.append(system)
            return system
        return None
    
    def set_parameter(self, system, param_name, value):
        if self.world and system:
            # 根据参数类型自动选择设置方法
            if isinstance(value, unreal.Vector):
                self.api.set_vector_param(self.world, system, param_name, value)
            elif isinstance(value, float):
                self.api.set_scalar_param(self.world, system, param_name, value)
            elif isinstance(value, bool):
                self.api.set_bool_param(self.world, system, param_name, value)
            return True
        return False
    
    def pause_all(self):
        if self.world:
            for system in self.systems:
                self.api.set_paused(self.world, system, True)
            return True
        return False
    
    def resume_all(self):
        if self.world:
            for system in self.systems:
                self.api.set_paused(self.world, system, False)
            return True
        return False

def manage_niagara_systems():
    manager = NiagaraSystemManager()
    
    if not manager.initialize():
        print("Failed to initialize")
        return
    
    # 加载粒子系统模板
    explosion = unreal.load_asset("/Game/Niagara/Sys_Explosion")
    smoke = unreal.load_asset("/Game/Niagara/Sys_Smoke")
    
    # 在不同位置发射
    manager.spawn_system(explosion, unreal.Vector(0.0, 0.0, 100.0), 1.0)
    manager.spawn_system(smoke, unreal.Vector(100.0, 0.0, 50.0), 1.5)
    
    # 修改参数
    if manager.systems:
        manager.set_parameter(manager.systems[0], "EmissionRate", 200.0)
    
    # 暂停所有系统
    manager.pause_all()
    unreal.delay(2.0)
    manager.resume_all()
```

### 粒子系统参数控制器

```python
import unreal

class NiagaraParameterController:
    def __init__(self):
        self.api = unreal.NiagaraFunctionLibrary
        self.world = None
    
    def initialize(self):
        self.world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
        return self.world is not None
    
    def set_explosion_intensity(self, system, intensity):
        """控制爆炸强度参数"""
        if not self.world or not system:
            return False
        
        # 强度影响多个参数
        self.api.set_scalar_param(self.world, system, "ExplosionIntensity", intensity)
        self.api.set_scalar_param(self.world, system, "EmissionRate", intensity * 100.0)
        self.api.set_vector_param(self.world, system, "ExplosionColor", 
                                  unreal.LinearColor(intensity, 0.5 * intensity, 0.2 * intensity, 1.0))
        return True
    
    def set_smoke_density(self, system, density):
        """控制烟雾密度参数"""
        if not self.world or not system:
            return False
        
        self.api.set_scalar_param(self.world, system, "SmokeDensity", density)
        self.api.set_scalar_param(self.world, system, "EmissionRate", density * 50.0)
        return True

def control_particle_parameters():
    controller = NiagaraParameterController()
    
    if not controller.initialize():
        print("Failed to initialize")
        return
    
    system = unreal.NiagaraFunctionLibrary.spawn_system_at_location(
        controller.world,
        unreal.load_asset("/Game/Niagara/Sys_Explosion"),
        unreal.Vector(0.0, 0.0, 100.0),
        unreal.Rotator(0.0, 0.0, 0.0),
        unreal.Vector(1.0, 1.0, 1.0),
        True
    )
    
    if system:
        # 动态调整爆炸强度
        controller.set_explosion_intensity(system, 2.0)
```

### 多类型特效同步发射

```python
import unreal

def synchronized_emission_system():
    api = unreal.NiagaraFunctionLibrary
    world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    if not world:
        print("World context not available")
        return
    
    # 多类型特效同步发射
    def spawn_effect_at_location(effect_type, location):
        templates = {
            "explosion": "/Game/Niagara/Sys_Explosion",
            "smoke": "/Game/Niagara/Sys_Smoke",
            "spark": "/Game/Niagara/Sys_Spark"
        }
        
        template_path = templates.get(effect_type)
        if template_path:
            return api.spawn_system_at_location(
                world,
                unreal.load_asset(template_path),
                location,
                unreal.Rotator(0.0, 0.0, 0.0),
                unreal.Vector(1.0, 1.0, 1.0),
                True
            )
        return None
    
    # 圆周同步发射
    radius = 100.0
    count = 8
    
    for i in range(count):
        angle = (i / count) * 360.0
        rad = unreal.KismetMathLibrary.degrees_to_radians(angle)
        
        x = radius * unreal.KismetMathLibrary.cos(rad)
        y = radius * unreal.KismetMathLibrary.sin(rad)
        z = 50.0
        
        location = unreal.Vector(x, y, z)
        spawn_effect_at_location("explosion", location)
```

## 高级用法

### 粒子系统生命周期管理

```python
import unreal

class NiagaraLifecycleManager:
    def __init__(self):
        self.api = unreal.NiagaraFunctionLibrary
        self.world = None
        self.systems = {}
    
    def initialize(self):
        self.world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
        return self.world is not None
    
    def spawn_auto_destroy(self, template, location, scale=1.0):
        """自动销毁的粒子系统"""
        if self.world:
            return self.api.spawn_system_at_location(
                self.world,
                template,
                location,
                unreal.Rotator(0.0, 0.0, 0.0),
                unreal.Vector(scale, scale, scale),
                True  # b_auto_destroy=True
            )
        return None
    
    def spawn_persistent(self, template, location, scale=1.0):
        """持久的粒子系统（需手动销毁）"""
        if self.world:
            system = self.api.spawn_system_at_location(
                self.world,
                template,
                location,
                unreal.Rotator(0.0, 0.0, 0.0),
                unreal.Vector(scale, scale, scale),
                False  # b_auto_destroy=False
            )
            if system:
                self.systems[system] = True
            return system
        return None
    
    def destroy_system(self, system):
        """手动销毁粒子系统"""
        if system and system in self.systems:
            system.destroy_component()
            del self.systems[system]
            return True
        return False
```

### 粒子轨迹查询

```python
import unreal

def query_particle_scatter_samples():
    api = unreal.NiagaraFunctionLibrary
    world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    if not world:
        print("World context not available")
        return
    
    system = api.spawn_system_at_location(
        world,
        unreal.load_asset("/Game/Niagara/Sys_Explosion"),
        unreal.Vector(0.0, 0.0, 100.0),
        unreal.Rotator(0.0, 0.0, 0.0),
        unreal.Vector(1.0, 1.0, 1.0),
        True
    )
    
    if system:
        # 获取粒子采样点
        samples = []
        success = api.get_scatter_samples(world, system, 100, samples)
        
        if success:
            print(f"Scatter samples: {len(samples)}")
            for i, sample in enumerate(samples[:5]):  # 只显示前5个
                print(f"Sample {i}: {sample.get_location()}")
```

### 特效性能监控

```python
import unreal

class NiagaraPerformanceMonitor:
    def __init__(self):
        self.api = unreal.NiagaraFunctionLibrary
        self.world = None
        self.tracked_systems = []
    
    def initialize(self):
        self.world = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
        return self.world is not None
    
    def track_system(self, system):
        if system:
            self.tracked_systems.append(system)
    
    def get_tracked_systems_age(self):
        ages = []
        for system in self.tracked_systems:
            age = self.api.get_system_age(self.world, system) if self.world else 0.0
            ages.append(age)
        return ages
    
    def get_system_emitter_count(self, system):
        if self.world:
            return self.api.get_emitter_count(self.world, system)
        return 0

def monitor_effect_performance():
    monitor = NiagaraPerformanceMonitor()
    
    if not monitor.initialize():
        print("Failed to initialize")
        return
    
    # 跟踪多个特效
    for i in range(10):
        system = unreal.NiagaraFunctionLibrary.spawn_system_at_location(
            monitor.world,
            unreal.load_asset("/Game/Niagara/Sys_Spark"),
            unreal.Vector(float(i * 10), 0.0, 50.0),
            unreal.Rotator(0.0, 0.0, 0.0),
            unreal.Vector(1.0, 1.0, 1.0),
            True
        )
        monitor.track_system(system)
    
    # 查询年龄
    ages = monitor.get_tracked_systems_age()
    print(f"Ages: {ages}")
```

## 常见问题与最佳实践

### 性能优化技巧

1. **系统数量控制**：
   - 使用对象池而非频繁创建销毁
   - 合并相似特效为单个系统
   
2. **参数更新优化**：
   - 批量设置参数避免频繁更新
   - 使用 Niagara 的 Parameter Map 集中管理
   
3. **查询频率控制**：
   - 避免每帧查询 `get_system_age`
   - 使用委托监听特效完成事件

### 常见陷阱

1. **世界上下文**：
   - 编辑器静态模式下 `get_game_instance()` 可能返回 `None`
   - 应确保 PIE/运行时上下文
   
2. **参数名称**：
   - 参数名区分大小写
   - 确保 Niagara 系统中存在对应参数
   
3. **自动销毁**：
   - `b_auto_destroy=True` 会在特效完成后自动清理
   - 手动管理时需调用 `destroy_component()`

### 最佳实践

1. **预制模板管理**：
   - 使用 `/Game/Niagara/Templates/` 保存常用模板
   - 通过蓝图继承创建变体
   
2. **调试与优化**：
   - 使用 Niagara Debugger 查看系统性能
   - 监控粒子数量和更新开销
   
3. **代码组织**：
   - 创建系统管理器类统一处理特效
   - 使用枚举或常量管理参数名

## 限制和注意事项

- 大部分 Niagara 控制方法需要有效的 `WorldContextObject` 与 Niagara 系统组件引用；非运行时调用返回 `BLOCKED_TOOLING`。
- `SpawnSystemAtLocation` 系列方法创建的组件默认自动销毁；设置 `b_auto_destroy=False` 可手动管理生命周期。
- `Set*Parameter` 系列方法修改的是运行时参数；生效时间取决于 Niagara 系统更新周期（通常是下一帧）。
- 粒子系统路径无效、模板未加载、参数名不存在等返回 `BLOCKED_INPUT`；无世界上下文或 Niagara 系统未激活返回 `BLOCKED_TOOLING`。
- `WITH_EDITOR` 限定的方法仅编辑器 Python 可用；非编辑器环境调用会失败。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
