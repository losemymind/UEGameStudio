# KismetInternationalizationLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetInternationalizationLibrary.h` 整理 `UKismetInternationalizationLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的成员（共 15 个）。方法命名取 `meta=(ScriptMethod=...)` 值转 snake_case；本类方法均无 `ScriptMethod`，故按 C++ 函数名转 snake_case。culture 一律为 IETF 语言标签（如 `"zh-Hans-CN"`）。

## 阻塞状态与诚实性（前置约定）

- `BLOCKED_INPUT`：缺少必要输入，或传入的 culture 没有对应本地化数据、asset group 不存在。
- `BLOCKED_TOOLING`：运行时本地化/国际化系统不可用，无法读取或切换。
- 文化获取依赖运行时本地化配置，设置后由 QA/本地化验收；本文件方法为标称方法，精确 Python 暴露名需在目标 UE 5.6 Editor 实测确认。

## 设置当前文化

### set_current_culture

- C++ 签名：`bool SetCurrentCulture(const FString& Culture, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`set_current_culture(culture, save_to_config=False) -> bool`
- 说明：同时设置语言与区域并清除已设置的 asset group 文化；参数 `SaveToConfig` 为 True 时写入 `GameUserSettings` 配置持久化。
- 示例：

```python
import unreal

api = unreal.KismetInternationalizationLibrary
ok = api.set_current_culture("zh-Hans-CN")
if ok:
    print("culture switched")
else:
    print({"status": "BLOCKED_INPUT", "reason": "culture not available"})
```

### get_current_culture

- C++ 签名：`FString GetCurrentCulture()`（BlueprintPure）
- Python：`get_current_culture() -> str`
- 说明：获取当前 culture（IETF 语言标签）；与 `get_current_language()` 等价，为旧 API 兼容保留。
- 示例：

```python
print("culture:", api.get_current_culture())
```

## 设置当前语言

### set_current_language

- C++ 签名：`bool SetCurrentLanguage(const FString& Culture, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`set_current_language(culture, save_to_config=False) -> bool`
- 说明：仅设置当前语言（用于本地化），不改变 locale；一般场景优先用 `set_current_language_and_locale` 或 `set_current_culture`。
- 示例：

```python
ok = api.set_current_language("zh-Hans-CN")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "language unavailable"})
```

### get_current_language

- C++ 签名：`FString GetCurrentLanguage()`（BlueprintPure）
- Python：`get_current_language() -> str`
- 说明：获取当前语言（用于本地化）。
- 示例：

```python
print("language:", api.get_current_language())
```

## 设置当前 locale

### set_current_locale

- C++ 签名：`bool SetCurrentLocale(const FString& Culture, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`set_current_locale(culture, save_to_config=False) -> bool`
- 说明：仅设置当前区域（用于国际化），不改变语言。
- 示例：

```python
ok = api.set_current_locale("zh-Hans-CN")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "locale unavailable"})
```

### get_current_locale

- C++ 签名：`FString GetCurrentLocale()`（BlueprintPure）
- Python：`get_current_locale() -> str`
- 说明：获取当前区域（用于国际化）。
- 示例：

```python
print("locale:", api.get_current_locale())
```

## 同时设置语言与区域

### set_current_language_and_locale

- C++ 签名：`bool SetCurrentLanguageAndLocale(const FString& Culture, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`set_current_language_and_locale(culture, save_to_config=False) -> bool`
- 说明：同时设置语言与区域；一般语言切换的首选入口。
- 示例：

```python
ok = api.set_current_language_and_locale("zh-Hans-CN")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "language and locale unavailable"})
```

## Asset Group 文化

### set_current_asset_group_culture

- C++ 签名：`bool SetCurrentAssetGroupCulture(FName AssetGroup, const FString& Culture, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`set_current_asset_group_culture(asset_group, culture, save_to_config=False) -> bool`
- 说明：为指定 asset group 类别设置文化覆盖。
- 示例：

```python
ok = api.set_current_asset_group_culture(unreal.Name("Audio"), "zh-Hans-CN")
if not ok:
    print({"status": "BLOCKED_INPUT", "reason": "asset group culture failed"})
```

### get_current_asset_group_culture

- C++ 签名：`FString GetCurrentAssetGroupCulture(FName AssetGroup)`（BlueprintPure）
- Python：`get_current_asset_group_culture(asset_group) -> str`
- 说明：获取指定 asset group 的文化；该组无覆盖时返回当前语言。
- 示例：

```python
print("audio culture:", api.get_current_asset_group_culture(unreal.Name("Audio")))
```

### clear_current_asset_group_culture

- C++ 签名：`void ClearCurrentAssetGroupCulture(FName AssetGroup, bool SaveToConfig = false)`（BlueprintCallable）
- Python：`clear_current_asset_group_culture(asset_group, save_to_config=False) -> None`
- 说明：清除指定 asset group 的 culture 覆盖，使该组回退到当前语言。
- 示例：

```python
api.clear_current_asset_group_culture(unreal.Name("Audio"))
```

## 原生文化

### get_native_culture

- C++ 签名：`FString GetNativeCulture(ELocalizedTextSourceCategory TextCategory)`（BlueprintPure）
- Python：`get_native_culture(text_category) -> str`
- 说明：获取给定本地化类别的原生文化；类别对应 `unreal.LocalizedTextSourceCategory.Game / .Engine / .Editor / .Additional`，精确枚举名需实测确认。
- 示例：

```python
print("native:", api.get_native_culture(unreal.LocalizedTextSourceCategory.Game))
```

## 本地化文化列表

### get_localized_cultures

- C++ 签名：`TArray<FString> GetLocalizedCultures(bool IncludeGame = true, bool IncludeEngine = false, bool IncludeEditor = false, bool IncludeAdditional = false)`（BlueprintPure）
- Python：`get_localized_cultures(include_game=True, include_engine=False, include_editor=False, include_additional=False) -> Array[str]`
- 说明：返回存在本地化数据的文化列表；默认只查 Game 资源，Engine/Editor/Additional 需显式开启。
- 示例：

```python
cultures = api.get_localized_cultures(include_game=True, include_engine=True)
print("localized cultures:", cultures)
```

## 文化匹配

### get_suitable_culture

- C++ 签名：`FString GetSuitableCulture(const TArray<FString>& AvailableCultures, const FString& CultureToMatch, const FString& FallbackCulture = TEXT("en"))`（BlueprintPure）
- Python：`get_suitable_culture(available_cultures, culture_to_match, fallback_culture="en") -> str`
- 说明：按文化优先级从候选列表中选出最合适的 culture；列表如 `["en", "fr", "de"]` 且待匹配为 `"en-US"` 时返回 `"en"`，无匹配返回 `FallbackCulture`（含回退，实际返回 `"en"` 或指定的回退值，原 fallback 为空时不会额外返回空）。
- 示例：

```python
cultures = api.get_localized_cultures(include_game=True)
match = api.get_suitable_culture(cultures, "zh-Hans-CN", "en")
print("suitable:", match)
```

## 文化显示名

### get_culture_display_name

- C++ 签名：`FString GetCultureDisplayName(const FString& Culture, bool Localized = true)`（BlueprintPure）
- Python：`get_culture_display_name(culture, localized=True) -> str`
- 说明：获取文化显示名；`localized=True` 用该文化自身语言显示，`False` 用当前语言；失败返回文化代码本身。
- 示例：

```python
print("display:", api.get_culture_display_name("zh-Hans-CN"))
print("in current lang:", api.get_culture_display_name("zh-Hans-CN", localized=False))
```

## 读写方向

### is_culture_right_to_left

- C++ 签名：`bool IsCultureRightToLeft(const FString& Culture)`（BlueprintPure）
- Python：`is_culture_right_to_left(culture) -> bool`
- 说明：返回该文化是否从右向左阅读（RTL）。
- 示例：

```python
if api.is_culture_right_to_left("ar"):
    print("right-to-left layout required")
```

## 完整示例：语言切换并取显示名

```python
import unreal

def main():
    api = unreal.KismetInternationalizationLibrary

    cultures = api.get_localized_cultures(include_game=True)
    if not cultures:
        print({"status": "BLOCKED_INPUT", "reason": "no localized culture data"})
        return

    target = api.get_suitable_culture(cultures, "zh-Hans-CN", "en")
    ok = api.set_current_language_and_locale(target)
    if not ok:
        print({"status": "BLOCKED_INPUT", "reason": "language switch failed"})
        return

    print({
        "language": api.get_current_language(),
        "locale": api.get_current_locale(),
        "display": api.get_culture_display_name(target),
    })

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入；culture / asset group 无本地化数据导致设置失败或返回空。
- `BLOCKED_TOOLING`：运行时本地化/国际化系统不可用。
- 设置 culture 属于运行时配置变更：默认不持久化，`save_to_config=True` 时写入 `GameUserSettings` 并需用户确认；切换后由 QA/本地化验收，Agent 不得断言本地化已生效。
- 本文件只收录头文件中带 `UFUNCTION` 标记、可由 Python 调用的成员；标称方法与精确 Python 暴露名（含枚举 `unreal.LocalizedTextSourceCategory`）需在目标 UE 5.6 Editor 实测确认后方可断言。