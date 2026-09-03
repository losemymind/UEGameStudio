---
name: kismet-internationalization-library
description: UE 5.6 本地化与国际化运行时 API（UKismetInternationalizationLibrary） - 读取与设置当前语言/区域/文化、文化显示名、原生文化、本地化文化列表、文化读写方向排序；在 Agent 需要通过 unreal Python 查询或切换游戏运行时本地化配置时使用
tags: [ue5.6, internationalization, localization, culture, python]
---

# KismetInternationalizationLibrary - 本地化与国际化（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UKismetInternationalizationLibrary` 暴露给 Python 的本地化（Localization）与国际化（Internationalization）运行时接口。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetInternationalizationLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理。

## 入口说明

```python
import unreal

api = unreal.KismetInternationalizationLibrary
```

- Python 类名为去掉 U 前缀的类名；全部成员为 static，以类方法形式调用。
- 方法命名为 `meta=(ScriptMethod=...)` 值转 snake_case；本类方法均无 `ScriptMethod`，故按 C++ 函数名转 snake_case。精确 Python 暴露名需实测确认。
- 传入的 culture 一律为 IETF 语言标签，如 `"zh-Hans-CN"`。文化设置/获取依赖运行时本地化配置。
- 文化相关输入缺省（如不存在传入 culture 的本地化数据）按 `BLOCKED_INPUT` 处理并停止。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 设置 | `set_current_culture(culture, save_to_config=False)` | `bool SetCurrentCulture(const FString&, bool)` | `bool` |
| 获取 | `get_current_culture()` | `FString GetCurrentCulture()` | `str` |
| 设置 | `set_current_language(culture, save_to_config=False)` | `bool SetCurrentLanguage(const FString&, bool)` | `bool` |
| 获取 | `get_current_language()` | `FString GetCurrentLanguage()` | `str` |
| 设置 | `set_current_locale(culture, save_to_config=False)` | `bool SetCurrentLocale(const FString&, bool)` | `bool` |
| 获取 | `get_current_locale()` | `FString GetCurrentLocale()` | `str` |
| 设置 | `set_current_language_and_locale(culture, save_to_config=False)` | `bool SetCurrentLanguageAndLocale(const FString&, bool)` | `bool` |
| 设置 | `set_current_asset_group_culture(asset_group, culture, save_to_config=False)` | `bool SetCurrentAssetGroupCulture(FName, const FString&, bool)` | `bool` |
| 获取 | `get_current_asset_group_culture(asset_group)` | `FString GetCurrentAssetGroupCulture(FName)` | `str` |
| 清除 | `clear_current_asset_group_culture(asset_group, save_to_config=False)` | `void ClearCurrentAssetGroupCulture(FName, bool)` | `None` |
| 获取 | `get_native_culture(text_category)` | `FString GetNativeCulture(ELocalizedTextSourceCategory)` | `str` |
| 查询 | `get_localized_cultures(include_game=True, include_engine=False, include_editor=False, include_additional=False)` | `TArray<FString> GetLocalizedCultures(bool, bool, bool, bool)` | `Array[str]` |
| 查询 | `get_suitable_culture(available_cultures, culture_to_match, fallback_culture="en")` | `FString GetSuitableCulture(const TArray<FString>&, const FString&, const FString&)` | `str` |
| 查询 | `get_culture_display_name(culture, localized=True)` | `FString GetCultureDisplayName(const FString&, bool)` | `str` |
| 查询 | `is_culture_right_to_left(culture)` | `bool IsCultureRightToLeft(const FString&)` | `bool` |

## 快速示例

```python
import unreal

api = unreal.KismetInternationalizationLibrary

current = api.get_current_language()
print("current language:", current)

localized = api.get_localized_cultures(include_game=True)
print("game-localized cultures:", localized)

ok = api.set_current_language("zh-Hans-CN", save_to_config=False)
if not ok:
    print("language switch failed")

print("display name:", api.get_culture_display_name("zh-Hans-CN"))
```

## 注意事项

- `SetCurrentCulture` 是"大锤"接口：同时设置语言与区域并清除已设置的 asset group 文化；需要独立控制时使用 `set_current_language` / `set_current_locale` / `set_current_language_and_locale`。
- `SaveToConfig=True` 会把新设置写入 `GameUserSettings` 配置并持久化；未经确认不得在正式项目中开启持久化设置。
- 运行时切换语言/区域后，本会话内文本资源按新 culture 本地化，需由 QA/本地化验收，Agent 不自行断言本地化结果已生效。
- `clear_current_asset_group_culture` 无返回值（无 Out 参数），成功与否需实测确认。
- 缺传入 culture 的本地化数据时返回空列表或失败结果，按 `BLOCKED_INPUT` 处理；运行时本地化系统不可用时按 `BLOCKED_TOOLING` 处理。
- 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言。

详细 API 与完整示例见 `docs/overview.md`。