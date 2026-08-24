---
name: qa-plan
description: QA 测试计划：读取 GDD 与 story，按 Logic/Integration/Visual/UI/Config 分类每个 story，产出覆盖自动化测试、手动用例、冒烟范围与试玩签字的结构化测试计划。Use when 冲刺开始前或启动一个主要功能前，提前明确所需测试工作。
---

# QA 测试计划

为冲刺、功能或单个 story 生成结构化 QA 计划。读取所有范围内 story 及其引用的 GDD，按测试类型分类，产出告诉开发者"自动化什么、手动验证什么、冒烟范围是什么、何时引入试玩者"的计划。实现完成后才写测试计划是"事后尸检"，不是计划。

## 何时使用
- 冲刺开始前，让团队提前知道所需测试工作
- 启动一个主要功能前
- 需要按 story 类型分配自动化/手动验证

## 流程
### 解析范围
1. `sprint`（读最近冲刺文件；有 sprint-status.yaml 则以其为主）/ `feature:[system]` / `story:[path]` / 无参数则询问。

### 加载输入
1. 逐 story 提取标题、ID、Type、验收标准、实现文件、引擎注释、GDD/ADR 引用、估算、依赖。
2. 一次性加载 systems-index、各 GDD 的 Acceptance Criteria/Formulas/Edge Cases 三节（不读全文）、control-manifest 的禁用模式。

### 分类 story
1. 已有 `Type:` 字段则原样采用（权威，不重分类）；缺失则按验收标准推断：Logic（计算/公式/阈值/状态转移/AI/数据校验）/ Integration（多系统交互/事件跨边界/存档往返/网络/持久化）/ Visual/Feel（动画/VFX/手感/时序/屏幕震动/粒子/音频同步）/ UI（菜单/HUD/按钮/对话框/面板）/ Config/Data（仅平衡数值/数据/配置，无新逻辑）。
2. 混合 story 按最高实现风险定主类型并注明次类型；推断的需标记为缺口。

### 生成测试计划
1. 产出 Test Summary 表、自动化测试要求（测试路径、测什么、边界用例、预估数量）、手动 QA 清单、冒烟范围、试玩要求、本冲刺 Definition of Done。
2. 用真实 story 标题、GDD 公式文本与验收标准，不用占位符。

### 写输出
1. 展示计划后询问写文件与是否回填 story 的 `## QA Test Cases` 节；写后给出后续步骤。

## 测试环境搭建（合并自 test-setup）

在生成测试计划的同时，必须确认测试环境已就绪。未就绪的测试环境会导致计划中的自动化测试无法执行。

### UE 自动化测试框架配置
1. **检查测试模块**：确认 `Source/<GameModule>/Tests/` 目录存在，`.Build.cs` 中已添加 `"AutomationController"` 模块依赖
2. **Session Frontend**：确认 UE Editor 的 Session Frontend (Window > Test Automation) 可正常启动
3. **自动化测试插件**：确认 `Gauntlet`、`FunctionalTestingEditor` 插件已启用
4. **测试地图**：确认 `Content/TestMaps/` 中有专用的测试关卡，避免依赖完整游戏流程
5. **测试配置**：检查 `DefaultEngine.ini` 中 `[AutomationTestFramework]` 配置节

### CI 集成
1. **检查 CI 配置**：确认 `.github/workflows/` 或 CI 配置文件中包含测试步骤
2. **UE 命令行测试**：CI 中应使用 `UnrealEditor-Cmd.exe <Project> -unattended -nopause -NullRHI -TestExit="Automation RunTests <TestGroup>;quit" -ReportOutputPath="Saved/TestReports"`
3. **测试报告解析**：CI 应能解析 `Saved/TestReports/index.json` 中的测试结果
4. **Gauntlet 集成**：对需要完整关卡加载的测试，CI 应配置 Gauntlet 框架
5. **失败通知**：CI 测试失败应自动通知相关人员（Slack/邮件/Issue）

### 环境就绪检查
1. 测试环境未就绪时，将"测试环境搭建"列为计划的第一个行动项
2. 输出环境状态报告：测试目录存在 / CI 配置存在 / 测试框架可用 / 测试地图就绪（每项 YES/NO/MISSING）
3. MISSING 项标记为 BLOCKING 行动项，在计划中明确由谁负责解决

## 测试辅助工具（合并自 test-helpers）

### UE 测试辅助库
1. **GameTestHelpers.h**：通用测试辅助函数库，提供：
   - `FGameTestHelper::SpawnActor<T>()` — 在测试地图中生成 Actor
   - `FGameTestHelper::ApplyGameplayEffect()` — 对目标施加 GE
   - `FGameTestHelper::WaitForAttributeChange()` — 等待属性变化
   - `FGameTestHelper::SimulateInput()` — 模拟输入
   - `FGameTestHelper::WaitForCondition()` — 等待条件满足（带超时）
2. **Latent Actions**：对于需要延迟的测试（如等待动画完成），使用 `FLatentTestHelper` 的 `WaitUntil()` 和 `WaitForTick()`
3. **Test Fixtures**：为常用测试场景预置 Fixture 类（如 `FEquippedWeaponFixture`、`FInCombatFixture`）
4. **Mock 工具**：对网络/存档/UI 等外部依赖，提供 `MockNetworkManager`、`MockSaveSystem` 等 Mock 类

### 测试辅助工具使用规范
1. 测试计划中引用 GameTestHelpers 的宏/函数时，注明具体函数名和使用场景
2. 对需要 Latent Action 的测试，在计划中标注 `[LATENT]`，预估测试时长
3. 对需要 Fixture 的测试，标注所需 Fixture 类名
4. 新增测试辅助函数时，同步更新 `tests/README.md` 中的辅助工具索引

## 输入/输出
- 输入：冲刺/story 文件、GDD 关键节、systems-index、control-manifest
- 输出：QA 计划（`production/qa/qa-plan-[sprint-slug]-[date].md`）+ 环境状态报告 + 可选回填 story 测试用例

## 约束
- 写计划前必须获批准；分类保守（Logic 与 Integration 难分时归 Integration，需单测+集成测试）。
- 不发明超出验收标准与 GDD 公式的测试用例；公式缺失就标记，不猜测。
- 试玩要求是建议性的，由用户决定边界 Visual/Feel story 是否需要试玩。
- 无参数时用 `AskUserQuestion` 选范围，其余阶段保持非交互。
- 测试环境未就绪时，计划第一项必须是环境搭建，标记为 BLOCKING。
- 测试辅助工具引用必须注明具体函数名，不写"使用辅助函数"类模糊引用。

## 反例（不要这样）
- 实现完成后才写测试计划——那是事后记录，不是计划。
- 用占位符文本而非真实 story 标题/公式——测试条目脱离真实需求。
- 臆造不存在的公式去生成测试用例——应标记缺失而非猜测。
- 未经批准就写计划文件。
- 测试环境未就绪却直接生成自动化测试计划——测试无法执行，计划为空谈。
- 测试辅助工具引用模糊（"使用辅助函数"），不指定具体函数名和使用场景。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「实现完了再补一份测试计划就行」 | 实现后写计划是「事后尸检」不是计划，须在冲刺开始前。 |
| 「story 标题用占位符代替没关系」 | 占位符脱离真实需求，测试条目无法核对，必须用真实 story 标题/公式。 |
| 「公式没有我猜一个写进去」 | 不发明超出 GDD 的公式，缺失就标记，不猜测。 |
| 「直接写计划文件」 | 写前必须获批准。 |
| 「测试环境后面再搭，先写计划」 | 环境未就绪时计划第一项必须是环境搭建，否则自动化测试条目无法执行。 |
| 「辅助函数用哪个都行，不用指定」 | 模糊引用会导致实现时选错函数或遗漏依赖，必须注明具体函数名。 |

## Red Flags（违规信号）
- 计划在实现完成后才生成。
- 测试用例含占位符文本或臆造的公式。
- 已有 Type 字段被重分类（应原样采用），或缺失 Type 未标记缺口。
- 未经批准写 qa-plan 文件。
- 自动化测试计划中未包含环境就绪检查结果。
- 测试辅助工具引用模糊，未注明具体函数名。

## Verification（证据化验证门）
- [ ] 范围已解析（sprint/feature/story 或询问）。
- [ ] 逐 story 提取标题/ID/Type/验收标准，Type 权威保留、缺失推断并标记缺口。
- [ ] 计划含 Test Summary、自动化要求、手动清单、冒烟范围、试玩要求、DoD，用真实内容。
- [ ] 经批准才写文件，并询问是否回填 story 的 QA Test Cases 节。
- [ ] 环境状态报告已生成（测试目录/CI 配置/测试框架/测试地图），MISSING 项已标记为 BLOCKING 行动项。
- [ ] 测试辅助工具引用已注明具体函数名（如 `FGameTestHelper::ApplyGameplayEffect`）和使用场景。

## 合并覆盖
- **test-setup**：UE 自动化测试框架配置（测试模块检查、Session Frontend、Gauntlet/FunctionalTestingEditor 插件、测试地图、DefaultEngine.ini 配置）、CI 集成（GitHub Actions 配置、UE 命令行测试参数、测试报告解析、Gauntlet 集成、失败通知）、环境就绪检查（YES/NO/MISSING 状态报告，MISSING 标记为 BLOCKING 行动项）
- **test-helpers**：GameTestHelpers.h 测试辅助库（SpawnActor、ApplyGameplayEffect、WaitForAttributeChange、SimulateInput、WaitForCondition）、Latent Actions（FLatentTestHelper）、Test Fixtures 预置类、Mock 工具（MockNetworkManager、MockSaveSystem）、辅助工具使用规范（标注具体函数名、[LATENT] 标注、Fixture 标注、辅助工具索引维护）