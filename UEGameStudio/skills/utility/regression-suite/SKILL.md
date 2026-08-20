---
name: regression-suite
description: 回归套件维护：把测试覆盖映射到 GDD 关键路径、识别已修复但缺回归测试的 bug、检测新功能带来的覆盖漂移，并维护 tests/regression-suite.md。Use when 修复 bug 后确认是否写了回归测试、发布门前、或冲刺收尾检测覆盖漂移时。
---

# 回归套件维护

确保每个 bug 修复都有能"抓到原始 bug"的测试背书，并让回归套件随游戏演化保持最新，同时检测新增功能是否缺少对应回归覆盖。回归套件不是新的测试类别，而是对 `tests/` 中已存在测试的**精选清单**，共同覆盖游戏关键路径与已知失败点。

## 何时使用
- 修复 bug 后（确认写了回归测试或识别缺口）
- 发布门前（Polish 门要求回归套件存在）
- 冲刺收尾检测覆盖漂移

## 流程
### 解析参数
1. 模式：`update`（扫描本冲刺新修复并补充清单）/ `audit`（全量审计 GDD 关键路径覆盖）/ `report`（只读状态报告）/ 无参数（有活跃冲刺则 update，否则询问）。

### 加载上下文
1. 读既有 `tests/regression-suite.md`（总数、更新日期、STALE/QUARANTINED）。
2. Glob 测试文件清单（unit/integration/regression）。
3. `audit` 模式读 systems-index 与各 MVP 系统 GDD 的 Acceptance Criteria / Formulas / Edge Cases；`update` 模式只读当前冲刺已完成的 story。
4. Glob `production/qa/bugs/*.md` 过滤 `Status: Closed/Fixed` 的 bug。

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

## 输入/输出
- 输入：既有回归套件、测试文件清单、GDD 关键路径、已关闭 bug 清单
- 输出：状态报告 + `tests/regression-suite.md` 清单

## 约束
- 未经明确批准，永不从清单中删除已有回归测试——删掉刻意写的测试本身就是回归风险。
- 缺口是建议性而非阻塞（发布门除外）；隔离不是删除——偶发失败测试标记隔离并修复。
- 写清单前必须确认。

## 反例（不要这样）
- 删除清单里已有的回归测试——制造新的回归风险。
- 把"隔离"当成"删除"——偶发失败测试应保留并标记，由 `/test-flakiness` 修复。
- 只修 bug 不补回归测试且不标记缺口——bug 会在未来冲刺静默复发。
- 未经批准就更新清单文件。

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「这条回归测试多余，删掉算了」 | 删掉刻意写的测试本身就是回归风险，未经批准永不删除。 |
| 「偶发失败的测试先删了，干净点」 | 隔离不等于删除，应标记 QUARANTINED 并保留修复。 |
| 「缺口只是建议，不用标」 | 不标记回归缺口会让 bug 在后续冲刺静默复发。 |

## Red Flags（违规信号）
- 清单中已有回归测试被移除。
- QUARANTINED 测试被当作删除而非隔离。
- 已关闭 bug 未给出 HAS/MISSING REGRESSION TEST 判定。

## Verification（证据化验证门）
- [ ] 每个已关闭 bug 均有 HAS/MISSING REGRESSION TEST 判定，缺失者标记缺口。
- [ ] 关键路径映射给出 COVERED/PARTIAL/MISSING/EXEMPT，公式/状态机 MISSING 提升 HIGH PRIORITY。
- [ ] 更新/重写清单前已确认；无删除已有回归测试的改动。
