---
name: test-evidence-review
description: 评审测试文件与人工证据文档的质量，超越存在性检查：断言覆盖、边界处理、命名规范、证据完整性，每个 story 产出 ADEQUATE/INCOMPLETE/MISSING verdict。Use when：QA 签核前、测试质量存疑时、里程碑评审。
---

# 测试证据质量评审

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。

## 何时使用
- QA 交接签核前
- 任何测试质量存疑的 story
- 里程碑评审中做逻辑/集成 story 质量审计

## 流程
### 1. 解析参数
- 单 story 路径 / `sprint`（当前 sprint 全部）/ 系统名 / 无参数询问范围

### 2. 加载范围内 story
- 提取：Type（Logic/Integration/Visual·Feel/UI/Config·Data）、Test Evidence 段、slug、系统名、验收标准

### 3. 定位证据文件
- Logic → `tests/unit/`；Integration → `tests/integration/` 或 playtest 记录；Visual/Feel 与 UI → `production/qa/evidence/`；Config/Data → smoke 报告
- 记录找到的路径或缺口

### 4. 评审自动化测试质量（Logic/Integration）
- 断言覆盖：每函数 3+ 断言正常，1–2 标记偏薄，0 断言 → BLOCKING（空测试）
- 边界覆盖：验收标准中的数值/阈值/条件是否被测试覆盖
- 命名质量：`test_[场景]_[预期结果]`，泛化命名标记
- 公式可追溯：公式是否被测试按名引用

### 5. 评审人工证据质量（Visual/Feel/UI）
- 标准关联：证据是否覆盖每条验收标准
- 签核完整性：开发者/设计师或美术主管/QA 主管三签
- 截图/产物完整性：截图路径是否引用且存在、UI 是否有操作走查序列
- 日期覆盖：证据日期早于最后一次大改则标 POTENTIALLY STALE

### 6. 构建评审报告
- 逐 story 判 verdict：ADEQUATE / INCOMPLETE / MISSING；整体取最差
- 区分 BLOCKING（阻止 story-done）与 ADVISORY（发布前应修）

## 输入/输出
- 输入：story 文件 + 测试文件 + 证据文档
- 输出：评审报告（会话内）+ 可选 `production/qa/evidence-review-[日期].md`

## 约束
- 只报告质量问题，不修改测试/证据文件
- ADEQUATE = 足够发布，非完美；避免吹毛求疵
- 严格区分 BLOCKING 与 ADVISORY
- 写报告文件前必须确认（可选）

## 反例（不要这样）
- 只查测试存在与否，不做质量评估（那只是 smoke-check）
- 动手修改测试文件而非报告
- 把偏薄断言吹毛求疵成 BLOCKING
- 未经确认直接写报告文件

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「测试文件都在，就是够了的」 | 存在性只是 smoke-check，必须评审断言覆盖/边界/命名 |
| 「断言偏薄，直接判 BLOCKING 严一点没错」 | 偏薄是 ADVISORY 范畴，吹毛求疵成 BLOCKING 违反约束 |
| 「顺手把测试改对更快」 | 本技能只报告不修改，改动需走正常流程 |

## Red Flags（违规信号）
- 只列测试文件存在与否，无质量结论
- verdict 未区分 ADEQUATE/INCOMPLETE/MISSING 或未区分 BLOCKING/ADVISORY
- 证据日期早于最后一次大改却未标 POTENTIALLY STALE

## Verification（证据化验证门）
- [ ] 每条 story 有 Type 与 verdict（ADEQUATE/INCOMPLETE/MISSING），整体取最差
- [ ] Logic/Integration 已评审断言覆盖、边界覆盖、命名（test_[场景]_[预期结果]）、公式可追溯
- [ ] Visual/Feel/UI 已核对三签、截图路径引用且存在、日期覆盖
- [ ] 0 断言判 BLOCKING，1–2 断言标偏薄而非 BLOCKING
