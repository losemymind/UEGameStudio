# EditorUtilityBlueprintLibrary - 概述（UE 5.6）

## 库功能概述

`UEditorUtilityBlueprintLibrary` 是 UE 5.6 引擎暴露给蓝图和 Python 的静态工具库，专门提供编辑器级别（Editor-only）的通用功能。该库是 `UBlueprintFunctionLibrary` 的派生类，专为编辑器脚本和实用程序设计，提供文件操作、系统信息查询、编辑器行为控制等核心能力。

与 `KismetSystemLibrary` 不同，`EditorUtilityBlueprintLibrary` 的所有方法都标有 `WithEditorOnlyData` 限定，只能在编辑器环境中调用，无法在运行时（PIE/打包版）使用。

## 核心用途与场景

### 1. 编辑器脚本与自动化
- **批量资产处理**：遍历项目资产、修改属性、批量重命名
- **自动化构建**：配合 Cook、Package 流程自动执行预处理
- **资产检查工具**：扫描项目中的潜在问题（缺失引用、无效路径等）

### 2. 系统信息与环境查询
- **编辑器版本信息**：获取当前 UE 编辑器版本、构建信息
- **操作系统检测**：识别 Windows/macOS/Linux 环境
- **磁盘空间查询**：检查项目目录可用空间

### 3. 编辑器行为控制
- **UI 交互**：显示消息框、选择文件夹、确认对话框
- **选中行为**：控制选中对象、滚动到视图、聚焦
- **时间与性能**：获取编辑器帧时间、内存使用

## 更多使用示例

### 示例 1：批量重命名资产
```python
import unreal

def batch_rename_assets(asset_paths, prefix="New_"):
    """为资产路径列表添加统一前缀"""
    editor_asset_lib = unreal.EditorAssetLibrary
    
    results = {"success": [], "failed": []}
    
    for path in asset_paths:
        if not editor_asset_lib.does_asset_exist(path):
            results["failed"].append({"path": path, "reason": " Asset does not exist"})
            continue
        
        try:
            # 获取资产名称
            asset_name = unreal.Paths.get_base_filename(path)
            new_name = f"{prefix}{asset_name}"
            
            # 重命名
            new_path = editor_asset_lib.rename_asset(path, new_name)
            results["success"].append({"original": path, "new": new_path})
        except Exception as e:
            results["failed"].append({"path": path, "reason": str(e)})
    
    return results

# 使用示例
assets = [
    "/Game/Maps/Level1.umap",
    "/Game/Blueprints/BP_Character.uasset"
]
print(batch_rename_assets(assets, "Renamed_"))
```

### 示例 2：文件系统操作
```python
import unreal

def explore_project_directory():
    """探索项目目录结构"""
    project_dir = unreal.Paths.project_dir()
    content_dir = unreal.Paths.project_content_dir()
    
    # 列出目录内容
    files = unreal.Paths.get_files(project_dir, "*.*", recursive=True)
    
    # 过滤特定类型
    uassets = [f for f in files if f.endswith('.uasset')]
    umaps = [f for f in files if f.endswith('.umap')]
    
    return {
        "project_dir": project_dir,
        "content_dir": content_dir,
        "total_files": len(files),
        "uassets": len(uassets),
        "umaps": len(umaps)
    }

# 示例输出
# {
#     "project_dir": "C:/Projects/MyGame/",
#     "content_dir": "C:/Projects/MyGame/Content/",
#     "total_files": 1523,
#     "uassets": 847,
#     "umaps": 12
# }
```

### 示例 3：系统与性能信息
```python
import unreal

def get_editor_system_info():
    """获取编辑器系统信息"""
    # 版本信息
    engine_version = unreal.KismetSystemLibrary.get_engine_version()
    
    # 内存使用
    memory_info = unreal.GEngine.get_memory_usage()
    
    # 帧时间（编辑器）
    delta_time = unreal.GEngine.get_delta_seconds()
    
    # 屏幕信息
    screen_res = unreal.GGameViewportDelegate.get_viewport_size()
    
    return {
        "engine_version": engine_version,
        "memory_usage_mb": memory_info / (1024 * 1024),
        "delta_time_ms": delta_time * 1000,
        "screen_resolution": screen_res
    }
```

### 示例 4：UI 对话框与用户交互
```python
import unreal

def show_asset_picker():
    """显示资产选择器对话框"""
    # 选择单个资产
    selected = unreal.EditorFileDialog.show_dialog_open_asset(
        "选择资产",
        "/Game",
        "*.uasset"
    )
    
    if selected:
        return {"selected": selected}
    
    # 批量选择资产
    multi_selected = unreal.EditorFileDialog.show_dialog_open_asset_multiple(
        "批量选择资产",
        "/Game",
        "*.uasset;*.umap"
    )
    
    return {"selected_count": len(multi_selected), "paths": multi_selected}

def confirm_action(message="确认执行操作？"):
    """显示确认对话框"""
    result = unreal.EditorUtilityDialog.show_dialog(
        unreal.EditorUtilityDialogButtonYES | unreal.EditorUtilityDialogButtonNO,
        "确认",
        message
    )
    
    return result == unreal.EditorUtilityDialogButtonYES
```

### 示例 5：编辑器工具集成
```python
import unreal

@unreal.ufunction.static
def refresh_all_thumbnails():
    """刷新所有资产缩略图（编辑器工具）"""
    editor_asset_lib = unreal.EditorAssetLibrary
    editor_utility = unreal.EditorUtilityLibrary
    
    # 获取所有资产
    assets = editor_asset_lib.list_assets("/Game", recursive=True)
    
    # 刷新缩略图
    for asset in assets:
        editor_utility.set_thumbnails_dirty(asset)
    
    return {"status": "OK", "assets_checked": len(assets)}

# 在编辑器工具按钮中调用
# tool = unreal.EditorUtilityWidget()
# tool.add_button("Refresh Thumbnails", refresh_all_thumbnails)
```

## 高级用法与最佳实践

### 1. 编辑器脚本生命周期管理
- **事务支持**：使用 `begin_transaction`/`end_transaction` 包裹修改操作
- **撤销/重做**：编辑器操作自动支持撤销栈
- **状态检查**：操作前检查项目是否已保存、是否有未提交更改

### 2. 性能优化建议
- **批量操作**：尽可能批量处理资产，避免逐个遍历
- **异步处理**：长时间操作使用 `unreal.EditorAsyncTask` 避免阻塞编辑器
- **内存管理**：处理大量资产时分批加载，及时释放资源

### 3. 与 Editor Utility Subsystem 配合
```python
import unreal

def use_editor_subsystem():
    """使用编辑器子系统获取编辑器上下文"""
    editor_subsystem = unreal.get_editor_subsystem(unreal.UnrealEditorSubsystem)
    
    # 当前选中对象
    selected_assets = editor_subsystem.get_selected_assets()
    
    # 当前关卡
    editor_world = editor_subsystem.get_editor_world()
    
    # 项目设置
    project_settings = editor_subsystem.get_game_project_settings()
    
    return {
        "selected_count": len(selected_assets),
        "project_name": project_settings.get_project_name() if project_settings else None
    }
```

### 4. 错误处理与用户反馈
```python
import unreal

def safe_asset_operation(operation_func):
    """安全执行资产操作的装饰器"""
    try:
        result = operation_func()
        unreal.EditorUtilityDialog.show_dialog(
            unreal.EditorUtilityDialogButtonOK,
            "成功",
            "操作已完成"
        )
        return result
    except Exception as e:
        unreal.EditorUtilityDialog.show_dialog(
            unreal.EditorUtilityDialogButtonOK,
            "错误",
            f"操作失败: {str(e)}"
        )
        return None
```

## 常见问题与注意事项

### 1. 编辑器专用限制
- **运行时不可用**：所有方法仅在编辑器中有效，PIE/打包版返回 `BLOCKED_TOOLING`
- **WithEditorOnlyData**：标记此限定的方法不能在运行时调用
- **Python 环境**：需要编辑器 Python 环境（非纯 Python 解释器）

### 2. 阻塞状态处理
- `BLOCKED_TOOLING`：编辑器上下文不可用、运行时环境被检测到
- `BLOCKED_INPUT`：缺少必要的路径、文件名、选项等输入参数
- **最佳实践**：所有操作前检查编辑器状态 `unreal.System.is_running_in_editor()`

### 3. 文件路径格式
- **绝对路径**：推荐使用绝对路径，避免相对路径混淆
- **正斜杠**：UE 统一使用正斜杠 `/` 分隔路径
- **路径辅助函数**：使用 `unreal.Paths` 类处理路径拼接、获取扩展名等

### 4. 权限与访问控制
- **文件权限**：确保对目标目录有写权限
- **资产锁定**：检查资产是否被其他进程锁定
- **版本控制**：操作前了解源代码控制系统状态（Perforce/Git）

### 5. 与 KismetSystemLibrary 的区别
- **KismetSystemLibrary**：运行时 + 编辑器通用工具（如数学运算、Trace 检测）
- **EditorUtilityBlueprintLibrary**：仅编辑器专用（文件操作、UI 交互、编辑器控制）

### 6. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.EditorButtonUtilityBlueprintLibrary)` 实测确认
- 个别方法（如 `find_editor_blueprint_asset`）可能因插件而异

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。