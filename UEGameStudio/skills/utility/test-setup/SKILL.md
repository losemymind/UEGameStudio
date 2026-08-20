---
name: test-setup
description: 测试框架 + CI 脚手架：按引擎生成 tests/ 目录结构、测试运行器配置与 GitHub Actions 工作流（含 UE Automation 测试、headless `UnrealEditor -nullrhi -ExecCmds="Automation RunTests"` 与 self-hosted runner 安装 UE Editor）。Use when 在 Technical Setup 阶段、第一个冲刺开始前一次性搭建测试基础设施。
---

# 测试框架 + CI 脚手架

检测已配置引擎，生成对应测试运行器配置，创建标准目录布局，并接通 CI/CD 让每次 push 都跑测试。冲刺开始时装测试框架花 30 分钟；第四个冲刺才装要花 3 个冲刺。

## 何时使用
- Technical Setup 阶段、任何实现开始前一次性搭建测试基础设施
- 需要生成 tests/ 目录与 `.github/workflows/tests.yml`
- 需要补齐缺失的测试文件（`force` 模式跳过"已存在"早退但不覆盖）

## 流程
### 检测引擎与现有状态
1. 读取技术偏好提取 `Engine:`；未配置则停止并提示 `/setup-engine`。
2. 检查 `tests/`、`tests/unit/`、`tests/integration/`、`.github/workflows/` 及引擎特定产物（`Source/Tests/` 等）是否已存在。
3. 若都已存在且未传 `force`，提示可 `force` 重新生成（仍不覆盖已有文件）。

### 展示计划
1. 展示将创建的目录（unit/integration/smoke/evidence/README）与 CI 工作流，经批准后执行。

### 创建目录结构
1. 写 `tests/README.md`（目录布局、运行命令、命名规范、Story 类型→测试证据映射、CI 说明）。
2. 引擎特定文件：
   - Godot：`tests/gdunit4_runner.gd` + 占位文件 + GdUnit4 安装说明。
   - Unity：`tests/EditMode/README.md`、`tests/PlayMode/README.md` + Test Framework 启用说明。
   - Unreal：`Source/Tests/README.md`，说明用 UE Automation Testing Framework，类名 `F[SystemName]Test`、分类 `"MyGame.[System].[Feature]"`，运行方式为 Session Frontend → Automation 或 headless：`UnrealEditor -nullrhi -ExecCmds="Automation RunTests MyGame.; Quit"`。

### 创建 CI/CD 工作流
1. Godot：gdUnit4-action；Unity：game-ci/unity-test-runner（需 `UNITY_LICENSE` secret）；Unreal：`runs-on: self-hosted`（本地 runner 需装 Unreal Editor，设 `UE_EDITOR_PATH`），运行 `UnrealEditor [Project].uproject -nullrhi -nosound -ExecCmds="Automation RunTests MyGame.; Quit" -log -unattended`，上传 `Saved/Logs/`。

### 创建冒烟测试种子
1. 写 `tests/smoke/critical-paths.md`（核心稳定性、核心机制、数据完整性、性能检查项）。

### 收尾摘要
1. 报告创建的文件与后续步骤；门控要求 tests/ 目录、CI 工作流、至少一个示例测试文件。

## 输入/输出
- 输入：已配置引擎、现有测试/CI 状态
- 输出：`tests/` 目录结构、引擎特定运行器/README、`.github/workflows/tests.yml`、冒烟种子

## 约束
- 永不覆盖已有测试文件，只创建缺失的。
- 创建文件前必须获批准；引擎检测不可协商——未配置就停止，不猜测。
- `force` 跳过"已存在"早退，但仍不覆盖。
- Unity CI 的 `UNITY_LICENSE` secret 需手动配置，不自动化许可证管理。

## 反例（不要这样）
- 覆盖已有测试文件——可能覆盖手写的自定义测试。
- 引擎未配置就猜测引擎——会生成错误的运行器与 CI 命令。
- 跳过 CI 工作流只建目录——测试不会在 push 时自动跑。
- 忘了 Unreal 的 headless 命令细节（`-nullrhi`/`-ExecCmds`/self-hosted runner 装 UE Editor）——UE 无法在标准 ubuntu runner 上跑编辑器测试。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「那个测试文件内容不对，我直接覆盖重写」 | 约束「永不覆盖已有测试文件，只创建缺失的」，可能覆盖手写定制。 |
| 「没配引擎我先按最流行的猜一个生成」 | 约束「引擎检测不可协商，未配置就停止，不猜测」。 |
| 「只建目录就行，CI 工作流后面再补」 | 反例「跳过 CI 只建目录」，测试不会在 push 自动跑，门控不通过。 |
| 「Unreal headless 命令我凭印象写」 | 反例点明必须记准 -nullrhi/-ExecCmds/self-hosted runner 装 UE Editor，否则 UE 无法在 ubuntu runner 跑。 |

## Red Flags（违规信号）
- 覆盖/改写任何已存在的测试文件或工作流。
- 引擎未配置时猜测引擎并生成运行器与 CI 命令。
- 未建 CI 工作流（.github/workflows/tests.yml）只建目录。
- 创建文件前未获批准。

## Verification（证据化验证门）
- [ ] 引擎取自技术偏好的 Engine: 字段，未配置时停止并有 /setup-engine 提示。
- [ ] 生成的 Unreal 命令含 -nullrhi、-ExecCmds 与 self-hosted runner 说明（UE_EDITOR_PATH）。
- [ ] tests/ 目录含 unit/integration/smoke/evidence/README，门控要求（tests/ 目录、CI 工作流、至少一个示例测试文件）满足。
- [ ] 已有文件均未改动（无覆盖动作），创建前有批准记录。
