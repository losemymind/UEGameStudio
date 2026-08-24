---
name: regression-suite
description: 回归套件维护：把测试覆盖映射到 GDD 关键路径、识别已修复但缺回归测试的 bug、检测新功能带来的覆盖漂移，并维护 tests/regression-suite.md。Use when 修复 bug 后确认是否写了回归测试、发布门前、或冲刺收尾检测覆盖漂移时。
---

# 回归套件维护

确保每个 bug 修复都有能"抓到原始 bug"的测试背书，并让回归套件随游戏演化保持最新，同时检测新增功能是否缺少对应回归覆盖。回归套件不是新的测试类别，而是对 `tests/` 中已存在测试的**精选清单**，共同覆盖游戏关键路径与已知失败点。

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。

## 何时使用
- 修复 bug 后（确认写了回归测试或识别缺口）
- 发布门前（Polish 门要求回归套件存在）
- 冲刺收尾检测覆盖漂移
- 审查测试证据（截图/日志）确认测试结果真实性
- 处理偶发失败的测试，决定隔离或修复

## 流程
### 解析参数
1. 模式：`update`（扫描本冲刺新修复并补充清单）/ `audit`（全量审计 GDD 关键路径覆盖）/ `report`（只读状态报告）/ `evidence`（审查测试证据）/ `flakiness`（处理偶发失败测试）/ 无参数（有活跃冲刺则 update，否则询问）。

### 加载上下文
1. 读既有 `tests/regression-suite.md`（总数、更新日期、STALE/QUARANTINED）。
2. Glob 测试文件清单（unit/integration/regression）。
3. `audit` 模式读 systems-index 与各 MVP 系统 GDD 的 Acceptance Criteria / Formulas / Edge Cases；`update` 模式只读当前冲刺已完成的 story。
4. Glob `production/qa/bugs/*.md` 过滤 `Status: Closed/Fixed` 的 bug。
5. `evidence` 模式 Glob `production/qa/evidence/` 下证据文档与截图。

### 映射覆盖——关键路径
1. 对每个 GDD 验收标准判定 COVERED / PARTIAL / MISSING / EXEMPT；公式或状态机相关的 MISSING 提升为 HIGH PRIORITY。

### 映射覆盖——已修复 bug
1. 对每个已关闭 bug 判定 HAS REGRESSION TEST / MISSING REGRESSION TEST；缺失者标记为回归缺口并给出建议测试路径。

### 检测覆盖漂移
1. 检查本冲刺完成但无测试文件的 story、systems-index 新增系统、GDD 修订、套件最后更新距现在超过 2 个冲刺等信号。

### 生成报告与套件清单
1. 对话中输出状态报告（关键路径覆盖、bug 回归覆盖、漂移指标、建议新增测试）。
2. 维护 `tests/regression-suite.md`：注册测试表、已知缺口、隔离（QUARANTINED）测试表。

### 写输出
1. 经确认写入/更新清单；`update` 追加、`audit` 重写、`report` 不写。

## 测试证据审查（合并自 test-evidence-review）

对 Visual/Feel 和 UI 类 story，测试结果无法通过自动化断言验证，需要审查测试证据来确认测试的真实性。

### 证据审查流程
1. **收集证据**：Glob `production/qa/evidence/` 下所有证据文档（`[slug]-evidence.md`）、截图（`*.png`）、录屏（`*.mp4`）、日志（`*.log`）
2. **逐项核对**：
   - **截图对比**：对比 before/after 截图，确认视觉效果符合预期，UI 元素位置/大小/颜色正确，无渲染异常
   - **日志验证**：读取 UE `Saved/Logs/` 中相关日志，确认无 Error/Warning 级别的新增异常，关键事件日志存在且时序正确
   - **证据文档交叉验证**：证据文档中声称的 PASS 项是否与实际截图/日志一致
3. **判定**：证据充分且一致 → VERIFIED；证据不足 → INSUFFICIENT EVIDENCE；证据矛盾 → EVIDENCE MISMATCH
4. **记录**：审查结果写入对应 story 的 Test Evidence 节，注明审查日期和审查人

### 证据审查约束
- 截图必须包含完整的 UI 上下文（不能只截一个按钮），需能识别所属屏幕
- 日志验证必须覆盖关键事件（如属性变化、状态转移、网络事件），不只看 Error 级别
- 证据文档中声称 PASS 但无对应截图/日志佐证的 → 判定 INSUFFICIENT EVIDENCE

## 测试偶发失败处理（合并自 test-flakiness）

偶发失败的测试会侵蚀团队对回归套件的信任。必须对偶发失败进行识别、隔离和修复。

### 偶发失败识别
1. **检测信号**：同一测试在连续 3 次运行中出现 ≥1 次 PASS 和 ≥1 次 FAIL → 标记为疑似偶发
2. **根因分类**：时序依赖（等待时间不足）/ 随机种子（未固定种子导致结果不可复现）/ 状态污染（测试间共享状态未清理）/ 外部依赖（网络/文件系统/硬件）/ 资源竞争（多线程/异步操作）
3. **频率统计**：记录偶发测试的失败率（失败次数/总运行次数），用于优先级排序

### 隔离（Quarantine）策略
1. 确认偶发的测试 → 从主回归套件中移除常规执行，移入 QUARANTINED 表
2. 在 `tests/regression-suite.md` 的 QUARANTINED 表中记录：测试路径、失败率、根因分类、隔离日期、预计修复日期
3. 隔离不是删除，偶发测试保留在代码库中，在独立环境中继续运行以收集数据

### 修复策略
1. **时序依赖**：增加等待超时或使用 `WaitForCondition` 替代固定 `Delay`
2. **随机种子**：测试开头固定随机种子（`FMath::SRandInit(42)`）
3. **状态污染**：在 `SetUp()`/`TearDown()` 中完全重置状态，使用 Fixture 的 `Reset()` 方法
4. **外部依赖**：替换为 Mock 对象
5. **资源竞争**：添加同步原语（`FCriticalSection`/`FEvent`）或使用单线程测试模式

### 修复后回流
1. 修复后在隔离环境中连续运行 10 次，全部 PASS → 移回主回归套件
2. 仍偶发 → 修改根因分类，继续隔离，提高优先级
3. 连续 30 天未修复且失败率 >50% → 标记为 STALE，评估是否需要重写测试

### 偶发失败约束
- 隔离不等于删除，QUARANTINED 测试必须保留在代码库中
- 修复偶发测试时不得降低断言强度来"通过"——修复根因而非弱化测试
- 隔离测试的修复优先级按失败率 × 覆盖重要性排序

## 输入/输出
- 输入：既有回归套件、测试文件清单、GDD 关键路径、已关闭 bug 清单、证据文档、测试运行日志
- 输出：状态报告 + `tests/regression-suite.md` 清单 + 证据审查结果 + 偶发失败隔离/修复记录

## 约束
- 未经明确批准，永不从清单中删除已有回归测试——删掉刻意写的测试本身就是回归风险。
- 缺口是建议性而非阻塞（发布门除外）；隔离不是删除——偶发失败测试标记隔离并修复。
- 写清单前必须确认。
- 截图证据必须包含完整 UI 上下文，不能只截局部。
- 修复偶发测试时不得降低断言强度，必须修复根因。

## 反例（不要这样）
- 删除清单里已有的回归测试——制造新的回归风险。
- 把"隔离"当成"删除"——偶发失败测试应保留并标记，由 `/test-flakiness` 修复。
- 只修 bug 不补回归测试且不标记缺口——bug 会在未来冲刺静默复发。
- 未经批准就更新清单文件。
- 证据审查时只看截图不检查日志，或日志只查 Error 级别忽略关键事件。
- 证据文档声称 PASS 但无佐证材料仍判 VERIFIED。
- 修复偶发失败时弱化断言（如将 `assertEqual(x, 5)` 改为 `assertTrue(x > 0)`）来"通过"测试。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「这条回归测试多余，删掉算了」 | 删掉刻意写的测试本身就是回归风险，未经批准永不删除。 |
| 「偶发失败的测试先删了，干净点」 | 隔离不等于删除，应标记 QUARANTINED 并保留修复。 |
| 「缺口只是建议，不用标」 | 不标记回归缺口会让 bug 在后续冲刺静默复发。 |
| 「截图证据看一眼就行，日志不用查」 | 截图只能验证视觉，日志验证关键事件（属性变化/状态转移/网络事件）是确认功能正确性的必要步骤。 |
| 「这个偶发测试降低点断言标准就能过」 | 修复偶发测试必须修复根因，弱化断言是掩盖问题而非解决问题。 |

## Red Flags（违规信号）
- 清单中已有回归测试被移除。
- QUARANTINED 测试被当作删除而非隔离。
- 已关闭 bug 未给出 HAS/MISSING REGRESSION TEST 判定。
- 证据审查时未核对日志关键事件，只看了截图。
- 证据文档声称 PASS 但无截图/日志佐证，仍判 VERIFIED。
- 偶发测试修复时断言强度被降低（如精确值断言变为范围断言）。

## Verification（证据化验证门）
- [ ] 每个已关闭 bug 均有 HAS/MISSING REGRESSION TEST 判定，缺失者标记缺口。
- [ ] 关键路径映射给出 COVERED/PARTIAL/MISSING/EXEMPT，公式/状态机 MISSING 提升 HIGH PRIORITY。
- [ ] 更新/重写清单前已确认；无删除已有回归测试的改动。
- [ ] 证据审查已逐项核对截图/日志/证据文档，判定 VERIFIED/INSUFFICIENT EVIDENCE/EVIDENCE MISMATCH 有据可查。
- [ ] 偶发失败测试已记录失败率、根因分类、隔离日期，QUARANTINED 表完整。
- [ ] 修复后回流测试已连续 10 次 PASS，断言强度未降低。

## 合并覆盖
- **test-evidence-review**：测试证据审查工作流（截图对比——before/after 视觉效果、日志验证——UE Saved/Logs Error/Warning 检查与关键事件时序、证据文档交叉验证——PASS 声称与截图/日志一致性），判定 VERIFIED/INSUFFICIENT EVIDENCE/EVIDENCE MISMATCH，约束（截图必须含完整 UI 上下文、日志验证覆盖关键事件、无佐证材料不得判 VERIFIED）
- **test-flakiness**：偶发失败处理（识别——连续 3 次 ≥1 PASS + ≥1 FAIL 标记疑似偶发、根因分类——时序依赖/随机种子/状态污染/外部依赖/资源竞争），隔离策略（移入 QUARANTINED 表、记录失败率/根因/隔离日期），修复策略（按根因分类对应修复方案、固定随机种子、Mock 外部依赖、同步原语），修复后回流（连续 10 次 PASS 移回主套件），约束（隔离≠删除、修复不得降低断言强度）