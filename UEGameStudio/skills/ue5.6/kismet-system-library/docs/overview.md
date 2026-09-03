# KismetSystemLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetSystemLibrary.h` 整理 `UKismetSystemLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记、可由 Python 调用的全部成员，按头文件分组顺序逐组列出。Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case，无则按 C++ 函数名转 snake_case；精确 Python 暴露名需在目标 5.6 编辑器 `dir()`/`help()` 实测确认。

## 入口与通用约定

```python
import unreal

# 全部为静态方法，以类方法形式调用，无需实例：
api = unreal.KismetSystemLibrary
```

- 需要世界上下文的方法传入已归入世界的对象（例如 `unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()` 或任意运行世界中的 Actor）。
- Out/ByRef 参数返回约定：仅一个 Out 参数时直接返回该值；返回值与 Out 并存时按元组返回（返回值为首位）；无 Out 且无返回值时返回 `None`。
- 带 `(WITH_EDITOR)` 注记的方法仅在编辑器构建可用；带\"已弃用\"注记的方法仅在旧蓝图兼容中使用，新实现避免。
- 多数纯查询方法在编辑器与运行时均可调用；涉及世界上下文、Trace、延迟、定时器的方法只在对应世界语义（编辑器世界或 PIE/运行时）下有效。
- 命中与重叠返回的 `FHitResult` 在 Python 中为 `unreal.HitResult`；缺失实参、类路径不可加载按 `BLOCKED_INPUT`，对应上下文不可用按 `BLOCKED_TOOLING` 处理。

## 通用工具（Utilities）

### is_valid

- C++ 签名：`bool IsValid(const UObject* Object)`
- Python：`is_valid(object) -> bool`
- 说明：对象非空且未挂起销毁（PendingKill）时为 `True`。
- 示例：

```python
if api.is_valid(actor):
    print("actor usable")
```

### is_valid_class

- C++ 签名：`bool IsValidClass(UClass* Class)`
- Python：`is_valid_class(object_class) -> bool`
- 说明：类非空且未挂起销毁时为 `True`。
- 示例：

```python
if api.is_valid_class(unreal.load_class("/Game/Blueprints/BP_NPC")):
    print("class usable")
```

### get_object_name

- C++ 签名：`FString GetObjectName(const UObject* Object)`
- Python：`get_object_name(object) -> str`
- 说明：返回对象的实际名称。
- 示例：

```python
name = api.get_object_name(actor)
```

### get_path_name

- C++ 签名：`FString GetPathName(const UObject* Object)`
- Python：`get_path_name(object) -> str`
- 说明：返回对象的完整路径字符串（如 `/Game/Blueprints/BP_NPC.BP_NPC_C`）。
- 示例：

```python
path = api.get_path_name(actor)
```

### get_soft_object_path

- C++ 签名：`FSoftObjectPath GetSoftObjectPath(const UObject* Object)`
- Python：`get_soft_object_path(object) -> SoftObjectPath`
- 说明：返回对象的软对象路径。仅对象为资产时适用；非资产返回空路径。
- 示例：

```python
soft_path = api.get_soft_object_path(asset)
```

### get_system_path

- C++ 签名：`FString GetSystemPath(const UObject* Object)`
- Python：`get_system_path(object) -> str`
- 说明：返回对象对应资产的文件系统绝对路径；非资产对象返回空字符串。
- 示例：

```python
file_path = api.get_system_path(asset)
```

### get_display_name

- C++ 签名：`FString GetDisplayName(const UObject* Object)`
- Python：`get_display_name(object) -> str`
- 说明：返回显示名（编辑器内为 Actor 标签，运行时为对象名）。不用于唯一标识。非本地化。
- 示例：

```python
label = api.get_display_name(actor)
```

### get_class_display_name

- C++ 签名：`FString GetClassDisplayName(const UClass* Class)`
- Python：`get_class_display_name(object_class) -> str`
- 说明：返回类的显示名。
- 示例：

```python
display = api.get_class_display_name(actor.get_class())
```

### get_soft_class_path

- C++ 签名：`FSoftClassPath GetSoftClassPath(const UClass* Class)`
- Python：`get_soft_class_path(object_class) -> SoftClassPath`
- 说明：返回类的软类路径。
- 示例：

```python
scp = api.get_soft_class_path(actor.get_class())
```

### get_class_path_name

- C++ 签名：`FTopLevelAssetPath GetClassTopLevelAssetPath(const UClass* Class)`（Python 名来自 `ScriptMethod=GetClassPathName`）
- Python：`get_class_path_name(actor_class) -> TopLevelAssetPath`
- 说明：返回类的顶层资产路径（Asset Registry 使用的路径格式）。
- 示例：

```python
top_path = api.get_class_path_name(actor_class)
```

### get_struct_path_name

- C++ 签名：`FTopLevelAssetPath GetStructTopLevelAssetPath(const UScriptStruct* Struct)`（`ScriptMethod=GetStructPathName`）
- Python：`get_struct_path_name(struct) -> TopLevelAssetPath`
- 说明：返回结构体的顶层资产路径。
- 示例：

```python
top_path = api.get_struct_path_name(unreal.HitResult.struct_class())
```

### get_enum_path_name

- C++ 签名：`FTopLevelAssetPath GetEnumTopLevelAssetPath(const UEnum* Enum)`（`ScriptMethod=GetEnumPathName`）
- Python：`get_enum_path_name(enum) -> TopLevelAssetPath`
- 说明：返回枚举的顶层资产路径。
- 示例：

```python
enum_class = unreal.load_class("/Script/Engine.EAttachmentRule")
top_path = api.get_enum_path_name(enum_class)
```

### get_outer_object

- C++ 签名：`UObject* GetOuterObject(const UObject* Object)`
- Python：`get_outer_object(object) -> Object 或 None`
- 说明：返回对象的 Outer（外部对象）。
- 示例：

```python
outer = api.get_outer_object(actor)
```

### is_object_cooked（编辑器）

- C++ 签名：`bool IsObjectCooked(const UObject* Object)`（WITH_EDITOR）
- Python：`is_object_cooked(object) -> bool`
- 说明：返回对象是否已 Cook。
- 示例：

```python
cooked = api.is_object_cooked(asset)
```

### object_has_editor_only_data（编辑器）

- C++ 签名：`bool ObjectHasEditorOnlyData(const UObject* Object)`（WITH_EDITOR）
- Python：`object_has_editor_only_data(object) -> bool`
- 说明：返回对象是否包含仅编辑器使用的数据。
- 示例：

```python
has_editor_data = api.object_has_editor_only_data(actor)
```

### duplicate_object（编辑器）

- C++ 签名：`UObject* DuplicateObject(const UObject* SourceObject, UObject* Outer, const FName Name = NAME_None)`（WITH_EDITOR）
- Python：`duplicate_object(source_object, outer, name=None) -> Object 或 None`
- 说明：复制对象为新实例；失败返回 `None`。
- 示例：

```python
copy = api.duplicate_object(actor, actor.get_outer(), unreal.Name("Copy_01"))
```

### get_engine_version

- C++ 签名：`FString GetEngineVersion()`
- Python：`get_engine_version() -> str`
- 说明：返回引擎版本号（如 5.6 系列版本串）。
- 示例：

```python
ver = api.get_engine_version()
```

### get_build_version

- C++ 签名：`FString GetBuildVersion()`
- Python：`get_build_version() -> str`
- 说明：返回构建版本。
- 示例：

```python
bv = api.get_build_version()
```

### get_build_configuration

- C++ 签名：`FString GetBuildConfiguration()`
- Python：`get_build_configuration() -> str`
- 说明：返回构建配置（Development / Shipping 等）。
- 示例：

```python
cfg = api.get_build_configuration()
```

### get_game_name

- C++ 签名：`FString GetGameName()`
- Python：`get_game_name() -> str`
- 说明：返回当前项目名。
- 示例：

```python
game = api.get_game_name()
```

### get_game_bundle_id

- C++ 签名：`FString GetGameBundleId()`
- Python：`get_game_bundle_id() -> str`
- 说明：返回平台特定的游戏包标识名。运行时获取平台信息。
- 示例：

```python
bundle_id = api.get_game_bundle_id()
```

### get_project_directory

- C++ 签名：`FString GetProjectDirectory()`
- Python：`get_project_directory() -> str`
- 说明：返回当前项目根目录。
- 示例：

```python
root = api.get_project_directory()
```

### get_project_content_directory

- C++ 签名：`FString GetProjectContentDirectory()`
- Python：`get_project_content_directory() -> str`
- 说明：返回项目 Content 目录。
- 示例：

```python
content = api.get_project_content_directory()
```

### get_project_saved_directory

- C++ 签名：`FString GetProjectSavedDirectory()`
- Python：`get_project_saved_directory() -> str`
- 说明：返回项目 Saved 目录。
- 示例：

```python
saved = api.get_project_saved_directory()
```

### convert_to_relative_path

- C++ 签名：`FString ConvertToRelativePath(const FString& Filename)`
- Python：`convert_to_relative_path(filename) -> str`
- 说明：把文件名转换为相对路径。
- 示例：

```python
rel = api.convert_to_relative_path(r"E:/Proj/Content/X.y")
```

### convert_to_absolute_path

- C++ 签名：`FString ConvertToAbsolutePath(const FString& Filename)`
- Python：`convert_to_absolute_path(filename) -> str`
- 说明：把文件名转换为绝对路径。
- 示例：

```python
abs_path = api.convert_to_absolute_path("Content/X.y")
```

### normalize_filename

- C++ 签名：`FString NormalizeFilename(const FString& InFilename)`
- Python：`normalize_filename(in_filename) -> str`
- 说明：把路径中的 `\\` 与 `/` 统一为 `/`。
- 示例：

```python
norm = api.normalize_filename(r"Content\\X.y")
```

### get_platform_user_name

- C++ 签名：`FString GetPlatformUserName()`
- Python：`get_platform_user_name() -> str`
- 说明：返回当前操作系统用户名。
- 示例：

```python
user = api.get_platform_user_name()
```

### get_platform_user_dir

- C++ 签名：`FString GetPlatformUserDir()`
- Python：`get_platform_user_dir() -> str`
- 说明：返回当前操作系统用户目录。
- 示例：

```python
udir = api.get_platform_user_dir()
```

### does_implement_interface

- C++ 签名：`bool DoesImplementInterface(const UObject* TestObject, TSubclassOf<UInterface> Interface)`
- Python：`does_implement_interface(test_object, interface) -> bool`
- 说明：判断对象是否实现指定接口（原生与蓝图接口均可）。
- 示例：

```python
if api.does_implement_interface(actor, interface_class):
    print("implements interface")
```

### does_class_implement_interface

- C++ 签名：`bool DoesClassImplementInterface(const UClass* TestClass, TSubclassOf<UInterface> Interface)`
- Python：`does_class_implement_interface(test_class, interface) -> bool`
- 说明：判断类是否实现指定接口。
- 示例：

```python
ok = api.does_class_implement_interface(actor_class, interface_class)
```

### get_game_time_in_seconds

- C++ 签名：`double GetGameTimeInSeconds(const UObject* WorldContextObject)`
- Python：`get_game_time_in_seconds(world_context_object) -> float`
- 说明：返回世界游戏时间（暂停停止、受时移影响）。运行时可用。
- 示例：

```python
t = api.get_game_time_in_seconds(world_context)
```

### get_frame_count

- C++ 签名：`int64 GetFrameCount()`
- Python：`get_frame_count() -> int`
- 说明：返回已发生帧数（GFrameCounter）。
- 示例：

```python
frame = api.get_frame_count()
```

### get_platform_time_seconds（编辑器）

- C++ 签名：`double GetPlatformTime_Seconds()`（WITH_EDITOR）
- Python：`get_platform_time_seconds() -> float`
- 说明：返回当前平台时间（秒），用于执行计时/时间戳。
- 示例：

```python
ts = api.get_platform_time_seconds()
```

### raise_script_error

- C++ 签名：`void RaiseScriptError(const FString& ErrorMessage = TEXT("An error occurred"))`
- Python：`raise_script_error(error_message="An error occurred") -> None`
- 说明：以蓝图异常形式抛出错误，输出错误日志（仅开发环境生效）。
- 示例：

```python
api.raise_script_error("PRECONDITION FAILED")
```

### stack_trace

- C++ 签名：`void StackTrace()`（Development|Editor）
- Python：`stack_trace() -> None`（暴露名以实测为准）
- 说明：打印当前脚本调用栈；用于定位调用链。仅在相关构建可用。
- 示例：

```python
api.stack_trace()
```

## 网络与运行模式判定（Networking）

### is_server

- C++ 签名：`bool IsServer(const UObject* WorldContextObject)`
- Python：`is_server(world_context_object) -> bool`
- 说明：返回对象所在世界是否为服务端（Host）。
- 示例：

```python
host = api.is_server(world_context)
```

### is_dedicated_server

- C++ 签名：`bool IsDedicatedServer(const UObject* WorldContextObject)`
- Python：`is_dedicated_server(world_context_object) -> bool`
- 说明：返回是否运行在专用服务器上。编辑器纯编辑态无意义，视为 `BLOCKED_TOOLING` 场景。
- 示例：

```python
dedicated = api.is_dedicated_server(world_context)
```

### is_standalone

- C++ 签名：`bool IsStandalone(const UObject* WorldContextObject)`
- Python：`is_standalone(world_context_object) -> bool`
- 说明：返回当前是否为无网络的单机运行。
- 示例：

```python
standalone = api.is_standalone(world_context)
```

### is_split_screen（已弃用）

- C++ 签名：`bool IsSplitScreen(const UObject* WorldContextObject)`（已弃用，改用 `HasMultipleLocalPlayers`）
- Python：`is_split_screen(world_context_object) -> bool`
- 说明：旧分屏判定；新实现使用 `has_multiple_local_players`。
- 示例：

```python
old_split = api.is_split_screen(world_context)
```

### has_multiple_local_players

- C++ 签名：`bool HasMultipleLocalPlayers(const UObject* WorldContextObject)`
- Python：`has_multiple_local_players(world_context_object) -> bool`
- 说明：返回当前世界中是否多于一个本地玩家。
- 示例：

```python
multi = api.has_multiple_local_players(world_context)
```

### is_packaged_for_distribution

- C++ 签名：`bool IsPackagedForDistribution()`
- Python：`is_packaged_for_distribution() -> bool`
- 说明：返回是否为面向分发打包的构建。
- 示例：

```python
retail = api.is_packaged_for_distribution()
```

### get_unique_device_id（已弃用）

- C++ 签名：`FString GetUniqueDeviceId()`（已弃用，改用 `GetDeviceId`）
- Python：`get_unique_device_id() -> str`
- 说明：返回平台唯一设备 ID（旧接口）。
- 示例：

```python
uid = api.get_unique_device_id()
```

### get_device_id

- C++ 签名：`FString GetDeviceId()`
- Python：`get_device_id() -> str`
- 说明：返回平台唯一设备 ID。
- 示例：

```python
device_id = api.get_device_id()
```

## 类型转换（Conversion）

### conv_object_to_class

- C++ 签名：`UClass* Conv_ObjectToClass(UObject* Object, TSubclassOf<UObject> Class)`（Pure，Cast）
- Python：`conv_object_to_class(object, unreal_class) -> Class 或 None`
- 说明：把对象转为其类（对象本身必须是类实例才有效）。失败返回 `None`。
- 示例：

```python
bp_class = api.conv_object_to_class(actor_asset, unreal.load_class("/Game/Blueprints/BP_NPC"))
```

### conv_interface_to_object

- C++ 签名：`UObject* Conv_InterfaceToObject(const FScriptInterface& Interface)`（Pure）
- Python：`conv_interface_to_object(interface) -> Object 或 None`
- 说明：把接口实例转换为对象。Python 侧需以接口包装对象调用；未绑定对象返回 `None`。
- 示例：

```python
obj = api.conv_interface_to_object(tagged_interface)
```

### is_valid_interface

- C++ 签名：`bool IsValidInterface(const FScriptInterface& Interface)`（Pure）
- Python：`is_valid_interface(interface) -> bool`
- 说明：接口实例是否携带有效对象（原生与蓝图实现均有效）。
- 示例：

```python
if api.is_valid_interface(tagged_interface):
    print("valid interface")
```

### make_soft_object_path

- C++ 签名：`FSoftObjectPath MakeSoftObjectPath(const FString& PathString)`（Pure）
- Python：`make_soft_object_path(path_string) -> SoftObjectPath`
- 说明：由 `/folder/AssetName.ObjectName` 字符串构造 SoftObjectPath。
- 示例：

```python
soft_path = api.make_soft_object_path("/Game/Blueprints/BP_NPC.BP_NPC_C")
```

### break_soft_object_path

- C++ 签名：`void BreakSoftObjectPath(FSoftObjectPath InSoftObjectPath, FString& PathString)`（Pure，1 个 Out）
- Python：`break_soft_object_path(in_soft_object_path) -> str`
- 说明：把 SoftObjectPath 拆为路径字符串；单个 Out 直接返回。
- 示例：

```python
path_str = api.break_soft_object_path(soft_path)
```

### conv_soft_obj_path_to_soft_obj_ref

- C++ 签名：`TSoftObjectPtr<UObject> Conv_SoftObjPathToSoftObjRef(const FSoftObjectPath& SoftObjectPath)`（Pure）
- Python：`conv_soft_obj_path_to_soft_obj_ref(soft_object_path) -> SoftObjectReference`
- 说明：SoftObjectPath 转基础 SoftObjectReference（不保证可解析）。
- 示例：

```python
soft_ref = api.conv_soft_obj_path_to_soft_obj_ref(soft_path)
```

### conv_soft_obj_ref_to_soft_obj_path

- C++ 签名：`FSoftObjectPath Conv_SoftObjRefToSoftObjPath(TSoftObjectPtr<UObject> SoftObjectReference)`（Pure）
- Python：`conv_soft_obj_ref_to_soft_obj_path(soft_object_reference) -> SoftObjectPath`
- 说明：SoftObjectReference 转 SoftObjectPath。
- 示例：

```python
path = api.conv_soft_obj_ref_to_soft_obj_path(soft_ref)
```

### make_top_level_asset_path

- C++ 签名：`FTopLevelAssetPath MakeTopLevelAssetPath(UPARAM(DisplayName="FullPathOrPackageName") const FString& PackageName, const FString& AssetName)`（Pure）
- Python：`make_top_level_asset_path(package_name, asset_name) -> TopLevelAssetPath`
- 说明：由完整路径（或包名+资产名）构造 TopLevelAssetPath；可传 `"/Package"` 与 `"Asset"`。
- 示例：

```python
top = api.make_top_level_asset_path("/Game/Blueprints", "BP_NPC")
```

### break_top_level_asset_path

- C++ 签名：`void BreakTopLevelAssetPath(const FTopLevelAssetPath& TopLevelAssetPath, FString& PathString)`（Pure，1 个 Out）
- Python：`break_top_level_asset_path(top_level_asset_path) -> str`
- 说明：把 TopLevelAssetPath 拆为路径字符串。
- 示例：

```python
top_str = api.break_top_level_asset_path(top)
```

### make_soft_class_path

- C++ 签名：`FSoftClassPath MakeSoftClassPath(const FString& PathString)`（Pure）
- Python：`make_soft_class_path(path_string) -> SoftClassPath`
- 说明：由 `/folder/packagename.classname` 字符串构造 SoftClassPath；蓝图类需指向实际类（常带 `_C`）。
- 示例：

```python
scp = api.make_soft_class_path("/Game/Blueprints/BP_NPC.BP_NPC_C")
```

### break_soft_class_path

- C++ 签名：`void BreakSoftClassPath(FSoftClassPath InSoftClassPath, FString& PathString)`（Pure，1 个 Out）
- Python：`break_soft_class_path(in_soft_class_path) -> str`
- 说明：把 SoftClassPath 拆为路径字符串。
- 示例：

```python
scp_str = api.break_soft_class_path(scp)
```

### conv_soft_class_path_to_soft_class_ref

- C++ 签名：`TSoftClassPtr<UObject> Conv_SoftClassPathToSoftClassRef(const FSoftClassPath& SoftClassPath)`（Pure）
- Python：`conv_soft_class_path_to_soft_class_ref(soft_class_path) -> SoftClassReference`
- 说明：SoftClassPath 转基础 SoftClassReference（不保证可解析）。
- 示例：

```python
scr = api.conv_soft_class_path_to_soft_class_ref(scp)
```

### conv_soft_obj_ref_to_soft_class_path

- C++ 签名：`FSoftClassPath Conv_SoftObjRefToSoftClassPath(TSoftClassPtr<UObject> SoftClassReference)`（Pure）
- Python：`conv_soft_obj_ref_to_soft_class_path(soft_class_reference) -> SoftClassPath`
- 说明：SoftClassReference 转 SoftClassPath。
- 示例：

```python
scp = api.conv_soft_obj_ref_to_soft_class_path(scr)
```

### is_valid_soft_object_reference

- C++ 签名：`bool IsValidSoftObjectReference(const TSoftObjectPtr<UObject>& SoftObjectReference)`（Pure）
- Python：`is_valid_soft_object_reference(soft_object_reference) -> bool`
- 说明：SoftObjectReference 是否非空。
- 示例：

```python
if api.is_valid_soft_object_reference(soft_ref):
    print("ref valid")
```

### conv_soft_object_reference_to_string

- C++ 签名：`FString Conv_SoftObjectReferenceToString(const TSoftObjectPtr<UObject>& SoftObjectReference)`（Pure）
- Python：`conv_soft_object_reference_to_string(soft_object_reference) -> str`
- 说明：SoftObjectReference 转路径字符串。
- 示例：

```python
ref_str = api.conv_soft_object_reference_to_string(soft_ref)
```

### equal_equal_soft_object_reference

- C++ 签名：`bool EqualEqual_SoftObjectReference(const TSoftObjectPtr<UObject>& A, const TSoftObjectPtr<UObject>& B)`（Pure）
- Python：`equal_equal_soft_object_reference(a, b) -> bool`
- 说明：两个 SoftObjectReference 是否相等。
- 示例：

```python
same = api.equal_equal_soft_object_reference(soft_ref, other_ref)
```

### not_equal_soft_object_reference

- C++ 签名：`bool NotEqual_SoftObjectReference(const TSoftObjectPtr<UObject>& A, const TSoftObjectPtr<UObject>& B)`（Pure）
- Python：`not_equal_soft_object_reference(a, b) -> bool`
- 说明：两个 SoftObjectReference 是否不等。
- 示例：

```python
diff = api.not_equal_soft_object_reference(soft_ref, other_ref)
```

### load_asset_blocking

- C++ 签名：`UObject* LoadAsset_Blocking(TSoftObjectPtr<UObject> Asset)`（Callable）
- Python：`load_asset_blocking(asset) -> Object 或 None`
- 说明：同步加载软对象引用资产（阻塞；会造成卡顿，大量加载优先用流送方式）。
- 示例：

```python
loaded = api.load_asset_blocking(unreal.load_asset("/Game/Blueprints/BP_NPC"))
```

### is_valid_soft_class_reference

- C++ 签名：`bool IsValidSoftClassReference(const TSoftClassPtr<UObject>& SoftClassReference)`（Pure）
- Python：`is_valid_soft_class_reference(soft_class_reference) -> bool`
- 说明：SoftClassReference 是否非空。
- 示例：

```python
if api.is_valid_soft_class_reference(scr):
    print("class ref valid")
```

### get_soft_class_top_level_asset_path

- C++ 签名：`FTopLevelAssetPath GetSoftClassTopLevelAssetPath(TSoftClassPtr<UObject> SoftClassReference)`（Pure）
- Python：`get_soft_class_top_level_asset_path(soft_class_reference) -> TopLevelAssetPath`
- 说明：SoftClassReference 转 TopLevelAssetPath（资产工具用）。
- 示例：

```python
top = api.get_soft_class_top_level_asset_path(scr)
```

### conv_soft_class_reference_to_string

- C++ 签名：`FString Conv_SoftClassReferenceToString(const TSoftClassPtr<UObject>& SoftClassReference)`（Pure）
- Python：`conv_soft_class_reference_to_string(soft_class_reference) -> str`
- 说明：SoftClassReference 转路径字符串。
- 示例：

```python
scr_str = api.conv_soft_class_reference_to_string(scr)
```

### equal_equal_soft_class_reference

- C++ 签名：`bool EqualEqual_SoftClassReference(const TSoftClassPtr<UObject>& A, const TSoftClassPtr<UObject>& B)`（Pure）
- Python：`equal_equal_soft_class_reference(a, b) -> bool`
- 说明：两个 SoftClassReference 是否相等。
- 示例：

```python
same = api.equal_equal_soft_class_reference(scr, other)
```

### not_equal_soft_class_reference

- C++ 签名：`bool NotEqual_SoftClassReference(const TSoftClassPtr<UObject>& A, const TSoftClassPtr<UObject>& B)`（Pure）
- Python：`not_equal_soft_class_reference(a, b) -> bool`
- 说明：两个 SoftClassReference 是否不等。
- 示例：

```python
diff = api.not_equal_soft_class_reference(scr, other)
```

### load_class_asset_blocking

- C++ 签名：`UClass* LoadClassAsset_Blocking(TSoftClassPtr<UObject> AssetClass)`（Callable）
- Python：`load_class_asset_blocking(asset_class) -> Class 或 None`
- 说明：同步加载软类引用资产对应的类（阻塞）。
- 示例：

```python
klass = api.load_class_asset_blocking(scr)
if klass is None:
    print("BLOCKED_INPUT: class asset not loadable")
```

### is_object_of_soft_class

- C++ 签名：`bool IsObjectOfSoftClass(const UObject* Object, TSoftClassPtr<UObject> SoftClass)`（Callable）
- Python：`is_object_of_soft_class(object, soft_class) -> bool`
- 说明：对象是否属于（或子类、或实现）软类引用对应的类；比 Cast 慢但不增强硬引用。
- 示例：

```python
is_npc = api.is_object_of_soft_class(actor, scr)
```

## 软引用内部转换（Internal Conversion）

以下为蓝图内部节点对应的转换函数，Python 直接调用时行为不变。

### conv_soft_object_reference_to_object

- C++ 签名：`UObject* Conv_SoftObjectReferenceToObject(const TSoftObjectPtr<UObject>& SoftObject)`（Pure）
- Python：`conv_soft_object_reference_to_object(soft_object) -> Object 或 None`
- 说明：把 SoftObjectReference 解析为已加载对象（不加载）。
- 示例：

```python
obj = api.conv_soft_object_reference_to_object(soft_ref)
```

### conv_soft_class_reference_to_class

- C++ 签名：`TSubclassOf<UObject> Conv_SoftClassReferenceToClass(const TSoftClassPtr<UObject>& SoftClass)`（Pure）
- Python：`conv_soft_class_reference_to_class(soft_class) -> Class 或 None`
- 说明：把 SoftClassReference 解析为已加载类。
- 示例：

```python
klass = api.conv_soft_class_reference_to_class(scr)
```

### conv_object_to_soft_object_reference

- C++ 签名：`TSoftObjectPtr<UObject> Conv_ObjectToSoftObjectReference(UObject* Object)`（Pure）
- Python：`conv_object_to_soft_object_reference(object) -> SoftObjectReference`
- 说明：对象转 SoftObjectReference。
- 示例：

```python
ref = api.conv_object_to_soft_object_reference(actor)
```

### conv_class_to_soft_class_reference

- C++ 签名：`TSoftClassPtr<UObject> Conv_ClassToSoftClassReference(const TSubclassOf<UObject>& Class)`（Pure）
- Python：`conv_class_to_soft_class_reference(object_class) -> SoftClassReference`
- 说明：类转 SoftClassReference。
- 示例：

```python
scr = api.conv_class_to_soft_class_reference(actor.get_class())
```

### conv_component_reference_to_soft_component_reference

- C++ 签名：`FSoftComponentReference Conv_ComponentReferenceToSoftComponentReference(const FComponentReference& ComponentReference)`（Pure）
- Python：`conv_component_reference_to_soft_component_reference(component_reference) -> SoftComponentReference`
- 说明：组件引用转软组件引用。
- 示例：

```python
soft_comp = api.conv_component_reference_to_soft_component_reference(component_reference)
```

### load_asset（流送）

- C++ 签名：`void LoadAsset(const UObject* WorldContextObject, TSoftObjectPtr<UObject> Asset, FOnAssetLoaded OnLoaded, FLatentActionInfo LatentInfo)`（Latent）
- Python：`load_asset(world_context_object, asset, on_loaded, latent_info=...) -> None`
- 说明：异步流送加载软对象资产，完成后触发回调（流送节点语义）。
- 示例：

```python
api.load_asset(world_context, soft_ref, unreal.KismetSystemLibrary.on_asset_loaded())
```

### load_asset_class（流送）

- C++ 签名：`void LoadAssetClass(const UObject* WorldContextObject, TSoftClassPtr<UObject> AssetClass, FOnAssetClassLoaded OnLoaded, FLatentActionInfo LatentInfo)`（Latent）
- Python：`load_asset_class(world_context_object, asset_class, on_loaded, latent_info=...) -> None`
- 说明：异步流送加载软类引用对应的类，完成后触发回调。
- 示例：

```python
api.load_asset_class(world_context, scr, unreal.KismetSystemLibrary.on_asset_class_loaded())
```

## 字面量（Literals）

### make_literal_int

- C++ 签名：`int32 MakeLiteralInt(int32 Value)`（Pure）
- Python：`make_literal_int(value) -> int`
- 说明：构造字面量 int。
- 示例：

```python
n = api.make_literal_int(42)
```

### make_literal_int64

- C++ 签名：`int64 MakeLiteralInt64(int64 Value)`（Pure）
- Python：`make_literal_int64(value) -> int`
- 说明：构造字面量 64 位整数。
- 示例：

```python
n64 = api.make_literal_int64(9000000000)
```

### make_literal_double

- C++ 签名：`double MakeLiteralDouble(double Value)`（Pure）
- Python：`make_literal_double(value) -> float`
- 说明：构造字面量双精度浮点。
- 示例：

```python
f = api.make_literal_double(1.5)
```

### make_literal_bool

- C++ 签名：`bool MakeLiteralBool(bool Value)`（Pure）
- Python：`make_literal_bool(value) -> bool`
- 说明：构造字面量布尔。
- 示例：

```python
b = api.make_literal_bool(True)
```

### make_literal_name

- C++ 签名：`FName MakeLiteralName(FName Value)`（Pure）
- Python：`make_literal_name(value) -> Name`
- 说明：构造字面量 Name。
- 示例：

```python
nm = api.make_literal_name("ActorLabel")
```

### make_literal_byte

- C++ 签名：`uint8 MakeLiteralByte(uint8 Value)`（Pure）
- Python：`make_literal_byte(value) -> int`
- 说明：构造字面量字节。
- 示例：

```python
byte_val = api.make_literal_byte(255)
```

### make_literal_string

- C++ 签名：`FString MakeLiteralString(FString Value)`（Pure）
- Python：`make_literal_string(value) -> str`
- 说明：构造字面量字符串。
- 示例：

```python
s = api.make_literal_string("hello")
```

### make_literal_text

- C++ 签名：`FText MakeLiteralText(FText Value)`（Pure）
- Python：`make_literal_text(value) -> Text`
- 说明：构造字面量 Text。
- 示例：

```python
t = api.make_literal_text(unreal.Text("hello"))
```

## 日志与打印（Printing / Logging）

### log_string

- C++ 签名：`void LogString(const FString& InString = TEXT("Hello"), bool bPrintToLog = true)`（Callable）
- Python：`log_string(in_string="Hello", b_print_to_log=True) -> None`
- 说明：只写日志；`b_print_to_log=False` 时仅 Verbose 级别。
- 示例：

```python
api.log_string("system ready", True)
```

### print_string

- C++ 签名：`void PrintString(const UObject* WorldContextObject, const FString& InString = TEXT("Hello"), bool bPrintToScreen = true, bool bPrintToLog = true, FLinearColor TextColor = FLinearColor(0.f, 0.66f, 1.f), float Duration = 2.f, const FName Key = NAME_None)`（Callable）
- Python：`print_string(world_context_object, in_string="Hello", b_print_to_screen=True, b_print_to_log=True, text_color=..., duration=2.0, key=None) -> None`
- 说明：打印屏幕与日志文本；`Key` 非空时替换同名屏幕消息。运行时上下文使用。
- 示例：

```python
api.print_string(world_context, "objective updated", True, True, duration=3.0)
```

### print_text

- C++ 签名：`void PrintText(const UObject* WorldContextObject, const FText InText = INVTEXT("Hello"), bool bPrintToScreen = true, bool bPrintToLog = true, FLinearColor TextColor = FLinearColor(0.f, 0.66f, 1.f), float Duration = 2.f, const FName Key = NAME_None)`（Callable）
- Python：`print_text(world_context_object, in_text, b_print_to_screen=True, b_print_to_log=True, text_color=..., duration=2.0, key=None) -> None`
- 说明：打印本地化文本到屏幕/日志。
- 示例：

```python
api.print_text(world_context, unreal.Text("Objective updated"), True, True)
```

### print_warning

- C++ 签名：`void PrintWarning(const FString& InString)`（Callable）
- Python：`print_warning(in_string) -> None`
- 说明：打印警告到日志与屏幕。
- 示例：

```python
api.print_warning("misconfigured node")
```

### set_window_title

- C++ 签名：`void SetWindowTitle(const FText& Title)`（Callable）
- Python：`set_window_title(title) -> None`
- 说明：设置游戏窗口标题。
- 示例：

```python
api.set_window_title(unreal.Text("My Game - Debug"))
```

### execute_console_command

- C++ 签名：`void ExecuteConsoleCommand(const UObject* WorldContextObject, const FString& Command, APlayerController* SpecificPlayer = NULL)`（Callable）
- Python：`execute_console_command(world_context_object, command, specific_player=None) -> None`
- 说明：执行控制台命令；指定玩家时经该玩家路由。
- 示例：

```python
api.execute_console_command(world_context, "stat fps")
```

### get_console_variable_string_value

- C++ 签名：`FString GetConsoleVariableStringValue(const FString& VariableName)`（Callable）
- Python：`get_console_variable_string_value(variable_name) -> str`
- 说明：读取字符串控制台变量的值；不存在返回空串。
- 示例：

```python
val = api.get_console_variable_string_value("r.Streaming.PoolSize")
```

### get_console_variable_float_value

- C++ 签名：`float GetConsoleVariableFloatValue(const FString& VariableName)`（Callable）
- Python：`get_console_variable_float_value(variable_name) -> float`
- 说明：读取浮点控制台变量值；不存在返回 0。
- 示例：

```python
f = api.get_console_variable_float_value("r.ScreenPercentage")
```

### get_console_variable_int_value

- C++ 签名：`int32 GetConsoleVariableIntValue(const FString& VariableName)`（Callable）
- Python：`get_console_variable_int_value(variable_name) -> int`
- 说明：读取整数控制台变量值；不存在返回 0。
- 示例：

```python
n = api.get_console_variable_int_value("r.ContactShadows")
```

### get_console_variable_bool_value

- C++ 签名：`bool GetConsoleVariableBoolValue(const FString& VariableName)`（Callable）
- Python：`get_console_variable_bool_value(variable_name) -> bool`
- 说明：读取布尔控制台变量值（非零为真）。
- 示例：

```python
b = api.get_console_variable_bool_value("r.VolumetricFog")
```

### quit_game

- C++ 签名：`void QuitGame(const UObject* WorldContextObject, APlayerController* SpecificPlayer, TEnumAsByte<EQuitPreference::Type> QuitPreference, bool bIgnorePlatformRestrictions)`（Callable）
- Python：`quit_game(world_context_object, specific_player, quit_preference, b_ignore_platform_restrictions) -> None`
- 说明：退出游戏（Quit 或转入后台）。只应在用户明确触发时调用。
- 示例：

```python
api.quit_game(world_context, pc, unreal.QuitPreference.QUIT, False)
```

### quit_editor（编辑器）

- C++ 签名：`void QuitEditor()`（WITH_EDITOR，Callable）
- Python：`quit_editor() -> None`
- 说明：退出编辑器。仅编辑器构建可用；属于破坏性流程，先确认保存状态。
- 示例：

```python
api.quit_editor()
```

## 延迟流送（Latent Actions，仅 PIE/运行时）

> 这些是蓝图流送（Latent）节点；Python 直调会依赖运行世界的流送执行语义，编辑器纯编辑态无意义，按 `BLOCKED_TOOLING` 处理。

### delay

- C++ 签名：`void Delay(const UObject* WorldContextObject, float Duration, struct FLatentActionInfo LatentInfo)`
- Python：`delay(world_context_object, duration, latent_info=...) -> None`
- 说明：延迟指定秒数后继续（再次调用会忽略计数中的延迟）。
- 示例：

```python
api.delay(world_context, 2.0)
```

### delay_until_next_tick

- C++ 签名：`void DelayUntilNextTick(const UObject* WorldContextObject, struct FLatentActionInfo LatentInfo)`
- Python：`delay_until_next_tick(world_context_object, latent_info=...) -> None`
- 说明：延迟到下一帧。
- 示例：

```python
api.delay_until_next_tick(world_context)
```

### retriggerable_delay

- C++ 签名：`void RetriggerableDelay(const UObject* WorldContextObject, float Duration, FLatentActionInfo LatentInfo)`
- Python：`retriggerable_delay(world_context_object, duration, latent_info=...) -> None`
- 说明：可重触发的延迟：再次调用会重置倒计时为 Duration。
- 示例：

```python
api.retriggerable_delay(world_context, 1.5)
```

### move_component_to

- C++ 签名：`void MoveComponentTo(USceneComponent* Component, FVector TargetRelativeLocation, FRotator TargetRelativeRotation, bool bEaseOut, bool bEaseIn, float OverTime, bool bForceShortestRotationPath, TEnumAsByte<EMoveComponentAction::Type> MoveAction, FLatentActionInfo LatentInfo)`
- Python：`move_component_to(component, target_relative_location, target_relative_rotation, b_ease_out, b_ease_in, over_time, b_force_shortest_rotation_path, move_action, latent_info=...) -> None`
- 说明：在指定时间内把组件插值移动到目标相对位置/旋转（可缓动；`Move` / `Stop` / `Return` 三态）。
- 示例：

```python
api.move_component_to(
    lift_component, unreal.Vector(0, 0, 500.0), unreal.Rotator(0, 0, 0),
    True, True, 3.0, True, unreal.MoveComponentAction.MOVE,
)
```

## 定时器（Timer，运行时会话）

定时器依赖运行世界的 TimerManager。Python 取 `ScriptName` 对应的名字。

### set_timer_delegate

- C++ 签名：`FTimerHandle K2_SetTimerDelegate(FTimerDynamicDelegate Delegate, float Time, bool bLooping, bool bMaxOncePerFrame = false, float InitialStartDelay = 0.f, float InitialStartDelayVariance = 0.f)`（`ScriptName=SetTimerDelegate`）
- Python：`set_timer_delegate(event, time, b_looping, b_max_once_per_frame=False, initial_start_delay=0.0, initial_start_delay_variance=0.0) -> TimerHandle`
- 说明：按动态委托设置定时器，返回句柄用于后续操控。
- 示例：

```python
handle = api.set_timer_delegate(unreal.KismetSystemLibrary.on_asset_loaded(), 1.0, False)
```

### set_timer_for_next_tick_delegate

- C++ 签名：`FTimerHandle K2_SetTimerForNextTickDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=SetTimerForNextTickDelegate`）
- Python：`set_timer_for_next_tick_delegate(event) -> TimerHandle`
- 说明：在下一帧执行委托。
- 示例：

```python
handle = api.set_timer_for_next_tick_delegate(unreal.KismetSystemLibrary.on_asset_loaded())
```

### clear_timer_delegate（已弃用）

- C++ 签名：`void K2_ClearTimerDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=ClearTimerDelegate`，已弃用）
- Python：`clear_timer_delegate(event) -> None`
- 说明：清除指定委托对应的定时器（旧接口，建议用 handle 版本）。
- 示例：

```python
api.clear_timer_delegate(unreal.KismetSystemLibrary.on_asset_loaded())
```

### pause_timer_delegate（已弃用）

- C++ 签名：`void K2_PauseTimerDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=PauseTimerDelegate`，已弃用）
- Python：`pause_timer_delegate(event) -> None`
- 说明：在当前位置暂停委托定时器。
- 示例：

```python
api.pause_timer_delegate(event_delegate)
```

### un_pause_timer_delegate（已弃用）

- C++ 签名：`void K2_UnPauseTimerDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=UnPauseTimerDelegate`，已弃用）
- Python：`un_pause_timer_delegate(event) -> None`
- 说明：恢复暂停的委托定时器。
- 示例：

```python
api.un_pause_timer_delegate(event_delegate)
```

### is_timer_active_delegate（已弃用）

- C++ 签名：`bool K2_IsTimerActiveDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=IsTimerActiveDelegate`，已弃用）
- Python：`is_timer_active_delegate(event) -> bool`
- 说明：委托定时器是否存在且活跃。
- 示例：

```python
active = api.is_timer_active_delegate(event_delegate)
```

### is_timer_paused_delegate（已弃用）

- C++ 签名：`bool K2_IsTimerPausedDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=IsTimerPausedDelegate`，已弃用）
- Python：`is_timer_paused_delegate(event) -> bool`
- 说明：委托定时器是否存在且暂停。
- 示例：

```python
paused = api.is_timer_paused_delegate(event_delegate)
```

### timer_exists_delegate（已弃用）

- C++ 签名：`bool K2_TimerExistsDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=TimerExistsDelegate`，已弃用）
- Python：`timer_exists_delegate(event) -> bool`
- 说明：委托定时器是否存在。
- 示例：

```python
present = api.timer_exists_delegate(event_delegate)
```

### get_timer_elapsed_time_delegate（已弃用）

- C++ 签名：`float K2_GetTimerElapsedTimeDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=GetTimerElapsedTimeDelegate`，已弃用）
- Python：`get_timer_elapsed_time_delegate(event) -> float`
- 说明：返回委托定时器当前迭代已流逝时间。
- 示例：

```python
elapsed = api.get_timer_elapsed_time_delegate(event_delegate)
```

### get_timer_remaining_time_delegate（已弃用）

- C++ 签名：`float K2_GetTimerRemainingTimeDelegate(FTimerDynamicDelegate Delegate)`（`ScriptName=GetTimerRemainingTimeDelegate`，已弃用）
- Python：`get_timer_remaining_time_delegate(event) -> float`
- 说明：返回委托定时器当前迭代剩余时间。
- 示例：

```python
remaining = api.get_timer_remaining_time_delegate(event_delegate)
```

### is_valid_timer_handle

- C++ 签名：`bool K2_IsValidTimerHandle(FTimerHandle Handle)`（`ScriptName=IsValidTimerHandle`）
- Python：`is_valid_timer_handle(handle) -> bool`
- 说明：句柄是否有效（仅指曾引用合法定时器，不代表活跃）。
- 示例：

```python
ok = api.is_valid_timer_handle(handle)
```

### invalidate_timer_handle

- C++ 签名：`FTimerHandle K2_InvalidateTimerHandle(UPARAM(ref) FTimerHandle& Handle)`（`ScriptName=InvalidateTimerHandle`）
- Python：`invalidate_timer_handle(handle) -> TimerHandle`
- 说明：使句柄失效并返回该（已失效的）句柄。
- 示例：

```python
handle = api.invalidate_timer_handle(handle)
```

### clear_timer_handle（已弃用）

- C++ 签名：`void K2_ClearTimerHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=ClearTimerHandle`，已弃用）
- Python：`clear_timer_handle(world_context_object, handle) -> None`
- 说明：清除句柄定时器（旧接口；新实现用 `clear_and_invalidate_timer_handle`）。
- 示例：

```python
api.clear_timer_handle(world_context, handle)
```

### clear_and_invalidate_timer_handle

- C++ 签名：`void K2_ClearAndInvalidateTimerHandle(const UObject* WorldContextObject, UPARAM(ref) FTimerHandle& Handle)`（`ScriptName=ClearAndInvalidateTimerHandle`）
- Python：`clear_and_invalidate_timer_handle(world_context_object, handle) -> None`（ref 参数按引用处理并写回）
- 说明：清除定时器并同时使句柄失效；此后无需自行重置句柄。
- 示例：

```python
api.clear_and_invalidate_timer_handle(world_context, handle)
```

### pause_timer_handle

- C++ 签名：`void K2_PauseTimerHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=PauseTimerHandle`）
- Python：`pause_timer_handle(world_context_object, handle) -> None`
- 说明：在当前位置暂停句柄定时器。
- 示例：

```python
api.pause_timer_handle(world_context, handle)
```

### un_pause_timer_handle

- C++ 签名：`void K2_UnPauseTimerHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=UnPauseTimerHandle`）
- Python：`un_pause_timer_handle(world_context_object, handle) -> None`
- 说明：恢复暂停的句柄定时器。
- 示例：

```python
api.un_pause_timer_handle(world_context, handle)
```

### is_timer_active_handle

- C++ 签名：`bool K2_IsTimerActiveHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=IsTimerActiveHandle`）
- Python：`is_timer_active_handle(world_context_object, handle) -> bool`
- 说明：句柄定时器是否活跃。
- 示例：

```python
active = api.is_timer_active_handle(world_context, handle)
```

### is_timer_paused_handle

- C++ 签名：`bool K2_IsTimerPausedHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=IsTimerPausedHandle`）
- Python：`is_timer_paused_handle(world_context_object, handle) -> bool`
- 说明：句柄定时器是否暂停。
- 示例：

```python
paused = api.is_timer_paused_handle(world_context, handle)
```

### timer_exists_handle

- C++ 签名：`bool K2_TimerExistsHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=TimerExistsHandle`）
- Python：`timer_exists_handle(world_context_object, handle) -> bool`
- 说明：句柄定时器是否存在。
- 示例：

```python
present = api.timer_exists_handle(world_context, handle)
```

### get_timer_elapsed_time_handle

- C++ 签名：`float K2_GetTimerElapsedTimeHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=GetTimerElapsedTimeHandle`）
- Python：`get_timer_elapsed_time_handle(world_context_object, handle) -> float`
- 说明：返回句柄定时器当前迭代已流逝时间。
- 示例：

```python
elapsed = api.get_timer_elapsed_time_handle(world_context, handle)
```

### get_timer_remaining_time_handle

- C++ 签名：`float K2_GetTimerRemainingTimeHandle(const UObject* WorldContextObject, FTimerHandle Handle)`（`ScriptName=GetTimerRemainingTimeHandle`）
- Python：`get_timer_remaining_time_handle(world_context_object, handle) -> float`
- 说明：返回句柄定时器当前迭代剩余时间。
- 示例：

```python
remaining = api.get_timer_remaining_time_handle(world_context, handle)
```

### set_timer

- C++ 签名：`FTimerHandle K2_SetTimer(UObject* Object, FString FunctionName, float Time, bool bLooping, bool bMaxOncePerFrame = false, float InitialStartDelay = 0.f, float InitialStartDelayVariance = 0.f)`（`ScriptName=SetTimer`）
- Python：`set_timer(object, function_name, time, b_looping, b_max_once_per_frame=False, initial_start_delay=0.0, initial_start_delay_variance=0.0) -> TimerHandle`
- 说明：按函数名设置定时器（函数名可为 K2 函数或自定义事件）。
- 示例：

```python
handle = api.set_timer(self_actor, \"TickCooldown\", 2.0, True)
```

### set_timer_for_next_tick

- C++ 签名：`FTimerHandle K2_SetTimerForNextTick(UObject* Object, FString FunctionName)`（`ScriptName=SetTimerForNextTick`）
- Python：`set_timer_for_next_tick(object, function_name) -> TimerHandle`
- 说明：下一帧执行指定函数名。
- 示例：

```python
handle = api.set_timer_for_next_tick(self_actor, \"OnNextTick\")
```

### clear_timer

- C++ 签名：`void K2_ClearTimer(UObject* Object, FString FunctionName)`（`ScriptName=ClearTimer`）
- Python：`clear_timer(object, function_name) -> None`
- 说明：清除指定函数名的定时器。
- 示例：

```python
api.clear_timer(self_actor, \"TickCooldown\")
```

### pause_timer

- C++ 签名：`void K2_PauseTimer(UObject* Object, FString FunctionName)`（`ScriptName=PauseTimer`）
- Python：`pause_timer(object, function_name) -> None`
- 说明：暂停指定函数名的定时器。
- 示例：

```python
api.pause_timer(self_actor, \"TickCooldown\")
```

### un_pause_timer

- C++ 签名：`void K2_UnPauseTimer(UObject* Object, FString FunctionName)`（`ScriptName=UnPauseTimer`）
- Python：`un_pause_timer(object, function_name) -> None`
- 说明：恢复指定函数名的定时器。
- 示例：

```python
api.un_pause_timer(self_actor, \"TickCooldown\")
```

### is_timer_active

- C++ 签名：`bool K2_IsTimerActive(UObject* Object, FString FunctionName)`（`ScriptName=IsTimerActive`）
- Python：`is_timer_active(object, function_name) -> bool`
- 说明：指定函数名的定时器是否活跃。
- 示例：

```python
active = api.is_timer_active(self_actor, \"TickCooldown\")
```

### is_timer_paused

- C++ 签名：`bool K2_IsTimerPaused(UObject* Object, FString FunctionName)`（`ScriptName=IsTimerPaused`）
- Python：`is_timer_paused(object, function_name) -> bool`
- 说明：指定函数名的定时器是否暂停。
- 示例：

```python
paused = api.is_timer_paused(self_actor, \"TickCooldown\")
```

### timer_exists

- C++ 签名：`bool K2_TimerExists(UObject* Object, FString FunctionName)`（`ScriptName=TimerExists`）
- Python：`timer_exists(object, function_name) -> bool`
- 说明：指定函数名的定时器是否存在。
- 示例：

```python
present = api.timer_exists(self_actor, \"TickCooldown\")
```

### get_timer_elapsed_time

- C++ 签名：`float K2_GetTimerElapsedTime(UObject* Object, FString FunctionName)`（`ScriptName=GetTimerElapsedTime`）
- Python：`get_timer_elapsed_time(object, function_name) -> float`
- 说明：返回指定函数名定时器当前迭代已流逝时间。
- 示例：

```python
elapsed = api.get_timer_elapsed_time(self_actor, \"TickCooldown\")
```

### get_timer_remaining_time

- C++ 签名：`float K2_GetTimerRemainingTime(UObject* Object, FString FunctionName)`（`ScriptName=GetTimerRemainingTime`）
- Python：`get_timer_remaining_time(object, function_name) -> float`
- 说明：返回指定函数名定时器当前迭代剩余时间。
- 示例：

```python
remaining = api.get_timer_remaining_time(self_actor, \"TickCooldown\")
```

## 按名称设置属性（Property By Name）

一组按属性名写对象属性的工具；Object 为任意 UObject，PropertyName 为属性名，无返回值（修改失败仅写日志并返回 `None`）。

### set_int_property_by_name

- C++ 签名：`void SetIntPropertyByName(UObject* Object, FName PropertyName, int32 Value)`
- Python：`set_int_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_int_property_by_name(actor, "Health", 100)
```

### set_int64_property_by_name

- C++ 签名：`void SetInt64PropertyByName(UObject* Object, FName PropertyName, int64 Value)`
- Python：`set_int64_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_int64_property_by_name(actor, "SavedScore", 9_000_000_000)
```

### set_byte_property_by_name

- C++ 签名：`void SetBytePropertyByName(UObject* Object, FName PropertyName, uint8 Value)`
- Python：`set_byte_property_by_name(object, property_name, value) -> None`
- 说明：设置 uint8 或枚举类型属性。
- 示例：

```python
api.set_byte_property_by_name(actor, "Team", 0)
```

### set_double_property_by_name

- C++ 签名：`void SetDoublePropertyByName(UObject* Object, FName PropertyName, double Value)`
- Python：`set_double_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_double_property_by_name(actor, "Speed", 600.0)
```

### set_bool_property_by_name

- C++ 签名：`void SetBoolPropertyByName(UObject* Object, FName PropertyName, bool Value)`
- Python：`set_bool_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_bool_property_by_name(actor, "bIsDead", True)
```

### set_object_property_by_name

- C++ 签名：`void SetObjectPropertyByName(UObject* Object, FName PropertyName, UObject* Value)`
- Python：`set_object_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_object_property_by_name(actor, "Weapon", weapon_actor)
```

### set_class_property_by_name

- C++ 签名：`void SetClassPropertyByName(UObject* Object, FName PropertyName, TSubclassOf<UObject> Value)`
- Python：`set_class_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_class_property_by_name(actor, "SpawnClass", npc_class)
```

### set_interface_property_by_name

- C++ 签名：`void SetInterfacePropertyByName(UObject* Object, FName PropertyName, const FScriptInterface& Value)`
- Python：`set_interface_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_interface_property_by_name(actor, "InteractionTarget", tagged_object)
```

### set_name_property_by_name

- C++ 签名：`void SetNamePropertyByName(UObject* Object, FName PropertyName, const FName& Value)`
- Python：`set_name_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_name_property_by_name(actor, "TagName", "Respawn")
```

### set_soft_object_property_by_name

- C++ 签名：`void SetSoftObjectPropertyByName(UObject* Object, FName PropertyName, const TSoftObjectPtr<UObject>& Value)`
- Python：`set_soft_object_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_soft_object_property_by_name(actor, "ReferencedAsset", soft_ref)
```

### set_soft_class_property_by_name

- C++ 签名：`void SetSoftClassPropertyByName(UObject* Object, FName PropertyName, const TSoftClassPtr<UObject>& Value)`
- Python：`set_soft_class_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_soft_class_property_by_name(actor, "ReferencedClass", scr)
```

### set_string_property_by_name

- C++ 签名：`void SetStringPropertyByName(UObject* Object, FName PropertyName, const FString& Value)`
- Python：`set_string_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_string_property_by_name(actor, "Label", "Entry_01")
```

### set_text_property_by_name

- C++ 签名：`void SetTextPropertyByName(UObject* Object, FName PropertyName, const FText& Value)`
- Python：`set_text_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_text_property_by_name(actor, "DisplayName", unreal.Text("Front Gate"))
```

### set_vector_property_by_name

- C++ 签名：`void SetVectorPropertyByName(UObject* Object, FName PropertyName, const FVector& Value)`
- Python：`set_vector_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_vector_property_by_name(actor, "SpawnOffset", unreal.Vector(0, 0, 200.0))
```

### set_vector3f_property_by_name

- C++ 签名：`void SetVector3fPropertyByName(UObject* Object, FName PropertyName, const FVector3f& Value)`
- Python：`set_vector3f_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_vector3f_property_by_name(actor, "HalfExtent", unreal.Vector(50.0, 50.0, 50.0))
```

### set_rotator_property_by_name

- C++ 签名：`void SetRotatorPropertyByName(UObject* Object, FName PropertyName, const FRotator& Value)`
- Python：`set_rotator_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_rotator_property_by_name(actor, "InitialRotation", unreal.Rotator(0, 90, 0))
```

### set_linear_color_property_by_name

- C++ 签名：`void SetLinearColorPropertyByName(UObject* Object, FName PropertyName, const FLinearColor& Value)`
- Python：`set_linear_color_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_linear_color_property_by_name(actor, "Tint", unreal.LinearColor(1.0, 0.2, 0.2, 1.0))
```

### set_color_property_by_name

- C++ 签名：`void SetColorPropertyByName(UObject* Object, FName PropertyName, const FColor& Value)`
- Python：`set_color_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_color_property_by_name(actor, "FlashColor", unreal.Color(255, 0, 0, 255))
```

### set_transform_property_by_name

- C++ 签名：`void SetTransformPropertyByName(UObject* Object, FName PropertyName, const FTransform& Value)`
- Python：`set_transform_property_by_name(object, property_name, value) -> None`
- 示例：

```python
api.set_transform_property_by_name(actor, "SpawnTransform", spawn_transform)
```

### set_collision_profile_name_property

- C++ 签名：`void SetCollisionProfileNameProperty(UObject* Object, FName PropertyName, const FCollisionProfileName& Value)`
- Python：`set_collision_profile_name_property(object, property_name, value) -> None`
- 说明：设置碰撞配置文件（CollisionProfileName）类型属性（传参以目标 5.6 暴露的类型为准）。
- 示例：

```python
api.set_collision_profile_name_property(actor, "CollisionProfile", "BlockAll")
```

### set_field_path_property_by_name

- C++ 签名：`void SetFieldPathPropertyByName(UObject* Object, FName PropertyName, const TFieldPath<FField>& Value)`
- Python：`set_field_path_property_by_name(object, property_name, value) -> None`
- 说明：设置字段路径（FieldPath）类型属性。
- 示例：

```python
api.set_field_path_property_by_name(actor, "SourceField", field_path)
```

### set_structure_property_by_name

- C++ 签名：`void SetStructurePropertyByName(UObject* Object, FName PropertyName, const FGenericStruct& Value)`
- Python：`set_structure_property_by_name(object, property_name, value) -> None`
- 说明：设置自定义结构体类型属性；值传结构体实例。
- 示例：

```python
api.set_structure_property_by_name(actor, "CustomData", custom_struct)
```

## 碰撞重叠（Collision Overlap）

重叠查询返回是否通过过滤器（bool），并把结果数组作为 Out 返回；布尔与数组按元组返回（bool 在首位）。

### sphere_overlap_actors

- C++ 签名：`bool SphereOverlapActors(const UObject* WorldContextObject, const FVector SpherePos, float SphereRadius, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`sphere_overlap_actors(world_context_object, sphere_pos, sphere_radius, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 示例：

```python
hit, actors = api.sphere_overlap_actors(world_context, unreal.Vector(0,0,0), 300.0,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [])
```

### sphere_overlap_components

- C++ 签名：`bool SphereOverlapComponents(const UObject* WorldContextObject, const FVector SpherePos, float SphereRadius, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`sphere_overlap_components(world_context_object, sphere_pos, sphere_radius, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.sphere_overlap_components(world_context, center, 200.0,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], primitive_component_class, [])
```

### box_overlap_actors

- C++ 签名：`bool BoxOverlapActors(const UObject* WorldContextObject, const FVector BoxPos, FVector BoxExtent, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`box_overlap_actors(world_context_object, box_pos, box_extent, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 示例：

```python
hit, actors = api.box_overlap_actors(world_context, center, extent,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [])
```

### box_overlap_actors_with_orientation

- C++ 签名：`bool BoxOverlapActorsWithOrientation(const UObject* WorldContextObject, const FVector BoxPos, FVector BoxExtent, FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`box_overlap_actors_with_orientation(world_context_object, box_pos, box_extent, orientation, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 示例：

```python
hit, actors = api.box_overlap_actors_with_orientation(world_context, center, extent,
    unreal.Rotator(0, 45, 0), [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [])
```

### box_overlap_components

- C++ 签名：`bool BoxOverlapComponents(const UObject* WorldContextObject, const FVector BoxPos, FVector Extent, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`box_overlap_components(world_context_object, box_pos, extent, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.box_overlap_components(world_context, center, extent,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], primitive_component_class, [])
```

### box_overlap_components_with_orientation

- C++ 签名：`bool BoxOverlapComponentsWithOrientation(const UObject* WorldContextObject, const FVector BoxPos, FVector Extent, FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`box_overlap_components_with_orientation(world_context_object, box_pos, extent, orientation, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.box_overlap_components_with_orientation(world_context, center, extent,
    unreal.Rotator(0, 0, 30), [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], comp_class, [])
```

### capsule_overlap_actors

- C++ 签名：`bool CapsuleOverlapActors(const UObject* WorldContextObject, const FVector CapsulePos, float Radius, float HalfHeight, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`capsule_overlap_actors(world_context_object, capsule_pos, radius, half_height, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 示例：

```python
hit, actors = api.capsule_overlap_actors(world_context, center, 60.0, 90.0,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [])
```

### capsule_overlap_actors_with_orientation

- C++ 签名：`bool CapsuleOverlapActorsWithOrientation(const UObject* WorldContextObject, const FVector CapsulePos, float Radius, float HalfHeight, FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`capsule_overlap_actors_with_orientation(world_context_object, capsule_pos, radius, half_height, orientation, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 示例：

```python
hit, actors = api.capsule_overlap_actors_with_orientation(world_context, center, 60.0, 90.0,
    unreal.Rotator(0, 0, 0), [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [])
```

### capsule_overlap_components

- C++ 签名：`bool CapsuleOverlapComponents(const UObject* WorldContextObject, const FVector CapsulePos, float Radius, float HalfHeight, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`capsule_overlap_components(world_context_object, capsule_pos, radius, half_height, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.capsule_overlap_components(world_context, center, 60.0, 90.0,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], comp_class, [])
```

### capsule_overlap_components_with_orientation

- C++ 签名：`bool CapsuleOverlapComponentsWithOrientation(const UObject* WorldContextObject, const FVector CapsulePos, float Radius, float HalfHeight, FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`capsule_overlap_components_with_orientation(world_context_object, capsule_pos, radius, half_height, orientation, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.capsule_overlap_components_with_orientation(world_context, center, 60.0, 90.0,
    unreal.Rotator(0, 0, 0), [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], comp_class, [])
```

### component_overlap_actors

- C++ 签名：`bool ComponentOverlapActors(UPrimitiveComponent* Component, const FTransform& ComponentTransform, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ActorClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<AActor*>& OutActors)`
- Python：`component_overlap_actors(component, component_transform, object_types, actor_class_filter, actors_to_ignore) -> (bool, Array[Actor])`
- 说明：用指定组件与变换做重叠测试（可放置到任意位置测试）。需要可碰撞的 PrimitiveComponent。仅在运行时可用。
- 示例：

```python
hit, actors = api.component_overlap_actors(
    primitive, component_transform,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], actor_class, [],
)
```

### component_overlap_components

- C++ 签名：`bool ComponentOverlapComponents(UPrimitiveComponent* Component, const FTransform& ComponentTransform, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, UClass* ComponentClassFilter, const TArray<AActor*>& ActorsToIgnore, TArray<UPrimitiveComponent*>& OutComponents)`
- Python：`component_overlap_components(component, component_transform, object_types, component_class_filter, actors_to_ignore) -> (bool, Array[PrimitiveComponent])`
- 示例：

```python
hit, comps = api.component_overlap_components(
    primitive, component_transform,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY1], comp_class, [],
)
```

## 射线追踪（Traces）

所有追踪函数在 PIE/运行时对所在世界执行；返回 `(bool, HitResult)` 或 `(bool, Array[HitResult])`（阻塞命中排在最后）。编辑器纯编辑态无世界碰撞，按 `BLOCKED_TOOLING` 处理。

### line_trace_single

- C++ 签名：`bool LineTraceSingle(const UObject* WorldContextObject, const FVector Start, const FVector End, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, FLinearColor TraceColor = FLinearColor::Red, FLinearColor TraceHitColor = FLinearColor::Green, float DrawTime = 5.0f)`
- Python：`line_trace_single(world_context_object, start, end, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, trace_color=..., trace_hit_color=..., draw_time=5.0) -> (bool, HitResult)`
- 说明：按 TraceChannel 做单线射线，返回首个阻塞命中。
- 示例：

```python
hit_any, hit = api.line_trace_single(world_context, start, end,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### line_trace_multi

- C++ 签名：`bool LineTraceMulti(const UObject* WorldContextObject, const FVector Start, const FVector End, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, FLinearColor TraceColor = ..., FLinearColor TraceHitColor = ..., float DrawTime = 5.0f)`
- Python：`line_trace_multi(world_context_object, start, end, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.line_trace_multi(world_context, start, end,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_single

- C++ 签名：`bool SphereTraceSingle(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_single(world_context_object, start, end, radius, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.sphere_trace_single(world_context, start, end, 50.0,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_multi

- C++ 签名：`bool SphereTraceMulti(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_multi(world_context_object, start, end, radius, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.sphere_trace_multi(world_context, start, end, 50.0,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### box_trace_single

- C++ 签名：`bool BoxTraceSingle(const UObject* WorldContextObject, const FVector Start, const FVector End, const FVector HalfSize, const FRotator Orientation, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`box_trace_single(world_context_object, start, end, half_size, orientation, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.box_trace_single(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [],
    unreal.DrawDebugTrace.NONE, True)
```

### box_trace_multi

- C++ 签名：`bool BoxTraceMulti(const UObject* WorldContextObject, const FVector Start, const FVector End, FVector HalfSize, const FRotator Orientation, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`box_trace_multi(world_context_object, start, end, half_size, orientation, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.box_trace_multi(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [],
    unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_single

- C++ 签名：`bool CapsuleTraceSingle(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_single(world_context_object, start, end, radius, half_height, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.capsule_trace_single(world_context, start, end, 40.0, 80.0,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_multi

- C++ 签名：`bool CapsuleTraceMulti(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, ETraceTypeQuery TraceChannel, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_multi(world_context_object, start, end, radius, half_height, trace_channel, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.capsule_trace_multi(world_context, start, end, 40.0, 80.0,
    unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [], unreal.DrawDebugTrace.NONE, True)
```

### line_trace_single_for_objects

- C++ 签名：`bool LineTraceSingleForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`line_trace_single_for_objects(world_context_object, start, end, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 说明：只命中 ObjectTypes 指定的对象类型。
- 示例：

```python
hit_any, hit = api.line_trace_single_for_objects(world_context, start, end,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], False, [], unreal.DrawDebugTrace.NONE, True)
```

### line_trace_multi_for_objects

- C++ 签名：`bool LineTraceMultiForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`line_trace_multi_for_objects(world_context_object, start, end, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.line_trace_multi_for_objects(world_context, start, end,
    [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_single_for_objects

- C++ 签名：`bool SphereTraceSingleForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_single_for_objects(world_context_object, start, end, radius, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.sphere_trace_single_for_objects(world_context, start, end, 50.0,
    object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_multi_for_objects

- C++ 签名：`bool SphereTraceMultiForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_multi_for_objects(world_context_object, start, end, radius, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.sphere_trace_multi_for_objects(world_context, start, end, 50.0,
    object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### box_trace_single_for_objects

- C++ 签名：`bool BoxTraceSingleForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, const FVector HalfSize, const FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`box_trace_single_for_objects(world_context_object, start, end, half_size, orientation, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.box_trace_single_for_objects(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### box_trace_multi_for_objects

- C++ 签名：`bool BoxTraceMultiForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, const FVector HalfSize, const FRotator Orientation, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`box_trace_multi_for_objects(world_context_object, start, end, half_size, orientation, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.box_trace_multi_for_objects(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_single_for_objects

- C++ 签名：`bool CapsuleTraceSingleForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_single_for_objects(world_context_object, start, end, radius, half_height, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.capsule_trace_single_for_objects(world_context, start, end, 40.0, 80.0,
    object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_multi_for_objects

- C++ 签名：`bool CapsuleTraceMultiForObjects(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, const TArray<TEnumAsByte<EObjectTypeQuery>>& ObjectTypes, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_multi_for_objects(world_context_object, start, end, radius, half_height, object_types, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.capsule_trace_multi_for_objects(world_context, start, end, 40.0, 80.0,
    object_types, False, [], unreal.DrawDebugTrace.NONE, True)
```

### line_trace_single_by_profile

- C++ 签名：`bool LineTraceSingleByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`line_trace_single_by_profile(world_context_object, start, end, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 说明：按碰撞配置文件（ProfileName）追踪，返回首个阻塞命中。
- 示例：

```python
hit_any, hit = api.line_trace_single_by_profile(world_context, start, end, "BlockAll",
    False, [], unreal.DrawDebugTrace.NONE, True)
```

### line_trace_multi_by_profile

- C++ 签名：`bool LineTraceMultiByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`line_trace_multi_by_profile(world_context_object, start, end, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.line_trace_multi_by_profile(world_context, start, end, "BlockAll",
    False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_single_by_profile

- C++ 签名：`bool SphereTraceSingleByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_single_by_profile(world_context_object, start, end, radius, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.sphere_trace_single_by_profile(world_context, start, end, 50.0,
    "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

### sphere_trace_multi_by_profile

- C++ 签名：`bool SphereTraceMultiByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`sphere_trace_multi_by_profile(world_context_object, start, end, radius, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.sphere_trace_multi_by_profile(world_context, start, end, 50.0,
    "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

### box_trace_single_by_profile

- C++ 签名：`bool BoxTraceSingleByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, const FVector HalfSize, const FRotator Orientation, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`box_trace_single_by_profile(world_context_object, start, end, half_size, orientation, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.box_trace_single_by_profile(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

### box_trace_multi_by_profile

- C++ 签名：`bool BoxTraceMultiByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, FVector HalfSize, const FRotator Orientation, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`box_trace_multi_by_profile(world_context_object, start, end, half_size, orientation, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.box_trace_multi_by_profile(world_context, start, end, half_size,
    unreal.Rotator(0, 0, 0), "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_single_by_profile

- C++ 签名：`bool CapsuleTraceSingleByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, FHitResult& OutHit, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_single_by_profile(world_context_object, start, end, radius, half_height, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, HitResult)`
- 示例：

```python
hit_any, hit = api.capsule_trace_single_by_profile(world_context, start, end, 40.0, 80.0,
    "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

### capsule_trace_multi_by_profile

- C++ 签名：`bool CapsuleTraceMultiByProfile(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius, float HalfHeight, FName ProfileName, bool bTraceComplex, const TArray<AActor*>& ActorsToIgnore, EDrawDebugTrace::Type DrawDebugType, TArray<FHitResult>& OutHits, bool bIgnoreSelf, ...)`
- Python：`capsule_trace_multi_by_profile(world_context_object, start, end, radius, half_height, profile_name, b_trace_complex, actors_to_ignore, draw_debug_type, b_ignore_self, ...) -> (bool, Array[HitResult])`
- 示例：

```python
hit_any, hits = api.capsule_trace_multi_by_profile(world_context, start, end, 40.0, 80.0,
    "BlockAll", False, [], unreal.DrawDebugTrace.NONE, True)
```

## 组件到 Actor 列表

### get_actor_list_from_component_list

- C++ 签名：`void GetActorListFromComponentList(const TArray<UPrimitiveComponent*>& ComponentList, UClass* ActorClassFilter, TArray<AActor*>& OutActorList)`
- Python：`get_actor_list_from_component_list(component_list, actor_class_filter) -> Array[Actor]`
- 说明：从组件列表取唯一对应的 Actor 列表（可带类过滤）；单个 Out 直接返回。
- 示例：

```python
owners = api.get_actor_list_from_component_list(components, actor_class)
```

## 调试绘制（Debug Drawing）

调试绘制方法需要世界上下文；标记为开发用途，实施后按要求清理，不遗留持久调试内容。

### draw_debug_line

- C++ 签名：`void DrawDebugLine(const UObject* WorldContextObject, const FVector LineStart, const FVector LineEnd, FLinearColor LineColor, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_line(world_context_object, line_start, line_end, line_color, duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_line(world_context, start, end, unreal.LinearColor(1.0, 0.0, 0.0, 1.0), 5.0)
```

### draw_debug_circle

- C++ 签名：`void DrawDebugCircle(const UObject* WorldContextObject, FVector Center, float Radius, int32 NumSegments=12, FLinearColor LineColor = FLinearColor::White, float Duration=0.f, float Thickness=0.f, FVector YAxis=FVector(0.f,1.f,0.f), FVector ZAxis=FVector(0.f,0.f,1.f), bool bDrawAxis=false)`
- Python：`draw_debug_circle(world_context_object, center, radius, num_segments=12, line_color=..., duration=0.0, thickness=0.0, y_axis=..., z_axis=..., b_draw_axis=False) -> None`
- 示例：

```python
api.draw_debug_circle(world_context, unreal.Vector(0,0,100), 200.0, 24, unreal.LinearColor(0.0, 1.0, 0.0, 1.0))
```

### draw_debug_point

- C++ 签名：`void DrawDebugPoint(const UObject* WorldContextObject, const FVector Position, float Size, FLinearColor PointColor, float Duration=0.f)`
- Python：`draw_debug_point(world_context_object, position, size, point_color, duration=0.0) -> None`
- 示例：

```python
api.draw_debug_point(world_context, unreal.Vector(0,0,100), 10.0, unreal.LinearColor(1.0, 1.0, 0.0, 1.0), 2.0)
```

### draw_debug_arrow

- C++ 签名：`void DrawDebugArrow(const UObject* WorldContextObject, const FVector LineStart, const FVector LineEnd, float ArrowSize, FLinearColor LineColor, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_arrow(world_context_object, line_start, line_end, arrow_size, line_color, duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_arrow(world_context, start, end, 50.0, unreal.LinearColor(1.0, 0.0, 0.0, 1.0), 2.0)
```

### draw_debug_box

- C++ 签名：`void DrawDebugBox(const UObject* WorldContextObject, const FVector Center, FVector Extent, FLinearColor LineColor, const FRotator Rotation=FRotator::ZeroRotator, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_box(world_context_object, center, extent, line_color, rotation=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_box(world_context, center, extent, unreal.LinearColor(0.0, 0.0, 1.0, 1.0), duration=3.0)
```

### draw_debug_coordinate_system

- C++ 签名：`void DrawDebugCoordinateSystem(const UObject* WorldContextObject, const FVector AxisLoc, const FRotator AxisRot, float Scale=1.f, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_coordinate_system(world_context_object, axis_loc, axis_rot, scale=1.0, duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_coordinate_system(world_context, loc, unreal.Rotator(0, 0, 0), 100.0)
```

### draw_debug_sphere

- C++ 签名：`void DrawDebugSphere(const UObject* WorldContextObject, const FVector Center, float Radius=100.f, int32 Segments=12, FLinearColor LineColor = FLinearColor::White, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_sphere(world_context_object, center, radius=100.0, segments=12, line_color=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_sphere(world_context, unreal.Vector(0,0,100), 150.0, 16, unreal.LinearColor(1.0, 0.0, 1.0, 1.0), 2.0)
```

### draw_debug_cylinder

- C++ 签名：`void DrawDebugCylinder(const UObject* WorldContextObject, const FVector Start, const FVector End, float Radius=100.f, int32 Segments=12, FLinearColor LineColor = FLinearColor::White, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_cylinder(world_context_object, start, end, radius=100.0, segments=12, line_color=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_cylinder(world_context, start, end, 80.0, 16, unreal.LinearColor(0.0, 1.0, 1.0, 1.0), 2.0)
```

### draw_debug_cone（已弃用）

- C++ 签名：`void DrawDebugCone(const UObject* WorldContextObject, const FVector Origin, const FVector Direction, float Length, float AngleWidth, float AngleHeight, int32 NumSides, FLinearColor LineColor, float Duration = 0.f, float Thickness = 0.f)`（已弃用，角度单位改为度数）
- Python：`draw_debug_cone(world_context_object, origin, direction, length, angle_width, angle_height, num_sides, line_color, duration=0.0, thickness=0.0) -> None`
- 说明：旧版本节点已弃用；新实现用 `draw_debug_cone_in_degrees` 传角度为度数。
- 示例：

```python
api.draw_debug_cone(world_context, origin, direction, 200.0, 45.0, 45.0, 12, unreal.LinearColor(1.0, 0.0, 0.0, 1.0))
```

### draw_debug_cone_in_degrees

- C++ 签名：`void DrawDebugConeInDegrees(const UObject* WorldContextObject, const FVector Origin, const FVector Direction, float Length=100.f, float AngleWidth=45.f, float AngleHeight=45.f, int32 NumSides = 12, FLinearColor LineColor = FLinearColor::White, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_cone_in_degrees(world_context_object, origin, direction, length=100.0, angle_width=45.0, angle_height=45.0, num_sides=12, line_color=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_cone_in_degrees(world_context, origin, direction, 300.0, 30.0, 30.0, 16)
```

### draw_debug_capsule

- C++ 签名：`void DrawDebugCapsule(const UObject* WorldContextObject, const FVector Center, float HalfHeight, float Radius, const FRotator Rotation, FLinearColor LineColor = FLinearColor::White, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_capsule(world_context_object, center, half_height, radius, rotation, line_color=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_capsule(world_context, center, 90.0, 40.0, unreal.Rotator(0,0,0), duration=2.0)
```

### draw_debug_string

- C++ 签名：`void DrawDebugString(const UObject* WorldContextObject, const FVector TextLocation, const FString& Text, AActor* TestBaseActor = NULL, FLinearColor TextColor = FLinearColor::White, float Duration=0.f)`
- Python：`draw_debug_string(world_context_object, text_location, text, test_base_actor=None, text_color=..., duration=0.0) -> None`
- 示例：

```python
api.draw_debug_string(world_context, loc, "spawning...", None, unreal.LinearColor(1.0, 1.0, 1.0, 1.0), 2.0)
```

### flush_debug_strings

- C++ 签名：`void FlushDebugStrings(const UObject* WorldContextObject)`
- Python：`flush_debug_strings(world_context_object) -> None`
- 说明：清除全部世界中的调试文字。
- 示例：

```python
api.flush_debug_strings(world_context)
```

### draw_debug_plane

- C++ 签名：`void DrawDebugPlane(const UObject* WorldContextObject, const FPlane& PlaneCoordinates, const FVector Location, float Size, FLinearColor PlaneColor = FLinearColor::White, float Duration=0.f)`
- Python：`draw_debug_plane(world_context_object, plane_coordinates, location, size, plane_color=..., duration=0.0) -> None`
- 示例：

```python
api.draw_debug_plane(world_context, plane, loc, 200.0, unreal.LinearColor(1.0, 1.0, 1.0, 1.0))
```

### flush_persistent_debug_lines

- C++ 签名：`void FlushPersistentDebugLines(const UObject* WorldContextObject)`
- Python：`flush_persistent_debug_lines(world_context_object) -> None`
- 说明：清除所有持久调试线条与图形。
- 示例：

```python
api.flush_persistent_debug_lines(world_context)
```

### draw_debug_frustum

- C++ 签名：`void DrawDebugFrustum(const UObject* WorldContextObject, const FTransform& FrustumTransform, FLinearColor FrustumColor = FLinearColor::White, float Duration=0.f, float Thickness = 0.f)`
- Python：`draw_debug_frustum(world_context_object, frustum_transform, frustum_color=..., duration=0.0, thickness=0.0) -> None`
- 示例：

```python
api.draw_debug_frustum(world_context, camera_transform, duration=2.0)
```

### draw_debug_camera

- C++ 签名：`void DrawDebugCamera(const ACameraActor* CameraActor, FLinearColor CameraColor = FLinearColor::White, float Duration=0.f)`
- Python：`draw_debug_camera(camera_actor, camera_color=..., duration=0.0) -> None`
- 说明：绘制摄像机形状（含视锥），需要运行世界中的摄像机 Actor。
- 示例：

```python
api.draw_debug_camera(camera_actor, unreal.LinearColor(1.0, 1.0, 0.0, 1.0), 3.0)
```

### draw_debug_float_history_transform

- C++ 签名：`void DrawDebugFloatHistoryTransform(const UObject* WorldContextObject, const FDebugFloatHistory& FloatHistory, const FTransform& DrawTransform, FVector2D DrawSize, FLinearColor DrawColor = FLinearColor::White, float Duration = 0.f)`
- Python：`draw_debug_float_history_transform(world_context_object, float_history, draw_transform, draw_size, draw_color=..., duration=0.0) -> None`
- 示例：

```python
api.draw_debug_float_history_transform(world_context, history, draw_transform, unreal.Vector2D(200.0, 80.0))
```

### draw_debug_float_history_location

- C++ 签名：`void DrawDebugFloatHistoryLocation(const UObject* WorldContextObject, const FDebugFloatHistory& FloatHistory, FVector DrawLocation, FVector2D DrawSize, FLinearColor DrawColor = FLinearColor::White, float Duration = 0.f)`
- Python：`draw_debug_float_history_location(world_context_object, float_history, draw_location, draw_size, draw_color=..., duration=0.0) -> None`
- 示例：

```python
api.draw_debug_float_history_location(world_context, history, loc, unreal.Vector2D(200.0, 80.0))
```

### add_float_history_sample

- C++ 签名：`FDebugFloatHistory AddFloatHistorySample(float Value, const FDebugFloatHistory& FloatHistory)`
- Python：`add_float_history_sample(value, float_history) -> FloatHistory`
- 说明：向 FloatHistory 追加一个样本并返回新结构体。
- 示例：

```python
history = api.add_float_history_sample(0.45, history)
```

## 边界与渲染（Bounds / Rendering）

### get_component_bounds

- C++ 签名：`void GetComponentBounds(const USceneComponent* Component, FVector& Origin, FVector& BoxExtent, float& SphereRadius)`
- Python：`get_component_bounds(component) -> (Vector, Vector, float)`
- 说明：返回组件包围盒中心、半长与包围球半径（3 个 Out 按元组返回）。
- 示例：

```python
origin, extent, sphere_r = api.get_component_bounds(scene_component)
```

### get_actor_bounds（已弃用）

- C++ 签名：`void GetActorBounds(const AActor* Actor, FVector& Origin, FVector& BoxExtent)`（已弃用）
- Python：`get_actor_bounds(actor) -> (Vector, Vector)`
- 说明：返回 Actor 包围盒中心与半长（旧接口）。
- 示例：

```python
origin, extent = api.get_actor_bounds(actor)
```

### get_rendering_detail_mode

- C++ 签名：`int32 GetRenderingDetailMode()`
- Python：`get_rendering_detail_mode() -> int`
- 说明：返回已钳制的高细节模式等级（0 低、1 中、2 高、3 最高）。不能在构造脚本中使用。
- 示例：

```python
mode = api.get_rendering_detail_mode()
```

### get_rendering_material_quality_level

- C++ 签名：`int32 GetRenderingMaterialQualityLevel()`
- Python：`get_rendering_material_quality_level() -> int`
- 说明：返回已钳制的材质质量等级（0 低、1 高、2 中）。
- 示例：

```python
q = api.get_rendering_material_quality_level()
```

### get_supported_fullscreen_resolutions

- C++ 签名：`bool GetSupportedFullscreenResolutions(TArray<FIntPoint>& Resolutions)`
- Python：`get_supported_fullscreen_resolutions() -> (bool, Array[IntPoint])`
- 说明：查询设备支持的全屏分辨率列表。
- 示例：

```python
ok, resolutions = api.get_supported_fullscreen_resolutions()
```

### get_convenient_windowed_resolutions

- C++ 签名：`bool GetConvenientWindowedResolutions(TArray<FIntPoint>& Resolutions)`
- Python：`get_convenient_windowed_resolutions() -> (bool, Array[IntPoint])`
- 说明：查询适合当前主显示器的窗口化分辨率列表。
- 示例：

```python
ok, resolutions = api.get_convenient_windowed_resolutions()
```

### get_min_y_resolution_for_ui

- C++ 签名：`int32 GetMinYResolutionForUI()`
- Python：`get_min_y_resolution_for_ui() -> int`
- 说明：返回 UI 支持的最小 Y 分辨率（像素）。
- 示例：

```python
min_y = api.get_min_y_resolution_for_ui()
```

### get_min_y_resolution_for_3d_view

- C++ 签名：`int32 GetMinYResolutionFor3DView()`
- Python：`get_min_y_resolution_for_3d_view() -> int`
- 说明：返回 3D 视图支持的最小 Y 分辨率（像素）。
- 示例：

```python
min_y = api.get_min_y_resolution_for_3d_view()
```

## 平台 / 广告 / 在线 / 设备（Platform / Ads / Online）

以下为平台相关常用工具；移动端/在线相关成员只在对应平台与运行上下文有效，不支持时按 `BLOCKED_TOOLING` 处理。

### launch_url

- C++ 签名：`void LaunchURL(const FString& URL)`
- Python：`launch_url(url) -> None`
- 说明：在平台默认浏览器中打开 URL。需在真机/合法上下文由用户确认后执行。
- 示例：

```python
api.launch_url("https://example.com")
```

### launch_external_url

- C++ 签名：`void LaunchExternalUrl(const TArray<FString>& InDomainStrings, const FString& URL)`
- Python：`launch_external_url(in_domain_strings, url) -> None`
- 说明：仅当 URL 属于白名单域列表时打开外部 URL。
- 示例：

```python
api.launch_external_url(["example.com"], "https://example.com/help")
```

### can_launch_url

- C++ 签名：`bool CanLaunchURL(const FString& URL)`
- Python：`can_launch_url(url) -> bool`
- 说明：URL 是否可被当前平台启动。
- 示例：

```python
ok = api.can_launch_url("https://example.com")
```

### collect_garbage

- C++ 签名：`void CollectGarbage()`
- Python：`collect_garbage() -> None`
- 说明：回收所有未被引用的对象（会排队并在帧末执行；可能造成卡顿）。
- 示例：

```python
api.collect_garbage()
```

### show_ad_banner

- C++ 签名：`void ShowAdBanner(int32 AdIdIndex, bool bShowOnBottomOfScreen)`（iOS / Android）
- Python：`show_ad_banner(ad_id_index, b_show_on_bottom_of_screen) -> None`
- 示例：

```python
api.show_ad_banner(0, True)
```

### get_ad_id_count

- C++ 签名：`int32 GetAdIDCount()`
- Python：`get_ad_id_count() -> int`
- 示例：

```python
count = api.get_ad_id_count()
```

### hide_ad_banner

- C++ 签名：`void HideAdBanner()`（iOS / Android）
- Python：`hide_ad_banner() -> None`
- 示例：

```python
api.hide_ad_banner()
```

### force_close_ad_banner

- C++ 签名：`void ForceCloseAdBanner()`（iOS / Android）
- Python：`force_close_ad_banner() -> None`
- 示例：

```python
api.force_close_ad_banner()
```

### load_interstitial_ad

- C++ 签名：`void LoadInterstitialAd(int32 AdIdIndex)`（Android）
- Python：`load_interstitial_ad(ad_id_index) -> None`
- 示例：

```python
api.load_interstitial_ad(0)
```

### is_interstitial_ad_available

- C++ 签名：`bool IsInterstitialAdAvailable()`（Android）
- Python：`is_interstitial_ad_available() -> bool`
- 示例：

```python
ready = api.is_interstitial_ad_available()
```

### is_interstitial_ad_requested

- C++ 签名：`bool IsInterstitialAdRequested()`（Android）
- Python：`is_interstitial_ad_requested() -> bool`
- 示例：

```python
requested = api.is_interstitial_ad_requested()
```

### show_interstitial_ad

- C++ 签名：`void ShowInterstitialAd()`（Android）
- Python：`show_interstitial_ad() -> None`
- 示例：

```python
api.show_interstitial_ad()
```

### show_platform_specific_leaderboard_screen

- C++ 签名：`void ShowPlatformSpecificLeaderboardScreen(const FString& CategoryName)`（iOS / Android，未来可能改名或移动）
- Python：`show_platform_specific_leaderboard_screen(category_name) -> None`
- 示例：

```python
api.show_platform_specific_leaderboard_screen("ScoreBoard")
```

### show_platform_specific_achievements_screen

- C++ 签名：`void ShowPlatformSpecificAchievementsScreen(const APlayerController* SpecificPlayer)`（iOS / Android）
- Python：`show_platform_specific_achievements_screen(specific_player) -> None`
- 说明：显示成就界面；`None` 时默认玩家 0。
- 示例：

```python
api.show_platform_specific_achievements_screen(pc)
```

### is_logged_in

- C++ 签名：`bool IsLoggedIn(const APlayerController* SpecificPlayer)`
- Python：`is_logged_in(specific_player) -> bool`
- 说明：玩家是否已登录当前在线子系统。
- 示例：

```python
logged_in = api.is_logged_in(pc)
```

### is_screensaver_enabled

- C++ 签名：`bool IsScreensaverEnabled()`
- Python：`is_screensaver_enabled() -> bool`
- 示例：

```python
enabled = api.is_screensaver_enabled()
```

### control_screensaver

- C++ 签名：`void ControlScreensaver(bool bAllowScreenSaver)`
- Python：`control_screensaver(b_allow_screen_saver) -> None`
- 说明：`False` 时尽可能抑制屏保。
- 示例：

```python
api.control_screensaver(False)
```

### set_volume_buttons_handled_by_system

- C++ 签名：`void SetVolumeButtonsHandledBySystem(bool bEnabled)`（Android）
- Python：`set_volume_buttons_handled_by_system(b_enabled) -> None`
- 示例：

```python
api.set_volume_buttons_handled_by_system(True)
```

### get_volume_buttons_handled_by_system

- C++ 签名：`bool GetVolumeButtonsHandledBySystem()`（Android）
- Python：`get_volume_buttons_handled_by_system() -> bool`
- 示例：

```python
handled = api.get_volume_buttons_handled_by_system()
```

### set_gamepads_block_device_feedback

- C++ 签名：`void SetGamepadsBlockDeviceFeedback(bool bBlock)`（移动端）
- Python：`set_gamepads_block_device_feedback(b_block) -> None`
- 示例：

```python
api.set_gamepads_block_device_feedback(True)
```

### reset_gamepad_assignments

- C++ 签名：`void ResetGamepadAssignments()`（Android / iOS）
- Python：`reset_gamepad_assignments() -> None`
- 示例：

```python
api.reset_gamepad_assignments()
```

### reset_gamepad_assignment_to_controller

- C++ 签名：`void ResetGamepadAssignmentToController(int32 ControllerId)`（Android / iOS）
- Python：`reset_gamepad_assignment_to_controller(controller_id) -> None`
- 示例：

```python
api.reset_gamepad_assignment_to_controller(0)
```

### is_controller_assigned_to_gamepad

- C++ 签名：`bool IsControllerAssignedToGamepad(int32 ControllerId)`（Android / iOS）
- Python：`is_controller_assigned_to_gamepad(controller_id) -> bool`
- 示例：

```python
assigned = api.is_controller_assigned_to_gamepad(0)
```

### get_gamepad_controller_name

- C++ 签名：`FString GetGamepadControllerName(int32 ControllerId)`（Android / iOS）
- Python：`get_gamepad_controller_name(controller_id) -> str`
- 示例：

```python
name = api.get_gamepad_controller_name(0)
```

### get_gamepad_button_glyph

- C++ 签名：`UTexture2D* GetGamepadButtonGlyph(const FString& ButtonKey, int32 ControllerIndex)`（iOS / tvOS）
- Python：`get_gamepad_button_glyph(button_key, controller_index) -> Texture2D 或 None`
- 示例：

```python
tex = api.get_gamepad_button_glyph("FaceButtonBottom", 0)
```

### set_suppress_viewport_transition_message

- C++ 签名：`void SetSuppressViewportTransitionMessage(const UObject* WorldContextObject, bool bState)`
- Python：`set_suppress_viewport_transition_message(world_context_object, b_state) -> None`
- 说明：控制暂停时视口过渡消息的显示。
- 示例：

```python
api.set_suppress_viewport_transition_message(world_context, True)
```

### get_preferred_languages

- C++ 签名：`TArray<FString> GetPreferredLanguages()`
- Python：`get_preferred_languages() -> Array[str]`
- 示例：

```python
langs = api.get_preferred_languages()
```

### get_default_language

- C++ 签名：`FString GetDefaultLanguage()`
- Python：`get_default_language() -> str`
- 说明：IETF 标签形式，如 `zh-Hans-CN`。
- 示例：

```python
lang = api.get_default_language()
```

### get_default_locale

- C++ 签名：`FString GetDefaultLocale()`
- Python：`get_default_locale() -> str`
- 示例：

```python
locale = api.get_default_locale()
```

### get_local_currency_code

- C++ 签名：`FString GetLocalCurrencyCode()`
- Python：`get_local_currency_code() -> str`
- 示例：

```python
code = api.get_local_currency_code()
```

### get_local_currency_symbol

- C++ 签名：`FString GetLocalCurrencySymbol()`
- Python：`get_local_currency_symbol() -> str`
- 示例：

```python
sym = api.get_local_currency_symbol()
```

### register_for_remote_notifications

- C++ 签名：`void RegisterForRemoteNotifications()`（Android / iOS）
- Python：`register_for_remote_notifications() -> None`
- 示例：

```python
api.register_for_remote_notifications()
```

### unregister_for_remote_notifications

- C++ 签名：`void UnregisterForRemoteNotifications()`（Android）
- Python：`unregister_for_remote_notifications() -> None`
- 示例：

```python
api.unregister_for_remote_notifications()
```

### set_user_activity

- C++ 签名：`void SetUserActivity(const FUserActivity& UserActivity)`
- Python：`set_user_activity(user_activity) -> None`
- 说明：告知引擎当前用户行为（供日志/分析）。
- 示例：

```python
api.set_user_activity(unreal.UserActivity(action_name="Exploring"))
```

### get_command_line

- C++ 签名：`FString GetCommandLine()`
- Python：`get_command_line() -> str`
- 示例：

```python
cmdline = api.get_command_line()
```

### parse_command_line

- C++ 签名：`void ParseCommandLine(const FString& InCmdLine, TArray<FString>& OutTokens, TArray<FString>& OutSwitches, TMap<FString, FString>& OutParams)`
- Python：`parse_command_line(in_cmd_line) -> (Array[str], Array[str], Dict[str, str])`
- 说明：解析命令行串为松散 token、开关（`-foo`）与参数（`-key=value`）。
- 示例：

```python
tokens, switches, params = api.parse_command_line("-foo -bar=/game/baz testtoken")
```

### parse_param

- C++ 签名：`bool ParseParam(const FString& InString, const FString& InParam)`
- Python：`parse_param(in_string, in_param) -> bool`
- 说明：字符串中是否含 `-param`（不要写前导 `-`）。
- 示例：

```python
has_demo = api.parse_param(api.get_command_line(), "demobuild")
```

### parse_param_value

- C++ 签名：`bool ParseParamValue(const FString& InString, const FString& InParam, FString& OutValue)`
- Python：`parse_param_value(in_string, in_param) -> (bool, str)`
- 示例：

```python
found, value = api.parse_param_value(api.get_command_line(), "benchmark")
```

### is_unattended

- C++ 签名：`bool IsUnattended()`
- Python：`is_unattended() -> bool`
- 说明：是否运行于无人值守模式（命令行含 `-unattended`）。
- 示例：

```python
unattended = api.is_unattended()
```

## 编辑器属性与事务（Editor Property / Transactions）

以下仅在编辑器构建可用（若标注 WITH_EDITOR）；事务相关会修改撤销缓冲，实施后需审计并确保由用户确认的保存流程。

### get_editor_property（编辑器）

- C++ 签名：`bool GetEditorProperty(UObject* Object, const FName PropertyName, int32& PropertyValue)`（WITH_EDITOR，结构体通用版本）
- Python：`get_editor_property(object, property_name) -> (bool, 值)`（值类型取决于属性；Python 侧按文档所述传任意已命名的属性）
- 说明：按名称读取对象属性并返回是否成功。较通用推荐使用 Python 原生 `get_editor_property`；此静态方法是蓝图内部节点对应。
- 示例：

```python
ok, value = api.get_editor_property(actor, "MaxHealth")
```

### set_editor_property（编辑器）

- C++ 签名：`bool SetEditorProperty(UObject* Object, const FName PropertyName, const int32& PropertyValue, const EPropertyAccessChangeNotifyMode ChangeNotifyMode)`（WITH_EDITOR）
- Python：`set_editor_property(object, property_name, value, change_notify_mode=...) -> bool`
- 示例：

```python
api.set_editor_property(actor, "MaxHealth", 100, unreal.PropertyAccessChangeNotifyMode.NEVER)
```

### reset_editor_property（编辑器）

- C++ 签名：`bool ResetEditorProperty(UObject* Object, const FName PropertyName, const EPropertyAccessChangeNotifyMode ChangeNotifyMode = EPropertyAccessChangeNotifyMode::Default)`（WITH_EDITOR）
- Python：`reset_editor_property(object, property_name, change_notify_mode=...) -> bool`
- 示例：

```python
api.reset_editor_property(actor, "MaxHealth")
```

### is_editor_property_overridden（编辑器）

- C++ 签名：`EEditorPropertyValueState IsEditorPropertyOverridden(UObject* Object, const FName PropertyName)`（WITH_EDITOR）
- Python：`is_editor_property_overridden(object, property_name) -> EditorPropertyValueState`
- 示例：

```python
state = api.is_editor_property_overridden(actor, "MaxHealth")
```

### begin_transaction

- C++ 签名：`int32 BeginTransaction(const FString& Context, FText Description, UObject* PrimaryObject)`
- Python：`begin_transaction(context, description, primary_object) -> int`
- 说明：开始撤销事务；返回活动 action 计数（>0 表示已在一个事务中），失败返回 -1。
- 示例：

```python
tx_index = api.begin_transaction("PythonEditor", "batch mesh change", primary_object)
```

### end_transaction

- C++ 签名：`int32 EndTransaction()`
- Python：`end_transaction() -> int`
- 说明：结束当前事务；成功闭合时 action 计数为 1。
- 示例：

```python
count = api.end_transaction()
```

### cancel_transaction

- C++ 签名：`void CancelTransaction(const int32 Index)`
- Python：`cancel_transaction(index) -> None`
- 说明：按 `begin_transaction` 返回的 Index 取消事务。
- 示例：

```python
api.cancel_transaction(tx_index)
```

### transact_object

- C++ 签名：`void TransactObject(UObject* Object)`
- Python：`transact_object(object) -> None`
- 说明：标记对象即将被修改并放入撤销缓冲（内部调用 Modify，会使所属包变脏）。
- 示例：

```python
api.transact_object(actor)
```

### snapshot_object

- C++ 签名：`void SnapshotObject(UObject* Object)`
- Python：`snapshot_object(object) -> None`
- 说明：为对象中间态快照（内部 SnapshotTransactionBuffer）。
- 示例：

```python
api.snapshot_object(actor)
```

### create_copy_for_undo_buffer

- C++ 签名：`void CreateCopyForUndoBuffer(UObject* ObjectToModify)`
- Python：`create_copy_for_undo_buffer(object_to_modify) -> None`
- 说明：把对象当前状态标记进撤销缓冲。
- 示例：

```python
api.create_copy_for_undo_buffer(actor)
```

## 资产管理器（Asset Manager）

### get_object（从 PrimaryAssetId 取对象）

- C++ 签名：`UObject* GetObjectFromPrimaryAssetId(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=GetObject`）
- Python：`get_object(primary_asset_id) -> Object 或 None`
- 说明：仅返回内存中已加载对象，不触发加载。
- 示例：

```python
obj = api.get_object(primary_asset_id)
```

### get_class（从 PrimaryAssetId 取类）

- C++ 签名：`TSubclassOf<UObject> GetClassFromPrimaryAssetId(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=GetClass`）
- Python：`get_class(primary_asset_id) -> Class 或 None`
- 示例：

```python
klass = api.get_class(primary_asset_id)
```

### get_soft_object_reference（从 PrimaryAssetId 取软对象引用）

- C++ 签名：`TSoftObjectPtr<UObject> GetSoftObjectReferenceFromPrimaryAssetId(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=GetSoftObjectReference`）
- Python：`get_soft_object_reference(primary_asset_id) -> SoftObjectReference`
- 示例：

```python
soft = api.get_soft_object_reference(primary_asset_id)
```

### get_soft_class_reference（从 PrimaryAssetId 取软类引用）

- C++ 签名：`TSoftClassPtr<UObject> GetSoftClassReferenceFromPrimaryAssetId(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=GetSoftClassReference`）
- Python：`get_soft_class_reference(primary_asset_id) -> SoftClassReference`
- 示例：

```python
scr = api.get_soft_class_reference(primary_asset_id)
```

### get_primary_asset_id_from_object

- C++ 签名：`FPrimaryAssetId GetPrimaryAssetIdFromObject(UObject* Object)`
- Python：`get_primary_asset_id_from_object(object) -> PrimaryAssetId`
- 说明：未注册资产返回无效 ID。
- 示例：

```python
paid = api.get_primary_asset_id_from_object(asset)
```

### get_primary_asset_id_from_class

- C++ 签名：`FPrimaryAssetId GetPrimaryAssetIdFromClass(TSubclassOf<UObject> Class)`
- Python：`get_primary_asset_id_from_class(object_class) -> PrimaryAssetId`
- 示例：

```python
paid = api.get_primary_asset_id_from_class(klass)
```

### get_primary_asset_id_from_soft_object_reference

- C++ 签名：`FPrimaryAssetId GetPrimaryAssetIdFromSoftObjectReference(TSoftObjectPtr<UObject> SoftObjectReference)`
- Python：`get_primary_asset_id_from_soft_object_reference(soft_object_reference) -> PrimaryAssetId`
- 示例：

```python
paid = api.get_primary_asset_id_from_soft_object_reference(soft)
```

### get_primary_asset_id_from_soft_class_reference

- C++ 签名：`FPrimaryAssetId GetPrimaryAssetIdFromSoftClassReference(TSoftClassPtr<UObject> SoftClassReference)`
- Python：`get_primary_asset_id_from_soft_class_reference(soft_class_reference) -> PrimaryAssetId`
- 示例：

```python
paid = api.get_primary_asset_id_from_soft_class_reference(scr)
```

### get_primary_asset_id_list

- C++ 签名：`void GetPrimaryAssetIdList(FPrimaryAssetType PrimaryAssetType, TArray<FPrimaryAssetId>& OutPrimaryAssetIdList)`
- Python：`get_primary_asset_id_list(primary_asset_type) -> Array[PrimaryAssetId]`
- 示例：

```python
id_list = api.get_primary_asset_id_list(primary_asset_type)
```

### is_valid（PrimaryAssetId）

- C++ 签名：`bool IsValidPrimaryAssetId(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=IsValid`，与同名字符串等工具重名，靠参数类型区分）
- Python：`is_valid(primary_asset_id) -> bool`
- 示例：

```python
ok = api.is_valid(primary_asset_id)
```

### to_string（PrimaryAssetId）

- C++ 签名：`FString Conv_PrimaryAssetIdToString(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=ToString`）
- Python：`to_string(primary_asset_id) -> str`
- 示例：

```python
s = api.to_string(primary_asset_id)
```

### equal_equal_primary_asset_id

- C++ 签名：`bool EqualEqual_PrimaryAssetId(FPrimaryAssetId A, FPrimaryAssetId B)`
- Python：`equal_equal_primary_asset_id(a, b) -> bool`
- 示例：

```python
same = api.equal_equal_primary_asset_id(a, b)
```

### not_equal_primary_asset_id

- C++ 签名：`bool NotEqual_PrimaryAssetId(FPrimaryAssetId A, FPrimaryAssetId B)`
- Python：`not_equal_primary_asset_id(a, b) -> bool`
- 示例：

```python
diff = api.not_equal_primary_asset_id(a, b)
```

### is_valid（PrimaryAssetType）

- C++ 签名：`bool IsValidPrimaryAssetType(FPrimaryAssetType PrimaryAssetType)`（`ScriptMethod=IsValid`）
- Python：`is_valid(primary_asset_type) -> bool`
- 示例：

```python
ok = api.is_valid(primary_asset_type)
```

### to_string（PrimaryAssetType）

- C++ 签名：`FString Conv_PrimaryAssetTypeToString(FPrimaryAssetType PrimaryAssetType)`（`ScriptMethod=ToString`）
- Python：`to_string(primary_asset_type) -> str`
- 示例：

```python
s = api.to_string(primary_asset_type)
```

### equal_equal_primary_asset_type

- C++ 签名：`bool EqualEqual_PrimaryAssetType(FPrimaryAssetType A, FPrimaryAssetType B)`
- Python：`equal_equal_primary_asset_type(a, b) -> bool`
- 示例：

```python
same = api.equal_equal_primary_asset_type(a, b)
```

### not_equal_primary_asset_type

- C++ 签名：`bool NotEqual_PrimaryAssetType(FPrimaryAssetType A, FPrimaryAssetType B)`
- Python：`not_equal_primary_asset_type(a, b) -> bool`
- 示例：

```python
diff = api.not_equal_primary_asset_type(a, b)
```

### unload（PrimaryAsset）

- C++ 签名：`void UnloadPrimaryAsset(FPrimaryAssetId PrimaryAssetId)`（`ScriptMethod=Unload`）
- Python：`unload(primary_asset_id) -> None`
- 示例：

```python
api.unload(primary_asset_id)
```

### unload_primary_asset_list

- C++ 签名：`void UnloadPrimaryAssetList(const TArray<FPrimaryAssetId>& PrimaryAssetIdList)`
- Python：`unload_primary_asset_list(primary_asset_id_list) -> None`
- 示例：

```python
api.unload_primary_asset_list(id_list)
```

### get_current_bundle_state

- C++ 签名：`bool GetCurrentBundleState(FPrimaryAssetId PrimaryAssetId, bool bForceCurrentState, TArray<FName>& OutBundles)`
- Python：`get_current_bundle_state(primary_asset_id, b_force_current_state=False) -> (bool, Array[Name])`
- 示例：

```python
ok, bundles = api.get_current_bundle_state(primary_asset_id, False)
```

### get_primary_assets_with_bundle_state

- C++ 签名：`void GetPrimaryAssetsWithBundleState(const TArray<FName>& RequiredBundles, const TArray<FName>& ExcludedBundles, const TArray<FPrimaryAssetType>& ValidTypes, bool bForceCurrentState, TArray<FPrimaryAssetId>& OutPrimaryAssetIdList)`
- Python：`get_primary_assets_with_bundle_state(required_bundles, excluded_bundles, valid_types, b_force_current_state=False) -> Array[PrimaryAssetId]`
- 示例：

```python
ids = api.get_primary_assets_with_bundle_state(["Ready"], [], [], False)
```

## ARFilter（资产过滤器）

### make_ar_filter

- C++ 签名：`FARFilter MakeARFilter(const TArray<FName>& PackageNames, const TArray<FName>& PackagePaths, const TArray<FSoftObjectPath>& SoftObjectPaths, const TArray<FTopLevelAssetPath>& ClassPaths, const TSet<FTopLevelAssetPath>& RecursiveClassPathsExclusionSet, const TArray<FName>& ClassNames, const TSet<FName>& RecursiveClassesExclusionSet, const bool bRecursivePaths=false, const bool bRecursiveClasses=false, const bool bIncludeOnlyOnDiskAssets=false)`
- Python：`make_ar_filter(...) -> ARFilter`
- 说明：构造 ARFilter；优先使用 `class_paths`，`class_names`/`recursive_classes_exclusion_set` 已弃用（传非空会触发运行时警告）。
- 示例：

```python
filt = api.make_ar_filter(package_names, package_paths, soft_object_paths,
    class_paths, recursive_class_paths_exclusion_set, class_names,
    recursive_classes_exclusion_set, b_recursive_paths=True, b_include_only_on_disk_assets=True)
```

### break_ar_filter

- C++ 签名：`void BreakARFilter(FARFilter InARFilter, TArray<FName>& PackageNames, TArray<FName>& PackagePaths, TArray<FSoftObjectPath>& SoftObjectPaths, TArray<FTopLevelAssetPath>& ClassPaths, TSet<FTopLevelAssetPath>& RecursiveClassPathsExclusionSet, TArray<FName>& ClassNames, TSet<FName>& RecursiveClassesExclusionSet, bool& bRecursivePaths, bool& bRecursiveClasses, bool& bIncludeOnlyOnDiskAssets)`
- Python：`break_ar_filter(in_ar_filter) -> (Array[Name], Array[Name], Array[SoftObjectPath], Array[TopLevelAssetPath], Set[TopLevelAssetPath], Array[Name], Set[Name], bool, bool, bool)`
- 示例：

```python
(pns, pps, sops, cps, rcles, cns, rces, b_rec, b_cls, b_ondisk) = api.break_ar_filter(filt)
```

## 完整端到端示例：追踪 + 重叠 + 调试绘制 + 定时器

```python
import unreal

def main():
    api = unreal.KismetSystemLibrary
    world_context = unreal.get_engine_subsystem(unreal.UnrealEngineSubsystem).get_game_instance()

    start = unreal.Vector(0.0, 0.0, 200.0)
    end = unreal.Vector(0.0, 0.0, -2000.0)

    hit_any, hit = api.line_trace_single(
        world_context, start, end,
        unreal.TraceTypeQuery.TRACE_TYPE_QUERY1, False, [],
        unreal.DrawDebugTrace.NONE, True,
    )
    if hit_any:
        print({"status": "OK", "hit_actor": api.get_display_name(hit.get_actor())})

    overlap_ok, actors = api.sphere_overlap_actors(
        world_context, unreal.Vector(0, 0, 0), 500.0,
        [unreal.ObjectTypeQuery.OBJECT_TYPE_QUERY3], None, [],
    )
    api.draw_debug_line(world_context, start, end, unreal.LinearColor(1.0, 0.0, 0.0, 1.0), 2.0)

    handle = api.set_timer(world_context, "OnElapsed", 1.0, True)

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少世界上下文对象、对象/类引用、属性名、路径等必要输入，或类路径无法加载。
- `BLOCKED_TOOLING`：编辑器/运行时上下文不可用（如编辑器纯编辑态执行 Trace、延迟、定时器，或专用服务器执行本地玩家类操作）、平台功能不支持、或所需引擎/平台服务缺失。
- `DrawDebug*`、`print_string`、事务、属性写入等属于会留下可见或持久状态的操作：实施后必须由审计/QA 独立验收，未验证前不得声称已完成。
- 生命周期类操作（延迟、定时器、资产加载流送、垃圾回收）依赖运行世界与调度语义：脚本必须在运行会话内给出可验证结果。
- 本文件覆盖 `KismetSystemLibrary.h` 中全部带 `UFUNCTION` 标记（`BlueprintCallable / BlueprintPure`）成员的完整清单；标称方法名与精确 Python 暴露名需在目标 UE 5.6 编辑器 `dir()`/`help()` 实测确认后方可断言。