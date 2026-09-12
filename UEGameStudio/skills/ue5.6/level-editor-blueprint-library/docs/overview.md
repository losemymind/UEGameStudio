# LevelEditorBlueprintLibrary 概览（UE 5.6）

## API 摘要

`ULevelEditorBlueprintLibrary` 是 UE 5.6 关卡编辑器级函数库，提供关卡加载、保存、视口控制、PIE 控制与选择集查询能力。

### 分类汇总

| 分类 | 方法数 | 主要用途 |
| --- | --- | --- |
| 世界与模式 | 6 | 获取编辑器/游戏/当前世界，检查运行模式 |
| 关卡加载与保存 | 6 | 加载/卸载/保存关卡，构建光照 |
| 视口控制 | 7 | 刷新/实时/游戏视图，摄像机控制 |
| PIE 控制 | 3 | 开始/停止 PIE 模拟 |
| 摄像机操控 | 3 | 驾驶/释放视口摄像机 |
| 选择集 | 4 | 查询/清空选择集 |
| 其它 | 8 | 视口尺寸/位置、关卡信息等 |

**总计**：37 个 UFUNCTION

### Python 入口

```python
import unreal

api = unreal.LevelEditorBlueprintLibrary
```

## 使用限制

- **Editor Only**：全部方法仅编辑器 Python 可用（`WITH_EDITOR`）；运行时调用返回 `None` 或失败。
- **阻塞处理**：加载/保存/构建方法可能阻塞；建议对 UI 交互类方法单独处理。
- **返回约定**：`bool`/`FString` 等标量直接返回；`void` + Out 参数按返回约定处理；无效上下文返回 `None` 或空数组。
- **未实测声明**：本技能基于头文件整理，未在真实 UE 5.6 Editor 中逐个函数验证；调用前建议 `dir(unreal.LevelEditorBlueprintLibrary)` 核对。

## 阻塞与错误处理

| 阻塞类型 | 条件 | 返回/异常 |
| --- | --- | --- |
| `BLOCKED_INPUT` | 关卡路径无效、文件不存在 | `False` 或空数组 |
| `BLOCKED_TOOLING` | 无编辑器上下文、PIE 运行时调用编辑器专属 API | `None` |
| `BLOCKED_UNVERIFIED` | 未在目标 Editor 实测验证 | 需人工确认 |

## 完整 UFUNCTION 列表（按字母排序）

- `build_actor_lighting()`
- `build_light_maps(quality, b_with_reflection_captures)`
- `clear_selection_set()`
- `editor_get_allows_cinematic_control()`
- `editor_get_exact_camera_view()`
- `editor_get_game_view()`
- `editor_invalidate_viewports()`
- `editor_play_simulate()`
- `editor_request_begin_play()`
- `editor_request_end_play()`
- `editor_set_allows_cinematic_control(b_allow)`
- `editor_set_exact_camera_view(b_exact)`
- `editor_set_game_view(b_game_view)`
- `editor_set_viewport_realtime(b_in_realtime)`
- `eject_pilot_level_actor()`
- `get_current_level()`
- `get_current_world()`
- `get_editor_viewport_position()`
- `get_editor_viewport_size()`
- `get_editor_world()`
- `get_levels(world)`
- `get_level_from_package(world, package_path)`
- `get_game_world()`
- `get_pilot_level_actor()`
- `get_selected_actors()`
- `get_selected_external_assets()`
- `get_selected_external_components()`
- `is_in_editor_mode()`
- `is_in_game_mode()`
- `is_in_play_in_editor()`
- `is_in_profiling_mode()`
- `load_level(world, level_path, b_should_visiblize, b_should_block_on_load)`
- `pilot_level_actor(actor)`
- `save_all_dirty_levels()`
- `save_current_level()`
- `save_level(world, level_path, b_check_modified)`
- `unload_level(world, level_path)`

---

**生成时间**: 2026-09-09  
**版本**: UE 5.6  
**来源**: `Engine/Source/Editor/LevelEditor/Public/LevelEditorBlueprintLibrary.h`
