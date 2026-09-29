# 会话交接（2026-09-29 · 第 11 版）

本文件供后续会话快速接续；仓库权威规则见根 `AGENTS.md` 与 `UEGameStudio/AGENTS.md`。第 10 版记录保留在下方供追溯，第 1–9 版见 git 历史。

## 仓库状态速览

- **git**：分支 `master`；本版开始时 HEAD 为 `963b1c8`。本轮修改仅在工作区，未提交或推送。
- **本版改动范围**：新增性能诊断 skill、渲染与运行时分析 Agent；重写既有剖析和架构 Agent 的流程；更新六个既有性能 skill、技术路由、注册表、安装测试与说明文档；`.opencode/` 未纳入版本控制。
- **成品结构**：`UEGameStudio/` = `agents/`、`skills/ue5.6/`、`docs/`、`scripts/`、`AGENTS.md`、`INSTALL.md`。
- **Agent 阵容**：33 个，分布 gamestudio / directors / academic / design / technical(14) / production / qa 共 7 层；全部 `mode: subagent`；`docs/agent-registry.json` 33 条与磁盘一致。
- **技能库**：`skills/ue5.6/` 共 64 个 skill（64 SKILL.md + 58 docs/overview.md）；其中 7 个性能相关 skill 随附 `evals.json`。
- **门禁**：`verify-registry.ps1` = `REGISTRY_VERIFY: PASS (33 agents verified)`；`test-install.ps1` = 通过（33 Agent / 64 skill / `subagent_depth` 断言 / 幂等）；`validate_agents.py --strict` = 33/33；`validate_skills.py --strict` = 64/64（旧技能仍有 57 条 evals.json 建议项）。

## 本会话（第 11 版）改动

1. 从 Epic 性能优化学习路径总页提取并整理 31 个子链接，落入 `skills/ue5.6/performance-diagnostics/references/source-index.md`。索引明确区分正文核对与目录级核对，视频字幕尚未核对；技术细节须按 UE5.6 项目版本验证。
2. 新 skill 以场景/构建/设备、帧时间与尾部、Insights/GPU/平台工具、单变量 A/B 及复测为主线，提供 profiling、rendering、runtime 参考与触发用例。六个旧性能实施 skill 增加测量入口与版本核对。
3. `performance-profiler` 保留正式测量和 `PERF-BUDGET`，`performance-architecture-specialist` 保留跨系统 ADR 草案；新增 `ue-rendering-performance-analyst` 与 `ue-runtime-performance-analyst` 两个只读专题角色。架构决策、实施与独立验证仍分离。
4. 注册表、技术总监路由、产品说明、阵容报告和安装器断言同步为 33 Agent / 64 skill。未对真实 UE 游戏工程进行性能实测。

## 当前限制与接手事项

- **来源覆盖**：学习路径 31 条链接中，11 条核对过正文或官方文档，20 条只核对了总页标题、简介与链接；视频字幕未核对。使用具体 UE 命令、CVar、默认值或功能状态前，按目标版本重新核查原文。逐条状态见 `skills/ue5.6/performance-diagnostics/references/source-index.md`。
- **验证范围**：当前通过的是仓库注册表、Agent/Skill 静态规范和隔离安装回归；尚未把这套 Agent/Skill 装入真实 UE 项目采集 Trace、运行 A/B 或验证 `PERF-BUDGET`。任何真实性能收益仍需目标设备与代表性构建证明。
- **工作区状态**：本轮文件未提交、未推送；先核对 `git status`，保留本轮改动和用户已有工作。目标项目中若残留旧 ID `orchestration-director`，安装器不会自动清理，升级时需单独核查。
- **个人临时副本**：此前整理时创建的 `C:\Users\Administrator\.codex\skills\ue-performance-optimization` 及三个 `ue-perf-*.toml` 仍在个人 Codex 目录。自动审批审查拒绝了递归删除命令；仓库成品不依赖这些副本。
- **既有建议项**：严格 Skill 校验通过，但 57 个旧 skill 仍缺 `evals.json`，属于非阻断建议项；本轮新增的 `performance-diagnostics` 已有触发用例。

## 第 10 版记录（历史）

### 第 10 版当次改动

1. **重命名总控编排专家：`orchestration-director` → `gamestudio-orchestrator`**
   - 目录：`agents/orchestration/` → `agents/gamestudio/`（该目录仅含此 1 个 Agent，原目录已不存在）。
   - 文件：`orchestration-director.md` → `gamestudio-orchestrator.md`；frontmatter `name` 同步为 `gamestudio-orchestrator`。
   - 注册表：`docs/agent-registry.json` 该条 `id` / `file` / `layer` 改为 `gamestudio-orchestrator` / `gamestudio/gamestudio-orchestrator.md` / `gamestudio`。
   - 引用同步：根 `AGENTS.md`（目录树 + 蒸馏结构）、`UEGameStudio/AGENTS.md` §3 路由原则、`agents/technical/performance-architecture-specialist.md`（4 处）、`INSTALL.md`（4 处）、`docs/agent-roster-report.md`（表格与时间线条目）、`scripts/install.ps1`（提示文案）、`scripts/test-install.ps1`（断言文案）。
   - 显示标题 `总控编排专家` 与职责、权限矩阵均未改动（权限仍为 `"*": deny`，`edit` 仅 `.opencode/task-plans/**`，`task: allow`，`bash`/`webfetch`/`websearch`/`external_directory: deny`）。
2. **门禁复跑**：第 10 版当时 `verify-registry.ps1` / `test-install.ps1` / `validate_agents.py --strict` 全部通过（当时为 31 Agent）；本版的 33 Agent 结果见当前状态速览。

### 第 10 版所记上一会话改动（已提交 `f13c636` 并推送）

1. **修复总控编排专家委派缺陷**：根因是 opencode `subagent_depth` **默认值为 1**，`task` 的深度门禁在权限检查之前执行（主 Agent → 编排专家时 `h=1`，`1 >= 1` 直接失败），与 `bash` 权限无关。`scripts/install.ps1` 现确保目标项目 `opencode.json` 的 `subagent_depth >= 2`（缺失或 `< 2` 写为 `2`，不降级既有更大值，非整数报错且不改写原文件）；`test-install.ps1` 增加对应断言。**未修改任何 Agent 权限**。
2. **修复 `performance-architecture-specialist` 非法权限**：`restricted:` 字面值导致目标项目 `ConfigInvalidError`，已改为 `edit: allow`；`verify-registry.ps1` 新增 permission 键名与取值校验（此类错误现于门禁阶段 FAIL）。
3. **权属收敛**：任务树写入权归还总控（该 Agent 只提交建议节点路径）；ADR 统一存放项目根 `.adr/`，编号与状态归 `technical-director`。
4. **文档漂移修正**：30 → 31 Agent、57 → 63 skill 的计数与描述同步。

### 已知待办 / 潜在风险（第 10 版记录，未逐项复核）

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

# 安装器隔离回归（33 Agent / 64 ue5.6 skills / subagent_depth / 幂等）
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
核对 git status / git log、注册表与磁盘实际阵容，保留本轮尚未提交的改动。
按用户当前任务继续执行；.opencode/ 不入版本控制，不要擅自提交或推送。
```
