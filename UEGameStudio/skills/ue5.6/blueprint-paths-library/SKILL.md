---
name: blueprint-paths-library
description: UBlueprintPathsLibrary（UE 5.6）路径查询与规范化 Function Library - 引擎/项目/用户/沙盒等目录获取、路径组合与拆分、文件名操作、规范化与相对/绝对转换；在 Agent 需要从 Python 定位或清洗引擎与磁盘路径（日志、Saved、Content、工程文件）时使用
tags: [ue5.6, python, paths, filesystem, function-library]
---

# BlueprintPathsLibrary - Paths Ops（UE 5.6）

本 skill 描述 UE 5.6 引擎 `UBlueprintPathsLibrary` 暴露给 Python 的路径查询与规范化方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Classes/Kismet/BlueprintPathsLibrary.h` 中带 `UFUNCTION(BlueprintCallable / BlueprintPure)` 标记的成员整理。

## 入口说明

Python 反射类名为去掉 U 前缀的 `unreal.BlueprintPathsLibrary`，本类全部成员为 static，以类方法形式直接调用，无需实例化：

```python
import unreal
paths = unreal.BlueprintPathsLibrary

print(paths.get_project_file_path())
print(paths.get_project_saved_dir())
```

- 命名约定：Python 方法名优先取 `meta=(ScriptMethod=...)` 值转 snake_case；无则按 C++ 函数名转 snake_case。本类头文件未声明 `ScriptMethod` 元数据，故全部按 C++ 函数名转换。精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。
- Out/ByRef 参数返回约定：`void` + 单 Out 直接返回该值；返回值 + Out 按元组返回（返回值在首位）；无 Out 且无返回值则返回 `None`。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 根与启动 | `should_save_to_user_dir()` | `bool ShouldSaveToUserDir()` | `bool` |
| 根与启动 | `launch_dir()` | `FString LaunchDir()` | `str` |
| 根与启动 | `root_dir()` | `FString RootDir()` | `str` |
| 根与启动 | `get_relative_path_to_root()` | `const FString& GetRelativePathToRoot()` | `str` |
| 引擎目录 | `engine_dir()` | `FString EngineDir()` | `str` |
| 引擎目录 | `engine_user_dir()` | `FString EngineUserDir()` | `str` |
| 引擎目录 | `engine_version_agnostic_user_dir()` | `FString EngineVersionAgnosticUserDir()` | `str` |
| 引擎目录 | `engine_content_dir()` | `FString EngineContentDir()` | `str` |
| 引擎目录 | `engine_config_dir()` | `FString EngineConfigDir()` | `str` |
| 引擎目录 | `engine_intermediate_dir()` | `FString EngineIntermediateDir()` | `str` |
| 引擎目录 | `engine_saved_dir()` | `FString EngineSavedDir()` | `str` |
| 引擎目录 | `engine_plugins_dir()` | `FString EnginePluginsDir()` | `str` |
| 引擎目录 | `engine_source_dir()` | `FString EngineSourceDir()` | `str` |
| 引擎目录 | `enterprise_dir()` | `FString EnterpriseDir()` | `str` |
| 引擎目录 | `enterprise_plugins_dir()` | `FString EnterprisePluginsDir()` | `str` |
| 引擎目录 | `enterprise_feature_pack_dir()` | `FString EnterpriseFeaturePackDir()` | `str` |
| 项目目录 | `project_dir()` | `FString ProjectDir()` | `str` |
| 项目目录 | `project_user_dir()` | `FString ProjectUserDir()` | `str` |
| 项目目录 | `project_content_dir()` | `FString ProjectContentDir()` | `str` |
| 项目目录 | `project_config_dir()` | `FString ProjectConfigDir()` | `str` |
| 项目目录 | `project_saved_dir()` | `FString ProjectSavedDir()` | `str` |
| 项目目录 | `project_intermediate_dir()` | `FString ProjectIntermediateDir()` | `str` |
| 项目目录 | `project_plugins_dir()` | `FString ProjectPluginsDir()` | `str` |
| 项目目录 | `project_mods_dir()` | `FString ProjectModsDir()` | `str` |
| 项目目录 | `project_log_dir()` | `FString ProjectLogDir()` | `str` |
| 项目目录 | `game_source_dir()` | `FString GameSourceDir()` | `str` |
| 项目目录 | `game_agnostic_saved_dir()` | `FString GameAgnosticSavedDir()` | `str` |
| 项目目录 | `game_developers_dir()` | `FString GameDevelopersDir()` | `str` |
| 项目目录 | `game_user_developer_dir()` | `FString GameUserDeveloperDir()` | `str` |
| 项目目录 | `has_project_persistent_download_dir()` | `bool HasProjectPersistentDownloadDir()` | `bool` |
| 项目目录 | `project_persistent_download_dir()` | `FString ProjectPersistentDownloadDir()` | `str` |
| 工具目录 | `shader_working_dir()` | `FString ShaderWorkingDir()` | `str` |
| 工具目录 | `source_config_dir()` | `FString SourceConfigDir()` | `str` |
| 工具目录 | `generated_config_dir()` | `FString GeneratedConfigDir()` | `str` |
| 工具目录 | `sandboxes_dir()` | `FString SandboxesDir()` | `str` |
| 工具目录 | `profiling_dir()` | `FString ProfilingDir()` | `str` |
| 工具目录 | `screen_shot_dir()` | `FString ScreenShotDir()` | `str` |
| 工具目录 | `bug_it_dir()` | `FString BugItDir()` | `str` |
| 工具目录 | `video_capture_dir()` | `FString VideoCaptureDir()` | `str` |
| 工具目录 | `automation_dir()` | `FString AutomationDir()` | `str` |
| 工具目录 | `automation_transient_dir()` | `FString AutomationTransientDir()` | `str` |
| 工具目录 | `automation_log_dir()` | `FString AutomationLogDir()` | `str` |
| 工具目录 | `cloud_dir()` | `FString CloudDir()` | `str` |
| 工具目录 | `diff_dir()` | `FString DiffDir()` | `str` |
| 工具目录 | `feature_pack_dir()` | `FString FeaturePackDir()` | `str` |
| 本地化 | `get_engine_localization_paths()` | `const TArray<FString>& GetEngineLocalizationPaths()` | `Array[str]` |
| 本地化 | `get_editor_localization_paths()` | `const TArray<FString>& GetEditorLocalizationPaths()` | `Array[str]` |
| 本地化 | `get_property_name_localization_paths()` | `const TArray<FString>& GetPropertyNameLocalizationPaths()` | `Array[str]` |
| 本地化 | `get_tool_tip_localization_paths()` | `const TArray<FString>& GetToolTipLocalizationPaths()` | `Array[str]` |
| 本地化 | `get_game_localization_paths()` | `const TArray<FString>& GetGameLocalizationPaths()` | `Array[str]` |
| 限制路径 | `get_restricted_folder_names()` | `const TArray<FString>& GetRestrictedFolderNames()` | `Array[str]` |
| 限制路径 | `is_restricted_path(in_path)` | `bool IsRestrictedPath(const FString& InPath)` | `bool` |
| 工程文件 | `is_project_file_path_set()` | `bool IsProjectFilePathSet()` | `bool` |
| 工程文件 | `get_project_file_path()` | `FString GetProjectFilePath()` | `str` |
| 工程文件 | `set_project_file_path(new_game_project_file_path)` | `void SetProjectFilePath(const FString& NewGameProjectFilePath)` | `None` |
| 文件名 | `get_extension(in_path, b_include_dot=False)` | `FString GetExtension(const FString& InPath, bool bIncludeDot = false)` | `str` |
| 文件名 | `get_clean_filename(in_path)` | `FString GetCleanFilename(const FString& InPath)` | `str` |
| 文件名 | `get_base_filename(in_path, b_remove_path=True)` | `FString GetBaseFilename(const FString& InPath, bool bRemovePath = true)` | `str` |
| 文件名 | `get_path(in_path)` | `FString GetPath(const FString& InPath)` | `str` |
| 文件名 | `change_extension(in_path, in_new_extension)` | `FString ChangeExtension(const FString& InPath, const FString& InNewExtension)` | `str` |
| 文件名 | `set_extension(in_path, in_new_extension)` | `FString SetExtension(const FString& InPath, const FString& InNewExtension)` | `str` |
| 文件名 | `get_invalid_file_system_chars()` | `FString GetInvalidFileSystemChars()` | `str` |
| 文件名 | `make_valid_file_name(in_string, in_replacement_char="")` | `FString MakeValidFileName(const FString& InString, const FString& InReplacementChar = TEXT(""))` | `str` |
| 文件名 | `create_temp_filename(path, prefix="", extension=".tmp")` | `FString CreateTempFilename(const FString& Path, const FString& Prefix = TEXT(""), const FString& Extension = TEXT(".tmp"))` | `str` |
| 存在性 | `file_exists(in_path)` | `bool FileExists(const FString& InPath)` | `bool` |
| 存在性 | `directory_exists(in_path)` | `bool DirectoryExists(const FString& InPath)` | `bool` |
| 存在性 | `is_drive(in_path)` | `bool IsDrive(const FString& InPath)` | `bool` |
| 存在性 | `is_relative(in_path)` | `bool IsRelative(const FString& InPath)` | `bool` |
| 存在性 | `is_same_path(path_a, path_b)` | `bool IsSamePath(const FString& PathA, const FString& PathB)` | `bool` |
| 规范化 | `normalize_filename(in_path)` | `void NormalizeFilename(const FString& InPath, FString& OutPath)` | `str`（单 Out 直接返回） |
| 规范化 | `normalize_directory_name(in_path)` | `void NormalizeDirectoryName(const FString& InPath, FString& OutPath)` | `str` |
| 规范化 | `remove_duplicate_slashes(in_path)` | `void RemoveDuplicateSlashes(const FString& InPath, FString& OutPath)` | `str` |
| 规范化 | `make_standard_filename(in_path)` | `void MakeStandardFilename(const FString& InPath, FString& OutPath)` | `str` |
| 规范化 | `make_platform_filename(in_path)` | `void MakePlatformFilename(const FString& InPath, FString& OutPath)` | `str` |
| 规范化 | `collapse_relative_directories(in_path)` | `bool CollapseRelativeDirectories(const FString& InPath, FString& OutPath)` | `Tuple[bool, str]` |
| 规范化 | `make_path_relative_to(in_path, in_relative_to)` | `bool MakePathRelativeTo(const FString& InPath, const FString& InRelativeTo, FString& OutPath)` | `Tuple[bool, str]` |
| 转换 | `convert_relative_path_to_full(in_path, in_base_path="")` | `FString ConvertRelativePathToFull(const FString& InPath, const FString& InBasePath = TEXT(""))` | `str` |
| 转换 | `convert_to_sandbox_path(in_path, in_sandbox_name)` | `FString ConvertToSandboxPath(const FString& InPath, const FString& InSandboxName)` | `str` |
| 转换 | `convert_from_sandbox_path(in_path, in_sandbox_name)` | `FString ConvertFromSandboxPath(const FString& InPath, const FString& InSandboxName)` | `str` |
| 校验 | `validate_path(in_path)` | `void ValidatePath(const FString& InPath, bool& bDidSucceed, FText& OutReason)` | `Tuple[bool, Text]` |
| 拆分 | `split(in_path)` | `void Split(const FString& InPath, FString& PathPart, FString& FilenamePart, FString& ExtensionPart)` | `Tuple[str, str, str]` |
| 组合 | `combine(in_paths)` | `FString Combine(const TArray<FString>& InPaths)` | `str` |

## 快速示例

```python
import unreal

paths = unreal.BlueprintPathsLibrary

print("project file:", paths.get_project_file_path())
print("saved:", paths.get_project_saved_dir())
print("log:", paths.get_project_log_dir())

base = paths.get_base_filename("D:/Game/Saved/Logs/UE5.log")
full = paths.convert_relative_path_to_full("Content/Maps/Main", "D:/Game")
joined = paths.combine(["D:/Game/Content", "Maps", "Main"])
print(base, full, joined)

standard = paths.make_standard_filename("D:/Game/Content/../Content/A.umap")
print(standard)

exists = paths.file_exists(paths.get_project_file_path())
print("project file exists:", exists)
```

## 注意事项

- 本类查询依赖实际运行环境（编辑器安装与命令行参数、`FApp::GetProjectName()` 是否已设置、打包二进制上下文）；结果以当前引擎与项目实际状态为准，不得与磁盘猜测或硬编码路径混用。
- 缺必要输入（空/非法路径串、文件不存在等）返回 `BLOCKED_INPUT`；运行环境不可用（无法确定项目、不在有效引擎上下文）返回 `BLOCKED_TOOLING`。
- `file_exists` / `directory_exists` / `is_drive` 等反映真实磁盘与挂载状态，只作查询，不构成写入依据；利用所得路径写文件时仍按项目规范审计。
- 本类全部成员为只读查询或纯字符串处理，不修改项目内容。
- 未在真实 UE 5.6 中实测的调用不做"已验证"断言；精确 Python 暴露名需在目标 5.6 编辑器 `dir()` / `help()` 实测确认。

详细 API 与完整示例见 `docs/overview.md`。