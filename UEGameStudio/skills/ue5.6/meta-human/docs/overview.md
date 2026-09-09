# MetaHuman 插件 - 完整 API 参考（UE 5.6）

**插件：** MetaHuman  
**要求：** 需在UE编辑器中启用 MetaHuman 插件  
**运行时：** 仅编辑器 Python（`WITH_EDITOR`）  
**未实测声明：** 未在真实 UE 5.6 Editor 中实测的调用不做"已验证"断言

---

## 一、MetaHuman 创建（Creation）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `create_meta_human_frompreset(preset_path)` | `FMetaHumanCreateResult CreateMetaHumanFromPreset(const FString&)`（WITH_EDITOR） | `CreateResult` |
| `create_meta_human_from_anthropometry(anthropometry)` | `FMetaHumanCreateResult CreateMetaHumanFromAnthropometry(const FMetaHumanAnthropometry&)`（WITH_EDITOR） | `CreateResult` |
| `create_meta_human_from_parameters(parameters)` | `FMetaHumanCreateResult CreateMetaHumanFromParameters(const FMetaHumanParameters&)`（WITH_EDITOR） | `CreateResult` |
| `create_meta_human_from_parameters_and_gender(parameters, gender)` | `FMetaHumanCreateResult CreateMetaHumanFromParametersAndGender(const FMetaHumanParameters&, EMetaHumanGender::Type)`（WITH_EDITOR） | `CreateResult` |

---

## 二、MetaHuman 查询（Query）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_meta_human_anthropometry(meta_human_actor)` | `FMetaHumanAnthropometry GetMetaHumanAnthropometry(AActor*)`（WITH_EDITOR） | `Anthropometry` |
| `get_meta_human_parameters(meta_human_actor)` | `FMetaHumanParameters GetMetaHumanParameters(AActor*)`（WITH_EDITOR） | `Parameters` |
| `get_meta_human_gender(meta_human_actor)` | `EMetaHumanGender::Type GetMetaHumanGender(AActor*)`（WITH_EDITOR） | `int` |
| `get_meta_human_race(meta_human_actor)` | `EMetaHumanRace::Type GetMetaHumanRace(AActor*)`（WITH_EDITOR） | `int` |
| `get_meta_human_version(meta_human_actor)` | `int32 GetMetaHumanVersion(AActor*)`（WITH_EDITOR） | `int` |

---

## 三、MetaHuman 修改（Modification）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `modify_meta_human_parameters(meta_human_actor, parameters)` | `void ModifyMetaHumanParameters(AActor*, const FMetaHumanParameters&)`（WITH_EDITOR） | `None` |
| `modify_meta_human_gender(meta_human_actor, gender)` | `void ModifyMetaHumanGender(AActor*, EMetaHumanGender::Type)`（WITH_EDITOR） | `None` |
| `modify_meta_human_race(meta_human_actor, race)` | `void ModifyMetaHumanRace(AActor*, EMetaHumanRace::Type)`（WITH_EDITOR） | `None` |

---

## 四、Anthropometry 操作（Anthropometry）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_anthropometry_id(anthropometry)` | `FString GetAnthropometryID(const FMetaHumanAnthropometry&)` | `str` |
| `get_anthropometry_height_cm(anthropometry)` | `float GetAnthropometryHeightCm(const FMetaHumanAnthropometry&)` | `float` |
| `get_anthropometry_body_type(anthropometry)` | `float GetAnthropometryBodyType(const FMetaHumanAnthropometry&)` | `float` |
| `get_anthropometry_head_size(anthropometry)` | `float GetAnthropometryHeadSize(const FMetaHumanAnthropometry&)` | `float` |
| `get_anthropometry_weight_kg(anthropometry)` | `float GetAnthropometryWeightKg(const FMetaHumanAnthropometry&)` | `float` |
| `get_anthropometry_facial_features(anthropometry)` | `TMap<FString, float> GetAnthropometryFacialFeatures(const FMetaHumanAnthropometry&)` | `Dict[str, float]` |

---

## 五、Preset 操作（Presets）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `save_meta_human_as_preset(meta_human_actor, preset_path)` | `bool SaveMetaHumanAsPreset(AActor*, const FString&)`（WITH_EDITOR） | `bool` |
| `load_meta_human_preset(preset_path)` | `FMetaHumanParameters LoadMetaHumanPreset(const FString&)`（WITH_EDITOR） | `Parameters` |
| `get_preset_metadata(preset_path)` | `FMetaHumanPresetMetadata GetPresetMetadata(const FString&)`（WITH_EDITOR） | `Metadata` |

---

## 六、CreateResult 对象接口（CreateResult）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `is_success(create_result)` | `bool IsSuccess(const FMetaHumanCreateResult&)` | `bool` |
| `get_error_message(create_result)` | `FString GetErrorMessage(const FMetaHumanCreateResult&)` | `str` |
| `get_meta_human_actor(create_result)` | `AActor* GetMetaHumanActor(const FMetaHumanCreateResult&)`（WITH_EDITOR） | `Actor \| None` |
| `get_anthropometry(create_result)` | `FMetaHumanAnthropometry GetAnthropometry(const FMetaHumanCreateResult&)` | `Anthropometry` |

---

## 七、导入/导出（Import/Export）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `import_external_meta_human_asset(asset_path)` | `FMetaHumanCreateResult ImportExternalMetaHumanAsset(const FString&)`（WITH_EDITOR） | `CreateResult` |

---

## 八、辅助工具（Utilities）

| Python 方法 | C++ 签名 | 返回值 |
| --- | --- | --- |
| `get_supported_genders()` | `TArray<EMetaHumanGender::Type> GetSupportedGenders()` | `Array[int]` |
| `get_supported_races()` | `TArray<EMetaHumanRace::Type> GetSupportedRaces()` | `Array[int]` |
| `get_parameters_version()` | `int32 GetParametersVersion()` | `int` |

---

## 九、UFUNCTION 对应的 Python 方法清单

**所有 `UMetaHumanLibrary` 类的 `UFUNCTION()` 成员方法：**

1. `CreateMetaHumanFromPreset`
2. `CreateMetaHumanFromAnthropometry`
3. `CreateMetaHumanFromParameters`
4. `CreateMetaHumanFromParametersAndGender`
5. `GetMetaHumanAnthropometry`
6. `GetMetaHumanParameters`
6. `GetMetaHumanGender`
7. `GetMetaHumanRace`
8. `GetMetaHumanVersion`
9. `ModifyMetaHumanParameters`
10. `ModifyMetaHumanGender`
11. `ModifyMetaHumanRace`
12. `GetAnthropometryID`
13. `GetAnthropometryHeightCm`
14. `GetAnthropometryBodyType`
15. `GetAnthropometryHeadSize`
16. `GetAnthropometryWeightKg`
17. `GetAnthropometryFacialFeatures`
18. `SaveMetaHumanAsPreset`
19. `LoadMetaHumanPreset`
20. `GetPresetMetadata`
21. `IsSuccess`
22. `GetErrorMessage`
23. `GetMetaHumanActor`
24. `GetAnthropometry`
25. `ImportExternalMetaHumanAsset`
26. `GetSupportedGenders`
27. `GetSupportedRaces`
28. `GetParametersVersion`

**说明：**
- `WITH_EDITOR` 限定方法仅编辑器 Python 可用
- `FMetaHumanCreateResult` 为结构体，需通过 `IsSuccess` / `GetErrorMessage` / `GetMetaHumanActor` 等方法访问
- 实际暴露的方法以目标编辑器 `help(unreal.MetaHumanLibrary)` 输出为准

---

## 十、支持的性别与种族

**性别类型（典型）：**
- `EMetaHumanGender::MALE` (0)
- `EMetaHumanGender::FEMALE` (1)

**种族类型（典型）：**
- `EMetaHumanRace::CAUCASIAN` (0)
- `EMetaHumanRace::AFRICAN` (1)
- `EMetaHumanRace::ASIAN` (2)
- `EMetaHumanRace::INDIAN` (3)
- `EMetaHumanRace::HISPANIC` (4)

**注意：**实际支持的性别与种族因插件版本与内容包而异，务必通过 `get_supported_genders()` 与 `get_supported_races()` 在目标环境验证。

---

## 十一、使用限制与要求

- **插件依赖：** 项目必须在 Edit > Plugins > MetaHuman 中启用插件并重载
- **编辑器限制：** 全部方法需在编辑器 Python 中调用（`unreal.System.is_running_in_editor() == True`）
- **BLOCKED_TOOLING：** 项目未启用 MetaHuman 插件或非编辑器环境返回 `BLOCKED_TOOLING`
- **BLOCKED_INPUT：** 缺少 Preset 路径、文件不存在或资源不足返回 `BLOCKED_INPUT`
- **写入持久化：** 修改后的 MetaHuman 需调用 `unreal.EditorAssetLibrary.save_asset()` 固化
- **未实测调用：** 本表未在真实 UE 5.6 Editor 中实测，调用前需在目标 5.6 环境验证
- **资源要求：** MetaHuman 实例化需要大量 GPU 内存与磁盘空间，创建失败可能因资源不足
