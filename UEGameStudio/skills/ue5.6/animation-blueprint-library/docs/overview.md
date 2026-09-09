# UAnimationBlueprintLibrary API 参考（UE 5.6）

本页列出 `UAnimationBlueprintLibrary` 的完整 Python 方法映射表，按功能分组。

## 骨骼变换（Bone Transform）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_bone_transform(anim_instance, bone_name, space)` | `FTransform GetBoneTransform(...)` | `Transform` |
| `set_bone_transform(anim_instance, bone_name, space, transform, b_replace)` | `void SetBoneTransform(...)` | `None` |
| `get_relative_bone_transform(anim_instance, bone_name, space)` | `FTransform GetRelativeBoneTransform(...)` | `Transform` |
| `get_bone_space_transform(anim_instance, bone_name, space)` | `FTransform GetBoneSpaceTransform(...)` | `Transform` |
| `get_bone_local_space_transform(anim_instance, bone_name)` | `FTransform GetBoneLocalSpaceTransform(...)` | `Transform` |
| `set_bone_local_space_transform(anim_instance, bone_name, transform, b_replace)` | `void SetBoneLocalSpaceTransform(...)` | `None` |
| `get_bone_rotation(anim_instance, bone_name, space)` | `FQuat GetBoneRotation(...)` | `Quat` |
| `set_bone_rotation(anim_instance, bone_name, space, rotation, b_replace)` | `void SetBoneRotation(...)` | `None` |
| `get_bone_location(anim_instance, bone_name, space)` | `FVector GetBoneLocation(...)` | `Vector` |
| `set_bone_location(anim_instance, bone_name, space, location, b_replace)` | `void SetBoneLocation(...)` | `None` |
| `get_bone_scale(anim_instance, bone_name, space)` | `FVector GetBoneScale(...)` | `Vector` |
| `set_bone_scale(anim_instance, bone_name, space, scale, b_replace)` | `void SetBoneScale(...)` | `None` |
| `to_local_space(anim_instance, transform, bone_name)` | `FTransform ToLocalSpace(...)` | `Transform` |
| `to_world_space(anim_instance, transform, bone_name)` | `FTransform ToWorldSpace(...)` | `Transform` |

## 动画混合与评估（Animation Blend & Evaluate）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `blend_two_anim_instances(anim1, anim2, alpha, delta_time)` | `FBlendSampleData BlendTwoAnimInstances(...)` | `BlendSampleData` |
| `add_anim_instance(anim_instance, delta_time)` | `void AddAnimInstance(...)` | `None` |
| `evaluate_animation_preserve_root(anim_instance, delta_time, b_preserve_root)` | `void EvaluateAnimationPreserveRoot(...)` | `None` |
| `start_asset_transition(anim_instance, asset, duration, start_position, b_looping, b_play_backwards)` | `void StartAssetTransition(...)` | `None` |
| `stop_asset_transition(anim_instance)` | `void StopAssetTransition(...)` | `None` |
| `get_transition_current_position(anim_instance)` | `float GetTransitionCurrentPosition(...)` | `float` |
| `set_transition_position(anim_instance, position)` | `void SetTransitionPosition(...)` | `None` |
| `get_transition_duration(anim_instance)` | `float GetTransitionDuration(...)` | `float` |

## 物理模拟（Physics Simulation）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_bone_physics_transform(anim_instance, bone_name, space)` | `FTransform GetBonePhysicsTransform(...)` | `Transform` |
| `set_bone_physics_transform(anim_instance, bone_name, space, transform, b_replace)` | `void SetBonePhysicsTransform(...)` | `None` |
| `get_bone_linear_velocity(anim_instance, bone_name)` | `FVector GetBoneLinearVelocity(...)` | `Vector` |
| `get_bone_angular_velocity(anim_instance, bone_name)` | `FVector GetBoneAngularVelocity(...)` | `Vector` |
| `is_bone_rigid(anim_instance, bone_name)` | `bool IsBoneRigid(...)` | `bool` |
| `set_bone_rigid(anim_instance, bone_name, b_rigid)` | `void SetBoneRigid(...)` | `None` |

## 动画实例控制（Anim Instance Control）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `has_curve(anim_instance, curve_name)` | `bool HasCurve(...)` | `bool` |
| `get_curve_value(anim_instance, curve_name, default_value)` | `float GetCurveValue(...)` | `float` |
| `set_curve_value(anim_instance, curve_name, value, b_force)` | `void SetCurveValue(...)` | `None` |
| `get_curve_names(anim_instance)` | `TArray<FName> GetCurveNames(...)` | `Array[Name]` |
| `getAnimatingBoneTransform(anim_instance, bone_name, space)` | `FTransform GetAnimatingBoneTransform(...)` | `Transform` |
| `get_current_anim_scale(anim_instance)` | `float GetCurrentAnimScale(...)` | `float` |
| `get_current_asset_play_time(anim_instance)` | `float GetCurrentAssetPlayTime(...)` | `float` |
| `get_current_asset_duration(anim_instance)` | `float GetCurrentAssetDuration(...)` | `float` |
| `get_anim_current_group_name(anim_instance)` | `FString GetAnimCurrentGroupName(...)` | `str` |
| `get_anim_current_name(anim_instance)` | `FString GetAnimCurrentName(...)` | `str` |

## 状态机（State Machine）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_state_machine_current_state_name(anim_instance, state_machine_name)` | `FString GetStateMachineCurrentStateName(...)` | `str` |
| `get_state_machine_current_state_duration(anim_instance, state_machine_name)` | `float GetStateMachineCurrentStateDuration(...)` | `float` |
| `get_state_machine_current_state_elapsed_time(anim_instance, state_machine_name)` | `float GetStateMachineCurrentStateElapsedTime(...)` | `float` |

## 其他（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_mesh_rotation_at_time(anim_instance, bone_name, time)` | `FQuat GetMeshRotationAtTime(...)` | `Quat` |
| `get_mesh_location_at_time(anim_instance, bone_name, time)` | `FVector GetMeshLocationAtTime(...)` | `Vector` |
| `get_mesh_scale_at_time(anim_instance, bone_name, time)` | `FVector GetMeshScaleAtTime(...)` | `Vector` |
| `create_transform(translation, rotation, scale)` | `FTransform CreateTransform(...)` | `Transform` |
| `inverse_transform(anim_instance, transform, space, bone_name)` | `FTransform InverseTransform(...)` | `Transform` |
| `forward_vector(anim_instance, transform, space, bone_name)` | `FVector ForwardVector(...)` | `Vector` |
| `up_vector(anim_instance, transform, space, bone_name)` | `FVector UpVector(...)` | `Vector` |
| `right_vector(anim_instance, transform, space, bone_name)` | `FVector RightVector(...)` | `Vector` |
