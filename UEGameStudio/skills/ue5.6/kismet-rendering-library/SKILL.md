---
name: kismet-rendering-library
description: UKismetRenderingLibrary（UE 5.6，unreal.KismetRenderingLibrary）渲染公共函数库 - RenderTarget 2D/Array/Volume 创建/清理/缩放/释放/导出/读取、Canvas 绘制（Begin/EndDrawCanvasToRenderTarget、DrawMaterialToRenderTarget）、编辑器静态纹理创建与转换、纹理导入导出、路径追踪开关、PSO 预编译查询；在 Agent 需要通过 unreal Python 操作渲染目标或渲染原语时使用
risk: safe
category: development
tags: [ue5.6, rendering, blueprint, python, library]
---

# KismetRenderingLibrary - Rendering Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 操作渲染目标或渲染原语时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-rendering-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetRenderingLibrary`（`UBlueprintFunctionLibrary` 派生）暴露给 Python 的渲染公共函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetRenderingLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.KismetRenderingLibrary` 上，直接以类名调用，无需实例。多数方法需要 `WorldContextObject` 参数：

```python
import unreal

api = unreal.KismetRenderingLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

rt = api.create_render_target2_d(world, width=512, height=512)
```

- **命名约定**：方法名优先取函数 `meta` 的脚本化名称（`ScriptName=`/`ScriptMethod=`）转 snake_case；无脚本化名称时按 C++ 函数名转 snake_case。本库多数成员无脚本化名称，按 C++ 函数名转 snake_case，数字字母统一转出 `2_d` / `2_d_array` 形式（如 `ClearRenderTarget2D` → `clear_render_target2_d`、`BeginDrawCanvasToRenderTarget` → `begin_draw_canvas_to_render_target`）。精确 Python 暴露名需实测确认。
- **类名**：取 C++ 类名去 `U` 前缀（本库 `unreal.KismetRenderingLibrary`），不采用类级 `ScriptName` 别名；实测时以 `dir(unreal)` / 反射结果为准。
- 渲染目标类型：`unreal.TextureRenderTarget2D` / `TextureRenderTarget2DArray` / `TextureRenderTargetVolume` / `TextureRenderTargetCube`，来自 `unreal.KismetRenderingLibrary` 创建接口或资产加载。
- 标记 Editor Only 的方法（静态纹理创建/转换）仅编辑器内可用。
- 绘制/调试职责归 `ue-technical-art-engineer` / `performance-profiler`；本 skill 只提供 Python 调用 API。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 目标清理 | `clear_render_target2_d(world_context_object, texture_render_target, clear_color=unreal.LinearColor(0,0,0,1))` | `void ClearRenderTarget2D(UObject*, UTextureRenderTarget2D*, FLinearColor)` | `None` |
| 目标创建 | `create_render_target2_d(world_context_object, width=256, height=256, format=..., clear_color=..., b_auto_generate_mip_maps=False, b_support_uavs=False)` | `UTextureRenderTarget2D* CreateRenderTarget2D(UObject*, int32, int32, ETextureRenderTargetFormat, FLinearColor, bool, bool)` | `TextureRenderTarget2D` |
| 目标创建 | `create_render_target2_d_array(world_context_object, width=256, height=256, slices=1, format=..., clear_color=..., b_auto_generate_mip_maps=False, b_support_uavs=False)` | `UTextureRenderTarget2DArray* CreateRenderTarget2DArray(UObject*, int32, int32, int32, ETextureRenderTargetFormat, FLinearColor, bool, bool)` | `TextureRenderTarget2DArray` |
| 目标创建 | `create_render_target_volume(world_context_object, width=16, height=16, depth=16, format=..., clear_color=..., b_auto_generate_mip_maps=False, b_support_uavs=False)` | `UTextureRenderTargetVolume* CreateRenderTargetVolume(UObject*, int32, int32, int32, ETextureRenderTargetFormat, FLinearColor, bool, bool)` | `TextureRenderTargetVolume` |
| 目标释放 | `release_render_target2_d(texture_render_target)` | `void ReleaseRenderTarget2D(UTextureRenderTarget2D*)` | `None` |
| 目标缩放 | `resize_render_target2_d(texture_render_target, width=256, height=256)` | `void ResizeRenderTarget2D(UTextureRenderTarget2D*, int32, int32)` | `None` |
| 材质绘制 | `draw_material_to_render_target(world_context_object, texture_render_target, material)` | `void DrawMaterialToRenderTarget(UObject*, UTextureRenderTarget2D*, UMaterialInterface*)` | `None` |
| Editor 静态纹理 | `render_target_create_static_texture2_d_editor_only(render_target, name=\"Texture\", compression_settings=..., mip_settings=...)` | `UTexture2D* RenderTargetCreateStaticTexture2DEditorOnly(UTextureRenderTarget2D*, FString, TextureCompressionSettings, TextureMipGenSettings)` | `Texture2D` |
| Editor 静态纹理 | `render_target_create_static_texture2_d_array_editor_only(render_target, name=\"Texture\", compression_settings=..., mip_settings=...)` | `UTexture2DArray* RenderTargetCreateStaticTexture2DArrayEditorOnly(UTextureRenderTarget2DArray*, FString, TextureCompressionSettings, TextureMipGenSettings)` | `Texture2DArray` |
| Editor 静态纹理 | `render_target_create_static_texture_cube_editor_only(render_target, name=\"Texture\", compression_settings=..., mip_settings=...)` | `UTextureCube* RenderTargetCreateStaticTextureCubeEditorOnly(UTextureRenderTargetCube*, FString, TextureCompressionSettings, TextureMipGenSettings)` | `TextureCube` |
| Editor 静态纹理 | `render_target_create_static_volume_texture_editor_only(render_target, name=\"Texture\", compression_settings=..., mip_settings=...)` | `UVolumeTexture* RenderTargetCreateStaticVolumeTextureEditorOnly(UTextureRenderTargetVolume*, FString, TextureCompressionSettings, TextureMipGenSettings)` | `VolumeTexture` |
| Editor 转换 | `convert_render_target_to_texture2_d_editor_only(world_context_object, render_target, texture)` | `void ConvertRenderTargetToTexture2DEditorOnly(UObject*, UTextureRenderTarget2D*, UTexture2D*)` | `None` |
| Editor 转换 | `convert_render_target_to_texture2_d_array_editor_only(world_context_object, render_target, texture)` | `void ConvertRenderTargetToTexture2DArrayEditorOnly(UObject*, UTextureRenderTarget2DArray*, UTexture2DArray*)` | `None` |
| Editor 转换 | `convert_render_target_to_texture_cube_editor_only(world_context_object, render_target, texture)` | `void ConvertRenderTargetToTextureCubeEditorOnly(UObject*, UTextureRenderTargetCube*, UTextureCube*)` | `None` |
| Editor 转换 | `convert_render_target_to_texture_volume_editor_only(world_context_object, render_target, texture)` | `void ConvertRenderTargetToTextureVolumeEditorOnly(UObject*, UTextureRenderTargetVolume*, UVolumeTexture*)` | `None` |
| 导出 | `export_render_target(world_context_object, texture_render_target, file_path, file_name)` | `void ExportRenderTarget(UObject*, UTextureRenderTarget2D*, const FString&, const FString&)` | `None` |
| 读取 | `read_render_target_pixel(world_context_object, texture_render_target, x, y)` | `FColor ReadRenderTargetPixel(UObject*, UTextureRenderTarget2D*, int32, int32)` | `Color` |
| 读取 | `read_render_target_uv(world_context_object, texture_render_target, u, v)` | `FColor ReadRenderTargetUV(UObject*, UTextureRenderTarget2D*, float, float)` | `Color` |
| 读取 | `read_render_target(world_context_object, texture_render_target, b_normalize=True)` | `bool ReadRenderTarget(UObject*, UTextureRenderTarget2D*, TArray<FColor>& OutSamples, bool)` | `(bool, Array[Color])` |
| 读取 | `read_render_target_raw_pixel(world_context_object, texture_render_target, x, y, b_normalize=True)` | `FLinearColor ReadRenderTargetRawPixel(UObject*, UTextureRenderTarget2D*, int32, int32, bool)` | `LinearColor` |
| 读取 | `read_render_target_raw_pixel_area(world_context_object, texture_render_target, min_x, min_y, max_x, max_y, b_normalize=True)` | `TArray<FLinearColor> ReadRenderTargetRawPixelArea(UObject*, UTextureRenderTarget2D*, int32, int32, int32, int32, bool)` | `Array[LinearColor]` |
| 读取 | `read_render_target_raw_uv(world_context_object, texture_render_target, u, v, b_normalize=True)` | `FLinearColor ReadRenderTargetRawUV(UObject*, UTextureRenderTarget2D*, float, float, bool)` | `LinearColor` |
| 读取 | `read_render_target_raw(world_context_object, texture_render_target, b_normalize=True)` | `bool ReadRenderTargetRaw(UObject*, UTextureRenderTarget2D*, TArray<FLinearColor>& OutLinearSamples, bool)` | `(bool, Array[LinearColor])` |
| 读取 | `read_render_target_raw_uv_area(world_context_object, texture_render_target, area, b_normalize=True)` | `TArray<FLinearColor> ReadRenderTargetRawUVArea(UObject*, UTextureRenderTarget2D*, FBox2D, bool)` | `Array[LinearColor]` |
| 纹理导出 | `export_texture2_d(world_context_object, texture, file_path, file_name)` | `void ExportTexture2D(UObject*, UTexture2D*, const FString&, const FString&)` | `None` |
| 纹理导入 | `import_file_as_texture2_d(world_context_object, filename)` | `UTexture2D* ImportFileAsTexture2D(UObject*, const FString&)` | `Texture2D` 或 `None` |
| 纹理导入 | `import_buffer_as_texture2_d(world_context_object, buffer)` | `UTexture2D* ImportBufferAsTexture2D(UObject*, const TArray<uint8>&)` | `Texture2D` 或 `None` |
| Canvas 绘制 | `begin_draw_canvas_to_render_target(world_context_object, texture_render_target)` | `void BeginDrawCanvasToRenderTarget(UObject*, UTextureRenderTarget2D*, UCanvas*& Canvas, FVector2D& Size, FDrawToRenderTargetContext& Context)` | `(Canvas, Vector2D, DrawToRenderTargetContext)` |
| Canvas 绘制 | `end_draw_canvas_to_render_target(world_context_object, context)` | `void EndDrawCanvasToRenderTarget(UObject*, const FDrawToRenderTargetContext&)` | `None` |
| 骨骼权重 | `make_skin_weight_info(bone0, weight0, bone1, weight1, bone2, weight2, bone3, weight3)` | `FSkelMeshSkinWeightInfo MakeSkinWeightInfo(int32, uint8, int32, uint8, int32, uint8, int32, uint8)` | `SkelMeshSkinWeightInfo` |
| 骨骼权重 | `break_skin_weight_info(in_weight)` | `void BreakSkinWeightInfo(FSkelMeshSkinWeightInfo, int32&, uint8&, int32&, uint8&, int32&, uint8&, int32&, uint8&)` | `(int, int, int, int, int, int, int, int)` |
| 阴影 | `set_cast_inset_shadow_for_all_attachments(primitive_component, b_cast_inset_shadow, b_light_attachments_as_group)` | `void SetCastInsetShadowForAllAttachments(UPrimitiveComponent*, bool, bool)` | `None` |
| 投影 | `calculate_projection_matrix(minimal_view_info)` | `FMatrix CalculateProjectionMatrix(const FMinimalViewInfo&)` | `Matrix` |
| 路径追踪 | `enable_path_tracing(b_enable_path_tracer)` | `void EnablePathTracing(bool)` | `None` |
| 路径追踪 | `refresh_path_tracing_output()` | `void RefreshPathTracingOutput()` | `None` |
| 管线缓存 | `num_precompiling_psos_remaining()` | `int32 NumPrecompilingPSOsRemaining()` | `int` |

## 示例

```python
import unreal

api = unreal.KismetRenderingLibrary
world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()

# 创建渲染目标并绘制材质
rt = api.create_render_target2_d(world, width=512, height=512)
material = unreal.load_asset("/Game/Materials/M_RT_Probe")
api.draw_material_to_render_target(world, rt, material)

# Canvas 绘制（Begin/End 必须成对）
canvas, size, ctx = api.begin_draw_canvas_to_render_target(world, rt)
try:
    # 通过 canvas 的绘制方法在此绘制原语
    pass
finally:
    api.end_draw_canvas_to_render_target(world, ctx)

# 读取与导出
ok, samples = api.read_render_target(world, rt)
api.export_render_target(world, rt, "E:/Exports", "probe.png")
```

## 限制和注意事项

- `begin_draw_canvas_to_render_target` 返回 `(Canvas, Size, Context)` 三元组；`Context` 必须原样回传给成对的 `end_draw_canvas_to_render_target`，未成对闭合会造成渲染目标状态悬空。
- 单象限快速填满用 `draw_material_to_render_target`；一次绘制多个原语到同一目标用 Begin/End Canvas 成对流程（引擎注释明确前者每次重新设置渲染目标，开销更高）。
- 读取类方法引擎注释标记为"极低效慢操作"：`read_render_target*` 全家逐像素回读，避免全图逐帧读取；性能敏感路径归 `performance-profiler` 评估。
- Editor Only 方法（静态纹理创建/转换）只在编辑器内有效；无编辑器上下文按 `BLOCKED_TOOLING` 处理。
- `.uasset` 安全：RenderTarget 是运行时二进制资源，任何静态纹理落盘修改必须经 UE Editor 接口完成，禁止文本/字节补丁；编辑器或 DCC 不可用时返回 `BLOCKED_TOOLING`。
- 绘制、渲染调试与视觉验证职责归 `ue-technical-art-engineer`；性能分析归 `performance-profiler`；本 skill 只提供 Python 调用 API。
- 缺 RenderTarget、材质、路径、类路径等必要输入按 `BLOCKED_INPUT`；无编辑器/引擎上下文按 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言；`dir(unreal.KismetRenderingLibrary)` 实测命名后再落脚本。

详细逐方法 API 与完整示例见 `docs/overview.md`。