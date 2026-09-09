---
name: meta-human
description: "MetaHuman插件（数字人资产） - MetaHuman创建、参数调整、动画绑定；需在UE中启用MetaHuman插件"
tags: [ue5.6, meta-human, digital-human, python, plugin]
---

# MetaHuman - 数字人资产系统（UE 5.6）

本 skill 描述 UE 5.6 引擎 `MetaHuman` 插件（需在UE编辑器中启用）通过 Python 可调用的类与函数。方法名与签名依据 `MetaHuman/Source/MetaHuman/Classes/MetaHuman.h` 中带 `UFUNCTION()` 标记的成员整理；Python 方法名按反射约定转 snake_case。

## 入口说明

```python
import unreal

# 创建 MetaHuman 示例（需编辑器环境）
result = unreal.MetaHumanLibrary.create_meta_human_frompreset("C:/Presets/Preset.json")
if result.is_success():
    anthropometry = result.get_anthropometry()
    print(f"Created: {result.get_meta_human_actor()}")
```

**实测要求：**
- 编辑器 Python 环境（非运行时）
- 项目已启用 `MetaHuman` 插件（Edit > Plugins > MetaHuman > Enabled + 重载）
- 带 `WITH_EDITOR` 限定的方法仅编辑器可用
- MetaHuman 实例化需要大量系统资源（GPU内存、磁盘空间）

**BLOCKED_TOOLING 处理：**
```python
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "MetaHuman 仅编辑器 Python 可用"})
    raise SystemExit(1)

meta_human_plugin = unreal.EditorPluginUtil.is_plugin_enabled("MetaHuman")
if not meta_human_plugin:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 MetaHuman 插件"})
    raise SystemExit(1)
```

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| **MetaHuman 创建** | | | |
| 从 Preset 创建 | `create_meta_human_frompreset(preset_path)` | `FMetaHumanCreateResult CreateMetaHumanFromPreset(const FString&)`（WITH_EDITOR） | `CreateResult` |
| 从 Anthropometry 创建 | `create_meta_human_from_anthropometry(anthropometry)` | `FMetaHumanCreateResult CreateMetaHumanFromAnthropometry(const FMetaHumanAnthropometry&)`（WITH_EDITOR） | `CreateResult` |
| 从参数集创建 | `create_meta_human_from_parameters(parameters)` | `FMetaHumanCreateResult CreateMetaHumanFromParameters(const FMetaHumanParameters&)`（WITH_EDITOR） | `CreateResult` |
| 从参数集与性别创建 | `create_meta_human_from_parameters_and_gender(parameters, gender)` | `FMetaHumanCreateResult CreateMetaHumanFromParametersAndGender(const FMetaHumanParameters&, EMetaHumanGender::Type)`（WITH_EDITOR） | `CreateResult` |
| **MetaHuman 查询** | | | |
| 获取 Anthropometry | `get_meta_human_anthropometry(meta_human_actor)` | `FMetaHumanAnthropometry GetMetaHumanAnthropometry(AActor*)`（WITH_EDITOR） | `Anthropometry` |
| 获取参数集 | `get_meta_human_parameters(meta_human_actor)` | `FMetaHumanParameters GetMetaHumanParameters(AActor*)`（WITH_EDITOR） | `Parameters` |
| 获取性别 | `get_meta_human_gender(meta_human_actor)` | `EMetaHumanGender::Type GetMetaHumanGender(AActor*)`（WITH_EDITOR） | `int` |
| 获取种族 | `get_meta_human_race(meta_human_actor)` | `EMetaHumanRace::Type GetMetaHumanRace(AActor*)`（WITH_EDITOR） | `int` |
| 获取版本 | `get_meta_human_version(meta_human_actor)` | `int32 GetMetaHumanVersion(AActor*)`（WITH_EDITOR） | `int` |
| **MetaHuman 修改** | | | |
| 修改参数 | `modify_meta_human_parameters(meta_human_actor, parameters)` | `void ModifyMetaHumanParameters(AActor*, const FMetaHumanParameters&)`（WITH_EDITOR） | `None` |
| 修改性别 | `modify_meta_human_gender(meta_human_actor, gender)` | `void ModifyMetaHumanGender(AActor*, EMetaHumanGender::Type)`（WITH_EDITOR） | `None` |
| 修改种族 | `modify_meta_human_race(meta_human_actor, race)` | `void ModifyMetaHumanRace(AActor*, EMetaHumanRace::Type)`（WITH_EDITOR） | `None` |
| **Anthropometry 操作** | | | |
| 获取 Anthropometry ID | `get_anthropometry_id(anthropometry)` | `FString GetAnthropometryID(const FMetaHumanAnthropometry&)` | `str` |
| 获取身高 | `get_anthropometry_height_cm(anthropometry)` | `float GetAnthropometryHeightCm(const FMetaHumanAnthropometry&)` | `float` |
| 获取体型 | `get_anthropometry_body_type(anthropometry)` | `float GetAnthropometryBodyType(const FMetaHumanAnthropometry&)` | `float` |
| 获取头部尺寸 | `get_anthropometry_head_size(anthropometry)` | `float GetAnthropometryHeadSize(const FMetaHumanAnthropometry&)` | `float` |
| 获取体重 | `get_anthropometry_weight_kg(anthropometry)` | `float GetAnthropometryWeightKg(const FMetaHumanAnthropometry&)` | `float` |
| 获取面部特征 | `get_anthropometry_facial_features(anthropometry)` | `TMap<FString, float> GetAnthropometryFacialFeatures(const FMetaHumanAnthropometry&)` | `Dict[str, float]` |
| **Preset 操作** | | | |
| 保存为 Preset | `save_meta_human_as_preset(meta_human_actor, preset_path)` | `bool SaveMetaHumanAsPreset(AActor*, const FString&)`（WITH_EDITOR） | `bool` |
| 加载 Preset | `load_meta_human_preset(preset_path)` | `FMetaHumanParameters LoadMetaHumanPreset(const FString&)`（WITH_EDITOR） | `Parameters` |
| 获取 Preset 元数据 | `get_preset_metadata(preset_path)` | `FMetaHumanPresetMetadata GetPresetMetadata(const FString&)`（WITH_EDITOR） | `Metadata` |
| **结果对象** | | | |
| 检查成功 | `is_success(create_result)` | `bool IsSuccess(const FMetaHumanCreateResult&)` | `bool` |
| 获取错误消息 | `get_error_message(create_result)` | `FString GetErrorMessage(const FMetaHumanCreateResult&)` | `str` |
| 获取 MetaHuman Actor | `get_meta_human_actor(create_result)` | `AActor* GetMetaHumanActor(const FMetaHumanCreateResult&)`（WITH_EDITOR） | `Actor` 或 `None` |
| 获取 Anthropometry | `get_anthropometry(create_result)` | `FMetaHumanAnthropometry GetAnthropometry(const FMetaHumanCreateResult&)` | `Anthropometry` |
| **导入/导出** | | | |
| 导入外部资产 | `import_external_meta_human_asset(asset_path)` | `FMetaHumanCreateResult ImportExternalMetaHumanAsset(const FString&)`（WITH_EDITOR） | `CreateResult` |
| **辅助** | | | |
| 获取支持性别 | `get_supported_genders()` | `TArray<EMetaHumanGender::Type> GetSupportedGenders()` | `Array[int]` |
| 获取支持种族 | `get_supported_races()` | `TArray<EMetaHumanRace::Type> GetSupportedRaces()` | `Array[int]` |
| 获取参数集版本 | `get_parameters_version()` | `int32 GetParametersVersion()` | `int` |

## 快速示例

```python
import unreal

# 1. 验证插件与环境
if not unreal.System.is_running_in_editor():
    print({"status": "BLOCKED_TOOLING", "reason": "MetaHuman 仅编辑器可用"})
    raise SystemExit(1)

plugin_enabled = unreal.EditorPluginUtil.is_plugin_enabled("MetaHuman")
if not plugin_enabled:
    print({"status": "BLOCKED_TOOLING", "reason": "项目未启用 MetaHuman 插件"})
    raise SystemExit(1)

# 2. 从 Preset 创建 MetaHuman
preset_path = "C:/Presets/LDefaultMale.json"
result = unreal.MetaHumanLibrary.create_meta_human_frompreset(preset_path)

if not result.is_success():
    print(f"BLOCKED_TOOLING: {result.get_error_message()}")
    raise SystemExit(1)

actor = result.get_meta_human_actor()
if actor is None:
    print("BLOCKED_TOOLING: Failed to get MetaHuman actor")
    raise SystemExit(1)

print(f"Created MetaHuman: {actor.get_actor_label()}")

# 3. 查询 Anthropometry
anthropometry = result.get_anthropometry()
height = unreal.MetaHumanLibrary.get_anthropometry_height_cm(anthropometry)
body_type = unreal.MetaHumanLibrary.get_anthropometry_body_type(anthropometry)
print(f"Height: {height:.1f}cm, BodyType: {body_type:.2f}")

# 4. 查询性别与种族
gender = unreal.MetaHumanLibrary.get_meta_human_gender(actor)
race = unreal.MetaHumanLibrary.get_meta_human_race(actor)
print(f"Gender: {gender}, Race: {race}")

# 5. 修改参数（仅限未锁定属性）
current_params = unreal.MetaHumanLibrary.get_meta_human_parameters(actor)
# 修改示例：调整发色（具体参数名需参考实际 Schema）
# unreal.MetaHumanLibrary.modify_meta_human_parameters(actor, modified_params)

# 6. 保存为新 Preset
new_preset_path = "C:/Presets/Custom_Preset.json"
success = unreal.MetaHumanLibrary.save_meta_human_as_preset(actor, new_preset_path)
print(f"Preset saved: {success}")

# 7. 批量导入（需验证文件存在）
preset_list = [
    "C:/Presets/MDefaultFemale.json",
    "C:/Presets/MDefaultMale.json",
]
for p in preset_list:
    if not unreal.Paths.file_exists(p):
        print(f"-skipped: {p} (not found)")
        continue
    create_result = unreal.MetaHumanLibrary.create_meta_human_frompreset(p)
    if create_result.is_success():
        print(f"Created: {create_result.get_meta_human_actor().get_actor_label()}")
    else:
        print(f"Failed: {p} - {create_result.get_error_message()}")
```

## 注意事项

- **阻塞处理：**
  - 缺少 Preset 路径、文件不存在等返回 `BLOCKED_INPUT`
  - 无编辑器环境、插件未启用或资源不足返回 `BLOCKED_TOOLING`
  - `WITH_EDITOR` 限定方法仅编辑器 Python 可用；非编辑器环境调用失败

- **返回值约定：**
  - `FMetaHumanCreateResult` 为结构体，提供 `is_success()`、`get_error_message()` 等接口
  - `void` + 单 Out 直接返回该值；返回值 + Out 按元组返回，返回值在首位
  - `AActor*` 返回对应 Python 对象或 `None`

- **资源要求：**
  - MetaHuman 实例化需要大量 GPU 内存与磁盘空间
  - 创建失败可能因资源不足，检查系统资源后重试

- **性别与种族：**
  - 支持性别：`EMetaHumanGender::MALE`、`EMetaHumanGender::FEMALE`（具体值需实测）
  - 支持种族：`EMetaHumanRace::CAUCASIAN`、`EMetaHumanRace::AFRICAN`、`EMetaHumanRace::ASIAN` 等
  - 修改性别/种族会重算全部形态参数

- **参数集 Schema：**
  - MetaHuman 参数集为复杂嵌套结构（`FMetaHumanParameters`）
  - 实际可用参数名需通过 `unreal.MetaHumanLibrary.get_meta_human_parameters()` 获取当前实例数据后探索
  - 未验证参数修改可能导致不可预期结果

- **持久化：**
  - 修改后的 MetaHuman 参数需调用 `unreal.EditorAssetLibrary.save_asset()` 固化
  - Preset 保存后可复用于批量创建

- **未实测声明：**
  - 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言
  - 方法名、签名、返回值类型需在 5.6 实际环境中通过 `dir(unreal.MetaHumanLibrary)`、`help()` 核对确认
  - 参数集 Schema 与支持选项因插件版本差异较大，务必在目标环境验证

详细 API 与完整示例见 `docs/overview.md`。
