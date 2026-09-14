---
name: editor-utility-blueprint-library
description: UEditorUtilityBlueprintLibrary（UE 5.6）编辑器工具函数库 - 资产选择、编辑器UI交互、执行编辑器命令；在 Agent 需要通过 unreal Python 调用编辑器级工具功能时使用
risk: critical
category: development
tags: [ue5.6, editor, utility, blueprint-library, python]
---

# EditorUtilityBlueprintLibrary - Editor Utility Ops（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 调用编辑器级工具功能时使用本 skill（description 触发场景）。
- 本 skill 只在与 editor-utility-blueprint-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UEditorUtilityBlueprintLibrary` 暴露给 Python 的编辑器工具方法。方法名与签名依据 `Engine/Source/Editor/EditorUtilityBlueprintLibrary/Public/EditorUtilityBlueprintLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的 static 成员整理。

## 入口说明

static 函数在 Python 中以类方法形式暴露在 `unreal.EditorUtilityBlueprintLibrary` 上：

```python
import unreal

api = unreal.EditorUtilityBlueprintLibrary

# 选择资产
asset = unreal.load_asset("/Game/Assets/MyAsset")
api.select_asset(asset)
```

- **命名约定**：Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无该 meta 的按 C++ 函数名转 snake_case。精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- **Editor Only**：本库所有方法仅在编辑器 Python 可用（`WITH_EDITOR`）；运行时环境调用返回 `None` 或失败。
- **UI 交互**：部分方法会打开编辑器对话框或改变选择状态；自动化脚本需注意避免阻塞。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 选择 | `select_asset(asset)` | `void SelectAsset(UObject*)` | `None` |
| 选择 | `deselect_asset(asset)` | `void DeselectAsset(UObject*)` | `None` |
| 选择 | `get_selected_assets()` | `TArray<UObject*> GetSelectedAssets()` | `Array[Object]` |
| 选择 | `get_selected_external_assets()` | `TArray<FAssetData> GetSelectedAssetsFromAssetSelection()` | `Array[AssetData]` |
| 对话框 | `open_folder_dialog(title, default_path)` | `FString OpenFolderDialog(const FString&)` | `str` 或空串 |
| 对话框 | `open_file_dialog(title, default_path, file_types, default_file)` | `FString OpenFileDialog(const FString&, const FString&, const FString&, const FString&)` | `str` 或空串 |
| 对话框 | `save_file_dialog(title, default_path, file_types, default_file)` | `FString SaveFileDialog(const FString&, const FString&, const FString&, const FString&)` | `str` 或空串 |
| 对话框 | `prompt_for_folder(title, default_path)` | `FString PromptForFolder(const FString&)` | `str` 或空串 |
| 对话框 | `prompt_save_file(title, default_path, file_types, default_file)` | `FString PromptSaveFileDialog(const FString&, const FString&, const FString&, const FString&)` | `str` 或空串 |
| 提示 | `display_message(title, message)` | `void DisplayMessage(const FString&, const FString&)` | `None` |
| 提示 | `display_error(title, message)` | `void DisplayError(const FString&, const FString&)` | `None` |
| 提示 | `prompt_yes_no(title, message)` | `bool PromptYesNo(const FString&, const FString&)` | `bool` |
| 提示 | `prompt_retry_cancel(title, message)` | `bool PromptRetryCancel(const FString&, const FString&)` | `bool` |
| 资产 | `get_selected_blueprint()` | `UBlueprint* GetSelectedBlueprint()` | `Blueprint` 或 `None` |
| 资产 | `get_selected_actor()` | `AActor* GetSelectedActor()` | `Actor` 或 `None` |
| 资产 | `get_selected_level_actors()` | `TArray<AActor*> GetSelectedLevelActors()` | `Array[Actor]` |
| 执行 | `run_blueprint_action(bp_class, action_name)` | `void RunBlueprintAction(UClass*, const FString&)` | `None` |
| 执行 | `compile_blueprint(bp_class)` | `void CompileBlueprint(UClass*)` | `None` |
| 执行 | `save_blueprint(bp_class)` | `void SaveBlueprint(UClass*)` | `None` |

## 示例

```python
import unreal

api = unreal.EditorUtilityBlueprintLibrary

# 选择资产
asset = unreal.load_asset("/Game/Assets/MyAsset")
if asset:
    api.select_asset(asset)
    print("asset selected:", asset.get_name())

# 获取当前选择
selected = api.get_selected_assets()
print("selected count:", len(selected))

# 打开文件对话框
path = api.open_file_dialog("Select Asset", "C:/", "*.uasset", "*.uasset")
if path:
    print("selected:", path)

# 提示用户
ok = api.prompt_yes_no("Confirm", "Do you want to continue?")
if ok:
    print("user confirmed")
else:
    print("user cancelled")
```

## 限制和注意事项

- **Editor Only**：本库所有方法仅编辑器 Python 可用；PIE/运行时环境调用返回 `BLOCKED_TOOLING`。
- **UI 阻塞**：`prompt_*` / `open_*_dialog` 等方法会打开模态对话框；自动化脚本需避免调用或处理用户交互。
- `get_selected_*` 系列返回编辑器当前选择状态；选择为空时返回空数组，不视为错误。
- `run_blueprint_action` / `compile_blueprint` / `save_blueprint` 需要有效的 `BlueprintClass`；类不存在或编译失败时返回 `None`（不抛异常）。
- 资产选择后需等待编辑器更新；`save_asset` 等持久化操作需单独调用 `unreal.EditorAssetLibrary`。
- 缺有效资产/上下文返回 `BLOCKED_INPUT`；无编辑器环境返回 `BLOCKED_TOOLING`。
- 本库为编辑器交互与选择工具，不修改资产内容本身，仅为编辑器操作入口。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。
