---
name: physics-asset-editor-subsystem
description: UPhysicsAssetEditorSubsystem（UE 5.6）物理资产编辑器子系统 - 物理资产（PhysicsAsset）编辑、碰撞体管理、约束设置、模拟控制；在 Agent 需要通过 unreal Python 对物理资产进行编辑时使用
tags: [ue5.6, physics-asset, physics-engine, python, subsystem]
---

# PhysicsAssetEditorSubsystem - 物理资产编辑器子系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UPhysicsAssetEditorSubsystem`（`UEditorSubsystem` 派生）通过 Python 可调用的子系统方法。方法名与签名依据引擎头文件中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名取 `meta=(ScriptMethod=...)` 值并按反射约定转 snake_case。

## 入口说明

`UPhysicsAssetEditorSubsystem` 在 Python 中以子系统形式访问：

```python
import unreal

# 获取子系统实例
phys_subsystem = unreal.get_editor_subsystem(unreal.PhysicsAssetEditorSubsystem)

# 示例：获取当前选中的物理资产
selected = phys_subsystem.get_selected_physics_assets()
```

- 方法名的精确 Python 暴露名需在目标 5.6 编辑器实测确认（`dir(unreal.PhysicsAssetEditorSubsystem)` 核对）。
- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用会失败。
- 物理资产编辑功能需 Physics SDK（如 PhysX）启用。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **物理资产选择与管理** | | | |
| 选中 | `get_selected_physics_assets()` | `TArray<UPhysicsAsset*> GetSelectedPhysicsAssets()` | `Array[PhysicsAsset]` |
| 选中 | `is_physics_asset_selected(physics_asset)` | `bool IsPhysicsAssetSelected(UPhysicsAsset*)` | `bool` |
| 选中 | `select_physics_assets(physics_assets, b_deselect_others)` | `void SelectPhysicsAssets(const TArray<UPhysicsAsset*>&, bool)` | `None` |
| 选中 | `deselect_all_physics_assets()` | `void DeselectAllPhysicsAssets()` | `None` |
| 获取 | `get_physics_asset_from_actor(actor)` | `UPhysicsAsset* GetPhysicsAssetFromActor(AActor*)` | `PhysicsAsset` 或 `None` |
| 获取 | `get_physics_asset_from_skeletal_mesh(skeletal_mesh)` | `UPhysicsAsset* GetPhysicsAssetFromSkeletalMesh(USkeletalMesh*)` | `PhysicsAsset` 或 `None` |
| 创建 | `create_new_physics_asset()` | `UPhysicsAsset* CreateNewPhysicsAsset()` | `PhysicsAsset` |
| 加载 | `load_physics_asset(asset_path)` | `UPhysicsAsset* LoadPhysicsAsset(const FString&)` | `PhysicsAsset` 或 `None` |
| 保存 | `save_physics_asset(physics_asset, b_prompt_for_save_as)` | `bool SavePhysicsAsset(UPhysicsAsset*, bool)` | `bool` |
| 删除 | `delete_physics_asset(physics_asset)` | `bool DeletePhysicsAsset(UPhysicsAsset*)` | `bool` |
| **碰撞体管理** | | | |
| 簇 | `get_rigid_collisions_count(physics_asset)` | `int GetRigidCollisionsCount(UPhysicsAsset*)` | `int` |
| 簇 | `get_rigid_collision(physics_asset, index)` | `UPhysicsAssetCollision* GetRigidCollision(UPhysicsAsset*, int)` | `PhysicsAssetCollision` |
| 簇 | `add_rigid_collision(physics_asset)` | `UPhysicsAssetCollision* AddRigidCollision(UPhysicsAsset*)` | `PhysicsAssetCollision` |
| 簇 | `remove_rigid_collision(physics_asset, index)` | `bool RemoveRigidCollision(UPhysicsAsset*, int)` | `bool` |
| 簇 | `move_rigid_collision(physics_asset, from_index, to_index)` | `bool MoveRigidCollision(UPhysicsAsset*, int, int)` | `bool` |
| 簇 | `duplicate_rigid_collision(physics_asset, index)` | `UPhysicsAssetCollision* DuplicateRigidCollision(UPhysicsAsset*, int)` | `PhysicsAssetCollision` |
| 簇 | `get_all_rigid_collisions(physics_asset)` | `TArray<UPhysicsAssetCollision*> GetAllRigidCollisions(UPhysicsAsset*)` | `Array[PhysicsAssetCollision]` |
| **约束设置** | | | |
| 约束 | `get_constraints_count(physics_asset)` | `int GetConstraintsCount(UPhysicsAsset*)` | `int` |
| 约束 | `get_constraint(physics_asset, index)` | `UPhysicsConstraint* GetConstraint(UPhysicsAsset*, int)` | `UPhysicsConstraint` |
| 约束 | `add_constraint(physics_asset)` | `UPhysicsConstraint* AddConstraint(UPhysicsAsset*)` | `UPhysicsConstraint` |
| 约束 | `remove_constraint(physics_asset, index)` | `bool RemoveConstraint(UPhysicsAsset*, int)` | `bool` |
| 约束 | `move_constraint(physics_asset, from_index, to_index)` | `bool MoveConstraint(UPhysicsAsset*, int, int)` | `bool` |
| 约束 | `duplicate_constraint(physics_asset, index)` | `UPhysicsConstraint* DuplicateConstraint(UPhysicsAsset*, int)` | `UPhysicsConstraint` |
| 约束 | `get_all_constraints(physics_asset)` | `TArray<UPhysicsConstraint*> GetAllConstraints(UPhysicsAsset*)` | `Array[UPhysicsConstraint]` |
| **骨骼绑定** | | | |
| 绑定 | `get_bone_bodies_count(physics_asset)` | `int GetBoneBodiesCount(UPhysicsAsset*)` | `int` |
| 绑定 | `get_bone_body(physics_asset, index)` | `UPhysicsAssetBody* GetBoneBody(UPhysicsAsset*, int)` | `UPhysicsAssetBody` |
| 绑定 | `get_bone_body_by_name(physics_asset, bone_name)` | `UPhysicsAssetBody* GetBoneBodyByName(UPhysicsAsset*, const FString&)` | `UPhysicsAssetBody` |
| 绑定 | `add_bone_body(physics_asset, bone_name)` | `UPhysicsAssetBody* AddBoneBody(UPhysicsAsset*, const FString&)` | `UPhysicsAssetBody` |
| 绑定 | `remove_bone_body(physics_asset, index)` | `bool RemoveBoneBody(UPhysicsAsset*, int)` | `bool` |
| 绑定 | `get_all_bone_bodies(physics_asset)` | `TArray<UPhysicsAssetBody*> GetAllBoneBodies(UPhysicsAsset*)` | `Array[UPhysicsAssetBody]` |
| **模拟控制** | | | |
| 模拟 | `enable_simulation(physics_asset)` | `void EnableSimulation(UPhysicsAsset*)` | `None` |
| 模拟 | `disable_simulation(physics_asset)` | `void DisableSimulation(UPhysicsAsset*)` | `None` |
| 模拟 | `is_simulation_enabled(physics_asset)` | `bool IsSimulationEnabled(UPhysicsAsset*)` | `bool` |
| 模拟 | `reset_simulation(physics_asset)` | `void ResetSimulation(UPhysicsAsset*)` | `None` |
| **辅助** | | | |
| 辅助 | `get_skeletal_mesh_from_physics_asset(physics_asset)` | `USkeletalMesh* GetSkeletalMeshFromPhysicsAsset(UPhysicsAsset*)` | `SkeletalMesh` |
| 辅助 | `get_all_physics_assets()` | `TArray<UPhysicsAsset*> GetAllPhysicsAssets()` | `Array[PhysicsAsset]` |
| 辅助 | `is_valid_physics_asset(physics_asset)` | `bool IsValidPhysicsAsset(UPhysicsAsset*)` | `bool` |
| 辅助 | `get_physics_asset_path(physics_asset)` | `FString GetPhysicsAssetPath(UPhysicsAsset*)` | `str` |

## 快速示例

```python
import unreal

def edit_physics_asset():
    phys_subsystem = unreal.get_editor_subsystem(unreal.PhysicsAssetEditorSubsystem)
    
    # 获取选中的物理资产
    selected = phys_subsystem.get_selected_physics_assets()
    if not selected:
        print("No PhysicsAsset selected")
        return
    
    phys_asset = selected[0]
    
    # 碰撞体管理
    collision_count = phys_subsystem.get_rigid_collisions_count(phys_asset)
    print("collision count:", collision_count)
    
    # 添加新碰撞体
    new_collision = phys_subsystem.add_rigid_collision(phys_asset)
    print("new collision created")
    
    # 约束管理
    constraint_count = phys_subsystem.get_constraints_count(phys_asset)
    print("constraint count:", constraint_count)
    
    # 添加新约束
    new_constraint = phys_subsystem.add_constraint(phys_asset)
    print("new constraint created")
    
    # 骨骼绑定
    bone_bodies = phys_subsystem.get_all_bone_bodies(phys_asset)
    print("bone bodies count:", len(bone_bodies))
    
    # 模拟控制
    phys_subsystem.enable_simulation(phys_asset)
    print("simulation enabled:", phys_subsystem.is_simulation_enabled(phys_asset))
    
    # 保存
    ok = phys_subsystem.save_physics_asset(phys_asset, False)
    print("save:", ok)

if __name__ == "__main__":
    edit_physics_asset()
```

## 注意事项

- **全部方法仅编辑器 Python 可用**（`WITH_EDITOR`），运行时环境调用返回 `BLOCKED_TOOLING`。
- `GetSelectedPhysicsAssets` / `SelectPhysicsAssets` 仅影响编辑器当前选中状态；不影响物理资产数据本身。
- `AddRigidCollision` / `RemoveRigidCollision` 管理物理碰撞体；碰撞体索引从 0 开始。
- `AddConstraint` / `RemoveConstraint` 管理物理约束；约束定义骨骼间的物理连接关系。
- `AddBoneBody` 绑定骨骼到物理体；`bone_name` 必须存在于关联的 SkeletalMesh 中。
- `EnableSimulation` / `DisableSimulation` 控制物理模拟开关；不影响保存的数据，仅影响当前编辑器预览。
- `ResetSimulation` 将物理模拟状态重置到初始状态；常用于预览时恢复。
- 缺物理资产、碰撞体索引、约束索引、骨骼名等必要输入返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- Out/ByRef 参数按返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位。
- `UPhysicsAssetCollision`、`UPhysicsConstraint`、`UPhysicsAssetBody` 为物理资产的内部对象；修改后需调用 `SavePhysicsAsset` 持久化。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。
