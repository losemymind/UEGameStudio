# 会话交接（2026-09-12 · 第 3 版）

本文件供后续会话快速接续；仓库权威规则见根 `AGENTS.md` 与 `UEGameStudio/AGENTS.md`。旧版 Batch-G 交接记录（第 1/2 版）已由本版取代，需要追溯请查 git 历史。

## 仓库状态速览

- **git**：分支 `master`，remote `origin`（`https://github.com/losemymind/UEGameStudio.git`），HEAD `9cacb68`；本会话两个提交尚未 push（本地领先 `origin/master` 2 个提交）。
- **工作区**：干净（`git status` 无输出）。
- **成品结构**：`UEGameStudio/` = `agents/`、`skills/ue5.6/`、`docs/`、`scripts/`、`AGENTS.md`、`INSTALL.md`。
- **Agent 阵容**：30 个（不含 `_template.md`），分布 orchestration / directors / academic / design / technical / production / qa 共 7 层；全部 `mode: subagent`；`docs/agent-registry.json` 30 条与磁盘一致。
- **技能库**：`skills/ue5.6/` 共 57 个 skill（57 SKILL.md + 58 docs/overview.md），21 个 Kismet 库，累计约 3400+ 个函数。
- **门禁**：`verify-registry.ps1` = `REGISTRY_VERIFY: PASS (30 agents)`；`test-install.ps1` = 通过（30 Agent / 57 skill）。

## 本会话已完成改动

1. **漂移清理（使门禁转绿）**
   - 删除孤儿文件 `UEGameStudio/agents/orchestration/batch-g3-coordinator.md`：提交 `794873a` 声称删除但实际残留，且不在注册表内，导致 31≠30。经用户 2026-09-12 确认后重新移除。
   - 移除 `skills/ue5.6/` 下 4 个遗留空目录（`engine-subsystem`、`game-instance`、`kismet-memory-library`、`world`），目录数 61 → 57。
   - 影响文件：`agents/orchestration/batch-g3-coordinator.md`。
2. **`.opencode/` 移出版本控制**
   - `git rm -r --cached .opencode`（259 个文件出索引，磁盘 3900+ 文件保留）。
   - `.gitignore` 新增 `.opencode/` 规则（第 21 行），`git check-ignore` 已验证生效。
3. **仓库 `AGENTS.md` 治理规范新增第 8 条**：`.opencode/` 不入库，不得用 `git add -f` 绕过忽略；`git rm -r --cached .opencode` 的暂存删除须与其他改动分开处理。

**验证结果**：`verify-registry.ps1` PASS、`test-install.ps1` 全部断言通过（30 Agent / ue5.6 skills / 幂等）。

**提交结果**：本会话已提交两个 commit（均未 push）：
- `b4752c6` chore: 修正 Agent 阵容漂移并同步治理文档（`.gitignore`、`AGENTS.md`、孤儿 Agent 删除、`agent-roster-report.md`、`session-handoff.md`）
- `9cacb68` chore: 停止跟踪 .opencode 本地配置与 skills（259 个文件出索引，保留磁盘）

## 已知待办 / 潜在风险

- **未 push**：上述两个提交仍在本地，`origin/master` 未更新；push 需用户明确指示。
- **`agents/_template.md` 仍缺失**：`cb84600` 未说明即删除，根 `AGENTS.md` 与 `INSTALL.md` 仍引用它作为新 Agent 模板；`skills/_skill-anatomy.md`、`skills/_skill-template.md` 同样缺失。是否恢复待裁决。
- **交接文件历史**：旧版逐批统计已被本版覆盖。
- **真实项目工具验证**：`.uasset` / DCC / 音频 / 构建行为仍需在目标 UE 项目实测（见 `docs/formal-project-validation.md`）。
- **可选扩展**（非必须）：UE 5.7 兼容性清单、按使用率蒸馏插件库、补充已有 skill 的场景示例。

## 验证命令备忘

```powershell
# Agent 注册表与磁盘双向校验（漂移即 FAIL）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\verify-registry.ps1

# 安装器隔离回归（30 Agent / ue5.6 skills / 幂等）
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\test-install.ps1
```

---

## 新会话启动要求（请复制以下内容到新会话）

```text
读取 UEGameStudio/docs/session-handoff.md 与 UEGameStudio/docs/agent-roster-report.md，
核对 git status / git log 与磁盘实际阵容后，汇报差异并等待我确认本次任务，再开始执行。
注意：上一会话有两个提交尚未 push，请勿擅自推送；.opencode/ 已不再纳入版本控制。
```
