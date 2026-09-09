# WidgetBlueprintLibrary - API 参考（UE 5.6）

本文件整理 `Engine/Source/Runtime/UMG/Public/Blueprint/WidgetBlueprintLibrary.h` 中通过 Python 可暴露的 static `UFUNCTION`。所有方法经 Python 反射暴露在 `unreal.WidgetBlueprintLibrary` 类上，精确 snake_case 名以目标 5.6 编辑器 `dir(unreal.WidgetBlueprintLibrary)` 为准。

## 一、Create 创建与全局查找

### `create`
```python
unreal.WidgetBlueprintLibrary.create(
    world_context,              # WorldContextObject: 编辑器世界或当前游戏世界
    widget_class,               # BlueprintGeneratedClass (WBP_* 资产)
    owning_player=None,         # PlayerController，控件所属玩家；运行时场景建议传入
) -> unreal.UserWidget | None
```
C++: `static UUserWidget* Create(UObject* WorldContextObject, TSubclassOf<UUserWidget> WidgetType, APlayerController* OwningPlayer);`

### `get_all_widgets_of_class`
```python
unreal.WidgetBlueprintLibrary.get_all_widgets_of_class(
    world_context, widget_class, top_level_only=True,
) -> list[unreal.UserWidget]
```
C++: `static void GetAllWidgetsOfClass(UObject*, TArray<UUserWidget*>& FoundWidgets, TSubclassOf<UUserWidget> WidgetClass, bool TopLevelOnly);`

### `get_all_widgets_with_interface`
```python
unreal.WidgetBlueprintLibrary.get_all_widgets_with_interface(
    world_context, interface_class, top_level_only=False,
) -> list[unreal.UserWidget]
```
C++: `static void GetAllWidgetsWithInterface(UObject*, TArray<UUserWidget*>&, TSubclassOf<UInterface>);`

## 二、InputMode（运行时独占/混合模式）

| Python | 参数 | 说明 |
| --- | --- | --- |
| `set_input_mode_ui_only(player_controller, widget_to_focus=None, mouse_lock_mode=0, flush_input=False)` | `widget_to_focus: Widget`, `mouse_lock_mode: EMouseLockMode`, `flush_input: bool` | 纯 UI 模式，捕获鼠标到视口 |
| `set_input_mode_game_and_ui(player_controller, widget_to_focus=None, mouse_lock_mode=0, hide_cursor_during_capture=True, flush_input=False)` | 同上 + `hide_cursor_during_capture` | 游戏与 UI 并存 |
| `set_input_mode_game_only(player_controller, center_cursor_to_game_window=True)` | `center_cursor_to_game_window: bool` | 纯游戏模式 |
| `set_input_mode_none(player_controller)` | - | 无鼠标捕获模式 |

C++: `SetInputMode_UIOnly / _GameAndUI / _GameOnly / _None`。需要有效 `APlayerController`。

## 三、Canvas Paint 绘制原语

以下方法只能在控件 `Paint` 上下文内由 `FPaintContext&` 驱动，Python 顶层脚本不能直接构造 `FPaintContext`。若在编辑器 Python 中需要 UI 调试绘制，改用 `unreal.DebugDraw` 或自定义 UserWidget Paint 事件配合蓝图节点。

| Python | C++ 要点 | 参数 |
| --- | --- | --- |
| `draw_box(context, position, size, brush, tint=白)` | `DrawBox(FPaintContext&, FVector2D, FVector2D, USlateBrushAsset*, FLinearColor)` | brush 可用 `make_brush_from_*` 产出 |
| `draw_line(context, pos_a, pos_b, tint=白, anti_alias=True, thickness=1.0)` | `DrawLine(FPaintContext&, FVector2D, FVector2D, FLinearColor, bool, float)` | 两点连线 |
| `draw_lines(context, points, tint=白, anti_alias=True, thickness=1.0)` | `DrawLines(FPaintContext&, TArray<FVector2D>, FLinearColor, bool, float)` | 折线 |
| `draw_spline(context, start, start_dir, end, end_dir, tint=白, thickness=1.0)` | `DrawSpline(FPaintContext&, FVector2D×4, FLinearColor, float)` | 贝塞尔样条 |
| `draw_text(context, text, position, tint=白)` | `DrawText(FPaintContext&, FString, FVector2D, FLinearColor)` | 基础文本 |
| `draw_text_formatted(context, text, position, font=None, font_size=16, tint=白)` | `DrawTextFormatted(FPaintContext&, FText, FVector2D, UFont*, int32, FLinearColor)` | 指定字体字号 |
| `draw_material(context, material, position, size=0,0, scale=1,1)` | `DrawMaterial(FPaintContext&, UMaterialInterface*, FVector2D, FVector2D, FVector2D, FVector2D, FLinearColor)` | 材质绘制 |

## 四、Brush 工厂与动态材质

| Python | C++ | 返回 |
| --- | --- | --- |
| `make_brush_from_texture(texture, width, height)` | `MakeBrushFromTexture(UTexture2D*, int32, int32)` | `FSlateBrush` |
| `make_brush_from_material(material, width, height)` | `MakeBrushFromMaterial(UMaterialInterface*, int32, int32)` | `FSlateBrush` |
| `make_brush_from_asset(brush_asset)` | `MakeBrushFromAsset(USlateBrushAsset*)` | `FSlateBrush` |
| `get_dynamic_material(material)` | `GetDynamicMaterial(UMaterialInterface*, UMaterialInstanceDynamic*&)` | `MaterialInstanceDynamic` |

## 五、DragDrop

| Python | 说明 |
| --- | --- |
| `create_drag_drop_operation(operation_class)` | 创建拖放操作对象（`TSubclassOf<UDragDropOperation>`）→ `DragDropOperation` |
| `get_drag_drop_operation()` | 返回当前拖放操作或 `None` |
| `cancel_drag_drop()` | 取消进行中的拖放 |

## 六、视口 / 光标 / 杂项

| Python | 返回 | 备注 |
| --- | --- | --- |
| `get_viewport_size(world_context)` | `Vector2D` | 游戏视口像素尺寸 |
| `get_viewport_scale(world_context)` | `float` | DPI 缩放比 |
| `set_hardware_cursor(player_controller, cursor_shape, cursor_name='', hotspot=0,0)` | `bool` | 设置 OS 硬件光标；`cursor_shape: EMouseCursor` |
| `is_gamepad_attached()` | `bool` | 是否接入手柄 |
| `get_focus_widget()` | `Widget` | 当前键盘焦点控件或 `None` |

## 绑定约定

- Out/ByRef 参数：`void` + 单 Out → 直接作为返回值；返回值 + Out → 元组 `(返回, out...)`。
- 缺失必要输入（world/class/PC 无效）返回 `BLOCKED_INPUT`；无 PIE/运行环境执行 InputMode 返回 `BLOCKED_TOOLING`。
- 所有 Python 暴露名未经真实 5.6 Editor 实测前标注"推断名"，须 `dir()` 核对。
