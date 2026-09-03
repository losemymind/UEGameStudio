# KismetAnimationLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/AnimGraphRuntime/Public/KismetAnimationLibrary.h` 整理 `UKismetAnimationLibrary`（继承 `UBlueprintFunctionLibrary`）中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的 static 成员。Python 类名去掉 `U` 前缀：`unreal.KismetAnimationLibrary`。方法名优先取函数 `meta` 的脚本化名称（`ScriptName=`/`ScriptMethod=`）转 snake_case，无脚本化名称时按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 通用约定

```python
import unreal

api = unreal.KismetAnimationLibrary
```

### Out / ByRef 返回约定

| 组合 | Python 返回 |
| --- | --- |
| `void` + 单个 Out/ByRef | 直接返回该 Out 参数的值 |
| `void` + 多个 Out/ByRef | 按声明顺序返回元组 `(out1, out2, ...)` |
| 有返回值 + Out/ByRef | 返回 `(return_value, out1, out2, ...)`，返回值在首位 |
| 无 Out 且无返回值 | `None` |
| `UPARAM(ref)` 修改型参数 | 对象被就地修改，按上述规则返回 |

### 类型映射

| C++ | Python |
| --- | --- |
| `bool` | `bool` |
| `int32` | `int` |
| `float` | `float` |
| `FName` | 接受 `str` / `unreal.Name` |
| `FString` | `str` |
| `FVector` / `FRotator` / `FTransform` | `unreal.Vector` / `unreal.Rotator` / `unreal.Transform` |
| `FPositionHistory` | `unreal.PositionHistory`（ref 修改型） |
| `FRuntimeFloatCurve` | `unreal.RuntimeFloatCurve` |
| `USkeletalMeshComponent*` | `unreal.SkeletalMeshComponent` |
| 枚举 | `unreal.<枚举名>`，多数接受名称字符串 |

## IK

### two_bone_ik

- C++ 签名：`void K2_TwoBoneIK(const FVector& RootPos, const FVector& JointPos, const FVector& EndPos, const FVector& JointTarget, const FVector& Effector, FVector& OutJointPos, FVector& OutEndPos, bool bAllowStretching, float StartStretchRatio, float MaxStretchScale)`（`ScriptName="TwoBoneIK"`）
- Python：`two_bone_ik(root_pos, joint_pos, end_pos, joint_target, effector, b_allow_stretching=False, start_stretch_ratio=1.0, max_stretch_scale=1.2) -> (Vector, Vector)`
- 说明：对两骨链（Root-Joint-End）求解两骨 IK；返回 `(OutJointPos, OutEndPos)` 元组。允许拉伸时按 `StartStretchRatio` 起拉伸、`MaxStretchScale` 限幅。
- 示例：

```python
joint_pos, end_pos = api.two_bone_ik(
    unreal.Vector(0.0, 0.0, 0.0),
    unreal.Vector(50.0, 0.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
    unreal.Vector(80.0, 30.0, 0.0),
    unreal.Vector(100.0, 0.0, 0.0),
    b_allow_stretching=False,
    start_stretch_ratio=1.0,
    max_stretch_scale=1.2,
)
```

## 朝向

### look_at

- C++ 签名：`FTransform K2_LookAt(const FTransform& CurrentTransform, const FVector& TargetPosition, FVector LookAtVector, bool bUseUpVector, FVector UpVector, float ClampConeInDegree)`（`ScriptName="LookAt"`）
- Python：`look_at(current_transform, target_position, look_at_vector, b_use_up_vector=False, up_vector=unreal.Vector(0,0,1), clamp_cone_in_degree=0.0) -> Transform`
- 说明：计算使本地轴指向目标位置的变换；`b_use_up_vector=True` 时启用上向量扭转；`clamp_cone_in_degree` 限制旋转锥角。
- 示例：

```python
t = api.look_at(
    unreal.Transform(location=unreal.Vector(0.0, 0.0, 0.0)),
    unreal.Vector(300.0, 0.0, 50.0),
    unreal.Vector(1.0, 0.0, 0.0),
    b_use_up_vector=True,
    up_vector=unreal.Vector(0.0, 0.0, 1.0),
    clamp_cone_in_degree=90.0,
)
```

## 距离

### distance_between_sockets

- C++ 签名：`float K2_DistanceBetweenTwoSocketsAndMapRange(const USkeletalMeshComponent* Component, const FName SocketOrBoneNameA, ERelativeTransformSpace SocketSpaceA, const FName SocketOrBoneNameB, ERelativeTransformSpace SocketSpaceB, bool bRemapRange, float InRangeMin, float InRangeMax, float OutRangeMin, float OutRangeMax)`
- Python：`distance_between_sockets(component, socket_or_bone_name_a, socket_space_a, socket_or_bone_name_b, socket_space_b, b_remap_range=False, in_range_min=0.0, in_range_max=0.0, out_range_min=0.0, out_range_max=1.0) -> float`
- 说明：计算两骨骼/插槽间的距离，可选将输入距离范围重映射到输出范围；插槽空间传 `unreal.RelativeTransformSpace`（如 `RTS_WORLD`）。范围参数默认值按 BP 面板常见默认（0/0/0/1），精确默认需实测确认。
- 示例：

```python
dist = api.distance_between_sockets(
    skeleton_component,
    "hand_r", unreal.RelativeTransformSpace.RTS_WORLD,
    "hand_l", unreal.RelativeTransformSpace.RTS_WORLD,
    b_remap_range=True,
    in_range_min=0.0, in_range_max=200.0,
    out_range_min=0.0, out_range_max=1.0,
)
```

## 方向

### direction_between_sockets

- C++ 签名：`FVector K2_DirectionBetweenSockets(const USkeletalMeshComponent* Component, const FName SocketOrBoneNameFrom, const FName SocketOrBoneNameTo)`
- Python：`direction_between_sockets(component, socket_or_bone_name_from, socket_or_bone_name_to) -> Vector`
- 说明：返回从第一个骨骼/插槽指向第二个的单位向量（骨骼空间）。
- 示例：

```python
d = api.direction_between_sockets(skeleton_component, "hand_r", "hand_l")
```

## 噪声

### make_vector_from_perlin_noise

- C++ 签名：`FVector K2_MakePerlinNoiseVectorAndRemap(float X, float Y, float Z, float RangeOutMinX, float RangeOutMaxX, float RangeOutMinY, float RangeOutMaxY, float RangeOutMinZ, float RangeOutMaxZ)`
- Python：`make_vector_from_perlin_noise(x, y, z, range_out_min_x=-1.0, range_out_max_x=1.0, range_out_min_y=-1.0, range_out_max_y=1.0, range_out_min_z=-1.0, range_out_max_z=1.0) -> Vector`
- 说明：对 `(X, Y, Z)` 生成 Perlin 噪声向量并逐分量重映射。
- 示例：

```python
n = api.make_vector_from_perlin_noise(1.0, 2.0, 3.0)
```

### make_float_from_perlin_noise

- C++ 签名：`float K2_MakePerlinNoiseAndRemap(float Value, float RangeOutMin, float RangeOutMax)`
- Python：`make_float_from_perlin_noise(value, range_out_min=-1.0, range_out_max=1.0) -> float`
- 说明：对单个值生成 Perlin 噪声标量并重映射。
- 示例：

```python
n = api.make_float_from_perlin_noise(1.5, -1.0, 1.0)
```

## 速度

### calculate_velocity_from_position_history

- C++ 签名：`float K2_CalculateVelocityFromPositionHistory(float DeltaSeconds, FVector Position, UPARAM(ref) FPositionHistory& History, int32 NumberOfSamples, float VelocityMin, float VelocityMax)`
- Python：`calculate_velocity_from_position_history(delta_seconds, position, history, number_of_samples=16, velocity_min=0.0, velocity_max=128.0) -> float`
- 说明：由跨帧位置历史计算速度；`history` 为 `FPositionHistory` ref 修改型参数，由调用方持有并就地更新；`velocity_min/max` 均设 0 时关闭归一化。
- 示例：

```python
history = unreal.PositionHistory()
for pos in [unreal.Vector(0,0,0), unreal.Vector(10,0,0), unreal.Vector(20,0,0)]:
    speed = api.calculate_velocity_from_position_history(
        0.033, pos, history, number_of_samples=16,
        velocity_min=0.0, velocity_max=128.0,
    )
    print("speed:", speed)
```

### calculate_velocity_from_sockets

- C++ 签名：`float K2_CalculateVelocityFromSockets(float DeltaSeconds, USkeletalMeshComponent* Component, const FName SocketOrBoneName, const FName ReferenceSocketOrBone, ERelativeTransformSpace SocketSpace, FVector OffsetInBoneSpace, UPARAM(ref) FPositionHistory& History, int32 NumberOfSamples, float VelocityMin, float VelocityMax, EEasingFuncType EasingType, const FRuntimeFloatCurve& CustomCurve)`
- Python：`calculate_velocity_from_sockets(delta_seconds, component, socket_or_bone_name, reference_socket_or_bone, socket_space, offset_in_bone_space, history, number_of_samples=16, velocity_min=0.0, velocity_max=128.0, easing_type=..., custom_curve=...) -> float`
- 说明：跟踪骨骼/插槽偏移位置（可选以另一骨骼/插槽为参考系）的速度；`history` 为 ref 修改型参数；`EasingType` 传 `unreal.EEasingFuncType`（含 `EF_LINEAR` 等），`EF_CUSTOM_CURVE` 时用 `custom_curve`。精确枚举暴露名需实测确认。
- 示例：

```python
history = unreal.PositionHistory()
speed = api.calculate_velocity_from_sockets(
    0.033, skeleton_component,
    "root", None,
    unreal.RelativeTransformSpace.RTS_WORLD,
    unreal.Vector(0.0, 0.0, 100.0),
    history,
    number_of_samples=16,
    velocity_min=0.0, velocity_max=128.0,
    easing_type=unreal.EEasingFuncType.EF_LINEAR,
)
```

## 剖析

### k2_start_profiling_timer

- C++ 签名：`void K2_StartProfilingTimer()`
- Python：`k2_start_profiling_timer() -> None`
- 说明：开始测量剖析区间耗时。
- 示例：

```python
api.k2_start_profiling_timer()
```

### k2_end_profiling_timer

- C++ 签名：`float K2_EndProfilingTimer(bool bLog = true, const FString& LogPrefix = "")`
- Python：`k2_end_profiling_timer(b_log=True, log_prefix="") -> float`
- 说明：结束剖析区间，返回耗时（毫秒）；`b_log=True` 时写入 OutputLog。
- 示例：

```python
api.k2_start_profiling_timer()
# ...动画计算...
ms = api.k2_end_profiling_timer(b_log=True, log_prefix="[anim] ")
```

## 方向

### calculate_direction

- C++ 签名：`float CalculateDirection(const FVector& Velocity, const FRotator& BaseRotation)`
- Python：`calculate_direction(velocity, base_rotation) -> float`
- 说明：返回速度方向与基准旋转前向的夹角，范围 [-180, 180]，用于驱动方向性混合空间。
- 示例：

```python
angle = api.calculate_direction(
    unreal.Vector(120.0, 0.0, 0.0),
    unreal.Rotator(0.0, 0.0, 0.0),
)
```

## 完整示例：骨骼速度追踪与剖析

```python
import unreal

def main():
    api = unreal.KismetAnimationLibrary
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

    skeleton_component = None
    # 从选中 Actor 或已命名组件取得骨骼网格组件，缺省则阻塞
    if skeleton_component is None:
        print({"status": "BLOCKED_INPUT", "reason": "缺少 USkeletalMeshComponent"})
        return

    history = unreal.PositionHistory()
    api.k2_start_profiling_timer()

    for i in range(100):
        speed = api.calculate_velocity_from_position_history(
            0.033,
            unreal.Vector(float(i) * 2.0, 0.0, 0.0),
            history,
            number_of_samples=16,
            velocity_min=0.0, velocity_max=128.0,
        )
        dir_vec = api.direction_between_sockets(skeleton_component, "spine_01", "head")

    ms = api.k2_end_profiling_timer(b_log=True, log_prefix="[velocity] ")
    print({"status": "OK", "speed": speed, "dir": dir_vec, "measure_ms": ms})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺 `USkeletalMeshComponent`、骨骼/插槽名、`FPositionHistory` 或必要数值输入；插槽名不存在按同规则返回并补全。
- `BLOCKED_TOOLING`：无可用 UE 5.6 编辑器/运行时引擎上下文，无法执行引擎反射调用。
- 本库为纯计算工具库，不修改任何资产；动画效果设计、动画蓝图与混合空间职责归 `character-animation-engineer`，本文件只提供 Python 调用 API。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；标称方法与精确 Python 暴露名需实测确认（`dir(unreal.KismetAnimationLibrary)` / 反射核对）。