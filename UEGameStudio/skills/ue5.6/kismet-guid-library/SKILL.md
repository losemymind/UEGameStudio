---
name: kismet-guid-library
description: UKismetGuidLibrary（UE 5.6）GUID 蓝图函数库 - 相等/不等判定、有效性检查、失效、新建 GUID、GUID 转字符串与字符串解析；在 Agent 需要通过 unreal Python 生成或解析 GUID、校验 GUID 有效性时使用
risk: safe
category: development
tags: [ue5.6, kismet, guid, python, blueprint-function-library]
---

# KismetGuidLibrary - GUID 工具（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 生成或解析 GUID、校验 GUID 有效性时使用本 skill（description 触发场景）。
- 本 skill 只在与 kismet-guid-library 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UKismetGuidLibrary` 暴露给 Python 的 GUID 静态工具函数。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetGuidLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理；Python 方法名由 C++ 函数名按反射约定转 snake_case。

## 入口说明

所有函数均为 static，以类方法形式调用：

```python
import unreal
api = unreal.KismetGuidLibrary
```

- 无子类示例之外的实例化或编辑器上下文要求；函数为无状态纯工具。库不可用时按 `BLOCKED_TOOLING` 处理。
- GUID 参数为 `unreal.Guid`，字符串参数为 `str`。
- 命名约定：C++ 函数名转 snake_case，例如 `IsValid_Guid` -> `is_valid_guid`。带 `meta=(ScriptMethod=...)` 的转换函数保留类方法命名，正文均按 C++ 函数名命名。
- 精确暴露名需在目标 UE 5.6 Editor 实测确认。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 判定 | `equal_equal_guid_guid(a, b)` | `bool EqualEqual_GuidGuid(const FGuid&, const FGuid&)` | `bool` |
| 判定 | `not_equal_guid_guid(a, b)` | `bool NotEqual_GuidGuid(const FGuid&, const FGuid&)` | `bool` |
| 校验 | `is_valid_guid(in_guid)` | `bool IsValid_Guid(const FGuid&)` | `bool` |
| 失效 | `invalidate_guid(in_guid)` | `void Invalidate_Guid(UPARAM(ref) FGuid&)` | `None`（ref 参数就地失效） |
| 生成 | `new_guid()` | `FGuid NewGuid()` | `Guid` |
| 转换 | `conv_guid_to_string(in_guid)` | `FString Conv_GuidToString(const FGuid&)` | `str` |
| 解析 | `parse_string_to_guid(guid_string)` | `void Parse_StringToGuid(const FString&, FGuid& OutGuid, bool& Success)` | `Tuple[Guid, bool]` = `(out_guid, success)` |

## 示例

```python
import unreal

if not hasattr(unreal, "KismetGuidLibrary"):
    raise RuntimeError("BLOCKED_TOOLING: KismetGuidLibrary 不可用")

g = unreal.KismetGuidLibrary.new_guid()
print("guid:", unreal.KismetGuidLibrary.conv_guid_to_string(g))
print("valid:", unreal.KismetGuidLibrary.is_valid_guid(g))

out_guid, ok = unreal.KismetGuidLibrary.parse_string_to_guid(
    "A-B-C-D"
)
if not ok:
    print("parse failed")

g2 = g
unreal.KismetGuidLibrary.invalidate_guid(g2)
print("equal after invalidate:", unreal.KismetGuidLibrary.equal_equal_guid_guid(g, g2))
```

## 限制和注意事项

- 返回值约定：`void` + 单 Out 直接返回具体值；返回值 + Out 按元组返回（返回值在首位）；无 Out 返回 `None`。
- `invalidate_guid` 的入参是 `UPARAM(ref)`，失效发生在传入的 GUID 对象上：修改为 `guid(0,0,0,0)`；实际就地修改行为需在真实 Editor 实测确认。
- `parse_string_to_guid` 接受的标准格式见 `EGuidFormats`（如 `DigitsWithHyphens`），非标准字符串返回 `success=False`。
- 生成 GUID 具有全局唯一性；不要手工构造 GUID 冒充 `new_guid` 的产物。
- 无编辑器环境或库不可用时返回 `BLOCKED_TOOLING`；缺少必要输入返回 `BLOCKED_INPUT`。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。