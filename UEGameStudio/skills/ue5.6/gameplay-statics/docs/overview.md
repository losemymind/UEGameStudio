# GameplayStatics - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/GameplayStatics.h` 整理 `UGameplayStatics` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的全部成员。Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无则按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 5.6 编辑器 `dir()`/`help()` 实测确认。

## 入口与通用约定

```python
import unreal

# 全部为静态方法，以类方法形式调用，无需实例：
api = unreal.GameplayStatics
```

- 绝大多数方法是运行时方法：只在 PIE / 运行时可用；编辑器非运行态调用返回空/假值或无效果。
- 带 `WorldContextObject` 的方法传世界上下文对象，例如：

```python
world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()
```

- Out/ByRef 参数返回约定：仅一个 Out 参数时直接返回该值；返回值与 Out 并存时按元组返回（返回值为首位）；无 Out 且无返回值时返回 `None`。
- 需要运行时 Actor 类时用 `unreal.load_class("/Game/Blueprints/BP_XXX")`，返回 `None` 表示类路径不可加载。

## 生成（Spawning / Deferred）

### spawn_object

- C++ 签名：`UObject* SpawnObject(TSubclassOf<UObject> ObjectClass, UObject* Outer)`
- Python：`spawn_object(object_class, outer) -> Object 或 None`
- 说明：直接生成一个类实例并指定 Outer；用于无延迟生成普通对象。
- 示例：

```python
obj = api.spawn_object(unreal.Class("Engine/World"), world_context)
```

### begin_deferred_actor_spawn_from_class

- C++ 签名：`AActor* BeginDeferredActorSpawnFromClass(const UObject* WorldContextObject, TSubclassOf<AActor> ActorClass, const FTransform& SpawnTransform, ESpawnActorCollisionHandlingMethod CollisionHandlingOverride, AActor* Owner, ESpawnActorScaleMethod TransformScaleMethod)`
- Python：`begin_deferred_actor_spawn_from_class(world_context_object, actor_class, spawn_transform, collision_handling_override=..., owner=..., transform_scale_method=...) -> Actor 或 None`
- 说明：延迟生成 Actor：先创建实例但不执行构造函数，设置属性后再用 `finish_spawning_actor` 完成生成（此阶段才运行构造脚本）。
- 示例：

```python
npc_class = unreal.load_class("/Game/Blueprints/BP_NPC")
spawn_tm = unreal.Transform(location=unreal.Vector(0, 0, 100.0))
pending = api.begin_deferred_actor_spawn_from_class(world_context, npc_class, spawn_tm)
if pending is not None:
    finished = api.finish_spawning_actor(pending, spawn_tm)
```

### finish_spawning_actor

- C++ 签名：`AActor* FinishSpawningActor(AActor* Actor, const FTransform& SpawnTransform, ESpawnActorScaleMethod TransformScaleMethod)`
- Python：`finish_spawning_actor(actor, spawn_transform, transform_scale_method=...) -> Actor`
- 说明：完成延迟生成并运行 Actor 构造脚本；返回完成后的 Actor。
- 示例：

```python
finished = api.finish_spawning_actor(pending_actor, spawn_transform)
```

### begin_spawning_actor_from_blueprint（已弃用）

- C++ 签名：`AActor* BeginSpawningActorFromBlueprint(const UObject* WorldContextObject, const UBlueprint* Blueprint, const FTransform& SpawnTransform, bool bNoCollision)`
- Python：`begin_spawning_actor_from_blueprint(world_context_object, blueprint, spawn_transform, b_no_collision) -> Actor 或 None`
- 说明：旧版延迟生成入口；已被 `begin_deferred_actor_spawn_from_class` 取代，新代码不要使用。
- 示例：

```python
blueprint = unreal.load_asset("/Game/Blueprints/BP_NPC")
pending = api.begin_spawning_actor_from_blueprint(world_context, blueprint, spawn_tm, False)
```

## Actor 查询（Actor）

### get_actor_array_average_location

- C++ 签名：`FVector GetActorArrayAverageLocation(const TArray<AActor*>& Actors)`
- Python：`get_actor_array_average_location(actors) -> Vector`
- 说明：返回 Actor 数组的平均位置（质心）。
- 示例：

```python
actors = api.get_all_actors_of_class(world_context, actor_class)
center = api.get_actor_array_average_location(actors)
```

### get_actor_array_bounds

- C++ 签名：`void GetActorArrayBounds(const TArray<AActor*>& Actors, bool bOnlyCollidingComponents, FVector& Center, FVector& BoxExtent)`
- Python：`get_actor_array_bounds(actors, b_only_colliding_components=False) -> (Vector, Vector)`
- 说明：返回 Actor 数组包围盒的中心与半长。两个 Out 参数并存，按元组返回。
- 示例：

```python
center, extent = api.get_actor_array_bounds(actors, True)
```

### get_actor_of_class

- C++ 签名：`AActor* GetActorOfClass(const UObject* WorldContextObject, TSubclassOf<AActor> ActorClass)`
- Python：`get_actor_of_class(world_context_object, actor_class) -> Actor 或 None`
- 说明：返回世界中指定类的第一个 Actor；类必须指定。
- 示例：

```python
target = api.get_actor_of_class(world_context, target_class)
if target is None:
    print("BLOCKED_INPUT: actor of class not found")
```

### get_all_actors_of_class

- C++ 签名：`void GetAllActorsOfClass(const UObject* WorldContextObject, TSubclassOf<AActor> ActorClass, TArray<AActor*>& OutActors)`
- Python：`get_all_actors_of_class(world_context_object, actor_class) -> Array[Actor]`
- 说明：返回世界中该类的全部 Actor；仅一个 Out 参数，直接返回数组。
- 示例：

```python
npcs = api.get_all_actors_of_class(world_context, unreal.load_class("/Game/Blueprints/BP_NPC"))
```

### get_all_actors_with_interface

- C++ 签名：`void GetAllActorsWithInterface(const UObject* WorldContextObject, TSubclassOf<UInterface> Interface, TArray<AActor*>& OutActors)`
- Python：`get_all_actors_with_interface(world_context_object, interface) -> Array[Actor]`
- 说明：返回世界中实现了指定接口的全部 Actor（逐 Actor 全量搜索，代价高）。
- 示例：

```python
iface = unreal.load_class("/Script/GameplayAbilities.IGameplayTagAssetInterface")
able = api.get_all_actors_with_interface(world_context, iface)
```

### get_all_actors_with_tag

- C++ 签名：`void GetAllActorsWithTag(const UObject* WorldContextObject, FName Tag, TArray<AActor*>& OutActors)`
- Python：`get_all_actors_with_tag(world_context_object, tag) -> Array[Actor]`
- 说明：返回世界中具有指定 Tag 的全部 Actor（逐 Actor 全量搜索）。
- 示例：

```python
respawn_points = api.get_all_actors_with_tag(world_context, "Respawn")
```

### get_all_actors_of_class_with_tag

- C++ 签名：`void GetAllActorsOfClassWithTag(const UObject* WorldContextObject, TSubclassOf<AActor> ActorClass, FName Tag, TArray<AActor*>& OutActors)`
- Python：`get_all_actors_of_class_with_tag(world_context_object, actor_class, tag) -> Array[Actor]`
- 说明：返回同时满足指定类与 Tag 的全部 Actor。
- 示例：

```python
cam = api.get_all_actors_of_class_with_tag(world_context, camera_class, "Main_Cam")
```

### find_nearest_actor

- C++ 签名：`AActor* FindNearestActor(FVector Origin, const TArray<AActor*>& ActorsToCheck, float& Distance)`
- Python：`find_nearest_actor(origin, actors_to_check) -> (Actor, float)`
- 说明：返回距 Origin 最近的 Actor 及其距离；返回值与 Out `Distance` 并存，按元组返回。
- 示例：

```python
nearest, distance = api.find_nearest_actor(pawn.get_actor_location(), npcs)
```

## Player（Player Functions）

### get_game_instance

- C++ 签名：`UGameInstance* GetGameInstance(const UObject* WorldContextObject)`
- Python：`get_game_instance(world_context_object) -> GameInstance 或 None`
- 说明：返回游戏实例对象。
- 示例：

```python
gi = api.get_game_instance(world_context)
```

### get_num_player_states

- C++ 签名：`int32 GetNumPlayerStates(const UObject* WorldContextObject)`
- Python：`get_num_player_states(world_context_object) -> int`
- 说明：返回活跃 PlayerState 数量（每个已连接玩家一个，含远程客户端）。
- 示例：

```python
count = api.get_num_player_states(world_context)
```

### get_player_state

- C++ 签名：`APlayerState* GetPlayerState(const UObject* WorldContextObject, int32 PlayerStateIndex)`
- Python：`get_player_state(world_context_object, player_state_index) -> PlayerState 或 None`
- 说明：返回指定索引的 PlayerState；客户端与服务端索引一致。
- 示例：

```python
ps = api.get_player_state(world_context, 0)
```

### get_player_state_from_unique_net_id

- C++ 签名：`APlayerState* GetPlayerStateFromUniqueNetId(const UObject* WorldContextObject, const FUniqueNetIdRepl& UniqueId)`
- Python：`get_player_state_from_unique_net_id(world_context_object, unique_id) -> PlayerState 或 None`
- 说明：按唯一网络 ID 查找 PlayerState，未找到返回 `None`。
- 示例：

```python
ps = api.get_player_state_from_unique_net_id(world_context, unique_net_id)
```

### get_num_player_controllers

- C++ 签名：`int32 GetNumPlayerControllers(const UObject* WorldContextObject)`
- Python：`get_num_player_controllers(world_context_object) -> int`
- 说明：返回可用 PlayerController 总数（服务端含远程玩家）。
- 示例：

```python
n = api.get_num_player_controllers(world_context)
```

### get_num_local_player_controllers

- C++ 签名：`int32 GetNumLocalPlayerControllers(const UObject* WorldContextObject)`
- Python：`get_num_local_player_controllers(world_context_object) -> int`
- 说明：返回完全初始化的本地玩家数（专用服务器上为 0）。
- 示例：

```python
n = api.get_num_local_player_controllers(world_context)
```

### get_player_controller

- C++ 签名：`APlayerController* GetPlayerController(const UObject* WorldContextObject, int32 PlayerIndex)`
- Python：`get_player_controller(world_context_object, player_index) -> PlayerController 或 None`
- 说明：获取指定索引的 PlayerController。
- 示例：

```python
pc = api.get_player_controller(world_context, 0)
```

### get_player_pawn

- C++ 签名：`APawn* GetPlayerPawn(const UObject* WorldContextObject, int32 PlayerIndex)`
- Python：`get_player_pawn(world_context_object, player_index) -> Pawn 或 None`
- 说明：获取指定玩家的 Pawn。
- 示例：

```python
pawn = api.get_player_pawn(world_context, 0)
```

### get_player_character

- C++ 签名：`ACharacter* GetPlayerCharacter(const UObject* WorldContextObject, int32 PlayerIndex)`
- Python：`get_player_character(world_context_object, player_index) -> Character 或 None`
- 说明：获取指定玩家的 Character；Pawn 非 Character 时返回 `None`。
- 示例：

```python
hero = api.get_player_character(world_context, 0)
```

### get_player_camera_manager

- C++ 签名：`APlayerCameraManager* GetPlayerCameraManager(const UObject* WorldContextObject, int32 PlayerIndex)`
- Python：`get_player_camera_manager(world_context_object, player_index) -> PlayerCameraManager 或 None`
- 说明：获取指定玩家索引对应的摄像机管理器。
- 示例：

```python
cam_man = api.get_player_camera_manager(world_context, 0)
```

### is_any_local_player_camera_within_range

- C++ 签名：`bool IsAnyLocalPlayerCameraWithinRange(const UObject* WorldContextObject, const FVector& Location, float MaximumRange)`
- Python：`is_any_local_player_camera_within_range(world_context_object, location, maximum_range) -> bool`
- 说明：判断是否有本地玩家摄像机在指定位置范围内；专用服务器恒为 `False`。
- 示例：

```python
in_range = api.is_any_local_player_camera_within_range(world_context, point, 5000.0)
```

### get_player_controller_from_id

- C++ 签名：`APlayerController* GetPlayerControllerFromID(const UObject* WorldContextObject, int32 ControllerID)`
- Python：`get_player_controller_from_id(world_context_object, controller_id) -> PlayerController 或 None`
- 说明：按物理手柄 ID 获取本地 PlayerController。
- 示例：

```python
pc = api.get_player_controller_from_id(world_context, 0)
```

### get_player_controller_from_platform_user

- C++ 签名：`APlayerController* GetPlayerControllerFromPlatformUser(const UObject* WorldContextObject, FPlatformUserId UserId)`
- Python：`get_player_controller_from_platform_user(world_context_object, user_id) -> PlayerController 或 None`
- 说明：按平台用户 ID 获取本地 PlayerController。
- 示例：

```python
pc = api.get_player_controller_from_platform_user(world_context, unreal.PlatformUserId(0))
```

### create_player

- C++ 签名：`APlayerController* CreatePlayer(const UObject* WorldContextObject, int32 ControllerId = -1, bool bSpawnPlayerController = true)`
- Python：`create_player(world_context_object, controller_id=-1, b_spawn_player_controller=True) -> PlayerController 或 None`
- 说明：为本机创建新的本地玩家（本地多人）；失败返回 `None`。
- 示例：

```python
new_pc = api.create_player(world_context, controller_id=1)
```

### create_player_from_platform_user

- C++ 签名：`APlayerController* CreatePlayerFromPlatformUser(const UObject* WorldContextObject, FPlatformUserId UserId, bool bSpawnPlayerController = true)`
- Python：`create_player_from_platform_user(world_context_object, user_id, b_spawn_player_controller=True) -> PlayerController 或 None`
- 说明：为指定平台用户创建新的本地玩家。
- 示例：

```python
new_pc = api.create_player_from_platform_user(world_context, user_id)
```

### remove_player

- C++ 签名：`void RemovePlayer(APlayerController* Player, bool bDestroyPawn)`
- Python：`remove_player(player, b_destroy_pawn) -> None`
- 说明：从本机移除一个本地玩家，可选一并销毁其 Pawn。
- 示例：

```python
api.remove_player(player_to_remove, True)
```

### get_player_controller_id

- C++ 签名：`int32 GetPlayerControllerID(APlayerController* Player)`
- Python：`get_player_controller_id(player) -> int`
- 说明：获取本地玩家当前的物理控制器 ID；未分配时返回 -1。
- 示例：

```python
cid = api.get_player_controller_id(pc)
```

### set_player_controller_id

- C++ 签名：`void SetPlayerControllerID(APlayerController* Player, int32 ControllerId)`
- Python：`set_player_controller_id(player, controller_id) -> None`
- 说明：设置本地玩家使用的物理控制器 ID。
- 示例：

```python
api.set_player_controller_id(pc, 2)
```

### set_player_platform_user_id

- C++ 签名：`void SetPlayerPlatformUserId(APlayerController* PlayerController, FPlatformUserId UserId)`
- Python：`set_player_platform_user_id(player_controller, user_id) -> None`
- 说明：设置本地玩家使用的平台用户 ID。
- 示例：

```python
api.set_player_platform_user_id(pc, unreal.PlatformUserId(1))
```

## 关卡流送与全局控制（Level Streaming）

### load_stream_level

- C++ 签名：`void LoadStreamLevel(const UObject* WorldContextObject, FName LevelName, bool bMakeVisibleAfterLoad, bool bShouldBlockOnLoad, FLatentActionInfo LatentInfo)`
- Python：`load_stream_level(world_context_object, level_name, b_make_visible_after_load, b_should_block_on_load, latent_info=...) -> None`
- 说明：按名称流送加载关卡；lazy 流程节点，流送完成前调用方按调度语义挂起，可用 `get_streaming_level` 轮询状态。
- 示例：

```python
api.load_stream_level(world_context, \"Sub_Level_A\", True, True)
```

### load_stream_level_by_soft_object_path

- C++ 签名：`void LoadStreamLevelBySoftObjectPtr(const UObject* WorldContextObject, const TSoftObjectPtr<UWorld> Level, bool bMakeVisibleAfterLoad, bool bShouldBlockOnLoad, FLatentActionInfo LatentInfo)`
- Python：`load_stream_level_by_soft_object_path(world_context_object, level, b_make_visible_after_load, b_should_block_on_load, latent_info=...) -> None`
- 说明：按软对象引用流送加载关卡。
- 示例：

```python
level = unreal.load_asset(\"/Game/Maps/Sub_Level_A\")
api.load_stream_level_by_soft_object_path(world_context, level, True, True)
```

### unload_stream_level

- C++ 签名：`void UnloadStreamLevel(const UObject* WorldContextObject, FName LevelName, FLatentActionInfo LatentInfo, bool bShouldBlockOnUnload)`
- Python：`unload_stream_level(world_context_object, level_name, latent_info=..., b_should_block_on_unload) -> None`
- 说明：按名称卸载流送关卡。
- 示例：

```python
api.unload_stream_level(world_context, \"Sub_Level_A\", None, False)
```

### unload_stream_level_by_soft_object_path

- C++ 签名：`void UnloadStreamLevelBySoftObjectPtr(const UObject* WorldContextObject, const TSoftObjectPtr<UWorld> Level, FLatentActionInfo LatentInfo, bool bShouldBlockOnUnload)`
- Python：`unload_stream_level_by_soft_object_path(world_context_object, level, latent_info=..., b_should_block_on_unload) -> None`
- 说明：按软对象引用卸载流送关卡。
- 示例：

```python
api.unload_stream_level_by_soft_object_path(world_context, level, None, False)
```

### get_streaming_level

- C++ 签名：`ULevelStreaming* GetStreamingLevel(const UObject* WorldContextObject, FName PackageName)`
- Python：`get_streaming_level(world_context_object, package_name) -> LevelStreaming 或 None`
- 说明：按关卡包名返回流送对象，用于查询/控制流送状态。
- 示例：

```python
sl = api.get_streaming_level(world_context, \"Sub_Level_A\")
print(sl.get_editor_property(\"should_be_visible\") if sl else None)
```

### flush_level_streaming

- C++ 签名：`void FlushLevelStreaming(const UObject* WorldContextObject)`
- Python：`flush_level_streaming(world_context_object) -> None`
- 说明：阻塞式完成当前帧的关卡流送请求（子关卡加载/隐藏/可见全部完成）。
- 示例：

```python
api.flush_level_streaming(world_context)
```

### cancel_async_loading

- C++ 签名：`void CancelAsyncLoading()`
- Python：`cancel_async_loading() -> None`
- 说明：取消所有排队的流送/异步加载包。
- 示例：

```python
api.cancel_async_loading()
```

### open_level

- C++ 签名：`void OpenLevel(const UObject* WorldContextObject, FName LevelName, bool bAbsolute = true, FString Options = TEXT(\"\"))`
- Python：`open_level(world_context_object, level_name, b_absolute=True, options=\"\") -> None`
- 说明：按名称切换关卡（Travel）；会改变世界状态，仅在 PIE/运行时执行。
- 示例：

```python
api.open_level(world_context, \"Lobby\")
```

### open_level_by_soft_object_path

- C++ 签名：`void OpenLevelBySoftObjectPtr(const UObject* WorldContextObject, const TSoftObjectPtr<UWorld> Level, bool bAbsolute = true, FString Options = TEXT(\"\"))`
- Python：`open_level_by_soft_object_path(world_context_object, level, b_absolute=True, options=\"\") -> None`
- 说明：按软对象引用切换关卡。
- 示例：

```python
api.open_level_by_soft_object_path(world_context, unreal.load_asset(\"/Game/Maps/Lobby\"))
```

### get_current_level_name

- C++ 签名：`FString GetCurrentLevelName(const UObject* WorldContextObject, bool bRemovePrefixString = true)`
- Python：`get_current_level_name(world_context_object, b_remove_prefix_string=True) -> str`
- 说明：返回当前关卡名（默认去除流送/编辑器前缀）。
- 示例：

```python
level_name = api.get_current_level_name(world_context)
```

## 全局状态（Global / Game）

### get_game_mode

- C++ 签名：`AGameModeBase* GetGameMode(const UObject* WorldContextObject)`
- Python：`get_game_mode(world_context_object) -> GameModeBase 或 None`
- 说明：返回当前 GameModeBase；客户端无法取到时为 `None`。
- 示例：

```python
gm = api.get_game_mode(world_context)
```

### get_game_state

- C++ 签名：`AGameStateBase* GetGameState(const UObject* WorldContextObject)`
- Python：`get_game_state(world_context_object) -> GameStateBase 或 None`
- 说明：返回当前 GameStateBase。
- 示例：

```python
gs = api.get_game_state(world_context)
```

### get_object_class

- C++ 签名：`UClass* GetObjectClass(const UObject* Object)`
- Python：`get_object_class(object) -> Class`
- 说明：返回对象的类。
- 示例：

```python
cls = api.get_object_class(pawn)
```

### object_is_a

- C++ 签名：`bool ObjectIsA(const UObject* Object, TSubclassOf<UObject> ObjectClass)`
- Python：`object_is_a(object, object_class) -> bool`
- 说明：判断对象是否属于（或继承自）指定类。
- 示例：

```python
is_hero = api.object_is_a(pawn, unreal.load_class(\"/Game/Characters/BP_Hero\"))
```

### get_global_time_dilation

- C++ 签名：`float GetGlobalTimeDilation(const UObject* WorldContextObject)`
- Python：`get_global_time_dilation(world_context_object) -> float`
- 说明：返回全局时间膨胀系数。
- 示例：

```python
slomo = api.get_global_time_dilation(world_context)
```

### set_global_time_dilation

- C++ 签名：`void SetGlobalTimeDilation(const UObject* WorldContextObject, float TimeDilation)`
- Python：`set_global_time_dilation(world_context_object, time_dilation) -> None`
- 说明：设置全局时间膨胀系数（影响 Tick 与动画等）。
- 示例：

```python
api.set_global_time_dilation(world_context, 0.5)
```

### set_game_paused

- C++ 签名：`bool SetGamePaused(const UObject* WorldContextObject, bool bPaused)`
- Python：`set_game_paused(world_context_object, b_paused) -> bool`
- 说明：设置暂停状态，成功返回 `True`。
- 示例：

```python
ok = api.set_game_paused(world_context, True)
```

### is_game_paused

- C++ 签名：`bool IsGamePaused(const UObject* WorldContextObject)`
- Python：`is_game_paused(world_context_object) -> bool`
- 说明：返回当前是否暂停。
- 示例：

```python
paused = api.is_game_paused(world_context)
```

### set_force_disable_splitscreen

- C++ 签名：`void SetForceDisableSplitscreen(const UObject* WorldContextObject, bool bDisable)`
- Python：`set_force_disable_splitscreen(world_context_object, b_disable) -> None`
- 说明：强制启用/禁用本地分屏。
- 示例：

```python
api.set_force_disable_splitscreen(world_context, True)
```

### is_splitscreen_force_disabled

- C++ 签名：`bool IsSplitscreenForceDisabled(const UObject* WorldContextObject)`
- Python：`is_splitscreen_force_disabled(world_context_object) -> bool`
- 说明：返回分屏是否被强制禁用。
- 示例：

```python
disabled = api.is_splitscreen_force_disabled(world_context)
```

### set_enable_world_rendering

- C++ 签名：`void SetEnableWorldRendering(const UObject* WorldContextObject, bool bEnable)`
- Python：`set_enable_world_rendering(world_context_object, b_enable) -> None`
- 说明：启用/禁用世界的渲染。
- 示例：

```python
api.set_enable_world_rendering(world_context, False)
```

### get_enable_world_rendering

- C++ 签名：`bool GetEnableWorldRendering(const UObject* WorldContextObject)`
- Python：`get_enable_world_rendering(world_context_object) -> bool`
- 说明：返回世界当前是否渲染。
- 示例：

```python
rendering = api.get_enable_world_rendering(world_context)
```

### get_viewport_mouse_capture_mode

- C++ 签名：`EMouseCaptureMode GetViewportMouseCaptureMode(const UObject* WorldContextObject)`
- Python：`get_viewport_mouse_capture_mode(world_context_object) -> EMouseCaptureMode`
- 说明：返回当前视口鼠标捕获模式。
- 示例：

```python
mode = api.get_viewport_mouse_capture_mode(world_context)
```

### set_viewport_mouse_capture_mode

- C++ 签名：`void SetViewportMouseCaptureMode(const UObject* WorldContextObject, const EMouseCaptureMode MouseCaptureMode)`
- Python：`set_viewport_mouse_capture_mode(world_context_object, mouse_capture_mode) -> None`
- 说明：设置视口鼠标捕获模式。
- 示例：

```python
api.set_viewport_mouse_capture_mode(world_context, unreal.MouseCaptureMode.CAPTURE_DURING_MOUSE_DOWN)
```

## 伤害（Damage）

以下伤害方法为权威端（服务器）语义，需在可应用伤害的运行时上下文中调用。

### apply_radial_damage

- C++ 签名：`bool ApplyRadialDamage(const UObject* WorldContextObject, float BaseDamage, const FVector& Origin, float DamageRadius, TSubclassOf<UDamageType> DamageTypeClass, const TArray<AActor*>& IgnoreActors, AActor* DamageCauser = nullptr, AController* InstigatedByController = nullptr, bool bDoFullDamage = false, ECollisionChannel DamagePreventionChannel = ECC_Visibility)`
- Python：`apply_radial_damage(world_context_object, base_damage, origin, damage_radius, damage_type_class, ignore_actors, damage_causer=None, instigated_by_controller=None, b_do_full_damage=False, damage_prevention_channel=...) -> bool`
- 说明：对半径内至少一个目标施加伤害时返回 `True`；只命中阻挡 Visibility 通道的组件。
- 示例：

```python
damage_type = unreal.load_class("/Script/Engine.DamageType")
hit_any = api.apply_radial_damage(
    world_context, 50.0, unreal.Vector(0, 0, 0), 1000.0, damage_type,
    ignore_actors=[], damage_causer=pawn, instigated_by_controller=pc,
)
```

### apply_radial_damage_with_falloff

- C++ 签名：`bool ApplyRadialDamageWithFalloff(const UObject* WorldContextObject, float BaseDamage, float MinimumDamage, const FVector& Origin, float DamageInnerRadius, float DamageOuterRadius, float DamageFalloff, TSubclassOf<UDamageType> DamageTypeClass, const TArray<AActor*>& IgnoreActors, AActor* DamageCauser = nullptr, AController* InstigatedByController = nullptr, ECollisionChannel DamagePreventionChannel = ECC_Visibility)`
- Python：`apply_radial_damage_with_falloff(world_context_object, base_damage, minimum_damage, origin, damage_inner_radius, damage_outer_radius, damage_falloff, damage_type_class, ignore_actors, damage_causer=None, instigated_by_controller=None, damage_prevention_channel=...) -> bool`
- 说明：带距离衰减的径向伤害，内径内全额伤害、外径外无效。
- 示例：

```python
hit_any = api.apply_radial_damage_with_falloff(
    world_context, 100.0, 10.0, unreal.Vector(0, 0, 0), 200.0, 800.0, 1.0,
    damage_type, [], instigated_by_controller=pc,
)
```

### apply_point_damage

- C++ 签名：`float ApplyPointDamage(AActor* DamagedActor, float BaseDamage, const FVector& HitFromDirection, const FHitResult& HitInfo, AController* EventInstigator, AActor* DamageCauser, TSubclassOf<UDamageType> DamageTypeClass)`
- Python：`apply_point_damage(damaged_actor, base_damage, hit_from_direction, hit_info, event_instigator, damage_causer, damage_type_class) -> float`
- 说明：对指定 Actor 施加带命中方向与命中信息的点伤害；返回实际造成的伤害。
- 示例：

```python
actual = api.apply_point_damage(
    target, 30.0, unreal.Vector(0, 0, -1.0), hit_result, pc, pawn, damage_type,
)
```

### apply_damage

- C++ 签名：`float ApplyDamage(AActor* DamagedActor, float BaseDamage, AController* EventInstigator, AActor* DamageCauser, TSubclassOf<UDamageType> DamageTypeClass)`
- Python：`apply_damage(damaged_actor, base_damage, event_instigator, damage_causer, damage_type_class) -> float`
- 说明：对指定 Actor 施加普通伤害；返回实际造成的伤害。
- 示例：

```python
actual = api.apply_damage(target, 20.0, pc, pawn, damage_type)
```

## 摄像机（Camera）

### play_world_camera_shake

- C++ 签名：`void PlayWorldCameraShake(const UObject* WorldContextObject, TSubclassOf<UCameraShakeBase> Shake, FVector Epicenter, float InnerRadius, float OuterRadius, float Falloff = 1.f, bool bOrientShakeTowardsEpicenter = false)`
- Python：`play_world_camera_shake(world_context_object, shake, epicenter, inner_radius, outer_radius, falloff=1.0, b_orient_shake_towards_epicenter=False) -> None`
- 说明：在世界坐标位置播放摄像机震屏（距离衰减，不复制）。
- 示例：

```python
shake_class = unreal.load_class("/Script/Engine.LegacyCameraShake")
api.play_world_camera_shake(world_context, shake_class, unreal.Vector(0, 0, 0), 0.0, 3000.0)
```

## 粒子特效（Particle Effects）

### spawn_emitter_at_location

- C++ 签名：`UParticleSystemComponent* SpawnEmitterAtLocation(const UObject* WorldContextObject, UParticleSystem* EmitterTemplate, FVector Location, FRotator Rotation = FRotator::ZeroRotator, FVector Scale = FVector(1.f), bool bAutoDestroy = true, EPSCPoolMethod PoolingMethod = EPSCPoolMethod::None, bool bAutoActivateSystem = true)`
- Python：`spawn_emitter_at_location(world_context_object, emitter_template, location, rotation=..., scale=..., b_auto_destroy=True, pooling_method=..., b_auto_activate_system=True) -> ParticleSystemComponent 或 None`
- 说明：在世界位置生成可立即播放的粒子系统组件（Fire and Forget，不复制）。
- 示例：

```python
ps = unreal.load_asset("/Game/Particles/PS_Explosion")
comp = api.spawn_emitter_at_location(world_context, ps, unreal.Vector(0, 0, 100.0))
```

### spawn_emitter_attached

- C++ 签名：`UParticleSystemComponent* SpawnEmitterAttached(UParticleSystem* EmitterTemplate, USceneComponent* AttachToComponent, FName AttachPointName = NAME_None, FVector Location = ..., FRotator Rotation = FRotator::ZeroRotator, FVector Scale = FVector(1.f), EAttachLocation::Type LocationType = EAttachLocation::KeepRelativeOffset, bool bAutoDestroy = true, EPSCPoolMethod PoolingMethod = EPSCPoolMethod::None, bool bAutoActivate = true)`
- Python：`spawn_emitter_attached(emitter_template, attach_to_component, attach_point_name=None, location=..., rotation=..., scale=..., location_type=..., b_auto_destroy=True, pooling_method=..., b_auto_activate=True) -> ParticleSystemComponent 或 None`
- 说明：生成并附着在指定 SceneComponent 上的粒子系统组件。
- 示例：

```python
muzzle = weapon.get_editor_property("muzzle")  # USceneComponent
api.spawn_emitter_attached(ps, muzzle)
```

## 音频（Audio / Sound / Dialogue）

### are_any_listeners_within_range

- C++ 签名：`bool AreAnyListenersWithinRange(const UObject* WorldContextObject, const FVector& Location, float MaximumRange)`
- Python：`are_any_listeners_within_range(world_context_object, location, maximum_range) -> bool`
- 说明：判断是否有音频监听者在指定位置与范围内（无音频设备时恒为 `False`）。
- 示例：

```python
has_listener = api.are_any_listeners_within_range(world_context, point, 2000.0)
```

### get_closest_listener_location

- C++ 签名：`bool GetClosestListenerLocation(const UObject* WorldContextObject, const FVector& Location, float MaximumRange, const bool bAllowAttenuationOverride, FVector& ListenerPosition)`
- Python：`get_closest_listener_location(world_context_object, location, maximum_range, b_allow_attenuation_override) -> (bool, Vector)`
- 说明：返回范围内最近监听者位置；返回布尔结果与 `ListenerPosition` Out 元组。
- 示例：

```python
found, pos = api.get_closest_listener_location(world_context, point, 3000.0, True)
```

### set_global_pitch_modulation

- C++ 签名：`void SetGlobalPitchModulation(const UObject* WorldContextObject, float PitchModulation, float TimeSec)`
- Python：`set_global_pitch_modulation(world_context_object, pitch_modulation, time_sec) -> None`
- 说明：全局设置非 UI 声音的音调调制，并在给定时间内线性过渡。
- 示例：

```python
api.set_global_pitch_modulation(world_context, 0.8, 1.0)
```

### set_sound_class_distance_scale

- C++ 签名：`void SetSoundClassDistanceScale(const UObject* WorldContextObject, USoundClass* SoundClass, float DistanceAttenuationScale, float TimeSec = 0.0f)`
- Python：`set_sound_class_distance_scale(world_context_object, sound_class, distance_attenuation_scale, time_sec=0.0) -> None`
- 说明：设置声音类的距离衰减缩放并在时间内插值。
- 示例：

```python
sc = unreal.load_object(None, "/Game/Audio/SC_Ambient")
api.set_sound_class_distance_scale(world_context, sc, 0.5, 2.0)
```

### set_global_listener_focus_parameters

- C++ 签名：`void SetGlobalListenerFocusParameters(const UObject* WorldContextObject, float FocusAzimuthScale = 1.0f, float NonFocusAzimuthScale = 1.0f, float FocusDistanceScale = 1.0f, float NonFocusDistanceScale = 1.0f, float FocusVolumeScale = 1.0f, float NonFocusVolumeScale = 1.0f, float FocusPriorityScale = 1.0f, float NonFocusPriorityScale = 1.0f)`
- Python：`set_global_listener_focus_parameters(world_context_object, focus_azimuth_scale=1.0, non_focus_azimuth_scale=1.0, focus_distance_scale=1.0, non_focus_distance_scale=1.0, focus_volume_scale=1.0, non_focus_volume_scale=1.0, focus_priority_scale=1.0, non_focus_priority_scale=1.0) -> None`
- 说明：设置全局监听焦点参数（方位/距离/音量/优先级缩放）。
- 示例：

```python
api.set_global_listener_focus_parameters(world_context, focus_distance_scale=0.5)
```

### play_sound_2d

- C++ 签名：`void PlaySound2D(const UObject* WorldContextObject, USoundBase* Sound, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundConcurrency* ConcurrencySettings = nullptr, const AActor* OwningActor = nullptr, bool bIsUISound = true)`
- Python：`play_sound_2d(world_context_object, sound, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, concurrency_settings=None, owning_actor=None, b_is_ui_sound=True) -> None`
- 说明：直接播放 2D 声音（无衰减，适合 UI）。
- 示例：

```python
sfx = unreal.load_asset("/Game/Audio/SFX_Click")
api.play_sound_2d(world_context, sfx)
```

### spawn_sound_2d

- C++ 签名：`UAudioComponent* SpawnSound2D(const UObject* WorldContextObject, USoundBase* Sound, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundConcurrency* ConcurrencySettings = nullptr, bool bPersistAcrossLevelTransition = false, bool bAutoDestroy = true)`
- Python：`spawn_sound_2d(world_context_object, sound, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, concurrency_settings=None, b_persist_across_level_transition=False, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：生成 2D 音频组件并立即播放，返回可控制的组件。
- 示例：

```python
comp = api.spawn_sound_2d(world_context, sfx)
```

### create_sound_2d

- C++ 签名：`UAudioComponent* CreateSound2D(const UObject* WorldContextObject, USoundBase* Sound, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundConcurrency* ConcurrencySettings = nullptr, bool bPersistAcrossLevelTransition = false, bool bAutoDestroy = true)`
- Python：`create_sound_2d(world_context_object, sound, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, concurrency_settings=None, b_persist_across_level_transition=False, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：创建 2D 音频组件（不强制立即播放），便于在生成前配置。
- 示例：

```python
comp = api.create_sound_2d(world_context, sfx)
```

### play_sound_at_location

- C++ 签名：`void PlaySoundAtLocation(const UObject* WorldContextObject, USoundBase* Sound, FVector Location, FRotator Rotation, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr, USoundConcurrency* ConcurrencySettings = nullptr, const AActor* OwningActor = nullptr, const UInitialActiveSoundParams* InitialParams = nullptr)`
- Python：`play_sound_at_location(world_context_object, sound, location, rotation=..., volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None, concurrency_settings=None, owning_actor=None, initial_params=None) -> None`
- 说明：在世界位置播放带衰减的声音（Fire and Forget，不随 Actor 移动）。
- 示例：

```python
api.play_sound_at_location(world_context, sfx, unreal.Vector(0, 0, 100.0))
```

### spawn_sound_at_location

- C++ 签名：`UAudioComponent* SpawnSoundAtLocation(const UObject* WorldContextObject, USoundBase* Sound, FVector Location, FRotator Rotation = FRotator::ZeroRotator, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr, USoundConcurrency* ConcurrencySettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_sound_at_location(world_context_object, sound, location, rotation=..., volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None, concurrency_settings=None, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：在世界位置生成音频组件并播放，返回可操控的组件。
- 示例：

```python
comp = api.spawn_sound_at_location(world_context, sfx, unreal.Vector(0, 0, 100.0))
```

### spawn_sound_attached

- C++ 签名：`UAudioComponent* SpawnSoundAttached(USoundBase* Sound, USceneComponent* AttachToComponent, FName AttachPointName = NAME_None, FVector Location = ..., FRotator Rotation = FRotator::ZeroRotator, EAttachLocation::Type LocationType = EAttachLocation::KeepRelativeOffset, bool bStopWhenAttachedToDestroyed = false, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr, USoundConcurrency* ConcurrencySettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_sound_attached(sound, attach_to_component, attach_point_name=None, location=..., rotation=..., location_type=..., b_stop_when_attached_to_destroyed=False, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None, concurrency_settings=None, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：生成声音并附着指定组件，随组件移动。
- 示例：

```python
comp = api.spawn_sound_attached(sfx, engine_comp, location=unreal.Vector(50, 0, 0))
```

### play_dialogue_2d

- C++ 签名：`void PlayDialogue2D(const UObject* WorldContextObject, UDialogueWave* Dialogue, const FDialogueContext& Context, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f)`
- Python：`play_dialogue_2d(world_context_object, dialogue, context, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0) -> None`
- 说明：直接播放 2D 对话（无衰减，适合 UI）。
- 示例：

```python
dw = unreal.load_asset("/Game/Audio/DW_Hello")
api.play_dialogue_2d(world_context, dw, dialogue_context)
```

### spawn_dialogue_2d

- C++ 签名：`UAudioComponent* SpawnDialogue2D(const UObject* WorldContextObject, UDialogueWave* Dialogue, const FDialogueContext& Context, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, bool bAutoDestroy = true)`
- Python：`spawn_dialogue_2d(world_context_object, dialogue, context, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：生成 2D 对话音频组件并播放。
- 示例：

```python
comp = api.spawn_dialogue_2d(world_context, dw, dialogue_context)
```

### play_dialogue_at_location

- C++ 签名：`void PlayDialogueAtLocation(const UObject* WorldContextObject, UDialogueWave* Dialogue, const FDialogueContext& Context, FVector Location, FRotator Rotation, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr)`
- Python：`play_dialogue_at_location(world_context_object, dialogue, context, location, rotation, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None) -> None`
- 说明：在世界位置播放对话（Fire and Forget）。
- 示例：

```python
api.play_dialogue_at_location(world_context, dw, dialogue_context, unreal.Vector(0, 0, 100.0), unreal.Rotator(0, 0, 0))
```

### spawn_dialogue_at_location

- C++ 签名：`UAudioComponent* SpawnDialogueAtLocation(const UObject* WorldContextObject, UDialogueWave* Dialogue, const FDialogueContext& Context, FVector Location, FRotator Rotation = FRotator::ZeroRotator, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_dialogue_at_location(world_context_object, dialogue, context, location, rotation=..., volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：在世界位置生成对话音频组件并播放。
- 示例：

```python
comp = api.spawn_dialogue_at_location(world_context, dw, dialogue_context, loc)
```

### spawn_dialogue_attached

- C++ 签名：`UAudioComponent* SpawnDialogueAttached(UDialogueWave* Dialogue, const FDialogueContext& Context, USceneComponent* AttachToComponent, FName AttachPointName = NAME_None, FVector Location = ..., FRotator Rotation = FRotator::ZeroRotator, EAttachLocation::Type LocationType = EAttachLocation::KeepRelativeOffset, bool bStopWhenAttachedToDestroyed = false, float VolumeMultiplier = 1.f, float PitchMultiplier = 1.f, float StartTime = 0.f, USoundAttenuation* AttenuationSettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_dialogue_attached(dialogue, context, attach_to_component, attach_point_name=None, location=..., rotation=..., location_type=..., b_stop_when_attached_to_destroyed=False, volume_multiplier=1.0, pitch_multiplier=1.0, start_time=0.0, attenuation_settings=None, b_auto_destroy=True) -> AudioComponent 或 None`
- 说明：生成对话音频组件并附着指定组件。
- 示例：

```python
api.spawn_dialogue_attached(dw, dialogue_context, npc_root_component)
```

## 力反馈（Force Feedback）

### spawn_force_feedback_at_location

- C++ 签名：`UForceFeedbackComponent* SpawnForceFeedbackAtLocation(const UObject* WorldContextObject, UForceFeedbackEffect* ForceFeedbackEffect, FVector Location, FRotator Rotation = FRotator::ZeroRotator, bool bLooping = false, float IntensityMultiplier = 1.f, float StartTime = 0.f, UForceFeedbackAttenuation* AttenuationSettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_force_feedback_at_location(world_context_object, force_feedback_effect, location, rotation=..., b_looping=False, intensity_multiplier=1.0, start_time=0.0, attenuation_settings=None, b_auto_destroy=True) -> ForceFeedbackComponent 或 None`
- 说明：在世界位置生成力反馈组件并播放。
- 示例：

```python
ff = unreal.load_asset("/Game/Audio/FF_Impact")
comp = api.spawn_force_feedback_at_location(world_context, ff, unreal.Vector(0, 0, 0))
```

### spawn_force_feedback_attached

- C++ 签名：`UForceFeedbackComponent* SpawnForceFeedbackAttached(UForceFeedbackEffect* ForceFeedbackEffect, USceneComponent* AttachToComponent, FName AttachPointName = NAME_None, FVector Location = ..., FRotator Rotation = FRotator::ZeroRotator, EAttachLocation::Type LocationType = EAttachLocation::KeepRelativeOffset, bool bStopWhenAttachedToDestroyed = false, bool bLooping = false, float IntensityMultiplier = 1.f, float StartTime = 0.f, UForceFeedbackAttenuation* AttenuationSettings = nullptr, bool bAutoDestroy = true)`
- Python：`spawn_force_feedback_attached(force_feedback_effect, attach_to_component, attach_point_name=None, location=..., rotation=..., location_type=..., b_stop_when_attached_to_destroyed=False, b_looping=False, intensity_multiplier=1.0, start_time=0.0, attenuation_settings=None, b_auto_destroy=True) -> ForceFeedbackComponent 或 None`
- 说明：生成力反馈组件并附着指定组件。
- 示例：

```python
api.spawn_force_feedback_attached(ff, gun_mesh)
```

## 字幕与声音混合（Subtitles / Sound Mix）

### set_subtitles_enabled

- C++ 签名：`void SetSubtitlesEnabled(bool bEnabled)`
- Python：`set_subtitles_enabled(b_enabled) -> None`
- 说明：启用或禁用字幕绘制。
- 示例：

```python
api.set_subtitles_enabled(True)
```

### are_subtitles_enabled

- C++ 签名：`bool AreSubtitlesEnabled()`
- Python：`are_subtitles_enabled() -> bool`
- 说明：返回字幕当前是否启用。
- 示例：

```python
subs = api.are_subtitles_enabled()
```

### set_base_sound_mix

- C++ 签名：`void SetBaseSoundMix(const UObject* WorldContextObject, USoundMix* InSoundMix)`
- Python：`set_base_sound_mix(world_context_object, in_sound_mix) -> None`
- 说明：设置音频系统基础声音混合（用于特殊 EQ）。
- 示例：

```python
mix = unreal.load_object(None, "/Game/Audio/SM_Dialogue")
api.set_base_sound_mix(world_context, mix)
```

### prime_sound

- C++ 签名：`void PrimeSound(USoundBase* InSound)`
- Python：`prime_sound(in_sound) -> None`
- 说明：预加载声音，缓存流式音频首段，减少播放卡顿。
- 示例：

```python
api.prime_sound(sfx)
```

### get_available_spatial_plugin_names

- C++ 签名：`TArray<FName> GetAvailableSpatialPluginNames(const UObject* WorldContextObject)`
- Python：`get_available_spatial_plugin_names(world_context_object) -> Array[Name]`
- 说明：返回可用音频空间化插件名列表。
- 示例：

```python
plugins = api.get_available_spatial_plugin_names(world_context)
```

### get_active_spatial_plugin_name

- C++ 签名：`FName GetActiveSpatialPluginName(const UObject* WorldContextObject)`
- Python：`get_active_spatial_plugin_name(world_context_object) -> Name`
- 说明：返回当前活动音频空间化插件名。
- 示例：

```python
name = api.get_active_spatial_plugin_name(world_context)
```

### set_active_spatial_plugin_by_name

- C++ 签名：`bool SetActiveSpatialPluginByName(const UObject* WorldContextObject, FName InPluginName)`
- Python：`set_active_spatial_plugin_by_name(world_context_object, in_plugin_name) -> bool`
- 说明：按名称切换活动空间化插件，返回是否成功。
- 示例：

```python
ok = api.set_active_spatial_plugin_by_name(world_context, "SP_DEFAULT")
```

### prime_all_sounds_in_sound_class

- C++ 签名：`void PrimeAllSoundsInSoundClass(USoundClass* InSoundClass)`
- Python：`prime_all_sounds_in_sound_class(in_sound_class) -> None`
- 说明：预加载指定声音类下全部声音的流式首段。
- 示例：

```python
api.prime_all_sounds_in_sound_class(sc)
```

### un_retain_all_sounds_in_sound_class

- C++ 签名：`void UnRetainAllSoundsInSoundClass(USoundClass* InSoundClass)`
- Python：`un_retain_all_sounds_in_sound_class(in_sound_class) -> None`
- 说明：释放指定声音类下全部声音的保留块（未播放时可逐出）。
- 示例：

```python
api.un_retain_all_sounds_in_sound_class(sc)
```

### set_sound_mix_class_override

- C++ 签名：`void SetSoundMixClassOverride(const UObject* WorldContextObject, USoundMix* InSoundMixModifier, USoundClass* InSoundClass, float Volume = 1.0f, float Pitch = 1.0f, float FadeInTime = 1.0f, bool bApplyToChildren = true)`
- Python：`set_sound_mix_class_override(world_context_object, in_sound_mix_modifier, in_sound_class, volume=1.0, pitch=1.0, fade_in_time=1.0, b_apply_to_children=True) -> None`
- 说明：覆盖声音混合中的指定声音类调节器。
- 示例：

```python
api.set_sound_mix_class_override(world_context, mix, sc, volume=0.5)
```

### clear_sound_mix_class_override

- C++ 签名：`void ClearSoundMixClassOverride(const UObject* WorldContextObject, USoundMix* InSoundMixModifier, USoundClass* InSoundClass, float FadeOutTime = 1.0f)`
- Python：`clear_sound_mix_class_override(world_context_object, in_sound_mix_modifier, in_sound_class, fade_out_time=1.0) -> None`
- 说明：清除声音混合中的声音类调节器覆盖。
- 示例：

```python
api.clear_sound_mix_class_override(world_context, mix, sc)
```

### push_sound_mix_modifier

- C++ 签名：`void PushSoundMixModifier(const UObject* WorldContextObject, USoundMix* InSoundMixModifier)`
- Python：`push_sound_mix_modifier(world_context_object, in_sound_mix_modifier) -> None`
- 说明：将声音混合修饰器压入音频系统。
- 示例：

```python
api.push_sound_mix_modifier(world_context, mix)
```

### pop_sound_mix_modifier

- C++ 签名：`void PopSoundMixModifier(const UObject* WorldContextObject, USoundMix* InSoundMixModifier)`
- Python：`pop_sound_mix_modifier(world_context_object, in_sound_mix_modifier) -> None`
- 说明：从音频系统移除（弹出）声音混合修饰器。
- 示例：

```python
api.pop_sound_mix_modifier(world_context, mix)
```

### clear_sound_mix_modifiers

- C++ 签名：`void ClearSoundMixModifiers(const UObject* WorldContextObject)`
- Python：`clear_sound_mix_modifiers(world_context_object) -> None`
- 说明：清空全部声音混合修饰器。
- 示例：

```python
api.clear_sound_mix_modifiers(world_context)
```

### activate_reverb_effect

- C++ 签名：`void ActivateReverbEffect(const UObject* WorldContextObject, UReverbEffect* ReverbEffect, FName TagName, float Priority = 0.f, float Volume = 0.5f, float FadeTime = 2.f)`
- Python：`activate_reverb_effect(world_context_object, reverb_effect, tag_name, priority=0.0, volume=0.5, fade_time=2.0) -> None`
- 说明：在音频卷之外手动激活混响效果。
- 示例：

```python
rev = unreal.load_object(None, "/Game/Audio/Rev_Cave")
api.activate_reverb_effect(world_context, rev, "Cave")
```

### deactivate_reverb_effect

- C++ 签名：`void DeactivateReverbEffect(const UObject* WorldContextObject, FName TagName)`
- Python：`deactivate_reverb_effect(world_context_object, tag_name) -> None`
- 说明：按标签停用手动激活的混响效果。
- 示例：

```python
api.deactivate_reverb_effect(world_context, "Cave")
```

### get_current_reverb_effect

- C++ 签名：`UReverbEffect* GetCurrentReverbEffect(const UObject* WorldContextObject)`
- Python：`get_current_reverb_effect(world_context_object) -> ReverbEffect 或 None`
- 说明：返回当前最高优先级混响设置。
- 示例：

```python
rev = api.get_current_reverb_effect(world_context)
```

### set_max_audio_channels_scaled

- C++ 签名：`void SetMaxAudioChannelsScaled(const UObject* WorldContextObject, float MaxChannelCountScale)`
- Python：`set_max_audio_channels_scaled(world_context_object, max_channel_count_scale) -> None`
- 说明：按百分比动态调整最大音频声道数（0.5 减半、1.0 恢复）。
- 示例：

```python
api.set_max_audio_channels_scaled(world_context, 0.5)
```

### get_max_audio_channel_count

- C++ 签名：`int32 GetMaxAudioChannelCount(const UObject* WorldContextObject)`
- Python：`get_max_audio_channel_count(world_context_object) -> int`
- 说明：返回音频引擎当前最大声道数。
- 示例：

```python
channels = api.get_max_audio_channel_count(world_context)
```

## 贴花（Decal）

### spawn_decal_at_location

- C++ 签名：`UDecalComponent* SpawnDecalAtLocation(const UObject* WorldContextObject, UMaterialInterface* DecalMaterial, FVector DecalSize, FVector Location, FRotator Rotation = FRotator(-90, 0, 0), float LifeSpan = 0)`
- Python：`spawn_decal_at_location(world_context_object, decal_material, decal_size, location, rotation=..., life_span=0) -> DecalComponent 或 None`
- 说明：在世界位置生成贴花组件（Fire and Forget，不复制）。需要运行时世界。
- 示例：

```python
mat = unreal.load_asset("/Game/Materials/M_BloodDecal")
comp = api.spawn_decal_at_location(
    world_context, mat, unreal.Vector(40, 40, 40), unreal.Vector(0, 0, 50.0),
)
```

### spawn_decal_attached

- C++ 签名：`UDecalComponent* SpawnDecalAttached(UMaterialInterface* DecalMaterial, FVector DecalSize, USceneComponent* AttachToComponent, FName AttachPointName = NAME_None, FVector Location = ..., FRotator Rotation = ..., EAttachLocation::Type LocationType = EAttachLocation::KeepRelativeOffset, float LifeSpan = 0)`
- Python：`spawn_decal_attached(decal_material, decal_size, attach_to_component, attach_point_name=None, location=..., rotation=..., location_type=..., life_span=0) -> DecalComponent 或 None`
- 说明：生成贴花并附着指定组件，随组件移动。
- 示例：

```python
comp = api.spawn_decal_attached(mat, unreal.Vector(40, 40, 40), wall_component)
```

## 命中结果（Hit Result）

### break_hit_result

- C++ 签名：`void BreakHitResult(const FHitResult& Hit, bool& bBlockingHit, bool& bInitialOverlap, float& Time, float& Distance, FVector& Location, FVector& ImpactPoint, FVector& Normal, FVector& ImpactNormal, UPhysicalMaterial*& PhysMat, AActor*& HitActor, UPrimitiveComponent*& HitComponent, FName& HitBoneName, FName& BoneName, int32& HitItem, int32& ElementIndex, int32& FaceIndex, FVector& TraceStart, FVector& TraceEnd)`
- Python：`break_hit_result(hit) -> (bool, bool, float, float, Vector, Vector, Vector, Vector, PhysicalMaterial 或 None, Actor 或 None, PrimitiveComponent 或 None, Name, Name, int, int, int, Vector, Vector)`
- 说明：多 Out 参数拆解命中结果；按顺序返回全部 Out 元组。
- 示例：

```python
(b_blocking, b_overlap, t, dist, loc, impact, normal, inormal,
 phys_mat, hit_actor, hit_comp, hit_bone, bone, item, elem, face,
 t_start, t_end) = api.break_hit_result(hit_result)
```

### make_hit_result

- C++ 签名：`FHitResult MakeHitResult(bool bBlockingHit, bool bInitialOverlap, float Time, float Distance, FVector Location, FVector ImpactPoint, FVector Normal, FVector ImpactNormal, UPhysicalMaterial* PhysMat, AActor* HitActor, UPrimitiveComponent* HitComponent, FName HitBoneName, FName BoneName, int32 HitItem, int32 ElementIndex, int32 FaceIndex, FVector TraceStart, FVector TraceEnd)`
- Python：`make_hit_result(b_blocking_hit, b_initial_overlap, time, distance, location, impact_point, normal, impact_normal, phys_mat, hit_actor, hit_component, hit_bone_name, bone_name, hit_item, element_index, face_index, trace_start, trace_end) -> HitResult`
- 说明：构造一个 `HitResult` 结构体（与 `break_hit_result` 互逆）。
- 示例：

```python
hr = api.make_hit_result(
    True, False, 0.5, 250.0, unreal.Vector(0,0,50), unreal.Vector(0,0,50),
    unreal.Vector(0,0,1), unreal.Vector(0,0,1), None, target, None,
    "none", "none", 0, 0, 0, unreal.Vector(0,0,0), unreal.Vector(0,0,100),
)
```

### get_surface_type

- C++ 签名：`EPhysicalSurface GetSurfaceType(const FHitResult& Hit)`
- Python：`get_surface_type(hit) -> EPhysicalSurface`
- 说明：返回命中结果的物理表面类型（可配合项目物理表面设置使用）。
- 示例：

```python
surface = api.get_surface_type(hit_result)
```

### find_collision_uv

- C++ 签名：`bool FindCollisionUV(const FHitResult& Hit, int32 UVChannel, FVector2D& UV)`
- Python：`find_collision_uv(hit, uv_channel=0) -> (bool, Vector2D)`
- 说明：查找碰撞命中点的 UV；仅当项目启用 \"Support UV From Hit Results\" 时有效。
- 示例：

```python
found, uv = api.find_collision_uv(hit_result, 0)
```

## 存档（SaveGame）

### create_save_game_object

- C++ 签名：`USaveGame* CreateSaveGameObject(TSubclassOf<USaveGame> SaveGameClass)`
- Python：`create_save_game_object(save_game_class) -> SaveGame 或 None`
- 说明：创建新的空存档对象，写入数据后交给 `save_game_to_slot`。
- 示例：

```python
sg_class = unreal.load_class("/Script/Engine.SaveGame")
sg = api.create_save_game_object(sg_class)
```

### save_game_to_slot

- C++ 签名：`bool SaveGameToSlot(USaveGame* SaveGameObject, const FString& SlotName, const int32 UserIndex)`
- Python：`save_game_to_slot(save_game_object, slot_name, user_index) -> bool`
- 说明：将存档对象序列化写入平台存档槽；成功返回 `True`。需要 PIE/运行时可写的存档系统。
- 示例：

```python
ok = api.save_game_to_slot(sg, "Save_01", 0)
```

### does_save_game_exist

- C++ 签名：`bool DoesSaveGameExist(const FString& SlotName, const int32 UserIndex)`
- Python：`does_save_game_exist(slot_name, user_index) -> bool`
- 说明：检查指定存档槽是否存在存档。
- 示例：

```python
if api.does_save_game_exist("Save_01", 0):
    print("slot exists")
```

### load_game_from_slot

- C++ 签名：`USaveGame* LoadGameFromSlot(const FString& SlotName, const int32 UserIndex)`
- Python：`load_game_from_slot(slot_name, user_index) -> SaveGame 或 None`
- 说明：从存档槽加载存档对象；失败返回 `None`。
- 示例：

```python
loaded = api.load_game_from_slot("Save_01", 0)
if loaded is None:
    print("BLOCKED_INPUT: save not found")
```

### delete_game_in_slot

- C++ 签名：`bool DeleteGameInSlot(const FString& SlotName, const int32 UserIndex)`
- Python：`delete_game_in_slot(slot_name, user_index) -> bool`
- 说明：删除指定存档槽；删到真实存在的文件返回 `True`。
- 示例：

```python
deleted = api.delete_game_in_slot("Save_01", 0)
```

## 时间（Time）

以下时间函数返回运行会话的世界时间，仅 PIE / 运行时可用。

### get_world_delta_seconds

- C++ 签名：`double GetWorldDeltaSeconds(const UObject* WorldContextObject)`
- Python：`get_world_delta_seconds(world_context_object) -> float`
- 说明：返回按时间膨胀调节的帧增量秒数。
- 示例：

```python
dt = api.get_world_delta_seconds(world_context)
```

### get_time_seconds

- C++ 签名：`double GetTimeSeconds(const UObject* WorldContextObject)`
- Python：`get_time_seconds(world_context_object) -> float`
- 说明：世界开始运行以来的秒数，受时间膨胀影响，暂停时停止。
- 示例：

```python
t = api.get_time_seconds(world_context)
```

### get_unpaused_time_seconds

- C++ 签名：`double GetUnpausedTimeSeconds(const UObject* WorldContextObject)`
- Python：`get_unpaused_time_seconds(world_context_object) -> float`
- 说明：世界开始运行以来的秒数，暂停不停止，但受时间膨胀影响。
- 示例：

```python
t = api.get_unpaused_time_seconds(world_context)
```

### get_real_time_seconds

- C++ 签名：`double GetRealTimeSeconds(const UObject* WorldContextObject)`
- Python：`get_real_time_seconds(world_context_object) -> float`
- 说明：世界开始运行以来的真实秒数，不受暂停与时间膨胀影响。
- 示例：

```python
t = api.get_real_time_seconds(world_context)
```

### get_audio_time_seconds

- C++ 签名：`double GetAudioTimeSeconds(const UObject* WorldContextObject)`
- Python：`get_audio_time_seconds(world_context_object) -> float`
- 说明：世界开始运行以来的音频系统秒数，暂停时停止、不做膨胀/钳制。
- 示例：

```python
t = api.get_audio_time_seconds(world_context)
```

### get_accurate_real_time

- C++ 签名：`void GetAccurateRealTime(int32& Seconds, double& PartialSeconds)`
- Python：`get_accurate_real_time() -> (int, float)`（两个 Out 参数按元组返回）
- 说明：返回应用启动以来的精确秒数与小数部分，调用时刻精确。
- 示例：

```python
sec, partial = api.get_accurate_real_time()
```

## 其他全局工具

### enable_live_streaming

- C++ 签名：`void EnableLiveStreaming(bool Enable)`
- Python：`enable_live_streaming(enable) -> None`
- 说明：启用/禁用 DVR 实时流送。需要平台支持。
- 示例：

```python
api.enable_live_streaming(True)
```

### get_platform_name

- C++ 签名：`FString GetPlatformName()`
- Python：`get_platform_name() -> str`
- 说明：返回当前平台名称字符串（Windows、Mac、Linux、IOS、Android、Console 等）。
- 示例：

```python
platform = api.get_platform_name()
```

## 弹道（Projectile）

### blueprint_suggest_projectile_velocity

- C++ 签名：`bool BlueprintSuggestProjectileVelocity(const UObject* WorldContextObject, FVector& TossVelocity, FVector StartLocation, FVector EndLocation, float LaunchSpeed, float OverrideGravityZ, ESuggestProjVelocityTraceOption::Type TraceOption, float CollisionRadius, bool bFavorHighArc, bool bDrawDebug, bool bAcceptClosestOnNoSolutions = false)`
- Python：`blueprint_suggest_projectile_velocity(world_context_object, start_location, end_location, launch_speed, override_gravity_z, trace_option, collision_radius, b_favor_high_arc, b_draw_debug, b_accept_closest_on_no_solutions=False) -> (bool, Vector)`（返回成功标志与 `TossVelocity`）
- 说明：计算抛射体从 Start 命中 End 的初速度；带轨迹验证与调试绘制选项。
- 示例：

```python
ok, toss = api.blueprint_suggest_projectile_velocity(
    world_context, unreal.Vector(0,0,0), unreal.Vector(1000,0,0), 1500.0,
    0.0, unreal.SuggestProjVelocityTraceOption.TRACE_FULL_PATH, 30.0, False, False,
)
```

### blueprint_predict_projectile_path_by_object_type

- C++ 签名：`bool Blueprint_PredictProjectilePath_ByObjectType(const UObject* WorldContextObject, FHitResult& OutHit, TArray<FVector>& OutPathPositions, FVector& OutLastTraceDestination, FVector StartPos, FVector LaunchVelocity, bool bTracePath, float ProjectileRadius, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, float DrawDebugTime, float SimFrequency = 15.f, float MaxSimTime = 2.f, float OverrideGravityZ = 0)`
- Python：`blueprint_predict_projectile_path_by_object_type(world_context_object, start_pos, launch_velocity, b_trace_path, projectile_radius, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, draw_debug_time, sim_frequency=15.0, max_sim_time=2.0, override_gravity_z=0.0) -> (bool, HitResult, Array[Vector], Vector)`（OutHit、OutPathPositions、OutLastTraceDestination 按元组返回）
- 说明：按 ObjectType 追踪预测抛射体弧线路径，返回命中、路径点与终点。
- 示例：

```python
hit_any, hit, path, dest = api.blueprint_predict_projectile_path_by_object_type(
    world_context, start, velocity, True, 20.0, object_types, False, [], 
    unreal.DrawDebugTrace.NONE, 0.0,
)
```

### blueprint_predict_projectile_path_by_trace_channel

- C++ 签名：`bool Blueprint_PredictProjectilePath_ByTraceChannel(const UObject* WorldContextObject, FHitResult& OutHit, TArray<FVector>& OutPathPositions, FVector& OutLastTraceDestination, FVector StartPos, FVector LaunchVelocity, bool bTracePath, float ProjectileRadius, TEnumAsByte<ECollisionChannel> TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, float DrawDebugTime, float SimFrequency = 15.f, float MaxSimTime = 2.f, float OverrideGravityZ = 0)`
- Python：`blueprint_predict_projectile_path_by_trace_channel(world_context_object, start_pos, launch_velocity, b_trace_path, projectile_radius, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, draw_debug_time, sim_frequency=15.0, max_sim_time=2.0, override_gravity_z=0.0) -> (bool, HitResult, Array[Vector], Vector)`
- 说明：按 TraceChannel 追踪预测抛射体弧线路径。
- 示例：

```python
hit_any, hit, path, dest = api.blueprint_predict_projectile_path_by_trace_channel(
    world_context, start, velocity, True, 20.0, unreal.TraceTypeQuery.MAX, False, [], 
    unreal.DrawDebugTrace.NONE, 0.0,
)
```

### blueprint_predict_projectile_path_advanced

- C++ 签名：`bool Blueprint_PredictProjectilePath_Advanced(const UObject* WorldContextObject, const FPredictProjectilePathParams& PredictParams, FPredictProjectilePathResult& PredictResult)`
- Python：`blueprint_predict_projectile_path_advanced(world_context_object, predict_params) -> (bool, PredictProjectilePathResult)`
- 说明：使用参数结构体预测抛射体路径的高级版本；`PredictParams` 与 `PredictResult` 是蓝图结构体。
- 示例：

```python
params = unreal.PredictProjectilePathParams(start_location=start, launch_velocity=velocity)
ok, result = api.blueprint_predict_projectile_path_advanced(world_context, params)
```

### suggest_projectile_velocity_custom_arc

- C++ 签名：`bool SuggestProjectileVelocity_CustomArc(const UObject* WorldContextObject, FVector& OutLaunchVelocity, FVector StartPos, FVector EndPos, float OverrideGravityZ = 0, float ArcParam = 0.5f)`
- Python：`suggest_projectile_velocity_custom_arc(world_context_object, start_pos, end_pos, override_gravity_z=0.0, arc_param=0.5) -> (bool, Vector)`
- 说明：计算自定义弧度抛射初速度（`ArcParam=0.5` 为默认中等弧线，`0` 向上、`1` 直指 End）。
- 示例：

```python
ok, toss = api.suggest_projectile_velocity_custom_arc(world_context, start, end, arc_param=0.6)
```

### suggest_projectile_velocity_moving_target

- C++ 签名：`bool SuggestProjectileVelocity_MovingTarget(const UObject* WorldContextObject, FVector& OutLaunchVelocity, FVector ProjectileStartLocation, AActor* TargetActor, FVector TargetLocationOffset = FVector::ZeroVector, double GravityZOverride = 0.f, double TimeToTarget = 1.f, EDrawDebugTrace::Type DrawDebugType = None, float DrawDebugTime = 3.f, FLinearColor DrawDebugColor = FLinearColor::Red)`
- Python：`suggest_projectile_velocity_moving_target(world_context_object, projectile_start_location, target_actor, target_location_offset=..., gravity_z_override=0.0, time_to_target=1.0, draw_debug_type=..., draw_debug_time=3.0, draw_debug_color=...) -> (bool, Vector)`
- 说明：计算击中运动目标的抛射初速度（目标按常量速度移动，目标时间最小 0.1 秒）。
- 示例：

```python
ok, toss = api.suggest_projectile_velocity_moving_target(world_context, muzzle, target_actor, time_to_target=0.8)
```

## 世界原点与坐标（World Origin）

### get_world_origin_location

- C++ 签名：`FIntVector GetWorldOriginLocation(const UObject* WorldContextObject)`
- Python：`get_world_origin_location(world_context_object) -> IntVector`
- 说明：返回世界原点（大世界坐标偏移）。运行时可用。
- 示例：

```python
origin = api.get_world_origin_location(world_context)
```

### set_world_origin_location

- C++ 签名：`void SetWorldOriginLocation(const UObject* WorldContextObject, FIntVector NewLocation)`
- Python：`set_world_origin_location(world_context_object, new_location) -> None`
- 说明：请求新的世界原点位置。
- 示例：

```python
api.set_world_origin_location(world_context, unreal.IntVector(0, 0, 0))
```

### rebase_local_origin_onto_zero

- C++ 签名：`FVector RebaseLocalOriginOntoZero(UObject* WorldContextObject, FVector WorldLocation)`
- Python：`rebase_local_origin_onto_zero(world_context_object, world_location) -> Vector`
- 说明：把本地（原点相对）坐标换算为原点为零的坐标。
- 示例：

```python
pos = api.rebase_local_origin_onto_zero(world_context, world_loc)
```

### rebase_zero_origin_onto_local

- C++ 签名：`FVector RebaseZeroOriginOntoLocal(UObject* WorldContextObject, FVector WorldLocation)`
- Python：`rebase_zero_origin_onto_local(world_context_object, world_location) -> Vector`
- 说明：把原点为零的坐标换算为本地坐标。
- 示例：

```python
local = api.rebase_zero_origin_onto_local(world_context, origin_pos)
```

## 植被（Foliage）

### grass_overlapping_sphere_count

- C++ 签名：`int32 GrassOverlappingSphereCount(const UObject* WorldContextObject, const UStaticMesh* StaticMesh, FVector CenterPosition, float Radius)`
- Python：`grass_overlapping_sphere_count(world_context_object, static_mesh, center_position, radius) -> int`
- 说明：统计与球体重叠的草植被实例数量。
- 示例：

```python
count = api.grass_overlapping_sphere_count(world_context, grass_mesh, center, 300.0)
```

## 摄像机投影（Camera Projection）

### deproject_screen_to_world

- C++ 签名：`bool DeprojectScreenToWorld(APlayerController const* Player, const FVector2D& ScreenPosition, FVector& WorldPosition, FVector& WorldDirection)`
- Python：`deproject_screen_to_world(player, screen_position) -> (bool, Vector, Vector)`
- 说明：把 2D 屏幕坐标反投影为 3D 世界点与方向（使用玩家视图）。
- 示例：

```python
ok, pos, direction = api.deproject_screen_to_world(pc, unreal.Vector2D(960.0, 540.0))
```

### deproject_scene_capture_to_world

- C++ 签名：`bool DeprojectSceneCaptureToWorld(ASceneCapture2D const* SceneCapture2D, const FVector2D& TargetUV, FVector& WorldPosition, FVector& WorldDirection)`
- Python：`deproject_scene_capture_to_world(scene_capture_2d, target_uv) -> (bool, Vector, Vector)`
- 说明：使用 SceneCapture2D 的视图做反投影。
- 示例：

```python
ok, pos, direction = api.deproject_scene_capture_to_world(scene_capture, unreal.Vector2D(0.5, 0.5))
```

### deproject_scene_capture_component_to_world

- C++ 签名：`bool DeprojectSceneCaptureComponentToWorld(USceneCaptureComponent2D* SceneCaptureComponent2D, const FVector2D& TargetUV, FVector& WorldPosition, FVector& WorldDirection)`
- Python：`deproject_scene_capture_component_to_world(scene_capture_component_2d, target_uv) -> (bool, Vector, Vector)`
- 说明：使用 SceneCaptureComponent2D 的视图做反投影。
- 示例：

```python
ok, pos, direction = api.deproject_scene_capture_component_to_world(comp, unreal.Vector2D(0.5, 0.5))
```

### project_world_to_screen

- C++ 签名：`bool ProjectWorldToScreen(APlayerController const* Player, const FVector& WorldPosition, FVector2D& ScreenPosition, bool bPlayerViewportRelative = false)`
- Python：`project_world_to_screen(player, world_position, b_player_viewport_relative=False) -> (bool, Vector2D)`
- 说明：把 3D 世界点投影为玩家屏幕坐标。
- 示例：

```python
visible, screen_pos = api.project_world_to_screen(pc, pawn.get_actor_location())
```

### transform_world_to_first_person

- C++ 签名：`FVector TransformWorldToFirstPerson(const FMinimalViewInfo& ViewInfo, const FVector& WorldPosition, bool bIgnoreFirstPersonScale)`
- Python：`transform_world_to_first_person(view_info, world_position, b_ignore_first_person_scale) -> Vector`
- 说明：把世界位置变换为第一人称空间位置（用于第一人称几何对应的生成）。
- 示例：

```python
v = api.transform_world_to_first_person(view_info, world_pos, False)
```

### get_view_projection_matrix

- C++ 签名：`void GetViewProjectionMatrix(FMinimalViewInfo DesiredView, FMatrix& ViewMatrix, FMatrix& ProjectionMatrix, FMatrix& ViewProjectionMatrix)`
- Python：`get_view_projection_matrix(desired_view) -> (Matrix, Matrix, Matrix)`
- 说明：返回给定视图的 View、Projection 与 ViewProjection 矩阵。
- 示例：

```python
m_view, m_proj, m_vp = api.get_view_projection_matrix(view_info)
```

## 关卡选项解析（Game Options）

### get_key_value

- C++ 签名：`void GetKeyValue(const FString& Pair, FString& Key, FString& Value)`
- Python：`get_key_value(pair) -> (str, str)`
- 说明：把 `key=value` 对拆为键与值。
- 示例：

```python
key, value = api.get_key_value("difficulty=hard")
```

### parse_option

- C++ 签名：`FString ParseOption(FString Options, const FString& Key)`
- Python：`parse_option(options, key) -> str`
- 说明：从选项字符串中查找键对应的值；未找到返回空串。
- 示例：

```python
val = api.parse_option("host=127.0.0.1?port=7777", "port")
```

### has_option

- C++ 签名：`bool HasOption(FString Options, const FString& InKey)`
- Python：`has_option(options, in_key) -> bool`
- 说明：判断选项字符串中是否存在指定键。
- 示例：

```python
present = api.has_option("?bIsLanMatch", "bIsLanMatch")
```

### get_int_option

- C++ 签名：`int32 GetIntOption(const FString& Options, const FString& Key, int32 DefaultValue)`
- Python：`get_int_option(options, key, default_value) -> int`
- 说明：从选项字符串中读取指定键的整数值，缺失时返回默认值。
- 示例：

```python
max_players = api.get_int_option("?MaxPlayers=32", "MaxPlayers", 16)
```

### has_launch_option

- C++ 签名：`bool HasLaunchOption(const FString& OptionToCheck)`
- Python：`has_launch_option(option_to_check) -> bool`
- 说明：检查启动命令行是否包含指定选项（如 `-demobuild`）。
- 示例：

```python
demo = api.has_launch_option("demobuild")
```

## 无障碍（Accessibility）

### announce_accessible_string

- C++ 签名：`void AnnounceAccessibleString(const FString& AnnouncementString)`
- Python：`announce_accessible_string(announcement_string) -> None`
- 说明：请求平台向玩家播报一行无障碍文本；仅在 Windows 10 / Mac / iOS 支持，且需平台无障碍能力。
- 示例：

```python
api.announce_accessible_string("Objective updated: reach the beacon")
```

## 完整端到端示例

以下脚本在 PIE/运行时中完成：查找玩家、生成 NPC、对 NPC 施加伤害、播放音效并保存存档：

```python
import unreal

def main():
    api = unreal.GameplayStatics
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    pc = api.get_player_controller(world_context, 0)
    pawn = api.get_player_pawn(world_context, 0)
    if pawn is None:
        print({"status": "BLOCKED_INPUT", "reason": "需要 PIE/运行时世界中的玩家 Pawn"})
        return

    npc_class = unreal.load_class("/Game/Blueprints/BP_NPC")
    if npc_class is None:
        print({"status": "BLOCKED_INPUT", "reason": "NPC 类路径不可加载"})
        return

    npcs = api.get_all_actors_of_class(world_context, npc_class)
    nearest, distance = api.find_nearest_actor(pawn.get_actor_location(), npcs)

    if nearest is not None and distance < 20000.0:
        api.apply_point_damage(
            nearest, 25.0, unreal.Vector(0, 0, -1.0), unreal.HitResult(),
            pc, pawn, unreal.load_class("/Script/Engine.DamageType"),
        )

    sfx = unreal.load_asset("/Game/Audio/SFX_Hit")
    if sfx is not None:
        api.play_sound_at_location(world_context, sfx, nearest.get_actor_location())

    sg = api.create_save_game_object(unreal.load_class("/Script/Engine.SaveGame"))
    if sg is not None:
        ok = api.save_game_to_slot(sg, "Runtime_Check", 0)
        print({"status": "OK", "npc_count": len(npcs), "saved": ok})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少世界上下文、Actor/类/资产路径、玩家索引等必要输入。
- `BLOCKED_TOOLING`：运行时上下文不可用（编辑器非运行态、无 PIE 会话、专用服务器缺失本机玩家等），或所需的运行时系统/平台能力缺失。
- 本库绝大多数方法只在 PIE / 运行时可用；在编辑器纯编辑状态执行会返回空/假值或无副作用，按 `BLOCKED_TOOLING` 处理并停止，不得声称已完成。
- 切换关卡、流送加载、世界原点、存档写入等会改变世界或持久状态：实施后必须由审计/QA 独立验收，未验证前不声称已完成。
- 本文件覆盖 `GameplayStatics.h` 中全部带 `UFUNCTION` 标记（`BlueprintCallable / BlueprintPure`）成员的完整清单；标称方法名与精确 Python 暴露名需在目标 UE 5.6 编辑器 `dir()`/`help()` 实测确认后方可断言。