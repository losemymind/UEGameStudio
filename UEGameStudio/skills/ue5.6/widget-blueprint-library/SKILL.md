---
name: widget-blueprint-library
description: UWidgetBlueprintLibrary（UE 5.6）UMG 全局函数库 - 运行时创建 UserWidget、输入模式切换、Canvas 绘制原语、Brush 资源转换、DragDrop 与 HardwareCursor 操作；Agent 需要通过 unreal Python 在运行时或编辑器对 UMG 控件与视口做全局操作时使用
risk: safe
category: development
tags: [ue5.6, umg, widget, python, blueprint-function-library]
---

# WidgetBlueprintLibrary - UMG 全局函数库（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 在运行时或编辑器对 UMG 控件与视口做全局操作时使用本 skill（description 触发场景）。
- 本 skill 只在与 widget-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UWidgetBlueprintLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法与签名依据 `Engine/Source/Runtime/UMG/Public/Blueprint/WidgetBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 的 static 成员整理；Python 方法名按 `meta=(ScriptName=...)` / 反射 snake_case 约定。

## 入口说明

`UBlueprintFunctionLibrary` 的 static 函数在 Python 中以类方法暴露于 `unreal.WidgetBlueprintLibrary`，首个实参通常是 `WorldContextObject`（可用编辑器世界 / 当前游戏世界）：

```python
import unreal

world = unreal.EditorLevelLibrary.get_editor_world()
wl = unreal.WidgetBlueprintLibrary
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.WidgetBlueprintLibrary)` 核对）。
- 全部方法均为静态类方法；`unreal.WidgetBlueprintLibrary` 为类对象而非实例。

## 可用操作

### Create 创建控件

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 创建 | `create(world_context, widget_class, owning_player=None)` | `UUserWidget* Create(UObject* WorldContextObject, TSubclassOf<UUserWidget> WidgetType, APlayerController* OwningPlayer)` | `UserWidget` |
| 查找 | `get_all_widgets_of_class(world_context, widget_class, top_level_only=True)` | `void GetAllWidgetsOfClass(UObject*, TArray<UUserWidget*>&, TSubclassOf<UUserWidget>, bool)` | `Array[UserWidget]` |
| 查找 | `get_all_widgets_with_interface(world_context, interface_class, top_level_only=False)` | `void GetAllWidgetsWithInterface(UObject*, TArray<UUserWidget*>&, UClass*)` | `Array[UserWidget]` |

### InputMode 输入模式（有 PlayerController 实参）

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 输入 | `set_input_mode_ui_only(player_controller, widget_to_focus=None, mouse_lock_mode=0)` | `void SetInputMode_UIOnly(APlayerController*, UWidget*, EMouseLockMode, bool)` | `None` |
| 输入 | `set_input_mode_game_and_ui(player_controller, widget_to_focus=None, hide_cursor_during_capture=True)` | `void SetInputMode_GameAndUI(APlayerController*, UWidget*, EMouseLockMode, bool, bool)` | `None` |
| 输入 | `set_input_mode_game_only(player_controller, center_cursor_to_game_window=True)` | `void SetInputMode_GameOnly(APlayerController*, bool)` | `None` |
| 输入 | `set_input_mode_none(player_controller)` | `void SetInputMode_None(APlayerController*)` | `None` |

### Canvas Paint 绘制原语

所有 Draw 方法都要求 `FPaintContext`——只能在控件 `OnPaint`（蓝图事件或自定义 `UUserWidget` paint）中产生，**不可在普通 Python 脚本直接伪造**；Python 侧一般通过自定义 UserWidget 的 Paint 事件或 DebugDraw 进入。记录以备 Agent 在 UMG 绘制上下文内对齐节点名。

| Python 方法名（snake_case） | C++ 签名 | 说明 |
| --- | --- | --- |
| `draw_box(context, position, size, brush, tint=白)` | `void DrawBox(FPaintContext&, FVector2D, FVector2D, USlateBrushAsset*, FLinearColor)` | 实心/边框矩形 |
| `draw_line(context, pos_a, pos_b, tint=白, anti_alias=True, thickness=1.0)` | `void DrawLine(FPaintContext&, FVector2D, FVector2D, FLinearColor, bool, float)` | 线段 |
| `draw_lines(context, points, tint=白, anti_alias=True, thickness=1.0)` | `void DrawLines(FPaintContext&, TArray<FVector2D>, FLinearColor, bool, float)` | 多段线 |
| `draw_spline(context, start, start_dir, end, end_dir, tint=白, thickness=1.0)` | `void DrawSpline(FPaintContext&, FVector2D, FVector2D, FVector2D, FVector2D, FLinearColor, float)` | 贝塞尔样条 |
| `draw_text(context, text, position, tint=白)` | `void DrawText(FPaintContext&, FString, FVector2D, FLinearColor)` | 文本 |
| `draw_text_formatted(context, text, position, font=None, font_size=16, tint=白)` | `void DrawTextFormatted(FPaintContext&, FText, FVector2D, UFont*, int32, FLinearColor)` | 带字体文本 |
| `draw_material(context, material, position, size=自动)` | `void DrawMaterial(FPaintContext&, UMaterialInterface*, FVector2D, FVector2D, FVector2D, FVector2D, FLinearColor)` | 材质绘制 |

### Brush / 资源转换

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `make_brush_from_texture(texture, width, height)` | `FSlateBrush MakeBrushFromTexture(UTexture2D*, int32, int32)` | `SlateBrush` |
| `make_brush_from_material(material, width, height)` | `FSlateBrush MakeBrushFromMaterial(UMaterialInterface*, int32, int32)` | `SlateBrush` |
| `make_brush_from_asset(brush_asset)` | `FSlateBrush MakeBrushFromAsset(USlateBrushAsset*)` | `SlateBrush` |
| `get_dynamic_material(material)` | `void GetDynamicMaterial(UMaterialInterface*, UMaterialInstanceDynamic*&)` | `MaterialInstanceDynamic` |

### DragDrop 拖放

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `create_drag_drop_operation(operation_class)` | `UDragDropOperation* CreateDragDropOperation(TSubclassOf<UDragDropOperation>)` | `DragDropOperation` |
| `get_drag_drop_operation()` | `UDragDropOperation* GetDragDropOperation()` | `DragDropOperation` 或 `None` |
| `cancel_drag_drop()` | `void CancelDragDrop()` | `None` |

### 其它（视口 / 光标 / 游戏垫）

| Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- |
| `get_viewport_size(world_context)` | `void GetViewportSize(UObject*, FVector2D&)` | `Vector2D` |
| `get_viewport_scale(world_context)` | `float GetViewportScale(UObject*)` | `float` |
| `set_hardware_cursor(player_controller, cursor_shape, cursor_name='', hotspot=0,0)` | `bool SetHardwareCursor(APlayerController*, EMouseCursor::Type, FName, FVector2D)` | `bool` |
| `is_gamepad_attached()` | `bool IsGamepadAttached()` | `bool` |
| `get_focus_widget()` | `UWidget* GetFocusWidget()` | `Widget` 或 `None` |

## 示例

```python
import unreal

world = unreal.EditorLevelLibrary.get_editor_world()
wl = unreal.WidgetBlueprintLibrary

bp = unreal.load_asset("/Game/UI/WBP_HUD")
if bp is None or not isinstance(bp, unreal.BlueprintGeneratedClass):
    print("BLOCKED_INPUT: widget class not loadable")
    raise SystemExit(1)

widget = wl.create(world, bp)
print("created:", widget is not None)
```

## 限制和注意事项

- `create` 用蓝图生成类（`BlueprintGeneratedClass` 资产）作为 `widget_class`；运行时创建绑定 GameInstance/PlayerController 的场景需传 `owning_player`。
- `set_input_mode_*` 需有效 `PlayerController`（PIE 或运行中游戏世界）；编辑器纯预览模式无玩家控制器时返回 `BLOCKED_TOOLING`。
- `draw_*` 系列需 `FPaintContext`，脱离 UMG Paint 上下文调用无效——此点与纯数据类函数库不同，勿在脚本顶层直接调用。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- `get_dynamic_material` / `make_brush_*` 在 Python 中暴露方式以目标编辑器 `dir()` 为准。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
