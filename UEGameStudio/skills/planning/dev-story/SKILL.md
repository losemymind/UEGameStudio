---
name: dev-story
description: 核心实施技能：读取 story 文件并实现它——加载完整上下文（story、GDD 需求、ADR 指南、control manifest），路由到正确的程序员 agent，实现代码与测试，并逐项确认验收标准。Use when：`/story-readiness` 通过后、`/code-review` 与 `/story-done` 之前。
---

# 实施 Story

> **路径约定**：本技能中的 `src/`、`assets/`、`tests/`、`prototypes/` 等为项目级约定路径，落到 UE 项目时对应 `Source/<GameModule>/`、`Content/`、`Source/**/Tests/`、`Prototypes/`；完整映射见 `references/project-paths.md`。

## 何时使用
- `/story-readiness [story-path]` 通过之后
- `/code-review` 与 `/story-done` 之前
- 每个 story 的循环：`/qa-plan` → `/story-readiness` → `/dev-story`（本技能）→ `/code-review` → `/story-done`

## 流程
### 阶段 1：定位 Story
1. 给了路径就直接读；没给则查 `production/session-state/active.md`，否则 Glob 列出 `Status: Ready` 的 story 询问

### 阶段 2：加载完整上下文
1. **先校验必需文件**：TR 注册表与治理 ADR 缺失 → 置 BLOCKED 并停止；control manifest 缺失 → 警告但继续
2. 并行读取：story 文件、TR 注册表（需求以注册表为准，不依赖 story 内可能过期的文本）、治理 ADR、control manifest、引擎偏好（`docs/technical-preferences.md`）
3. **Manifest 版本比对**：story 内嵌版本与当前 manifest 日期不一致时，AskUserQuestion 让用户选（按新规则实施 / 按旧规则并记录 Manifest-Note / 停止）
4. **依赖校验**：每个依赖 story 的 Status 必须是 Complete/Done，否则询问（继续接受风险 / 停止 / 补标 Complete）
5. 静默更新 `sprint-status.yaml` 与 story 的 `Last Updated` 字段

### 阶段 3：路由到正确的程序员 agent
1. **Config/Data story 跳过 agent 派发**——直接编辑数据文件
2. 主 agent 路由表：

| Story 场景 | 主 agent |
|---|---|
| Foundation 层（任意类型） | `unreal-engine-programmer` |
| 任意层 · UI | `unreal-ui-developer` |
| 任意层 · Visual/Feel | `unreal-gameplay-programmer` |
| Core/Feature · 玩法机制 | `unreal-gameplay-programmer` |
| Core/Feature · AI/寻路 | `unreal-ai-programmer` |
| Core/Feature · 网络/复制 | `unreal-network-programmer` |

3. **引擎专家 agent（代码类 story 作为次级一并派发）**，UE 专家路由表：

| 引擎 | 可用专家 agent |
|---|---|
| Godot 4 | `godot-specialist`, `godot-gdscript-specialist`, `godot-shader-specialist` |
| Unity | `unity-specialist`, `unity-ui-specialist`, `unity-shader-specialist` |
| Unreal Engine | `unreal-engine-programmer`, `unreal-gameplay-programmer`, `unreal-network-programmer` |

4. 引擎风险为 HIGH 时（ADR 或 VERSION.md 标注），即使非引擎面向的 story 也必须派发引擎专家

### 阶段 4：实施
1. 用 Task 派发选定的程序员 agent，brief 只给文件路径与定向阅读指引，不把文档内容塞进 prompt
2. Logic/Integration 必须同实现一起写测试文件（路径来自 story 的 Test Evidence 节），每个验收标准至少一个测试函数，命名 `test_[场景]_[期望结果]`，禁止随机种子/时间依赖断言/外部 I/O
3. Visual/Feel 的验收标准无法自动验证，留待 `/story-done` 人工确认
4. 所有文件写入由子 agent 完成，本编排器不直接写源码

### 阶段 5：测试证据要求
- Logic：单元测试（BLOCKING）；Integration：集成测试或 playtest 记录（BLOCKING）
- Visual/Feel 与 UI：`production/qa/evidence/[slug]-evidence.md` 证据文档（ADVISORY）
- Config/Data：无，冒烟检查即证据

### 阶段 6：收集并汇总
1. 汇总文件变更、测试函数数、越界偏离、阻断项、引擎风险
2. 提醒：跑 `/story-done` 前先在本地跑测试确认通过

### 阶段 7：更新会话状态
追加到 `production/session-state/active.md`

## Story 就绪检查（合并自 story-readiness）

实施前必须通过就绪检查，确保 story 具备进入开发的条件。未通过就绪检查的 story 不得开始实施。

### 就绪检查清单
1. **元数据完整**：标题、ID、Type、Priority、Estimate、Dependencies 均已填写
2. **验收标准存在**：每条验收标准为 Given-When-Then 格式，可独立验证
3. **GDD 引用有效**：引用的 GDD/ADR 文件存在且未过期，设计文档未被标记为 `[DRAFT]` 或 `[QUICK]`
4. **依赖满足**：所有依赖 story 的 Status 为 Complete/Done，或已明确接受风险
5. **测试路径明确**：Logic/Integration story 已指定测试文件路径，Visual/Feel story 已有证据收集计划
6. **TR 注册表对齐**：story 中的需求与 TR 注册表一致，无冲突或过期引用
7. **越界明确**：story 明确标注了 Out of Scope 边界，不与其他 story 有重复覆盖

### 就绪检查输出
- 所有项通过：判定 READY，允许进入 `/dev-story`
- 有 WARNING 项：判定 CONDITIONAL READY，标注风险项后允许进入，但风险项必须在 `/story-done` 前解决
- 有 BLOCKING 项：判定 NOT READY，列出所有阻塞项，story 退回 refinement

## Story 完成检查（合并自 story-done）

实施完成后必须通过完成检查，验证 story 达成 Definition of Done。

### 完成检查清单
1. **代码到位**：所有实现文件已写入，无 `// TODO` 残留（或已记录为技术债）
2. **测试通过**：Logic/Integration story 的测试全部通过（PASS，无非 PASS 的 NOT RUN），Visual/Feel story 有证据文档
3. **验收标准逐项确认**：每条验收标准已逐项验证，结果为 PASS / DEFERRED / FAIL
4. **ADR 合规**：实施符合 ADR 的 Implementation Guidelines，无未标记的偏离
5. **越界无侵入**：未触碰 Out of Scope 之外的文件，或已记录并批准越界偏离
6. **代码审查通过**：`/code-review` 已通过，无 BLOCKING 问题
7. **冒烟检查通过**：`/smoke-check` 中与本 story 相关的检查项均已 PASS
8. **回归套件更新**：新增/修改的回归测试已注册到 `tests/regression-suite.md`
9. **文档更新**：相关设计文档/API 文档已同步更新
10. **状态更新**：story Status 更新为 Done，sprint-status.yaml 已同步

### 完成检查输出
- 所有项通过：判定 DONE，story 关闭
- 有 DEFERRED 项：判定 DONE WITH DEFERRED，记录延期项到下一 sprint 或技术债
- 有 FAIL 项：判定 NOT DONE，列出失败项，story 退回实施

## 输入/输出
- 输入：story 文件、TR 注册表、治理 ADR、control manifest、引擎偏好
- 输出：`src/` 源码 + `tests/` 测试文件 + 会话状态更新

## 约束
- **ADR 是法律**：实施必须遵循 ADR 的 Implementation Guidelines，冲突时不默默偏离，标记到汇总
- **越界是合同**：触碰 Out of Scope 之外的文件必须停下来问
- Logic/Integration 测试非可选
- Visual/Feel 标准是"延后"不是"跳过"，标记为 DEFERRED
- 上下文不完整绝不开始编码
- 未通过 `/story-readiness` 的 story 不得进入实施
- 未通过 `/story-done` 的 story 不得关闭

## 反例（不要这样）
- 未校验 TR 注册表/ADR 存在就直接派发程序员 agent
- 跳过 agent 路由表，把 story 交给错误角色的 agent 实现
- 把完整文档内容序列化进 Task prompt（应让 agent 自己读文件）
- 没有写测试文件就宣布 Logic story 完成
- 遇到 ADR 与 story 冲突时自己猜一个方向实施
- 跳过就绪检查直接开始实施——依赖未满足的 story 会导致返工
- 跳过完成检查直接关闭 story——未验证的 story 会留下隐藏缺陷
- 完成检查时只看代码不看测试结果——未经测试通过等于未完成

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「文档我都看过了，直接塞进 Task prompt 让子 agent 一次到位」 | brief 只给文件路径与定向阅读指引，让 agent 自己读文件；序列化文档会膨胀上下文并埋下过期内容的坑。 |
| 「这个 Logic story 逻辑简单，测试后面再补」 | Logic/Integration 测试是 BLOCKING，非可选；每个验收标准至少一个测试函数，没有测试就不得宣布完成。 |
| 「ADR 和 story 冲突，我挑一个更合理的方向直接实现」 | ADR 是法律，冲突时不默默偏离，必须标记到汇总，让用户裁决。 |
| 「就绪检查太繁琐，直接开始写代码更快」 | 跳过就绪检查会导致依赖未满足、验收标准模糊、设计文档过期，返工成本远高于检查成本。 |
| 「完成检查是形式主义，代码写完就关 story」 | 完成检查是验证门，未测试/未审查/未验证验收标准的 story 关闭后会在后续冲刺复发。 |

## Red Flags（违规信号）
- 编排器自己直接写 src/ 源码文件（应由子 agent 完成写入）。
- story 被派发给路由表之外的角色 agent（如 UI story 给了 unreal-engine-programmer）。
- 未校验 TR 注册表/ADR 存在就派发 agent，或依赖 story 的 Status 非 Complete 仍继续。
- Logic/Integration story 提交时没有任何测试文件。
- 未通过 `/story-readiness` 就绪检查直接进入实施。
- 未通过 `/story-done` 完成检查直接关闭 story。

## Verification（证据化验证门）
- [ ] 每个 Logic/Integration story 都有对应测试文件，函数命名符合 test_[场景]_[期望结果]。
- [ ] 派发的 agent 与主 agent 路由表及引擎专家路由表匹配，可举证。
- [ ] Manifest 版本比对已执行，不一致时已记录用户选择（按新规则/按旧规则记录 Manifest-Note/停止）。
- [ ] ADR 冲突与越界偏离已标记到汇总，并在本地测试确认通过后才提醒跑 /story-done。
- [ ] 就绪检查已通过，所有 BLOCKING 项已解决，WARNING 项已记录风险。
- [ ] 完成检查已通过，验收标准逐项确认，测试全部通过，冒烟/回归/审查均已通过。

## 合并覆盖
- **story-readiness**：Story 就绪检查工作流（元数据完整、验收标准、GDD 引用有效、依赖满足、测试路径明确、TR 注册表对齐、越界明确），输出 READY / CONDITIONAL READY / NOT READY 判定
- **story-done**：Story 完成检查工作流（代码到位、测试通过、验收标准逐项确认、ADR 合规、越界无侵入、代码审查通过、冒烟检查通过、回归套件更新、文档更新、状态更新），输出 DONE / DONE WITH DEFERRED / NOT DONE 判定