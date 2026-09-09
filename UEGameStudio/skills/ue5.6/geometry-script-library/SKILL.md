---
name: geometry-script-library
description: UGeometryScriptLibrary（UE 5.6）几何脚本函数库 - 网格布尔/采样/变形/优化；在 Agent 需要通过 unreal Python 对静态网格或动态网格做几何处理时使用
tags: [ue5.6, geometry, mesh, python, blueprint-function-library]
---

# GeometryScriptLibrary - 几何处理工具库（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UGeometryScriptLibrary`（`UBlueprintFunctionLibrary` 派生）通过 Python 可调用的静态函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/GeometryScripting/GeometryScriptLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UBlueprintFunctionLibrary` 的 static 函数在 Python 中以类方法形式暴露在 `unreal.GeometryScriptLibrary` 上：

```python
import unreal

# 示例：对网格做布尔运算
mesh_asset = unreal.load_asset("/Game/Meshes/StaticMesh")
unreal.GeometryScriptLibrary.mesh_boolean(...)
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.GeometryScriptLibrary)` 核对）。
- 几何处理方法通常需要 `UGeometryScript_Target` 对象（如 `UGeometryScript_Mesh`、`UGeometryScript_LevelSet`、`UGeometryScript_SDF`）。
- 大多数方法仅编辑器 Python 可用（`WITH_EDITOR`），运行时调用会失败。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **布尔运算** | | | |
| 布尔 | `mesh_boolean(mesh_target, mesh_a, mesh_b, boolean_operation, b_optimize_result, b_single_body_mode)` | `bool MeshBoolean(...)` | `bool` |
| 布尔 | `mesh_boolean_with_transforms(mesh_target, mesh_a, mesh_b, transform_a, transform_b, boolean_operation, b_optimize_result, b_single_body_mode)` | `bool MeshBooleanWithTransforms(...)` | `bool` |
| 布尔 | `level_set_to_mesh(level_set_source, mesh_target, b_optimize_result)` | `bool LevelSetToMesh(...)` | `bool` |
| 布尔 | `mesh_to_level_set(mesh_source, level_set_target, transform, b_auto_open_boundary)` | `bool MeshToLevelSet(...)` | `bool` |
| **采样与查询** | | | |
| 采样 | `sample_mesh_closest_point(mesh, position, b_only_closest_triangles)` | `FGeometryScriptSampleResult SampleMeshClosestPoint(...)` | `SampleResult` |
| 采样 | `sample_mesh_random_point(mesh, out_position, out_normal, out_uv)` | `bool SampleMeshRandomPoint(...)` | `bool` |
| 查询 | `mesh_point_distance(mesh, position)` | `float MeshPointDistance(...)` | `float` |
| 查询 | `mesh_point_side(mesh, position)` | `ETriangleSide MeshPointSide(...)` | `int` |
| 查询 | `mesh_triangle_contains_point(mesh, triangle_id, point)` | `bool MeshTriangleContainsPoint(...)` | `bool` |
| **几何操作** | | | |
| 变形 | `mesh_deform_basic(mesh, transform, b_affect_uvs, b_affect_normals)` | `bool MeshDeformBasic(...)` | `bool` |
| 变形 | `mesh_flatten(mesh, plane_world_origin, plane_world_normal, strength, b_affect_uvs)` | `bool MeshFlatten(...)` | `bool` |
| 变形 | `mesh_planar_project(mesh, plane_origin, plane_normal, plane_up, uv_channel)` | `bool MeshPlanarProject(...)` | `bool` |
| 变形 | `mesh_planar_project_spherically(mesh, sphere_center, sphere_radius, uv_channel)` | `bool MeshPlanarProjectSpherically(...)` | `bool` |
| **优化与清理** | | | |
| 清理 | `mesh_remove_degenerate_triangles(mesh, b_remove_zero_area_triangles, b_remove_zero_length_edges)` | `bool MeshRemoveDegenerateTriangles(...)` | `bool` |
| 清理 | `mesh_remove_duplicate_triangles(mesh)` | `bool MeshRemoveDuplicateTriangles(...)` | `bool` |
| 清理 | `mesh_remove_unused_vertices(mesh)` | `bool MeshRemoveUnusedVertices(...)` | `bool` |
| 优化 | `mesh_optimize(mesh, b_optimize_vertices, b_optimize_triangles, b_collapse_edges)` | `bool MeshOptimize(...)` | `bool` |
| 优化 | `mesh_reorder_triangles(mesh, b_minimize_triangle_changes, b_minimize_vertex_cache)` | `bool MeshReorderTriangles(...)` | `bool` |
| **拓扑操作** | | | |
| 分割 | `mesh_split_disjoint_meshes(mesh_source, out_meshes)` | `bool MeshSplitDisjointMeshes(...)` | `bool` |
| 分割 | `mesh_split_by_material(mesh_source, out_meshes)` | `bool MeshSplitByMaterial(...)` | `bool` |
| 组合 | `mesh_combine(mesh_targets, mesh_output, b_compute_material_ids)` | `bool MeshCombine(...)` | `bool` |
| **法线与UV** | | | |
| 法线 | `mesh_compute_normals(mesh, b_smooth_normals, b_weight_by_angle)` | `bool MeshComputeNormals(...)` | `bool` |
| 法线 | `mesh_compute_tangents(mesh, b_compute_tangents)` | `bool MeshComputeTangents(...)` | `bool` |
| UV | `mesh_recompute_uv(mesh, uv_channel, b_recompute_u, b_recompute_v, b_auto_generate)` | `bool MeshRecomputeUV(...)` | `bool` |
| UV | `mesh_pack_uvs(mesh, max_texture_size, b_pack_by_material)` | `bool MeshPackUVs(...)` | `bool` |
| **体素与网格转换** | | | |
| 体素化 | `mesh_to_volume(mesh, volume_target, transform, voxel_extent, b_fill_interior)` | `bool MeshToVolume(...)` | `bool` |
| 体素化 | `volume_to_mesh(volume_source, mesh_target, iso_value, b_optimize_mesh)` | `bool VolumeToMesh(...)` | `bool` |
| **其他** | | | |
| 边界 | `mesh_compute_bounds(mesh)` | `FBoxSphereBounds MeshComputeBounds(...)` | `BoxSphereBounds` |
| 边界 | `mesh_get_triangle_bounds(mesh, triangle_id)` | `FBoxSphereBounds MeshGetTriangleBounds(...)` | `BoxSphereBounds` |
| 三角形 | `mesh_get_triangle_vertices(mesh, triangle_id)` | `FGeometryScriptTriangle MeshGetTriangleVertices(...)` | `Triangle` |
| 三角形 | `mesh_get_triangle_centers(mesh)` | `TArray<FVector> MeshGetTriangleCenters(...)` | `Array[Vector]` |
| 三角形 | `mesh_get_triangle_area(mesh, triangle_id)` | `float MeshGetTriangleArea(...)` | `float` |
| 三角形 | `mesh_get_total_area(mesh)` | `float MeshGetTotalArea(...)` | `float` |
| 计数 | `mesh_get_num_vertices(mesh)` | `int MeshGetNumVertices(...)` | `int` |
| 计数 | `mesh_get_num_triangles(mesh)` | `int MeshGetNumTriangles(...)` | `int` |
| 计数 | `mesh_get_num.edges(mesh)` | `int MeshGetNumEdges(...)` | `int` |

## 快速示例

```python
import unreal

def process_mesh():
    mesh_asset = unreal.load_asset("/Game/Meshes/BP_StaticMesh")
    if mesh_asset is None:
        print("BLOCKED_INPUT: mesh asset not loadable")
        return

    api = unreal.GeometryScriptLibrary
    
    # 创建目标网格
    mesh_target = unreal.GeometryScript_Mesh()
    
    # 执行网格布尔差集
    mesh_a = unreal.load_asset("/Game/Meshes/Box")
    mesh_b = unreal.load_asset("/Game/Meshes/Cylinder")
    
    ok = api.mesh_boolean(
        mesh_target,
        mesh_a, mesh_b,
        unreal.EGeometryScriptBooleanOperation.DIFFERENCE,
        True, False
    )
    if ok:
        print({"status": "OK", "result": "mesh_boolean completed"})

if __name__ == "__main__":
    process_mesh()
```

## 注意事项

- 大多数几何处理方法仅编辑器 Python 可用（`WITH_EDITOR`），运行时调用会失败，应输出 `BLOCKED_TOOLING`。
- 处理后的网格需通过 `unreal.EditorStaticMeshLibrary` 或类似 API 保存到 `.uasset` 资产；直接修改内存对象不会持久化。
- 几何处理通常较耗时，大数据集建议分批处理并监控 Editor 性能。
- `MeshBoolean` 的 `b_single_body_mode` 适用于单体网格（无多个分离子网格）场景，开启可提升速度。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- 缺目标网格/输入网格等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
