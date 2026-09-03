# KismetMathLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetMathLibrary.h` 整理 `UKismetMathLibrary`（继承 `UBlueprintFunctionLibrary`）中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的 static 成员。Python 类名去掉 `U` 前缀：`unreal.KismetMathLibrary`。方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case，无 ScriptMethod 的按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

本库共 737 个带 `UFUNCTION` 标记的成员，以下按头部 `Category=` 分组逐一列出。算术运算符家族（字节/整数/整数64/浮点的加减乘除、比较、`EqualEqual_*`、`NotEqual_*` 等）结构一致，给出代表签名后注明"同模式方法按同样参数约定调用"。

## 通用约定

### Python 类与方法

```python
import unreal

out = unreal.KismetMathLibrary.sqrt(16.0)          # 无 ScriptMethod，C++ 名转 snake_case
out = unreal.KismetMathLibrary.normal(unreal.Vector(3.0, 4.0, 0.0))  # ScriptMethod=Normal
```

命名约定：

- `meta=(ScriptMethod=...)` 存在时以该值转 snake_case，例如 `Add_VectorVector`（SM=`Add`）→ `add(a, b)`、`VSize`（SM=`Length`）→ `length(a)`、`Vector_Distance`（SM=`Distance`）→ `distance(v1, v2)`、`Conv_VectorToRotator`（SM=`Rotator`）→ `rotator(vec)`。
- 无 ScriptMethod 时按 C++ 函数名转 snake_case，例如 `Add_IntInt` → `add_int_int`、`FClamp` → `f_clamp`、`Abs` → `abs`。
- 部分派生名可能与 Python 内置对象重名（如 `len`、`min`、`max`、`round`、`abs`、`sin`、`cos`、`exp`、`log`、`sqrt`、`mean` 等），调用时必须通过 `unreal.KismetMathLibrary.<name>` 限定，不要直接以裸名调用。
- 带 `meta=(ScriptConstant=...)` 的常量成员（`Vector_Zero`、`IntPoint_Up`、`Quat_Identity`、`Matrix_Identity`、`LinearColor_Red`、`TimespanZeroValue` 等）在脚本侧通常以宿主结构体常量暴露（如 `unreal.Vector`、`unreal.IntPoint`、`unreal.Quat`、`unreal.Matrix`、`unreal.LinearColor`、`unreal.Timespan` 上的 `Zero`/`One`/`Forward`/`Red`/`Identity` 等），作为库方法直接调用能否暴露需按编辑器实测为准。
- `dir(unreal.KismetMathLibrary)` 是核对精确暴露名的唯一可靠手段；未实测不做"已验证"断言。

### Out / ByRef 返回约定

| 组合 | Python 返回 |
| --- | --- |
| `void` + 单个 Out/ByRef | 直接返回该 Out 参数的值 |
| `void` + 多个 Out/ByRef | 按声明顺序返回元组 `(out1, out2, ...)` |
| 有返回值 + Out/ByRef | 返回 `(return_value, out1, out2, ...)`，返回值在首位 |
| 无 Out 且无返回值 | `None` |
| `UPARAM(ref)/UPARAM(Ref)` 修改型参数 | 对象被就地修改，按上述规则返回 |

### 类型映射

| C++ | Python |
| --- | --- |
| `bool` | `bool`（byte 亦以 `int`） |
| `int32`/`int64`/`uint8` | `int` |
| `float`/`double` | `float` |
| `FString`/`FText`/`FName` | `str` / `str` / `unreal.Name` |
| `FVector`/`FVector2D`/`FVector4` | `unreal.Vector` / `unreal.Vector2D` / `unreal.Vector4` |
| `FRotator`/`FQuat`/`FMatrix`/`FTransform`/`FPlane` | `unreal.Rotator` / `unreal.Quat` / `unreal.Matrix` / `unreal.Transform` / `unreal.Plane` |
| `FLinearColor`/`FColor` | `unreal.LinearColor` / `unreal.Color` |
| `FIntPoint`/`FIntVector`/`FIntVector2` | `unreal.IntPoint` / `unreal.IntVector` / `unreal.IntVector2` |
| `FRandomStream` | `unreal.RandomStream` |
| `FBox`/`FBox2D`/`FBoxSphereBounds` | `unreal.Box` / `unreal.Box2D` / `unreal.BoxSphereBounds` |
| `FDateTime`/`FTimespan` | `unreal.DateTime` / `unreal.Timespan` |
| `FFrameNumber`/`FFrameRate`/`FQualifiedFrameTime` | `unreal.FrameNumber` / `unreal.FrameRate` / `unreal.QualifiedFrameTime` |
| `TArray<T>` | `Array[T]` |
| 枚举参数 | `unreal.<枚举名>`，多数接受名称字符串 |

## Math|Boolean（8 个）

全为布尔/逻辑运算，签名模式一致，Python 名如下：

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `not_pre_bool(a)` | `bool Not_PreBool(bool A)` | `bool` |
| `equal_equal_bool_bool(a, b)` | `bool EqualEqual_BoolBool(bool A, bool B)` | `bool` |
| `not_equal_bool_bool(a, b)` | `bool NotEqual_BoolBool(bool A, bool B)` | `bool` |
| `boolean_and(a, b)` | `bool BooleanAND(bool A, bool B)` | `bool` |
| `boolean_nand(a, b)` | `bool BooleanNAND(bool A, bool B)` | `bool` |
| `boolean_or(a, b)` | `bool BooleanOR(bool A, bool B)` | `bool` |
| `boolean_xor(a, b)` | `bool BooleanXOR(bool A, bool B)` | `bool` |
| `boolean_nor(a, b)` | `bool BooleanNOR(bool A, bool B)` | `bool` |

示例：

```python
ok = unreal.KismetMathLibrary.boolean_and(True, False)
nand = unreal.KismetMathLibrary.boolean_nand(True, True)
```

## Math|Byte（15 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `multiply_byte_byte(a, b)` | `uint8 Multiply_ByteByte(uint8 A, uint8 B)` | `int` |
| `divide_byte_byte(a, b=1)` | `uint8 Divide_ByteByte(uint8 A, uint8 B)` | `int` |
| `percent_byte_byte(a, b=1)` | `uint8 Percent_ByteByte(uint8 A, uint8 B)` | `int` |
| `add_byte_byte(a, b=1)` | `uint8 Add_ByteByte(uint8 A, uint8 B)` | `int` |
| `subtract_byte_byte(a, b=1)` | `uint8 Subtract_ByteByte(uint8 A, uint8 B)` | `int` |
| `less_byte_byte(a, b)` / `greater_byte_byte(a, b)` | `bool Less/Greater_ByteByte(uint8, uint8)` | `bool` |
| `less_equal_byte_byte(a, b)` / `greater_equal_byte_byte(a, b)` | `bool LessEqual/GreaterEqual_ByteByte(...)` | `bool` |
| `equal_equal_byte_byte(a, b)` / `not_equal_byte_byte(a, b)` | `bool EqualEqual/NotEqual_ByteByte(...)` | `bool` |
| `b_min(a, b)` / `b_max(a, b)` | `uint8 BMin/BMax(uint8 A, uint8 B)` | `int` |
| `max_of_byte_array(byte_array)` | `void MaxOfByteArray(const TArray<uint8>&, int32& IndexOfMaxValue, uint8& MaxValue)` | `(int, int)` |
| `min_of_byte_array(byte_array)` | `void MinOfByteArray(const TArray<uint8>&, int32& IndexOfMinValue, uint8& MinValue)` | `(int, int)` |

示例：

```python
idx, hi = unreal.KismetMathLibrary.max_of_byte_array([1, 3, 2, 5])
```

## Math|Integer（27 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `multiply_int_int(a, b)` | `int32 Multiply_IntInt(int32 A, int32 B)` | `int` |
| `divide_int_int(a, b=1)` | `int32 Divide_IntInt(int32 A, int32 B)` | `int` |
| `percent_int_int(a, b=1)` | `int32 Percent_IntInt(int32 A, int32 B)` | `int` |
| `add_int_int(a, b=1)` | `int32 Add_IntInt(int32 A, int32 B)` | `int` |
| `subtract_int_int(a, b=1)` | `int32 Subtract_IntInt(int32 A, int32 B)` | `int` |
| `less_int_int(a,b)` / `greater_int_int(a,b)` / `less_equal_int_int(a,b)` / `greater_equal_int_int(a,b)` | `bool Less/Greater/LessEqual/GreaterEqual_IntInt(...)` | `bool` |
| `equal_equal_int_int(a,b)` / `not_equal_int_int(a,b)` | `bool EqualEqual/NotEqual_IntInt(...)` | `bool` |
| `in_range_int_int(value, min, max, inclusive_min=True, inclusive_max=True)` | `bool InRange_IntInt(int32, int32, int32, bool, bool)` | `bool` |
| `and_int_int(a, b)` | `int32 And_IntInt(int32 A, int32 B)` | `int` |
| `xor_int_int(a, b)` | `int32 Xor_IntInt(int32 A, int32 B)` | `int` |
| `or_int_int(a, b)` | `int32 Or_IntInt(int32 A, int32 B)` | `int` |
| `not_int(a)` | `int32 Not_Int(int32 A)` | `int` |
| `sign_of_integer(a)` | `int32 SignOfInteger(int32 A)` | `int` |
| `min(a, b)` / `max(a, b)` | `int32 Min/Max(int32 A, int32 B)` | `int` |
| `clamp(value, min, max)` | `int32 Clamp(int32 Value, int32 Min, int32 Max)` | `int` |
| `wrap(value, min, max)` | `int32 Wrap(int32 Value, int32 Min, int32 Max)` | `int` |
| `abs_int(a)` | `int32 Abs_Int(int32 A)` | `int` |
| `max_of_int_array(int_array)` | `void MaxOfIntArray(const TArray<int32>&, int32& IndexOfMaxValue, int32& MaxValue)` | `(int, int)` |
| `min_of_int_array(int_array)` | `void MinOfIntArray(const TArray<int32>&, int32& IndexOfMinValue, int32& MinValue)` | `(int, int)` |
| `median_of_int_array(int_array)` | `void MedianOfIntArray(TArray<int32>, float& MedianValue)` | `float` |
| `average_of_int_array(int_array)` | `void AverageOfIntArray(const TArray<int32>&, float& AverageValue)` | `float` |
| `select_int(a, b, b_pick_a)` | `int32 SelectInt(int32 A, int32 B, bool bPickA)` | `int` |

示例：

```python
n = unreal.KismetMathLibrary.clamp(150, 0, 100)
idx, hi = unreal.KismetMathLibrary.max_of_int_array([3, 9, 4])
avg = unreal.KismetMathLibrary.average_of_int_array([1, 2, 3])
```

## Math|Integer64（21 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `multiply_int64_int64(a, b)` / `divide_int64_int64(a, b=1)` | `int64 Multiply/Divide_Int64Int64(int64, int64)` | `int` |
| `percent_int64_int64(a, b=1)` | `int64 Percent_Int64Int64(int64 A, int64 B)` | `int` |
| `add_int64_int64(a, b=1)` / `subtract_int64_int64(a, b=1)` | `int64 Add/Subtract_Int64Int64(int64, int64)` | `int` |
| `less_int64_int64(a,b)` / `greater_int64_int64(a,b)` / `less_equal_int64_int64(a,b)` / `greater_equal_int64_int64(a,b)` | `bool Less/Greater/..._Int64Int64(int64,int64)` | `bool` |
| `equal_equal_int64_int64(a,b)` / `not_equal_int64_int64(a,b)` | `bool EqualEqual/NotEqual_Int64Int64(...)` | `bool` |
| `in_range_int64_int64(value, min, max, inclusive_min=True, inclusive_max=True)` | `bool InRange_Int64Int64(...)` | `bool` |
| `and_int64_int64(a,b)` / `xor_int64_int64(a,b)` / `or_int64_int64(a,b)` | `int64 And/Xor/Or_Int64Int64(...)` | `int` |
| `not_int64(a)` | `int64 Not_Int64(int64 A)` | `int` |
| `sign_of_integer64(a)` | `int64 SignOfInteger64(int64 A)` | `int` |
| `min_int64(a, b)` / `max_int64(a, b)` | `int64 MinInt64/MaxInt64(int64, int64)` | `int` |
| `clamp_int64(value, min, max)` | `int64 ClampInt64(int64, int64, int64)` | `int` |
| `abs_int64(a)` | `int64 Abs_Int64(int64 A)` | `int` |

示例：

```python
big = unreal.KismetMathLibrary.add_int64_int64(2**40, 123)
ok = unreal.KismetMathLibrary.in_range_int64_int64(big, 0, 2**60)
```

## Math|Float（54 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `multiply_multiply_float_float(base, exp)` | `double MultiplyMultiply_FloatFloat(double Base, double Exp)`（Power） | `float` |
| `multiply_int_float(a, b)` | `double Multiply_IntFloat(int32 A, double B)` | `float` |
| `percent_float_float(a, b=1.0)` | `double Percent_FloatFloat(double A, double B)` | `float` |
| `fraction(a)` | `double Fraction(double A)` | `float` |
| `add_double_double(a, b=1.0)` / `subtract_double_double(a, b=1.0)` | `double Add/Subtract_DoubleDouble(double, double)` | `float` |
| `multiply_double_double(a, b)` / `divide_double_double(a, b=1.0)` | `double Multiply/Divide_DoubleDouble(...)` | `float` |
| `less_double_double(a,b)` / `greater_double_double(a,b)` / `less_equal_double_double(a,b)` / `greater_equal_double_double(a,b)` | `bool Less/Greater/..._DoubleDouble(double,double)` | `bool` |
| `equal_equal_double_double(a,b)` / `not_equal_double_double(a,b)` | `bool EqualEqual/NotEqual_DoubleDouble(...)` | `bool` |
| `nearly_equal_float_float(a, b, error_tolerance=1.e-6)` | `bool NearlyEqual_FloatFloat(double, double, double)` | `bool` |
| `in_range_float_float(value, min, max, inclusive_min=True, inclusive_max=True)` | `bool InRange_FloatFloat(double, double, double, bool, bool)` | `bool` |
| `hypotenuse(width, height)` | `double Hypotenuse(double Width, double Height)` | `float` |
| `grid_snap_float(location, grid_size)` | `double GridSnap_Float(double Location, double GridSize)` | `float` |
| `abs(a)` | `double Abs(double A)` | `float` |
| `exp(a)` / `log(a, base=1.0)` / `loge(a)` | `double Exp/Log/Loge(double)` | `float` |
| `sqrt(a)` / `square(a)` | `double Sqrt/Square(double)` | `float` |
| `f_min(a, b)` / `f_max(a, b)` | `double FMin/FMax(double A, double B)` | `float` |
| `f_clamp(value, min, max)` | `double FClamp(double Value, double Min, double Max)` | `float` |
| `f_wrap(value, min, max)` | `double FWrap(double Value, double Min, double Max)` | `float` |
| `safe_divide(a, b)` | `double SafeDivide(double A, double B)`（B 为 0 返回 0） | `float` |
| `round(a)` / `f_floor(a)` / `f_trunc(a)` / `f_ceil(a)` | `int32 Round/FFloor/FTrunc/FCeil(double)` | `int` |
| `round64(a)` / `f_floor64(a)` / `f_trunc64(a)` / `f_ceil64(a)` | `int64 Round64/FFloor64/FTrunc64/FCeil64(double)` | `int` |
| `f_mod(dividend, divisor)` | `int32 FMod(double Dividend, double Divisor, double& Remainder)` | `(int, float)` |
| `f_mod64(dividend, divisor)` | `int64 FMod64(double Dividend, double Divisor, double& Remainder)` | `(int, float)` |
| `sign_of_float(a)` | `double SignOfFloat(double A)` | `float` |
| `normalize_to_range(value, range_min, range_max)` | `double NormalizeToRange(double, double, double)` | `float` |
| `map_range_unclamped(value, in_range_a, in_range_b, out_range_a, out_range_b)` | `double MapRangeUnclamped(...)` | `float` |
| `map_range_clamped(value, in_range_a, in_range_b, out_range_a, out_range_b)` | `double MapRangeClamped(...)` | `float` |
| `multiply_by_pi(value)` | `double MultiplyByPi(double Value)` | `float` |
| `lerp(a, b, alpha)` | `double Lerp(double A, double B, double Alpha)` | `float` |
| `f_interp_ease_in_out(a, b, alpha, exponent)` | `double FInterpEaseInOut(double, double, double, double)` | `float` |
| `truncated(in_vector)` | `FIntVector FTruncVector(const FVector&)`（SM=`Truncated`，各分量向零截断） | `IntVector` |
| `truncated(in_vector2d)` | `FIntVector2 FTruncVector2D(const FVector2D&)`（SM=`Truncated`） | `IntVector2` |
| `make_pulsating_value(current_time, pulses_per_second=1.0, phase=0.0)` | `float MakePulsatingValue(float, float, float)` | `float` |
| `fixed_turn(current, desired, delta_rate)` | `float FixedTurn(float, float, float)` | `float` |
| `max_of_float_array(float_array)` | `void MaxOfFloatArray(const TArray<float>&, int32& IndexOfMaxValue, float& MaxValue)` | `(int, float)` |
| `min_of_float_array(float_array)` | `void MinOfFloatArray(const TArray<float>&, int32& IndexOfMinValue, float& MinValue)` | `(int, float)` |
| `select_float(a, b, b_pick_a)` | `double SelectFloat(double, double, bool)` | `float` |

示例：

```python
v = unreal.KismetMathLibrary.map_range_clamped(0.5, 0.0, 1.0, 0.0, 100.0)
idx, hi = unreal.KismetMathLibrary.max_of_float_array([1.5, 3.7, 0.2])
whole, rem = unreal.KismetMathLibrary.f_mod(17.0, 5.0)
safe = unreal.KismetMathLibrary.safe_divide(10.0, 0.0)
```

## Math|Trig（18 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `sin(a)` / `cos(a)` / `tan(a)` | `double Sin/Cos/Tan(double)`（弧度输入） | `float` |
| `asin(a)` / `acos(a)` / `atan(a)` | `double Asin/Acos/Atan(double)`（输出弧度） | `float` |
| `atan2(y, x)` | `double Atan2(double Y, double X)` | `float` |
| `deg_sin(a)` / `deg_cos(a)` / `deg_tan(a)` | `double DegSin/DegCos/DegTan(double)`（角度输入） | `float` |
| `deg_asin(a)` / `deg_acos(a)` / `deg_atan(a)` | `double DegAsin/DegAcos/DegAtan(double)`（输出角度） | `float` |
| `deg_atan2(y, x)` | `double DegAtan2(double Y, double X)` | `float` |
| `get_p_i()` / `get_tau()` | `double GetPI()/GetTAU()` | `float` |
| `degrees_to_radians(a)` | `double DegreesToRadians(double A)` | `float` |
| `radians_to_degrees(a)` | `double RadiansToDegrees(double A)` | `float` |
| `clamp_angle(angle_degrees, min_angle_degrees, max_angle_degrees)` | `double ClampAngle(double, double, double)` | `float` |

示例：

```python
rad = unreal.KismetMathLibrary.degrees_to_radians(90.0)
s = unreal.KismetMathLibrary.sin(rad)
ang = unreal.KismetMathLibrary.clamp_angle(370.0, 0.0, 360.0)
```

## Math|IntPoint|Constants（6 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `int_point_zero()` | `FIntPoint IntPoint_Zero()` | `IntPoint`（宿主常量 `Zero`） |
| `int_point_one()` | `FIntPoint IntPoint_One()` | `IntPoint`（宿主常量 `One`） |
| `int_point_up()` | `FIntPoint IntPoint_Up()` | `IntPoint`（宿主常量 `Up`） |
| `int_point_left()` | `FIntPoint IntPoint_Left()` | `IntPoint`（宿主常量 `Left`） |
| `int_point_right()` | `FIntPoint IntPoint_Right()` | `IntPoint`（宿主常量 `Right`） |
| `int_point_down()` | `FIntPoint IntPoint_Down()` | `IntPoint`（宿主常量 `Down`） |

## Math|IntPoint（10 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `vector2d(int_point)` | `FVector2D Conv_IntPointToVector2D(FIntPoint)`（SM=`Vector2D`） | `Vector2D` |
| `add(a, b)` | `FIntPoint Add_IntPointIntPoint(FIntPoint, FIntPoint)`（SM=`Add`） | `IntPoint` |
| `add_int(a, b)` | `FIntPoint Add_IntPointInt(FIntPoint, int32)`（SM=`AddInt`） | `IntPoint` |
| `subtract(a, b)` / `subtract_int(a, b)` | `FIntPoint Subtract_IntPointIntPoint/Int(...)` | `IntPoint` |
| `multiply(a, b)` / `multiply_int(a, b)` | `FIntPoint Multiply_IntPointIntPoint/Int(...)` | `IntPoint` |
| `divide(a, b)` / `divide_int(a, b)` | `FIntPoint Divide_IntPointIntPoint/Int(...)` | `IntPoint` |
| `equals(a, b)` | `bool Equal_IntPointIntPoint(FIntPoint, FIntPoint)`（SM=`Equals`） | `bool` |
| `not_equal(a, b)` | `bool NotEqual_IntPointIntPoint(FIntPoint, FIntPoint)` | `bool` |

示例：

```python
pt = unreal.KismetMathLibrary.add(unreal.IntPoint(1, 2), unreal.IntPoint(3, 4))
```

## Math|Vector2D（40 个，含 3 个常量）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `vector2d_one()` | `FVector2D Vector2D_One()`（常量 `One`） | `Vector2D` |
| `vector2d_unit45_deg()` | `FVector2D Vector2D_Unit45Deg()`（常量 `Unit45Deg`） | `Vector2D` |
| `vector2d_zero()` | `FVector2D Vector2D_Zero()`（常量 `Zero`） | `Vector2D` |
| `make_vector2d(x, y)` | `FVector2D MakeVector2D(double, double)` | `Vector2D` |
| `break_vector2d(vec)` | `void BreakVector2D(FVector2D, double& X, double& Y)` | `(float, float)` |
| `vector(v2, z=0)` | `FVector Conv_Vector2DToVector(FVector2D, float)`（Conversions，SM=`Vector`） | `Vector` |
| `int_point(v2)` | `FIntPoint Conv_Vector2DToIntPoint(FVector2D)`（SM=`IntPoint`） | `IntPoint` |
| `add(a, b)` / `add_float(a, b)` | `FVector2D Add_Vector2DVector2D/Float(...)`（SM=`Add`/`AddFloat`） | `Vector2D` |
| `subtract(a, b)` / `subtract_float(a, b)` | `FVector2D Subtract_Vector2DVector2D/Float(...)` | `Vector2D` |
| `multiply(a, b)` / `multiply_float(a, b)` | `FVector2D Multiply_Vector2DVector2D/Float(...)` | `Vector2D` |
| `divide(a, b)` / `divide_float(a, b=1.0)` | `FVector2D Divide_Vector2DVector2D/Float(...)` | `Vector2D` |
| `equals(a, b)` | `bool EqualExactly_Vector2DVector2D(...)`（SM=`Equals`，精确相等） | `bool` |
| `is_near_equal(a, b, error_tolerance=1.e-4)` | `bool EqualEqual_Vector2DVector2D(...)`（SM=`IsNearEqual`） | `bool` |
| `not_equal(a, b)` | `bool NotEqualExactly_Vector2DVector2D(...)`（精确不等） | `bool` |
| `is_not_near_equal(a, b, error_tolerance=1.e-4)` | `bool NotEqual_Vector2DVector2D(...)` | `bool` |
| `negated(a)` | `FVector2D Negated2D(const FVector2D&)`（SM=`Negated`） | `Vector2D` |
| `set(a, x, y)` | `void Set2D(UPARAM(ref) FVector2D&, double, double)`（SM=`Set`） | `None`（就地修改） |
| `clamped_axes(a, min_axis_val, max_axis_val)` | `FVector2D ClampAxes2D(...)`（SM=`ClampedAxes`） | `Vector2D` |
| `cross(a, b)` | `double CrossProduct2D(FVector2D, FVector2D)`（SM=`Cross`） | `float` |
| `distance(v1, v2)` | `double Distance2D(FVector2D, FVector2D)`（SM=`Distance`） | `float` |
| `distance_squared(v1, v2)` | `double DistanceSquared2D(...)` | `float` |
| `dot(a, b)` | `double DotProduct2D(FVector2D, FVector2D)`（SM=`Dot`） | `float` |
| `get_abs(a)` | `FVector2D GetAbs2D(...)`（SM=`GetAbs`） | `Vector2D` |
| `get_abs_max(a)` / `get_max(a)` / `get_min(a)` | `double GetAbsMax2D/GetMax2D/GetMin2D(...)` | `float` |
| `get_rotated(a, angle_deg)` | `FVector2D GetRotated2D(FVector2D, float)`（SM=`GetRotated`） | `Vector2D` |
| `is_nearly_zero(a, tolerance=1.e-4)` | `bool IsNearlyZero2D(const FVector2D&, float)` | `bool` |
| `is_zero(a)` | `bool IsZero2D(const FVector2D&)` | `bool` |
| `interp_to(current, target, delta_time, interp_speed)` | `FVector2D Vector2DInterpTo(...)`（Interpolation，SM=`InterpTo`） | `Vector2D` |
| `interp_to_constant(current, target, delta_time, interp_speed)` | `FVector2D Vector2DInterpTo_Constant(...)` | `Vector2D` |
| `normal(a, tolerance=1.e-8)` | `FVector2D NormalSafe2D(...)`（SM=`Normal`，安全归一化） | `Vector2D` |
| `normal_unsafe(a)` | `FVector2D Normal2D(...)`（SM=`NormalUnsafe`） | `Vector2D` |
| `normalize(a, tolerance=1.e-8)` | `void Normalize2D(UPARAM(ref) FVector2D&, float)`（SM=`Normalize`） | `None` |
| `spherical_to_unit_cartesian(a)` | `FVector Spherical2DToUnitCartesian(...)` | `Vector` |
| `to_direction_and_length(a)` | `void ToDirectionAndLength2D(FVector2D, FVector2D& OutDir, double& OutLength)` | `(Vector2D, float)` |
| `to_rounded(a)` | `FVector2D ToRounded2D(...)` | `Vector2D` |
| `to_sign(a)` | `FVector2D ToSign2D(...)` | `Vector2D` |
| `length(a)` / `length_squared(a)` | `double VSize2D/VSize2DSquared(FVector2D)`（SM=`Length`/`LengthSquared`） | `float` |

示例：

```python
v2 = unreal.KismetMathLibrary.make_vector2d(3.0, 4.0)
len_ = unreal.KismetMathLibrary.length(v2)
norm2 = unreal.KismetMathLibrary.normal(v2)
dir_, ln = unreal.KismetMathLibrary.to_direction_and_length(v2)
```

## Math|Vector（109 个，含 8 个常量和 8 个 NetQuantize 构造/分解）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `vector_zero()` / `vector_one()` / `vector_forward()` / `vector_backward()` | `FVector Vector_Zero()/One()/Forward()/Backward()`（常量 `Zero`/`One`/`Forward`/`Backward`） | `Vector` |
| `vector_up()` / `vector_down()` / `vector_right()` / `vector_left()` | `FVector Vector_Up()/Down()/Right()/Left()`（常量 `Up`/`Down`/`Right`/`Left`） | `Vector` |
| `make_vector(x, y, z)` | `FVector MakeVector(double, double, double)` | `Vector` |
| `create_vector_from_yaw_pitch(yaw, pitch, length=1.0)` | `FVector CreateVectorFromYawPitch(float, float, float)` | `Vector` |
| `vector_assign(a, in_vector)` | `void Vector_Assign(UPARAM(ref) FVector&, const FVector&)`（SM=`Assign`） | `None` |
| `vector_set(a, x, y, z)` | `void Vector_Set(UPARAM(ref) FVector&, double, double, double)`（SM=`Set`） | `None` |
| `break_vector(vec)` | `void BreakVector(FVector, double& X, double& Y, double& Z)` | `(float, float, float)` |
| `rotator_from_axis_and_angle(axis, angle)` | `FRotator RotatorFromAxisAndAngle(FVector, float)`（SM=`RotatorFromAxisAndAngle`） | `Rotator` |
| `slerp_vectors(vector, direction, alpha)` | `FVector Vector_SlerpVectorToDirection(FVector, FVector, double)`（SM=`SlerpVectors`） | `Vector` |
| `slerp_normals(normal_a, normal_b, alpha)` | `FVector Vector_SlerpNormals(FVector, FVector, double)` | `Vector` |
| `add(a, b)` / `add_float(a, b)` / `add_int(a, b)` | `FVector Add_VectorVector/VectorFloat/VectorInt(...)`（SM=`Add`/`AddFloat`/`AddInt`） | `Vector` |
| `subtract(a, b)` / `subtract_float(a, b)` / `subtract_int(a, b)` | `FVector Subtract_VectorVector/VectorFloat/VectorInt(...)` | `Vector` |
| `multiply(a, b)` / `multiply_float(a, b)` / `multiply_int(a, b)` | `FVector Multiply_VectorVector/VectorFloat/VectorInt(...)` | `Vector` |
| `divide(a, b)` / `divide_float(a, b=1.0)` / `divide_int(a, b=1)` | `FVector Divide_VectorVector/VectorFloat/VectorInt(...)` | `Vector` |
| `negated(a)` | `FVector NegateVector(FVector)`（SM=`Negated`） | `Vector` |
| `equals(a, b)` | `bool EqualExactly_VectorVector(...)`（精确相等） | `bool` |
| `is_near_equal(a, b, error_tolerance=1.e-4)` | `bool EqualEqual_VectorVector(...)` | `bool` |
| `not_equal(a, b)` / `is_not_near_equal(a, b, error_tolerance=1.e-4)` | `bool NotEqualExactly_VectorVector(...)` / `NotEqual_VectorVector(...)` | `bool` |
| `dot(a, b)` | `double Dot_VectorVector(FVector, FVector)`（SM=`Dot`） | `float` |
| `cross(a, b)` | `FVector Cross_VectorVector(FVector, FVector)`（SM=`Cross`） | `Vector` |
| `rotate(a, rotator)` | `FVector GreaterGreater_VectorRotator(FVector, FRotator)`（SM=`Rotate`） | `Vector` |
| `rotate_angle_axis(vect, angle_deg, axis)` | `FVector RotateAngleAxis(FVector, float, FVector)`（SM=`RotateAngleAxis`） | `Vector` |
| `unrotate(a, rotator)` | `FVector LessLess_VectorRotator(FVector, FRotator)`（SM=`Unrotate`） | `Vector` |
| `vector_unwind_euler(a)` | `void Vector_UnwindEuler(UPARAM(ref) FVector&)`（SM=`UnwindEuler`） | `None` |
| `clamped_size(a, min, max)` | `FVector ClampVectorSize(FVector, double, double)`（SM=`ClampedSize`） | `Vector` |
| `clamped_size_2d(a, min, max)` | `FVector Vector_ClampSize2D(...)`（SM=`ClampedSize2D`，Z 不变） | `Vector` |
| `clamped_size_max(a, max)` | `FVector Vector_ClampSizeMax(...)` | `Vector` |
| `clamped_size_max_2d(a, max)` | `FVector Vector_ClampSizeMax2D(...)` | `Vector` |
| `get_min_element(a)` / `get_max_element(a)` | `double GetMinElement/GetMaxElement(FVector)`（SM=`GetMinElement`/`GetMaxElement`） | `float` |
| `get_abs_max(a)` / `get_abs_min(a)` | `double Vector_GetAbsMax/GetAbsMin(FVector)` | `float` |
| `get_abs(a)` | `FVector Vector_GetAbs(FVector)` | `Vector` |
| `get_min(a, b)` / `get_max(a, b)` | `FVector Vector_ComponentMin/ComponentMax(FVector, FVector)`（SM=`GetMin`/`GetMax`，逐分量 min/max） | `Vector` |
| `get_sign_vector(a)` | `FVector Vector_GetSignVector(FVector)`（SM=`GetSignVector`） | `Vector` |
| `get_projection(a)` | `FVector Vector_GetProjection(FVector)`（按 Z 投影/除 Z） | `Vector` |
| `heading_angle(a)` | `double Vector_HeadingAngle(FVector)`（返回 ±PI 弧度） | `float` |
| `cosine_angle2d(a, b)` | `double Vector_CosineAngle2D(FVector, FVector)`（XY 平面夹角余弦） | `float` |
| `to_radians(a)` / `to_degrees(a)` | `FVector Vector_ToRadians/ToDegrees(FVector)` | `Vector` |
| `unit_cartesian_to_spherical(a)` | `FVector2D Vector_UnitCartesianToSpherical(FVector)` | `Vector2D` |
| `direction_unit_to(from, to)` | `FVector GetDirectionUnitVector(FVector, FVector)`（SM=`DirectionUnitTo`） | `Vector` |
| `get_yaw_pitch(in_vec)` | `void GetYawPitchFromVector(FVector, float& Yaw, float& Pitch)`（SM=`GetYawPitch`） | `(float, float)` |
| `get_azimuth_elevation(in_direction, reference_frame)` | `void GetAzimuthAndElevation(FVector, const FTransform&, float&, float&)` | `(float, float)` |
| `get_vector_array_average(vectors)` | `FVector GetVectorArrayAverage(const TArray<FVector>&)` | `Vector` |
| `distance(v1, v2)` | `double Vector_Distance(FVector, FVector)`（SM=`Distance`） | `float` |
| `distance_squared(v1, v2)` | `double Vector_DistanceSquared(...)` | `float` |
| `distance_2d(v1, v2)` / `distance_2d_squared(v1, v2)` | `double Vector_Distance2D/Squared(...)` | `float` |
| `length(a)` / `length_squared(a)` / `length2d(a)` / `length2d_squared(a)` | `double VSize/VSizeSquared/VSizeXY/VSizeXYSquared(FVector)`（SM=`Length`/`LengthSquared`/`Length2D`/`Length2DSquared`） | `float` |
| `is_nearly_zero(a, tolerance=1.e-4)` | `bool Vector_IsNearlyZero(const FVector&, float)` | `bool` |
| `is_zero(a)` / `is_nan(a)` / `is_uniform(a, tolerance=1.e-4)` / `is_unit(a, squared_length_tolerance=1.e-4)` / `is_normal(a)` | `bool Vector_IsZero/IsNAN/IsUniform/IsUnit/IsNormal(...)` | `bool` |
| `normal(a, tolerance=1.e-4)` | `FVector Normal(FVector, float)`（SM=`Normal`，安全归一化） | `Vector` |
| `normal_2d(a, tolerance=1.e-4)` | `FVector Vector_Normal2D(FVector, float)`（XY 归一化，Z=0） | `Vector` |
| `normal_unsafe(a)` | `FVector Vector_NormalUnsafe(const FVector&)` | `Vector` |
| `normalize(a, tolerance=1.e-8)` | `void Vector_Normalize(UPARAM(ref) FVector&, float)`（SM=`Normalize`） | `None` |
| `lerp_to(a, b, alpha)` | `FVector VLerp(FVector, FVector, float)`（SM=`LerpTo`） | `Vector` |
| `reciprocal(a)` | `FVector Vector_Reciprocal(const FVector&)` | `Vector` |
| `mirror_by_vector(direction, surface_normal)` | `FVector GetReflectionVector(FVector, FVector)`（SM=`MirrorByVector`） | `Vector` |
| `mirror_vector_by_normal(in_vect, in_normal)` | `FVector MirrorVectorByNormal(FVector, FVector)` | `Vector` |
| `mirror_by_plane(a, plane)` | `FVector Vector_MirrorByPlane(FVector, const FPlane&)` | `Vector` |
| `snapped_to_grid(in_vect, grid_size)` | `FVector Vector_SnappedToGrid(FVector, float)` | `Vector` |
| `bounded_to_cube(in_vect, radius)` | `FVector Vector_BoundedToCube(FVector, float)` | `Vector` |
| `add_bounded(a, in_add_vect, radius)` | `void Vector_AddBounded(UPARAM(ref) FVector&, FVector, float)` | `None` |
| `bounded_to_box(in_vect, box_min, box_max)` | `FVector Vector_BoundedToBox(FVector, FVector, FVector)` | `Vector` |
| `project_on_to_normal(v, in_normal)` | `FVector Vector_ProjectOnToNormal(FVector, FVector)`（假定 InNormal 为单位向量） | `Vector` |
| `project_on_to(v, target)` | `FVector ProjectVectorOnToVector(FVector, FVector)`（SM=`ProjectOnTo`） | `Vector` |
| `project_point_on_to_plane(point, plane_base, plane_normal)` | `FVector ProjectPointOnToPlane(FVector, FVector, FVector)` | `Vector` |
| `project_on_to_plane(v, plane_normal)` | `FVector ProjectVectorOnToPlane(FVector, FVector)` | `Vector` |
| `find_nearest_points_on_line_segments(s1_start, s1_end, s2_start, s2_end)` | `void FindNearestPointsOnLineSegments(FVector×4, FVector&, FVector&)` | `(Vector, Vector)` |
| `find_closest_point_on_segment(point, segment_start, segment_end)` | `FVector FindClosestPointOnSegment(...)` | `Vector` |
| `find_closest_point_on_line(point, line_origin, line_direction)` | `FVector FindClosestPointOnLine(...)` | `Vector` |
| `get_point_distance_to_segment(point, segment_start, segment_end)` | `float GetPointDistanceToSegment(...)` | `float` |
| `get_point_distance_to_line(point, line_origin, line_direction)` | `float GetPointDistanceToLine(...)` | `float` |
| `get_forward_vector(in_rot)` / `get_right_vector(in_rot)` / `get_up_vector(in_rot)` | `FVector GetForwardVector/RightVector/UpVector(FRotator)` | `Vector` |
| `select_vector(a, b, b_pick_a)` | `FVector SelectVector(FVector, FVector, bool)` | `Vector` |
| `make_vector_net_quantize(x, y, z)` | `FVector_NetQuantize MakeVector_NetQuantize(double, double, double)` | `Vector` |
| `make_vector_net_quantize10(x, y, z)` / `make_vector_net_quantize100(x, y, z)` / `make_vector_net_quantize_normal(x, y, z)` | `FVector_NetQuantize10/100/Normal MakeVector_NetQuantize10/100/Normal(...)` | `Vector` |
| `break_vector_net_quantize(vec)` | `void BreakVector_NetQuantize(FVector_NetQuantize, double&, double&, double&)` | `(float, float, float)` |
| `break_vector_net_quantize10(vec)` / `break_vector_net_quantize100(vec)` / `break_vector_net_quantize_normal(vec)` | `void BreakVector_NetQuantize10/100/Normal(...)` | `(float, float, float)` |

示例：

```python
v = unreal.KismetMathLibrary.make_vector(3.0, 4.0, 0.0)
n = unreal.KismetMathLibrary.normal(v)
l = unreal.KismetMathLibrary.length(v)
proj = unreal.KismetMathLibrary.project_on_to(v, unreal.Vector(1.0, 0.0, 0.0))
near = unreal.KismetMathLibrary.find_closest_point_on_segment(proj, unreal.Vector(0,0,0), unreal.Vector(10,0,0))
x, y, z = unreal.KismetMathLibrary.break_vector(v)
```

## Math|Transform（17 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `select_transform(a, b, b_pick_a)` | `FTransform SelectTransform(const FTransform&, const FTransform&, bool)` | `Transform` |
| `make_transform(location, rotation, scale=Vector(1,1,1))` | `FTransform MakeTransform(FVector Location, FRotator Rotation, FVector Scale)` | `Transform` |
| `break_transform(trans)` | `void BreakTransform(const FTransform&, FVector& Location, FRotator& Rotation, FVector& Scale)` | `(Vector, Rotator, Vector)` |
| `equals(a, b)` | `bool EqualEqual_TransformTransform(const FTransform&, const FTransform&)` | `bool` |
| `is_near_equal(a, b, location_tolerance=1.e-4, rotation_tolerance=1.e-4, scale3d_tolerance=1.e-4)` | `bool NearlyEqual_TransformTransform(...)` | `bool` |
| `multiply(a, b)` | `FTransform ComposeTransforms(const FTransform&, const FTransform&)`（SM=`Multiply`，A*B：先 B 后 A） | `Transform` |
| `transform_location(t, location)` | `FVector TransformLocation(const FTransform&, FVector)` | `Vector` |
| `transform_direction(t, direction)` | `FVector TransformDirection(const FTransform&, FVector)`（不改变长度） | `Vector` |
| `transform_rotation(t, rotation)` | `FRotator TransformRotation(const FTransform&, FRotator)` | `Rotator` |
| `inverse_transform_location(t, location)` | `FVector InverseTransformLocation(const FTransform&, FVector)` | `Vector` |
| `inverse_transform_direction(t, direction)` | `FVector InverseTransformDirection(const FTransform&, FVector)` | `Vector` |
| `inverse_transform_rotation(t, rotation)` | `FRotator InverseTransformRotation(const FTransform&, FRotator)` | `Rotator` |
| `make_relative(a, relative_to)` | `FTransform MakeRelativeTransform(const FTransform&, const FTransform&)`（SM=`MakeRelative`） | `Transform` |
| `inverse(t)` | `FTransform InvertTransform(const FTransform&)`（SM=`Inverse`） | `Transform` |
| `lerp(a, b, alpha, interp_mode=ELerpInterpolationMode::QuatInterp)` | `FTransform TLerp(const FTransform&, const FTransform&, float, TEnumAsByte<ELerpInterpolationMode::Type>)`（SM=`Lerp`） | `Transform` |
| `determinant(t)` | `float Transform_Determinant(const FTransform&)`（SM=`Determinant`） | `float` |
| `to_matrix(t)` | `FMatrix Conv_TransformToMatrix(const FTransform&)`（Conversions，SM=`ToMatrix`） | `Matrix` |

示例：

```python
t = unreal.KismetMathLibrary.make_transform(
    unreal.Vector(100.0, 0.0, 0.0), unreal.Rotator(0.0, 90.0, 0.0))
world_pos = unreal.KismetMathLibrary.transform_location(t, unreal.Vector(0.0, 0.0, 50.0))
rel = unreal.KismetMathLibrary.make_relative(world_pos_transform, parent_transform)
inv = unreal.KismetMathLibrary.inverse(t)
```

## Math|Vector4（31 个，含 1 个常量）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `vector4_zero()` | `FVector4 Vector4_Zero()`（常量 `Zero`） | `Vector4` |
| `make_vector4(x, y, z, w)` | `FVector4 MakeVector4(double, double, double, double)` | `Vector4` |
| `break_vector4(vec)` | `void BreakVector4(const FVector4&, double&, double&, double&, double&)` | `(float, float, float, float)` |
| `vector(v4)` | `FVector Conv_Vector4ToVector(const FVector4&)`（Conversions，SM=`Vector`） | `Vector` |
| `rotator(v4)` | `FRotator Conv_Vector4ToRotator(const FVector4&)`（SM=`Rotator`） | `Rotator` |
| `quaternion(v4)` | `FQuat Conv_Vector4ToQuaternion(const FVector4&)`（SM=`Quaternion`） | `Quat` |
| `add(a, b)` / `subtract(a, b)` / `multiply(a, b)` / `divide(a, b)` | `FVector4 Add/Subtract/Multiply/Divide_Vector4Vector4(...)` | `Vector4` |
| `equals(a, b)` / `is_near_equal(a, b, tolerance=1.e-4)` | `bool EqualExactly/EqualEqual_Vector4Vector4(...)` | `bool` |
| `not_equal(a, b)` / `is_not_near_equal(a, b, tolerance=1.e-4)` | `bool NotEqualExactly/NotEqual_Vector4Vector4(...)` | `bool` |
| `negated(a)` | `FVector4 Vector4_Negated(const FVector4&)`（SM=`Negated`） | `Vector4` |
| `vector4_assign(a, in_vector)` / `vector4_set(a, x, y, z, w)` | `void Vector4_Assign/Set(UPARAM(ref) FVector4&, ...)` | `None` |
| `cross3(a, b)` | `FVector4 Vector4_CrossProduct3(const FVector4&, const FVector4&)`（SM=`Cross3`） | `Vector4` |
| `dot(a, b)` / `dot3(a, b)` | `double Vector4_DotProduct/DotProduct3(...)`（SM=`Dot`/`Dot3`） | `float` |
| `is_nan(a)` / `is_nearly_zero3(a, tolerance=1.e-4)` / `is_zero(a)` | `bool Vector4_IsNAN/IsNearlyZero3/IsZero(...)` | `bool` |
| `length(a)` / `length_squared(a)` / `length3(a)` / `length_squared3(a)` | `double Vector4_Size/SizeSquared/Size3/SizeSquared3(...)` | `float` |
| `is_unit3(a, tolerance=1.e-4)` / `is_normal3(a)` | `bool Vector4_IsUnit3/IsNormal3(...)` | `bool` |
| `normal3(a, tolerance=1.e-4)` | `FVector4 Vector4_Normal3(...)`（SM=`Normal3`，安全归一化） | `Vector4` |
| `normal_unsafe3(a)` | `FVector4 Vector4_NormalUnsafe3(...)` | `Vector4` |
| `normalize3(a, tolerance=1.e-8)` | `void Vector4_Normalize3(UPARAM(ref) FVector4&, float)` | `None` |
| `mirror_by_vector3(direction, surface_normal)` | `FVector4 Vector4_MirrorByVector3(...)` | `Vector4` |
| `transform_vector4(a, b)` | `FVector4 TransformVector4(const FMatrix&, const FVector4&)` | `Vector4` |

示例：

```python
v4 = unreal.KismetMathLibrary.make_vector4(1.0, 2.0, 3.0, 1.0)
w = unreal.KismetMathLibrary.dot3(v4, v4)
m = unreal.Matrix()
out = unreal.KismetMathLibrary.transform_vector4(m, v4)
```

## Math|Rotator（28 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_rotator(roll, pitch, yaw)` | `FRotator MakeRotator(float Roll, float Pitch, float Yaw)`（X=Roll，Y=Pitch，Z=Yaw） | `Rotator` |
| `make_rot_from_x(x)` / `make_rot_from_y(y)` / `make_rot_from_z(z)` | `FRotator MakeRotFromX/Y/Z(const FVector&)` | `Rotator` |
| `make_rot_from_xy(x, y)` / `make_rot_from_xz(x, z)` / `make_rot_from_yx(y, x)` / `make_rot_from_yz(y, z)` / `make_rot_from_zx(z, x)` / `make_rot_from_zy(z, y)` | `FRotator MakeRotFromXY/XZ/YX/YZ/ZX/ZY(...)` | `Rotator` |
| `make_rotation_from_axes(forward, right, up)` | `FRotator MakeRotationFromAxes(FVector, FVector, FVector)` | `Rotator` |
| `find_look_at_rotation(start, target)` | `FRotator FindLookAtRotation(const FVector&, const FVector&)` | `Rotator` |
| `find_relative_look_at_rotation(start_transform, target_location)` | `FRotator FindRelativeLookAtRotation(const FTransform&, const FVector&)` | `Rotator` |
| `break_rotator(in_rot)` | `void BreakRotator(FRotator, float& Roll, float& Pitch, float& Yaw)` | `(float, float, float)` |
| `break_rot_into_axes(in_rot)` | `void BreakRotIntoAxes(const FRotator&, FVector& X, FVector& Y, FVector& Z)` | `(Vector, Vector, Vector)` |
| `is_near_equal(a, b, error_tolerance=1.e-4)` | `bool EqualEqual_RotatorRotator(FRotator, FRotator, float)`（SM=`IsNearEqual`） | `bool` |
| `is_not_near_equal(a, b, error_tolerance=1.e-4)` | `bool NotEqual_RotatorRotator(...)` | `bool` |
| `scale(a, b)` | `FRotator Multiply_RotatorFloat(FRotator, float)`（SM=`Scale`） | `Rotator` |
| `scale_integer(a, b)` | `FRotator Multiply_RotatorInt(FRotator, int32)`（SM=`ScaleInteger`） | `Rotator` |
| `combine(a, b)` | `FRotator ComposeRotators(FRotator, FRotator)`（SM=`Combine`，先 A 后 B） | `Rotator` |
| `inversed(a)` | `FRotator NegateRotator(FRotator)`（SM=`Inversed`） | `Rotator` |
| `to_vector(in_rot)` | `FVector Conv_RotatorToVector(FRotator)`（Math|Rotator，SM=`ToVector`） | `Vector` |
| `transform(in_rotator)` | `FTransform Conv_RotatorToTransform(const FRotator&)`（Conversions） | `Transform` |
| `get_axes(a)` | `void GetAxes(FRotator, FVector& X, FVector& Y, FVector& Z)` | `(Vector, Vector, Vector)` |
| `lerp(a, b, alpha, b_shortest_path)` | `FRotator RLerp(FRotator, FRotator, float, bool)`（SM=`Lerp`） | `Rotator` |
| `select_rotator(a, b, b_pick_a)` | `FRotator SelectRotator(FRotator, FRotator, bool)` | `Rotator` |
| `delta(a, b)` | `FRotator NormalizedDeltaRotator(FRotator, FRotator)`（SM=`Delta`，A-B 归一化） | `Rotator` |
| `clamp_axis(angle)` | `float ClampAxis(float)`（钳到 [0,360)） | `float` |
| `normalize_axis(angle)` | `float NormalizeAxis(float)`（钳到 [-180,180]） | `float` |
| `random_rotator(b_roll=False)` | `FRotator RandomRotator(bool bRoll)`（Math|Random） | `Rotator` |

示例：

```python
r = unreal.KismetMathLibrary.make_rotator(0.0, 30.0, 90.0)
look = unreal.KismetMathLibrary.find_look_at_rotation(unreal.Vector(0,0,0), unreal.Vector(100,0,50))
roll, pitch, yaw = unreal.KismetMathLibrary.break_rotator(r)
ax = unreal.KismetMathLibrary.get_axes(r)
ang = unreal.KismetMathLibrary.clamp_axis(-45.0)
```

## Math|Matrix（43 个，含 1 个常量）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `transform(in_matrix)` | `FTransform Conv_MatrixToTransform(const FMatrix&)`（Conversions，SM=`Transform`） | `Transform` |
| `rotator(in_matrix)` | `FRotator Conv_MatrixToRotator(const FMatrix&)`（Conversions） | `Rotator` |
| `get_origin(m)` | `FVector Matrix_GetOrigin(const FMatrix&)`（SM=`GetOrigin`） | `Vector` |
| `matrix_identity()` | `FMatrix Matrix_Identity()`（常量 `Identity`） | `Matrix` |
| `multiply(a, b)` | `FMatrix Multiply_MatrixMatrix(const FMatrix&, const FMatrix&)`（SM=`Multiply`） | `Matrix` |
| `add(a, b)` | `FMatrix Add_MatrixMatrix(...)` | `Matrix` |
| `multiply_float(a, b)` | `FMatrix Multiply_MatrixFloat(const FMatrix&, double)`（SM=`MultiplyFloat`） | `Matrix` |
| `equals(a, b, tolerance=1.e-4)` | `bool EqualEqual_MatrixMatrix(...)` | `bool` |
| `not_equal(a, b, tolerance=1.e-4)` | `bool NotEqual_MatrixMatrix(...)` | `bool` |
| `transform_vector4(m, v)` | `FVector4 Matrix_TransformVector4(const FMatrix&, FVector4)` | `Vector4` |
| `transform_position(m, v)` | `FVector4 Matrix_TransformPosition(const FMatrix&, FVector)` | `Vector4` |
| `inverse_transform_position(m, v)` | `FVector Matrix_InverseTransformPosition(const FMatrix&, FVector)` | `Vector` |
| `transform_vector(m, v)` | `FVector4 Matrix_TransformVector(const FMatrix&, FVector)` | `Vector4` |
| `inverse_transform_vector(m, v)` | `FVector Matrix_InverseTransformVector(const FMatrix&, FVector)` | `Vector` |
| `get_transposed(m)` | `FMatrix Matrix_GetTransposed(const FMatrix&)` | `Matrix` |
| `get_determinant(m)` | `float Matrix_GetDeterminant(const FMatrix&)` | `float` |
| `get_rot_determinant(m)` | `float Matrix_GetRotDeterminant(const FMatrix&)` | `float` |
| `get_inverse(m)` | `FMatrix Matrix_GetInverse(const FMatrix&)` | `Matrix` |
| `get_transpose_adjoint(m)` | `FMatrix Matrix_GetTransposeAdjoint(const FMatrix&)` | `Matrix` |
| `remove_scaling(m, tolerance=1.e-8)` | `void Matrix_RemoveScaling(UPARAM(Ref) FMatrix&, float)` | `None` |
| `get_matrix_without_scale(m, tolerance=1.e-8)` | `FMatrix Matrix_GetMatrixWithoutScale(...)` | `Matrix` |
| `get_scale_vector(m, tolerance=1.e-8)` | `FVector Matrix_GetScaleVector(...)` | `Vector` |
| `remove_translation(m)` | `FMatrix Matrix_RemoveTranslation(...)` | `Matrix` |
| `concatenate_translation(m, translation)` | `FMatrix Matrix_ConcatenateTranslation(...)` | `Matrix` |
| `contains_nan(m)` | `bool Matrix_ContainsNaN(const FMatrix&)` | `bool` |
| `scale_translation(m, scale3d)` | `FMatrix Matrix_ScaleTranslation(...)` | `Matrix` |
| `get_maximum_axis_scale(m)` | `float Matrix_GetMaximumAxisScale(...)` | `float` |
| `apply_scale(m, scale)` | `FMatrix Matrix_ApplyScale(const FMatrix&, float)` | `Matrix` |
| `get_scaled_axis(m, axis)` | `FVector Matrix_GetScaledAxis(const FMatrix&, TEnumAsByte<EAxis::Type>)` | `Vector` |
| `get_scaled_axes(m)` | `void Matrix_GetScaledAxes(const FMatrix&, FVector& X, FVector& Y, FVector& Z)` | `(Vector, Vector, Vector)` |
| `get_unit_axis(m, axis)` | `FVector Matrix_GetUnitAxis(const FMatrix&, TEnumAsByte<EAxis::Type>)` | `Vector` |
| `get_unit_axes(m)` | `void Matrix_GetUnitAxes(const FMatrix&, FVector&, FVector&, FVector&)` | `(Vector, Vector, Vector)` |
| `set_axis(m, axis, axis_vector)` | `void Matrix_SetAxis(UPARAM(Ref) FMatrix&, TEnumAsByte<EAxis::Type>, FVector)` | `None` |
| `set_origin(m, new_origin)` | `void Matrix_SetOrigin(UPARAM(Ref) FMatrix&, FVector)` | `None` |
| `get_column(m, column)` | `FVector Matrix_GetColumn(const FMatrix&, TEnumAsByte<EMatrixColumns::Type>)` | `Vector` |
| `set_column(m, column, value)` | `void Matrix_SetColumn(UPARAM(Ref) FMatrix&, TEnumAsByte<EMatrixColumns::Type>, FVector)` | `None` |
| `get_rotator(m)` | `FRotator Matrix_GetRotator(const FMatrix&)` | `Rotator` |
| `to_quat(m)` | `FQuat Matrix_ToQuat(const FMatrix&)` | `Quat` |
| `get_frustum_near_plane(m)` / `get_frustum_far_plane(m)` / `get_frustum_left_plane(m)` / `get_frustum_right_plane(m)` / `get_frustum_top_plane(m)` / `get_frustum_bottom_plane(m)` | `bool Matrix_GetFrustumNearPlane/... (const FMatrix&, FPlane& OutPlane)` | `(bool, Plane)` |
| `mirror(m, mirror_axis, flip_axis)` | `FMatrix Matrix_Mirror(const FMatrix&, TEnumAsByte<EAxis::Type>, TEnumAsByte<EAxis::Type>)` | `Matrix` |

示例：

```python
m = unreal.KismetMathLibrary.matrix_identity()
inv = unreal.KismetMathLibrary.get_inverse(m)
det = unreal.KismetMathLibrary.get_determinant(m)
ok, near_plane = unreal.KismetMathLibrary.get_frustum_near_plane(m)
```

## Math|Quat（38 个，含 1 个常量）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `quat_identity()` | `FQuat Quat_Identity()`（常量 `Identity`） | `Quat` |
| `equals(a, b, tolerance=1.e-4)` | `bool EqualEqual_QuatQuat(const FQuat&, const FQuat&, float)` | `bool` |
| `not_equal(a, b, error_tolerance=1.e-4)` | `bool NotEqual_QuatQuat(...)` | `bool` |
| `add(a, b)` / `subtract(a, b)` | `FQuat Add_QuatQuat/Subtract_QuatQuat(...)` | `Quat` |
| `make_quat(x, y, z, w)` | `FQuat MakeQuat(float, float, float, float)` | `Quat` |
| `break_quat(q)` | `void BreakQuat(const FQuat&, float& X, float& Y, float& Z, float& W)` | `(float, float, float, float)` |
| `multiply(a, b)` | `FQuat Multiply_QuatQuat(const FQuat&, const FQuat&)`（A*B：先 B 后 A） | `Quat` |
| `is_identity(q, tolerance=1.e-4)` | `bool Quat_IsIdentity(...)` | `bool` |
| `is_normalized(q)` / `is_finite(q)` / `is_non_finite(q)` | `bool Quat_IsNormalized/IsFinite/IsNonFinite(...)` | `bool` |
| `angular_distance(a, b)` | `float Quat_AngularDistance(const FQuat&, const FQuat&)`（弧度） | `float` |
| `ensure_shortest_arc_to(a, b)` | `void Quat_EnforceShortestArcWith(UPARAM(ref) FQuat&, const FQuat&)`（SM=`EnsureShortestArcTo`） | `None` |
| `euler(q)` | `FVector Quat_Euler(const FQuat&)`（欧拉角，角度） | `Vector` |
| `exp(q)` | `FQuat Quat_Exp(const FQuat&)` | `Quat` |
| `get_angle(q)` | `float Quat_GetAngle(const FQuat&)` | `float` |
| `get_axis_x(q)` / `get_axis_y(q)` / `get_axis_z(q)` | `FVector Quat_GetAxisX/Y/Z(...)` | `Vector` |
| `vector_forward(q)` / `vector_right(q)` / `vector_up(q)` | `FVector Quat_VectorForward/Right/Up(...)` | `Vector` |
| `normalize(q, tolerance=1.e-4)` | `void Quat_Normalize(UPARAM(ref) FQuat&, float)` | `None` |
| `normalized(q, tolerance=1.e-4)` | `FQuat Quat_Normalized(const FQuat&, float)` | `Quat` |
| `get_rotation_axis(q)` | `FVector Quat_GetRotationAxis(const FQuat&)` | `Vector` |
| `inversed(q)` | `FQuat Quat_Inversed(const FQuat&)` | `Quat` |
| `log(q)` | `FQuat Quat_Log(const FQuat&)` | `Quat` |
| `set_components(q, x, y, z, w)` | `void Quat_SetComponents(UPARAM(ref) FQuat&, float×4)` | `None` |
| `set_from_euler(q, euler)` | `void Quat_SetFromEuler(UPARAM(ref) FQuat&, const FVector&)` | `None` |
| `make_from_euler(euler)` | `FQuat Quat_MakeFromEuler(const FVector&)` | `Quat` |
| `rotator(q)` | `FRotator Quat_Rotator(const FQuat&)`（Conversions，SM=`Rotator`） | `Rotator` |
| `quaternion(in_rot)` | `FQuat Conv_RotatorToQuaternion(FRotator)`（SM=`Quaternion`） | `Quat` |
| `size(q)` / `size_squared(q)` | `float Quat_Size/SizeSquared(...)` | `float` |
| `rotate_vector(q, v)` | `FVector Quat_RotateVector(const FQuat&, const FVector&)` | `Vector` |
| `unrotate_vector(q, v)` | `FVector Quat_UnrotateVector(const FQuat&, const FVector&)` | `Vector` |
| `slerp_quat(a, b, alpha)` | `FQuat Quat_Slerp(const FQuat&, const FQuat&, double)`（SM=`SlerpQuat`） | `Quat` |
| `find_quat_between_vectors(start, end)` | `FQuat Quat_FindBetweenVectors(FVector, FVector)` | `Quat` |
| `find_quat_between_normals(start_normal, end_normal)` | `FQuat Quat_FindBetweenNormals(FVector, FVector)` | `Quat` |

示例：

```python
q = unreal.KismetMathLibrary.quaternion(unreal.Rotator(0.0, 90.0, 0.0))
qv = unreal.KismetMathLibrary.rotate_vector(q, unreal.Vector(1.0, 0.0, 0.0))
q2 = unreal.KismetMathLibrary.slerp_quat(unreal.KismetMathLibrary.quat_identity(), q, 0.5)
r = unreal.KismetMathLibrary.rotator(q)
```

## Math|Color（44 个，含 8 个常量）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `linear_color_white()` / `linear_color_gray()` / `linear_color_black()` / `linear_color_red()` / `linear_color_green()` / `linear_color_blue()` / `linear_color_yellow()` / `linear_color_transparent()` | `FLinearColor LinearColor_White()/Gray()/Black()/Red()/Green()/Blue()/Yellow()/Transparent()`（宿主常量，线性色彩空间） | `LinearColor` |
| `make_color(r, g, b, a=1.0)` | `FLinearColor MakeColor(float, float, float, float)` | `LinearColor` |
| `break_color(color)` | `void BreakColor(FLinearColor, float& R, float& G, float& B, float& A)` | `(float, float, float, float)` |
| `set(in_out_color, in_color)` | `void LinearColor_Set(UPARAM(ref) FLinearColor&, FLinearColor)` | `None` |
| `set_rgba(in_out_color, r, g, b, a=1.0)` | `void LinearColor_SetRGBA(UPARAM(ref) FLinearColor&, ...)` | `None` |
| `set_from_hsv(in_out_color, h, s, v, a=1.0)` | `void LinearColor_SetFromHSV(...)` | `None` |
| `set_from_srgb(in_out_color, in_srgb)` | `void LinearColor_SetFromSRGB(UPARAM(ref) FLinearColor&, const FColor&)` | `None` |
| `set_from_pow22(in_out_color, in_color)` | `void LinearColor_SetFromPow22(UPARAM(ref) FLinearColor&, const FColor&)` | `None` |
| `set_temperature(in_out_color, in_temperature)` | `void LinearColor_SetTemperature(UPARAM(ref) FLinearColor&, float)` | `None` |
| `set_random_hue(in_out_color)` | `void LinearColor_SetRandomHue(UPARAM(ref) FLinearColor&)` | `None` |
| `to_rgb_vector(color)` | `FVector Conv_LinearColorToVector(FLinearColor)`（Conversions，SM=`ToRGBVector`） | `Vector` |
| `to_rgbe(color)` | `FColor LinearColor_ToRGBE(FLinearColor)` | `Color` |
| `to_color(color, use_srgb=True)` | `FColor Conv_LinearColorToColor(FLinearColor, bool)`（Conversions，SM=`ToColor`） | `Color` |
| `quantize(in_color)` | `FColor LinearColor_Quantize(FLinearColor)`（已过时，用 `quantize_round`） | `Color` |
| `quantize_round(in_color)` | `FColor LinearColor_QuantizeRound(FLinearColor)` | `Color` |
| `desaturated(in_color, in_desaturation)` | `FLinearColor LinearColor_Desaturated(...)` | `LinearColor` |
| `distance(c1, c2)` | `float LinearColor_Distance(FLinearColor, FLinearColor)` | `float` |
| `to_new_opacity(in_color, in_opacity)` | `FLinearColor LinearColor_ToNewOpacity(...)` | `LinearColor` |
| `get_luminance(in_color)` | `float LinearColor_GetLuminance(...)` | `float` |
| `get_max(in_color)` / `get_min(in_color)` | `float LinearColor_GetMax/GetMin(...)` | `float` |
| `interpolate_to(current, target, delta_time, interp_speed)` | `FLinearColor CInterpTo(...)`（Interpolation，SM=`InterpolateTo`） | `LinearColor` |
| `lerp_to(a, b, alpha)` | `FLinearColor LinearColorLerp(...)`（SM=`LerpTo`） | `LinearColor` |
| `lerp_using_hsv_to(a, b, alpha)` | `FLinearColor LinearColorLerpUsingHSV(...)`（SM=`LerpUsingHSVTo`） | `LinearColor` |
| `is_near_equal(a, b, tolerance=1.e-4)` | `bool LinearColor_IsNearEqual(...)` | `bool` |
| `equals(a, b)` / `not_equal(a, b)` | `bool EqualEqual/NotEqual_LinearColorLinearColor(...)` | `bool` |
| `add(a, b)` / `subtract(a, b)` / `multiply(a, b)` / `divide(a, b)` | `FLinearColor Add/Subtract/Multiply/Divide_LinearColorLinearColor(...)` | `LinearColor` |
| `multiply_float(a, b)` | `FLinearColor Multiply_LinearColorFloat(...)` | `LinearColor` |
| `to_hex(color)` | `FString ToHex_LinearColor(FLinearColor)`（RRGGBBAA） | `str` |
| `hsv_to_rgb(h, s, v, a=1.0)` | `FLinearColor HSVToRGB(float, float, float, float)` | `LinearColor` |
| `hsv_into_rgb(hsv)` | `void HSVToRGB_Vector(FLinearColor HSV, FLinearColor& RGB)`（SM=`HSVIntoRGB`） | `LinearColor` |
| `hsv_to_rgb(hsv)` | `FLinearColor HSVToRGBLinear(FLinearColor)`（SM=`HSVToRGB`） | `LinearColor` |
| `rgb_into_hsv_components(color)` | `void RGBToHSV(FLinearColor, float& H, float& S, float& V, float& A)`（SM=`RGBIntoHSVComponents`） | `(float, float, float, float)` |
| `rgb_into_hsv(rgb)` | `void RGBToHSV_Vector(FLinearColor RGB, FLinearColor& HSV)` | `LinearColor` |
| `rgb_to_hsv(rgb)` | `FLinearColor RGBLinearToHSV(FLinearColor)` | `LinearColor` |

示例：

```python
c = unreal.KismetMathLibrary.make_color(1.0, 0.5, 0.2)
r, g, b, a = unreal.KismetMathLibrary.break_color(c)
hsv = unreal.KismetMathLibrary.rgb_to_hsv(c)
hexstr = unreal.KismetMathLibrary.to_hex(c)
```

## Math|Plane（1 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_plane_from_point_and_normal(point, normal)` | `FPlane MakePlaneFromPointAndNormal(FVector, FVector)` | `Plane` |

## Math|DateTime（38 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_datetime(year, month, day, hour=0, minute=0, second=0, millisecond=0)` | `FDateTime MakeDateTime(int32×3, int32 Hour, int32 Minute, int32 Second, int32 Millisecond)` | `DateTime` |
| `break_datetime(dt)` | `void BreakDateTime(FDateTime, int32&×7)` | `(int,int,int,int,int,int,int)` |
| `add_date_time_timespan(a, b)` | `FDateTime Add_DateTimeTimespan(FDateTime, FTimespan)` | `DateTime` |
| `subtract_date_time_timespan(a, b)` | `FDateTime Subtract_DateTimeTimespan(FDateTime, FTimespan)` | `DateTime` |
| `add_date_time_date_time(a, b)` | `FDateTime Add_DateTimeDateTime(FDateTime, FDateTime)` | `DateTime` |
| `subtract_date_time_date_time(a, b)` | `FTimespan Subtract_DateTimeDateTime(FDateTime, FDateTime)` | `Timespan` |
| `equal_equal_date_time_date_time(a, b)` / `not_equal_date_time_date_time(a, b)` | `bool EqualEqual/NotEqual_DateTimeDateTime(...)` | `bool` |
| `greater_date_time_date_time(a,b)` / `greater_equal_date_time_date_time(a,b)` / `less_date_time_date_time(a,b)` / `less_equal_date_time_date_time(a,b)` | `bool Greater/GreaterEqual/Less/LessEqual_DateTimeDateTime(...)` | `bool` |
| `get_date(a)` | `FDateTime GetDate(FDateTime)` | `DateTime` |
| `get_day(a)` | `int32 GetDay(FDateTime)` | `int` |
| `get_day_of_year(a)` | `int32 GetDayOfYear(FDateTime)` | `int` |
| `get_hour(a)` / `get_hour12(a)` | `int32 GetHour/GetHour12(FDateTime)` | `int` |
| `get_millisecond(a)` / `get_minute(a)` / `get_month(a)` / `get_second(a)` / `get_year(a)` | `int32 GetMillisecond/Minute/Month/Second/Year(...)` | `int` |
| `get_time_of_day(a)` | `FTimespan GetTimeOfDay(FDateTime)` | `Timespan` |
| `is_afternoon(a)` / `is_morning(a)` | `bool IsAfternoon/IsMorning(FDateTime)` | `bool` |
| `days_in_month(year, month)` | `int32 DaysInMonth(int32, int32)` | `int` |
| `days_in_year(year)` | `int32 DaysInYear(int32)` | `int` |
| `is_leap_year(year)` | `bool IsLeapYear(int32)` | `bool` |
| `date_time_max_value()` / `date_time_min_value()` | `FDateTime DateTimeMaxValue/MinValue()` | `DateTime` |
| `now()` / `today()` / `utc_now()` | `FDateTime Now()/Today()/UtcNow()` | `DateTime` |
| `date_time_from_iso_string(iso_string)` | `bool DateTimeFromIsoString(FString, FDateTime& Result)` | `(bool, DateTime)` |
| `date_time_from_string(date_time_string)` | `bool DateTimeFromString(FString, FDateTime& Result)` | `(bool, DateTime)` |
| `to_unix_timestamp(time)` | `int64 ToUnixTimestamp(const FDateTime&)` | `int` |
| `to_unix_timestamp_double(time)` | `double ToUnixTimestampDouble(const FDateTime&)` | `float` |
| `from_unix_timestamp(unix_time)` | `FDateTime FromUnixTimestamp(const int64)` | `DateTime` |

示例：

```python
now = unreal.KismetMathLibrary.now()
unix = unreal.KismetMathLibrary.to_unix_timestamp(now)
back = unreal.KismetMathLibrary.from_unix_timestamp(unix)
ok, dt = unreal.KismetMathLibrary.date_time_from_iso_string("2026-09-01")
```

## Math|Timespan（35 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `timespan_max_value()` / `timespan_min_value()` / `timespan_zero_value()` | `FTimespan TimespanMaxValue/MinValue/ZeroValue()`（宿主常量 `MaxValue`/`MinValue`/`Zero`） | `Timespan` |
| `make_timespan(days, hours, minutes, seconds, milliseconds)` | `FTimespan MakeTimespan(int32×5)` | `Timespan` |
| `make_timespan2(days, hours, minutes, seconds, fraction_nano)` | `FTimespan MakeTimespan2(int32, int32, int32, int32, int32)` | `Timespan` |
| `break_timespan(ts)` | `void BreakTimespan(FTimespan, int32& Days, int32& Hours, int32& Minutes, int32& Seconds, int32& Milliseconds)` | `(int,int,int,int,int)` |
| `break_timespan2(ts)` | `void BreakTimespan2(FTimespan, int32&, int32&, int32&, int32&, int32& FractionNano)` | `(int,int,int,int,int)` |
| `add_timespan_timespan(a, b)` / `subtract_timespan_timespan(a, b)` | `FTimespan Add/Subtract_TimespanTimespan(...)` | `Timespan` |
| `multiply_timespan_float(a, scalar)` | `FTimespan Multiply_TimespanFloat(FTimespan, float)` | `Timespan` |
| `divide_timespan_float(a, scalar)` | `FTimespan Divide_TimespanFloat(FTimespan, float)` | `Timespan` |
| `equal_equal_timespan_timespan(a,b)` / `not_equal_timespan_timespan(a,b)` | `bool EqualEqual/NotEqual_TimespanTimespan(...)` | `bool` |
| `greater_timespan_timespan(a,b)` / `greater_equal_timespan_timespan(a,b)` / `less_timespan_timespan(a,b)` / `less_equal_timespan_timespan(a,b)` | `bool Greater/..._TimespanTimespan(...)` | `bool` |
| `get_days(a)` / `get_hours(a)` / `get_minutes(a)` / `get_seconds(a)` / `get_milliseconds(a)` | `int32 GetDays/Hours/Minutes/Seconds/Milliseconds(FTimespan)` | `int` |
| `get_duration(a)` | `FTimespan GetDuration(FTimespan)`（绝对值） | `Timespan` |
| `get_total_days(a)` / `get_total_hours(a)` / `get_total_minutes(a)` / `get_total_seconds(a)` / `get_total_milliseconds(a)` | `double GetTotalDays/Hours/Minutes/Seconds/Milliseconds(FTimespan)` | `float` |
| `from_days(days)` / `from_hours(hours)` / `from_minutes(minutes)` / `from_seconds(seconds)` / `from_milliseconds(milliseconds)` | `FTimespan FromDays/Hours/Minutes/Seconds/Milliseconds(double)` | `Timespan` |
| `timespan_ratio(a, b)` | `float TimespanRatio(FTimespan, FTimespan)` | `float` |
| `timespan_from_string(timespan_string)` | `bool TimespanFromString(FString, FTimespan& Result)` | `(bool, Timespan)` |

示例：

```python
ts = unreal.KismetMathLibrary.from_seconds(75.0)
hrs = unreal.KismetMathLibrary.get_total_minutes(ts)
days, hours, minutes, seconds, ms = unreal.KismetMathLibrary.break_timespan(ts)
```

## Utilities|Time Management（Math|FrameTime，4 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_qualified_frame_time(frame, frame_rate, sub_frame=0.0)` | `FQualifiedFrameTime MakeQualifiedFrameTime(FFrameNumber, FFrameRate, float)` | `QualifiedFrameTime` |
| `break_qualified_frame_time(in_frame_time)` | `void BreakQualifiedFrameTime(const FQualifiedFrameTime&, FFrameNumber& Frame, FFrameRate& FrameRate, float& SubFrame)` | `(FrameNumber, FrameRate, float)` |
| `make_frame_rate(numerator, denominator=1)` | `FFrameRate MakeFrameRate(int32, int32)` | `FrameRate` |
| `break_frame_rate(in_frame_rate)` | `void BreakFrameRate(const FFrameRate&, int32& Numerator, int32& Denominator)` | `(int, int)` |

示例：

```python
fr = unreal.KismetMathLibrary.make_frame_rate(60, 1)
qft = unreal.KismetMathLibrary.make_qualified_frame_time(unreal.FrameNumber(30), fr)
```

## Math|Conversions（41 个 + 2 个已过时成员）

以下为数值/结构转换成员。带 ScriptMethod 的转换按其 ScriptMethod 命名（`vector`/`rotator`/`quaternion`/`transform`/`to_color` 等），无 ScriptMethod 的按 C++ 名转 snake_case。转换均不修改任何对象。

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `conv_byte_to_double(in_byte)` | `double Conv_ByteToDouble(uint8)` | `float` |
| `conv_int_to_double(in_int)` | `double Conv_IntToDouble(int32)` | `float` |
| `conv_int_to_int64(in_int)` | `int64 Conv_IntToInt64(int32)` | `int` |
| `conv_int_to_byte(in_int)` | `uint8 Conv_IntToByte(int32)`（溢出取低 8 位） | `int` |
| `conv_int64_to_int(in_int)` | `int32 Conv_Int64ToInt(int64)`（溢出取低 32 位） | `int` |
| `conv_int64_to_byte(in_int)` | `uint8 Conv_Int64ToByte(int64)` | `int` |
| `conv_double_to_int64(in_double)` | `int64 Conv_DoubleToInt64(double)` | `int` |
| `conv_int64_to_double(in_int)` | `double Conv_Int64ToDouble(int64)` | `float` |
| `conv_byte_to_int(in_byte)` | `int32 Conv_ByteToInt(uint8)` | `int` |
| `conv_byte_to_int64(in_byte)` | `int64 Conv_ByteToInt64(uint8)` | `int` |
| `conv_int_to_bool(in_int)` | `bool Conv_IntToBool(int32)` | `bool` |
| `conv_bool_to_int(in_bool)` | `int32 Conv_BoolToInt(bool)` | `int` |
| `conv_bool_to_double(in_bool)` | `double Conv_BoolToDouble(bool)` | `float` |
| `conv_bool_to_byte(in_bool)` | `uint8 Conv_BoolToByte(bool)` | `int` |
| `conv_int_to_int_vector(in_int)` | `FIntVector Conv_IntToIntVector(int32)` | `IntVector` |
| `conv_int_to_int_vector2(in_int)` | `FIntVector2 Conv_IntToIntVector2(int32)` | `IntVector2` |
| `conv_int_to_vector(in_int)` | `FVector Conv_IntToVector(int32)` | `Vector` |
| `conv_double_to_vector(in_double)` | `FVector Conv_DoubleToVector(double)` | `Vector` |
| `conv_double_to_vector2d(in_double)` | `FVector2D Conv_DoubleToVector2D(double)` | `Vector2D` |
| `conv_double_to_linear_color(in_double)` | `FLinearColor Conv_DoubleToLinearColor(double)` | `LinearColor` |
| `conv_color_to_linear_color(in_color)` | `FLinearColor Conv_ColorToLinearColor(FColor)` | `LinearColor` |
| `conv_int_vector_to_vector(in_int_vector)` | `FVector Conv_IntVectorToVector(const FIntVector&)` | `Vector` |
| `conv_int_vector2_to_vector2d(in_int_vector2)` | `FVector2D Conv_IntVector2ToVector2D(const FIntVector2&)` | `Vector2D` |
| `vector2d(int_point)` | `FVector2D Conv_IntPointToVector2D(FIntPoint)`（SM=`Vector2D`） | `Vector2D` |
| `vector(vector2d, z=0)` | `FVector Conv_Vector2DToVector(FVector2D, float)`（SM=`Vector`） | `Vector` |
| `int_point(vector2d)` | `FIntPoint Conv_Vector2DToIntPoint(FVector2D)`（SM=`IntPoint`） | `IntPoint` |
| `linear_color(in_vector)` | `FLinearColor Conv_VectorToLinearColor(FVector)` | `LinearColor` |
| `transform(in_location)` | `FTransform Conv_VectorToTransform(FVector)` | `Transform` |
| `vector2d(in_vector)` | `FVector2D Conv_VectorToVector2D(FVector)` | `Vector2D` |
| `rotator(in_vector)` | `FRotator Conv_VectorToRotator(FVector)` | `Rotator` |
| `quaternion(in_vector)` | `FQuat Conv_VectorToQuaternion(FVector)` | `Quat` |
| `vector(in_vector4)` | `FVector Conv_Vector4ToVector(const FVector4&)` | `Vector` |
| `rotator(in_vector4)` | `FRotator Conv_Vector4ToRotator(const FVector4&)` | `Rotator` |
| `quaternion(in_vector4)` | `FQuat Conv_Vector4ToQuaternion(const FVector4&)` | `Quat` |
| `transform(in_rotator)` | `FTransform Conv_RotatorToTransform(const FRotator&)` | `Transform` |
| `quaternion(in_rotator)` | `FQuat Conv_RotatorToQuaternion(FRotator)`（SM=`Quaternion`） | `Quat` |
| `transform(in_matrix)` | `FTransform Conv_MatrixToTransform(const FMatrix&)` | `Transform` |
| `rotator(in_matrix)` | `FRotator Conv_MatrixToRotator(const FMatrix&)` | `Rotator` |
| `to_matrix(in_transform)` | `FMatrix Conv_TransformToMatrix(const FTransform&)`（SM=`ToMatrix`） | `Matrix` |
| `to_color(in_linear_color, in_use_srgb=True)` | `FColor Conv_LinearColorToColor(FLinearColor, bool)`（SM=`ToColor`） | `Color` |
| `to_rgb_vector(in_linear_color)` | `FVector Conv_LinearColorToVector(FLinearColor)`（SM=`ToRGBVector`） | `Vector` |

已过时成员（`DeprecatedFunction`，不建议使用，仅列明以覆盖头文件全部标记成员）：

| Python 方法名 | C++ 签名 | 说明 |
| --- | --- | --- |
| `conv_double_to_float(in_double)` | `float Conv_DoubleToFloat(double)` | 已过时：显式浮点转换不再需要 |
| `conv_float_to_double(in_float)` | `double Conv_FloatToDouble(float)` | 已过时：显式浮点转换不再需要 |

示例：

```python
v = unreal.KismetMathLibrary.rotator(unreal.Vector(0.0, 0.0, 1.0))
q = unreal.KismetMathLibrary.quaternion(v)
m = unreal.KismetMathLibrary.to_matrix(unreal.KismetMathLibrary.transform(v))
```

## Math|Conversions|Indices（4 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `convert1d_to2d(index1d, x_size)` | `FIntPoint Convert1DTo2D(int32, int32)` | `IntPoint` |
| `convert1d_to3d(index1d, x_size, y_size)` | `FIntVector Convert1DTo3D(int32, int32, int32)` | `IntVector` |
| `convert2d_to1d(index2d, x_size)` | `int32 Convert2DTo1D(const FIntPoint&, int32)` | `int` |
| `convert3d_to1d(index3d, x_size, y_size)` | `int32 Convert3DTo1D(const FIntVector&, int32, int32)` | `int` |

示例：

```python
pt = unreal.KismetMathLibrary.convert1d_to2d(7, 3)   # (1, 2)
```

## Math|Box（9 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_box(min, max)` | `FBox MakeBox(FVector Min, FVector Max)` | `Box` |
| `make_box_with_origin(origin, extent)` | `FBox MakeBoxWithOrigin(const FVector&, const FVector&)` | `Box` |
| `box_is_inside(inner_test, outer_test)` | `bool Box_IsInside(const FBox&, const FBox&)` | `bool` |
| `box_is_inside_or_on(inner_test, outer_test)` | `bool Box_IsInsideOrOn(const FBox&, const FBox&)` | `bool` |
| `box_is_point_inside(box, point)` | `bool Box_IsPointInside(const FBox&, const FVector&)`（开区间） | `bool` |
| `box_intersects(a, b)` | `bool Box_Intersects(const FBox&, const FBox&)` | `bool` |
| `box_expand_by(box, negative, positive)` | `FBox Box_ExpandBy(const FBox&, const FVector&, const FVector&)` | `Box` |
| `box_overlap(a, b)` | `FBox Box_Overlap(const FBox&, const FBox&)` | `Box` |
| `box_get_closest_point_to(box, point)` | `FVector Box_GetClosestPointTo(const FBox&, const FVector&)` | `Vector` |

示例：

```python
box = unreal.KismetMathLibrary.make_box(unreal.Vector(-10,-10,-10), unreal.Vector(10,10,10))
inside = unreal.KismetMathLibrary.box_intersects(box, unreal.KismetMathLibrary.make_box(unreal.Vector(0,0,0), unreal.Vector(5,5,5)))
```

## Math|Box2D（1 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_box2d(min, max)` | `FBox2D MakeBox2D(FVector2D Min, FVector2D Max)` | `Box2D` |

## Math|BoxSphereBounds（2 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `make_box_sphere_bounds(origin, box_extent, sphere_radius)` | `FBoxSphereBounds MakeBoxSphereBounds(FVector, FVector, float)` | `BoxSphereBounds` |
| `break_box_sphere_bounds(in_bounds)` | `void BreakBoxSphereBounds(const FBoxSphereBounds&, FVector& Origin, FVector& BoxExtent, float& SphereRadius)` | `(Vector, Vector, float)` |

## Math|Random（37 个）

普通（非确定性，`NotBlueprintThreadSafe`）：

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `random_bool()` | `bool RandomBool()` | `bool` |
| `random_bool_with_weight(weight)` | `bool RandomBoolWithWeight(float)` | `bool` |
| `random_integer(exclusive_max)` | `int32 RandomInteger(int32 Max)` | `int` |
| `random_integer_in_range(min, max)` | `int32 RandomIntegerInRange(int32, int32)` | `int` |
| `random_integer64(exclusive_max)` | `int64 RandomInteger64(int64)` | `int` |
| `random_integer64_in_range(min, max)` | `int64 RandomInteger64InRange(int64, int64)` | `int` |
| `random_float()` | `double RandomFloat()` | `float` |
| `random_float_in_range(min, max)` | `double RandomFloatInRange(double, double)` | `float` |
| `random_unit_vector()` | `FVector RandomUnitVector()` | `Vector` |
| `random_point_in_box_extents(center, half_size)` | `FVector RandomPointInBoundingBox(const FVector Center, const FVector HalfSize)`（SM=`RandomPointInBoxExtents`） | `Vector` |
| `random_point_in_box_extents(box)` | `FVector RandomPointInBoundingBox_Box(const FBox)`（SM=`RandomPointInBoxExtents`） | `Vector` |
| `random_unit_vector_in_cone_in_radians(cone_dir, cone_half_angle_in_radians)` | `FVector RandomUnitVectorInConeInRadians(FVector, float)` | `Vector` |
| `random_unit_vector_in_cone_in_degrees(cone_dir, cone_half_angle_in_degrees)` | `FVector RandomUnitVectorInConeInDegrees(FVector, float)` | `Vector` |
| `random_unit_vector_in_elliptical_cone_in_radians(cone_dir, max_yaw_in_radians, max_pitch_in_radians)` | `FVector RandomUnitVectorInEllipticalConeInRadians(...)` | `Vector` |
| `random_unit_vector_in_elliptical_cone_in_degrees(cone_dir, max_yaw_in_degrees, max_pitch_in_degrees)` | `FVector RandomUnitVectorInEllipticalConeInDegrees(...)` | `Vector` |
| `random_rotator(b_roll=False)` | `FRotator RandomRotator(bool bRoll)` | `Rotator` |
| `make_random_stream(initial_seed)` | `FRandomStream MakeRandomStream(int32)` | `RandomStream` |
| `make_random_stream_from_location(location, distance_interval=200.0, b_include_z=False)` | `FRandomStream MakeRandomStreamFromLocation(const FVector&, float, bool)` | `RandomStream` |
| `break_random_stream(in_stream)` | `void BreakRandomStream(const FRandomStream&, int32& InitialSeed)` | `int` |
| `perlin_noise1d(value)` | `float PerlinNoise1D(const float Value)` | `float` |

确定性随机流成员（首参 `FRandomStream`，`ScriptMethodMutable` 会推进流状态；无 SM 的取 `FromStream` 后缀转 snake_case）：

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `random_bool_with_weight(stream, weight)` | `bool RandomBoolWithWeightFromStream(const FRandomStream&, float)`（SM=`RandomBoolWithWeight`） | `bool` |
| `random_bool(stream)` | `bool RandomBoolFromStream(const FRandomStream&)`（SM=`RandomBool`） | `bool` |
| `random_int(stream, max)` | `int32 RandomIntegerFromStream(const FRandomStream&, int32 Max)`（SM=`RandomInt`） | `int` |
| `random_int_in_range(stream, min, max)` | `int32 RandomIntegerInRangeFromStream(...)`（SM=`RandomIntInRange`） | `int` |
| `random_integer64_from_stream(stream, max)` | `int64 RandomInteger64FromStream(const FRandomStream&, int64)`（无 SM，按 C++ 名派生） | `int` |
| `random_integer64_in_range_from_stream(stream, min, max)` | `int64 RandomInteger64InRangeFromStream(...)`（无 SM） | `int` |
| `random_float(stream)` | `float RandomFloatFromStream(const FRandomStream&)`（SM=`RandomFloat`） | `float` |
| `random_float_in_range(stream, min, max)` | `float RandomFloatInRangeFromStream(...)`（SM=`RandomFloatInRange`） | `float` |
| `random_unit_vector(stream)` | `FVector RandomUnitVectorFromStream(const FRandomStream&)`（SM=`RandomUnitVector`） | `Vector` |
| `random_point_in_bounded_box(stream, center, half_size)` | `FVector RandomPointInBoundingBoxFromStream(...)`（SM=`RandomPointInBoundedBox`） | `Vector` |
| `random_point_in_box(stream, box)` | `FVector RandomPointInBoundingBoxFromStream_Box(...)`（SM=`RandomPointInBox`） | `Vector` |
| `random_rotator(stream, b_roll)` | `FRotator RandomRotatorFromStream(const FRandomStream&, bool)` | `Rotator` |
| `random_unit_vector_in_cone_in_radians(stream, cone_dir, cone_half_angle_in_radians)` | `FVector RandomUnitVectorInConeInRadiansFromStream(...)`（SM） | `Vector` |
| `random_unit_vector_in_cone_in_degrees(stream, cone_dir, cone_half_angle_in_degrees)` | `FVector RandomUnitVectorInConeInDegreesFromStream(...)` | `Vector` |
| `random_unit_vector_in_elliptical_cone_in_radians(stream, cone_dir, max_yaw, max_pitch)` | `FVector RandomUnitVectorInEllipticalConeInRadiansFromStream(...)` | `Vector` |
| `random_unit_vector_in_elliptical_cone_in_degrees(stream, cone_dir, max_yaw, max_pitch)` | `FVector RandomUnitVectorInEllipticalConeInDegreesFromStream(...)` | `Vector` |
| `reset_random_stream(stream)` | `void ResetRandomStream(const FRandomStream&)`（SM=`Reset`） | `None` |
| `generate_new_seed(stream)` | `void SeedRandomStream(UPARAM(ref) FRandomStream&)`（SM=`GenerateNewSeed`） | `None` |
| `set_seed(stream, new_seed)` | `void SetRandomStreamSeed(UPARAM(ref) FRandomStream&, int32)`（SM=`SetSeed`） | `None` |

示例（确定性采样）：

```python
stream = unreal.KismetMathLibrary.make_random_stream(128)
for i in range(5):
    print(unreal.KismetMathLibrary.random_int(stream, 100))

stream2 = unreal.KismetMathLibrary.make_random_stream_from_location(unreal.Vector(100, 0, 0), 200.0)
v = unreal.KismetMathLibrary.random_unit_vector(stream2)
```

## Math|Geometry（10 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `min_area_rectangle(world_context_object, in_points, sample_surface_normal, b_debug_draw=False)` | `void MinAreaRectangle(UObject*, const TArray<FVector>&, const FVector&, FVector& OutRectCenter, FRotator& OutRectRotation, float& OutRectLengthX, float& OutRectLengthY, bool)` | `(Vector, Rotator, float, float)` |
| `points_are_coplanar(points, tolerance=0.1)` | `bool PointsAreCoplanar(const TArray<FVector>&, float)` | `bool` |
| `is_point_in_box(point, box_origin, box_extent)` | `bool IsPointInBox(FVector, FVector, FVector)` | `bool` |
| `is_point_in_box_box(point, box)` | `bool IsPointInBox_Box(FVector, FBox)` | `bool` |
| `get_box_volume(box)` | `double GetBoxVolume(const FBox&)` | `float` |
| `get_box_size(box)` | `FVector GetBoxSize(const FBox&)` | `Vector` |
| `get_box_center(box)` | `FVector GetBoxCenter(const FBox&)` | `Vector` |
| `is_point_in_box_with_transform(point, box_world_transform, box_extent)` | `bool IsPointInBoxWithTransform(FVector, const FTransform&, FVector)` | `bool` |
| `is_point_in_box_with_transform_box(point, box_world_transform, box)` | `bool IsPointInBoxWithTransform_Box(FVector, const FTransform&, FBox)` | `bool` |
| `get_slope_degree_angles(my_right_y_axis, floor_normal, up_vector)` | `void GetSlopeDegreeAngles(const FVector&, const FVector&, const FVector&, float& OutSlopePitchDegreeAngle, float& OutSlopeRollDegreeAngle)` | `(float, float)` |

示例：

```python
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
center, rotation, lx, ly = unreal.KismetMathLibrary.min_area_rectangle(world, points, unreal.Vector(0, 0, 1))
```

## Math|Intersection（2 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `line_plane_intersection(line_start, line_end, plane)` | `bool LinePlaneIntersection(const FVector&, const FVector&, const FPlane&, float& T, FVector& Intersection)` | `(bool, float, Vector)` |
| `line_plane_intersection_origin_normal(line_start, line_end, plane_origin, plane_normal)` | `bool LinePlaneIntersection_OriginNormal(...)` | `(bool, float, Vector)` |

示例：

```python
ok, t, hit = unreal.KismetMathLibrary.line_plane_intersection(
    unreal.Vector(0, 0, 10), unreal.Vector(0, 0, -10),
    unreal.KismetMathLibrary.make_plane_from_point_and_normal(
        unreal.Vector(0, 0, 0), unreal.Vector(0, 0, 1)))
```

## Math|Smoothing（6 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `weighted_moving_average_float(current_sample, previous_sample, weight)` | `float WeightedMovingAverage_Float(float, float, float)` | `float` |
| `weighted_moving_average_vector(current_sample, previous_sample, weight)` | `FVector WeightedMovingAverage_FVector(FVector, FVector, float)` | `Vector` |
| `weighted_moving_average_rotator(current_sample, previous_sample, weight)` | `FRotator WeightedMovingAverage_FRotator(FRotator, FRotator, float)` | `Rotator` |
| `dynamic_weighted_moving_average_float(current, previous, max_distance, min_weight, max_weight)` | `float DynamicWeightedMovingAverage_Float(float×5)` | `float` |
| `dynamic_weighted_moving_average_vector(current, previous, max_distance, min_weight, max_weight)` | `FVector DynamicWeightedMovingAverage_FVector(FVector, FVector, float, float, float)` | `Vector` |
| `dynamic_weighted_moving_average_rotator(current, previous, max_distance, min_weight, max_weight)` | `FRotator DynamicWeightedMovingAverage_FRotator(FRotator, FRotator, float, float, float)` | `Rotator` |

示例：

```python
smoothed = unreal.KismetMathLibrary.weighted_moving_average_float(1.0, 0.8, 0.5)
```

## Math|Interpolation（23 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `ease(a, b, alpha, easing_func, blend_exp=2, steps=2)` | `double Ease(double, double, double, TEnumAsByte<EEasingFunc::Type>, double, int32)`（`BlueprintInternalUseOnly`） | `float` |
| `f_interp_to(current, target, delta_time, interp_speed)` | `double FInterpTo(double, double, double, double)` | `float` |
| `f_interp_to_constant(current, target, delta_time, interp_speed)` | `double FInterpTo_Constant(double, double, double, double)` | `float` |
| `r_interp_to(current, target, delta_time, interp_speed)` | `FRotator RInterpTo(FRotator, FRotator, float, float)` | `Rotator` |
| `r_interp_to_constant(current, target, delta_time, interp_speed)` | `FRotator RInterpTo_Constant(...)` | `Rotator` |
| `interp_to(current, target, delta_time, interp_speed)` | `FVector VInterpTo(FVector, FVector, float, float)`（SM=`InterpTo`） | `Vector` |
| `interp_to_constant(current, target, delta_time, interp_speed)` | `FVector VInterpTo_Constant(...)`（SM=`InterpToConstant`） | `Vector` |
| `vector2d_interp_to(current, target, delta_time, interp_speed)` | `FVector2D Vector2DInterpTo(...)`（SM=`InterpTo`：与 Vector 版同名冲突，以实测暴露名为准） | `Vector2D` |
| `vector2d_interp_to_constant(current, target, delta_time, interp_speed)` | `FVector2D Vector2DInterpTo_Constant(...)` | `Vector2D` |
| `ease(a, b, alpha, b_shortest_path, easing_func, blend_exp=2, steps=2)` | `FRotator REase(...)`（Math|Interpolation，SM=`Ease`） | `Rotator` |
| `ease(a, b, alpha, easing_func, blend_exp=2, steps=2)` | `FVector VEase(FVector, FVector, float, TEnumAsByte<EEasingFunc::Type>, float, int32)`（SM=`Ease`） | `Vector` |
| `ease(a, b, alpha, easing_func, blend_exp=2, steps=2)` | `FTransform TEase(...)`（Math|Interpolation，SM=`Ease`） | `Transform` |
| `interpolate_to(current, target, delta_time, interp_speed)` | `FLinearColor CInterpTo(FLinearColor, FLinearColor, float, float)`（Math|Interpolation，SM=`InterpolateTo`） | `LinearColor` |
| `interp_to(current, target, delta_time, interp_speed)` | `FTransform TInterpTo(const FTransform&, const FTransform&, float, float)`（SM=`InterpTo`） | `Transform` |
| `float_spring_interp(current, target, spring_state, stiffness, critical_damping_factor, delta_time, mass=1.0, target_velocity_amount=1.0, b_clamp=False, min_value=-1.0, max_value=1.0, b_initialize_from_target=False)` | `float FloatSpringInterp(float, float, UPARAM(ref) FFloatSpringState&, float, float, float, float, float, bool, float, float, bool)` | `float` |
| `interp_spring_to(current, target, spring_state, stiffness, critical_damping_factor, delta_time, mass=1.0, target_velocity_amount=1.0, b_clamp=False, min_value=..., max_value=..., b_initialize_from_target=False)` | `FVector VectorSpringInterp(...)`（SM=`InterpSpringTo`） | `Vector`（就地更新 SpringState） |
| `interp_spring_to(current, target, spring_state, stiffness, critical_damping_factor, delta_time, mass=1.0, target_velocity_amount=1.0, b_initialize_from_target=False)` | `FQuat QuaternionSpringInterp(...)`（SM=`InterpSpringTo`） | `Quat` |
| `reset_float_spring_state(spring_state)` / `reset_vector_spring_state(spring_state)` / `reset_quaternion_spring_state(spring_state)` | `void ResetFloatSpringState/ResetVectorSpringState/ResetQuaternionSpringState(UPARAM(ref) ...&)` | `None` |
| `set_float_spring_state_velocity(spring_state, velocity)` / `set_vector_spring_state_velocity(spring_state, velocity)` / `set_quaternion_spring_state_angular_velocity(spring_state, angular_velocity)` | `void SetFloatSpringStateVelocity/SetVectorSpringStateVelocity/SetQuaternionSpringStateAngularVelocity(UPARAM(ref) ..., ...)` | `None` |

示例：

```python
state = unreal.FloatSpringState()
for i in range(10):
    val = unreal.KismetMathLibrary.float_spring_interp(
        0.0, 1.0, state, 100.0, 1.0, 0.1)
unreal.KismetMathLibrary.reset_float_spring_state(state)
```

## Math|Curves（1 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `get_runtime_float_curve_value(curve, time, default_value=0.0)` | `float GetRuntimeFloatCurveValue(const FRuntimeFloatCurve&, const float, const float)` | `float` |

## Utilities（Object / Class / Select 族，7 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `select_object(a, b, b_select_a)` / `select_class(a, b, b_select_a)` | `UObject*/UClass* SelectObject/SelectClass(UObject*, UObject*, bool)` | `Object` / `Class` |
| `equal_equal_object_object(a, b)` / `not_equal_object_object(a, b)` | `bool EqualEqual/NotEqual_ObjectObject(UObject*, UObject*)` | `bool` |
| `equal_equal_class_class(a, b)` / `not_equal_class_class(a, b)` | `bool EqualEqual/NotEqual_ClassClass(UClass*, UClass*)` | `bool` |
| `class_is_child_of(test_class, parent_class)` | `bool ClassIsChildOf(TSubclassOf<UObject>, TSubclassOf<UObject>)`（含自反） | `bool` |

## Utilities|String（Select 族，3 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `select_string(a, b, b_pick_a)` | `FString SelectString(const FString&, const FString&, bool)` | `str` |
| `select_text(a, b, b_pick_a)` | `FText SelectText(FText, FText, bool)` | `str` |
| `select_name(a, b, b_pick_a)` | `FName SelectName(FName, FName, bool)` | `str`（Name 可传字符串） |

## Utilities|Name（2 个）

| Python 方法名 | C++ 签名 | Python 返回 |
| --- | --- | --- |
| `equal_equal_name_name(a, b)` | `bool EqualEqual_NameName(FName, FName)` | `bool` |
| `not_equal_name_name(a, b)` | `bool NotEqual_NameName(FName, FName)` | `bool` |

## 完整示例：确定性随机 + 向量投影 + 时间戳

```python
import unreal

def main():
    if not hasattr(unreal, "KismetMathLibrary"):
        print({"status": "BLOCKED_TOOLING", "reason": "KismetMathLibrary 不可用"})
        return

    # 确定性随机序列
    stream = unreal.KismetMathLibrary.make_random_stream(2026)
    roll = [unreal.KismetMathLibrary.random_int(stream, 100) for _ in range(5)]

    # 向量运算
    v = unreal.KismetMathLibrary.make_vector(3.0, 4.0, 0.0)
    unit = unreal.KismetMathLibrary.normal(v)

    # 类型转换
    rot = unreal.KismetMathLibrary.rotator(unit)
    quat = unreal.KismetMathLibrary.quaternion(rot)

    # 布尔/数值
    ok = unreal.KismetMathLibrary.in_range_float_float(0.5, 0.0, 1.0)

    # 时间
    now = unreal.KismetMathLibrary.now()
    ts = unreal.KismetMathLibrary.to_unix_timestamp(now)

    print({
        "status": "OK",
        "roll": roll,
        "unit": str(unit),
        "rot": str(rot),
        "ok": ok,
        "unix": ts,
        "note": "纯数学计算，未修改任何资产；精确方法名以编辑器实测为准",
    })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_TOOLING`：无 Python/引擎运行时上下文，无法执行任何库调用。
- `BLOCKED_INPUT`：缺必要输入（坐标类型错误、世界上下文缺失等）。
- 普通随机（非 `FromStream`）不可复现且非线程安全；需要可复现输出一律使用 `FRandomStream` 确定性版本。
- 本文件覆盖头文件中全部带 `UFUNCTION` 标记成员（共 737 个），按 `Category` 分组列出；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。