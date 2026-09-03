# KismetRenderingLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetRenderingLibrary.h` 整理 `UKismetRenderingLibrary`（继承 `UBlueprintFunctionLibrary`）中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的 static 成员。Python 类名去掉 `U` 前缀：`unreal.KismetRenderingLibrary`。方法名优先取函数 `meta` 的脚本化名称（`ScriptName=`/`ScriptMethod=`）转 snake_case，无脚本化名称时按 C++ 函数名转 snake_case；`2D` 类型名转出 `2_d`（`clear_render_target2_d` 等）、`2DArray` 转出 `2_d_array`。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 通用约定

```python
import unreal

api = unreal.KismetRenderingLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
```

- 需要 `WorldContextObject` 的方法传编辑器主世界或游戏世界；无世界观点时按 `BLOCKED_INPUT` 处理。
- `ETextureRenderTargetFormat` 取 `unreal.TextureRenderTargetFormat` 枚举（`RTF_RGBA16F` / `RTF_RGBA32F` / `RTF_RGBA8` / `RTF_BGRA8` 等），默认 `RTF_RGBA16F`；精确枚举暴露名需实测确认。
- `TextureCompressionSettings` 取 `unreal.TextureCompressionSettings`（默认 `TC_DEFAULT`）；`TextureMipGenSettings` 取 `unreal.TextureMipGenSettings`（默认 `TMGS_FROM_TEXTURE_GROUP`）。
- Out / ByRef 返回约定：

| 组合 | Python 返回 |
| --- | --- |
| `void` + 单个 Out/ByRef | 直接返回该 Out 参数的值 |
| `void` + 多个 Out/ByRef | 按声明顺序返回元组 `(out1, out2, ...)` |
| 有返回值 + Out/ByRef | 返回 `(return_value, out1, out2, ...)`，返回值在首位 |
| 无 Out 且无返回值（`void`） | `None` |

## 目标清理与创建

### clear_render_target2_d

- C++ 签名：`void ClearRenderTarget2D(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, FLinearColor ClearColor = FLinearColor(0,0,0,1))`
- Python：`clear_render_target2_d(world_context_object, texture_render_target, clear_color=unreal.LinearColor(0,0,0,1)) -> None`
- 说明：以指定清理色清空渲染目标。
- 示例：

```python
api.clear_render_target2_d(world, rt, unreal.LinearColor(0.0, 0.0, 0.0, 1.0))
```

### create_render_target2_d

- C++ 签名：`UTextureRenderTarget2D* CreateRenderTarget2D(UObject* WorldContextObject, int32 Width = 256, int32 Height = 256, ETextureRenderTargetFormat Format = RTF_RGBA16f, FLinearColor ClearColor = FLinearColor::Black, bool bAutoGenerateMipMaps = false, bool bSupportUAVs = false)`
- Python：`create_render_target2_d(world_context_object, width=256, height=256, format=unreal.TextureRenderTargetFormat.RTF_RGBA16F, clear_color=unreal.LinearColor(0,0,0,0), b_auto_generate_mip_maps=False, b_support_uavs=False) -> TextureRenderTarget2D`
- 说明：创建指定尺寸/格式的 2D 渲染目标；创建失败返回 `None`。
- 示例：

```python
rt = api.create_render_target2_d(world, width=1024, height=1024)
if rt is None:
    print({"status": "BLOCKED_INPUT", "reason": "render target 创建失败"})
```

### create_render_target2_d_array

- C++ 签名：`UTextureRenderTarget2DArray* CreateRenderTarget2DArray(UObject* WorldContextObject, int32 Width = 256, int32 Height = 256, int32 Slices = 1, ETextureRenderTargetFormat Format = RTF_RGBA16f, FLinearColor ClearColor = FLinearColor::Black, bool bAutoGenerateMipMaps = false, bool bSupportUAVs = false)`
- Python：`create_render_target2_d_array(world_context_object, width=256, height=256, slices=1, format=..., clear_color=..., b_auto_generate_mip_maps=False, b_support_uavs=False) -> TextureRenderTarget2DArray`
- 示例：

```python
rt_arr = api.create_render_target2_d_array(world, width=64, height=64, slices=4)
```

### create_render_target_volume

- C++ 签名：`UTextureRenderTargetVolume* CreateRenderTargetVolume(UObject* WorldContextObject, int32 Width = 16, int32 Height = 16, int32 Depth = 16, ETextureRenderTargetFormat Format = RTF_RGBA16f, FLinearColor ClearColor = FLinearColor::Black, bool bAutoGenerateMipMaps = false, bool bSupportUAVs = false)`
- Python：`create_render_target_volume(world_context_object, width=16, height=16, depth=16, format=..., clear_color=..., b_auto_generate_mip_maps=False, b_support_uavs=False) -> TextureRenderTargetVolume`
- 说明：创建体渲染目标（供体积绘制/读取使用）。
- 示例：

```python
rt_vol = api.create_render_target_volume(world, width=32, height=32, depth=32)
```

### release_render_target2_d

- C++ 签名：`void ReleaseRenderTarget2D(UTextureRenderTarget2D* TextureRenderTarget)`
- Python：`release_render_target2_d(texture_render_target) -> None`
- 说明：立即释放渲染目标 GPU 资源（引擎注释：大量创建渲染目标时用于规避 GC 过晚释放导致的显存压力）。
- 示例：

```python
api.release_render_target2_d(rt)
```

### resize_render_target2_d

- C++ 签名：`void ResizeRenderTarget2D(UTextureRenderTarget2D* TextureRenderTarget, int32 Width = 256, int32 Height = 256)`
- Python：`resize_render_target2_d(texture_render_target, width=256, height=256) -> None`
- 说明：运行时改变渲染目标分辨率（用于视口或游戏内动态分辨率场景）。
- 示例：

```python
api.resize_render_target2_d(rt, width=1920, height=1080)
```

## 材质绘制

### draw_material_to_render_target

- C++ 签名：`void DrawMaterialToRenderTarget(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, UMaterialInterface* Material)`
- Python：`draw_material_to_render_target(world_context_object, texture_render_target, material) -> None`
- 说明：以材质渲染一个覆盖渲染目标的四边形；注意每次都会重新设置渲染目标（引擎注释为昂贵操作），同目标绘制多个原语用 Begin/End Canvas。
- 示例：

```python
mat = unreal.load_asset("/Game/Materials/M_RT_Probe")
if mat is None:
    print({"status": "BLOCKED_INPUT", "reason": "材质资产缺失"})
else:
    api.draw_material_to_render_target(world, rt, mat)
```

## Canvas 绘制

### begin_draw_canvas_to_render_target

- C++ 签名：`void BeginDrawCanvasToRenderTarget(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, UCanvas*& Canvas, FVector2D& Size, FDrawToRenderTargetContext& Context)`
- Python：`begin_draw_canvas_to_render_target(world_context_object, texture_render_target) -> (Canvas, Vector2D, DrawToRenderTargetContext)`
- 说明：`void` + 3 个 Out 参数，按声明顺序返回 `(Canvas, Size, Context)`。返回的 Canvas 可执行绘制（`unreal.Canvas` 的 draw_* 系列）；`Context` 必须原样传给成对的 `end_draw_canvas_to_render_target`。
- 示例：

```python
canvas, size, ctx = api.begin_draw_canvas_to_render_target(world, rt)
try:
    # canvas.draw_line(...) / canvas.draw_text(...) 等在此段执行
    pass
finally:
    api.end_draw_canvas_to_render_target(world, ctx)
```

### end_draw_canvas_to_render_target

- C++ 签名：`void EndDrawCanvasToRenderTarget(UObject* WorldContextObject, const FDrawToRenderTargetContext& Context)`
- Python：`end_draw_canvas_to_render_target(world_context_object, context) -> None`
- 说明：必须与 `BeginDrawCanvasToRenderTarget` 成对闭合，提交 Canvas 绘制、完成渲染目标渲染。
- 示例：

```python
api.end_draw_canvas_to_render_target(world, ctx)
```

## 读取

> 引擎注释均标记为"极低效慢操作"，尽量避免全图/逐像素高频读取。

### read_render_target_pixel

- C++ 签名：`FColor ReadRenderTargetPixel(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, int32 X, int32 Y)`
- Python：`read_render_target_pixel(world_context_object, texture_render_target, x, y) -> Color`
- 说明：按整数像素坐标读取渲染目标像素，返回 8-bit sRGB BGRA 颜色。
- 示例：

```python
c = api.read_render_target_pixel(world, rt, 0, 0)
```

### read_render_target_uv

- C++ 签名：`FColor ReadRenderTargetUV(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, float U, float V)`
- Python：`read_render_target_uv(world_context_object, texture_render_target, u, v) -> Color`
- 说明：按 UV 坐标读取像素（sRGB 空间，8-bit BGRA）。
- 示例：

```python
c = api.read_render_target_uv(world, rt, 0.5, 0.5)
```

### read_render_target

- C++ 签名：`bool ReadRenderTarget(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, TArray<FColor>& OutSamples, bool bNormalize = true)`
- Python：`read_render_target(world_context_object, texture_render_target, b_normalize=True) -> (bool, Array[Color])`
- 说明：整张目标按 sRGB 读出，返回 `(成功否, 每像素一个 8-bit BGRA 取样数组)`；返回值与 Out 组成元组，返回值在首位。
- 示例：

```python
ok, samples = api.read_render_target(world, rt)
if not ok:
    print({"status": "BLOCKED_TOOLING", "reason": "读取渲染目标失败"})
```

### read_render_target_raw_pixel

- C++ 签名：`FLinearColor ReadRenderTargetRawPixel(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, int32 X, int32 Y, bool bNormalize = true)`
- Python：`read_render_target_raw_pixel(world_context_object, texture_render_target, x, y, b_normalize=True) -> LinearColor`
- 说明：按整数坐标读取原始线性值（HDR 目标为线性空间，不做 sRGB 变换）。
- 示例：

```python
px = api.read_render_target_raw_pixel(world, rt, 10, 10)
```

### read_render_target_raw_pixel_area

- C++ 签名：`TArray<FLinearColor> ReadRenderTargetRawPixelArea(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, int32 MinX, int32 MinY, int32 MaxX, int32 MaxY, bool bNormalize = true)`
- Python：`read_render_target_raw_pixel_area(world_context_object, texture_render_target, min_x, min_y, max_x, max_y, b_normalize=True) -> Array[LinearColor]`
- 说明：按整数像素矩形区域读取原始线性值数组。
- 示例：

```python
area = api.read_render_target_raw_pixel_area(world, rt, 0, 0, 64, 64)
```

### read_render_target_raw_uv

- C++ 签名：`FLinearColor ReadRenderTargetRawUV(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, float U, float V, bool bNormalize = true)`
- Python：`read_render_target_raw_uv(world_context_object, texture_render_target, u, v, b_normalize=True) -> LinearColor`
- 示例：

```python
px = api.read_render_target_raw_uv(world, rt, 0.5, 0.5)
```

### read_render_target_raw

- C++ 签名：`bool ReadRenderTargetRaw(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, TArray<FLinearColor>& OutLinearSamples, bool bNormalize = true)`
- Python：`read_render_target_raw(world_context_object, texture_render_target, b_normalize=True) -> (bool, Array[LinearColor])`
- 说明：整张目标按原始线性值读出，返回 `(成功否, 每像素线性取样)`。
- 示例：

```python
ok, linear_samples = api.read_render_target_raw(world, rt)
```

### read_render_target_raw_uv_area

- C++ 签名：`TArray<FLinearColor> ReadRenderTargetRawUVArea(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, FBox2D Area, bool bNormalize = true)`
- Python：`read_render_target_raw_uv_area(world_context_object, texture_render_target, area, b_normalize=True) -> Array[LinearColor]`
- 说明：按 UV 矩形区域（`unreal.Box2D`）读取原始线性值数组。
- 示例：

```python
region = unreal.Box2D(min=unreal.Vector2D(0.0, 0.0), max=unreal.Vector2D(0.5, 0.5))
area = api.read_render_target_raw_uv_area(world, rt, region)
```

## 导出与导入

### export_render_target

- C++ 签名：`void ExportRenderTarget(UObject* WorldContextObject, UTextureRenderTarget2D* TextureRenderTarget, const FString& FilePath, const FString& FileName)`
- Python：`export_render_target(world_context_object, texture_render_target, file_path, file_name) -> None`
- 说明：按渲染目标格式将目标导出为 HDR/PNG 图像到磁盘（文件名为带扩展名的目标文件名，如 `probe.png`）。
- 示例：

```python
api.export_render_target(world, rt, "E:/Exports", "probe.png")
```

### export_texture2_d

- C++ 签名：`void ExportTexture2D(UObject* WorldContextObject, UTexture2D* Texture, const FString& FilePath, const FString& FileName)`
- Python：`export_texture2_d(world_context_object, texture, file_path, file_name) -> None`
- 说明：将纹理导出为 HDR 图像到磁盘。
- 示例：

```python
api.export_texture2_d(world, texture, "E:/Exports", "shot.hdr")
```

### import_file_as_texture2_d

- C++ 签名：`UTexture2D* ImportFileAsTexture2D(UObject* WorldContextObject, const FString& Filename)`
- Python：`import_file_as_texture2_d(world_context_object, filename) -> Texture2D`
- 说明：从磁盘文件导入纹理并创建 `Texture2D`；文件无效/缺失返回 `None`。
- 示例：

```python
tex = api.import_file_as_texture2_d(world, "E:/Inputs/height.png")
if tex is None:
    print({"status": "BLOCKED_INPUT", "reason": "纹理文件不可读"})
```

### import_buffer_as_texture2_d

- C++ 签名：`UTexture2D* ImportBufferAsTexture2D(UObject* WorldContextObject, const TArray<uint8>& Buffer)`
- Python：`import_buffer_as_texture2_d(world_context_object, buffer) -> Texture2D`
- 说明：从字节缓冲创建纹理；数据无效返回 `None`。
- 示例：

```python
with open("E:/Inputs/mask.png", "rb") as f:
    data = f.read()
tex = api.import_buffer_as_texture2_d(world, data)
```

## Editor 静态纹理（Editor Only）

> 以下方法引擎注释明确仅在编辑器内有效；无编辑器上下文直接按 `BLOCKED_TOOLING` 处理。

### render_target_create_static_texture2_d_editor_only

- C++ 签名：`UTexture2D* RenderTargetCreateStaticTexture2DEditorOnly(UTextureRenderTarget2D* RenderTarget, FString Name = "Texture", enum TextureCompressionSettings CompressionSettings = TC_Default, enum TextureMipGenSettings MipSettings = TMGS_FromTextureGroup)`
- Python：`render_target_create_static_texture2_d_editor_only(render_target, name="Texture", compression_settings=unreal.TextureCompressionSettings.TC_DEFAULT, mip_settings=unreal.TextureMipGenSettings.TMGS_FROM_TEXTURE_GROUP) -> Texture2D`
- 示例：

```python
static_tex = api.render_target_create_static_texture2_d_editor_only(rt, "RT_Probe_Static")
```

### render_target_create_static_texture2_d_array_editor_only

- C++ 签名：`UTexture2DArray* RenderTargetCreateStaticTexture2DArrayEditorOnly(UTextureRenderTarget2DArray* RenderTarget, FString Name = "Texture", enum TextureCompressionSettings CompressionSettings = TC_Default, enum TextureMipGenSettings MipSettings = TMGS_FromTextureGroup)`
- Python：`render_target_create_static_texture2_d_array_editor_only(render_target, name=..., compression_settings=..., mip_settings=...) -> Texture2DArray`
- 示例：

```python
static_arr = api.render_target_create_static_texture2_d_array_editor_only(rt_arr, "RT_Array_Static")
```

### render_target_create_static_texture_cube_editor_only

- C++ 签名：`UTextureCube* RenderTargetCreateStaticTextureCubeEditorOnly(UTextureRenderTargetCube* RenderTarget, FString Name = "Texture", enum TextureCompressionSettings CompressionSettings = TC_Default, enum TextureMipGenSettings MipSettings = TMGS_FromTextureGroup)`
- Python：`render_target_create_static_texture_cube_editor_only(render_target, name=..., compression_settings=..., mip_settings=...) -> TextureCube`
- 示例：

```python
static_cube = api.render_target_create_static_texture_cube_editor_only(rt_cube, "RT_Cube_Static")
```

### render_target_create_static_volume_texture_editor_only

- C++ 签名：`UVolumeTexture* RenderTargetCreateStaticVolumeTextureEditorOnly(UTextureRenderTargetVolume* RenderTarget, FString Name = "Texture", enum TextureCompressionSettings CompressionSettings = TC_Default, enum TextureMipGenSettings MipSettings = TMGS_FromTextureGroup)`
- Python：`render_target_create_static_volume_texture_editor_only(render_target, name=..., compression_settings=..., mip_settings=...) -> VolumeTexture`
- 示例：

```python
static_vol = api.render_target_create_static_volume_texture_editor_only(rt_vol, "RT_Vol_Static")
```

## Editor 转换（Editor Only）

### convert_render_target_to_texture2_d_editor_only

- C++ 签名：`void ConvertRenderTargetToTexture2DEditorOnly(UObject* WorldContextObject, UTextureRenderTarget2D* RenderTarget, UTexture2D* Texture)`
- Python：`convert_render_target_to_texture2_d_editor_only(world_context_object, render_target, texture) -> None`
- 说明：将渲染目标内容复制到既有 `Texture2D` 资产。
- 示例：

```python
api.convert_render_target_to_texture2_d_editor_only(world, rt, target_texture)
```

### convert_render_target_to_texture2_d_array_editor_only

- C++ 签名：`void ConvertRenderTargetToTexture2DArrayEditorOnly(UObject* WorldContextObject, UTextureRenderTarget2DArray* RenderTarget, UTexture2DArray* Texture)`
- Python：`convert_render_target_to_texture2_d_array_editor_only(world_context_object, render_target, texture) -> None`

### convert_render_target_to_texture_cube_editor_only

- C++ 签名：`void ConvertRenderTargetToTextureCubeEditorOnly(UObject* WorldContextObject, UTextureRenderTargetCube* RenderTarget, UTextureCube* Texture)`
- Python：`convert_render_target_to_texture_cube_editor_only(world_context_object, render_target, texture) -> None`

### convert_render_target_to_texture_volume_editor_only

- C++ 签名：`void ConvertRenderTargetToTextureVolumeEditorOnly(UObject* WorldContextObject, UTextureRenderTargetVolume* RenderTarget, UVolumeTexture* Texture)`
- Python：`convert_render_target_to_texture_volume_editor_only(world_context_object, render_target, texture) -> None`

## 骨骼权重

### make_skin_weight_info

- C++ 签名：`FSkelMeshSkinWeightInfo MakeSkinWeightInfo(int32 Bone0, uint8 Weight0, int32 Bone1, uint8 Weight1, int32 Bone2, uint8 Weight2, int32 Bone3, uint8 Weight3)`（BlueprintPure）
- Python：`make_skin_weight_info(bone0, weight0, bone1, weight1, bone2, weight2, bone3, weight3) -> SkelMeshSkinWeightInfo`
- 说明：构造蒙皮权重信息结构。
- 示例：

```python
info = api.make_skin_weight_info(0, 255, 1, 128, -1, 0, -1, 0)
```

### break_skin_weight_info

- C++ 签名：`void BreakSkinWeightInfo(FSkelMeshSkinWeightInfo InWeight, int32& Bone0, uint8& Weight0, int32& Bone1, uint8& Weight1, int32& Bone2, uint8& Weight2, int32& Bone3, uint8& Weight3)`（BlueprintPure）
- Python：`break_skin_weight_info(in_weight) -> (int, int, int, int, int, int, int, int)`
- 说明：`void` + 8 个 Out，按声明顺序返回 `(Bone0, Weight0, Bone1, Weight1, Bone2, Weight2, Bone3, Weight3)`。
- 示例：

```python
b0, w0, b1, w1, b2, w2, b3, w3 = api.break_skin_weight_info(info)
```

## 阴影

### set_cast_inset_shadow_for_all_attachments

- C++ 签名：`void SetCastInsetShadowForAllAttachments(UPrimitiveComponent* PrimitiveComponent, bool bCastInsetShadow, bool bLightAttachmentsAsGroup)`
- Python：`set_cast_inset_shadow_for_all_attachments(primitive_component, b_cast_inset_shadow, b_light_attachments_as_group) -> None`
- 说明：设置组件及其全部子附件的内阴影投射状态。
- 示例：

```python
api.set_cast_inset_shadow_for_all_attachments(root_prim, True, True)
```

## 投影与路径追踪

### calculate_projection_matrix

- C++ 签名：`FMatrix CalculateProjectionMatrix(const FMinimalViewInfo& MinimalViewInfo)`（BlueprintPure，`ScriptMethod=\"CalculateProjectionMatrix\"`）
- Python：`calculate_projection_matrix(minimal_view_info) -> Matrix`
- 说明：按视角信息计算投影矩阵（不以 `bConstrainAspectRatio` 为准的宽高比计算）。
- 示例：

```python
view = unreal.MinimalViewInfo()
view.location = unreal.Vector(0.0, 0.0, 0.0)
view.rotation = unreal.Rotator(0.0, 0.0, 0.0)
view.fov = 90.0
view.aspect_ratio = 16.0 / 9.0
m = api.calculate_projection_matrix(view)
```

### enable_path_tracing

- C++ 签名：`void EnablePathTracing(bool bEnablePathTracer)`
- Python：`enable_path_tracing(b_enable_path_tracer) -> None`
- 说明：开启/关闭当前 Game Viewport 的路径追踪渲染（等价于设置 `ShowFlag.PathTracing`，且从 Shipping 构建也可访问）。
- 示例：

```python
api.enable_path_tracing(True)
```

### refresh_path_tracing_output

- C++ 签名：`void RefreshPathTracingOutput()`
- Python：`refresh_path_tracing_output() -> None`
- 说明：强制路径追踪重新开始采样累积（用于引擎无法自动探测场景变化的场合）。
- 示例：

```python
api.refresh_path_tracing_output()
```

## 管线缓存

### num_precompiling_psos_remaining

- C++ 签名：`int32 NumPrecompilingPSOsRemaining()`
- Python：`num_precompiling_psos_remaining() -> int`
- 说明：返回仍在运行的 PSO 预编译任务数量，可据此延长加载画面等待 GPU 管线缓存预热完成。
- 示例：

```python
remaining = api.num_precompiling_psos_remaining()
print("PSO tasks remaining:", remaining)
```

## 完整示例：Canvas 绘制、读取与导出渲染目标

```python
import unreal

def main():
    api = unreal.KismetRenderingLibrary
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    if world is None:
        print({"status": "BLOCKED_TOOLING", "reason": "编辑器世界不可用"})
        return

    rt = api.create_render_target2_d(world, width=512, height=512)
    if rt is None:
        print({"status": "BLOCKED_INPUT", "reason": "渲染目标创建失败"})
        return

    mat = unreal.load_asset("/Game/Materials/M_RT_Probe")
    if mat is None:
        print({"status": "BLOCKED_INPUT", "reason": "M_RT_Probe 材质缺失"})
        return
    api.draw_material_to_render_target(world, rt, mat)

    canvas, size, ctx = api.begin_draw_canvas_to_render_target(world, rt)
    try:
        # 调试线/文本等简单原语经 unreal.Canvas 绘制，此处以 pass 占位
        pass
    finally:
        api.end_draw_canvas_to_render_target(world, ctx)

    ok, samples = api.read_render_target(world, rt)
    if not ok:
        print({"status": "BLOCKED_TOOLING", "reason": "读取失败"})
        return

    api.export_render_target(world, rt, "E:/Exports", "probe.png")
    print({"status": "OK", "pixel_count": len(samples), "size": (size.x, size.y)})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺 `WorldContextObject`、RendererTarget、材质、导入/导出路径、类路径或其他必要输入；目标/资产不存在按同规则补全。
- `BLOCKED_TOOLING`：无可用 UE 5.6 编辑器/引擎渲染上下文，无法执行反射调用；Editor Only 方法在非编辑器上下文一律返回该状态。
- 渲染目标是运行时二进制资源：落盘静态纹理、转换与导出必须经 UE Editor 接口完成并由审计/QA 独立验收（遵守 `.uasset` 安全规范），禁止文本/字节补丁；未验证前不得声称完成。
- 绘制、渲染调试与视觉验证职责归 `ue-technical-art-engineer`；性能与读取开销评估归 `performance-profiler`；本文件只提供 Python 调用 API。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；标称方法与精确 Python 暴露名需实测确认（`dir(unreal.KismetRenderingLibrary)` / 反射核对）。