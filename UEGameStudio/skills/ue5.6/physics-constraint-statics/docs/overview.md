# UPhysicsConstraintStatics API 参考（UE 5.6）

本页列出 `UPhysicsConstraintStatics` 的完整 Python 方法映射表，按功能分组。

## 实例访问（Instance Access）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_constraint_instance(actor, constraint_index)` | `FConstraintInstance GetConstraintInstance(const AActor*, int32)` | `ConstraintInstance` |
| `get_constraint_instance_from_component(constraint_component)` | `FConstraintInstance GetConstraintInstanceFromComponent(const UPhysicsConstraintComponent*)` | `ConstraintInstance` |
| `set_constraint_instance(actor, constraint_index, constraint_instance)` | `void SetConstraintInstance(const AActor*, int32, const FConstraintInstance&)` | `None` |
| `set_constraint_instance_from_component(constraint_component, constraint_instance)` | `void SetConstraintInstanceFromComponent(const UPhysicsConstraintComponent*, const FConstraintInstance&)` | `None` |

## 约束开关（Constraint开关）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `is_constraint_enabled(actor, constraint_index)` | `bool IsConstraintEnabled(const AActor*, int32)` | `bool` |
| `enable_constraint(actor, constraint_index)` | `void EnableConstraint(const AActor*, int32)` | `None` |
| `disable_constraint(actor, constraint_index)` | `void DisableConstraint(const AActor*, int32)` | `None` |

## BREAK相关

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_break_force(actor, constraint_index)` | `FVector GetBreakForce(const AActor*, int32)` | `Vector` |
| `get_break_torque(actor, constraint_index)` | `FVector GetBreakTorque(const AActor*, int32)` | `Vector` |
| `set_break_force(actor, constraint_index, break_force)` | `void SetBreakForce(const AActor*, int32, const FVector&)` | `None` |
| `set_break_torque(actor, constraint_index, break_torque)` | `void SetBreakTorque(const AActor*, int32, const FVector&)` | `None` |
| `set_linear_breakable(actor, constraint_index, b_linear_breakable)` | `void SetLinearBreakable(const AActor*, int32, bool)` | `None` |
| `set_angular_breakable(actor, constraint_index, b_angular_breakable)` | `void SetAngularBreakable(const AActor*, int32, bool)` | `None` |

## 断裂（Fracture）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_linear_strength(actor, constraint_index)` | `float GetLinearStrength(const AActor*, int32)` | `float` |
| `get_angular_strength(actor, constraint_index)` | `float GetAngularStrength(const AActor*, int32)` | `float` |
| `set_linear_strength(actor, constraint_index, strength)` | `void SetLinearStrength(const AActor*, int32, float)` | `None` |
| `set_angular_strength(actor, constraint_index, strength)` | `void SetAngularStrength(const AActor*, int32, float)` | `None` |

## 碰撞与接触（Collision & Contact）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `is_collision_enabled(actor, constraint_index)` | `bool IsCollisionEnabled(const AActor*, int32)` | `bool` |
| `enable_collision(actor, constraint_index, b_collision_enabled)` | `void EnableCollision(const AActor*, int32, bool)` | `None` |
| `contact_notify_threshold(actor, constraint_index)` | `float ContactNotifyThreshold(const AActor*, int32)` | `float` |
| `set_contact_notify_threshold(actor, constraint_index, threshold)` | `void SetContactNotifyThreshold(const AActor*, int32, float)` | `None` |

## 驱动与动力学（Drive & Dynamics）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_drive_position(actor, constraint_index)` | `FTransform GetDrivePosition(const AActor*, int32)` | `Transform` |
| `get_drive_velocity(actor, constraint_index)` | `FVector GetDriveVelocity(const AActor*, int32)` | `Vector` |
| `set_drive_position(actor, constraint_index, position)` | `void SetDrivePosition(const AActor*, int32, const FTransform&)` | `None` |
| `set_drive_velocity(actor, constraint_index, velocity)` | `void SetDriveVelocity(const AActor*, int32, const FVector&)` | `None` |

## 其他（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_constraint_axis(actor, constraint_index)` | `FVector GetConstraintAxis(...)` | `Vector` |
| `get_constraint_projection_axis(actor, constraint_index)` | `FVector GetConstraintProjectionAxis(const AActor*, int32)` | `Vector` |
| `set_constraint_projection_axis(actor, constraint_index, axis)` | `void SetConstraintProjectionAxis(const AActor*, int32, const FVector&)` | `None` |
| `get_constraint_tag(actor, constraint_index)` | `FString GetConstraintTag(const AActor*, int32)` | `str` |
| `set_constraint_tag(actor, constraint_index, tag)` | `void SetConstraintTag(const AActor*, int32, const FString&)` | `None` |
