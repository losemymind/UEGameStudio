# KismetGuidLibrary - 概述（UE 5.6）

## 库功能概述

`UKismetGuidLibrary` 是 UE 5.6 引擎暴露给蓝图和 Python 的静态工具库，专门负责 GUID（Globally Unique Identifier）的创建、解析、转换与比较操作。该库提供了从字符串、二进制数据、UUID 或随机源生成 GUID 的完整能力，并支持 GUID 与 FString、FColor、FIntPoint 等类型的双向转换。

GUID 是分布式系统中无中心化协调的对象标识符标准，UE 游戏项目使用 GUID 作为：
- 资产的持久化唯一标识（Primary Asset ID、Save Game Slot、数据表键）
- 多玩家会话中的网络对象映射
- 临时会话的事务或操作跟踪 ID
- 跨插件/模块通信的去耦标识

## 核心用途与场景

### 1. 资产标识与引用
- **Primary Asset ID 构建**：使用 GUID 作为资产标识的一部分，避免路径依赖
- **动态加载验证**：通过 GUID 查询 Primary Asset System 确认资产存在性
- **Save Game Slot 生成**：每次新存档生成唯一 GUID 作为 slot name，避免覆盖

### 2. 网络同步与去耦
- **Replication ID**：为运行时生成的 Actor 或 Actor Component 分配 GUID 用于网络识别
- **NetworkGuid 映射**：在自定义同步协议中作为客户端-服务端对象映射键
- **操作日志**：为每个 RPC 或网络请求附带 GUID 方便日志追踪与调试

### 3. 临时会话与事务
- **事务 ID**：为编辑器批处理操作、Python 脚本执行生成唯一事务 ID
- **插件通信**：通过 Guid 作为消息 ID 实现插件间异步通信
- **重试机制**：为异步操作附加 GUID 方便失败后的重试与去重

## 更多使用示例

### 示例 1：存档系统唯一 Slot ID
```python
import unreal

def create_unique_save_slot():
    guid = unreal.Guid.new_guid()
    slot_name = f"save_{guid.string}"
    return slot_name

def save_game_with_guid():
    save_object = unreal.get_default_object(unreal.SaveGameBase)
    slot = create_unique_save_slot()
    unreal.GameplayStatics.save_game_to_slot(save_object, slot, 0)
    return {"slot": slot}

# 输出示例：{"slot": "save_0123456789ABCDEF0123456789ABCDEF"}
```

### 示例 2：编辑器批处理事务跟踪
```python
import unreal

def batch_import_assets(asset_paths):
    transaction_id = unreal.Guid.new_guid()
    unreal.begin_transaction(f"BatchImport_{transaction_id.string}", [], None)
    
    try:
        for path in asset_paths:
            unreal.import_asset(path, f"/Game/Imported/{transaction_id.string[:8]}")
        
        unreal.end_transaction()
        return {"status": "OK", "transaction_id": transaction_id.string}
    
    except Exception as e:
        unreal.end_transaction()
        return {"status": "ERROR", "transaction_id": transaction_id.string, "error": str(e)}
```

### 示例 3：网络 Actor 临时识别
```python
import unreal

def spawn_network_actor_with_guid():
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    
    actor_class = unreal.load_class("/Game/Blueprints/BP_ExperimentalActor")
    actor = unreal.GameplayStatics.spawn_actor_of_class(world, actor_class, unreal.Vector(0.0, 0.0, 100.0), unreal.Rotator(0.0, 0.0, 0.0))
    
    # 添加临时 GUID 标识符
    actor_tags = actor.get_actor_tags()
    actor_tags.add(unreal.Name(f"NetID_{unreal.Guid.new_guid().string[:16]}"))
    
    return {"actor": actor.get_actor_label(), "net_id": actor_tags}
```

### 示例 4：GUID 与数据表键映射
```python
import unreal

def create_data_row_with_guid():
    data_table = unreal.load_object(None, "/Game/DataTables/DT_MyData.DT_MyData")
    
    row_name = unreal.Name(f"Row_{unreal.Guid.new_guid().string[:16]}")
    new_data = unreal.DataRowHandler()
    new_data.some_field = "value"
    
    unreal.EditorDifficultyGlobals.add_data_table_row(data_table, row_name, new_data)
    return {"row_name": row_name.value}
```

### 示例 5：GUID 与颜色编码（调试可视化）
```python
import unreal

def guid_to_debug_color(guid_string):
    guid = unreal.Guid.new_guid_from_string(guid_string)
    hash_value = hash(guid_string)
    
    color = unreal.LinearColor(
        r=(hash_value & 0xFF) / 255.0,
        g=((hash_value >> 8) & 0xFF) / 255.0,
        b=((hash_value >> 16) & 0xFF) / 255.0,
        a=1.0
    )
    return color

# 调试绘制
world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
color = guid_to_debug_color("0123456789ABCDEF0123456789ABCDEF")
unreal.KismetSystemLibrary.draw_debug_box(world, unreal.Vector(0.0, 0.0, 50.0), unreal.Vector(10.0, 10.0, 10.0), color)
```

## 高级用法与最佳实践

### 1. GUID 性能优化建议
- **避免重复创建**：在循环中复用已生成 GUID，而非频繁调用 `new_guid()`
- **字符串缓存**：频繁使用的 GUID 字符串应缓存为常量，减少 `string` 属性访问
- **比较优化**：使用 `equal_equal_guid_guid()` 进行 GUID 比较，避免字符串比较

### 2. GUID 与 FString 相互转换
```python
# 从字符串解析（需验证格式）
guid_str = "0123456789ABCDEF0123456789ABCDEF"
guid = unreal.Guid.new_guid_from_string(guid_str)
if guid.is_valid():
    # 使用有效 GUID
    pass
else:
    # 处理无效格式

# 导出为不同格式
guid = unreal.Guid.new_guid()
print(f"Full: {guid.string}")
print(f"Compact: {guid.string.replace('-', '')}")
print(f"Braced: {{{guid.string}}}")  # 如 {0123456789ABCDEF0123456789ABCDEF}
```

### 3. GUID 随机性与碰撞规避
- **密码学安全**：UE 的 `new_guid()` 使用系统随机源，碰撞概率极低（2^122 空间）
- **种子控制**：如需可复现序列，使用 `make_random_stream(seed)` + `random_guid(stream)`
- **业务键组合**：关键业务场景（如拍卖、交易）可组合 GUID 与时间戳增强唯一性

### 4. 编辑器工具集成
```python
import unreal

@unreal.ufunction.static
def create_asset_with_guid():
    # 使用 GUID 作为 Asset 名称的一部分
    guid = unreal.Guid.new_guid()
    asset_name = f"Generated_{guid.string[:8]}"
    
    # 生成资产（如数据表行、配置等）
    # ...资产创建逻辑...
    
    return asset_name
```

## 常见问题与注意事项

### 1. GUID 字符串格式
- **标准格式**：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`（36 字符，含 4 个连字符）
- **大小写**：默认大写，可通过 `lowercase()` 转小写
- **无效字符串**：解析时长度不符或包含非法字符会返回无效 GUID

### 2. 阻塞状态处理
- `BLOCKED_INPUT`：缺少有效的 GUID 字符串、格式错误、无效源对象
- `BLOCKED_TOOLING`：缺少世界上下文（部分编辑器操作）、Python 运行时不可用
- **验证策略**：所有 GUID 操作前调用 `is_valid()` 检查有效性

### 3. 编辑器与运行时上下文
- **纯数学操作**：创建、转换、比较可在无上下文环境执行
- **Asset 相关操作**：需要编辑器世界或运行时世界上下文
- **PIE 会话**：运行时操作仅在 PIE / Play 会话中有效

### 4. 与其他标识系统的区别
- **Object Path**：`/Game/Path/To.Asset.Asset` - 依赖文件路径结构
- **Soft Object Path**：可序列化路径引用，支持热重载
- **Primary Asset ID**：由 `PrimaryAssetType` + `AssetName` 组成，需显式注册
- **GUID**：完全去中心化，不依赖任何结构，适合分布式场景

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.KismetGuidLibrary)` 实测确认
- 个别边缘方法（如特定版本新增的 `combine_guids`、`hash_guid`）可能未包含在内

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。