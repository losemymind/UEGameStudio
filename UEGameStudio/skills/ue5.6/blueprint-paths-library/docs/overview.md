# BlueprintPathsLibrary - API 参考与完整示例（UE 5.6）

本文件按 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintPathsLibrary.h` 整理 `UBlueprintPathsLibrary` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的可由 Python 调用的成员，覆盖该头文件全部 UFUNCTION 成员。Python 类名为 `unreal.BlueprintPathsLibrary`。Python 方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case；无则按 C++ 函数名转 snake_case（本类头文件全部未声明 `ScriptMethod`，故一律按 C++ 函数名转换）。精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。

## 入口与通用约定

```python
import unreal

paths = unreal.BlueprintPathsLibrary
```

- 本类全部成员为 static UFUNCTION，以类方法形式调用，无需实例化。
- Out/ByRef 参数返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回（返回值在首位）；无 Out 且无返回值则返回 `None`。
- 返回 `FString` 的方法在 Python 中得到 `str`；返回 `const TArray<FString>&` 得到 `Array[str]`；`FText` 得到 `unreal.Text`。

## 根与启动

### should_save_to_user_dir

- C++ 签名：`bool ShouldSaveToUserDir()`
- Python：`should_save_to_user_dir() -> bool`
- 说明：Saved 目录结构是否应根植于用户目录（而非相对于引擎/游戏目录）。
- 示例：

```python
if paths.should_save_to_user_dir():
    print("saved directories are rooted in the user dir")
```

### launch_dir

- C++ 签名：`FString LaunchDir()`
- Python：`launch_dir() -> str`
- 说明：返回应用被启动的目录（命令行工具常用）。
- 示例：

```python
print("launch dir:", paths.launch_dir())
```

### root_dir

- C++ 签名：`FString RootDir()`
- Python：`root_dir() -> str`
- 说明：返回引擎目录树的根目录。
- 示例：

```python
print("root dir:", paths.root_dir())
```

### get_relative_path_to_root

- C++ 签名：`const FString& GetRelativePathToRoot()`
- Python：`get_relative_path_to_root() -> str`
- 说明：返回从 BaseDir 到根目录的相对路径。
- 示例：

```python
print("relative path to root:", paths.get_relative_path_to_root())
```

## 引擎目录

### engine_dir

- C++ 签名：`FString EngineDir()`
- Python：`engine_dir() -> str`
- 说明：返回可跨游戏共享的引擎核心基础目录（着色器、基础本地化文件等所在）。
- 示例：

```python
print("engine dir:", paths.engine_dir())
```

### engine_user_dir

- C++ 签名：`FString EngineUserDir()`
- Python：`engine_user_dir() -> str`
- 说明：返回用户专属引擎文件根目录，始终可写。
- 示例：

```python
print("engine user dir:", paths.engine_user_dir())
```

### engine_version_agnostic_user_dir

- C++ 签名：`FString EngineVersionAgnosticUserDir()`
- Python：`engine_version_agnostic_user_dir() -> str`
- 说明：返回可在版本间共享的用户专属引擎文件根目录，始终可写。
- 示例：

```python
print("version agnostic user dir:", paths.engine_version_agnostic_user_dir())
```

### engine_content_dir

- C++ 签名：`FString EngineContentDir()`
- Python：`engine_content_dir() -> str`
- 说明：返回引擎 Content 目录。
- 示例：

```python
print("engine content dir:", paths.engine_content_dir())
```

### engine_config_dir

- C++ 签名：`FString EngineConfigDir()`
- Python：`engine_config_dir() -> str`
- 说明：返回引擎根配置文件的目录。
- 示例：

```python
print("engine config dir:", paths.engine_config_dir())
```

### engine_intermediate_dir

- C++ 签名：`FString EngineIntermediateDir()`
- Python：`engine_intermediate_dir() -> str`
- 说明：返回引擎 Intermediate 目录。
- 示例：

```python
print("engine intermediate dir:", paths.engine_intermediate_dir())
```

### engine_saved_dir

- C++ 签名：`FString EngineSavedDir()`
- Python：`engine_saved_dir() -> str`
- 说明：返回引擎 Saved 目录。
- 示例：

```python
print("engine saved dir:", paths.engine_saved_dir())
```

### engine_plugins_dir

- C++ 签名：`FString EnginePluginsDir()`
- Python：`engine_plugins_dir() -> str`
- 说明：返回引擎 Plugins 目录。
- 示例：

```python
print("engine plugins dir:", paths.engine_plugins_dir())
```

### engine_source_dir

- C++ 签名：`FString EngineSourceDir()`
- Python：`engine_source_dir() -> str`
- 说明：返回引擎源码文件存放目录。
- 示例：

```python
print("engine source dir:", paths.engine_source_dir())
```

### enterprise_dir

- C++ 签名：`FString EnterpriseDir()`
- Python：`enterprise_dir() -> str`
- 说明：返回 Enterprise 基础目录。
- 示例：

```python
print("enterprise dir:", paths.enterprise_dir())
```

### enterprise_plugins_dir

- C++ 签名：`FString EnterprisePluginsDir()`
- Python：`enterprise_plugins_dir() -> str`
- 说明：返回 Enterprise Plugins 目录。
- 示例：

```python
print("enterprise plugins dir:", paths.enterprise_plugins_dir())
```

### enterprise_feature_pack_dir

- C++ 签名：`FString EnterpriseFeaturePackDir()`
- Python：`enterprise_feature_pack_dir() -> str`
- 说明：返回 Enterprise FeaturePack 目录。
- 示例：

```python
print("enterprise feature pack dir:", paths.enterprise_feature_pack_dir())
```

## 项目目录

### project_dir

- C++ 签名：`FString ProjectDir()`
- Python：`project_dir() -> str`
- 说明：按 `FApp::GetProjectName()` 返回当前项目基础目录（通常是安装根目录的子目录，可被命令行覆盖以支持自包含 Mod）。
- 示例：

```python
print("project dir:", paths.project_dir())
```

### project_user_dir

- C++ 签名：`FString ProjectUserDir()`
- Python：`project_user_dir() -> str`
- 说明：返回用户专属游戏文件根目录。
- 示例：

```python
print("project user dir:", paths.project_user_dir())
```

### project_content_dir

- C++ 签名：`FString ProjectContentDir()`
- Python：`project_content_dir() -> str`
- 说明：按项目名返回当前游戏 Content 目录。
- 示例：

```python
print("project content dir:", paths.project_content_dir())
```

### project_config_dir

- C++ 签名：`FString ProjectConfigDir()`
- Python：`project_config_dir() -> str`
- 说明：返回项目根配置文件所在目录。
- 示例：

```python
print("project config dir:", paths.project_config_dir())
```

### project_saved_dir

- C++ 签名：`FString ProjectSavedDir()`
- Python：`project_saved_dir() -> str`
- 说明：按项目名返回当前游戏 Saved 目录。
- 示例：

```python
print("project saved dir:", paths.project_saved_dir())
```

### project_intermediate_dir

- C++ 签名：`FString ProjectIntermediateDir()`
- Python：`project_intermediate_dir() -> str`
- 说明：按项目名返回当前游戏 Intermediate 目录。
- 示例：

```python
print("project intermediate dir:", paths.project_intermediate_dir())
```

### project_plugins_dir

- C++ 签名：`FString ProjectPluginsDir()`
- Python：`project_plugins_dir() -> str`
- 说明：按项目名返回当前游戏 Plugins 目录。
- 示例：

```python
print("project plugins dir:", paths.project_plugins_dir())
```

### project_mods_dir

- C++ 签名：`FString ProjectModsDir()`
- Python：`project_mods_dir() -> str`
- 说明：按项目名返回当前项目 Mods 目录。
- 示例：

```python
print("project mods dir:", paths.project_mods_dir())
```

### project_log_dir

- C++ 签名：`FString ProjectLogDir()`
- Python：`project_log_dir() -> str`
- 说明：返回引擎输出日志的目录（游戏在读取 .ini 之前就开始记录日志，故不可用 .ini 配置）。
- 示例：

```python
print("project log dir:", paths.project_log_dir())
```

### game_source_dir

- C++ 签名：`FString GameSourceDir()`
- Python：`game_source_dir() -> str`
- 说明：返回游戏源码文件存放目录。
- 示例：

```python
print("game source dir:", paths.game_source_dir())
```

### game_agnostic_saved_dir

- C++ 签名：`FString GameAgnosticSavedDir()`
- Python：`game_agnostic_saved_dir() -> str`
- 说明：返回与游戏无关的 Saved 目录，通常与 `EngineSavedDir()` 相同。
- 示例：

```python
print("game agnostic saved dir:", paths.game_agnostic_saved_dir())
```

### game_developers_dir

- C++ 签名：`FString GameDevelopersDir()`
- Python：`game_developers_dir() -> str`
- 说明：返回包含开发者专属内容子文件夹的目录。
- 示例：

```python
print("game developers dir:", paths.game_developers_dir())
```

### game_user_developer_dir

- C++ 签名：`FString GameUserDeveloperDir()`
- Python：`game_user_developer_dir() -> str`
- 说明：返回当前用户的开发者专属内容目录。
- 示例：

```python
print("game user developer dir:", paths.game_user_developer_dir())
```

### has_project_persistent_download_dir

- C++ 签名：`bool HasProjectPersistentDownloadDir()`
- Python：`has_project_persistent_download_dir() -> bool`
- 说明：是否存在跨游玩会话持久化的可写下载数据目录。
- 示例：

```python
print("persistent download dir available:", paths.has_project_persistent_download_dir())
```

### project_persistent_download_dir

- C++ 签名：`FString ProjectPersistentDownloadDir()`
- Python：`project_persistent_download_dir() -> str`
- 说明：返回跨游玩会话持久化下载数据的可写目录。
- 示例：

```python
if paths.has_project_persistent_download_dir():
    print("download dir:", paths.project_persistent_download_dir())
```

## 工具与临时目录

### shader_working_dir

- C++ 签名：`FString ShaderWorkingDir()`
- Python：`shader_working_dir() -> str`
- 说明：返回 Shader Working 目录。
- 示例：

```python
print("shader working dir:", paths.shader_working_dir())
```

### source_config_dir

- C++ 签名：`FString SourceConfigDir()`
- Python：`source_config_dir() -> str`
- 说明：返回引擎查找源叶 ini 文件的目录（该目录无法用 .ini 变量表述）。
- 示例：

```python
print("source config dir:", paths.source_config_dir())
```

### generated_config_dir

- C++ 签名：`FString GeneratedConfigDir()`
- Python：`generated_config_dir() -> str`
- 说明：返回引擎保存生成配置文件的目录。
- 示例：

```python
print("generated config dir:", paths.generated_config_dir())
```

### sandboxes_dir

- C++ 签名：`FString SandboxesDir()`
- Python：`sandboxes_dir() -> str`
- 说明：返回引擎存放沙盒输出（Saved/Sandboxes）的目录。
- 示例：

```python
print("sandboxes dir:", paths.sandboxes_dir())
```

### profiling_dir

- C++ 签名：`FString ProfilingDir()`
- Python：`profiling_dir() -> str`
- 说明：返回引擎输出性能分析文件的目录。
- 示例：

```python
print("profiling dir:", paths.profiling_dir())
```

### screen_shot_dir

- C++ 签名：`FString ScreenShotDir()`
- Python：`screen_shot_dir() -> str`
- 说明：返回引擎输出截图文件的目录。
- 示例：

```python
print("screenshot dir:", paths.screen_shot_dir())
```

### bug_it_dir

- C++ 签名：`FString BugItDir()`
- Python：`bug_it_dir() -> str`
- 说明：返回引擎输出 BugIt 文件的目录。
- 示例：

```python
print("bugit dir:", paths.bug_it_dir())
```

### video_capture_dir

- C++ 签名：`FString VideoCaptureDir()`
- Python：`video_capture_dir() -> str`
- 说明：返回引擎输出用户请求视频捕获文件的目录。
- 示例：

```python
print("video capture dir:", paths.video_capture_dir())
```

### automation_dir

- C++ 签名：`FString AutomationDir()`
- Python：`automation_dir() -> str`
- 说明：返回自动化保存文件目录。
- 示例：

```python
print("automation dir:", paths.automation_dir())
```

### automation_transient_dir

- C++ 签名：`FString AutomationTransientDir()`
- Python：`automation_transient_dir() -> str`
- 说明：返回每次运行会被删除的自动化保存文件目录。
- 示例：

```python
print("automation transient dir:", paths.automation_transient_dir())
```

### automation_log_dir

- C++ 签名：`FString AutomationLogDir()`
- Python：`automation_log_dir() -> str`
- 说明：返回自动化日志文件目录。
- 示例：

```python
print("automation log dir:", paths.automation_log_dir())
```

### cloud_dir

- C++ 签名：`FString CloudDir()`
- Python：`cloud_dir() -> str`
- 说明：返回云模拟或支持使用的本地文件目录。
- 示例：

```python
print("cloud dir:", paths.cloud_dir())
```

### diff_dir

- C++ 签名：`FString DiffDir()`
- Python：`diff_dir() -> str`
- 说明：返回用于 diff 的临时文件目录。
- 示例：

```python
print("diff dir:", paths.diff_dir())
```

### feature_pack_dir

- C++ 签名：`FString FeaturePackDir()`
- Python：`feature_pack_dir() -> str`
- 说明：返回 FeaturePack 存放目录。
- 示例：

```python
print("feature pack dir:", paths.feature_pack_dir())
```

## 本地化与限制路径

### get_engine_localization_paths

- C++ 签名：`const TArray<FString>& GetEngineLocalizationPaths()`
- Python：`get_engine_localization_paths() -> Array[str]`
- 说明：返回引擎专属本地化路径列表。
- 示例：

```python
for p in paths.get_engine_localization_paths():
    print("engine loc:", p)
```

### get_editor_localization_paths

- C++ 签名：`const TArray<FString>& GetEditorLocalizationPaths()`
- Python：`get_editor_localization_paths() -> Array[str]`
- 说明：返回编辑器专属本地化路径列表。
- 示例：

```python
print("editor loc paths:", paths.get_editor_localization_paths())
```

### get_property_name_localization_paths

- C++ 签名：`const TArray<FString>& GetPropertyNameLocalizationPaths()`
- Python：`get_property_name_localization_paths() -> Array[str]`
- 说明：返回属性名本地化路径列表。
- 示例：

```python
print("property name loc paths:", paths.get_property_name_localization_paths())
```

### get_tool_tip_localization_paths

- C++ 签名：`const TArray<FString>& GetToolTipLocalizationPaths()`
- Python：`get_tool_tip_localization_paths() -> Array[str]`
- 说明：返回工具提示本地化路径列表。
- 示例：

```python
print("tooltip loc paths:", paths.get_tool_tip_localization_paths())
```

### get_game_localization_paths

- C++ 签名：`const TArray<FString>& GetGameLocalizationPaths()`
- Python：`get_game_localization_paths() -> Array[str]`
- 说明：返回游戏专属本地化路径列表。
- 示例：

```python
print("game loc paths:", paths.get_game_localization_paths())
```

### get_restricted_folder_names

- C++ 签名：`const TArray<FString>& GetRestrictedFolderNames()`
- Python：`get_restricted_folder_names() -> Array[str]`
- 说明：返回受限/内部文件夹名列表（不含斜杠），可用于对完整路径判定受限与否。
- 示例：

```python
print("restricted folders:", paths.get_restricted_folder_names())
```

### is_restricted_path

- C++ 签名：`bool IsRestrictedPath(const FString& InPath)`
- Python：`is_restricted_path(in_path) -> bool`
- 说明：判定所给路径是否使用受限/内部子目录；比较时斜杠被规范化且忽略字符大小写。
- 示例：

```python
check = paths.project_dir() + "/Restricted/Something"
if paths.is_restricted_path(check):
    print("path uses a restricted folder")
```

## 工程文件

### is_project_file_path_set

- C++ 签名：`bool IsProjectFilePathSet()`
- Python：`is_project_file_path_set() -> bool`
- 说明：工程文件路径是否已设置。
- 示例：

```python
print("project path set:", paths.is_project_file_path_set())
```

### get_project_file_path

- C++ 签名：`FString GetProjectFilePath()`
- Python：`get_project_file_path() -> str`
- 说明：返回工程文件（.uproject）路径。
- 示例：

```python
print("project file:", paths.get_project_file_path())
```

### set_project_file_path

- C++ 签名：`void SetProjectFilePath(const FString& NewGameProjectFilePath)`
- Python：`set_project_file_path(new_game_project_file_path) -> None`
- 说明：设置工程文件路径。写入后会影响本类其它项目相关查询的结果，属运行态全局状态。
- 示例：

```python
if paths.is_project_file_path_set():
    paths.set_project_file_path("D:/Dev/NewGame/NewGame.uproject")
print("project file now:", paths.get_project_file_path())
```

## 文件名处理

### get_extension

- C++ 签名：`FString GetExtension(const FString& InPath, bool bIncludeDot = false)`
- Python：`get_extension(in_path, b_include_dot=False) -> str`
- 说明：返回文件名扩展名；无扩展名返回空字符串。`b_include_dot=True` 时结果包含前导点。
- 示例：

```python
ext = paths.get_extension("D:/Game/Content/Maps/Main.umap")
print("extension:", ext)
with_dot = paths.get_extension("D:/Game/Content/Maps/Main.umap", True)
print("extension with dot:", with_dot)
```

### get_clean_filename

- C++ 签名：`FString GetCleanFilename(const FString& InPath)`
- Python：`get_clean_filename(in_path) -> str`
- 说明：返回去掉路径信息后的文件名（含扩展名）。
- 示例：

```python
print("clean filename:", paths.get_clean_filename("D:/Game/Saved/Logs/UE5.log"))
```

### get_base_filename

- C++ 签名：`FString GetBaseFilename(const FString& InPath, bool bRemovePath = true)`
- Python：`get_base_filename(in_path, b_remove_path=True) -> str`
- 说明：与 GetCleanFilename 相同但去掉扩展名；`b_remove_path` 控制是否同时去除路径。
- 示例：

```python
print("base filename:", paths.get_base_filename("D:/Game/Saved/Logs/UE5.log"))
print("name only:", paths.get_base_filename("D:/Game/Saved/Logs/UE5.log", False))
```

### get_path

- C++ 签名：`FString GetPath(const FString& InPath)`
- Python：`get_path(in_path) -> str`
- 说明：返回文件名之前的路径部分。
- 示例：

```python
print("path part:", paths.get_path("D:/Game/Content/Maps/Main.umap"))
```

### change_extension

- C++ 签名：`FString ChangeExtension(const FString& InPath, const FString& InNewExtension)`
- Python：`change_extension(in_path, in_new_extension) -> str`
- 说明：修改文件扩展名（文件没有扩展名时不做改动）。
- 示例：

```python
print(paths.change_extension("D:/Game/Content/Maps/Main.umap", ".txt"))
```

### set_extension

- C++ 签名：`FString SetExtension(const FString& InPath, const FString& InNewExtension)`
- Python：`set_extension(in_path, in_new_extension) -> str`
- 说明：设置扩展名（与 ChangeExtension 类似，但文件没有扩展名时也会补上）。
- 示例：

```python
print(paths.set_extension("D:/Game/Content/Maps/MapName", ".umap"))
```

### get_invalid_file_system_chars

- C++ 签名：`FString GetInvalidFileSystemChars()`
- Python：`get_invalid_file_system_chars() -> str`
- 说明：返回操作系统规定的全部非法文件名字符组成的字符串。
- 示例：

```python
print("invalid chars:", paths.get_invalid_file_system_chars())
```

### make_valid_file_name

- C++ 签名：`FString MakeValidFileName(const FString& InString, const FString& InReplacementChar = TEXT(""))`
- Python：`make_valid_file_name(in_string, in_replacement_char="") -> str`
- 说明：移除 InString 中全部非法字符，返回可安全用作文件名的字符串；`in_replacement_char` 可指定替换非法字符串的字符。
- 示例：

```python
safe = paths.make_valid_file_name("Report:2026-09-01?A/B", "_")
print("safe name:", safe)
```

### create_temp_filename

- C++ 签名：`FString CreateTempFilename(const FString& Path, const FString& Prefix = TEXT(""), const FString& Extension = TEXT(".tmp"))`
- Python：`create_temp_filename(path, prefix="", extension=".tmp") -> str`
- 说明：在指定目录创建带前缀的临时文件名（扩展名需以 `.` 开头）。
- 示例：

```python
tmp = paths.create_temp_filename(paths.project_saved_dir(), "audit")
print("temp file:", tmp)
```

## 存在性与判定

### file_exists

- C++ 签名：`bool FileExists(const FString& InPath)`
- Python：`file_exists(in_path) -> bool`
- 说明：文件是否存在。
- 示例：

```python
project_file = paths.get_project_file_path()
if not paths.file_exists(project_file):
    print("project file missing on disk")
```

### directory_exists

- C++ 签名：`bool DirectoryExists(const FString& InPath)`
- Python：`directory_exists(in_path) -> bool`
- 说明：目录是否存在。
- 示例：

```python
if paths.directory_exists(paths.project_content_dir()):
    print("content dir present")
```

### is_drive

- C++ 签名：`bool IsDrive(const FString& InPath)`
- Python：`is_drive(in_path) -> bool`
- 说明：路径是否表示根驱动器或卷。
- 示例：

```python
print("is drive D:/.", paths.is_drive("D:/"), paths.is_drive("D:/Game"))
```

### is_relative

- C++ 签名：`bool IsRelative(const FString& InPath)`
- Python：`is_relative(in_path) -> bool`
- 说明：路径是否为相对路径（相对另一路径）。
- 示例：

```python
print("relative:", paths.is_relative("Content/Maps/Main.umap"))
print("relative:", paths.is_relative("D:/Game/Content/Maps/Main.umap"))
```

### is_same_path

- C++ 签名：`bool IsSamePath(const FString& PathA, const FString& PathB)`
- Python：`is_same_path(path_a, path_b) -> bool`
- 说明：判断两个路径是否为同一路径。
- 示例：

```python
if paths.is_same_path("D:/Game/a.txt", "D:/Game/A.TXT"):
    print("treated as same path")
```

## 路径规范化

### normalize_filename

- C++ 签名：`void NormalizeFilename(const FString& InPath, FString& OutPath)`
- Python：`normalize_filename(in_path) -> str`
- 说明：将全部 `/` 与 `\` 规范化为 `/`，单 Out 直接返回结果。
- 示例：

```python
print(paths.normalize_filename("D:\\Game\\Content\\Maps\\Main.umap"))
```

### normalize_directory_name

- C++ 签名：`void NormalizeDirectoryName(const FString& InPath, FString& OutPath)`
- Python：`normalize_directory_name(in_path) -> str`
- 说明：规范化全部分隔符为 `/`，并去除末尾 `/`（若前一个字符不是 `/` 或冒号）。
- 示例：

```python
print(paths.normalize_directory_name("D:\\Game\\Content\\MapDir\\"))
```

### remove_duplicate_slashes

- C++ 签名：`void RemoveDuplicateSlashes(const FString& InPath, FString& OutPath)`
- Python：`remove_duplicate_slashes(in_path) -> str`
- 说明：去除路径中重复的斜杠（假定斜杠已规范化为 `/`）。
- 示例：

```python
print(paths.remove_duplicate_slashes("D:/Game//Content////Maps"))
```

### make_standard_filename

- C++ 签名：`void MakeStandardFilename(const FString& InPath, FString& OutPath)`
- Python：`make_standard_filename(in_path) -> str`
- 说明：生成标准"Unreal"路径：规范化分隔符、去除多余分隔符、折叠内部 `..`，并相对 `Engine\Binaries\<平台>`（结果以 `..\..\..` 开头）。
- 示例：

```python
print(paths.make_standard_filename("D:/Game/Content/../Content/A.umap"))
```

### make_platform_filename

- C++ 签名：`void MakePlatformFilename(const FString& InPath, FString& OutPath)`
- Python：`make_platform_filename(in_path) -> str`
- 说明：将"Unreal"路径转换为平台文件名（使用平台分隔符）。
- 示例：

```python
print(paths.make_platform_filename("D:/Game/Content/Maps/Main.umap"))
```

### collapse_relative_directories

- C++ 签名：`bool CollapseRelativeDirectories(const FString& InPath, FString& OutPath)`
- Python：`collapse_relative_directories(in_path) -> Tuple[bool, str]`
- 说明：折叠相对路径成分（如用相邻目录抵消 `..`）。返回 `(是否发生改变, 折叠后的路径)`。例：`Base/a/../b/F.ext` → `Base/b/F.ext`。
- 示例：

```python
ok, collapsed = paths.collapse_relative_directories("D:/Game/a/../b/F.ext")
print(ok, collapsed)
```

### make_path_relative_to

- C++ 签名：`bool MakePathRelativeTo(const FString& InPath, const FString& InRelativeTo, FString& OutPath)`
- Python：`make_path_relative_to(in_path, in_relative_to) -> Tuple[bool, str]`
- 说明：假定两个路径相对同一基目录，将 InPath 转为相对 InRelativeTo 的路径。返回 `(是否成功转为相对, 结果路径)`。
- 示例：

```python
ok, relative = paths.make_path_relative_to("D:/Game/Content/Maps/Main.umap", "D:/Game/Content")
print(ok, relative)
```

## 转换

### convert_relative_path_to_full

- C++ 签名：`FString ConvertRelativePathToFull(const FString& InPath, const FString& InBasePath = TEXT(""))`
- Python：`convert_relative_path_to_full(in_path, in_base_path="") -> str`
- 说明：将相对路径转为相对 `in_base_path`（缺省为进程 BaseDir）的绝对路径。
- 示例：

```python
full = paths.convert_relative_path_to_full("Saved/Logs/UE5.log", paths.project_dir())
print("full log path:", full)
base_full = paths.convert_relative_path_to_full("Content/Maps/Main.umap")
print("base-relative full path:", base_full)
```

### convert_to_sandbox_path

- C++ 签名：`FString ConvertToSandboxPath(const FString& InPath, const FString& InSandboxName)`
- Python：`convert_to_sandbox_path(in_path, in_sandbox_name) -> str`
- 说明：将普通路径转换为沙盒路径（位于 Saved/Sandboxes 下）。
- 示例：

```python
sandboxed = paths.convert_to_sandbox_path("D:/Game/Saved/Config/Engine.ini", "dev-box")
print("sandbox path:", sandboxed)
```

### convert_from_sandbox_path

- C++ 签名：`FString ConvertFromSandboxPath(const FString& InPath, const FString& InSandboxName)`
- Python：`convert_from_sandbox_path(in_path, in_sandbox_name) -> str`
- 说明：将沙盒路径（Saved/Sandboxes 下）转换回普通路径。
- 示例：

```python
normal = paths.convert_from_sandbox_path(sandboxed_path, "dev-box")
print("normal path:", normal)
```

## 拆分与校验

### split

- C++ 签名：`void Split(const FString& InPath, FString& PathPart, FString& FilenamePart, FString& ExtensionPart)`
- Python：`split(in_path) -> Tuple[str, str, str]`
- 说明：将完全限定或相对文件名解析为（路径、文件名、扩展名）三个部分。
- 示例：

```python
path_part, filename_part, extension_part = paths.split(
    "D:/Game/Content/Maps/Main.umap"
)
print(path_part, filename_part, extension_part)
```

### validate_path

- C++ 签名：`void ValidatePath(const FString& InPath, bool& bDidSucceed, FText& OutReason)`
- Python：`validate_path(in_path) -> Tuple[bool, Text]`
- 说明：校验路径各部分不含操作系统非法字符（此限制与 FPackageName 不同）。返回 `(是否通过校验, 失败原因)`。
- 示例：

```python
valid, reason = paths.validate_path("D:/Game/Content/OK/Path")
print(valid, reason)
bad, reason = paths.validate_path("D:/Game/Bad?Name")
if not bad:
    print("reason:", reason)
```

## 组合

### combine

- C++ 签名：`FString Combine(const TArray<FString>& InPaths)`
- Python：`combine(in_paths) -> str`
- 说明：将两个或多个路径合并为一个路径。
- 示例：

```python
joined = paths.combine(["D:/Game/Content", "Maps", "Main.umap"])
print("combined:", joined)
```

## 完整端到端示例

```python
import unreal

def main():
    paths = unreal.BlueprintPathsLibrary

    if not paths.is_project_file_path_set():
        print({"status": "BLOCKED_TOOLING", "reason": "project file path not set"})
        return

    project_file = paths.get_project_file_path()
    project_root = paths.get_path(project_file)
    if not paths.file_exists(project_file):
        print({"status": "BLOCKED_INPUT", "reason": "project file missing on disk"})
        return

    saved_dir = paths.get_project_saved_dir()
    log_dir = paths.get_project_log_dir()
    content_full = paths.convert_relative_path_to_full("Content/Maps/Main.umap", project_root)

    print({"status": "OK",
           "project_file": project_file,
           "saved": saved_dir,
           "log": log_dir,
           "content_full": content_full})

if __name__ == "__main__":
    main()
```

## 阻塞状态与诚实性

- `BLOCKED_INPUT`：缺少必要输入（空/非法路径串、工程文件路径未设置或磁盘不存在等）。
- `BLOCKED_TOOLING`：运行环境不可用（无法确定项目、不在有效引擎上下文、库不可用），无法执行查询。
- 本类全部成员为只读查询或纯字符串处理，不修改项目内容；查询结果依赖真实运行环境，不得以硬编码或磁盘猜测替代。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言；精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。
- 本文件覆盖 `BlueprintPathsLibrary.h` 中全部带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员。