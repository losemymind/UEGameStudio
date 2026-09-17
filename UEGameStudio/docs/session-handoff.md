# 会话交接（2026-09-17 · 第 10 版）

本文件供后续会话快速接续；仓库权威规则见根 `AGENTS.md` 与 `UEGameStudio/AGENTS.md`。旧版交接记录（第 1–9 版）已由本版取代，需要追溯请查 git 历史。

## 仓库状态速览

- **git**：分支 `master`，remote `origin`（`https://github.com/losemymind/UEGameStudio.git`）；本版改动已随本版收尾提交推送，`origin/master` 已同步（提交前 HEAD 为 `f13c636`）。
- **本版改动范围**：10 个文件（`AGENTS.md`、`UEGameStudio/AGENTS.md`、`UEGameStudio/INSTALL.md`、`agents/gamestudio/gamestudio-orchestrator.md`（重命名+改名）、`agents/technical/performance-architecture-specialist.md`、`docs/agent-registry.json`、`docs/agent-roster-report.md`、`docs/session-handoff.md`、`scripts/install.ps1`、`scripts/test-install.ps1`）；未触碰 `skills/`、`.opencode/`。
- **成品结构**：`UEGameStudio/` = `agents/`、`skills/ue5.6/`、`docs/`、`scripts/`、`AGENTS.md`、`INSTALL.md`。
- **Agent 阵容**：31 个，分布 gamestudio / directors / academic / design / technical(12) / production / qa 共 7 层；全部 `mode: subagent`；`docs/agent-registry.json` 31 条与磁盘一致。
- **技能库**：`skills/ue5.6/` 共 63 个 skill（63 SKILL.md + 58 docs/overview.md），21 个 Kismet 库；其中 6 个性能优化 skill 随附 `evals.json`。
- **门禁**：`verify-registry.ps1` = `REGISTRY_VERIFY: PASS (31 agents verified)`；`test-install.ps1` = 通过（31 Agent / 63 skill / `subagent_depth` 断言 / 幂等）；`validate_agents.py --strict` = 31/31；`validate_skills.py --strict` = 63/63（仅余 evals.json 建议项）。

## 本会话（第 10 版）改动

1. **重命名总控编排专家：`orchestration-director` → `gamestudio-orchestrator`**
   - 目录：`agents/orchestration/` → `agents/gamestudio/`（该目录仅含此 1 个 Agent，原目录已不存在）。
   - 文件：`orchestration-director.md` → `gamestudio-orchestrator.md`；frontmatter `name` 同步为 `gamestudio-orchestrator`。
   - 注册表：`docs/agent-registry.json` 该条 `id` / `file` / `layer` 改为 `gamestudio-orchestrator` / `gamestudio/gamestudio-orchestrator.md` / `gamestudio`。
   - 引用同步：根 `AGENTS.md`（目录树 + 蒸馏结构）、`UEGameStudio/AGENTS.md` §3 路由原则、`agents/technical/performance-architecture-specialist.md`（4 处）、`INSTALL.md`（4 处）、`docs/agent-roster-report.md`（表格与时间线条目）、`scripts/install.ps1`（提示文案）、`scripts/test-install.ps1`（断言文案）。
   - 显示标题 `总控编排专家` 与职责、权限矩阵均未改动（权限仍为 `"*": deny`，`edit` 仅 `.opencode/task-plans/**`，`task: allow`，`bash`/`webfetch`/`websearch`/`external_directory: deny`）。
2. **门禁复跑**：上述改动后 `verify-registry.ps1` / `test-install.ps1` / `validate_agents.py --strict` 全部通过（见上文数值）。

## 上一会话已完成改动（已提交 `f13c636` 并推送）

1. **修复总控编排专家委派缺陷**：根因是 opencode `subagent_depth` **默认值为 1**，`task` 的深度门禁在权限检查之前执行（主 Agent → 编排专家时 `h=1`，`1 >= 1` 直接失败），与 `bash` 权限无关。`scripts/install.ps1` 现确保目标项目 `opencode.json` 的 `subagent_depth >= 2`（缺失或 `< 2` 写为 `2`，不降级既有更大值，非整数报错且不改写原文件）；`test-install.ps1` 增加对应断言。**未修改任何 Agent 权限**。
2. **修复 `performance-architecture-specialist` 非法权限**：`restricted:` 字面值导致目标项目 `ConfigInvalidError`，已改为 `edit: allow`；`verify-registry.ps1` 新增 permission 键名与取值校验（此类错误现于门禁阶段 FAIL）。
3. **权属收敛**：任务树写入权归还总控（该 Agent 只提交建议节点路径）；ADR 统一存放项目根 `.adr/`，编号与状态归 `technical-director`。
4. **文档漂移修正**：30 → 31 Agent、57 → 63 skill 的计数与描述同步。

## 已知待办 / 潜在风险

- **重命名不会自动清理目标项目旧文件**：`install.ps1` 只复制不修剪，已安装过旧阵容的项目重装后 `.opencode/agent/orchestration/orchestration-director.md` 仍会残留，旧 ID 与 `gamestudio-orchestrator` 同时存在。升级旧项目时需先手工删除该旧文件（或清空 `.opencode/agent/` 后重装）；此点尚未写入 `INSTALL.md` 升级说明，待用户裁决是否补写。
- **委派深度需随项目配置**：`gamestudio-orchestrator` 依赖目标项目 `opencode.json` 的 `subagent_depth >= 2`（opencode 默认 1 会拦截）；`opencode.json` 改动需重启会话生效。
- **升级回归项**：若未来 opencode 把该键移回 `experimental.subagent_depth` 或改变默认值，需复核 `install.ps1` 的写入位置与 `test-install.ps1` 的断言。
- **evals.json 缺口**：57 个旧 skill 无独立触发用例（6 个性能 skill 已有）。
- **`.adr/` 目录尚未在目标项目中建立**：仅登记了 ADR 存放约定与权属；首次写 ADR 时由 `technical-director` 创建目录。
- **真实项目工具验证**：`.uasset` / DCC / 音频 / 性能 / 构建行为仍需在目标 UE 项目实测（见 `UEGameStudio/docs/formal-project-validation.md`）。
- **可选扩展**（非必须）：UE 5.7 兼容性清单、按使用率蒸馏插件库、补充已有 skill 的场景示例。

## 验证命令备忘

```powershell
# Agent 注册表与磁盘双向校验（含 permission 键名与取值校验，漂移或非法权限即 FAIL）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\verify-registry.ps1

# 安装器隔离回归（31 Agent / ue5.6 skills / subagent_depth / 幂等）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\test-install.ps1

# Agent 规范严格校验（agent-creator）
python .\.opencode\skills\agent-creator\scripts\validate_agents.py --dir .\UEGameStudio\agents --strict

# Skill 规范严格校验（skill-creator）
python .\.opencode\skills\skill-creator\scripts\validate_skills.py --dir .\UEGameStudio\skills --strict
```

> 后两条依赖本地 `.opencode/skills/` 中的 agent-creator / skill-creator（不入版本控制）；换机或缺失时需先重装这两个创建器技能。

---

## 新会话启动要求（请复制以下内容到新会话）

```text
读取 UEGameStudio/docs/session-handoff.md 与 UEGameStudio/docs/agent-roster-report.md，
核对 git status / git log 与磁盘实际阵容后，汇报差异并等待我确认本次任务，再开始执行。
注意：.opencode/ 不入版本控制；不要擅自提交或推送。
```
