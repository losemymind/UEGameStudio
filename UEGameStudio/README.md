# UE Game Studio — Agents & Skills

面向 Unreal Engine 游戏全生命周期的 OpenCode 可安装资产包。当前成品版本为 `0.6.0`（以 `VERSION` 为准）；`manifest.json` 是可安装 agents、skills 及其共享依赖的单一清单。

平台目标严格限定为 OpenCode **stable V1 Markdown agent schema**（`permission/bash/task`）。OpenCode V2 的 `permissions/shell/subagent` schema 尚未转换和验证，必须 fail-closed；不声明任意 OpenWork 实现兼容。核实依据见 `docs/platform-compatibility.md`。

## 当前资产

| 类型 | 数量 | 说明 |
|---|---:|---|
| Agents | 53 | manifest schema v2 明示 general/game/unreal/integration 四层及 engine dependency；Academic 属通用层 |
| Skills | 52 | onboarding、design、architecture、planning、dev、operations、review、qa、release、production、team、perf |
| Docs | 8 | 工作流目录、平台兼容性锚点与 UE 版本化参考集 |
| References | 5 | 路径规范与 GDD/ADR/关卡模板 |
| Rules | 11 | README 加 10 条 UE 路径作用域规则 |

准确文件、规范 ID、安装排除项和计数见 `manifest.json`。不要在 README 中维护第二份逐文件清单。

## 安装

项目级安装：

```powershell
& .\scripts\install.ps1 -Scope Project -ProjectRoot 'E:\Projects\MyGame'
```

全局安装：

```powershell
& .\scripts\install.ps1 -Scope Global
```

安装器由 manifest 驱动，将 agent/skill 展平到规范 ID，并保留 `docs/`、`references/`、`rules/` 相对 **opencode 配置根**的结构。`agents/_template.md` 永不安装；技能演进注册表默认不安装。完整参数、升级与卸载说明见 `INSTALL.md`。

## 发布前验证

```powershell
& .\scripts\validate-package.ps1
```

验证器检查：

- manifest 计数、路径和磁盘资产是否一一对应；
- agent/skill frontmatter 与规范 ID；
- 悬空 skill 命令和可识别的 agent 引用；
- `CLAUDE.md`、`AskUserQuestion`、Claude `Task` 等旧平台残留；
- package-relative 文件引用（尽力检查；可用 `-StrictReferences` 提升为阻断）；
- 安装排除项，尤其是 `agents/_template.md`。

## 自包含边界

运行所需共享知识随包安装：

```text
<opencode-root>/
├── agents/                 # 53 个规范 ID 文件
├── skills/                 # 52 个规范 ID 目录
├── docs/                   # 工作流与 UE 版本锚点
├── references/             # 跨 agent/skill 的共享参考
├── rules/                  # UE 路径作用域规则
└── .ue-game-studio/        # VERSION、manifest、provenance
```

SEA 自进化运行时是可选开发基础设施，不是本资产包的运行依赖。

### 两类路径不可混用

- **包共享资产**：相对 opencode 配置根解析。项目安装时配置根是 `<project>/.opencode`；全局安装时默认是 `~/.config/opencode`。例如包版本锚点是 `<config-root>/docs/engine-reference/unreal/VERSION.md`，不是 `<project>/docs/...`。
- **游戏项目产物**：相对游戏项目根解析。例如工作流生成的 `<project>/docs/architecture/`、`<project>/design/`、`<project>/production/` 不属于安装包，也不登记到 manifest。

Agent/skill 在读取共享资产前必须先解析当前 opencode 配置根；写入工作流产物前必须解析游戏项目根。不得把两个根目录下同名的 `docs/` 合并、互相覆盖或依赖当前工作目录猜测。

`agents/academic/` 是明确的通用层：定义只包含学科方法、证据纪律和专业边界。UE Studio 可把当前游戏任务作为调用上下文传入，但不得让这些 Agent 依赖 Unreal 版本锚点、UE 专用术语或特定编排器。

### Agent 四层契约

| evaluation_profile | scope | engine_dependency | 约束 |
|---|---|---|---|
| `general-core` | `general` | `none` | 通用学术、组织、工程和质量能力；禁止 UE 与集成层反向依赖 |
| `game-core` | `game` | `none` | 引擎无关的游戏制作能力；UE 只可作为调用上下文，不进入定义 |
| `unreal-specialist` | `unreal` | `required` | 只承载 UE API、编辑器、构建、内容管线与版本敏感实现 |
| `integration` | `integration` | `required` | 仅 `ue-studio-orchestrator`；单向组合全部叶子 Agent |

分类以 `manifest.json` 为唯一事实源，不能通过目录名或 `ue-` 前缀猜测。Core 先定义意图、约束与验收标准；只有实现节点确实需要 Unreal 时，编排器才追加最小 UE specialist。

## 来源与可追溯性

`provenance.json` 记录四个来源仓库、已蒸馏能力和本地审查证据。未在本地记录的源 commit 明确为 `null`，不得根据日期或远端默认分支虚构 pin：

- addyosmani/agent-skills
- msitarzewski/agency-agents
- Donchitos/Claude-Code-Game-Studios
- jnMetaCode/agency-agents-zh

## 维护规则

新增、删除或移动 agent、skill、doc、reference、rule 时必须同步修改 `manifest.json`，随后运行 validator 和一次临时目录安装 smoke test。版本敏感 UE 事实以 `docs/engine-reference/unreal/VERSION.md` 的核实状态为准。
