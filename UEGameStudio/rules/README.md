# rules/ — UE 路径作用域编码规则

> 本目录存放**路径作用域编码标准**：按源码路径自动生效的强制规则，来自 Claude-Code-Game-Studios 的 11 条规则（DISTILLED-CATALOG §3.3），适配 UE 项目后为 10 条。
>
> 机制：规则绑定到路径 glob，凡落入该路径的代码/文档必须遵守；违反即视为可观察的质量信号。安装到项目后可作为 opencode rules 或 SEA 校验脚本的输入。

## 规则清单

| 规则 | 路径作用域（UE 风格） | 核心强制 |
|---|---|---|
| `ue-gameplay-code` | `Source/<GameModule>/Gameplay/**` | 数值全配置化、全 delta time、禁直接引用 UI、禁静态单例 |
| `ue-engine-code` | `Source/<GameModule>/Core/**` | 热路径零分配、引擎不依赖 gameplay、API 变更需弃用期 |
| `ue-ai-code` | `Source/<GameModule>/AI/**` | AI 预算 ≤2ms/帧、参数数据文件可调、可视化调试钩子、意图预告 |
| `ue-network-code` | `Source/<GameModule>/Network/**` | 服务器权威、消息版本化、预测回滚、带宽预算 |
| `ue-ui-code` | `Source/<GameModule>/UI/**` + `Content/UI/**` | UI 不拥有游戏状态、全本地化、键鼠+手柄双支持 |
| `ue-design-docs` | `Docs/Design/GDD/**` | GDD 8 必节、公式四要素、AC 可测试、增量撰写 |
| `ue-shader-code` | `Shaders/**` + `Content/Shaders/**` | 命名规范、禁 magic number、half 精度、禁循环内读纹理 |
| `ue-test-standards` | `Source/**/Tests/**` | 命名规范、AAA、每个 bug 修复必须有回归测试 |
| `ue-prototype-code` | `Prototypes/**` | 标准放宽、隔离、README、成功后重写而非迁移 |
| `ue-data-files` | `Content/Data/**` | 数据合法性阻断构建、命名、文档化 schema、版本化 |

## UE 路径约定说明

- **C++ 代码**：模块根 `Source/<GameModule>/`（PascalCase），模块内按功能子目录组织（`Gameplay/`、`AI/`、`Network/`、`UI/`、`Core/` 等）。
- **资产（Content）**：物理路径 `Content/...`，对应虚拟路径 `/Game/...`；UMG 蓝图 → `Content/UI/`，DataTable/DataAsset → `Content/Data/`。
- **着色器**：模块级 USF/USH 放 `Source/<GameModule>/Shaders/` 或 `Content/Shaders/`。
- **自动化测试**：`IMPLEMENT_SIMPLE_AUTOMATION_TEST` 放 `Source/<GameModule>/Tests/` 或独立 `<GameModule>.Tests` 模块。

## 说明

- 每条规则一个 `.md` 文件，内容 = 强制要点 + 反例（违规信号）。
- 引擎专属的命名/API 细节以 `docs/engine-reference/unreal/VERSION.md` 锚定版本为准（先核实再断言）。
- 来源：Claude-Code-Game-Studios 路径作用域规则，蒸馏基准见仓库根 `DISTILLED-REFERENCE.md` §6.3。
