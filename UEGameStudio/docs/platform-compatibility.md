# OpenCode 平台兼容性锚点

- `verified_on`: 2026-08-24
- `package_target`: OpenCode stable 文档所描述的 Markdown agent schema（本包内部简称 **stable V1**）
- `opencode_v2`: **unsupported / fail-closed**
- `openwork`: 仅当宿主明确实现与 OpenCode stable V1 等价的 Markdown agent 与权限语义时，才可在独立验证后使用

## 已核实契约

OpenCode stable 文档使用：

- Markdown agent 的 `permission:` 映射；
- shell 工具权限键 `bash`；
- 子 agent 调度权限键 `task`，可用 `permission.task` 的 glob 白名单；
- 大多数权限在未配置时默认 `allow`，因此本包要求每个 agent 先以顶层 `"*": deny` 收紧，再显式开放最小能力。

OpenCode V2 文档改为：

- `permissions:` 有序规则数组；
- shell action 名为 `shell`；
- 子 agent action/tool 名为 `subagent`；
- last matching rule wins，且 V2 自定义 agent 仍从较宽的默认权限开始。

两套字段与权限表示法不兼容。本包 agent 目前没有完成 V2 schema 转换、白名单等价证明与安装烟测，因此 V2 加载必须 fail-closed：不得自动改名字段、不得假定旧 `permission/bash/task` 会被 V2 等价解释、不得声明 V2 兼容。

## 官方来源

- [OpenCode stable Agents](https://opencode.ai/docs/agents/)
- [OpenCode stable Permissions](https://opencode.ai/docs/permissions/)
- [OpenCode V2 Agents](https://opencode.ai/v2/docs/agents)
- [OpenCode V2 Permissions](https://opencode.ai/v2/docs/permissions)

## 重新核实触发器

以下任一情况发生时，必须重新读取上述官方文档并更新 `verified_on`：

- stable 或 V2 agent frontmatter/schema 发生变化；
- 权限默认值、匹配顺序、shell/task/subagent 命名发生变化；
- 本包开始生成 V2 变体；
- OpenWork 声明兼容但未提供与上述 schema 对应的权威版本文档。
