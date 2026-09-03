# LevelEditorSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/LevelEditor/Public/LevelEditorSubsystem.h` 整理 `ULevelEditorSubsystem` 中带 `UFUNCTION(BlueprintCallable)` 标记、可由 Python 调用的成员，共 26 个。Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无 ScriptMethod 时按 C++ 函数名转 snake_case；本子系统头文件未声明 ScriptMethod，故按 C++ 函数名转写。每个成员给出 C++ 签名、Python 调用形态与完整示例；精确 Python 暴露名与默认参数形态需在目标 UE 5.6 编辑器实测确认。

## 获取子系统

本子系统派生自 `UEditorSubsystem`，使用 `unreal.get_editor_subsystem` 获取：

```python
import unreal

api = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: LevelEditorSubsystem 不可用")
```

## 通用约定

- 关卡路径使用内容路径形式：`/Game/Maps/MyLevel`（不含 `.umap` 后缀）。
- 视图参数使用 `unreal.Name`：`None` 表示当前激活视图；可用配置键见 `get_viewport_config_keys()`。
- 全部成员无 Out 参数，返回形态即 C++ 返回值本身。

## 关卡加载与创建

### load_level

- C++ 签名：`bool LoadLevel(const FString& AssetPath)`
- Python：`load_level(asset_path) -> bool`
- 说明：关闭当前 Persistent Level（不保存）并加载指定关卡，成功返回 `True`。
- 示例：

```python
ok = api.load_level("/Game/Maps/ST_Level")
if not ok:
    print("BLOCKED_INPUT: 关卡路径不存在或加载失败")
```

### new_level

- C++ 签名：`bool NewLevel(const FString& AssetPath, bool bIsPartitionedWorld = false)`
- Python：`new_level(asset_path, b_is_partitioned_world=False) -> bool`
- 说明：关闭当前 Persistent Level（不保存），创建并保存一个新的空白关卡后加载；分块世界（Partitioned World）时传 `True`。
- 示例：

```python
created = api.new_level("/Game/Maps/NewMap")
if not created:
    print("new level 创建失败")
```

### new_level_from_template

- C++ 签名：`bool NewLevelFromTemplate(const FString& AssetPath, const FString& TemplateAssetPath)`
- Python：`new_level_from_template(asset_path, template_asset_path) -> bool`
- 说明：以 TemplateAssetPath 关卡为模板创建新关卡并保存加载。
- 示例：

```python
created = api.new_level_from_template("/Game/Maps/ST_Level_Copy", "/Game/Maps/ST_Level")
if created:
    api.save_current_level()
```

## 当前关卡信息

### get_current_level

- C++ 签名：`ULevel* GetCurrentLevel()`
- Python：`get_current_level() -> Level`
- 说明：返回世界编辑器当前使用的关卡对象。
- 示例：

```python
level = api.get_current_level()
if level is None:
    print("当前关卡不可用")
else:
    print("current level:", level.get_name())
```

### set_current_level_by_name

- C++ 签名：`bool SetCurrentLevelByName(FName LevelName)`
- Python：`set_current_level_by_name(level_name) -> bool`
- 说明：按名称切换当前编辑关卡；重名时使用先遇到的同名关卡，成功返回 `True`。
- 示例：

```python
ok = api.set_current_level_by_name(unreal.Name("ST_SubLevel"))
print("current level set:", ok)
```

## 关卡保存

### save_current_level

- C++ 签名：`bool SaveCurrentLevel()`
- Python：`save_current_level() -> bool`
- 说明：保存当前关卡；关卡须至少已保存过一次才有有效路径。
- 示例：

```python
if not api.save_current_level():
    print("当前关卡保存失败，缺少有效路径或写入被拒")
```

### save_all_dirty_levels

- C++ 签名：`bool SaveAllDirtyLevels()`
- Python：`save_all_dirty_levels() -> bool`
- 说明：保存世界编辑器当前加载的全部脏关卡。
- 示例：

```python
all_saved = api.save_all_dirty_levels()
print("all dirty levels saved:", all_saved)
```

## 关卡构建

### build_light_maps

- C++ 签名：`bool BuildLightMaps(ELightingBuildQuality Quality = Quality_Production, bool bWithReflectionCaptures = false)`
- Python：`build_light_maps(quality=..., b_with_reflection_captures=False) -> bool`
- 说明：构建光照贴图并可随后重建反射捕获；枚举默认工业级生产质量 `unreal.LightingBuildQuality.PRODUCTION`（精确枚举成员名以实测为准）。
- 示例：

```python
built = api.build_light_maps(
    quality=unreal.LightingBuildQuality.PRODUCTION,
    b_with_reflection_captures=True,
)
print("light maps built:", built)
```

## 选择集

### get_selection_set

- C++ 签名：`UTypedElementSelectionSet* GetSelectionSet()`
- Python：`get_selection_set() -> TypedElementSelectionSet`
- 说明：返回当前世界编辑器选择集对象，可跟踪与修改编辑器选择；读取选择需调用该对象自身暴露的查询方法。
- 示例：

```python
selection = api.get_selection_set()
if selection is not None:
    print("selection set object available")
```

## 视口

### editor_invalidate_viewports

- C++ 签名：`void EditorInvalidateViewports()`
- Python：`editor_invalidate_viewports() -> None`
- 说明：请求刷新全部编辑器视口。
- 示例：

```python
api.editor_invalidate_viewports()
```

### editor_set_viewport_realtime

- C++ 签名：`void EditorSetViewportRealtime(bool bInRealtime, FName ViewportConfigKey = NAME_None)`
- Python：`editor_set_viewport_realtime(b_in_realtime, viewport_config_key=None) -> None`
- 说明：设置视口实时显示（realtime）开关。
- 示例：

```python
api.editor_set_viewport_realtime(True)
```

### editor_set_game_view

- C++ 签名：`void EditorSetGameView(bool bGameView, FName ViewportConfigKey = NAME_None)`
- Python：`editor_set_game_view(b_game_view, viewport_config_key=None) -> None`
- 说明：设置视口 GameView（隐藏编辑器辅助显示）。
- 示例：

```python
api.editor_set_game_view(True)
```

### editor_get_game_view

- C++ 签名：`bool EditorGetGameView(FName ViewportConfigKey = NAME_None)`
- Python：`editor_get_game_view(viewport_config_key=None) -> bool`
- 说明：查询视口是否处于 GameView。
- 示例：

```python
is_game_view = api.editor_get_game_view()
```

### get_viewport_config_keys

- C++ 签名：`TArray<FName> GetViewportConfigKeys()`
- Python：`get_viewport_config_keys() -> Array[Name]`
- 说明：返回全部已保存视口配置的键。
- 示例：

```python
keys = api.get_viewport_config_keys()
print("viewport configs:", [str(k) for k in keys])
```

### get_active_viewport_config_key

- C++ 签名：`FName GetActiveViewportConfigKey()`
- Python：`get_active_viewport_config_key() -> Name`
- 说明：返回当前激活视口的配置键。
- 示例：

```python
active_key = api.get_active_viewport_config_key()
```

### set_allows_cinematic_control

- C++ 签名：`void SetAllowsCinematicControl(bool bAllow, FName ViewportConfigKey = NAME_None)`
- Python：`set_allows_cinematic_control(b_allow, viewport_config_key=None) -> None`
- 说明：允许或禁止视口接受影视级摄像机控制。
- 示例：

```python
api.set_allows_cinematic_control(True)
```

### get_allows_cinematic_control

- C++ 签名：`bool GetAllowsCinematicControl(FName ViewportConfigKey = NAME_None)`
- Python：`get_allows_cinematic_control(viewport_config_key=None) -> bool`
- 说明：查询视口是否允许影视级摄像机控制。
- 示例：

```python
allowed = api.get_allows_cinematic_control()
```

## 摄像机

### pilot_level_actor

- C++ 签名：`void PilotLevelActor(AActor* ActorToPilot, FName ViewportConfigKey = NAME_None)`
- Python：`pilot_level_actor(actor_to_pilot, viewport_config_key=None) -> None`
- 说明：让指定视口驾驶目标 Actor（Pilot），视口以该 Actor 为根。
- 示例：

```python
target = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world().get_actor_by_label("CameraRig")
api.pilot_level_actor(target)
```

### eject_pilot_level_actor

- C++ 签名：`void EjectPilotLevelActor(FName ViewportConfigKey = NAME_None)`
- Python：`eject_pilot_level_actor(viewport_config_key=None) -> None`
- 说明：结束视口驾驶并退出 Pilot。
- 示例：

```python
api.eject_pilot_level_actor()
```

### get_pilot_level_actor

- C++ 签名：`AActor* GetPilotLevelActor(FName ViewportConfigKey = NAME_None)`
- Python：`get_pilot_level_actor(viewport_config_key=None) -> Actor | None`
- 说明：返回当前被驾驶的 Actor；未驾驶时返回 `None`。
- 示例：

```python
piloted = api.get_pilot_level_actor()
print("pilot actor:", piloted.get_actor_label() if piloted else None)
```

### get_exact_camera_view

- C++ 签名：`bool GetExactCameraView(FName ViewportConfigKey = NAME_None)`
- Python：`get_exact_camera_view(viewport_config_key=None) -> bool`
- 说明：查询视口是否保持精确摄像机视图。
- 示例：

```python
exact = api.get_exact_camera_view()
```

### set_exact_camera_view

- C++ 签名：`void SetExactCameraView(bool bExactCameraView, FName ViewportConfigKey = NAME_None)`
- Python：`set_exact_camera_view(b_exact_camera_view, viewport_config_key=None) -> None`
- 说明：设置视口精确摄像机视图开关。
- 示例：

```python
api.set_exact_camera_view(True)
```

## 编辑模拟（PIE）

### editor_play_simulate

- C++ 签名：`void EditorPlaySimulate()`
- Python：`editor_play_simulate() -> None`
- 说明：进入编辑器模拟（Simulate in Editor）模式。
- 示例：

```python
api.editor_play_simulate()
```

### editor_request_begin_play

- C++ 签名：`void EditorRequestBeginPlay()`
- Python：`editor_request_begin_play() -> None`
- 说明：请求启动 Play in Editor。
- 示例：

```python
api.editor_request_begin_play()
```

### editor_request_end_play

- C++ 签名：`void EditorRequestEndPlay()`
- Python：`editor_request_end_play() -> None`
- 说明：请求结束 Play in Editor。
- 示例：

```python
api.editor_request_end_play()
```

### is_in_play_in_editor

- C++ 签名：`bool IsInPlayInEditor()`
- Python：`is_in_play_in_editor() -> bool`
- 说明：查询当前是否处于 Play in Editor。
- 示例：

```python
in_pie = api.is_in_play_in_editor()
print("in PIE:", in_pie)
```

## 完整示例：安全加载关卡并执行保存

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "LevelEditorSubsystem 不可用"})
        return

    api.eject_pilot_level_actor()

    ok = api.load_level("/Game/Maps/ST_Level")
    if not ok:
        print({"status": "BLOCKED_INPUT", "reason": "关卡路径不存在或加载失败"})
        return

    level = api.get_current_level()
    print({"status": "OK", "current_level": level.get_name() if level else None})

    if not api.save_current_level():
        print({"status": "BLOCKED_TOOLING", "reason": "当前关卡保存失败"})
        return

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少关卡 AssetPath、路径不可加载或目标类不可用。
- `BLOCKED_TOOLING`：子系统或编辑器上下文不可用，无法执行操作。
- 关卡加载、新建与保存会变更编辑器世界与资产状态，属世界构建边界（`ue-world-builder` 主责）；本 skill 只提供 LevelEditorSubsystem 的 Python 调用 API，不替代世界构建流程、审核与独立验收；未验证前不得声称关卡工作已完成。
- 本文件只收录头文件中带 `UFUNCTION(BlueprintCallable)` 标记、可由 Python 调用的成员；精确 Python 暴露名、默认参数与枚举成员名需在目标 UE 5.6 编辑器实测确认。