# UPhysicsAssetEditorSubsystem API 参考（UE 5.6）

本页列出 `UPhysicsAssetEditorSubsystem` 的完整 Python 方法映射表，按功能分组。

## 物理资产选择与管理（Physics Asset Selection & Management）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_selected_physics_assets()` | `TArray<UPhysicsAsset*> GetSelectedPhysicsAssets()` | `Array[PhysicsAsset]` |
| `is_physics_asset_selected(physics_asset)` | `bool IsPhysicsAssetSelected(UPhysicsAsset*)` | `bool` |
| `select_physics_assets(physics_assets, b_deselect_others)` | `void SelectPhysicsAssets(const TArray<UPhysicsAsset*>&, bool)` | `None` |
| `deselect_all_physics_assets()` | `void DeselectAllPhysicsAssets()` | `None` |
| `get_physics_asset_from_actor(actor)` | `UPhysicsAsset* GetPhysicsAssetFromActor(AActor*)` | `PhysicsAsset` 或 `None` |
| `get_physics_asset_from_skeletal_mesh(skeletal_mesh)` | `UPhysicsAsset* GetPhysicsAssetFromSkeletalMesh(USkeletalMesh*)` | `PhysicsAsset` 或 `None` |
| `create_new_physics_asset()` | `UPhysicsAsset* CreateNewPhysicsAsset()` | `PhysicsAsset` |
| `load_physics_asset(asset_path)` | `UPhysicsAsset* LoadPhysicsAsset(const FString&)` | `PhysicsAsset` 或 `None` |
| `save_physics_asset(physics_asset, b_prompt_for_save_as)` | `bool SavePhysicsAsset(UPhysicsAsset*, bool)` | `bool` |
| `delete_physics_asset(physics_asset)` | `bool DeletePhysicsAsset(UPhysicsAsset*)` | `bool` |

## 碰撞体管理（Collision Body Management）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_rigid_collisions_count(physics_asset)` | `int GetRigidCollisionsCount(UPhysicsAsset*)` | `int` |
| `get_rigid_collision(physics_asset, index)` | `UPhysicsAssetCollision* GetRigidCollision(UPhysicsAsset*, int)` | `PhysicsAssetCollision` |
| `add_rigid_collision(physics_asset)` | `UPhysicsAssetCollision* AddRigidCollision(UPhysicsAsset*)` | `PhysicsAssetCollision` |
| `remove_rigid_collision(physics_asset, index)` | `bool RemoveRigidCollision(UPhysicsAsset*, int)` | `bool` |
| `move_rigid_collision(physics_asset, from_index, to_index)` | `bool MoveRigidCollision(UPhysicsAsset*, int, int)` | `bool` |
| `duplicate_rigid_collision(physics_asset, index)` | `UPhysicsAssetCollision* DuplicateRigidCollision(UPhysicsAsset*, int)` | `PhysicsAssetCollision` |
| `get_all_rigid_collisions(physics_asset)` | `TArray<UPhysicsAssetCollision*> GetAllRigidCollisions(UPhysicsAsset*)` | `Array[PhysicsAssetCollision]` |

## 约束设置（Constraint Setup）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_constraints_count(physics_asset)` | `int GetConstraintsCount(UPhysicsAsset*)` | `int` |
| `get_constraint(physics_asset, index)` | `UPhysicsConstraint* GetConstraint(UPhysicsAsset*, int)` | `UPhysicsConstraint` |
| `add_constraint(physics_asset)` | `UPhysicsConstraint* AddConstraint(UPhysicsAsset*)` | `UPhysicsConstraint` |
| `remove_constraint(physics_asset, index)` | `bool RemoveConstraint(UPhysicsAsset*, int)` | `bool` |
| `move_constraint(physics_asset, from_index, to_index)` | `bool MoveConstraint(UPhysicsAsset*, int, int)` | `bool` |
| `duplicate_constraint(physics_asset, index)` | `UPhysicsConstraint* DuplicateConstraint(UPhysicsAsset*, int)` | `UPhysicsConstraint` |
| `get_all_constraints(physics_asset)` | `TArray<UPhysicsConstraint*> GetAllConstraints(UPhysicsAsset*)` | `Array[UPhysicsConstraint]` |

## 骨骼绑定（Bone Binding）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_bone_bodies_count(physics_asset)` | `int GetBoneBodiesCount(UPhysicsAsset*)` | `int` |
| `get_bone_body(physics_asset, index)` | `UPhysicsAssetBody* GetBoneBody(UPhysicsAsset*, int)` | `UPhysicsAssetBody` |
| `get_bone_body_by_name(physics_asset, bone_name)` | `UPhysicsAssetBody* GetBoneBodyByName(UPhysicsAsset*, const FString&)` | `UPhysicsAssetBody` |
| `add_bone_body(physics_asset, bone_name)` | `UPhysicsAssetBody* AddBoneBody(UPhysicsAsset*, const FString&)` | `UPhysicsAssetBody` |
| `remove_bone_body(physics_asset, index)` | `bool RemoveBoneBody(UPhysicsAsset*, int)` | `bool` |
| `get_all_bone_bodies(physics_asset)` | `TArray<UPhysicsAssetBody*> GetAllBoneBodies(UPhysicsAsset*)` | `Array[UPhysicsAssetBody]` |

## 模拟控制（Simulation Control）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `enable_simulation(physics_asset)` | `void EnableSimulation(UPhysicsAsset*)` | `None` |
| `disable_simulation(physics_asset)` | `void DisableSimulation(UPhysicsAsset*)` | `None` |
| `is_simulation_enabled(physics_asset)` | `bool IsSimulationEnabled(UPhysicsAsset*)` | `bool` |
| `reset_simulation(physics_asset)` | `void ResetSimulation(UPhysicsAsset*)` | `None` |

## 辅助（Misc）

| Python 方法名 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_skeletal_mesh_from_physics_asset(physics_asset)` | `USkeletalMesh* GetSkeletalMeshFromPhysicsAsset(UPhysicsAsset*)` | `SkeletalMesh` |
| `get_all_physics_assets()` | `TArray<UPhysicsAsset*> GetAllPhysicsAssets()` | `Array[PhysicsAsset]` |
| `is_valid_physics_asset(physics_asset)` | `bool IsValidPhysicsAsset(UPhysicsAsset*)` | `bool` |
| `get_physics_asset_path(physics_asset)` | `FString GetPhysicsAssetPath(UPhysicsAsset*)` | `str` |
