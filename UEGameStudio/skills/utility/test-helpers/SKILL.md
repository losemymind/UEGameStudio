---
name: test-helpers
description: 生成引擎特定的测试辅助库：读取现有测试模式，产出 tests/helpers/ 下的断言工具、工厂函数与 mock（含 UE GameTestHelpers.h 模板），减少新测试文件的样板代码。Use when 需要为项目测试套件生成领域化辅助库、或开始为新系统写测试时。
---

# 生成引擎测试辅助库

当公共的 setup/teardown/断言模式被抽象成辅助函数后，写测试更快更一致。本技能生成贴合项目实际引擎、语言与系统的 `tests/helpers/` 库，让每个开发者少写样板、多写断言。

## 何时使用
- `/test-setup` 搭好框架后（首次）
- 多个测试文件重复相同的 setup 样板时
- 开始为新系统写测试时

## 流程
### 解析参数
1. 模式：`[system-name]`（单系统）/ `all`（所有有测试的系统）/ `scaffold`（仅基础库）/ 无参数（无辅助库则 scaffold，否则 all）。

### 检测引擎与语言
1. 读取技术偏好提取 `Engine:`、`Language:`、测试框架；未配置则停止并提示 `/setup-engine`。

### 加载现有测试模式
1. Glob `tests/**/*_test.*`，采样至多 5 个文件，提取 setup/断言/对象创建/mock 模式，确保生成的辅助库匹配项目现有风格。
2. 读取 systems-index、相关 GDD、TR 注册表以了解系统与需测试的数据类型。

### 生成引擎特定辅助库
1. Godot（GDScript）：`game_assertions.gd`（范围断言、信号断言、节点存在断言）、`game_factory.gd`、`scene_runner_helper.gd`。
2. Unity（NUnit/C#）：`GameAssertions.cs`（范围/事件/组件断言）、`GameFactory.cs`（GameObject/ScriptableObject 工厂）。
3. Unreal（C++）：`tests/helpers/GameTestHelpers.h` —— 基于 `Misc/AutomationTest.h` 的宏 `GAME_TEST_ASSERT_IN_RANGE` / `GAME_TEST_ASSERT_VALID` / `GAME_TEST_ASSERT_SPAWNED`，以及 `GameTestHelpers::CreateTestWorld()`（记得 teardown 时 `World->DestroyWorld(false)`）。

### 生成系统特定辅助库
1. 对 `[system-name]`/`all`，读该系统 GDD 提取数据类型、公式变量与边界、Edge Cases 常见场景，生成 `[system]_factory.[ext]`（常量/边界应追溯到 GDD 公式，不臆造）。

### 写输出
1. 展示将创建的辅助库，经确认写入 `tests/helpers/`；永不覆盖已有文件（已存在则跳过并提示手动删除再生成）。

## 输入/输出
- 输入：引擎/语言、现有测试模式、systems-index、GDD、TR 注册表
- 输出：`tests/helpers/` 基础辅助库 + 可选系统工厂辅助文件

## 约束
- 永不覆盖已有辅助文件——它们可能含手写定制。
- 生成的代码是起点，工厂函数用 metadata 模式简化，待真实类结构出现后适配。
- 辅助库中的边界与常量应追溯到 GDD 公式，不发明数值。
- 写文件前必须确认。

## 反例（不要这样）
- 覆盖已有 helper 文件——丢掉手写定制逻辑。
- 臆造常量/边界而不追溯 GDD——断言与设计不符，测试失去意义。
- 生成与项目现有测试风格不符的通用模板——不匹配已有 setup/断言习惯。
- 未经确认就写 `tests/` 下的文件。
