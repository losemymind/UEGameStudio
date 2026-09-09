# KismetStringTableLibrary - 概述（UE 5.6）

## 库功能概述

`UKismetStringTableLibrary` 是 UE 5.6 引擎暴露给蓝图和 Python 的静态查询接口，专门负责运行时字符串表（String Table）的校验、读取与枚举操作。该库提供了从已注册字符串表中查询命名空间、条目源字符串、元数据，以及枚举已注册表与条目键的能力。

字符串表是 UE 本地化系统的重要组成部分，用于 centralized 管理运行时需要翻译的文本。通过字符串表，策划可以动态添加/修改条目而无需重新编译代码或重新导入 CSV，适合 UI 动态文本、事件描述、动态生成文本等场景。

## 核心用途与场景

### 1. 动态 UI 文本管理
- **事件描述**：通过字符串表管理成就、任务描述、日志信息等动态文本
- **动态菜单**：根据游戏状态动态加载不同的菜单项文本
- **运行时提示**：根据上下文动态显示不同的提示信息

### 2. 数据驱动文本
- **数据表关联**：将数据表行与字符串表条目关联，实现数据驱动的文本展示
- **条件文本**：根据游戏状态或条件动态切换不同的字符串表条目
- **A/B 测试**：通过切换字符串表实现文案 A/B 测试

### 3. 本地化调试与校验
- **缺失条目检测**：遍历所有字符串表条目，检查是否有缺失的本地化文本
- **调试工具**：在编辑器中快速查看字符串表的命名空间与条目结构
- **本地化覆盖率统计**：统计已本地化的条目比例

## 更多使用示例

### 示例 1：检查字符串表注册状态
```python
import unreal

api = unreal.KismetStringTableLibrary

def check_table_exists(table_id):
    name_id = unreal.Name(table_id)
    if not api.is_registered_table_id(name_id):
        print(f"Table '{table_id}' is not registered")
        return False
    
    keys = api.get_keys_from_string_table(name_id)
    print(f"Table '{table_id}' exists with {len(keys)} entries")
    return True

check_table_exists("Table_UI")
check_table_exists("Table_Dialogue")
```

### 示例 2：读取字符串表条目内容
```python
import unreal

api = unreal.KismetStringTableLibrary

def read_table_entry(table_id, key):
    name_id = unreal.Name(table_id)
    
    if not api.is_registered_table_entry(name_id, key):
        print(f"Entry '{key}' not found in table '{table_id}'")
        return None
    
    source_string = api.get_table_entry_source_string(name_id, key)
    namespace = api.get_table_namespace(name_id)
    
    return {
        "namespace": namespace,
        "key": key,
        "source_string": source_string
    }

# 示例调用
result = read_table_entry("Table_Dialogue", "intro_line_01")
if result:
    print(f"Namespace: {result['namespace']}")
    print(f"Source: {result['source_string']}")
```

### 示例 3：枚举所有已注册字符串表
```python
import unreal

api = unreal.KismetStringTableLibrary

def enumerate_all_tables():
    tables = api.get_registered_string_tables()
    print(f"Total registered tables: {len(tables)}")
    
    for table_name in tables:
        table_id = unreal.Name(table_name)
        keys = api.get_keys_from_string_table(table_id)
        
        print(f"\nTable: {table_name}")
        print(f"  Namespace: {api.get_table_namespace(table_id)}")
        print(f"  Entries: {len(keys)}")
        
        if len(keys) > 0:
            print(f"  Sample keys: {keys[:3]}...")

enumerate_all_tables()
```

### 示例 4：读取条目元数据
```python
import unreal

api = unreal.KismetStringTableLibrary

def read_entry_metadata(table_id, key):
    name_id = unreal.Name(table_id)
    
    if not api.is_registered_table_entry(name_id, key):
        print(f"Entry '{key}' not found")
        return None
    
    metadata_ids = api.get_meta_data_ids_from_string_table_entry(name_id, key)
    print(f"Metadata IDs: {metadata_ids}")
    
    metadata = {}
    for meta_id in metadata_ids:
        value = api.get_table_entry_meta_data(name_id, key, meta_id)
        metadata[meta_id.value] = value
        print(f"  {meta_id.value}: {value}")
    
    return metadata

# 示例调用
read_entry_metadata("Table_Items", "weapon_sword_01")
```

### 示例 5：本地化调试工具
```python
import unreal

api = unreal.KismetStringTableLibrary

def debug_localization_coverage():
    tables = api.get_registered_string_tables()
    total_entries = 0
    checked_entries = 0
    
    for table_name in tables:
        table_id = unreal.Name(table_name)
        keys = api.get_keys_from_string_table(table_id)
        
        total_entries += len(keys)
        
        for key in keys:
            if api.is_registered_table_entry(table_id, key):
                source = api.get_table_entry_source_string(table_id, key)
                # 这里可以添加本地化文本检查逻辑
                checked_entries += 1
    
    print(f"Total entries: {total_entries}")
    print(f"Checked entries: {checked_entries}")
    print(f"Coverage: {checked_entries / total_entries * 100:.2f}%" if total_entries > 0 else "No entries")

debug_localization_coverage()
```

## 高级用法与最佳实践

### 1. 字符串表性能优化建议
- **避免重复查询**：对频繁访问的字符串表条目进行缓存
- **批量查询**：如需查询多个条目，尽量在一次循环中完成
- **延迟加载**：对非关键文本使用延迟加载策略

### 2. 字符串表与数据表集成
```python
import unreal

def link_data_table_with_string_table():
    data_table = unreal.load_object(None, "/Game/DataTables/DT quests.DT_quests")
    string_table_id = unreal.Name("Table_Quests")
    
    rows = data_table.get_table_data()
    for row_name, row_data in rows.items():
        quest_name = row_data.get("QuestName", "")
        quest_desc = row_data.get("QuestDescription", "")
        
        # 将数据表行与字符串表条目关联
        key = f"{row_name.value}"
        # 这里可以添加字符串表创建逻辑
        print(f"Row: {row_name.value}, Quest: {quest_name}")
```

### 3. 动态字符串表生成
```python
import unreal

def create_dynamic_string_table():
    # 动态注册字符串表（需要在运行时）
    table_id = unreal.Name("Table_DynamicEvents")
    
    # 注册表（运行时 API，需要在 PIE 中）
    # unreal.KismetStringTableLibrary.register_string_table(table_id, "DynamicEvents")
    
    # 添加条目
    # unreal.KismetStringTableLibrary.add_string_table_entry(table_id, "event_001", "事件 001 描述")
    
    print("Dynamic string table creation requires runtime context")
```

### 4. 编辑器工具集成
```python
import unreal

@unreal.ufunction.static
def open_string_table_editor():
    # 打开字符串表编辑器
    unreal.EditorScriptingToolsLibrary.open_asset_editor(["/Script/LocalizationsDashboard"])

# 或使用命令行打开
unreal.EditorScriptingToolsLibrary.open_asset_editor(["/Script/LocalizationsDashboard"])
```

## 常见问题与注意事项

### 1. 字符串表注册状态
- **运行时 vs 编辑器**：字符串表 registrations 仅在 PIE/Play-session 中有效，在编辑器模式下可能不可见
- **热重载**：修改字符串表后需要触发热重载或重新进入 PIE 才能看到更新
- **异步加载**：字符串表加载是异步的，直接查询可能返回空值，需等待加载完成

### 2. 阻塞状态处理
- `BLOCKED_INPUT`：缺少有效的表 ID 或条目键、表未注册、条目不存在
- `BLOCKED_TOOLING`：缺少运行时世界上下文（PIE/Play）、Python 运行时不可用、字符串表系统未初始化
- **验证策略**：所有查询前先调用 `is_registered_table_id()` 和 `is_registered_table_entry()` 检查存在性

### 3. 编辑器与运行时上下文
- **编辑器模式**：字符串表查询在编辑器模式下可能返回空值或错误
- **PIE 会话**：运行时字符串表操作仅在 PIE / Play 会话中有效
- **Commandlet**：通过命令行编译时，字符串表可能尚未加载

### 4. 与其他本地化系统的区别
- **Loc Text（静态本地化）**：通过 `FText` 和 `NSLOCTEXT` 编译时生成，性能最优
- **Dynamic Text（动态本地化）**：通过 `ToSpec()` 格式化，适合运行时参数插入
- **String Table（字符串表）**：运行时查询，支持动态添加/修改，适合策划驱动内容
- **CSV 导入**：通过 Importer 导入的本地化文本，需重新导入才能更新

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.KismetStringTableLibrary)` 实测确认
- 个别边缘方法（如特定版本新增的注册/添加 API）可能未包含在内
- 运行时字符串表的创建、添加条目等修改操作在当前 SKILL.md 中未包含，如有需要请参考官方文档

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。
