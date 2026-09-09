# AnimationBlueprintLibrary - 概述（UE 5.6）

## 库功能概述

`UAnimationBlueprintLibrary` 是 UE 5.6 中专门用于骨骼网格体与动画系统高级操作的蓝图函数库。该库提供了骨骼分析、IK（反向运动学）计算、动画 blendspace 查询、动画状态机控制等高级动画功能，通常用于实现复杂的动画逻辑与定制化动画系统。

`UAnimationBlueprintLibrary` 继承自 `UBlueprintFunctionLibrary`，所有方法均为静态函数，必须提供骨骼网格体（SkeletalMesh）与 Bone 名称等输入参数才能执行动画计算。

## 核心用途与场景

### 1.骨骼分析与IK计算
- **骨骼位置查询**：获取骨骼在世界空间或本地空间的位置
- **IK 解算**：计算反向运动学目标位置
- **骨骼约束**：实现骨骼层次约束与限制

### 2. 动画状态查询
- **Blendspace 查询**：从 Blendspace 中获取动画权重
- **状态机状态获取**：查询当前动画状态机节点状态
- **动画时间偏移**：获取/设置动画播放时间

### 3. 动画合成与混合
- **动画层混合**：混合多个动画层
- **骨骼蒙版混合**：根据骨骼蒙版混合动画
- **动画插值**：在动画之间平滑过渡

### 4. 角色运动控制
- **脚部 IK**：调整脚部位置以适应地形
- **手部 IK**：调整手部位置以抓取物体
- **视线 IK**：让角色视线聚焦到目标

## 更多使用示例

### 示例 1：骨骼位置查询
```python
import unreal

def get_bone_transforms(skeletal_mesh_component):
    """获取骨骼组件中所有骨骼的变换"""
    if skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT", "reason": "SkeletalMeshComponent is None"}
    
    # 获取骨骼数量
    bone_count = skeletal_mesh_component.get_num_bones()
    
    transforms = []
    for bone_index in range(bone_count):
        bone_name = skeletal_mesh_component.get_bone_name(bone_index)
        transform = skeletal_mesh_component.get_local_space_bone_transform(bone_index)
        world_transform = skeletal_mesh_component.get_world_space_bone_transform(bone_index)
        
        transforms.append({
            "bone_index": bone_index,
            "bone_name": bone_name.value,
            "local_transform": transform,
            "world_transform": world_transform
        })
    
    return {
        "status": "OK",
        "bone_count": bone_count,
        " bones": transforms[:10]  # 限制返回数量
    }

def get_location_of_specific_bone(skeletal_mesh_component, bone_name):
    """获取指定骨骼的世界空间位置"""
    if skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT"}
    
    bone_index = skeletal_mesh_component.get_bone_index(unreal.Name(bone_name))
    if bone_index == -1:
        return {"status": "ERROR", "reason": f"Bone {bone_name} not found"}
    
    # 获取本地空间位置
    local_transform = skeletal_mesh_component.get_local_space_bone_transform(bone_index)
    
    # 获取世界空间位置
    world_transform = skeletal_mesh_component.get_world_space_bone_transform(bone_index)
    
    return {
        "status": "OK",
        "bone_name": bone_name,
        "bone_index": bone_index,
        "local_position": local_transform.get_translation(),
        "world_position": world_transform.get_translation()
    }
```

### 示例 2：IK 解算示例
```python
import unreal

def calculate_ik_foot_placement(skeletal_mesh_component, foot_bone_name, target_location):
    """计算脚部 IK 解算，让脚部对齐地面"""
    if skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT"}
    
    # 获取骨骼索引
    bone_index = skeletal_mesh_component.get_bone_index(unreal.Name(foot_bone_name))
    if bone_index == -1:
        return {"status": "ERROR", "reason": f"Bone {foot_bone_name} not found"}
    
    # 获取骨骼当前世界变换
    current_world_transform = skeletal_mesh_component.get_world_space_bone_transform(bone_index)
    
    # 计算需要的偏移量
    current_location = current_world_transform.get_translation()
    offset = target_location - current_location
    
    # 调整位置（简化示例，实际 IK 需要更复杂的解算）
    new_world_transform = current_world_transform
    new_world_transform.set_translation(target_location)
    
    return {
        "status": "OK",
        "foot_bone": foot_bone_name,
        "current_position": current_location,
        "target_position": target_location,
        "offset": offset
    }

def solve_full_body_ik(skeletal_mesh_component, ik_chain):
    """全身 IK 解算（简化示例）"""
    results = []
    
    for bone_name in ik_chain:
        # 假设每个骨骼有对应的目标位置
        # 实际实现需要更复杂的 IK 解算算法
        bone_index = skeletal_mesh_component.get_bone_index(unreal.Name(bone_name))
        if bone_index != -1:
            target_pos = unreal.Vector(0.0, 0.0, 0.0)  # 占位符
            result = calculate_ik_foot_placement(skeletal_mesh_component, bone_name, target_pos)
            results.append(result)
    
    return {
        "status": "OK",
        "ik_chain": ik_chain,
        "results": results
    }
```

### 示例 3：动画 Blendspace 查询
```python
import unreal

def query_anim_blendspace(anim_blendspace, x_param, y_param):
    """查询 Blendspace 中的动画权重"""
    if anim_blendspace is None:
        return {"status": "BLOCKED_INPUT", "reason": "AnimBlendspace is None"}
    
    # 查询 Blendspace（需要运行时动画播放器）
    # 实际实现需要使用动画播放器（AnimInstance）
    
    return {
        "status": "OK",
        "blendspace": anim_blendspace,
        "param_x": x_param,
        "param_y": y_param,
        "note": "实际 Blendspace 查询需通过 AnimInstance"
    }

def get_animated_blueprint_library_help():
    """获取 AnimationBlueprintLibrary 帮助信息"""
    # AnimationBlueprintLibrary 提供的 IK 辅助函数
    # 实际使用需与 AnimInstance 配合
    
    return {
        "status": "OK",
        "available_functions": [
            "break_skeletal_mesh_component",
            "get_bone_location",
            "get_socket_location",
            "get_relative_transform",
            "set_socket_location",
            "set_socket_rotation",
            "set_socket_transform"
        ],
        "note": "多数函数需要 SkeletalMeshComponent 作为世界上下文"
    }
```

### 示例 4：骨骼蒙版混合
```python
import unreal

def apply_bone_mask_blend(skeletal_mesh_component, bone_mask, alpha):
    """应用骨骼蒙版混合"""
    if skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT"}
    
    # 获取骨骼数量
    bone_count = skeletal_mesh_component.get_num_bones()
    
    # 应用蒙版（简化示例）
    blended_bones = []
    for i in range(bone_count):
        use_mask = bone_mask[i] if i < len(bone_mask) else 0.0
        weight = alpha * use_mask
        blended_bones.append({
            "bone_index": i,
            "weight": weight
        })
    
    return {
        "status": "OK",
        "alpha": alpha,
        "bone_count": bone_count,
        "blend_info": blended_bones[:5]  # 限制返回数量
    }

def create_bone_mask_for_spine(skeletal_mesh_component):
    """为脊柱骨骼创建蒙版"""
    if skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT"}
    
    # 获取脊柱相关骨骼
    spine_bones = ["spine_01", "spine_02", "spine_03", "neck_01"]
    bone_mask = {}
    
    for bone_name in spine_bones:
        bone_index = skeletal_mesh_component.get_bone_index(unreal.Name(bone_name))
        if bone_index != -1:
            bone_mask[bone_name] = bone_index
    
    return {
        "status": "OK",
        "spine_bones": bone_mask,
        "note": "实际蒙版需要根据动画层与混合权重计算"
    }
```

### 示例 5：动画状态机控制
```python
import unreal

def manage_animation_state_machine(anim_instance):
    """管理动画状态机（需要 AnimInstance）"""
    if anim_instance is None:
        return {"status": "BLOCKED_INPUT", "reason": "AnimInstance is None"}
    
    # 查询状态机状态（需要具体实现）
    # current_state = anim_instance.get_current_state_name()
    
    return {
        "status": "OK",
        "anim_instance": anim_instance,
        "note": "实际状态机控制需通过 AnimInstance 方法"
    }

def switch_animation_state(anim_instance, new_state_name):
    """切换动画状态"""
    if anim_instance is None:
        return {"status": "BLOCKED_INPUT"}
    
    # 切换状态（需要具体实现）
    # anim_instance.try_switch_to_state(new_state_name)
    
    return {
        "status": "OK",
        "new_state": new_state_name,
        "note": "实际切换需通过 AnimInstance 方法"
    }
```

## 高级用法与最佳实践

### 1. 性能优化建议
- **缓存骨骼索引**：重复使用的骨骼名称应缓存索引，避免每次查询
- **批量查询**：需要多个骨骼信息时，批量查询比多次单独查询更高效
- **世界变换缓存**：不必要的世界变换计算应改为本地变换

### 2. IK 实现最佳实践
- **分层 IK**：先解算主要关节（脚、手），再解算次要关节
- **平滑过渡**：使用插值在 IK 与正向动力学（FK）间平滑过渡
- **约束限制**：为 IK 链添加关节角度限制，避免不自然姿势

### 3. 与 AnimInstance 集成
```python
import unreal

def integrate_with_anim_instance(anim_instance, skeletal_mesh_component):
    """与 AnimInstance 配合使用"""
    if anim_instance is None or skeletal_mesh_component is None:
        return {"status": "BLOCKED_INPUT"}
    
    # 获取当前动画状态
    # state_name = anim_instance.get_current_state_name()
    
    # 设置动画参数
    # anim_instance.set_curve("MoveSpeed", 100.0)
    # anim_instance.set_curve("IsInAir", 0.0)
    
    return {
        "status": "OK",
        "integration": "AnimInstance + AnimationBlueprintLibrary"
    }
```

## 常见问题与注意事项

### 1. SkeletalMeshComponent 要求
- **必需参数**：所有方法都需要有效的 SkeletalMeshComponent
- **世界上下文**：部分方法需要世界上下文对象
- **骨骼有效性**：确保骨骼名称正确且存在于 SkeletalMesh 中

### 2. 运行时环境
- **编辑器与运行时**：多数方法在编辑器与运行时均可调用
- **PIE 会话**：动画相关功能在 PIE / Play 会话中最有效
- **模拟模式**：在编辑器模拟模式下可以预览动画效果

### 3. 常见错误
- `BLOCKED_INPUT`：缺少 SkeletalMeshComponent、骨骼名称无效
- `BLOCKED_TOOLING`：缺少世界上下文、骨骼网格体未加载
- **空索引**：骨骼索引为 -1 表示未找到骨骼

### 4. 与 Blueprint 同名函数的区别
- **AnimationBlueprintLibrary**：提供底层骨骼操作 API
- **AnimInstance**：提供高级动画状态机控制
- **选择准则**：需要直接骨骼操作 → AnimationBlueprintLibrary；需要状态机控制 → AnimInstance

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.AnimationBlueprintLibrary)` 实测确认
- 个别高级方法（如 `solve_full_body_ik`）可能需要自定义实现

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。