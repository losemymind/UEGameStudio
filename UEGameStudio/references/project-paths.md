# project-paths.md — 项目路径与结构约定（单一事实源）

> 本文件定义本项目工作流的**路径约定**。通用技能（gate/review/readiness/pipeline/authoring/analysis/team/sprint/utility 下引擎无关部分）引用的 `src/`、`assets/`、`tests/`、`design/`、`production/` 等为**项目级约定路径**（工作室工作流结构）；落到具体引擎时按下表映射。安装到 UE 项目后，agent 必须按本表定位真实目录，不得照搬抽象路径去 Glob。
>
> 引擎专属源码路径的强制规则见 `rules/`（UE 风格 `Source/<GameModule>/`）。

## 一、项目文档约定（工作室工作流，引擎无关，项目内固定）

| 约定路径 | 内容 | 对应技能 |
|---|---|---|
| `design/gdd/` | GDD（game-concept.md / systems-index.md / 各系统 GDD） | design-system 等 |
| `design/registry/entities.yaml` | 跨系统实体注册表 | consistency-check / systems-designer |
| `design/ux/` | UX/HUD/交互模式库 | ux-design / team-ui |
| `design/art/` | art-bible / 资产规格 | art-bible |
| `design/levels/`、`design/audio/`、`design/live-ops/` | 关卡/音频/运营文档（团队协作类 skill 按需使用） | team-level |
| `production/` | stage.txt / review-mode.txt / sprints / milestones / qa / security | gate-check / sprint-* / bug-* |
| `docs/architecture/` | ADR | create-architecture / architecture-decision |
| `docs/technical-preferences.md` | 引擎/命名/性能预算/测试框架偏好（项目级） | setup-engine / smoke-check / dev-story 等 |

> 落地时允许在项目根保留这些目录名，或按项目已有结构等价映射（如 `Docs/Design/`），但**必须在 AGENTS.md 或本文件的项目副本中记录映射**，供所有技能读取。

## 二、通用代码路径 → UE 映射

| 通用约定路径（技能正文） | UE 项目实际路径 |
|---|---|
| `src/`（源码） | `Source/<GameModule>/`（如 `Source/MyGame/`） |
| `src/gameplay/`、`src/ai/` 等 | `Source/<GameModule>/Gameplay/`、`.../AI/`（见 `rules/` 目录） |
| `assets/`（美术/音频/VFX/着色器/数据） | `Content/`（虚拟路径 `/Game/`）；对应子目录 `Content/Art|Audio|VFX|Shaders|Data/` |
| `assets/data/` | `Content/Data/`（DataTable / DataAsset / 配置） |
| `assets/shaders/` | `Content/Shaders/` 或 `Source/<GameModule>/Shaders/`（USF/USH） |
| `tests/` | 测试代码 `Source/**/Tests/`（UE Automation）；测试清单文档 `tests/`（项目约定，保留） |
| `tests/unit/`、`tests/integration/`、`tests/smoke/` | 文档/清单：`tests/` 下保留；测试代码：`Source/**/Tests/` |
| `tests/helpers/` | `Source/**/Tests/`（辅助宏/工厂）；文档模板可保留 `tests/helpers/` |
| `prototypes/` | `Prototypes/`（独立于 `Source/` 与 `Content/`） |
| `docs/`（通用文档） | 项目根 `docs/` 保留 |
| `CLAUDE.md`（旧引用，已废弃） | `AGENTS.md`（opencode 项目级指令） |

## 三、平台说明

- 本项目目标平台为 **opencode / OpenWork**：项目级指令文件是 `AGENTS.md`，不是 Claude Code 的 `CLAUDE.md`；技术偏好文件统一为 `docs/technical-preferences.md`（无 `.claude/` 前缀）。
- 引擎专属 agent（`agents/engine/unreal/*`）版本纪律先读 `docs/engine-reference/unreal/VERSION.md`。

## 维护

新增技能/agent 引用路径前，先查本表：约定路径写入项目文档约定列，UE 实际路径写入映射列；引擎无关路径（文档）不加映射行。本文件被全部引擎无关技能引用，改动需同步 `references/README.md`。
