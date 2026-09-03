---
name: kismet-animation-library
description: UKismetAnimationLibrary（UE 5.6，unreal.KismetAnimationLibrary）动画蓝图公共函数库 - 两骨 IK、LookAt、骨骼/插槽间距离与方向、Perlin 噪声向量与标量重映射、位置历史与插槽速度计算、剖析计时、朝向运动方向角度；在 Agent 需要通过 unreal Python 调用这些动画计算函数时使用
tags: [ue5.6, animation, blueprint, python, library]
---

# KismetAnimationLibrary - Anim Utilities（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetAnimationLibrary`（`UBlueprintFunctionLibrary` 派生）暴露给 Python 的动画公共函数。方法名与签名依据 `Engine/Source/Runtime/AnimGraphRuntime/Public/KismetAnimationLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.KismetAnimationLibrary` 上，直接以类名调用，无需实例：

```python
import unreal

joint_pos, end_pos = unreal.KismetAnimationLibrary.two_bone_ik(
    unreal.Vector(0.0, 0.0, 0.0),
    unreal.Vector(50.0, 0.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
    unreal.Vector(80.0, 30.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
)
```

- **命名约定**：方法名优先取函数 `meta` 的脚本化名称（`ScriptName=`/`ScriptMethod=`）转 snake_case（如 `K2_TwoBoneIK` 的 `ScriptName="TwoBoneIK"` → `two_bone_ik`、`K2_LookAt` → `look_at`）；无脚本化名称时按 C++ 函数名转 snake_case（如 `K2_StartProfilingTimer` → `k2_start_profiling_timer`、`CalculateDirection` → `calculate_direction`）。精确 Python 暴露名需实测确认。
- **类名**：取 C++ 类名去 `U` 前缀（本库 `unreal.KismetAnimationLibrary`），不采用类级 `ScriptName` 别名；实测时以 `dir(unreal)` / 反射结果为准。
- 依赖 `USkeletalMeshComponent` 的方法传入已持有并有效初始化（含骨骼网格）的组件实例；骨骼/插槽名传字符串。
- 坐标为 `unreal.Vector`，旋转为 `unreal.Rotator`，变换为 `unreal.Transform`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| IK | `two_bone_ik(root_pos, joint_pos, end_pos, joint_target, effector, b_allow_stretching=False, start_stretch_ratio=1.0, max_stretch_scale=1.2)` | `void K2_TwoBoneIK(const FVector&, const FVector&, const FVector&, const FVector&, const FVector&, FVector& OutJointPos, FVector& OutEndPos, bool, float, float)` | `(Vector, Vector)` |
| 朝向 | `look_at(current_transform, target_position, look_at_vector, b_use_up_vector=False, up_vector=unreal.Vector(0,0,1), clamp_cone_in_degree=0.0)` | `FTransform K2_LookAt(const FTransform&, const FVector&, FVector, bool, FVector, float)` | `Transform` |
| 距离 | `distance_between_sockets(component, socket_or_bone_name_a, socket_space_a, socket_or_bone_name_b, socket_space_b, b_remap_range=False, in_range_min=0.0, in_range_max=0.0, out_range_min=0.0, out_range_max=1.0)` | `float K2_DistanceBetweenTwoSocketsAndMapRange(const USkeletalMeshComponent*, const FName, ERelativeTransformSpace, const FName, ERelativeTransformSpace, bool, float, float, float, float)` | `float` |
| 方向 | `direction_between_sockets(component, socket_or_bone_name_from, socket_or_bone_name_to)` | `FVector K2_DirectionBetweenSockets(const USkeletalMeshComponent*, const FName, const FName)` | `Vector` |
| 噪声 | `make_vector_from_perlin_noise(x, y, z, range_out_min_x=-1.0, range_out_max_x=1.0, range_out_min_y=-1.0, range_out_max_y=1.0, range_out_min_z=-1.0, range_out_max_z=1.0)` | `FVector K2_MakePerlinNoiseVectorAndRemap(float, float, float, float, float, float, float, float, float, float)` | `Vector` |
| 噪声 | `make_float_from_perlin_noise(value, range_out_min=-1.0, range_out_max=1.0)` | `float K2_MakePerlinNoiseAndRemap(float Value, float RangeOutMin, float RangeOutMax)` | `float` |
| 速度 | `calculate_velocity_from_position_history(delta_seconds, position, history, number_of_samples=16, velocity_min=0.0, velocity_max=128.0)` | `float K2_CalculateVelocityFromPositionHistory(float, FVector, UPARAM(ref) FPositionHistory&, int32, float, float)` | `float` |
| 速度 | `calculate_velocity_from_sockets(delta_seconds, component, socket_or_bone_name, reference_socket_or_bone, socket_space, offset_in_bone_space, history, number_of_samples=16, velocity_min=0.0, velocity_max=128.0, easing_type=..., custom_curve=...)` | `float K2_CalculateVelocityFromSockets(float, USkeletalMeshComponent*, const FName, const FName, ERelativeTransformSpace, FVector, UPARAM(ref) FPositionHistory&, int32, float, float, EEasingFuncType, const FRuntimeFloatCurve&)` | `float` |
| 剖析 | `k2_start_profiling_timer()` | `void K2_StartProfilingTimer()` | `None` |
| 剖析 | `k2_end_profiling_timer(b_log=True, log_prefix="")` | `float K2_EndProfilingTimer(bool bLog, const FString& LogPrefix)` | `float` |
| 方向 | `calculate_direction(velocity, base_rotation)` | `float CalculateDirection(const FVector&, const FRotator&)` | `float`（[-180, 180]） |

## 快速示例

```python
import unreal

# 两骨 IK：void + 2 个 Out → 元组（OutJointPos, OutEndPos）
joint_pos, end_pos = unreal.KismetAnimationLibrary.two_bone_ik(
    unreal.Vector(0.0, 0.0, 0.0),
    unreal.Vector(50.0, 0.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
    unreal.Vector(80.0, 30.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
    b_allow_stretching=False,
    start_stretch_ratio=1.0,
    max_stretch_scale=1.2,
)

# LookAt：纯函数返回朝向变换
t = unreal.KismetAnimationLibrary.look_at(
    unreal.Transform(location=unreal.Vector(0.0, 0.0, 0.0)),
    unreal.Vector(300.0, 0.0, 50.0),
    unreal.Vector(1.0, 0.0, 0.0),
)

# 骨骼间方向向量
d = unreal.KismetAnimationLibrary.direction_between_sockets(
    skeleton_component, "hand_r", "hand_l")

# 朝向运动方向角度（驱动方向性混合空间）
angle = unreal.KismetAnimationLibrary.calculate_direction(
    unreal.Vector(120.0, 0.0, 0.0), unreal.Rotator(0.0, 0.0, 0.0))
print("move angle:", angle)
```

## 注意事项

- 全部为 static 函数，类方法调用，无实例化与状态持有（除 `FPositionHistory` 由调用方跨帧持有）。
- `calculate_velocity_from_position_history` 与 `calculate_velocity_from_sockets` 的 `history` 为 `UPARAM(ref)` 修改型结构体参数：原对象被就地更新，返回值仍为速度标量；未初始化样本数/区间会按 BP 面板默认（16 / 0 / 128）处理，精确参数暴露与默认值需实测确认。
- `distance_between_sockets` 的 `socket_space_a/b` 传 `unreal.RelativeTransformSpace` 枚举（如 `RTS_WORLD`）；插槽名不存在时返回默认值，先按 `BLOCKED_INPUT` 补齐输入。
- 动画职责归 `character-animation-engineer`（动画蓝图 / 骨骼动画 / 混合空间）；本 skill 只提供 Python 调用 API，不承担动画效果设计。
- 无编辑器/运行时引擎上下文时按 `BLOCKED_TOOLING` 处理；缺组件、骨骼/插槽名、必要数值输入时按 `BLOCKED_INPUT` 处理。本库为纯计算库，不修改资产。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；`dir(unreal.KismetAnimationLibrary)` 实测命名后再落脚本。

详细逐方法 API 与完整示例见 `docs/overview.md`。