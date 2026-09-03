# EditorUtilitySubsystem - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Editor/Blutility/Public/EditorUtilitySubsystem.h` 整理 `UEditorUtilitySubsystem` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员。方法名由 C++ 函数名按反射约定转 snake_case；精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。每个成员给出 C++ 签名、Python 参数、返回约定与示例。

## 获取子系统

```python
import unreal

api = unreal.get_editor_subsystem(unreal.EditorUtilitySubsystem)
if api is None:
    raise RuntimeError("BLOCKED_TOOLING: EditorUtilitySubsystem 不可用")
```

## 通用约定

- 资产与蓝图类经资产库加载后传入：`unreal.EditorAssetLibrary.load_asset` / `unreal.load_class`。
- TabID 为 `FName`，Python 侧传 `str` 或 `unreal.Name`。
- 返回值语义：`None`（对象找不到）、`False`（操作未发生）、空值区分正常结果与失败后再判定阻塞。
- 工具运行可能产生外部副作用；运行前先经工具管线主责/总控确认白名单，禁止直接执行未授权工具。

## 工具运行

### try_run

- C++ 签名：`bool TryRun(UObject* Asset)`
- Python：`try_run(asset) -> bool`
- 说明：运行指定资产对象对应的编辑器工具（如 `EditorUtilityWidgetBlueprint` 的实例）；运行成功返回 `True`。
- 示例：

```python
ui_asset = unreal.EditorAssetLibrary.load_asset("/Game/Editor/EW_PropScatter")
if ui_asset is None:
    print({"status": "BLOCKED_INPUT", "reason": "widget blueprint 无法加载"})
else:
    ok = api.try_run(ui_asset)
```

### try_run_class

- C++ 签名：`bool TryRunClass(UClass* ObjectClass)`
- Python：`try_run_class(object_class) -> bool`
- 说明：按蓝图类运行工具，等价于 `try_run` 的按类版本。
- 示例：

```python
tool_class = unreal.load_class("/Game/Editor/EW_PropScatter")
ok = api.try_run_class(tool_class)
```

### can_run

- C++ 签名：`bool CanRun(UObject* Asset) const`
- Python：`can_run(asset) -> bool`
- 说明：运行前查询给定资产是否可运行。
- 示例：

```python
if api.can_run(ui_asset):
    api.try_run(ui_asset)
```

### release_instance_of_asset

- C++ 签名：`void ReleaseInstanceOfAsset(UObject* Asset)`
- Python：`release_instance_of_asset(asset) -> None`
- 说明：释放资产对应的工具实例引用，允许其被垃圾回收。
- 示例：

```python
api.release_instance_of_asset(ui_asset)
```

## 工具 Tab（Widget Blueprint 注册与生成）

### register_tab_and_get_id

- C++ 签名：`void RegisterTabAndGetID(UEditorUtilityWidgetBlueprint* InBlueprint, FName& NewTabID)`
- Python：`register_tab_and_get_id(in_blueprint) -> Name`（Out 参数直接返回）
- 说明：注册工具 Widget Blueprint 为可生成的 Tab，返回自动分配的 TabID。
- 示例：

```python
tab_id = api.register_tab_and_get_id(ui_asset)
```

### spawn_and_register_tab

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTab(UEditorUtilityWidgetBlueprint* InBlueprint)`
- Python：`spawn_and_register_tab(in_blueprint) -> EditorUtilityWidget`
- 说明：注册并生成工具 Tab，返回生成的 Widget；失败返回 `None`。
- 示例：

```python
widget = api.spawn_and_register_tab(ui_asset)
```

### spawn_and_register_tab_and_get_id

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTabAndGetID(UEditorUtilityWidgetBlueprint* InBlueprint, FName& NewTabID)`
- Python：`spawn_and_register_tab_and_get_id(in_blueprint) -> tuple[EditorUtilityWidget, Name]`
- 说明：注册并生成工具 Tab，同时按元组返回 `(widget, new_tab_id)`。
- 示例：

```python
widget, tab_id = api.spawn_and_register_tab_and_get_id(ui_asset)
```

### spawn_and_register_tab_with_id

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTabWithId(UEditorUtilityWidgetBlueprint* InBlueprint, FName InTabID)`
- Python：`spawn_and_register_tab_with_id(in_blueprint, in_tab_id) -> EditorUtilityWidget`
- 说明：与 `spawn_and_register_tab_and_get_id` 不同，允许脚本指定 TabID 生成工具 Tab。
- 示例：

```python
widget = api.spawn_and_register_tab_with_id(ui_asset, "PropScatterTab")
```

### register_tab_and_get_id_generated_class

- C++ 签名：`void RegisterTabAndGetIDGeneratedClass(UWidgetBlueprintGeneratedClass* InGeneratedWidgetBlueprint, FName& NewTabID)`
- Python：`register_tab_and_get_id_generated_class(in_generated_widget_blueprint) -> Name`（Out 参数直接返回）
- 说明：按生成的 Widget 蓝图类注册工具 Tab，返回 TabID。
- 示例：

```python
gen_class = unreal.load_object(None, "/Game/Editor/EW_PropScatter")
tab_id = api.register_tab_and_get_id_generated_class(gen_class)
```

### spawn_and_register_tab_generated_class

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTabGeneratedClass(UWidgetBlueprintGeneratedClass* InGeneratedWidgetBlueprint)`
- Python：`spawn_and_register_tab_generated_class(in_generated_widget_blueprint) -> EditorUtilityWidget`
- 说明：按生成的 Widget 蓝图类注册并生成工具 Tab。
- 示例：

```python
widget = api.spawn_and_register_tab_generated_class(gen_class)
```

### spawn_and_register_tab_and_get_id_generated_class

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTabAndGetIDGeneratedClass(UWidgetBlueprintGeneratedClass* InGeneratedWidgetBlueprint, FName& NewTabID)`
- Python：`spawn_and_register_tab_and_get_id_generated_class(in_generated_widget_blueprint) -> tuple[EditorUtilityWidget, Name]`
- 说明：按生成的 Widget 蓝图类注册并生成工具 Tab，返回 `(widget, new_tab_id)`。
- 示例：

```python
widget, tab_id = api.spawn_and_register_tab_and_get_id_generated_class(gen_class)
```

### spawn_and_register_tab_with_id_generated_class

- C++ 签名：`UEditorUtilityWidget* SpawnAndRegisterTabWithIdGeneratedClass(UWidgetBlueprintGeneratedClass* InGeneratedWidgetBlueprint, FName InTabID)`
- Python：`spawn_and_register_tab_with_id_generated_class(in_generated_widget_blueprint, in_tab_id) -> EditorUtilityWidget`
- 说明：按生成的 Widget 蓝图类、指定 TabID 生成工具 Tab。
- 示例：

```python
widget = api.spawn_and_register_tab_with_id_generated_class(gen_class, "PropScatterTab")
```

## Tab 管理

### spawn_registered_tab_by_id

- C++ 签名：`bool SpawnRegisteredTabByID(FName NewTabID)`
- Python：`spawn_registered_tab_by_id(new_tab_id) -> bool`
- 说明：按 TabID 找到已注册的 Tab 生成器并生成 Tab；未找到对应生成器返回 `False`。
- 示例：

```python
ok = api.spawn_registered_tab_by_id(tab_id)
```

### does_tab_exist

- C++ 签名：`bool DoesTabExist(FName NewTabID)`
- Python：`does_tab_exist(new_tab_id) -> bool`
- 说明：按 TabID 检查 Tab 是否已存在。
- 示例：

```python
present = api.does_tab_exist(tab_id)
```

### close_tab_by_id

- C++ 签名：`bool CloseTabByID(FName NewTabID)`
- Python：`close_tab_by_id(new_tab_id) -> bool`
- 说明：按 TabID 查找并关闭已有 Tab；未找到返回 `False`。
- 示例：

```python
ok = api.close_tab_by_id(tab_id)
```

### unregister_tab_by_id

- C++ 签名：`bool UnregisterTabByID(FName TabID)`
- Python：`unregister_tab_by_id(tab_id) -> bool`
- 说明：关闭并反注册经本子系统注册的工具 Tab；未找到返回 `False`。
- 示例：

```python
ok = api.unregister_tab_by_id(tab_id)
```

### find_utility_widget_from_blueprint

- C++ 签名：`UEditorUtilityWidget* FindUtilityWidgetFromBlueprint(UEditorUtilityWidgetBlueprint* InBlueprint)`
- Python：`find_utility_widget_from_blueprint(in_blueprint) -> EditorUtilityWidget`
- 说明：按 Widget Blueprint 获取当前处于 Tab 中的 Widget；未在 Tab 中时返回 `None`。
- 示例：

```python
widget = api.find_utility_widget_from_blueprint(ui_asset)
```

## 工具任务

### register_and_execute_task

- C++ 签名：`void RegisterAndExecuteTask(UEditorUtilityTask* NewTask, UEditorUtilityTask* OptionalParentTask = nullptr)`
- Python：`register_and_execute_task(new_task, optional_parent_task=None) -> None`
- 说明：注册并执行一个 `EditorUtilityTask`，可选传入父任务；失败与实例状态由任务对象自身报告。
- 示例：

```python
task = unreal.EditorUtilityTask()  # 实际为已生成的工具任务实例
api.register_and_execute_task(task)
```

## 完整示例：注册、生成并清理工具 Tab

```python
import unreal

def main():
    api = unreal.get_editor_subsystem(unreal.EditorUtilitySubsystem)
    if api is None:
        print({"status": "BLOCKED_TOOLING", "reason": "EditorUtilitySubsystem 不可用"})
        return

    ui_asset = unreal.EditorAssetLibrary.load_asset("/Game/Editor/EW_PropScatter")
    if ui_asset is None:
        print({"status": "BLOCKED_INPUT", "reason": "widget blueprint path 无法加载"})
        return
    if not api.can_run(ui_asset):
        print({"status": "BLOCKED_INPUT", "reason": "工具不可运行"})
        return

    widget, tab_id = api.spawn_and_register_tab_and_get_id(ui_asset)
    if widget is None:
        print({"status": "BLOCKED_TOOLING", "reason": "工具 Tab 生成失败"})
        return

    run_ok = api.try_run(ui_asset)
    closed = api.unregister_tab_by_id(tab_id)

    print({"status": "OK", "tab_id": tab_id, "ran": run_ok, "unregistered": closed})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（资产路径、`UEditorUtilityWidgetBlueprint`、`UClass`、TabID 等），或资产/类无法加载、工具不可运行。
- `BLOCKED_TOOLING`：`EditorUtilitySubsystem` 或编辑器脚本上下文不可用，无法执行。
- 运行编辑器工具（Editor Utility Widget / Blueprint / Task）属工具管线，`ue-tools-pipeline-engineer` 为主责；工具运行可能产生外部副作用（改资产、批处理、出包等），未列入白名单的工具不得直接运行，须先经总控/工具管线主责确认。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认后方可断言。