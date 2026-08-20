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
| Foundation 层（任意类型） | `engine-programmer` |
| 任意层 · UI | `ui-programmer` |
| 任意层 · Visual/Feel | `gameplay-programmer` |
| Core/Feature · 玩法机制 | `gameplay-programmer` |
| Core/Feature · AI/寻路 | `ai-programmer` |
| Core/Feature · 网络/复制 | `network-programmer` |

3. **引擎专家 agent（代码类 story 作为次级一并派发）**，UE 专家路由表：

| 引擎 | 可用专家 agent |
|---|---|
| Godot 4 | `godot-specialist`, `godot-gdscript-specialist`, `godot-shader-specialist` |
| Unity | `unity-specialist`, `unity-ui-specialist`, `unity-shader-specialist` |
| Unreal Engine | `unreal-specialist`, `ue-gas-specialist`, `ue-blueprint-specialist`, `ue-umg-specialist`, `ue-replication-specialist` |

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

## 输入/输出
- 输入：story 文件、TR 注册表、治理 ADR、control manifest、引擎偏好
- 输出：`src/` 源码 + `tests/` 测试文件 + 会话状态更新

## 约束
- **ADR 是法律**：实施必须遵循 ADR 的 Implementation Guidelines，冲突时不默默偏离，标记到汇总
- **越界是合同**：触碰 Out of Scope 之外的文件必须停下来问
- Logic/Integration 测试非可选
- Visual/Feel 标准是"延后"不是"跳过"，标记为 DEFERRED
- 上下文不完整绝不开始编码

## 反例（不要这样）
- 未校验 TR 注册表/ADR 存在就直接派发程序员 agent
- 跳过 agent 路由表，把 story 交给错误角色的 agent 实现
- 把完整文档内容序列化进 Task prompt（应让 agent 自己读文件）
- 没有写测试文件就宣布 Logic story 完成
- 遇到 ADR 与 story 冲突时自己猜一个方向实施

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「文档我都看过了，直接塞进 Task prompt 让子 agent 一次到位」 | brief 只给文件路径与定向阅读指引，让 agent 自己读文件；序列化文档会膨胀上下文并埋下过期内容的坑。 |
| 「这个 Logic story 逻辑简单，测试后面再补」 | Logic/Integration 测试是 BLOCKING，非可选；每个验收标准至少一个测试函数，没有测试就不得宣布完成。 |
| 「ADR 和 story 冲突，我挑一个更合理的方向直接实现」 | ADR 是法律，冲突时不默默偏离，必须标记到汇总，让用户裁决。 |

## Red Flags（违规信号）
- 编排器自己直接写 src/ 源码文件（应由子 agent 完成写入）。
- story 被派发给路由表之外的角色 agent（如 UI story 给了 engine-programmer）。
- 未校验 TR 注册表/ADR 存在就派发 agent，或依赖 story 的 Status 非 Complete 仍继续。
- Logic/Integration story 提交时没有任何测试文件。

## Verification（证据化验证门）
- [ ] 每个 Logic/Integration story 都有对应测试文件，函数命名符合 test_[场景]_[期望结果]。
- [ ] 派发的 agent 与主 agent 路由表及引擎专家路由表匹配，可举证。
- [ ] Manifest 版本比对已执行，不一致时已记录用户选择（按新规则/按旧规则记录 Manifest-Note/停止）。
- [ ] ADR 冲突与越界偏离已标记到汇总，并在本地测试确认通过后才提醒跑 /story-done。
