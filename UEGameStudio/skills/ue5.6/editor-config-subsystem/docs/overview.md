# EditorConfigSubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/EditorConfig/Public/EditorConfigSubsystem.h` 整理 `UEditorConfigSubsystem` 中可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case；每个成员给出 C++ 签名、Python 参数、返回约定与示例；精确 Python 暴露名需实测确认。

## 获取子系统

```python
import unreal

api = unreal.get_editor_subsystem(unreal.EditorConfigSubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: EditorConfigSubsystem 不可用")
```

- `UEditorConfigSubsystem` 派生自 `UEditorSubsystem`，通过 `unreal.get_editor_subsystem` 获取。
- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 配置文件名来自 UClass 的 `EditorConfig="ConfigName"` 元数据。
- Python 方法名约定：C++ 函数名按反射约定转 snake_case，精确 Python 暴露名需实测确认。

## 通用约定

- 配置以 JSON 落盘，搜索目录按 Engine → Project → ProjectOverrides → User 层级组织。
- 过滤参数对应 `FEditorConfig::EPropertyFilter`：`MetadataOnly`（仅处理带 EditorConfig 元数据的属性，默认）与 `All`（处理全部属性）。
- `early_add_search_directory` 只能在子系统初始化前注册搜索层，初始化后调用会断言。

## 加载与保存

### load_config_object

- C++ 签名：`bool LoadConfigObject(const UClass* Class, UObject* Object, FEditorConfig::EPropertyFilter Filter = FEditorConfig::EPropertyFilter::MetadataOnly)`
- Python：`load_config_object(class_, object, filter=...) -> bool`
- 说明：按 UClass 的 EditorConfig 元数据加载配置到目标对象；加载失败返回 `False`。
- 示例：

```python
asset = unreal.EditorAssetLibrary.load_asset("/Game/ExampleAsset")
cls = asset.get_class()
loaded = api.load_config_object(cls, asset)
if not loaded:
    print("BLOCKED_INPUT: 配置加载失败，检查 class 元数据")
```

### save_config_object

- C++ 签名：`bool SaveConfigObject(const UClass* Class, const UObject* Object, FEditorConfig::EPropertyFilter Filter = FEditorConfig::EPropertyFilter::MetadataOnly)`
- Python：`save_config_object(class_, object, filter=...) -> bool`
- 说明：按 UClass 的 EditorConfig 元数据保存对象配置到配置文件；返回 `True` 表示写入成功。
- 示例：

```python
saved = api.save_config_object(cls, asset)
if not saved:
    print("BLOCKED_TOOLING: 配置写入失败，检查文件权限或路径")
```

## 配置对象操作

### find_or_load_config

- C++ 签名：`TSharedRef<FEditorConfig> FindOrLoadConfig(FStringView ConfigName, ESearchDirectoryType SearchType = ESearchDirectoryType::Project)`
- Python：`find_or_load_config(config_name, included_types=...) -> FEditorConfig`
- 说明：按配置名查找或加载配置；返回配置对象引用，失败断言。
- 示例：

```python
config_ref = api.find_or_load_config("MyConfig")
print("config found/loaded:", config_ref is not None)
```

### save_config

- C++ 签名：`void SaveConfig(TSharedRef<FEditorConfig> Config)`
- Python：`save_config(config) -> None`
- 说明：将配置引用写入磁盘。
- 示例：

```python
api.save_config(config_ref)
```

### reload_config

- C++ 签名：`bool ReloadConfig(TSharedRef<FEditorConfig> Config)`
- Python：`reload_config(config) -> bool`
- 说明：从磁盘重新加载配置；返回 `True` 表示加载成功。
- 示例：

```python
ok = api.reload_config(config_ref)
```

## 搜索目录管理

### add_search_directory

- C++ 签名：`void AddSearchDirectory(ESearchDirectoryType Type, FStringView SearchDir)`
- Python：`add_search_directory(type_, search_dir) -> None`
- 说明：注册额外搜索目录（项目运行时）。
- 示例：

```python
api.add_search_directory(unreal.ESearchDirectoryType.USER, "C:/CustomConfigs")
```

### early_add_search_directory

- C++ 签名：`static void EarlyAddSearchDirectory(ESearchDirectoryType Type, FStringView SearchDir)`
- Python：`early_add_search_directory(type_, search_dir) -> None`
- 说明：仅在子系统初始化前调用的搜索目录注册；初始化后调用会断言。
- 示例：

```python
unreal.EditorConfigSubsystem.early_add_search_directory(
    unreal.ESearchDirectoryType.USER, "C:/EarlyConfigs"
)
```

## 完整示例：配置持久化流程

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.EditorConfigSubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "EditorConfigSubsystem 不可用"})
        return

    asset = unreal.EditorAssetLibrary.load_asset("/Game/ExampleAsset")
    if asset is None:
        print({"status": "BLOCKED_INPUT", "reason": "asset path 无效"})
        return

    cls = asset.get_class()
    loaded = api.load_config_object(cls, asset)
    saved = api.save_config_object(cls, asset)

    print({
        "status": "OK",
        "loaded": loaded,
        "saved": saved,
    })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少类、对象等必要输入；或对象所属类未声明 `EditorConfig="..."` 元数据。
- `BLOCKED_TOOLING`：子系统或编辑器上下文不可用。
- 配置读写属于状态持久化：写入后须经编辑器接口确认并由审计/QA 独立验收。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。
