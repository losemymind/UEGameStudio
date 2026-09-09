---
name: physics-constraint-statics
description: UPhysicsConstraintStatics（UE 5.6）物理约束静态工具库 - 约束实例创建/访问、约束break/损伤/断裂；在 Agent 需要通过 unreal Python 对物理约束系统做查询与控制时使用
tags: [ue5.6, physics, constraint, python, statics]
---

# PhysicsConstraintStatics - 物理约束工具库（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UPhysicsConstraintStatics`（`UObject` 派生，**静态类**）通过 Python 可调用的类方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Physics Engine/PhysicsConstraintStatics.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UPhysicsConstraintStatics` 在 Python 中以类方法形式暴露在 `unreal.PhysicsConstraintStatics` 上：

```python
import unreal

# 示例：获取约束实例
actor = unreal.load_asset("/Game/Physics/Chain_Actor")
unreal.PhysicsConstraintStatics.get_constraint_instance(actor, 0)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.PhysicsConstraintStatics)` 核对）。
- 大部分方法操作 `UPhysicsConstraintComponent` 或 `FConstraintInstance`；需要物理激活的 Actor 或约束组件作为上下文。
- 带 `WITH_EDITOR` 限定的导入/导出方法仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **实例访问** | | | |
| 实例 | `get_constraint_instance(actor, constraint_index)` | `FConstraintInstance GetConstraintInstance(const AActor*, int32)` | `ConstraintInstance` |
| 实例 | `get_constraint_instance_from_component(constraint_component)` | `FConstraintInstance GetConstraintInstanceFromComponent(const UPhysicsConstraintComponent*)` | `ConstraintInstance` |
| 实例 | `set_constraint_instance(actor, constraint_index, constraint_instance)` | `void SetConstraintInstance(const AActor*, int32, const FConstraintInstance&)` | `None` |
| 实例 | `set_constraint_instance_from_component(constraint_component, constraint_instance)` | `void SetConstraintInstanceFromComponent(const UPhysicsConstraintComponent*, const FConstraintInstance&)` | `None` |
| **约束开关** | | | |
| 开关 | `is_constraint_enabled(actor, constraint_index)` | `bool IsConstraintEnabled(const AActor*, int32)` | `bool` |
| 开关 | `enable_constraint(actor, constraint_index)` | `void EnableConstraint(const AActor*, int32)` | `None` |
| 开关 | `disable_constraint(actor, constraint_index)` | `void DisableConstraint(const AActor*, int32)` | `None` |
| **BREAK相关** | | | |
| BREAK | `get_break_force(actor, constraint_index)` | ` FVector GetBreakForce(const AActor*, int32)` | `Vector` |
| BREAK | `get_break_torque(actor, constraint_index)` | `FVector GetBreakTorque(const AActor*, int32)` | `Vector` |
| BREAK | `set_break_force(actor, constraint_index, break_force)` | `void SetBreakForce(const AActor*, int32, const FVector&)` | `None` |
| BREAK | `set_break_torque(actor, constraint_index, break_torque)` | `void SetBreakTorque(const AActor*, int32, const FVector&)` | `None` |
| BREAK | `set_linear_breakable(actor, constraint_index, b_linear_breakable)` | `void SetLinearBreakable(const AActor*, int32, bool)` | `None` |
| BREAK | `set_angular_breakable(actor, constraint_index, b_angular_breakable)` | `void SetAngularBreakable(const AActor*, int32, bool)` | `None` |
| **断裂（Fracture）** | | | |
| 断裂 | `get_linear_strength(actor, constraint_index)` | `float GetLinearStrength(const AActor*, int32)` | `float` |
| 断裂 | `get_angular_strength(actor, constraint_index)` | `float GetAngularStrength(const AActor*, int32)` | `float` |
| 断裂 | `set_linear_strength(actor, constraint_index, strength)` | `void SetLinearStrength(const AActor*, int32, float)` | `None` |
| 断裂 | `set_angular_strength(actor, constraint_index, strength)` | `void SetAngularStrength(const AActor*, int32, float)` | `None` |
| **碰撞与接触** | | | |
| 碰撞 | `is_collision_enabled(actor, constraint_index)` | `bool IsCollisionEnabled(const AActor*, int32)` | `bool` |
| 碰撞 | `enable_collision(actor, constraint_index, b_collision_enabled)` | `void EnableCollision(const AActor*, int32, bool)` | `None` |
| 接触 | `contact_notify_threshold(actor, constraint_index)` | `float ContactNotifyThreshold(const AActor*, int32)` | `float` |
| 接触 | `set_contact_notify_threshold(actor, constraint_index, threshold)` | `void SetContactNotifyThreshold(const AActor*, int32, float)` | `None` |
| **驱动与动力学** | | | |
| 驱动 | `get_drive_position(actor, constraint_index)` | `FTransform GetDrivePosition(const AActor*, int32)` | `Transform` |
| 驱动 | `get_drive_velocity(actor, constraint_index)` | `FVector GetDriveVelocity(const AActor*, int32)` | `Vector` |
| 驱动 | `set_drive_position(actor, constraint_index, position)` | `void SetDrivePosition(const AActor*, int32, const FTransform&)` | `None` |
| 驱动 | `set_drive_velocity(actor, constraint_index, velocity)` | `void SetDriveVelocity(const AActor*, int32, const FVector&)` | `None` |
| **其他** | | | |
| 轴向 | `get_constraint_axis(anim_instance, constraint_index)` | `FVector GetConstraintAxis(...)` | `Vector` |
| 轴向 | `get_constraint_projection_axis(actor, constraint_index)` | `FVector GetConstraintProjectionAxis(const AActor*, int32)` | `Vector` |
| 轴向 | `set_constraint_projection_axis(actor, constraint_index, axis)` | `void SetConstraintProjectionAxis(const AActor*, int32, const FVector&)` | `None` |
| 辅助 | `get_constraint_tag(actor, constraint_index)` | `FString GetConstraintTag(const AActor*, int32)` | `str` |
| 辅助 | `set_constraint_tag(actor, constraint_index, tag)` | `void SetConstraintTag(const AActor*, int32, const FString&)` | `None` |

## 快速示例

```python
import unreal

def control_constraint():
    actor = unreal.load_asset("/Game/Physics/Chain_Actor")
    if actor is None:
        print("BLOCKED_INPUT: actor not loadable")
        return

    api = unreal.PhysicsConstraintStatics
    
    # 启用约束
    api.enable_constraint(actor, 0)
    
    # 查询BREAK阈值
    break_force = api.get_break_force(actor, 0)
    break_torque = api.get_break_torque(actor, 0)
    print("break force:", break_force)
    print("break torque:", break_torque)
    
    # 修改BREAK阈值
    new_break_force = unreal.Vector(5000.0, 5000.0, 5000.0)
    api.set_break_force(actor, 0, new_break_force)
    
    # 禁用碰撞
    api.disable_constraint(actor, 0)

if __name__ == "__main__":
    control_constraint()
```

## 注意事项

- 大部分约束控制方法需要物理Actor与有效索引（`constraint_index`），无效索引返回空或假值。
- BREAK 相关方法修改的是 `FConstraintInstance` 的 `BreakForce` / `BreakTorque` 字段；当力或力矩超过阈值时约束断裂。
- `EnableConstraint` / `DisableConstraint` 仅切换约束是否生效，不影响物理模拟；`DisableConstraint` 后约束体仍存在但不施加力。
- `EnableCollision` 控制约束连接的两个物理体是否相互碰撞；`False` 时允许穿透，常用于避免过约束。
- 带 `WITH_EDITOR` 限定的方法仅编辑器 Python 可用；非编辑器环境调用会失败，应输出 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 缺 Actor 或约束索引等必要输入返回 `BLOCKED_INPUT`；无物理上下文返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
