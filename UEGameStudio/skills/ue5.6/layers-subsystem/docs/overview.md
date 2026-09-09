# LayersSubsystem - 概述（UE 5.6）

## 库功能概述

`ULayersSubsystem` 是 UE 5.6 中专门用于管理关卡层（Level Layers）组织的编辑器子系统。关卡层是 UE 中用于组织 Actor、分组管理、控制可见性与选择的逻辑分组机制。该子系统提供了完整的层管理能力：创建/删除/重命名层、Actor 加入/移出层、按层查询、层可见性控制等。

与 `UWorldPartitionSubsystem` 不同，`ULayersSubsystem` 专注于传统的关卡层组织（Layer），适用于大小中等的关卡；而 World Partition 是为超大开放世界设计的 Grid Cell 分区系统。

## 核心用途与场景

### 1. 关卡组织与管理
- **功能分组**：将相关 Actor 分组到不同层（如环境、装饰、路径点）
- **快速选择**：按层选择 Actor，提高编辑器工作效率
- **批量操作**：对整个层进行移动、旋转、缩放等操作

### 2. 可见性控制
- **显示/隐藏层**：快速切换整个层的可见性
- **选择性显示**：仅显示特定层，隐藏其他层
- **视口优化**：减少视口渲染负载，提升编辑器性能

### 3. Actor 分组管理
- **批量添加/移除**：将多个 Actor 一次性加入/移出层
- **当前选中 Actor 操作**：对当前选中的所有 Actor 进行层操作
- **层内选择**：选择特定层内的所有 Actor

## 更多使用示例

### 示例 1：创建与管理层
```python
import unreal

def manage_layers():
    """管理关卡层"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    world = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem).get_editor_world()
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 创建新层
    layer = api.create_layer("L_Environment")
    print(f"Created layer: {layer.get_name()}")
    
    # 重命名层
    api.rename_layer("L_Environment", "L_Nature")
    
    # 删除层
    # api.delete_layer("L_Nature")
    
    return {"status": "OK", "actions": ["create", "rename", "delete_supported"]}
```

### 示例 2：Actor 加入/移出层
```python
import unreal

def add_actors_to_layer():
    """将 Actor 添加到层"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    editor_actor_subsystem = unreal.get_editor_subsystem(unreal.EditorActorSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 生成测试 Actor
    static_mesh_actor_class = unreal.load_class("/Script/Engine.StaticMeshActor")
    actor = editor_actor_subsystem.spawn_actor_from_class(
        static_mesh_actor_class,
        unreal.Vector(0.0, 0.0, 0.0)
    )
    
    # 单个 Actor 加入层
    success = api.add_actor_to_layer(actor, "L_Props")
    
    # 批量加入层
    actor_list = [actor]
    success_all = api.add_actors_to_layer(actor_list, "L_Props")
    
    return {
        "status": "OK",
        "single_actor_result": success,
        "batch_result": success_all
    }

def actors_in_layer():
    """查询层内的所有 Actor"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    actors = api.get_actors_from_layer("L_Props")
    
    return {
        "status": "OK",
        "layer_name": "L_Props",
        "actor_count": len(actors),
        "actors": [a.get_actor_label() for a in actors[:5]]  # 限制返回数量
    }

def remove_actors_from_layer():
    """将 Actor 移出层"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    actors = api.get_actors_from_layer("L_Props")
    if actors:
        success = api.remove_actors_from_layer(actors, "L_Props")
        return {
            "status": "OK",
            "removed_actors": len(actors),
            "result": success
        }
    
    return {"status": "OK", "message": "No actors in layer"}
```

### 示例 3：按层选择 Actor
```python
import unreal

def select_actors_by_layer():
    """按层选择 Actor"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 选择层内所有 Actor
    layer_name = "L_Deco"
    selected = api.select_actors_in_layer(
        layer_name,
        b_select=True,
        b_notify=True,
        b_select_even_if_hidden=False
    )
    
    # 取消选择层内所有 Actor
    api.select_actors_in_layer(layer_name, b_select=False, b_notify=True)
    
    return {
        "status": "OK",
        "layer_name": layer_name,
        "selected": selected
    }

def select_all_selected_to_layer():
    """将当前选中的所有 Actor 添加到层"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取当前选中的 Actor
    selected_actors = api.get_selected_actors()
    
    if selected_actors:
        success = api.add_selected_actors_to_layer("L_Selected")
        return {
            "status": "OK",
            "selected_count": len(selected_actors),
            "add_result": success
        }
    
    return {"status": "OK", "message": "No actors currently selected"}
```

### 示例 4：层可见性控制
```python
import unreal

def control_layer_visibility():
    """控制层可见性"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 设置层可见性
    api.set_layer_visibility("L_Hidden", False)  # 隐藏
    api.set_layer_visibility("L_Visible", True)  # 显示
    
    # 批量设置层可见性
    layers = ["L_Hidden1", "L_Hidden2", "L_Visible1"]
    api.set_layers_visibility(layers, False)  # 批量隐藏
    
    # 切换层可见性
    api.toggle_layer_visibility("L_Toggle")
    
    # 显示所有层
    api.make_all_layers_visible()
    
    return {"status": "OK", "actions": ["set", "batch_set", "toggle", "make_all_visible"]}

def toggle_layer_refresh():
    """刷新视口以应用可见性更改"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    if api is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 刷新特定层的视口可见性
    api.update_all_view_visibility("L_Visible")
    
    # 刷新所有 Actor 的可见性
    api.update_all_actors_visibility(
        b_notify_selection_change=True,
        b_redraw_viewports=True
    )
    
    return {"status": "OK", "refreshed": True}
```

### 示例 5：层管理工具集成
```python
import unreal

class LayerManagerTool:
    """关卡层管理工具"""
    
    def __init__(self):
        self.api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
        self.layers = self.get_all_layers()
    
    def get_all_layers(self):
        """获取所有现有层"""
        if self.api is None:
            return []
        
        layer_names = []
        self.api.add_all_layer_names_to(layer_names)
        return layer_names
    
    def create_layer_group(self, group_name, actors_to_add):
        """创建层组并添加 Actors"""
        layer_name = f"L_{group_name}"
        
        # 创建层
        if not self.api.is_layer(layer_name):
            self.api.create_layer(layer_name)
        
        # 添加 actors
        if actors_to_add:
            self.api.add_actors_to_layer(actors_to_add, layer_name)
        
        self.layers.append(layer_name)
        return {"status": "OK", "layer_name": layer_name, "actors_added": len(actors_to_add)}
    
    def hide_all_layers_except(self, visible_layer):
        """隐藏所有层，仅显示指定层"""
        for layer in self.layers:
            if layer != visible_layer:
                self.api.set_layer_visibility(layer, False)
        self.api.set_layer_visibility(visible_layer, True)
    
    def delete_unused_layers(self):
        """删除空层"""
        for layer in self.layers[:]:  # 复制列表以便安全删除
            actors = self.api.get_actors_from_layer(layer)
            if not actors:
                self.api.delete_layer(layer)
                self.layers.remove(layer)
                print(f"Deleted empty layer: {layer}")
        
        return {"status": "OK", "remaining_layers": len(self.layers)}

# 使用示例
def use_layer_manager_tool():
    tool = LayerManagerTool()
    
    # 创建新层组
    tool.create_layer_group("Props", [])
    
    # 隐藏除指定层外的所有层
    tool.hide_all_layers_except("L_Props")
    
    # 删除空层
    tool.delete_unused_layers()
    
    return {"status": "OK", "tool": "initialized"}
```

## 高级用法与最佳实践

### 1. 性能优化
- **批量操作**：使用批量方法（`add_actors_to_layers`）而非循环调用单个方法
- **选择优化**：选择大量 Actor 时，`b_notify` 设置为 `False` 可提升性能
- **视口管理**：可见性更改后调用 `update_*` 方法刷新视口

### 2. 编辑器工作流集成
- **与选择系统集成**：使用 `get_selected_actors()` 获取当前选中 Actor
- **与层浏览器同步**：调用 `editor_refresh_layer_browser()` 更新编辑器 UI
- **与关卡保存集成**：层修改后调用保存函数：

```python
import unreal

def save_after_layer_changes():
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # ... 层修改操作 ...
    
    # 保存修改
    unreal.EditorLoadingAndSavingUtils.save_dirty_packages(
        b_save_maps=True,
        b_check_modified=False
    )
    
    return {"status": "OK", "saved": True}
```

### 3. 批量 Actor 操作
```python
import unreal

def batch_move_to_layer():
    """批量移动 Actor 到新层"""
    api = unreal.get_editor_subsystem(unreal.LayersSubsystem)
    
    # 从原层移除
    original_layer = "L_Old"
    actors = api.get_actors_from_layer(original_layer)
    
    # 加入新层
    new_layer = "L_New"
    api.add_actors_to_layer(actors, new_layer)
    
    # 从原层移除（可选）
    # api.remove_actors_from_layer(actors, original_layer)
    
    return {"status": "OK", "moved_actors": len(actors)}
```

## 常见问题与注意事项

### 1. 编辑器专用
- **仅编辑器可用**：`ULayersSubsystem` 仅在编辑器上下文中可用，PIE/运行时不可用
- **世界依赖**：依赖当前已加载的关卡（Level）
- **保存要求**：所有修改必须通过编辑器接口保存（`save_dirty_packages()`）

### 2. 阻塞状态处理
- `BLOCKED_TOOLING`：编辑器子系统不可用、编辑器上下文不可用
- `BLOCKED_INPUT`：层不存在、Actor 无效、输入参数错误
- **最佳实践**：先检查 `api` 是否为 `None`，再执行操作

### 3. 层操作返回值
- **成功返回**：多数方法返回 `bool` 表示操作是否成功
- **失败情况**：层不存在、Actor 已在层中（add）、Actor 不在层中（remove）等
- **批量操作**：即使部分失败，只要有一个成功就可能返回 `True`

### 4. Actor 与层的关系
- **可变归属**：Actor 可以属于多个层，也可以随时更换归属层
- **去关联**：`disassociate_actor_from_layers()` 将 Actor 从所有层移除
- **初始化**：新生成的 Actor 需调用 `initialize_new_actor_layers()` 才能加入层

### 5. 与 World Partition 的区别
- **ULayersSubsystem**：传统的关卡层组织，适合中等规模关卡
- **UWorldPartitionSubsystem**：Grid Cell 分区系统，适合超大开放世界
- **选择准则**：地图不大（< 1km²）、需要灵活组织 → Layers；大型开放世界 → World Partition

### 6. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理
- 精确 Python 方法名需在目标编辑器中通过 `dir(unreal.LayersSubsystem)` 实测确认
- 个别方法可能因插件而异

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。