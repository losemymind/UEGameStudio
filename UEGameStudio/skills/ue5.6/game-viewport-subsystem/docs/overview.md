# GameViewportSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/UMG/Public/Blueprint/GameViewportSubsystem.h` 整理 `UGameViewportSubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case；精确 Python 暴露名需实测确认。

## 获取子系统

`UGameViewportSubsystem` 派生自 `UEngineSubsystem`（全局引擎子系统）：

```python
import unreal

api = unreal.get_engine_subsystem(unreal.GameViewportSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: GameViewportSubsystem 不可用")
```

- 返回 `None` 表示子系统不可用，按 `BLOCKED_TOOLING` 处理并停止。
- Widget 槽位使用 `unreal.GameViewportWidgetSlot`（`Anchors` / `Offsets` / `Alignment` / `ZOrder` / `b_auto_remove_on_world_removed`）。
- 坐标/尺寸使用 `unreal.Vector2D`，锚点使用 `unreal.Anchors`，边距使用 `unreal.Margin`。

## 通用约定

- 所有操作需 PIE/运行时上下文才能体现效果；纯编辑器模式无活动视口时按 `BLOCKED_TOOLING` 处理。
- `add_widget` 的 widget 必须是已构造的 UMG Widget 实例；未构造或资产加载失败返回 `False`。
- `add_widget_for_player` 用于分屏场景，只将 Widget 显示在指定玩家对应的视口区域。

## 查询操作

### is_widget_added

- C++ 签名：`bool IsWidgetAdded(const UWidget* Widget) const`
- Python：`is_widget_added(widget) -> bool`
- 说明：查询指定 Widget 是否已添加到视口。
- 示例：

```python
added = api.is_widget_added(my_widget)
if added:
    print("Widget is currently visible")
```

### get_widget_slot

- C++ 签名：`FGameViewportWidgetSlot GetWidgetSlot(const UWidget* Widget) const`
- Python：`get_widget_slot(widget) -> GameViewportWidgetSlot`
- 说明：获取指定 Widget 的槽位参数。
- 示例：

```python
slot = api.get_widget_slot(my_widget)
print("slot anchors:", slot.anchors)
```

## 添加与移除

### add_widget

- C++ 签名：`bool AddWidget(UWidget* Widget, FGameViewportWidgetSlot Slot)`
- Python：`add_widget(widget, slot) -> bool`
- 说明：向视口添加指定 Widget；成功返回 `True`。
- 示例：

```python
slot = unreal.GameViewportWidgetSlot(
    anchors=unreal.Anchors(0.5, 0.5, 0.5, 0.5),
    offsets=unreal.Margin(0.0, 0.0, 0.0, 0.0),
    z_order=10,
)
added = api.add_widget(my_widget, slot)
if not added:
    print("BLOCKED_INPUT: widget 已添加或构造失败")
```

### add_widget_for_player

- C++ 签名：`bool AddWidgetForPlayer(UWidget* Widget, ULocalPlayer* Player, FGameViewportWidgetSlot Slot)`
- Python：`add_widget_for_player(widget, player, slot) -> bool`
- 说明：向指定玩家的视口区域添加 Widget。
- 示例：

```python
local_players = api.get_local_players()  # 需要额外获取
if local_players:
    added = api.add_widget_for_player(my_widget, local_players[0], slot)
```

### remove_widget

- C++ 签名：`void RemoveWidget(UWidget* Widget)`
- Python：`remove_widget(widget) -> None`
- 说明：从视口移除指定 Widget。
- 示例：

```python
api.remove_widget(my_widget)
```

## 槽位操作

### set_widget_slot

- C++ 签名：`void SetWidgetSlot(UWidget* Widget, FGameViewportWidgetSlot Slot)`
- Python：`set_widget_slot(widget, slot) -> None`
- 说明：更新指定 Widget 的槽位参数。
- 示例：

```python
slot = api.get_widget_slot(my_widget)
slot.offsets = unreal.Margin(100.0, 100.0, -100.0, -100.0)
api.set_widget_slot(my_widget, slot)
```

### set_widget_slot_position（静态）

- C++ 签名：`FGameViewportWidgetSlot SetWidgetSlotPosition(FGameViewportWidgetSlot Slot, const UWidget* Widget, FVector2D Position, bool bRemoveDPIScale)`
- Python：`set_widget_slot_position(slot, widget, position, b_remove_dpi_scale) -> GameViewportWidgetSlot`
- 说明：返回更新了位置的新槽位（静态方法，不修改原 slot）。
- 示例：

```python
slot = unreal.GameViewportWidgetSlot(
    anchors=unreal.Anchors(0.5, 0.5, 0.5, 0.5),
    offsets=unreal.Margin(0.0, 0.0, 0.0, 0.0),
)
new_slot = unreal.GameViewportSubsystem.set_widget_slot_position(
    slot, my_widget, unreal.Vector2D(50.0, 50.0), False
)
api.set_widget_slot(my_widget, new_slot)
```

### set_widget_slot_desired_size（静态）

- C++ 签名：`FGameViewportWidgetSlot SetWidgetSlotDesiredSize(FGameViewportWidgetSlot Slot, FVector2D Size)`
- Python：`set_widget_slot_desired_size(slot, size) -> GameViewportWidgetSlot`
- 说明：返回更新了期望尺寸的新槽位（静态方法）。
- 示例：

```python
new_slot = unreal.GameViewportSubsystem.set_widget_slot_desired_size(slot, unreal.Vector2D(400.0, 300.0))
api.set_widget_slot(my_widget, new_slot)
```

## 完整示例：添加并调整 Widget 位置

```python
import unreal

def main():
    api = unreal.get_engine_subsystem(unreal.GameViewportSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "GameViewportSubsystem 不可用"})
        return

    widget = unreal.load_object(None, "/Game/UI/WBP_HUD")
    if widget is None:
        print({"status": "BLOCKED_INPUT", "reason": "widget 蓝图加载失败"})
        return

    slot = unreal.GameViewportWidgetSlot(
        anchors=unreal.Anchors(0.0, 0.0, 1.0, 1.0),
        offsets=unreal.Margin(80.0, 80.0, -80.0, -80.0),
        z_order=10,
    )

    added = api.add_widget(widget, slot)
    if not added:
        print("widget 已存在")
        return

    # 移动到屏幕中心
    slot = api.get_widget_slot(widget)
    slot = unreal.GameViewportSubsystem.set_widget_slot_position(
        slot, widget, unreal.Vector2D(50.0, 50.0), False
    )
    api.set_widget_slot(widget, slot)

    print({"status": "OK", "widget_added": added})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（widget、`ULocalPlayer`、槽位参数），或 widget 蓝图加载失败。
- `BLOCKED_TOOLING`：子系统不可用；需要 PIE/运行时视口上下文才能体现效果；纯编辑器无活动视口时按此处理。
- 本 skill 只提供 API 调用，不拥有 UMG 资产；Widget 蓝图的创建、编辑与资产所有权归属 `ue-ui-engineer`，本 skill 不越过该边界。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。
