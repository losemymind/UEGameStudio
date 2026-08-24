---
name: smoke-check
description: 冒烟门：执行自动化测试、核对测试覆盖缺口、批量验证关键路径并产出 PASS/FAIL 报告（含 UE Saved/Logs 自动化日志读取）。Use when 冲刺的 story 已实现、在手动 QA 开始前做移交门禁；失败的冒烟检查意味着构建未达 QA 移交条件。
---

# 冒烟门

这是"实现完成"与"可移交 QA"之间的门禁。它运行自动化测试套件、检查覆盖缺口、与开发者批量验证关键路径，并产出 PASS/FAIL 报告。规则很简单：**冒烟检查失败的构建不得进入 QA**。

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。
> 读取该 reference 前必须解析当前 UEGameStudio/OpenCode 配置根；它不是项目 cwd。找不到包根时 fail-closed，项目 `docs/` 仍按项目根解析。

## 何时使用
- 冲刺 story 实现完成后、手动 QA 开始前（QA 移交门禁）
- 修复某个具体失败后需要快速复检（`quick` 模式）
- 需要按平台（pc/console/mobile/all）做差异化冒烟
- 发布前需要进行长时间浸泡测试确认稳定性（`soak` 模式）

## 流程
### 检测测试环境
1. 检查 UE 测试模块/目录是否存在；不存在则停止并提示运行 `qa-plan setup`（legacy alias `test-setup`）。
2. 检查 `.github/workflows/` 是否配置了 CI 测试工作流。
3. 从 `docs/technical-preferences.md` 提取引擎，用于选择测试命令。
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
2. 逐 story 判定 COVERED / MANUAL / MISSING / EXPECTED / UNKNOWN；MISSING 为建议性缺口，不导致 FAIL 但需在 `dev-story done` 前解决。

### 运行手动冒烟检查
1. 从 QA 计划 Smoke Test Scope / smoke-tests.md / tests/smoke/ / 标准回退清单取检查项。
2. 分批请求用户核验（最多 3 次）：Batch 1 核心稳定性、Batch 2 冲刺变更与回归、Batch 3 数据完整性与性能（`quick` 跳过）；有 `--platform` 时追加平台批次。

### 生成报告
1. 汇总自动化测试、覆盖、手动冒烟、缺失证据、平台结果、结论（PASS / PASS WITH WARNINGS / FAIL）。
2. 判定规则：任一自动化失败或 Batch 1/2 失败 → FAIL；测试 PASS 或 NOT RUN 且无手动失败但有 MISSING 证据 → PASS WITH WARNINGS；全部通过且无缺失 → PASS。

### 写入并设门
1. 经确认写入 `production/qa/smoke-[date].md`；按结论给出 QA 移交或修复重跑指引。

## 浸泡测试（合并自 soak-test）

浸泡测试是冒烟检查的扩展模式（`soak` 模式），用于发布前确认游戏的长期稳定性。它不是冒烟检查的替代，而是补充——冒烟通过后再进行浸泡。

### 浸泡测试时机
- 发布门前的最后一个质量门（Polish 门之后、Launch 门之前）
- 修复了内存相关的重大 bug 后
- 新增了持续运行的系统（如在线服务、AI 子系统）后

### 浸泡测试流程
1. **配置浸泡参数**：读取 `production/qa/soak-config.md` 或使用默认值（运行时长 4 小时、目标 FPS ≥30、内存增长 ≤50MB/小时）
2. **启动长时间运行**：使用 UE 命令行启动游戏并附加监控：
   - `stat memory` — 每 30 分钟记录一次内存使用量（Physical/ Virtual）
   - `stat fps` — 记录 FPS 趋势，检测持续下降
   - `stat unit` — 记录 GameThread/RenderThread/GPU 耗时趋势
   - `obj list class=MyActor` — 每 30 分钟检查 Actor 数量，检测泄漏（数量持续增长即泄漏信号）
3. **内存泄漏检测**：
   - 物理内存持续增长（非波动性增长）超过阈值 → 判定 MEMORY LEAK
   - Actor 数量单向增长（非销毁-重建模式）→ 判定 OBJECT LEAK
   - 使用 `memreport -full` 生成详细内存报告，对比浸泡前后的内存快照
4. **性能退化检测**：
   - FPS 中位数在浸泡后半段比前半段下降 >15% → 判定 PERFORMANCE DEGRADATION
   - GameThread/RenderThread 耗时持续增长 → 判定 TICK OVERHEAD
5. **崩溃/卡死检测**：浸泡期间发生崩溃或超过 30 秒无响应 → 判定 STABILITY FAILURE
6. **输出浸泡报告**：内存趋势图（文本描述）、FPS 趋势、Actor 数量趋势、泄漏分析、结论

### 浸泡测试判定
- 全部通过：SOAK PASS，构建可进入发布流程
- 有 MEMORY LEAK / OBJECT LEAK / PERFORMANCE DEGRADATION：SOAK FAIL，阻塞发布
- 有波动但未超阈值：SOAK PASS WITH WARNINGS，记录监控项供上线后持续观察

### 浸泡测试约束
- 浸泡测试不得替代冒烟检查——先冒烟通过再浸泡
- 浸泡时长不可低于 4 小时，缩短时长的浸泡测试不可用于发布门
- 浸泡测试建议在专用硬件上运行，避免与其他任务竞争资源
- stat memory 监控必须记录 Physical 和 Virtual 两个指标，只用 Physical 可能漏掉虚拟内存泄漏

## 输入/输出
- 输入：测试目录/CI 配置、引擎、QA 计划、冲刺 story、手动核验结果、浸泡配置
- 输出：冒烟报告（`production/qa/smoke-[date].md`）与 PASS/PASS WITH WARNINGS/FAIL 门结论；浸泡模式额外输出 `production/qa/soak-[date].md`

## 约束
- 永不把 NOT RUN 自动判为 FAIL——记录为 NOT RUN，由开发者手动确认，未确认的 NOT RUN 计入 PASS WITH WARNINGS。
- 永不自动修复失败——只报告并说明需解决什么，不编辑源码/测试文件。
- PASS WITH WARNINGS 不阻塞 QA 移交，只记录建议性缺口供 `dev-story done` 跟进。
- 所有手动核验须请求用户输入；写报告前必须获得批准。
- 浸泡测试不得替代冒烟检查，必须先冒烟通过再浸泡。
- 浸泡时长不可低于 4 小时，stat memory 必须记录 Physical 和 Virtual 两个指标。

## 反例（不要这样）
- 把"测试无法运行"直接判 FAIL——应记为 NOT RUN 并请开发者确认，避免冤枉构建。
- 自动去改代码或测试文件来"修"失败——越权且掩盖真实问题。
- 忽略 MISSING 测试证据——它虽不 FAIL，但必须在 story 关闭前补上。
- 未经批准就写报告文件——违反协作协议。
- 跳过冒烟直接跑浸泡测试——浸泡不能替代冒烟，先确认基础稳定性再测长期稳定性。
- 浸泡测试只跑 30 分钟就出结论——4 小时是最低要求，缩短时间的内存泄漏检测不可靠。
- stat memory 只看 Physical 不看 Virtual——虚拟内存泄漏同样是严重问题。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「测试跑不起来，直接判 FAIL 就行」 | 约束「NOT RUN 不自动判 FAIL」，应记 NOT RUN 请开发者确认，避免冤枉构建。 |
| 「失败我顺手改一行就修好了」 | 约束「永不自动修复失败」，越权且掩盖真实问题。 |
| 「MISSING 只是建议，忽略没关系」 | 反例「忽略 MISSING」，须在 story 关闭前补上。 |
| 「报告我直接写了」 | 约束「写报告前必须获得批准」。 |
| 「冒烟太慢，直接跑浸泡，一次搞定」 | 浸泡测试不能替代冒烟检查，先冒烟通过确认基础稳定性，再测长期稳定性。 |
| 「跑 30 分钟够用了，4 小时太浪费时间」 | 4 小时是最低要求，缩短时间的内存泄漏检测不可靠，可能漏掉缓慢泄漏。 |
| 「内存只看 Physical 就行，Virtual 不重要」 | 虚拟内存泄漏同样是严重问题，只监控 Physical 会漏掉 VMMap 层面的泄漏。 |

## Red Flags（违规信号）
- 把 NOT RUN 自动判为 FAIL。
- 编辑源码/测试文件来修复失败。
- 手动核验没有用户请求与答复记录。
- 未经批准写入 smoke-[date].md。
- 跳过冒烟直接跑浸泡测试。
- 浸泡测试时长不足 4 小时。
- stat memory 监控只记录 Physical 不记录 Virtual。

## Verification（证据化验证门）
- [ ] 自动化测试结果含总数/通过/失败/失败测试名；NOT RUN 未被判 FAIL。
- [ ] 覆盖逐 story 有 COVERED/MANUAL/MISSING/EXPECTED/UNKNOWN 判定，MISSING 已记录供 dev-story done 跟进。
- [ ] 手动核验分批请求用户（≤3 次），结果有记录。
- [ ] 结论（PASS/PASS WITH WARNINGS/FAIL）符合判定规则，报告经批准后写入。
- [ ] 浸泡测试（如执行）已运行 ≥4 小时，memreport 快照已对比，stat memory 含 Physical 和 Virtual。
- [ ] 浸泡报告含内存趋势、FPS 趋势、Actor 数量趋势、泄漏分析、SOAK PASS/FAIL 结论。

## 合并覆盖
- **soak-test**：浸泡测试模式（`soak` 模式，发布门前最后的质量门），流程（配置浸泡参数——4 小时/目标 FPS≥30/内存增长≤50MB/小时、stat memory 每 30 分钟记录 Physical/Virtual、stat fps 趋势检测、stat unit 耗时趋势、obj list 检查 Actor 数量泄漏、memreport -full 内存快照对比），内存泄漏检测（物理内存持续增长/MEMORY LEAK、Actor 单向增长/OBJECT LEAK），性能退化检测（FPS 中位数下降 >15%/PERFORMANCE DEGRADATION），判定 SOAK PASS/SOAK FAIL/SOAK PASS WITH WARNINGS，约束（不可替代冒烟、≥4 小时、Physical+Virtual 双指标）
