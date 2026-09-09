---
name: gameplay-statics
description: UGameplayStatics（UE 5.6）游戏运行时静态工具库 - Actor / Player / 关卡流送、视口与全局控制、音效特效与伤害、瞄准弹道与投影、存档与选项解析；在 Agent 需要通过 unreal Python 在 PIE / 运行时游戏世界执行通用游戏逻辑时使用
tags: [ue5.6, gameplay, statics, runtime, python]
---

# GameplayStatics - 游戏运行时工具库（UE 5.6）

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

## 快速示例

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

## 注意事项

- 运行时方法只在 PIE / Play 会话中可用；编辑器非运行态调用返回空/假值，按 `BLOCKED_TOOLING` 处理并停止。
- Actor/播放器查询返回 `None` 表示不存在；`apply_*` 伤害与 `create_player` 需权威端/相应运行时上下文。
- 流送关卡与 Open Level 等会改变世界状态，实施后必须独立验收，不声明未实测的结果。
- Tag/Except 查询扩展（`get_all_actors_of_class_with_tag`、`get_all_actors_with_tags`、`get_all_actors_of_class_with_tags_*`、`get_all_actors_of_actor_class_with_tag`、`get_all_actors_of_actor_class_with_tags`、`get_all_actors_of_class_except`、`get_all_actors_with_tag_except`、`get_all_actors_of_class_with_tag_except`）在 UE 5.6 中为新增 API，未在真实 UE 5.6 Editor 中实测；调用前须在目标引擎中验证签名与参数类型。
- 缺世界上下文、类路径、Tag 名称、Except 列表等必要输入时返回 `BLOCKED_INPUT`；编辑器/运行时上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。