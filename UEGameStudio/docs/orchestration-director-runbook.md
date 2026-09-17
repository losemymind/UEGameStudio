# 总控编排专家运行手册（委派深度配置与降级处置）

> **适用范围**：仅 `agents/orchestration/orchestration-director.md`（总控编排专家）。其他 30 个 Agent 不在本手册范围内。
> **部署性质**：本文件位于 `UEGameStudio/docs/`，仅作仓库参考，**不随 `install.ps1` 部署到目标项目**。
> **记录日期**：2026-09-16

## 1. 症状与结论

**症状**：主 Agent 启动了 `orchestration-director`，但该 Agent 无法启动任何其他 subagent。

**结论（2026-09-16 更正）**：根因是 **opencode 的 `subagent_depth` 默认值为 1**，与 `bash` 权限无关。

```text
Subagent depth limit reached (1). Increase "subagent_depth" to allow nested subagents.
```

`install.ps1` 现已修复：写入目标项目 `opencode.json` 时确保 `subagent_depth >= 2`。

> **历史误判更正**：本手册 2026-09-16 初版曾把根因记为「宿主 `subagent_depth = 1` 属环境限制，无法在成品内消除」。该结论错误，已作废。现版本由第 3 节证据支持，并由安装器直接修复。

## 2. 机制

opencode 的 `task` 工具在**权限检查之前**先做深度门禁（反编译 `opencode.exe`）：

```js
let q = yield*i.get(p.sessionID), b = q, h = 0;
while (b.parentID) h++, b = yield*i.get(b.parentID);
if (h >= ($.subagent_depth ?? 1))
  return yield*s.fail(Error(`Subagent depth limit reached (${$.subagent_depth ?? 1}). ...`));
if (!p.extra?.bypassAgentCheck) yield*p.ask({ permission: tr, patterns: [m.subagent_type], ... });
```

- `h` = 当前会话沿 `parentID` 链到根的层数。
- 先 `return fail`，后查权限。**因此 `bash` / `edit` / `webfetch` 等权限取值对委派结果没有任何影响。**

官方 schema（`https://opencode.ai/config.json`，`Config.properties.subagent_depth`）：

| 属性 | 值 |
| --- | --- |
| 类型 | `integer`，最小 0 |
| 默认 | `1` |
| 描述 | "Maximum subagent nesting depth. Defaults to 1, which prevents subagents from launching subagents." |

顶层键为 `subagent_depth`；旧版的 `experimental.subagent_depth` 在二进制中保留了迁移逻辑。

### 期望链路

```text
h=0  主 Agent（primary，会话无 parentID）
 ├─ h=1  orchestration-director
 │   └─ h=2  专业 Agent
```

- `subagent_depth = 1`：orchestration-director 调用 `task` 时 `h=1`，`1 >= 1` → **失败**。
- `subagent_depth = 2`：`h=1`，`1 >= 2` 不成立 → **通过**；专业 Agent 再调用 `task` 时 `h=2`，`2 >= 2` → 失败（符合预期的三权分离，实施层不得继续下沉委派）。

## 3. 误判排查：为什么不是 `bash` 权限

排查委派失败时，依次核对以下三条即可排除权限假设：

1. **`task` 是合法的权限键，且本 Agent 已为 `allow`**。官方 schema 的 `PermissionConfig.properties` 列出 `read`/`edit`/`glob`/`grep`/`list`/`bash`/`task`/`external_directory`/`todowrite`/`question`/`webfetch`/`websearch`/`lsp`/`skill`。`orchestration-director` 的 `task: allow` 已被识别，不是被拒绝。
2. **`bash` 与 `task` 是两条独立权限，且无相关性**。目标项目中全部 5 个可委派角色（`orchestration-director`、`game-director`、`technical-director`、`game-producer`、`audiovisual-director`）均为 `bash: deny`；另有 22 个 Agent 为 `bash: allow` 但 `task: deny`。委派不经过 `bash`。
3. **门禁顺序决定权限无关**。见第 2 节的 `return fail` 位置：深度超限时权限尚未被查询。给 Agent 开全权限也不会改变结果。

## 4. 安装侧修复（已完成）

`scripts/install.ps1` 在写入 `opencode.json` 时：

- 缺失 `subagent_depth` → 写入 `2`；
- 已存在且 `< 2` → 提升为 `2`；
- 已存在且 `>= 2` → 保留原值，不降级；
- 已存在但非整数 → 抛错并**不修改**原文件。

`scripts/test-install.ps1` 对应断言：既有配置补 `2`、全新配置为 `2`、二次运行为 `2`、既有 `5` 不被降级、非整数配置报错且文件未被改写。

## 5. 宿主侧验证与降级处置

### 步骤 1 — 验证目标项目配置

在目标 UE 项目根检查 `opencode.json`：

```powershell
(Get-Content .\opencode.json -Raw | ConvertFrom-Json).subagent_depth
```

期望输出 `>= 2`。若缺失或为 `1`（例如项目早于本次安装器修复即已安装），补写后再启动会话：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "subagent_depth": 2,
  "instructions": [ "UEGameStudio/AGENTS.md" ]
}
```

**注意**：`opencode.json` 的改动需要重启会话才生效；安装器不会覆盖用户更大的取值。

### 步骤 2 — 识别降级（配置无法调整时）

若某宿主环境硬性限制深度、无法设置 `subagent_depth`，`orchestration-director` 会以 `BLOCKED_TOOLING` 返回。此时不要重复重试委派；按下列路径处置：

- **路径 A（首选）**：让编排专家运行在**顶层 Agent**，或确保目标项目 `subagent_depth >= 2`。这是唯一能让编排层按设计工作的方式。
- **路径 B**：由当前顶层 Agent（或用户）代总控执行其委派计划，调用专业 Agent 并回填任务节点。路径 B 是可审计替代方案，**不等价于真实编排**。

### 步骤 3 — 降级模式下的强制行为（编排专家侧）

1. 明确声明 `BLOCKED_TOOLING`，并给出实际错误文案与 `subagent_depth` 当前值。
2. 不得声称已委派、已执行命令、已取得专业结论或已落盘任务树。
3. 门禁照旧：先提问、达到 98% 且用户明确确认后才给出计划草案。
4. 交付物限定为：需求澄清问题与需求摘要、完整可执行的委派计划（按第 6 节契约字段）、需宿主代执行的命令清单、明确的未执行项与解除条件。

### 步骤 4 — 宿主代执行时下发最小契约

按第 6 节模板逐个子任务下发；每个子任务只能有一个唯一主责。

### 步骤 5 — 宿主必须回填

- 每个子任务的 `status`、交付物、证据、实际修改文本路径、实际修改 Package、阻塞类型；
- 预期写入清单与实际写入清单的对账结果；
- 未满足的验收条件、剩余风险与建议下一步。

### 步骤 6 — 本仓库门禁校验

```powershell
# Agent 注册表与磁盘双向校验（含 permission 键名与取值校验）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\verify-registry.ps1

# 安装器隔离回归（31 Agent / ue5.6 skills / subagent_depth / 幂等）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\test-install.ps1
```

## 6. 委派契约模板（照抄给每个专业 Agent）

```text
任务 ID：
计划 ID：
节点文件：
父任务 ID：
目标：
主责 Agent：
协作或评审 Agent：
输入与证据：
范围：
非目标：
必须遵守的项目约束：
预期交付物：
验收条件：
前置依赖：
允许修改的文本路径：
允许修改的 Package：
允许创建的新文件或对象：
允许执行的操作类型：
明确禁止的路径、Package 和操作：
允许使用的外部工具与目录：
预期写入清单：
阻塞与升级条件：
```

要求返回：状态（READY/CONCERNS/BLOCKED）、核心结论、交付物、证据、假设与未知项、风险、阻断类型（`BLOCKED_INPUT`/`BLOCKED_TOOLING`/领域专用阻断/NONE）、解除阻断的条件与责任方、实际修改的文本路径、实际修改的 Package、实际创建的文件或对象、实际使用的外部工具与目录、超出预期写入（YES/NO）、未满足的验收条件、建议的下一步。

## 7. 边界

- **不得用权限放宽替代深度配置**：`task: allow` + `subagent_depth >= 2` 才是正确组合。给 `orchestration-director` 开 `"*": allow` 既不修复委派，也违反 `AGENTS.md` §3 权限收窄与 §3.1 任务树唯一写入主责，并破坏决策/实施分离。
- 不通过更换 Agent 绕过权限限制；不以 `bash` 或宿主命令替代本应由委派完成的工作并声称为编排结果。
- 本手册不授权任何 `git commit` / `git push`，也不授权写入 `.opencode/`。
- 调试 `.uasset`/`.umap` 类问题仍需目标 UE 版本的 Editor 或受控自动化；工具不可用时按 `BLOCKED_TOOLING` 处理，不得声称二进制资产已完成。
