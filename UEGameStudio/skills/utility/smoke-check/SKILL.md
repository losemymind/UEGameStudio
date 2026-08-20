---
name: smoke-check
description: 冒烟门：执行自动化测试、核对测试覆盖缺口、批量验证关键路径并产出 PASS/FAIL 报告（含 UE Saved/Logs 自动化日志读取）。Use when 冲刺的 story 已实现、在手动 QA 开始前做移交门禁；失败的冒烟检查意味着构建未达 QA 移交条件。
---

# 冒烟门

这是"实现完成"与"可移交 QA"之间的门禁。它运行自动化测试套件、检查覆盖缺口、与开发者批量验证关键路径，并产出 PASS/FAIL 报告。规则很简单：**冒烟检查失败的构建不得进入 QA**。

## 何时使用
- 冲刺 story 实现完成后、手动 QA 开始前（QA 移交门禁）
- 修复某个具体失败后需要快速复检（`quick` 模式）
- 需要按平台（pc/console/mobile/all）做差异化冒烟

## 流程
### 检测测试环境
1. 检查 `tests/` 目录是否存在（不存在则停止并提示运行 `/test-setup`）。
2. 检查 `.github/workflows/` 是否配置了 CI 测试工作流。
3. 从 `.claude/docs/technical-preferences.md` 提取引擎，用于选择测试命令。
4. 检查 `production/qa/smoke-tests.md` 或 `tests/smoke/` 是否存在；检查最近的 QA 计划。

### 运行自动化测试
1. 按引擎选择命令：
   - Godot 4：`godot --headless --script tests/gdunit4_runner.gd`（或 GdUnitRunner.gd 路径）。
   - Unity：编辑器内运行，读取最近的 `test-results/` XML/JSON 结果。
   - Unreal：读取最近的 `Saved/Logs/` 中 test/automation 相关日志（`Get-ChildItem Saved/Logs/ | Where-Object { $_.Name -match 'test|automation' }`），解析 PASS/FAIL。
   - 未知/未配置引擎：停止并提示 `/setup-engine`。
2. 提取总数/通过/失败/失败测试名/崩溃输出；引擎二进制不在 PATH 时记录为 NOT RUN（不自动判 FAIL，需开发者手动确认）。

### 检查测试覆盖
1. 从 QA 计划或冲刺计划取 story 列表；`quick` 模式跳过此阶段。
2. 逐 story 判定 COVERED / MANUAL / MISSING / EXPECTED / UNKNOWN；MISSING 为建议性缺口，不导致 FAIL 但需在 `/story-done` 前解决。

### 运行手动冒烟检查
1. 从 QA 计划 Smoke Test Scope / smoke-tests.md / tests/smoke/ / 标准回退清单取检查项。
2. 用 `AskUserQuestion` 分批核验（最多 3 次）：Batch 1 核心稳定性、Batch 2 冲刺变更与回归、Batch 3 数据完整性与性能（`quick` 跳过）；有 `--platform` 时追加平台批次（PC/主机/移动）。

### 生成报告
1. 汇总自动化测试、覆盖、手动冒烟、缺失证据、平台结果、结论（PASS / PASS WITH WARNINGS / FAIL）。
2. 判定规则：任一自动化失败或 Batch 1/2 失败 → FAIL；测试 PASS 或 NOT RUN 且无手动失败但有 MISSING 证据 → PASS WITH WARNINGS；全部通过且无缺失 → PASS。

### 写入并设门
1. 经确认写入 `production/qa/smoke-[date].md`；按结论给出 QA 移交或修复重跑指引。

## 输入/输出
- 输入：测试目录/CI 配置、引擎、QA 计划、冲刺 story、手动核验结果
- 输出：冒烟报告（`production/qa/smoke-[date].md`）与 PASS/PASS WITH WARNINGS/FAIL 门结论

## 约束
- 永不把 NOT RUN 自动判为 FAIL——记录为 NOT RUN，由开发者手动确认，未确认的 NOT RUN 计入 PASS WITH WARNINGS。
- 永不自动修复失败——只报告并说明需解决什么，不编辑源码/测试文件。
- PASS WITH WARNINGS 不阻塞 QA 移交，只记录建议性缺口供 `/story-done` 跟进。
- 所有手动核验用 `AskUserQuestion`；写报告前必须获得批准。

## 反例（不要这样）
- 把"测试无法运行"直接判 FAIL——应记为 NOT RUN 并请开发者确认，避免冤枉构建。
- 自动去改代码或测试文件来"修"失败——越权且掩盖真实问题。
- 忽略 MISSING 测试证据——它虽不 FAIL，但必须在 story 关闭前补上。
- 未经批准就写报告文件——违反协作协议。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「测试跑不起来，直接判 FAIL 就行」 | 约束「NOT RUN 不自动判 FAIL」，应记 NOT RUN 请开发者确认，避免冤枉构建。 |
| 「失败我顺手改一行就修好了」 | 约束「永不自动修复失败」，越权且掩盖真实问题。 |
| 「MISSING 只是建议，忽略没关系」 | 反例「忽略 MISSING」，须在 story 关闭前补上。 |
| 「报告我直接写了」 | 约束「写报告前必须获得批准」。 |

## Red Flags（违规信号）
- 把 NOT RUN 自动判为 FAIL。
- 编辑源码/测试文件来修复失败。
- 手动核验未用 AskUserQuestion。
- 未经批准写入 smoke-[date].md。

## Verification（证据化验证门）
- [ ] 自动化测试结果含总数/通过/失败/失败测试名；NOT RUN 未被判 FAIL。
- [ ] 覆盖逐 story 有 COVERED/MANUAL/MISSING/EXPECTED/UNKNOWN 判定，MISSING 已记录供 /story-done 跟进。
- [ ] 手动核验用 AskUserQuestion 分批（≤3 次），结果有记录。
- [ ] 结论（PASS/PASS WITH WARNINGS/FAIL）符合判定规则，报告经批准后写入。
