# UGeometryScriptLibrary API 参考（UE 5.6）

本页列出 `UGeometryScriptLibrary` 的完整 Python 方法映射表，按功能分组。

## 布尔运算（Boolean Operations）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_boolean(mesh_target, mesh_a, mesh_b, boolean_operation, b_optimize_result, b_single_body_mode)` | `bool MeshBoolean(...)` | `bool` |
| `mesh_boolean_with_transforms(mesh_target, mesh_a, mesh_b, transform_a, transform_b, boolean_operation, b_optimize_result, b_single_body_mode)` | `bool MeshBooleanWithTransforms(...)` | `bool` |
| `level_set_to_mesh(level_set_source, mesh_target, b_optimize_result)` | `bool LevelSetToMesh(...)` | `bool` |
| `mesh_to_level_set(mesh_source, level_set_target, transform, b_auto_open_boundary)` | `bool MeshToLevelSet(...)` | `bool` |

## 采样与查询（Sampling & Query）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `sample_mesh_closest_point(mesh, position, b_only_closest_triangles)` | `FGeometryScriptSampleResult SampleMeshClosestPoint(...)` | `SampleResult` |
| `sample_mesh_random_point(mesh, out_position, out_normal, out_uv)` | `bool SampleMeshRandomPoint(...)` | `bool` |
| `mesh_point_distance(mesh, position)` | `float MeshPointDistance(...)` | `float` |
| `mesh_point_side(mesh, position)` | `ETriangleSide MeshPointSide(...)` | `int` |
| `mesh_triangle_contains_point(mesh, triangle_id, point)` | `bool MeshTriangleContainsPoint(...)` | `bool` |

## 几何操作（Geometry Operations）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_deform_basic(mesh, transform, b_affect_uvs, b_affect_normals)` | `bool MeshDeformBasic(...)` | `bool` |
| `mesh_flatten(mesh, plane_world_origin, plane_world_normal, strength, b_affect_uvs)` | `bool MeshFlatten(...)` | `bool` |
| `mesh_planar_project(mesh, plane_origin, plane_normal, plane_up, uv_channel)` | `bool MeshPlanarProject(...)` | `bool` |
| `mesh_planar_project_spherically(mesh, sphere_center, sphere_radius, uv_channel)` | `bool MeshPlanarProjectSpherically(...)` | `bool` |

## 优化与清理（Optimization & Cleanup）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_remove_degenerate_triangles(mesh, b_remove_zero_area_triangles, b_remove_zero_length_edges)` | `bool MeshRemoveDegenerateTriangles(...)` | `bool` |
| `mesh_remove_duplicate_triangles(mesh)` | `bool MeshRemoveDuplicateTriangles(...)` | `bool` |
| `mesh_remove_unused_vertices(mesh)` | `bool MeshRemoveUnusedVertices(...)` | `bool` |
| `mesh_optimize(mesh, b_optimize_vertices, b_optimize_triangles, b_collapse_edges)` | `bool MeshOptimize(...)` | `bool` |
| `mesh_reorder_triangles(mesh, b_minimize_triangle_changes, b_minimize_vertex_cache)` | `bool MeshReorderTriangles(...)` | `bool` |

## 拓扑操作（Topology Operations）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_split_disjoint_meshes(mesh_source, out_meshes)` | `bool MeshSplitDisjointMeshes(...)` | `bool` |
| `mesh_split_by_material(mesh_source, out_meshes)` | `bool MeshSplitByMaterial(...)` | `bool` |
| `mesh_combine(mesh_targets, mesh_output, b_compute_material_ids)` | `bool MeshCombine(...)` | `bool` |

## 法线与UV（Normals & UVs）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_compute_normals(mesh, b_smooth_normals, b_weight_by_angle)` | `bool MeshComputeNormals(...)` | `bool` |
| `mesh_compute_tangents(mesh, b_compute_tangents)` | `bool MeshComputeTangents(...)` | `bool` |
| `mesh_recompute_uv(mesh, uv_channel, b_recompute_u, b_recompute_v, b_auto_generate)` | `bool MeshRecomputeUV(...)` | `bool` |
| `mesh_pack_uvs(mesh, max_texture_size, b_pack_by_material)` | `bool MeshPackUVs(...)` | `bool` |

## 体素与网格转换（Voxel & Mesh Conversion）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_to_volume(mesh, volume_target, transform, voxel_extent, b_fill_interior)` | `bool MeshToVolume(...)` | `bool` |
| `volume_to_mesh(volume_source, mesh_target, iso_value, b_optimize_mesh)` | `bool VolumeToMesh(...)` | `bool` |

## 其他（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `mesh_compute_bounds(mesh)` | `FBoxSphereBounds MeshComputeBounds(...)` | `BoxSphereBounds` |
| `mesh_get_triangle_bounds(mesh, triangle_id)` | `FBoxSphereBounds MeshGetTriangleBounds(...)` | `BoxSphereBounds` |
| `mesh_get_triangle_vertices(mesh, triangle_id)` | `FGeometryScriptTriangle MeshGetTriangleVertices(...)` | `Triangle` |
| `mesh_get_triangle_centers(mesh)` | `TArray<FVector> MeshGetTriangleCenters(...)` | `Array[Vector]` |
| `mesh_get_triangle_area(mesh, triangle_id)` | `float MeshGetTriangleArea(...)` | `float` |
| `mesh_get_total_area(mesh)` | `float MeshGetTotalArea(...)` | `float` |
| `mesh_get_num_vertices(mesh)` | `int MeshGetNumVertices(...)` | `int` |
| `mesh_get_num_triangles(mesh)` | `int MeshGetNumTriangles(...)` | `int` |
| `mesh_get_num_edges(mesh)` | `int MeshGetNumEdges(...)` | `int` |
