# UE Game Studio 安装指南

本指南适用于成品版本 `0.6.0`。

本包当前包含 53 个 agents、52 个 skills，以及 `docs/`、`references/`、`rules/` 全部共享依赖。安装内容只由 manifest schema v2 决定；Agent 条目同时声明 scope、engine dependency、evaluation profile 和 integration owner。这些路径都相对 opencode 配置根，而不是游戏项目根。

## 前置条件

- PowerShell 7+（脚本使用 `System.IO.Path.GetRelativePath`）；
- 已安装使用 stable V1 `permission/bash/task` Markdown agent schema 的 OpenCode；
- 项目安装需提供项目根目录，全局安装默认使用 `$env:USERPROFILE\.config\opencode`。

OpenCode V2 使用 `permissions/shell/subagent`，本包尚未生成或验证 V2 变体，安装到 V2 必须停止而不是猜测转换。OpenWork 只有在宿主提供与 stable V1 等价的权威 schema 且完成独立 smoke test 后才可使用；本包不做笼统兼容承诺。详见 `docs/platform-compatibility.md`。

## 项目级安装

在本包根目录运行：

```powershell
& .\scripts\validate-package.ps1
& .\scripts\install.ps1 -Scope Project -ProjectRoot 'E:\Projects\MyGame'
```

默认目标为 `<ProjectRoot>\.opencode`。如平台使用其他配置根，可显式覆盖：

```powershell
& .\scripts\install.ps1 -Scope Project -DestinationRoot 'E:\Projects\MyGame\.custom-opencode'
```

## 全局安装

```powershell
& .\scripts\validate-package.ps1
& .\scripts\install.ps1 -Scope Global
```

显式目标示例：

```powershell
& .\scripts\install.ps1 -Scope Global -DestinationRoot 'D:\Shared\opencode'
```

可先预览而不写盘：

```powershell
& .\scripts\install.ps1 -Scope Project -ProjectRoot 'E:\Projects\MyGame' -WhatIf
```

安装器的 `-PlatformSchema` 当前只接受 `OpenCodeStableV1`。这是一道 fail-closed 门；不能用参数绕过为 V2 或其他宿主安装同一份 frontmatter。

## 安装布局

安装器按规范 ID 展平 agents 与 skills，避免分类目录成为运行时 ID 的一部分；共享依赖保留相对结构：

| 包内容 | 目标 |
|---|---|
| `agents/<category>/<id>.md` | `<target>/agents/<id>.md` |
| skill 的 `SKILL.md`、`test-prompts.json` | `<target>/skills/<id>/` |
| `docs/**` | `<target>/docs/**` |
| `references/**` | `<target>/references/**` |
| `rules/**` | `<target>/rules/**` |
| `VERSION`、manifest、provenance | `<target>/.ue-game-studio/` |

这里的 `<target>` 始终是 **opencode 配置根**：项目级默认为 `<project>/.opencode`，全局默认为 `~/.config/opencode`。包内共享文档应从 `<target>/docs/` 读取。

工作流运行时创建的项目文档则始终相对 **游戏项目根**，例如 `<project>/docs/architecture/`、`<project>/design/` 与 `<project>/production/`。这些不是包共享资产，安装器不会创建或覆盖它们。若项目根也有 `docs/`，不得将其与 `<project>/.opencode/docs/` 混为一谈；agent/skill 必须先解析相应根目录再读取或写入。

`agents/_template.md` 明确排除，绝不会成为可调用 agent。`skills/_evolutions/evolutions.json` 默认排除；只有目标环境已启用 SEA 兼容演进流程时才使用：

```powershell
& .\scripts\install.ps1 -Scope Project -ProjectRoot 'E:\Projects\MyGame' -IncludeEvolutionRegistry
```

## 安装后验证

1. 确认 `<target>/.ue-game-studio/manifest.json` 存在。
2. 确认 `<target>/agents/technical-director.md` 与 `<target>/skills/start/SKILL.md` 存在。
3. 确认 `<target>/agents/_template.md` 不存在。
4. 确认 `<target>/docs/engine-reference/unreal/VERSION.md`、`references/project-paths.md`、`rules/ue-engine-code.md` 存在。
5. 重启 opencode，调用 `technical-director` 或触发 `start` 技能完成加载验证。

## 升级

升级前先备份本地自定义。运行新包的 validator 后，用相同目标再次执行安装器即可覆盖 manifest 中的同名资产。

manifest 驱动安装不会自动删除已从新版本移除的旧资产。若需严格同步，请先根据目标 `.ue-game-studio/manifest.json` 识别旧版资产并备份/移除，再安装新版本；不要递归删除整个 `.opencode`，其中可能包含用户资产。

## 卸载

根据 `<target>/.ue-game-studio/manifest.json` 删除该包登记的 agent 文件、skill 目录和共享依赖。卸载前检查目标文件是否被用户修改或被其他包共用。安装器不提供自动删除命令，避免误删项目自己的 `docs/`、`references/` 或 `rules/`。

## 故障排查

- `manifest asset is missing`：包不完整或 manifest 未同步；先运行 validator。
- `Project installs require...`：传入 `-ProjectRoot` 或 `-DestinationRoot`。
- 资源已复制但未加载：确认平台配置根是否正确并重启加载器。
- package-relative 引用告警：运行 `validate-package.ps1 -StrictReferences` 获取阻断结果，再修正引用或补齐 manifest 资产。
