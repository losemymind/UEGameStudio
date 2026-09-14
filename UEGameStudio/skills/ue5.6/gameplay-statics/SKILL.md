---
name: gameplay-statics
description: UGameplayStatics（UE 5.6）游戏运行时静态工具库 - Actor / Player / 关卡流送、视口与全局控制、音效特效与伤害、瞄准弹道与投影、存档与选项解析；在 Agent 需要通过 unreal Python 在 PIE / 运行时游戏世界执行通用游戏逻辑时使用
risk: critical
category: development
tags: [ue5.6, gameplay, statics, runtime, python]
---

# GameplayStatics - 游戏运行时工具库（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 在 PIE / 运行时游戏世界执行通用游戏逻辑时使用本 skill（description 触发场景）。
- 本 skill 只在与 gameplay-statics 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UGameplayStatics` 暴露给 Python 的静态工具方法。签名与成员依据 `Engine/Source/Runtime/Engine/Classes/Kismet/GameplayStatics.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无则按 C++ 函数名转 snake_case。

## 入口说明

本库全部为静态方法，以类方法形式调用，不需要实例：

```python
import unreal
api = unreal.GameplayStatics
```

- 绝大多数方法是运行时方法：只在 PIE / 运行时可用，编辑器非运行态调用会失败或结果无意义。
- 带 `WorldContextObject` 的方法须传世界上下文对象（如 `unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()` 或任意已归入世界对象的 Actor）。
- Static 函数返回约定：仅一个 Out/ByRef 参数时直接返回该值；返回值与 Out 并存时按元组返回（返回值为首位）；无 Out 且无返回值时返回 `None`。
- 精确 Python 暴露名需在目标 5.6 编辑器 `dir()`/`help()` 实测确认。

## 可用操作（主要分组）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 生成 | `spawn_object(object_class, outer)` | `UObject* SpawnObject(TSubclassOf<UObject>, UObject*)` | `Object` 或 `None` |
| Actor | `get_actor_of_class(world_context, actor_class)` | `AActor* GetActorOfClass(...)` | `Actor` 或 `None` |
| Actor | `get_all_actors_of_class(world_context, actor_class)` | `void GetAllActorsOfClass(..., TArray<AActor*>& OutActors)` | `Array[Actor]` |
| Actor | `get_all_actors_with_tag(world_context, tag)` | `void GetAllActorsWithTag(..., FName, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_class_with_tag(world_context, actor_class, tag)` | `void GetAllActorsOfClassWithTag(..., TSubclassOf<AActor>, FName, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_with_tags(world_context, tags)` | `void GetAllActorsWithTags(..., const TArray<FName>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_class_with_tags_1(world_context, actor_class, tags)` | `void GetAllActorsOfClassWithTags(..., TSubclassOf<AActor>, const TArray<FName>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_class_with_tags_2(world_context, actor_class, tag)` | `void GetAllActorsOfClassWithTags(..., TSubclassOf<AActor>, FName, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_actor_class_with_tag(world_context, parent_actor, tag)` | `void GetAllActorsOfActorClassWithTag(..., AActor*, FName, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_actor_class_with_tags(world_context, parent_actor, tags)` | `void GetAllActorsOfActorClassWithTags(..., AActor*, const TArray<FName>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_class_except(world_context, actor_class, except_actors)` | `void GetAllActorsOfClassExcept(..., TSubclassOf<AActor>, const TArray<AActor*>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_with_tag_except(world_context, tag, except_actors)` | `void GetAllActorsWithTagExcept(..., FName, const TArray<AActor*>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `get_all_actors_of_class_with_tag_except(world_context, actor_class, tag, except_actors)` | `void GetAllActorsOfClassWithTagExcept(..., TSubclassOf<AActor>, FName, const TArray<AActor*>&, TArray<AActor*>&)` | `Array[Actor]` |
| Actor | `find_nearest_actor(origin, actors_to_check)` | `AActor* FindNearestActor(..., float& Distance)` | `(Actor, float)` |
| Player | `get_player_controller(world_context, player_index)` | `APlayerController* GetPlayerController(...)` | `PlayerController` 或 `None` |
| Player | `get_player_pawn(world_context, player_index)` | `APawn* GetPlayerPawn(...)` | `Pawn` 或 `None` |
| Player | `get_player_character(world_context, player_index)` | `ACharacter* GetPlayerCharacter(...)` | `Character` 或 `None` |
| Player | `create_player(world_context, controller_id=-1, b_spawn_player_controller=True)` | `APlayerController* CreatePlayer(...)` | `PlayerController` 或 `None` |
| 关卡 | `open_level(world_context, level_name, b_absolute=True)` | `void OpenLevel(..., FName, bool, FString)` | `None` |
| 关卡 | `load_stream_level(world_context, level_name, ...)` | `void LoadStreamLevel(...)` | `None` |
| 关卡 | `get_current_level_name(world_context, b_remove_prefix_string=True)` | `FString GetCurrentLevelName(...)` | `str` |
| 全局 | `get_game_mode(world_context)` | `AGameModeBase* GetGameMode(...)` | `GameModeBase` 或 `None` |
| 全局 | `get_game_state(world_context)` | `AGameStateBase* GetGameState(...)` | `GameStateBase` 或 `None` |
| 全局 | `set_game_paused(world_context, b_paused)` | `bool SetGamePaused(...)` | `bool` |
| 全局 | `set_global_time_dilation(world_context, time_dilation)` | `void SetGlobalTimeDilation(...)` | `None` |
| 伤害 | `apply_damage(damaged_actor, base_damage, ...)` | `float ApplyDamage(...)` | `float` |
| 伤害 | `apply_point_damage(damaged_actor, base_damage, hit_from_direction, hit_info, ...)` | `float ApplyPointDamage(...)` | `float` |
| 伤害 | `apply_radial_damage(world_context, base_damage, origin, ...)` | `bool ApplyRadialDamage(...)` | `bool` |
| 音效 | `play_sound_2d(world_context, sound, volume_multiplier=1.0)` | `void PlaySound2D(...)` | `None` |
| 音效 | `spawn_sound_at_location(world_context, sound, location, rotation=...)` | `UAudioComponent* SpawnSoundAtLocation(...)` | `AudioComponent` 或 `None` |
| 特效 | `spawn_emitter_at_location(world_context, emitter_template, location, rotation=...)` | `UParticleSystemComponent* SpawnEmitterAtLocation(...)` | `ParticleSystemComponent` 或 `None` |
| 特效 | `spawn_poly_line_emitter_at_location(world_context, emitter_template, location, rotation=...)` | `UParticleSystemComponent* SpawnPolyLineEmitterAtLocation(...)` | `ParticleSystemComponent` 或 `None` |
| 视口 | `project_world_to_screen(player, world_position)` | `bool ProjectWorldToScreen(..., FVector2D& ScreenPosition)` | `(bool, Vector2D)` |
| 视口 | `deproject_screen_to_world(player, screen_position)` | `bool DeprojectScreenToWorld(..., FVector&, FVector&)` | `(bool, Vector, Vector)` |
| 弹道 | `blueprint_suggest_projectile_velocity(world_context, start_location, end_location, launch_speed, ...)` | `bool BlueprintSuggestProjectileVelocity(..., FVector& TossVelocity)` | `(bool, Vector)` |
| 弹道 | `blueprint_predict_projectile_path_by_object_type(world_context, start_pos, launch_velocity, ...)` | `bool Blueprint_PredictProjectilePath_ByObjectType(...)` | `(bool, HitResult, Array[Vector], Vector)` |
| 存档 | `create_save_game_object(save_game_class)` | `USaveGame* CreateSaveGameObject(...)` | `SaveGame` 或 `None` |
| 存档 | `save_game_to_slot(save_game_object, slot_name, user_index)` | `bool SaveGameToSlot(...)` | `bool` |
| 存档 | `load_game_from_slot(slot_name, user_index)` | `USaveGame* LoadGameFromSlot(...)` | `SaveGame` 或 `None` |
| 时间 | `get_world_delta_seconds(world_context)` | `double GetWorldDeltaSeconds(...)` | `float` |
| 时间 | `get_time_seconds(world_context)` | `double GetTimeSeconds(...)` | `float` |

## 示例

```python
import unreal

def main():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    controller = api.get_player_controller(world_context, 0)
    if controller is None:
        print({"status": "BLOCKED_INPUT", "reason": "player controller 不可用，需 PIE/运行时"})
        return

    pawn = api.get_player_pawn(world_context, 0)
    npc_class = unreal.load_class("/Game/Blueprints/BP_NPC")
    npcs = api.get_all_actors_of_class(world_context, npc_class)
    nearest, distance = api.find_nearest_actor(pawn.get_actor_location(), npcs)

    ok = api.set_game_paused(world_context, True)
    api.play_sound_2d(world_context, unreal.load_object(None, "/Game/Audio/SFX_Click"))
    print({"status": "OK", "nearest": nearest.get_actor_label() if nearest else None, "paused": ok})

def example_tag_queries():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    npc_class = unreal.load_class("/Game/Blueprints/BP_NPC")
    enemies = api.get_all_actors_of_class_with_tag(world_context, npc_class, "Enemy")
    tagged_actors = api.get_all_actors_with_tags(world_context, ["Loot", "Interactive"])
    parent_actor = api.get_all_actors_of_class(world_context, unreal.load_class("/Game/Blueprints/BP_Parent"))[0] if api.get_all_actors_of_class(world_context, unreal.load_class("/Game/Blueprints/BP_Parent")) else None
    children = api.get_all_actors_of_actor_class_with_tag(world_context, parent_actor, "ChildActor") if parent_actor else []

def example_except_queries():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    npc_class = unreal.load_class("/Game/Blueprints/BP_NPC")
    all_npcs = api.get_all_actors_of_class(world_context, npc_class)
    exclude_list = [all_npcs[0]] if len(all_npcs) > 0 else []
    filtered = api.get_all_actors_of_class_except(world_context, npc_class, exclude_list)
    tagged_filtered = api.get_all_actors_with_tag_except(world_context, "Enemy", exclude_list)
    actor_class_filtered = api.get_all_actors_of_class_with_tag_except(world_context, npc_class, "Enemy", exclude_list) if len(all_npcs) > 0 else []

def example_poly_line_emitter():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    emitter_template = unreal.load_object(None, "/Game/Particles/PT_PolyLine.PT_PolyLine")
    loc = unreal.Vector(0.0, 0.0, 100.0)
    rot = unreal.Rotator(0.0, 0.0, 0.0)
    component = api.spawn_poly_line_emitter_at_location(world_context, emitter_template, loc, rot) if emitter_template else None

if __name__ == "__main__":
    main()
```

## 综合实战示例

### 网络状态与Player管理

```python
import unreal

def player_controller_manager():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    player_count = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_local_player_count()
    
    player_dict = {}
    for i in range(player_count):
        controller = api.get_player_controller(world_context, i)
        pawn = api.get_player_pawn(world_context, i)
        character = api.get_player_character(world_context, i)
        
        if controller and pawn:
            player_dict[i] = {
                "controller": controller.get_name(),
                "pawn": pawn.get_name(),
                "character": character.get_name() if character else None,
                "location": pawn.get_actor_location()
            }
    
    return player_dict

def create_player_with_settings(player_index, spawn_controller=True):
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    controller = api.create_player(
        world_context,
        controller_id=player_index,
        b_spawn_player_controller=spawn_controller
    )
    
    if controller:
        print(f"Player {player_index} created: {controller.get_name()}")
    
    return controller
```

### 关卡流送与场景管理

```python
import unreal

def level_streaming_controller():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 动态加载关卡
    api.load_stream_level(
        world_context,
        "City_02",
        unreal.TSoftObjectPtr(unreal.Level),
        unreal.LoadLevelTransform(),
        True,
        unreal.StreamLevelPriority.AutoHigh
    )
    
    # 查询当前关卡
    current_level = api.get_current_level_name(world_context)
    print(f"Current level: {current_level}")
    
    # 切换关卡
    api.open_level(world_context, "Main_Map")
```

### 全局游戏状态管理

```python
import unreal

def global_state_manager():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    game_mode = api.get_game_mode(world_context)
    game_state = api.get_game_state(world_context)
    
    # 暂停控制
    api.set_game_paused(world_context, True)
    api.set_game_paused(world_context, False)
    
    # 时间缩放（慢动作/快进）
    api.set_global_time_dilation(world_context, 0.5)  # 慢动作
    api.set_global_time_dilation(world_context, 2.0)  # 快进
    api.set_global_time_dilation(world_context, 1.0)  # 正常速度
    
    # 查询游戏时间
    world_delta = api.get_world_delta_seconds(world_context)
    game_time = api.get_time_seconds(world_context)
    
    return {
        "paused": game_state.is_paused() if game_state else False,
        "time_dilation": api.get_global_time_dilation(world_context) if hasattr(api, 'get_global_time_dilation') else 1.0,
        "world_delta": world_delta,
        "game_time": game_time
    }
```

### 伤害与伤害传播系统

```python
import unreal

def damage_system():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 单点伤害
    def apply_point_damage_to_actor(damaged_actor, damage, damage_type_class, hit_info, instigated_by, damage_causer):
        return api.apply_point_damage(
            damaged_actor,
            damage,
            hit_info.get_impact_point(),
            hit_info,
            instigated_by,
            damage_causer,
            damage_type_class
        )
    
    # 范围伤害
    def apply_radial_damage_to_targets(origin, radius, damage, damage_type, instigated_by, damage_causer, ignored_actors):
        return api.apply_radial_damage(
            world_context,
            damage,
            origin,
            radius,
            damage_type,
            ignored_actors,
            damage_causer,
            True
        )
    
    # 伤害衰减计算
    def calculate_falloff_damage(origin, target, max_radius, min_damage, max_damage):
        distance = unreal.KismetMathLibrary.length(
            unreal.KismetMathLibrary.subtract(target, origin)
        )
        
        if distance >= max_radius:
            return min_damage
        
        falloff = 1.0 - (distance / max_radius)
        return min_damage + (max_damage - min_damage) * falloff
```

### 弹道预测与瞄准辅助

```python
import unreal

def projectile_trajectory_system():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 推荐弹道速度（抛物线）
    def suggest_projectile_launch_velocity(start, end, launch_speed, gravity_scale=1.0):
        success, velocity = api.blueprint_suggest_projectile_velocity(
            world_context,
            start,
            end,
            launch_speed,
            0.0,
            gravity_scale,
            0.0,
            unreal.DrawDebugTrace.NONE,
            unreal.LinearColor(1.0, 0.0, 0.0, 1.0),
            True
        )
        
        return velocity if success else None
    
    # 预测弹道路径
    def predict_projectile_path(start, launch_velocity, projectile_radius=0.0):
        success, hit_result, path_points, end_point = api.blueprint_predict_projectile_path_by_object_type(
            world_context,
            start,
            launch_velocity,
            projectile_radius,
            unreal.TraceTypeQuery.TRACE_TYPE_QUERY1,
            False,
            [],
            unreal.DrawDebugTrace.NONE,
            unreal.LinearColor(0.0, 1.0, 0.0, 1.0),
            10.0,
            1.0,
            True
        )
        
        return {
            "success": success,
            "path": path_points,
            "end": end_point
        }
```

## 高级用法

### 存档系统与数据持久化

```python
import unreal

class SaveGameController:
    def __init__(self, slot_name, user_index=0):
        self.slot_name = slot_name
        self.user_index = user_index
        self.api = unreal.GameplayStatics
    
    def save_data(self, save_game_object):
        return self.api.save_game_to_slot(
            save_game_object,
            self.slot_name,
            self.user_index
        )
    
    def load_data(self):
        return self.api.load_game_from_slot(
            self.slot_name,
            self.user_index
        )
    
    def create_save_game(self, save_game_class):
        return self.api.create_save_game_object(save_game_class)

def high_score_system():
    controller = SaveGameController("HighScores", 0)
    
    # 创建存档对象
    save_obj = controller.create_save_game(unreal.load_class(None, "/Game/SaveGames/SG_HighScores.SG_HighScores_C"))
    
    # 读取分数
    existing_save = controller.load_data()
    if existing_save:
        high_scores = existing_save.get_high_scores()
    else:
        high_scores = []
    
    # 更新最高分
    new_score = 10000
    high_scores.append(new_score)
    high_scores.sort(reverse=True)
    high_scores = high_scores[:5]  # 保持前5名
    
    existing_save.set_high_scores(high_scores)
    controller.save_data(existing_save)
```

### 音效管理与空间音频

```python
import unreal

def sound_manager():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    # 2D音效
    def play_2d_sound(sound, volume=1.0, pitch=1.0):
        api.play_sound_2d(world_context, sound)
    
    # 3D空间音效
    def play_3d_sound_at_location(sound, location, volume=1.0, pitch=1.0, attenuation=None):
        component = api.spawn_sound_at_location(
            world_context,
            sound,
            location,
            unreal.Rotator(0.0, 0.0, 0.0),
            unreal.ComponentScale(1.0, 1.0, 1.0),
            False,
            volume,
            pitch,
            0.0,
            None,
            None
        )
        return component
    
    # 音效淡入淡出
    def fade Sound(component, target_volume, fade_time):
        if component:
            component.set_volume_multiplier(0.0)
            start_volume = 0.0
            end_volume = target_volume
            duration = fade_time
            # 需要自定义插值逻辑
```

### 视口与屏幕空间转换

```python
import unreal

def viewport_projection_system():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
    
    player = api.get_player_controller(world_context, 0)
    
    # 世界坐标→屏幕坐标
    def world_to_screen(world_position):
        success, screen_pos = api.project_world_to_screen(
            player,
            world_position
        )
        return screen_pos if success else None
    
    # 屏幕坐标→世界坐标（射线）
    def screen_to_world(screen_position):
        success, world_direction, world_position = api.deproject_screen_to_world(
            player,
            screen_position
        )
        return {
            "direction": world_direction,
            "origin": world_position
        } if success else None
```

## 常见问题与最佳实践

### 异步操作与阻塞调用

1. **阻塞式加载 vs 异步加载**：
   - `LoadAsset_Blocking`：同步加载，阻塞线程直到完成
   - `AsyncLoadAsset`：异步加载，需配合 delegate 处理
   
2. **Actor生成时机**：
   ```python
   # 编辑器模式：可直接生成
   actor = unreal.EditorLevelLibrary.spawn_actor_from_class(
       target_class,
       location,
       rotation
   )
   
   # 运行时模式：需要用 SpawnActor
   # api.spawn_object() 更适合动态对象
   ```

### 内存管理与对象生命周期

1. **临时对象清理**：
   - `SpawnObject` 创建的对象由 Outer 管理
   - 设置适当的 Outer 避免内存泄漏
   - 使用 `DestroyActor` 清理 Actor
   
2. **AudioComponent 管理**：
   ```python
   component = api.spawn_sound_at_location(...)
   if component:
       component.on_audio_component_finished_delegate.add_callable(
           lambda c: c.destroy_component()
       )
   ```

### 热重载与脚本安全性

1. **类引用动态化**：
   ```python
   # 避免硬编码类路径
   def safe_load_class(path):
       try:
           return unreal.load_class(None, path)
       except Exception:
           return None
   
   # 使用 TSoftObjectPtr
   soft_class = unreal.TSoftObjectPtr(unreal.Actor)
   soft_class.set_asset(path)
   ```

2. **异常处理**：
   ```python
   try:
       result = api.get_player_controller(world_context, 0)
       if result is None:
           print("Player controller not ready")
   except Exception as e:
       print(f"Error: {e}")
   ```

## 限制和注意事项

- 运行时方法只在 PIE / Play 会话中可用；编辑器非运行态调用返回空/假值，按 `BLOCKED_TOOLING` 处理并停止。
- Actor/播放器查询返回 `None` 表示不存在；`apply_*` 伤害与 `create_player` 需权威端/相应运行时上下文。
- 流送关卡与 Open Level 等会改变世界状态，实施后必须独立验收，不声明未实测的结果。
- Tag/Except 查询扩展（`get_all_actors_of_class_with_tag`、`get_all_actors_with_tags`、`get_all_actors_of_class_with_tags_*`、`get_all_actors_of_actor_class_with_tag`、`get_all_actors_of_actor_class_with_tags`、`get_all_actors_of_class_except`、`get_all_actors_with_tag_except`、`get_all_actors_of_class_with_tag_except`）在 UE 5.6 中为新增 API，未在真实 UE 5.6 Editor 中实测；调用前须在目标引擎中验证签名与参数类型。
- 缺世界上下文、类路径、Tag 名称、Except 列表等必要输入时返回 `BLOCKED_INPUT`；编辑器/运行时上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。