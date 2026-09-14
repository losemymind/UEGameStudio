---
name: game-viewport-subsystem
description: UGameViewportSubsystem（UE 5.6）UMG 视口 widget 管理 - 添加/移除/查询/定位视口 Widget（AddWidget / AddWidgetForPlayer / SetWidgetSlotPosition / SetWidgetSlotDesiredSize）；在 Agent 需要通过 unreal Python 向游戏视口添加或管理 UMG Widget 时使用
risk: safe
category: development
tags: [ue5.6, umg, viewport, widget, python, subsystem]
---

# GameViewportSubsystem - UMG 视口 Widget 管理（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 向游戏视口添加或管理 UMG Widget时使用本 skill（description 触发场景）。
- 本 skill 只在与 game-viewport-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UGameViewportSubsystem` 暴露给 Python 的 UMG 视口 Widget 管理方法。方法名与签名依据 `Engine/Source/Runtime/UMG/Public/Blueprint/GameViewportSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理。C++ 函数未声明 `ScriptMethod` meta，Python 方法名按 C++ 函数名转 snake_case；精确 Python 暴露名需实测确认。

## 入口说明

`UGameViewportSubsystem` 派生自 `UEngineSubsystem`（全局引擎子系统）。从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_engine_subsystem(unreal.GameViewportSubsystem)
```

- 返回 `None` 表示子系统不可用，按 `BLOCKED_TOOLING` 处理并停止。
- Widget 槽位使用 `unreal.GameViewportWidgetSlot`（`Anchors` / `Offsets` / `Alignment` / `ZOrder` / `b_auto_remove_on_world_removed`）。
- 坐标/尺寸使用 `unreal.Vector2D`，锚点使用 `unreal.Anchors`，边距使用 `unreal.Margin`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 查询 | `is_widget_added(widget)` | `bool IsWidgetAdded(const UWidget*) const` | `bool` |
| 添加 | `add_widget(widget, slot)` | `bool AddWidget(UWidget*, FGameViewportWidgetSlot)` | `bool` |
| 分屏添加 | `add_widget_for_player(widget, player, slot)` | `bool AddWidgetForPlayer(UWidget*, ULocalPlayer*, FGameViewportWidgetSlot)` | `bool` |
| 移除 | `remove_widget(widget)` | `void RemoveWidget(UWidget*)` | `None` |
| 查询槽位 | `get_widget_slot(widget)` | `FGameViewportWidgetSlot GetWidgetSlot(const UWidget*) const` | `GameViewportWidgetSlot` |
| 设置槽位 | `set_widget_slot(widget, slot)` | `void SetWidgetSlot(UWidget*, FGameViewportWidgetSlot)` | `None` |
| 定位 | `set_widget_slot_position(slot, widget, position, b_remove_dpi_scale)` | `FGameViewportWidgetSlot SetWidgetSlotPosition(FGameViewportWidgetSlot, const UWidget*, FVector2D, bool)`（静态） | `GameViewportWidgetSlot` |
| 设置尺寸 | `set_widget_slot_desired_size(slot, size)` | `FGameViewportWidgetSlot SetWidgetSlotDesiredSize(FGameViewportWidgetSlot, FVector2D)`（静态） | `GameViewportWidgetSlot` |

## 示例

```python
import unreal

api = unreal.get_engine_subsystem(unreal.GameViewportSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: GameViewportSubsystem 不可用")

# 全屏槽位（默认锚点铺满屏幕）
slot = unreal.GameViewportWidgetSlot(
    anchors=unreal.Anchors(0.0, 0.0, 1.0, 1.0),
    offsets=unreal.Margin(80.0, 80.0, -80.0, -80.0),
    z_order=10,
)

widget = unreal.load_object(None, "/Game/UI/WBP_HUD")  # 取已构建的 Widget 实例
added = api.add_widget(widget, slot)
if not added:
    print("widget not added")

if api.is_widget_added(widget):
    # 移动到屏幕 50% 位置
    slot = api.set_widget_slot_position(
        slot, widget, unreal.Vector2D(50.0, 50.0), False
    )
    api.set_widget_slot(widget, slot)
```

## 限制和注意事项

- 本 skill 只提供 API 调用，不拥有 UMG 资产；Widget 蓝图的创建、编辑与资产所有权归属 ue-ui-engineer，本 skill 不越过该边界。
- `add_widget` 的 widget 必须是已构造的 UMG Widget 实例；未构造或资产加载失败返回 `False`。
- `add_widget_for_player` 用于分屏场景，只将 Widget 显示在指定玩家对应的视口区域。
- `set_widget_slot_position` 的 `b_remove_dpi_scale`：已自行按逆 DPI 计算时传 `True`，否则 DPI 会自动反算。
- 需要 PIE/运行时视口上下文才能体现效果；纯编辑器无活动视口时按 `BLOCKED_TOOLING` 处理。
- 缺必要输入（widget、`ULocalPlayer`、槽位参数）时返回 `BLOCKED_INPUT`；子系统不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。