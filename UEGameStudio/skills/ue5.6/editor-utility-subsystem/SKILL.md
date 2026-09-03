---
name: editor-utility-subsystem
description: UEditorUtilitySubsystem（UE 5.6）编辑器工具（Editor Utility Widget Blueprint）注册、执行、工具 Tab 与任务状态；在 Agent 需要通过 unreal Python 调度编辑器工具并管理工具 Tab 时使用
tags: [ue5.6, editor, tooling, python, subsystem]
---

# EditorUtilitySubsystem - Tool Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UEditorUtilitySubsystem` 暴露给 Python 的编辑器工具操作方法。方法名与签名依据 `Engine/Source/Editor/Blutility/Public/EditorUtilitySubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.EditorUtilitySubsystem)
```

- 返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 资产与蓝图类经 `unreal.EditorAssetLibrary.load_asset` / `unreal.load_class` 传入；TabID / 层名为 `FName`，Python 侧传 `str` 或 `unreal.Name`。
- 方法名由 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。
- Out 参数约定：`void` + 单个 Out 参数直接作为返回值返回；返回类型 + Out 参数按元组 `(返回值, Out...)` 返回。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 工具运行 | `try_run(asset)` | `bool TryRun(UObject*)` | `bool` |
| 工具运行 | `try_run_class(object_class)` | `bool TryRunClass(UClass*)` | `bool` |
| 工具运行 | `can_run(asset)` | `bool CanRun(UObject*) const` | `bool` |
| 工具运行 | `release_instance_of_asset(asset)` | `void ReleaseInstanceOfAsset(UObject*)` | `None` |
| 工具 Tab | `register_tab_and_get_id(in_blueprint)` | `void RegisterTabAndGetID(UEditorUtilityWidgetBlueprint*, FName&)` | `Name` |
| 工具 Tab | `spawn_and_register_tab(in_blueprint)` | `UEditorUtilityWidget* SpawnAndRegisterTab(UEditorUtilityWidgetBlueprint*)` | `EditorUtilityWidget` 或 `None` |
| 工具 Tab | `spawn_and_register_tab_and_get_id(in_blueprint)` | `UEditorUtilityWidget* SpawnAndRegisterTabAndGetID(UEditorUtilityWidgetBlueprint*, FName&)` | `tuple[EditorUtilityWidget, Name]` |
| 工具 Tab | `spawn_and_register_tab_with_id(in_blueprint, in_tab_id)` | `UEditorUtilityWidget* SpawnAndRegisterTabWithId(UEditorUtilityWidgetBlueprint*, FName)` | `EditorUtilityWidget` 或 `None` |
| 工具 Tab | `register_tab_and_get_id_generated_class(in_generated_widget_blueprint)` | `void RegisterTabAndGetIDGeneratedClass(UWidgetBlueprintGeneratedClass*, FName&)` | `Name` |
| 工具 Tab | `spawn_and_register_tab_generated_class(in_generated_widget_blueprint)` | `UEditorUtilityWidget* SpawnAndRegisterTabGeneratedClass(UWidgetBlueprintGeneratedClass*)` | `EditorUtilityWidget` 或 `None` |
| 工具 Tab | `spawn_and_register_tab_and_get_id_generated_class(in_generated_widget_blueprint)` | `UEditorUtilityWidget* SpawnAndRegisterTabAndGetIDGeneratedClass(UWidgetBlueprintGeneratedClass*, FName&)` | `tuple[EditorUtilityWidget, Name]` |
| 工具 Tab | `spawn_and_register_tab_with_id_generated_class(in_generated_widget_blueprint, in_tab_id)` | `UEditorUtilityWidget* SpawnAndRegisterTabWithIdGeneratedClass(UWidgetBlueprintGeneratedClass*, FName)` | `EditorUtilityWidget` 或 `None` |
| Tab 管理 | `spawn_registered_tab_by_id(new_tab_id)` | `bool SpawnRegisteredTabByID(FName)` | `bool` |
| Tab 管理 | `does_tab_exist(new_tab_id)` | `bool DoesTabExist(FName)` | `bool` |
| Tab 管理 | `close_tab_by_id(new_tab_id)` | `bool CloseTabByID(FName)` | `bool` |
| Tab 管理 | `unregister_tab_by_id(tab_id)` | `bool UnregisterTabByID(FName)` | `bool` |
| Tab 管理 | `find_utility_widget_from_blueprint(in_blueprint)` | `UEditorUtilityWidget* FindUtilityWidgetFromBlueprint(UEditorUtilityWidgetBlueprint*)` | `EditorUtilityWidget` 或 `None` |
| 工具任务 | `register_and_execute_task(new_task, optional_parent_task=None)` | `void RegisterAndExecuteTask(UEditorUtilityTask*, UEditorUtilityTask*)` | `None` |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.EditorUtilitySubsystem)

ui_asset = unreal.EditorAssetLibrary.load_asset("/Game/Editor/EW_PropScatter")
if ui_asset is None:
    print({"status": "BLOCKED_INPUT", "reason": "widget blueprint path 无法加载"})
else:
    tab_id = api.register_tab_and_get_id(ui_asset)
    widget = api.spawn_and_register_tab(ui_asset)
    print("tab registered:", tab_id, "spawned:", widget is not None)
    api.unregister_tab_by_id(tab_id)
```

## 注意事项

- 运行编辑器工具（Editor Utility Widget / Blueprint / Task）属工具管线，`ue-tools-pipeline-engineer` 为主责；本 skill 只负责通过 `UEditorUtilitySubsystem` 调度与查询状态。
- 工具运行可能产生外部副作用（改资产、执行批处理、触发出包等）：未列入白名单的工具不得直接运行，须先经总控/工具管线主责确认。
- `try_run` / `try_run_class` 运行工具蓝图实例；`can_run` 在运行前查询可行性。工具通常由 `EditorUtilityWidgetBlueprint` 定义，其运行时对象依赖编辑器 UI 上下文。
- `register_tab_and_get_id` 返回自动分配的 TabID；`spawn_and_register_tab_with_id` 允许脚本指定 TabID。
- 缺资产路径、`UEditorUtilityWidgetBlueprint`、`UClass`、TabID 等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。