---
name: asset-editor-subsystem
description: UAssetEditorSubsystem（UE 5.6）资产编辑器子系统 - 打开/关闭资产编辑器；在 Agent 需要通过 unreal Python 打开或关闭资产编辑器时使用
tags: [ue5.6, editor, asset, python, subsystem]
---

# AssetEditorSubsystem - Asset Editor Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UAssetEditorSubsystem` 暴露给 Python 的资产编辑器操作方法。方法名与签名依据 `Engine/Source/Editor/UnrealEd/Public/Subsystems/AssetEditorSubsystem.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case，精确 Python 暴露名需实测确认。

## 入口说明

从 UE Python 获取本子系统：

```python
import unreal
api = unreal.get_editor_subsystem(unreal.AssetEditorSubsystem)
```

- `UAssetEditorSubsystem` 继承自 `UEditorSubsystem`，用 `get_editor_subsystem` 获取；返回 `None` 表示编辑器脚本上下文不可用，按 `BLOCKED_TOOLING` 处理并停止。
- 本子系统只管理已加载资产的编辑器生命周期，不负责资产的加载与保存。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 打开 | `open_editor_for_assets(assets, opened_method=...)` | `bool OpenEditorForAssets(const TArray<UObject*>&, EAssetTypeActivationOpenedMethod)` | `bool` |
| 关闭 | `close_all_editors_for_asset(asset)` | `int32 CloseAllEditorsForAsset(UObject*)` | `int`（关闭的编辑器数量） |

## 快速示例

```python
import unreal

api = unreal.get_editor_subsystem(unreal.AssetEditorSubsystem)
asset = unreal.EditorAssetLibrary.load_asset("/Game/Maps/Main")
if asset is None:
    print("BLOCKED_INPUT: asset not found")

opened = api.open_editor_for_assets([asset])
if not opened:
    print("editor not opened")

closed = api.close_all_editors_for_asset(asset)
print("closed editors:", closed)
```

## 注意事项

- `open_editor_for_assets` 的 `assets` 是已加载资产对象数组；未加载的资产请先经 `unreal.EditorAssetLibrary` 加载。
- `opened_method` 取 `unreal.AssetTypeActivationOpenedMethod` 的 `EDIT` / `VIEW`，缺省为 `EDIT`。
- 目标资产已打开时不会新建窗口，而是将已有编辑器前置。
- `close_all_editors_for_asset` 返回本次实际关闭的编辑器数量。
- 打开/关闭属于编辑器会话状态而非内容修改；涉及内容写入仍须经编辑器接口保存并由审计/QA 独立验收。
- 缺资产对象等必要输入时返回 `BLOCKED_INPUT`；子系统或编辑器上下文不可用时返回 `BLOCKED_TOOLING`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。