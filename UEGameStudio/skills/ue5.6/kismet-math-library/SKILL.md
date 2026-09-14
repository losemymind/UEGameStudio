---
name: kismet-math-library
description: UKismetMathLibrary（UE 5.6）数学与转换函数库 - 基础算术/三角/类型转换/向量·旋转器·四元数·矩阵·变换/确定性随机流/插值与平滑；在 Agent 需要通过 unreal Python 执行数值计算、类型/坐标转换、向量几何运算、随机采样或平滑插值时使用
risk: safe
category: development
tags: [ue5.6, kismet, math, python, blueprint-function-library]
---

# KismetMathLibrary - Math Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 执行数值计算、类型/坐标转换、向量几何运算、随机采样或平滑插值时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-math-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetMathLibrary`（`UBlueprintFunctionLibrary` 派生）暴露给 Python 的数学与转换静态函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetMathLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 737 个 static 成员整理；这是引擎最大的一支蓝图函数库。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.KismetMathLibrary` 上，直接以类名调用，无需实例：

```python
import unreal

squared = unreal.KismetMathLibrary.square(16.0)
normal = unreal.KismetMathLibrary.normal(unreal.Vector(3.0, 4.0, 0.0))
```

- **命名约定**：Python 方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case（如 `Add_VectorVector` 的 ScriptMethod 为 `Add` → `unreal.KismetMathLibrary.add(a, b)`；`Conv_VectorToRotator` 的 ScriptMethod 为 `Rotator` → `rotator(in_vec)`）；无 ScriptMethod 的成员按 C++ 函数名转 snake_case（如 `Add_IntInt` → `add_int_int`、`FClamp` → `f_clamp`）。运算符家族的 ScriptMethod 常见为 `Add/Subtract/Multiply/Divide/Dot/Cross/Length/Distance/Normal/Normalize/Lerp/InterpTo` 等。
- **精确 Python 暴露名需实测确认**：个别派生名会与内置名撞名（`sin`/`cos`/`exp`/`log`/`abs`/`round` 等），且引擎反射对 `GetPI`（→`get_p_i` 等派生）与 ScriptConstant（常量）有特殊规则；`dir(unreal.KismetMathLibrary)` 核对后再断言。
- static 方法返回 `void` 时 Python 返回 `None`；带 Out/ByRef 参数的按返回约定处理（单个 Out 直接返回该值；多个 Out 按声明顺序返回元组；有返回值 + Out 时返回值在首位）。
- 本函数库无编辑器独占依赖，编辑器与运行时 Python 均可调用；但个别 Geometry/Intersection 方法需要 `UWorld` 上下文对象，仅编辑器传参可用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 布尔 | `not_pre_bool(a)` | `bool Not_PreBool(bool A)` | `bool` |
| 布尔 | `boolean_and(a, b)` | `bool BooleanAND(bool A, bool B)` | `bool` |
| 字节 | `add_byte_byte(a, b=1)` | `uint8 Add_ByteByte(uint8 A, uint8 B)` | `int` |
| 整数 | `add_int_int(a, b=1)` | `int32 Add_IntInt(int32 A, int32 B)` | `int` |
| 整数 | `clamp(value, min, max)` | `int32 Clamp(int32 Value, int32 Min, int32 Max)` | `int` |
| 整数 | `in_range_int_int(value, min, max, inclusive_min=True, inclusive_max=True)` | `bool InRange_IntInt(int32, int32, int32, bool, bool)` | `bool` |
| 整数64 | `clamp_int64(value, min, max)` | `int64 ClampInt64(int64, int64, int64)` | `int` |
| 浮点 | `add_double_double(a, b=1.0)` | `double Add_DoubleDouble(double, double)` | `float` |
| 浮点 | `f_clamp(value, min, max)` | `double FClamp(double, double, double)` | `float` |
| 浮点 | `sqrt(a)` | `double Sqrt(double)` | `float` |
| 浮点 | `multiply_multiply_float_float(base, exp)` | `double MultiplyMultiply_FloatFloat(double, double)`（Power） | `float` |
| 浮点 | `f_mod(dividend, divisor)` | `int32 FMod(double, double, double& OutRemainder)` | `(int, float)` |
| 三角 | `sin(a)` / `cos(a)` / `tan(a)` | `double Sin/Cos/Tan(double)`（弧度） | `float` |
| 三角 | `deg_sin(a)` / `deg_cos(a)` / `deg_tan(a)` | `double DegSin/DegCos/DegTan(double)`（角度） | `float` |
| 三角 | `degrees_to_radians(a)` / `radians_to_degrees(a)` | `double DegreesToRadians/RadiansToDegrees(double)` | `float` |
| 转换 | `conv_int_to_double(in_int)` | `double Conv_IntToDouble(int32)` | `float` |
| 转换 | `conv_double_to_int64(in_double)` | `int64 Conv_DoubleToInt64(double)` | `int` |
| 转换 | `conv_int64_to_int(in_int)` | `int32 Conv_Int64ToInt(int64)` | `int` |
| 转换 | `conv_int_to_vector(in_int)` | `FVector Conv_IntToVector(int32)` | `Vector` |
| 转换 | `rotator(in_vector)` | `FRotator Conv_VectorToRotator(FVector)`（ScriptMethod） | `Rotator` |
| 转换 | `quaternion(in_vector)` | `FQuat Conv_VectorToQuaternion(FVector)`（ScriptMethod） | `Quat` |
| 转换 | `transform(in_rotator)` | `FTransform Conv_RotatorToTransform(const FRotator&)`（ScriptMethod） | `Transform` |
| 转换 | `to_vector(in_rotator)` | `FVector Conv_RotatorToVector(FRotator)`（ScriptMethod） | `Vector` |
| 转换 | `to_matrix(in_transform)` | `FMatrix Conv_TransformToMatrix(const FTransform&)`（ScriptMethod） | `Matrix` |
| 转换 | `convert1d_to2d(index1d, x_size)` / `convert2d_to1d(index2d, x_size)` | `FIntPoint Convert1DTo2D(int32,int32)` / `int32 Convert2DTo1D(...)` | `IntPoint` / `int` |
| 向量 | `make_vector(x, y, z)` | `FVector MakeVector(double, double, double)` | `Vector` |
| 向量 | `break_vector(vec)` | `void BreakVector(FVector, double&, double&, double&)` | `(float, float, float)` |
| 向量 | `add(a, b)` / `subtract(a, b)` / `multiply(a, b)` / `divide(a, b)` | `FVector Add/Subtract/Multiply/Divide_VectorVector(...)`（ScriptMethod） | `Vector` |
| 向量 | `dot(a, b)` / `cross(a, b)` | `double Dot_VectorVector(...)` / `FVector Cross_VectorVector(...)`（ScriptMethod） | `float` / `Vector` |
| 向量 | `length(a)` / `length_squared(a)` | `double VSize/VSizeSquared(FVector)`（ScriptMethod） | `float` |
| 向量 | `distance(v1, v2)` / `distance_squared(v1, v2)` | `double Vector_Distance/Vector_DistanceSquared(FVector, FVector)` | `float` |
| 向量 | `normal(a, tolerance=1.e-4)` | `FVector Normal(FVector, float)`（ScriptMethod） | `Vector` |
| 向量 | `rotate(a, rotator)` / `rotate_angle_axis(vect, angle_deg, axis)` | `FVector GreaterGreater_VectorRotator(...)` / `RotateAngleAxis(...)` | `Vector` |
| 向量 | `lerp_to(a, b, alpha)` | `FVector VLerp(FVector, FVector, float)`（ScriptMethod=LerpTo） | `Vector` |
| 向量 | `mirror_by_vector(direction, surface_normal)` | `FVector GetReflectionVector(...)`（ScriptMethod） | `Vector` |
| 向量2D | `make_vector2d(x, y)` / `break_vector2d(vec)` | `FVector2D MakeVector2D(...)` / `void BreakVector2D(...)` | `Vector2D` / `(float, float)` |
| 向量4 | `make_vector4(x, y, z, w)` / `break_vector4(vec)` | `FVector4 MakeVector4(...)` / `void BreakVector4(...)` | `Vector4` / `(float, float, float, float)` |
| 旋转器 | `make_rotator(roll, pitch, yaw)` | `FRotator MakeRotator(float Roll, float Pitch, float Yaw)` | `Rotator` |
| 旋转器 | `make_rot_from_x(axis)` / `make_rot_from_z(axis)` | `FRotator MakeRotFromX/Z(const FVector&)` | `Rotator` |
| 旋转器 | `find_look_at_rotation(start, target)` | `FRotator FindLookAtRotation(const FVector&, const FVector&)` | `Rotator` |
| 旋转器 | `combine(a, b)` | `FRotator ComposeRotators(FRotator, FRotator)`（ScriptMethod=Combine） | `Rotator` |
| 旋转器 | `delta(a, b)` | `FRotator NormalizedDeltaRotator(FRotator, FRotator)`（ScriptMethod=Delta） | `Rotator` |
| 旋转器 | `clamp_axis(angle)` / `normalize_axis(angle)` | `float ClampAxis/NormalizeAxis(float)` | `float` |
| 四元数 | `make_quat(x, y, z, w)` / `break_quat(q)` | `FQuat MakeQuat(...)` / `void BreakQuat(...)` | `Quat` / `(float,float,float,float)` |
| 四元数 | `multiply(a, b)` | `FQuat Multiply_QuatQuat(const FQuat&, const FQuat&)`（ScriptMethod） | `Quat` |
| 四元数 | `slerp_quat(a, b, alpha)` | `FQuat Quat_Slerp(const FQuat&, const FQuat&, double)`（ScriptMethod=SlerpQuat） | `Quat` |
| 四元数 | `rotate_vector(q, v)` | `FVector Quat_RotateVector(const FQuat&, const FVector&)` | `Vector` |
| 四元数 | `euler(q)` / `rotator(q)` | `FVector Quat_Euler(...)` / `FRotator Quat_Rotator(...)`（ScriptMethod） | `Vector` / `Rotator` |
| 矩阵 | `matrix_identity()` | `FMatrix Matrix_Identity()`（ScriptConstant=Identity） | `Matrix` |
| 矩阵 | `multiply(a, b)` | `FMatrix Multiply_MatrixMatrix(const FMatrix&, const FMatrix&)`（ScriptMethod） | `Matrix` |
| 矩阵 | `get_origin(m)` / `get_inverse(m)` / `get_determinant(m)` | `FVector Matrix_GetOrigin(...)` / `FMatrix Matrix_GetInverse(...)` / `float Matrix_GetDeterminant(...)` | `Vector` / `Matrix` / `float` |
| 矩阵 | `transform_position(m, v)` | `FVector4 Matrix_TransformPosition(const FMatrix&, FVector)` | `Vector4` |
| 变换 | `make_transform(location, rotation, scale)` | `FTransform MakeTransform(FVector, FRotator, FVector)` | `Transform` |
| 变换 | `break_transform(t)` | `void BreakTransform(...)` | `(Vector, Rotator, Vector)` |
| 变换 | `multiply(a, b)` | `FTransform ComposeTransforms(const FTransform&, const FTransform&)`（ScriptMethod） | `Transform` |
| 变换 | `inverse(t)` | `FTransform InvertTransform(const FTransform&)`（ScriptMethod=Inverse） | `Transform` |
| 变换 | `transform_location(t, location)` | `FVector TransformLocation(const FTransform&, FVector)` | `Vector` |
| 变换 | `make_relative(a, relative_to)` | `FTransform MakeRelativeTransform(...)`（ScriptMethod=MakeRelative） | `Transform` |
| 随机 | `random_integer(exclusive_max)` / `random_integer_in_range(min, max)` | `int32 RandomInteger(...)` / `RandomIntegerInRange(...)` | `int` |
| 随机 | `random_float()` / `random_float_in_range(min, max)` | `double RandomFloat()/RandomFloatInRange(...)` | `float` |
| 随机 | `random_bool()` / `random_bool_with_weight(weight)` | `bool RandomBool()/RandomBoolWithWeight(float)` | `bool` |
| 随机 | `random_unit_vector()` | `FVector RandomUnitVector()` | `Vector` |
| 随机 | `random_point_in_box_extents(center, half_size)` | `FVector RandomPointInBoundingBox(...)`（ScriptMethod） | `Vector` |
| 随机 | `make_random_stream(initial_seed)` | `FRandomStream MakeRandomStream(int32)` | `RandomStream` |
| 随机 | `random_int(stream, max)` / `random_float(stream)` / `random_bool(stream)` | `RandomIntegerFromStream/...（ScriptMethod，首参流）` | `int` / `float` / `bool` |
| 随机 | `set_seed(stream, new_seed)` / `reset_random_stream(stream)` | `void SetRandomStreamSeed/ResetRandomStream(...)` | `None` |
| 插值 | `f_interp_to(current, target, delta_time, interp_speed)` / `f_interp_to_constant(...)` | `double FInterpTo/FInterpTo_Constant(...)` | `float` |
| 插值 | `interp_to(current, target, delta_time, interp_speed)` | `FVector VInterpTo(...)`（ScriptMethod=InterpTo，泛用向量版） | `Vector` |
| 插值 | `float_spring_interp(...)` | `float FloatSpringInterp(float, float, FFloatSpringState&, ...)` | `float` |
| 平滑 | `weighted_moving_average_float(current, previous, weight)` | `float WeightedMovingAverage_Float(...)` | `float` |
| 平滑 | `dynamic_weighted_moving_average_float(...)` | `float DynamicWeightedMovingAverage_Float(...)` | `float` |
| 几何 | `is_point_in_box(point, box_origin, box_extent)` | `bool IsPointInBox(FVector, FVector, FVector)` | `bool` |
| 几何 | `get_box_volume(box)` / `get_box_size(box)` / `get_box_center(box)` | `double GetBoxVolume(const FBox&)` / `FVector GetBoxSize/GetBoxCenter(...)` | `float` / `Vector` |
| 相交 | `line_plane_intersection(line_start, line_end, plane, ...)` | `bool LinePlaneIntersection(..., float& T, FVector& Intersection)` | `(bool, float, Vector)` |
| 时间 | `now()` / `utc_now()` / `today()` | `FDateTime Now()/UtcNow()/Today()` | `DateTime` |
| 时间 | `make_datetime(year, month, day, ...)` / `break_datetime(dt)` | `FDateTime MakeDateTime(...)` / `void BreakDateTime(...)` | `DateTime` / `(int,int,int,int,int,int,int)` |
| 时间 | `to_unix_timestamp(dt)` / `from_unix_timestamp(ts)` | `int64 ToUnixTimestamp(...)` / `FDateTime FromUnixTimestamp(int64)` | `int` / `DateTime` |
| 时间 | `make_timespan(days, hours, minutes, seconds, milliseconds)` | `FTimespan MakeTimespan(...)` | `Timespan` |
| 时间 | `from_seconds(seconds)` / `get_total_seconds(ts)` | `FTimespan FromSeconds(double)` / `double GetTotalSeconds(FTimespan)` | `Timespan` / `float` |
| 颜色 | `make_color(r, g, b, a=1.0)` / `break_color(color)` | `FLinearColor MakeColor(...)` / `void BreakColor(...)` | `LinearColor` / `(float,float,float,float)` |
| 颜色 | `hsv_to_rgb(h, s, v, a=1.0)` | `FLinearColor HSVToRGB(float, float, float, float)` | `LinearColor` |
| 颜色 | `lerp_to(a, b, alpha)` | `FLinearColor LinearColorLerp(...)`（ScriptMethod=LerpTo） | `LinearColor` |
| 杂项 | `select_vector(a, b, b_pick_a)`（及 int/float/rotator/transform/string/color/object/class/name 同族） | `Select_Vector/Int/Float/Rotator/Transform/...` | 对应类型 |
| 杂项 | `class_is_child_of(test_class, parent_class)` | `bool ClassIsChildOf(TSubclassOf, TSubclassOf)` | `bool` |
| 帧时间 | `make_frame_rate(numerator, denominator=1)` / `break_frame_rate(rate)` | `FFrameRate MakeFrameRate(...)` / `void BreakFrameRate(...)` | `FrameRate` / `(int, int)` |
| 帧时间 | `make_qualified_frame_time(frame, frame_rate, sub_frame=0)` | `FQualifiedFrameTime MakeQualifiedFrameTime(...)` | `QualifiedFrameTime` |

## 示例

```python
import unreal

# 数值与三角
clamped = unreal.KismetMathLibrary.f_clamp(12.5, 0.0, 10.0)
frac, rem = unreal.KismetMathLibrary.f_mod(17.0, 5.0)

# 向量
v = unreal.KismetMathLibrary.make_vector(3.0, 4.0, 0.0)
norm = unreal.KismetMathLibrary.normal(v)
length = unreal.KismetMathLibrary.length_squared(v)
fwd = unreal.KismetMathLibrary.get_forward_vector(unreal.Rotator(0.0, 90.0, 0.0))

# 转换
pos = unreal.KismetMathLibrary.transform(
    unreal.Rotator(0.0, 45.0, 0.0))

# 确定性随机
stream = unreal.KismetMathLibrary.make_random_stream(42)
for _ in range(5):
    print(unreal.KismetMathLibrary.random_int(stream, 100))

# 插值
t = unreal.KismetMathLibrary.lerp_to(v, unreal.Vector(0.0, 0.0, 100.0), 0.3)
```

## 综合实战示例

### 坐标转换与世界定位

```python
import unreal

def spawn_actor_at_relative_location(base_actor, relative_offset):
    base_loc = base_actor.get_actor_location()
    base_rot = base_actor.get_actor_rotation()
    
    offset_local = unreal.KismetMathLibrary.transform_location(
        unreal.KismetMathLibrary.transform(base_rot),
        relative_offset
    )
    
    world_loc = unreal.KismetMathLibrary.add(base_loc, offset_local)
    
    return unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.StaticMeshActor,
        world_loc,
        base_rot
    )

def align_actor_to_surface(normal,up_vector):
    ref_up = unreal.Vector(0.0, 0.0, 1.0)
    rotation_axis = unreal.KismetMathLibrary.cross(normal, ref_up)
    rotation_angle = unreal.KismetMathLibrary.deg_cos(unreal.KismetMathLibrary.dot(normal, ref_up))
    
    if unreal.KismetMathLibrary.length_squared(rotation_axis) > 0.0001:
        rotation_axis = unreal.KismetMathLibrary.normal(rotation_axis)
        rotator = unreal.KismetMathLibrary.rotate_axis_angle_vector(
            unreal.Vector(1.0, 0.0, 0.0),
            rotation_angle,
            rotation_axis
        )
        return unreal.KismetMathLibrary.rotator(rotator)
    else:
        return unreal.Rotator(0.0, 0.0, 0.0)
```

### 随机流与确定性采样

```python
import unreal

def deterministic_loot_table(seed, probability_table):
    stream = unreal.KismetMathLibrary.make_random_stream(seed)
    total = sum(probability_table.values())
    accumulated = 0.0
    
    for item, prob in probability_table.items():
        accumulated += prob / total
        rand_val = unreal.KismetMathLibrary.random_float(stream)
        if rand_val <= accumulated:
            return item
    
    return list(probability_table.keys())[-1]

def generate_procedural_terrain(base_seed, size_x, size_y, noise_scale=0.1):
    terrain_data = {}
    stream = unreal.KismetMathLibrary.make_random_stream(base_seed)
    
    for x in range(size_x):
        for y in range(size_y):
            noise_seed = unreal.KismetMathLibrary.add_int_int(
                x, 
                unreal.KismetMathLibrary.multiply_int_int(y, size_x)
            )
            noise_stream = unreal.KismetMathLibrary.make_random_stream(noise_seed)
            height = unreal.KismetMathLibrary.f_clamp(
                unreal.KismetMathLibrary.random_float(noise_stream) * noise_scale,
                0.0,
                1.0
            )
            terrain_data[(x, y)] = height
    
    return terrain_data
```

### 插值与平滑动画

```python
import unreal

def smooth_camera_transition(start_loc, end_loc, duration, delta_time):
    current_time = 0.0
    interp_state = unreal.FFloatSpringState()
    
    while current_time < duration:
        alpha = current_time / duration
        
        lerp_pos = unreal.KismetMathLibrary.lerp_to(
            start_loc, end_loc, alpha
        )
        
        spring_pos = unreal.KismetMathLibrary.float_spring_interp(
            current_time,
            duration,
            interp_state,
            10.0,  # stiffness
            1.0,   # mass
            0.1    # damping
        )
        
        yield unreal.Vector(
            lerp_pos.get_x() * (1.0 - spring_pos) + spring_pos * end_loc.get_x(),
            lerp_pos.get_y() * (1.0 - spring_pos) + spring_pos * end_loc.get_y(),
            lerp_pos.get_z() * (1.0 - spring_pos) + spring_pos * end_loc.get_z()
        )
        
        current_time += delta_time

def smooth_value_interpolation(initial_value, target_value, delta_time, speed):
    return unreal.KismetMathLibrary.f_interp_to(
        initial_value,
        target_value,
        delta_time,
        speed
    )
```

## 高级用法

### 确定性随机流管理

```python
import unreal

class DeterministicRandomManager:
    def __init__(self):
        self.global_seed = 0
        self.streams = {}
    
    def get_stream(self, name):
        if name not in self.streams:
            stream = unreal.KismetMathLibrary.make_random_stream(
                self.global_seed + hash(name) % 10000
            )
            self.streams[name] = stream
        return self.streams[name]
    
    def seed_all(self, seed):
        self.global_seed = seed
        self.streams.clear()

def reproducible_simulation(seed, steps):
    manager = DeterministicRandomManager()
    manager.seed_all(seed)
    
    results = []
    for i in range(steps):
        stream = manager.get_stream(f"step_{i}")
        value = unreal.KismetMathLibrary.random_float(stream)
        results.append(value)
    
    return results
```

### 向量几何与碰撞检测

```python
import unreal

def closest_point_on_line(start, end, point):
    line_vec = unreal.KismetMathLibrary.subtract(end, start)
    point_vec = unreal.KismetMathLibrary.subtract(point, start)
    
    line_len_sq = unreal.KismetMathLibrary.length_squared(line_vec)
    if line_len_sq < 0.0001:
        return start
    
    projection = unreal.KismetMathLibrary.dot(point_vec, line_vec) / line_len_sq
    t = unreal.KismetMathLibrary.f_clamp(projection, 0.0, 1.0)
    
    return unreal.KismetMathLibrary.lerp_to(start, end, t)

def point_in_frustum(point, frustum_planes):
    for plane in frustum_planes:
        distance = unreal.KismetMathLibrary.dot(point, plane.get_normal()) + plane.get_w()
        if distance < 0.0:
            return False
    return True
```

### 矩阵变换与空间映射

```python
import unreal

def world_to_screen_with_aspect(world_point, view_info, aspect_ratio):
    world_to_mesh = view_info.get_view_transform_matrix()
    mesh_to_screen = unreal.KismetMathLibrary.make_matrix(
        unreal.Vector(aspect_ratio, 0.0, 0.0),
        unreal.Vector(0.0, 1.0, 0.0),
        unreal.Vector(0.0, 0.0, 1.0),
        unreal.Vector(0.0, 0.0, 0.0)
    )
    
    screen_point = unreal.KismetMathLibrary.transform_position(
        mesh_to_screen,
        unreal.KismetMathLibrary.transform_position(world_to_mesh, world_point)
    )
    
    return screen_point
```

### 时间与帧率计算

```python
import unreal

def calculate_frame_duration(frame_rate, frame_number=1):
    rate = unreal.KismetMathLibrary.make_frame_rate(
        frame_rate.get_numerator(),
        frame_rate.get_denominator()
    )
    time = unreal.KismetMathLibrary.make_qualified_frame_time(
        frame_number,
        rate
    )
    return unreal.KismetMathLibrary.from_seconds(
        unreal.KismetMathLibrary.get_total_seconds(
            unreal.KismetMathLibrary.from_seconds(1.0)
        )
    )

def sync_to_framerate(base_time, frame_rate, target_frame):
    rate = unreal.KismetMathLibrary.make_frame_rate(
        frame_rate.get_numerator(),
        frame_rate.get_denominator()
    )
    target_time = unreal.KismetMathLibrary.make_qualified_frame_time(
        target_frame,
        rate
    )
    return unreal.KismetMathLibrary.to_unix_timestamp(target_time)
```

## 常见问题与最佳实践

### 精度与边界条件

1. **浮点精度问题**：
   - 使用 `f_clamp` 替代手动边界检查，避免 `min(max(x, min), max)` 链式调用
   - 向量除零检测：除法前检查 `length_squared > 0.0001`
   - 比较浮点数时使用容差：`abs(a - b) < 0.0001`

2. **向量归一化安全**：
   ```python
   v = unreal.KismetMathLibrary.make_vector(x, y, z)
   len_sq = unreal.KismetMathLibrary.length_squared(v)
   if len_sq > 0.0001:
       normal = unreal.KismetMathLibrary.normal(v)
   else:
       normal = unreal.Vector(0.0, 0.0, 1.0)
   ```

3. **角度归一化**：
   ```python
   normalized_angle = unreal.KismetMathLibrary.clamp_axis(angle_deg)
   ```

### 性能优化技巧

1. **避免重复计算**：
   - 缓存 `length_squared` 替代 `length`（避免开方）
   - 预计算 `normal` 结果重复使用
   - 使用 `interpolate_to` 替代手写插值公式

2. **随机流管理**：
   - 需确定性序列时使用 `FRandomStream`，避免 `RandomFloat` 非确定性
   - 长时间运行的模拟按逻辑模块分隔随机流，便于调试

3. **变换组合优化**：
   - 多次变换前先组合 `Transform` 再应用，减少矩阵乘法
   - 向量变换优先使用 `TransformLocation` / `TransformRotation` 而非完整矩阵

### 典型陷阱

1. **旋转顺序混淆**：
   - UE 使用 Yaw-Pitch-Roll 顺序，组合旋转时注意非交换性
   - 使用 `Combine` / `Delta` 函数而非手动分量操作

2. **四元数插值**：
   - 短弧插值使用 `SlerpQuat`，长弧插值需手动处理
   - 四元数乘法顺序：`q_result = Multiply(q1, q2)` 表示 q2 后跟 q1

3. **时间单位混淆**：
   - 三角函数：`Sin/Cos/Tan` 接收弧度，`DegSin/DegCos/DegTan` 接收角度
   - 插值速度参数单位：`FInterpTo` 中 speed 是每秒接近率

### 调试技巧

```python
import unreal

def debug_vector_operations():
    v1 = unreal.Vector(1.0, 0.0, 0.0)
    v2 = unreal.Vector(0.0, 1.0, 0.0)
    
    dot = unreal.KismetMathLibrary.dot(v1, v2)
    cross = unreal.KismetMathLibrary.cross(v1, v2)
    angle_rad = unreal.KismetMathLibrary.de_degrees_to_radians(
        unreal.KismetMathLibrary.deg_cos(dot)
    )
    
    print(f"Dot: {dot}, Cross: ({cross.get_x()}, {cross.get_y()}, {cross.get_z()})")
    print(f"Angle: {unreal.KismetMathLibrary.degrees_to_radians(angle_rad)}")

def validate_transform_chain(transform_list):
    result = unreal.Transform()
    result.set_identity()
    
    for transform in transform_list:
        result = unreal.KismetMathLibrary.multiply(result, transform)
    
    return result
```

## 限制和注意事项

- 全部为 `BlueprintPure`/`BlueprintCallable` 静态方法；算术、比较、转换与结构体运算符家族按同模式调用（如 `add`/`subtract`/`multiply`/`divide`、`less`/`greater`/`equal_equal_*`、`conv_*` 族对应各自类型），完整逐方法清单见 `docs/overview.md`。
- 头文件中 `meta=(DeprecatedFunction)` 的成员（如 `Conv_DoubleToFloat`、`Conv_FloatToDouble`、`LinearColor_Quantize`）已过时，新脚本不要使用；`meta=(BlueprintInternalUseOnly)` 的 Ease 家族（`Ease`/`VEase`/`REase`/`TEase`）能否被 Python 直接调用需实测。
- 带 `UPARAM(ref)`/`UPARAM(ref)` 修改型参数（`Vector_Set`、`Vector_Normalize`、`Quat_Normalize`、`Matrix_RemoveScaling`、修改 spring/stream 状态的成员等）按 ByRef 约定：原对象被就地修改，返回按签名而定。
- 随机函数多数带 `NotBlueprintThreadSafe`（普通随机）或 `ScriptMethodMutable`（随机流版，读取流会推进流状态）；需要可复现序列一律用确定性 `FRandomStream`（`make_random_stream` + `*FromStream` 家族）。
- 本函数库无编辑器专属依赖；但无 Python/引擎运行时上下文时按 `BLOCKED_TOOLING` 处理，缺必要输入按 `BLOCKED_INPUT` 处理。转换/运算类调用不修改任何资产。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；`dir(unreal.KismetMathLibrary)` 实测命名后再落脚本。

详细逐方法 API 与完整示例见 `docs/overview.md`。