---
name: editor-config-subsystem
description: UEditorConfigSubsystem（UE 5.6）编辑器配置子系统 - 按 UClass 的 EditorConfig 元数据保存/加载 UObject 配置；在 Agent 需要通过 unreal Python 管理编辑器配置持久化时使用
risk: critical
category: development
tags: [ue5.6, editor, config, python, subsystem]
---

# EditorConfigSubsystem - Config Persistence（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 管理编辑器配置持久化时使用本 skill（description 触发场景）。
- 本 skill 只在与 editor-config-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UEditorConfigSubsystem` 的编辑器配置保存/加载操作。方法名与签名依据 `Engine/Source/Editor/EditorConfig/Public/EditorConfigSubsystem.h` 声明的公开成员整理。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.EditorConfigSubsystem)
```

- `UEditorConfigSubsystem` 派生自 `UEditorSubsystem`，通过 `unreal.get_editor_subsystem` 获取。
- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 配置文件名来自 UClass 的 `EditorConfig="ConfigName"` 元数据。
- Python 方法名约定：C++ 函数名按反射约定转 snake_case，精确 Python 暴露名需实测确认。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 加载 | `load_config_object(class_, object, filter=...)` | `bool LoadConfigObject(const UClass*, UObject*, FEditorConfig::EPropertyFilter)` | `bool` |
| 保存 | `save_config_object(class_, object, filter=...)` | `bool SaveConfigObject(const UClass*, const UObject*, FEditorConfig::EPropertyFilter)` | `bool` |
| 查找 | `find_or_load_config(config_name, included_types=...)` | `TSharedRef<FEditorConfig> FindOrLoadConfig(FStringView, ESearchDirectoryType)` | `FEditorConfig` 配置引用 |
| 保存 | `save_config(config)` | `void SaveConfig(TSharedRef<FEditorConfig>)` | `None` |
| 重载 | `reload_config(config)` | `bool ReloadConfig(TSharedRef<FEditorConfig>)` | `bool` |
| 搜索目录 | `add_search_directory(type_, search_dir)` | `void AddSearchDirectory(ESearchDirectoryType, FStringView)` | `None` |
| 搜索目录 | `early_add_search_directory(type_, search_dir)` | `static void EarlyAddSearchDirectory(ESearchDirectoryType, FStringView)` | `None` |

## 示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.EditorConfigSubsystem)
if api is None:
    print({"status": "BLOCKED_TOOLING", "reason": "EditorConfigSubsystem 不可用"})
    raise SystemExit(1)

asset = unreal.EditorAssetLibrary.load_asset("/Game/ExampleAsset")  # UClass 声明 EditorConfig="..." 元数据
if asset is None:
    print({"status": "BLOCKED_INPUT", "reason": "缺少目标对象"})
    raise SystemExit(1)

cls = asset.get_class()
loaded = api.load_config_object(cls, asset)
saved = api.save_config_object(cls, asset)
print({"status": "OK", "loaded": loaded, "saved": saved})
```

## 限制和注意事项

- 配置以 JSON 落盘，搜索目录按 Engine → Project → ProjectOverrides → User 层级组织。
- `load_config_object` / `save_config_object` 依赖 UClass 的 `EditorConfig="ConfigName"` 元数据定位配置文件；元数据缺失时加载/保存失败。
- 过滤参数对应 `FEditorConfig::EPropertyFilter`：`MetadataOnly`（仅处理带 EditorConfig 元数据的属性，默认）与 `All`（处理全部属性）。
- `early_add_search_directory` 只能在子系统初始化前注册搜索层，初始化后调用会断言。
- 配置读写属于状态持久化：写入后须经编辑器接口确认并由审计/QA 独立验收。
- 缺类、对象等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。