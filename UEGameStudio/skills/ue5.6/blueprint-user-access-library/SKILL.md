---
name: blueprint-user-access-library
description: UBlueprintUserAccessLibrary（UE 5.6）用户访问控制函数库 - 运行时权限查询与用户类型识别；在 Agent 需要通过 unreal Python 识别运行时用户角色或检查访问权限时使用
tags: [ue5.6, user-access, blueprint, python, function-library]
---

# BlueprintUserAccessLibrary - User Access Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UBlueprintUserAccessLibrary` 暴露给 Python 的用户访问控制与角色识别功能。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintUserAccessLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.BlueprintUserAccessLibrary` 上，直接以类名调用，无需实例：

```python
import unreal

api = unreal.BlueprintUserAccessLibrary
user_type = api.get_user_type(unreal.LocalPlayer)
print("user type:", user_type)
```

- **命名约定**：Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无该 meta 的按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认（`dir(unreal.BlueprintUserAccessLibrary)`）。
- **用户类型枚举**：`unreal.EBlueprintUserAccessLibraryUserType`（`EBlueprintUserAccessLibraryUserType`）：`PLAYER`、`EDITOR`、`SCRIPT`。
- **线程安全**：部分方法标记 `BlueprintThreadSafe`；访问全局状态（如 `GEngine`）的方法建议在主游戏线程调用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 用户识别 | `get_user_type(local_player)` | `EBlueprintUserAccessLibraryUserType GetUserType(const ULocalPlayer*)` | `EBlueprintUserAccessLibraryUserType` |
| 用户识别 | `is_player(local_player)` | `bool IsPlayer(const ULocalPlayer*)` | `bool` |
| 用户识别 | `is_editor(local_player)` | `bool IsEditor(const ULocalPlayer*)` | `bool` |
| 用户识别 | `is_script(local_player)` | `bool IsScript(const ULocalPlayer*)` | `bool` |

## 快速示例

```python
import unreal

api = unreal.BlueprintUserAccessLibrary

local_players = unreal.get_engine_subsystem(unreal.LocalPlayerSubsystem).get_local_players()
for lp in local_players:
    user_type = api.get_user_type(lp)
    print({
        "player": lp.get_player_controller().get_player_name() if lp.get_player_controller() else None,
        "user_type": user_type.name,
        "is_player": api.is_player(lp),
        "is_editor": api.is_editor(lp),
        "is_script": api.is_script(lp),
    })
```

## 注意事项

- 全部为 static 函数，类方法调用，无实例化与状态持有。
- `local_player` 为 `unreal.LocalPlayer`；空/失效指针返回默认枚举值，建议先用 `unreal.get_engine_subsystem(unreal.LocalPlayerSubsystem).get_local_players()` 获取有效列表。
- `is_editor` 对编辑器内运行的 PIE/PIE 预览有效；纯运行时构建（Editor=False）下 `is_editor` 恒为 `False`。
- 无 `LocalPlayer` 或世界上下文不可用时返回 `BLOCKED_TOOLING`；缺少必要输入返回 `BLOCKED_INPUT`。
- 本库为纯查询功能，不修改运行时状态或配置，可用于权限审计与条件分支。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
