# INSTALL.md — UE Game Studio Agents & Skills 安装指南

把本成品包安装到目标环境（全局 或 某个游戏项目），使其 agent 获得游戏开发智能化能力（含 UE 引擎专属专家）。

## 安装内容

| 组件 | 说明 | 安装到 |
|---|---|---|
| `agents/`（39 个） | 按职能层级分类的 subagent（directors/leads/specialists/operations/qa/engine-unreal） | 全局 agents 目录 或 `.opencode/agents/` |
| `skills/`（70 个） | 按生命周期分类的技能（gate/review/pipeline/authoring/analysis/team/sprint/utility） | 全局 skills 目录 或 `.opencode/skills/` |
| `references/` | 共享清单（含 `project-paths.md` 路径约定，被 22 个技能/agent 引用） | 随 skills 复制到目标项目并保持相对位置（建议 `references/` 与 `skills/` 同层，技能内以 `references/project-paths.md` 相对引用） |

> **目标目录**：
> - **全局**：`~/.config/opencode/agents/` 与 `~/.config/opencode/skills/`
> - **项目**：`<游戏项目>\.opencode\agents\` 与 `<游戏项目>\.opencode\skills\`

---

## 安装脚本说明

本包内 `agents/` 与 `skills/` 采用**分类子文件夹**组织（便于维护）。安装时可**展平复制**到目标目录（agent 文件平铺、技能目录平铺到目标 `skills/` 根），也可直接递归复制保留分类结构——opencode 加载器递归扫描、自进化运行时校验脚本（支持递归扫描）两种结构均兼容。

## 方式一：安装到全局（推荐：多个项目共享）

```powershell
$src = "<本成品包路径>"

# agents（递归收集全部 .md，展平复制）
Get-ChildItem -Recurse -LiteralPath "$src\agents" -Filter *.md | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination "$env:USERPROFILE\.config\opencode\agents\" -Force
}

# skills（递归定位每个技能目录，展平复制到目标 skills 根）
Get-ChildItem -Recurse -LiteralPath "$src\skills" -Filter SKILL.md | ForEach-Object {
    Copy-Item -LiteralPath $_.Directory.FullName -Destination "$env:USERPROFILE\.config\opencode\skills\" -Recurse -Force
}
```

## 方式二：安装到某个游戏项目

```powershell
$src = "<本成品包路径>"
$proj = "<游戏项目根目录，如 E:\Projects\MyGame>"

# agents
New-Item -ItemType Directory -Path "$proj\.opencode\agents" -Force | Out-Null
Get-ChildItem -Recurse -LiteralPath "$src\agents" -Filter *.md | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination "$proj\.opencode\agents\" -Force
}

# skills
New-Item -ItemType Directory -Path "$proj\.opencode\skills" -Force | Out-Null
Get-ChildItem -Recurse -LiteralPath "$src\skills" -Filter SKILL.md | ForEach-Object {
    Copy-Item -LiteralPath $_.Directory.FullName -Destination "$proj\.opencode\skills\" -Recurse -Force
}
```

> 安装后技能在目标 `skills/` 下为平铺结构（`skills/<技能名>/SKILL.md`），opencode 递归加载、自进化运行时校验脚本均可用。`_evolutions/`（技能演进注册表）默认不随技能安装；若目标项目已装自进化运行时并要纳入棘轮门，把 `skills/_evolutions/` 一并复制。

---

## 安装后验证

1. **重启** opencode，使新 agents/skills 生效。
2. 确认 agents 可被调用：新建会话，要求主 agent 派发 `unreal-specialist`（engine/unreal）或 `lead-programmer`（leads）等 subagent。
3. 确认 skills 被加载：输入触发技能描述的任务，观察技能是否被自动匹配。

## 卸载

删除对应目录下安装的 agent 文件（`*.md`）与技能目录即可。技能演进注册表 `_evolutions/evolutions.json` 一并删除或清空。

## 升级

- 本包使用 `VERSION` 文件管理版本。
- 升级 = 重新复制 `agents/` 与 `skills/`（覆盖同名文件）。
- 若你自定义过技能正文，升级前先 diff 备份。

---

## 配套（可选）

- **自进化运行时（SEA 等）**：如需记忆蒸馏/棘轮评估/技能进化能力，可安装独立的自进化运行时并把本包技能纳入其进化闭环（评测集 `test-prompts.json` 随演进渐进补充）。本成品包为纯资产，不依赖任何运行时即可使用。
- **版本锚定**：引擎专属 agent（`engine/unreal/*`）的「版本纪律」要求断言 UE API 前先核实 `docs/engine-reference/unreal/VERSION.md`；建议项目建立该目录并按 agent 纪律维护。
