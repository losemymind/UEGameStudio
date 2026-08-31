# UEGameStudio 成品安装说明（opencode）

## 1. 成品内容

本目录包含 30 个有效 Agent、项目级统一指令、正式项目验证方法和安装脚本：

| 路径 | 说明 |
| --- | --- |
| `AGENTS.md` | 安装后由目标项目 `opencode.json` 加载的 UEGameStudio 统一规则 |
| `agents/` | 30 个 `mode: subagent` 专业 Agent；`_template.md` 不安装 |
| `docs/formal-project-validation.md` | 正式 UE 项目中的完整实测、故障注入和自动修复方法 |
| `scripts/install.ps1` | 幂等安装/升级脚本，复制 Agent 并安全合并 `opencode.json` |
| `scripts/test-install.ps1` | 安装器的隔离回归测试 |
| `docs/session-handoff.md` | 成品仓库会话交接参考，不部署到目标项目 |
| `docs/agent-roster-report.md` | 当前 Agent 阵容报告，不部署到目标项目 |

项目范围严格截止于本地 UE 游戏构建包，不包含商店提交、平台认证、正式发布、部署或 LiveOps。

## 2. 前置条件

- 已安装 opencode，并已配置可用的 LLM 供应商。
- 目标目录是正式 UE 项目根目录，通常直接包含 `.uproject`。
- 对目标项目有写入 `.opencode/`、`UEGameStudio/` 和 `opencode.json` 的权限。
- 建议先提交或备份目标项目现有修改。

OpenCode 启动时会自动发现并加载工作目录/项目根的 `AGENTS.md`，因此它不需要出现在 `instructions`。安装器不会创建、修改或删除目标项目根 `AGENTS.md`，只追加无法通过根目录自动发现的 `UEGameStudio/AGENTS.md`。

## 3. 推荐安装

在成品仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\install.ps1 `
  -TargetProject "E:\Path\To\YourUnrealProject"
```

安装器会：

1. 将 30 个 Agent 复制到 `<目标项目>/.opencode/agent/`，排除 `_template.md`。
2. 复制 `AGENTS.md` 到 `<目标项目>/UEGameStudio/AGENTS.md`。
3. 复制验证方法到 `<目标项目>/UEGameStudio/docs/formal-project-validation.md`。
4. 解析并保留目标工程已有 `opencode.json` 配置。
5. 幂等加入 `UEGameStudio/AGENTS.md`，不产生重复项；根 `AGENTS.md` 继续由 OpenCode 自动加载。
6. 修改已有配置前创建 `opencode.json.uegamestudio-<时间>.bak`。

如果目标目录暂时没有 `.uproject`，只有在明确的安装测试中使用：

```powershell
.\UEGameStudio\scripts\install.ps1 -TargetProject "<目录>" -AllowMissingUProject
```

正式项目不建议跳过 `.uproject` 检查。

## 4. `opencode.json` 结果

目标项目根 `AGENTS.md` 由 OpenCode 自动加载，`opencode.json` 只需显式加入 UEGameStudio 的嵌套规则：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "UEGameStudio/AGENTS.md"
  ]
}
```

若目标工程已有 provider、model、permission、MCP 或其他 instruction，安装器会全部保留，只追加 `UEGameStudio/AGENTS.md`。若没有 `opencode.json`，上面就是安装器创建的最小配置。

安装器不会把 `AGENTS.md` 写入 `instructions`；即使目标根目录存在该文件，它也由 OpenCode 默认发现机制加载。

注意：JSON 中应使用真实 URL `https://opencode.ai/config.json`，不能写成 Markdown 链接语法。

## 5. 手动安装

如不使用脚本：

1. 将 `agents/` 的子目录复制到 `<目标项目>/.opencode/agent/`，排除 `_template.md`。
2. 将本目录 `AGENTS.md` 复制到 `<目标项目>/UEGameStudio/AGENTS.md`。
3. 将 `docs/formal-project-validation.md` 复制到 `<目标项目>/UEGameStudio/docs/`。
4. 备份并人工合并目标 `opencode.json`，保留全部现有 instruction，仅追加 `UEGameStudio/AGENTS.md`。

不要直接用示例 JSON 覆盖已有 `opencode.json`，否则可能丢失 provider、权限或其他项目配置。

## 6. 安装验证

### 6.1 安装器回归

```powershell
powershell -ExecutionPolicy Bypass -File .\UEGameStudio\scripts\test-install.ps1
```

该测试在系统临时目录建立隔离目标，验证：

- 已有 `opencode.json` 属性被保留。
- 30 个 Agent 被复制且 `_template.md` 被排除。
- 目标项目根 `AGENTS.md` 内容保持不变，且不会被安装器注入 `instructions`。
- 新建配置只加入 `UEGameStudio/AGENTS.md`。
- `UEGameStudio/AGENTS.md` 和正式项目验证方法被部署。
- 连续执行两次结果保持幂等。

### 6.2 目标项目验证

1. 打开目标 `opencode.json`，确认已有配置仍在。
2. 确认 `instructions` 包含且只包含一份 `UEGameStudio/AGENTS.md`，没有由安装器新增的 `AGENTS.md`。
3. 确认 `.opencode/agent/` 有 30 个 Agent，不含 `_template.md`。
4. 重启 opencode，使配置和 Agent 重新加载。
5. 使用 `/agents` 或当前版本等价命令确认阵容。
6. 向 `orchestration-director` 提交一个只读项目发现任务，验证它读取两层 AGENTS 指令并执行最小充分路由。

## 7. 正式项目实测与自动修复

安装后先读取：

```text
<目标项目>/UEGameStudio/docs/formal-project-validation.md
```

正式实测应直接在目标工程及其可恢复分支、工作树或副本中进行。发现缺失或缺陷时，Agent 默认按 `AGENTS.md` 建立“复现 → 指定唯一所有者 → 最小修复 → 原用例复测 → 受影响回归”的自动修复闭环；涉及产品/架构裁决、未授权路径、许可证、凭据或不可恢复操作时必须暂停请求用户确认。

## 8. 升级

重新执行 `install.ps1` 即可：

- 同名 Agent、UEGameStudio 指令和验证方法会被更新。
- `instructions` 不会重复。
- 已有项目配置会保留。
- 安装器不会自动删除成品中已经移除的旧 Agent；升级前后应比较实际安装 manifest，明确批准后再删除陈旧文件。

升级后重启 opencode。

## 9. 卸载

1. 从 `.opencode/agent/` 只删除由 UEGameStudio 安装的 Agent 文件；不要清理用户自有 Agent。
2. 删除 `<目标项目>/UEGameStudio/AGENTS.md` 和部署的验证方法。
3. 从 `opencode.json.instructions` 删除 `UEGameStudio/AGENTS.md`；项目根 `AGENTS.md` 是否保留由项目自行决定。
4. 重启 opencode。

## 10. 安全要求

- 不要为方便把所有 Agent 权限改成 `"*": allow`。
- 不要在安装现场修改 Agent frontmatter 或放宽专业边界。
- `.uasset`、`.umap` 只能通过 UE Editor 或受控自动化修改。
- 不恢复 Git 已删除的旧 Agent，不清理目标项目已有变更。
- 缺工具或输入时返回对应 `BLOCKED_*`，不得伪造实施或验证结果。
