# 会话交接（2026-09-16 · 第 9 版）

本文件供后续会话快速接续；仓库权威规则见根 `AGENTS.md` 与 `UEGameStudio/AGENTS.md`。旧版交接记录（第 1–8 版）已由本版取代，需要追溯请查 git 历史。

## 仓库状态速览

- **git**：分支 `master`，remote `origin`（`https://github.com/losemymind/UEGameStudio.git`）；本版改动随收尾提交一并推送，`origin/master` 已同步。
- **成品结构**：`UEGameStudio/` = `agents/`、`skills/ue5.6/`、`docs/`、`scripts/`、`AGENTS.md`、`INSTALL.md`。
- **Agent 阵容**：31 个，分布 orchestration / directors / academic / design / technical(12) / production / qa 共 7 层；全部 `mode: subagent`；`docs/agent-registry.json` 31 条与磁盘一致。
- **技能库**：`skills/ue5.6/` 共 63 个 skill（63 SKILL.md + 58 docs/overview.md），21 个 Kismet 库；其中 6 个性能优化 skill 随附 `evals.json`。
- **门禁**：`verify-registry.ps1` = `REGISTRY_VERIFY: PASS (31 agents verified)`；`test-install.ps1` = 通过（31 Agent / 63 skill / `subagent_depth` 断言 / 幂等）；`validate_agents.py --strict` = 31/31；`validate_skills.py --strict` = 63/63（仅余 evals.json 建议项）。

## 本会话（第 9 版）改动

1. **修复：总控编排专家无法启动其他 subagent（含一次误判更正）**
   - **现象**：主 Agent 启动 `orchestration-director` 后，该 Agent 无法启动任何专业 Agent。
   - **误判（已作废）**：本版前的第 7 版曾判定根因为「该 Agent 无 `bash` 权限」/「宿主深度限制属环境约束、无法在成品内消除」。**两条均错误**，第 7 版从未提交，故直接替换而非留档。
   - **真因**：opencode 的 `subagent_depth` **默认值为 1**。`task` 工具的深度门禁在**权限检查之前**执行：`while (b.parentID) h++; if (h >= subagent_depth ?? 1) return fail(...)`。主 Agent → 编排专家时 `h=1`，`1 >= 1` 立即失败，错误为 `Subagent depth limit reached (1). Increase "subagent_depth" to allow nested subagents.`
   - **`bash` 无关的三条证据**：① `task` 是 opencode 官方 schema 的合法权限键，编排专家本就持有 `task: allow`；② `bash` 与 `task` 是两条独立权限且无相关性——5 个可委派角色（orchestration/game/technical/audiovisual director + game-producer）全部 `bash: deny`，另有 22 个 Agent 为 `bash: allow` 但 `task: deny`；③ 门禁先于权限查询，放宽权限不改变结果。
   - **修复**：`scripts/install.ps1` 写入目标项目 `opencode.json` 时确保 `subagent_depth >= 2`——缺失或 `< 2` 写为 `2`，已存在且 `>= 2` 保留不降级，非整数则报错且不改写原文件。链路因此为 主 Agent(`h=0`) → 编排专家(`h=1`，通过) → 专业 Agent(`h=2`，正常拦截，符合三权分离)。
   - **未修改任何 Agent 定义**：未放宽 `orchestration-director` 的权限，`"*": deny` 与 `edit` 仅 `.opencode/task-plans/**` 保持不变；用户曾提出「全部权限」，已用上述证据说明其不修复该问题且违反 `AGENTS.md` §3 权限收窄与 §3.1，故未采纳。
2. **`scripts/test-install.ps1` 增加断言**：既有配置补 `2`、全新配置为 `2`、二次运行仍为 `2`、既有 `5` 不被降级、非整数 `subagent_depth` 报错且文件未被改写。
3. **新增 `docs/orchestration-director-runbook.md`**（`UEGameStudio/docs/`，不随安装部署）
   - 内容：症状与结论、`task` 深度门禁机制与期望链路、`bash` 误判排查三条证据、安装侧修复、宿主侧验证（读 `opencode.json` 的 `subagent_depth`）与降级处置（路径 A 修正配置/顶层、路径 B 宿主代执行）、委派契约模板、边界。
   - 明确写入：**不得**以放宽权限（含 `"*": allow`）替代深度配置。
4. **文档同步**
   - `INSTALL.md`：成品内容表新增 runbook 行；安装步骤第 7 条（写入 `subagent_depth`）；`opencode.json` 结果示例与说明；手动安装步骤；回归测试项；目标项目验证项；升级说明；安全要求新增「委派失败优先检查 `subagent_depth`，不要靠放宽权限解决」。
   - `agent-roster-report.md`：报告信息行（委派深度配置）、新增 `### 2026-09-16 委派深度缺陷修复` 子节、执行摘要段、权限结论区注记、治理问题表行。
   - 顺带修正 `session-handoff.md` 第 6 版中已过期的提交指针（`e8f61ec` → 实际收尾提交 `fa639bc`）。
5. **ME 目标项目已重装（用户 2026-09-16 指示执行）**
   - 执行命令：`install.ps1 -TargetProject "E:\GitHub\ME" -SkillsVersion "ue5.6"`。
   - 结果：31 Agent（与工作区源 **SHA256 全部一致**）、63 skill；`opencode.json` 追加 `"subagent_depth": 2`，原有 4 条 `instructions` 与 `$schema` 全保留；备份 `opencode.json.uegamestudio-20260916-210614.bak`。
   - 未受影响：ME `Content/MassCiv/` 下 3 个已修改的 `.umap`/`.uasset` 状态不变，`.opencode/task-plans/` 仍未跟踪。
   - **待用户执行**：**重启 ME 的 opencode 会话**后配置才生效，随后向 `orchestration-director` 提交只读发现任务验证委派链路。



## 上一会话已完成改动（已提交 `e8f61ec` / `fa639bc` 并推送）

1. **修复 `performance-architecture-specialist` 非法权限（目标项目加载报错根因）**
   - 原 frontmatter `edit: restricted:.opencode/task-plans/**;.adr/performance-*.md`：`restricted:` 是注册表/校验脚本的内部摘要表示，不是 opencode 合法取值（只接受 `allow`/`ask`/`deny` 或 glob 对象），导致 ME 项目安装后报 `ConfigInvalidError: Expected PermissionActionConfig`。
   - 依用户 2026-09-16 裁决改为 `edit: allow`（全量编辑权，以文件正确性优先于机械收窄）；删除不在 opencode 权限键表内的 `retrieve`/`net`，补齐与其余 Agent 同构的显式矩阵（`glob`/`grep`/`list`/`bash`/`webfetch`/`websearch`/`task`/`lsp`/`external_directory`）。
   - 修正正文 3 处笔误：协同评审前导空格、`architect ure设计`、技能路径 `skills/ue5.6/performance/` → `skills/ue5.6/`。
   - `docs/agent-registry.json` 同步该条 `edit: allow`、`webfetch/websearch: allow`。
2. **门禁加固：`scripts/verify-registry.ps1` 新增 permission 校验**
   - 顶层键必须属于 opencode 权限键集合；取值必须为 `allow`/`ask`/`deny` 或 glob 对象。
   - 已用负向测试确认：写回 `restricted:` 字面值即 `REGISTRY_VERIFY: FAIL`。此前四道门禁全部漏过该错误，只能在加载时暴露。
   - 顺带清理第 28 行死代码 typo（`'_ template.md'` 多一个空格，从未生效；真实过滤在下一行）。
3. **治理收敛（新 Agent 的权属对齐）**
   - **任务树写入权**：`performance-architecture-specialist` 不再自称落盘 `.opencode/task-plans/**`，改为把架构结论与建议节点路径提交 `orchestration-director`，由其唯一写回；与 `UEGameStudio/AGENTS.md` §3.1 及总控定义一致。
   - **ADR 归属**：新增仓库级约定——ADR 统一存放于项目根 `.adr/`，编号与状态归 `technical-director`（`TD-ADR`），已写入其关键规则与工作流程；该 Agent 只提交 `.adr/performance-*.md` 候选草案。
   - **措辞修正**：该 Agent 原「权限边界」改为「职责边界（专业自律，非运行时强制）」，与 `edit: allow` 的运行时事实一致；`agent-roster-report.md` 权限结论同步。
4. **文档漂移修正（30 → 31 Agent、57 → 63 skill）**
   - `INSTALL.md` 5 处计数、根 `AGENTS.md` 阵容计数与 technical 层描述、`test-install.ps1` 提示文案。
   - `agent-roster-report.md`：报告信息、技能统计、新增 2026-09-16 条目、阵容树、功能层与能力矩阵、权限结论（含 `edit: allow` 依据、`职责边界` 措辞与任务树/ADR 权属说明）、治理问题表（顺带修了 1 处列数错行）、后续建设原则第 12 条。
5. **副作用说明**：`.opencode/` 未纳入版本控制；根目录 `opencode.jsonc`（仅 `$schema`）保留不动。改动共 9 个文件，均位于 `UEGameStudio/` 与根 `AGENTS.md`。

## 已知待办 / 潜在风险

- **本版改动已提交推送**；本文件为随之同步的收尾记录。
- **工作区源共 6 个文件变更**——`scripts/install.ps1`、`scripts/test-install.ps1`、`docs/orchestration-director-runbook.md`（新增）、`docs/agent-roster-report.md`、`docs/session-handoff.md`、`INSTALL.md`；未触碰 `agents/`、`skills/`、`.opencode/`。
- **委派深度需随项目配置**：`orchestration-director` 依赖目标项目 `opencode.json` 的 `subagent_depth >= 2`（opencode 默认 1 会拦截）。新安装由 `install.ps1` 自动写入；**本次修复前已安装的项目需重装或手工补写该键**。`opencode.json` 改动需重启会话生效。ME 已于本版重装写入 `2`。
- **升级回归项**：若未来 opencode 把该键移回 `experimental.subagent_depth` 或改变默认值，需复核 `install.ps1` 的写入位置与 `test-install.ps1` 的断言。
- **ME 目标项目**：本版已由用户指示重装（31 Agent / 63 skill / `subagent_depth: 2`），备份 `opencode.json.uegamestudio-20260916-210614.bak`；**尚未重启会话，委派链路未实测**。ME 侧 `Content/MassCiv/` 3 个资产改动为其自身未提交项，与本仓库无关。
- **evals.json 缺口**：57 个旧 skill 无独立触发用例（6 个性能 skill 已有）；如需触发回归需后续补齐。
- **`.adr/` 目录尚未在目标项目中建立**：本次只登记了 ADR 存放约定与权属；实际项目首次写 ADR 时由 `technical-director` 创建目录。
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

## 参考文档

- `docs/orchestration-director-runbook.md`：总控编排专家的委派深度配置机制、`bash` 误判排查、安装侧修复与降级处置（仅作仓库参考，不随安装部署）。

---

## 新会话启动要求（请复制以下内容到新会话）

```text
读取 UEGameStudio/docs/session-handoff.md 与 UEGameStudio/docs/agent-roster-report.md，
核对 git status / git log 与磁盘实际阵容后，汇报差异并等待我确认本次任务，再开始执行。
注意：.opencode/ 不入版本控制；不要擅自提交或推送。
```
