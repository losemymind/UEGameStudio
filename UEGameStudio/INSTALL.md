# UEGameStudio 成品安装说明（opencode）

## 1. 成品内容

本目录为可安装成品，共 28 个有效 Agent 与 2 份治理文档：

| 路径 | 说明 |
| --- | --- |
| `agents/orchestration/` | 总控编排专家（工作流引擎，建议作为入口） |
| `agents/directors/` | 游戏总设计师、技术总监、游戏制作人、视听总监 |
| `agents/academic/` | 人类学家、地理学家、历史学家、叙事学家、心理学家 |
| `agents/design/` | 数值专家、经济专家、关卡与任务设计专家 |
| `agents/technical/` | UE 核心系统、Gameplay、AI、世界构建、动画、UI、技术美术、音频、工具管线、性能、构建 |
| `agents/production/` | 资产生产管理、视觉资产制作 |
| `agents/qa/` | 资产合规审计、QA 测试 |
| `agents/_template.md` | 新 Agent 编写模板（**不安装**，仅用于编写） |
| `docs/session-handoff.md` | 会话交接说明（**不随安装部署**，仅保留于成品仓库作参考） |
| `docs/agent-roster-report.md` | 智能体阵容报告（**不随安装部署**，仅保留于成品仓库作参考） |

所有 Agent 均为 opencode `mode: subagent` 格式（YAML frontmatter），可直接被 opencode 加载。

## 2. 前置条件

- 已安装 opencode，并能在目标项目中正常启动。
- 目标项目为一个 UE 项目目录（至少已确定 `.uasset` 安全规则所依赖的目录边界）。
- 已为目标项目配置好可用的 LLM 供应商（项目或全局 `opencode.json`）。

## 3. 标准安装

### 3.1 复制 Agent 到 `.opencode/agent/`

将 `agents/` 下全部子目录与文件复制到目标项目的 `.opencode/agent/`，**排除 `_template.md`**。opencode 会递归扫描该目录下的 `.md` 文件并注册为 Agent；保留现有子目录分组即可。

PowerShell（Windows）：

```powershell
robocopy "UEGameStudio\agents" "<目标项目>\.opencode\agent" /E /XF "_template.md" /NFL /NDL /NJH /NJS
```

macOS / Linux：

```bash
mkdir -p <目标项目>/.opencode/agent
cp -r UEGameStudio/agents/* <目标项目>/.opencode/agent/
rm -f <目标项目>/.opencode/agent/_template.md
```

安装后目标项目结构：

```
<目标项目>/
├── .opencode/
│   └── agent/
│       ├── orchestration/orchestration-director.md
│       ├── directors/…            （7 个分层子目录、共 28 个 Agent）
│       └── _template.md            ← 不含
└── （UE 项目自身内容）
```

### 3.2 验证

1. **重启 opencode**（配置与 Agent 仅在启动时加载，运行中的会话不热加载）。
2. 在命令行输入 `/agents`（或对应版本的 agent 列表命令），确认 28 个 Agent 均已列出：
   `orchestration-director`、`game-director`、`technical-director`、`game-producer`、`audiovisual-director`、5 个 `academic-*`、`lead-game-balance-designer`、`lead-game-economy-designer`、`level-mission-designer`、`ue-core-systems-engineer`、`ue-gameplay-engineer`、`game-ai-engineer`、`ue-world-builder`、`character-animation-engineer`、`ue-ui-engineer`、`ue-technical-art-engineer`、`game-audio-technical-specialist`、`ue-tools-pipeline-engineer`、`performance-profiler`、`ue-build-engineer`、`game-asset-production-manager`、`game-visual-asset-artist`、`asset-compliance-auditor`、`qa-test-specialist`。
3. 向 `orchestration-director` 委托一个与项目相关的任务，验证其能读取实际阵容并正确路由。

## 4. 使用要点

- 从 `orchestration-director`（总控编排）进入协作流程，由它决定单 Agent 路由或多 Agent 编排。
- 各 Agent 默认 `"*": deny` 的权限收窄模式：只读、委派类 Agent 不可编辑、执行命令或联网；实施类 Agent 拥有受限的 `edit`/`bash` 权限。不要为省事把权限改为 `"*": allow`。
- 二进制 `.uasset` 只能通过 UE Editor、Editor API、Editor Utility 或 Commandlet 修改，禁止文本或字节补丁；编辑器/DCC 不可用时必须返回 `BLOCKED_TOOLING`。
- 新增 Agent 时以 `_template.md` 为模板，保持 `mode: subagent`、英文 kebab-case ID、中文正文，且先展示设计取得用户确认后再落盘。

## 5. 升级

重新从成品目录复制对应的 `.md` 文件覆盖目标位置即可；升级后重启 opencode。若某 Agent 已不再部署，从 `.opencode/agent/` 移除对应文件。

## 6. 卸载

1. 删除 `<目标项目>/.opencode/agent/`（若与既有 Agent 混装，只删除来自本成品的文件）。
2. 重启 opencode 后，相关 Agent 即从列表消失。

## 7. 注意事项

- 不复制 `_template.md`，否则会注册一个空占位 Agent。
- `docs/` 不随安装部署，仅保留在成品目录作参考；需要时按需从成品目录读取原文，不在目标项目落地。
- 不要在安装时改写 Agent 的 frontmatter 或正文，除非目标项目有明确的治理修订需求；所有修订须按既有「先设计、后确认、再落盘」流程进行。
- 成品目录自身的 `docs/session-handoff.md` 记录了 4 项待修订治理问题（人类学家权限过宽、制作人范围超界、注册表缺失、真实工具能力待验证）。Agent 已按当前边界编写，使用中如触及上述边界应回成品仓库按既有流程修订，不得在现场临时放宽权限。