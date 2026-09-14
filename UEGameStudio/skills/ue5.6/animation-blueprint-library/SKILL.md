---
name: animation-blueprint-library
description: UAnimationBlueprintLibrary（UE 5.6）动画Blueprint函数库 - 动画混合/评估、骨骼操作、物理模拟、动画实例控制；在 Agent 需要通过 unreal Python 对动画系统做通用操作时使用
risk: safe
category: development
tags: [ue5.6, animation, blueprint-library, python]
---

# AnimationBlueprintLibrary - 动画系统工具库（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 对动画系统做通用操作时使用本 skill（description 触发场景）。
- 本 skill 只在与 animation-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UAnimationBlueprintLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Animation/AnimationBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UBlueprintFunctionLibrary` 的 static 函数在 Python 中以类方法形式暴露在 `unreal.AnimationBlueprintLibrary` 上：

```python
import unreal

# 示例：获取骨骼局部空间变换
anim_instance = unreal.get_default_object(unreal.AnimInstance)
transform = unreal.AnimationBlueprintLibrary.get_bone_transform(
    anim_instance, unreal.Name("pelvis"), unreal.Space.BONE_SPACE_LOCAL
)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.AnimationBlueprintLibrary)` 核对）。
- 动画相关方法通常需要有效的 `AnimInstance` 实例（PIE/运行时或编辑器预览）。
- 带 `WITH_EDITOR` 限定的导入/导出方法仅编辑器 Python 可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **骨骼变换** | | | |
| 骨骼 | `get_bone_transform(anim_instance, bone_name, space)` | `FTransform GetBoneTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Transform` |
| 骨骼 | `set_bone_transform(anim_instance, bone_name, space, transform, b_replace)` | `void SetBoneTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type, const FTransform&, bool)` | `None` |
| 骨骼 | `get_relative_bone_transform(anim_instance, bone_name, space)` | `FTransform GetRelativeBoneTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Transform` |
| 骨骼 | `get_bone_space_transform(anim_instance, bone_name, space)` | `FTransform GetBoneSpaceTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Transform` |
| 骨骼 | `get_bone_local_space_transform(anim_instance, bone_name)` | `FTransform GetBoneLocalSpaceTransform(const UAnimInstance*, const FName&)` | `Transform` |
| 骨骼 | `set_bone_local_space_transform(anim_instance, bone_name, transform, b_replace)` | `void SetBoneLocalSpaceTransform(const UAnimInstance*, const FName&, const FTransform&, bool)` | `None` |
| 骨骼 | `get_bone_rotation(anim_instance, bone_name, space)` | `FQuat GetBoneRotation(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Quat` |
| 骨骼 | `set_bone_rotation(anim_instance, bone_name, space, rotation, b_replace)` | `void SetBoneRotation(const UAnimInstance*, const FName&, EBoneSpaces::Type, const FQuat&, bool)` | `None` |
| 骨骼 | `get_bone_location(anim_instance, bone_name, space)` | `FVector GetBoneLocation(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Vector` |
| 骨骼 | `set_bone_location(anim_instance, bone_name, space, location, b_replace)` | `void SetBoneLocation(const UAnimInstance*, const FName&, EBoneSpaces::Type, const FVector&, bool)` | `None` |
| 骨骼 | `get_bone_scale(anim_instance, bone_name, space)` | `FVector GetBoneScale(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Vector` |
| 骨骼 | `set_bone_scale(anim_instance, bone_name, space, scale, b_replace)` | `void SetBoneScale(const UAnimInstance*, const FName&, EBoneSpaces::Type, const FVector&, bool)` | `None` |
| 空间转换 | `to_local_space(anim_instance, transform, bone_name)` | `FTransform ToLocalSpace(const UAnimInstance*, const FTransform&, const FName&)` | `Transform` |
| 空间转换 | `to_world_space(anim_instance, transform, bone_name)` | `FTransform ToWorldSpace(const UAnimInstance*, const FTransform&, const FName&)` | `Transform` |
| **动画混合与评估** | | | |
| 混合 | `blend_two_anim_instances(anim1, anim2, alpha, delta_time)` | `FBlendSampleData BlendTwoAnimInstances(const UAnimInstance*, const UAnimInstance*, float, float)` | `BlendSampleData` |
| 混合 | `add_anim_instance(anim_instance, delta_time)` | `void AddAnimInstance(const UAnimInstance*, float)` | `None` |
| 评估 | `evaluate_animation_preserve_root(anim_instance, delta_time, b_preserve_root)` | `void EvaluateAnimationPreserveRoot(const UAnimInstance*, float, bool)` | `None` |
| 过渡 | `start_asset_transition(anim_instance, asset, duration, start_position, b_looping, b_play_backwards)` | `void StartAssetTransition(const UAnimInstance*, UAnimSequenceBase*, float, float, bool, bool)` | `None` |
| 过渡 | `stop_asset_transition(anim_instance)` | `void StopAssetTransition(const UAnimInstance*)` | `None` |
| 过渡 | `get_transition_current_position(anim_instance)` | `float GetTransitionCurrentPosition(const UAnimInstance*)` | `float` |
| 过渡 | `set_transition_position(anim_instance, position)` | `void SetTransitionPosition(const UAnimInstance*, float)` | `None` |
| 过渡 | `get_transition_duration(anim_instance)` | `float GetTransitionDuration(const UAnimInstance*)` | `float` |
| **物理模拟** | | | |
| 物理骨骼 | `get_bone_physics_transform(anim_instance, bone_name, space)` | `FTransform GetBonePhysicsTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Transform` |
| 物理骨骼 | `set_bone_physics_transform(anim_instance, bone_name, space, transform, b_replace)` | `void SetBonePhysicsTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type, const FTransform&, bool)` | `None` |
| 物理骨骼 | `get_bone_linear_velocity(anim_instance, bone_name)` | `FVector GetBoneLinearVelocity(const UAnimInstance*, const FName&)` | `Vector` |
| 物理骨骼 | `get_bone_angular_velocity(anim_instance, bone_name)` | `FVector GetBoneAngularVelocity(const UAnimInstance*, const FName&)` | `Vector` |
| 物理骨骼 | `is_bone_rigid(anim_instance, bone_name)` | `bool IsBoneRigid(const UAnimInstance*, const FName&)` | `bool` |
| 物理骨骼 | `set_bone_rigid(anim_instance, bone_name, b_rigid)` | `void SetBoneRigid(const UAnimInstance*, const FName&, bool)` | `None` |
| **动画实例控制** | | | |
| 曲线 | `has_curve(anim_instance, curve_name)` | `bool HasCurve(const UAnimInstance*, const FName&)` | `bool` |
| 曲线 | `get_curve_value(anim_instance, curve_name, default_value)` | `float GetCurveValue(const UAnimInstance*, const FName&, float)` | `float` |
| 曲线 | `set_curve_value(anim_instance, curve_name, value, b_force)` | `void SetCurveValue(const UAnimInstance*, const FName&, float, bool)` | `None` |
| 曲线 | `get_curve_names(anim_instance)` | `TArray<FName> GetCurveNames(const UAnimInstance*)` | `Array[Name]` |
| 动画 | `getAnimatingBoneTransform(anim_instance, bone_name, space)` | `FTransform GetAnimatingBoneTransform(const UAnimInstance*, const FName&, EBoneSpaces::Type)` | `Transform` |
| 动画 | `get_current_anim_scale(anim_instance)` | `float GetCurrentAnimScale(const UAnimInstance*)` | `float` |
| 动画 | `get_current_asset_play_time(anim_instance)` | `float GetCurrentAssetPlayTime(const UAnimInstance*)` | `float` |
| 动画 | `get_current_asset_duration(anim_instance)` | `float GetCurrentAssetDuration(const UAnimInstance*)` | `float` |
| 动画 | `get_anim_current_group_name(anim_instance)` | `FString GetAnimCurrentGroupName(const UAnimInstance*)` | `str` |
| 动画 | `get_anim_current_name(anim_instance)` | `FString GetAnimCurrentName(const UAnimInstance*)` | `str` |
| **其他** | | | |
| 状态机 | `get_state_machine_current_state_name(anim_instance, state_machine_name)` | `FString GetStateMachineCurrentStateName(const UAnimInstance*, const FName&)` | `str` |
| 状态机 | `get_state_machine_current_state_duration(anim_instance, state_machine_name)` | `float GetStateMachineCurrentStateDuration(const UAnimInstance*, const FName&)` | `float` |
| 状态机 | `get_state_machine_current_state_elapsed_time(anim_instance, state_machine_name)` | `float GetStateMachineCurrentStateElapsedTime(const UAnimInstance*, const FName&)` | `float` |
| 通用 | `get_mesh_rotation_at_time(anim_instance, bone_name, time)` | `FQuat GetMeshRotationAtTime(const UAnimInstance*, const FName&, float)` | `Quat` |
| 通用 | `get_mesh_location_at_time(anim_instance, bone_name, time)` | `FVector GetMeshLocationAtTime(const UAnimInstance*, const FName&, float)` | `Vector` |
| 通用 | `get_mesh_scale_at_time(anim_instance, bone_name, time)` | `FVector GetMeshScaleAtTime(const UAnimInstance*, const FName&, float)` | `Vector` |
| 通用 | `create_transform(translation, rotation, scale)` | `FTransform CreateTransform(const FVector&, const FQuat&, const FVector&)` | `Transform` |
| 通用 | `inverse_transform(anim_instance, transform, space, bone_name)` | `FTransform InverseTransform(const UAnimInstance*, const FTransform&, EBoneSpaces::Type, const FName&)` | `Transform` |
| 通用 | `forward_vector(anim_instance, transform, space, bone_name)` | `FVector ForwardVector(const UAnimInstance*, const FTransform&, EBoneSpaces::Type, const FName&)` | `Vector` |
| 通用 | `up_vector(anim_instance, transform, space, bone_name)` | `FVector UpVector(const UAnimInstance*, const FTransform&, EBoneSpaces::Type, const FName&)` | `Vector` |
| 通用 | `right_vector(anim_instance, transform, space, bone_name)` | `FVector RightVector(const UAnimInstance*, const FTransform&, EBoneSpaces::Type, const FName&)` | `Vector` |

## 示例

```python
import unreal

def animate_bone():
    anim_instance = unreal.get_default_object(unreal.AnimInstance)
    if anim_instance is None:
        print({"status": "BLOCKED_TOOLING", "reason": "AnimInstance 不可用，需 PIE/运行时或编辑器预览"})
        return

    api = unreal.AnimationBlueprintLibrary
    
    # 获取骨骼局部空间变换
    transform = api.get_bone_transform(anim_instance, unreal.Name("pelvis"), unreal.Space.BONE_SPACE_LOCAL)
    print("pelvis transform:", transform)
    
    # 修改骨骼位置（局部空间）
    new_location = transform.translation + unreal.Vector(10.0, 0.0, 0.0)
    api.set_bone_location(anim_instance, unreal.Name("pelvis"), unreal.Space.BONE_SPACE_LOCAL, new_location, False)
    
    # 获取曲线值
    curve_value = api.get_curve_value(anim_instance, unreal.Name("Speed"), 0.0)
    print("speed curve:", curve_value)
    
    # 检查状态机当前状态
    state_name = api.get_state_machine_current_state_name(anim_instance, unreal.Name("BaseState"))
    print("current state:", state_name)

if __name__ == "__main__":
    animate_bone()
```

## 限制和注意事项

- 动画相关方法通常需要有效的 `AnimInstance` 实例（PIE/运行时或编辑器预览），编辑器非 animate 状态下调用会失败或返回无效值。
- `get_bone_*` / `set_bone_*` 系列方法的 `space` 参数指定空间类型：`BONE_SPACE_LOCAL`（局部空间）、`BONE_SPACE_WORLD`（世界空间）等。
- `set_*` 方法的 `b_replace` 参数决定是替换还是增量修改；编辑器环境下修改需调用 `unreal.EditorAnimLibrary` 持久化。
- `WITH_EDITOR` 限定的方法（如某些导入/导出）仅编辑器 Python 可用；非编辑器环境调用会失败，应输出 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 缺 `AnimInstance` 或骨骼名等必要输入返回 `BLOCKED_INPUT`；无编辑器/PIE 上下文返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
