# SEA / UEGameStudio 仓库安装与升级

本文件说明仓库级 SEA 自进化运行时的接入。可安装的 UE Game Studio agents/skills
是独立成品包，其安装入口见 `UEGameStudio/INSTALL.md`；不要把两套安装边界混在一起。

## 前置条件

- Python 3.10+；
- Git；
- OpenCode 稳定版配置格式。当前兼容边界见
  `UEGameStudio/docs/platform-compatibility.md`；OpenCode V2 配置格式不同，未转换前
  fail-closed；
- Python 依赖：

```powershell
python -m pip install -r SEA/requirements.txt
```

## 在本仓库运行 SEA

仓库根的 `AGENTS.md` 已注入纪律，`SEA/` 保存脚本、注册表、模板和记忆。首次使用先跑：

```powershell
python SEA/scripts/framework-version.py --check
python SEA/scripts/validate-memory.py
python SEA/scripts/validate-agent-improvements.py
python SEA/scripts/validate-topology.py
python SEA/scripts/validate-skill.py --skills-dir UEGameStudio/skills
```

需要评测或修改技能时，按 `SEA/EVOLUTION.md` 的 v2 两阶段协议执行。不要把
`--emit` 生成请求视为通过；只有逐断言回执通过、供应链审计通过并经 HITL 批准后
才能 solidify。

## 接入另一个工作区

1. 在目标工作区建立分支或其他可回滚快照。
2. 将本仓库 `SEA/` 复制到目标工作区的 `SEA/`。
3. 将根 `AGENTS.md` 作为目标工作区规则合并；若目标已有规则，人工合并，不要静默覆盖。
4. 将根 `VERSION` 与 `SEA/VERSION` 一并复制并保持一致。
5. 技能按目标环境选择工作区根 `.opencode/skills/` 或全局根
   `~/.config/opencode/skills/`；UEGameStudio 成品请使用其 manifest 驱动安装器。
6. 运行上一节全部 validator，并检查目标工作区：

```powershell
python SEA/scripts/framework-version.py --installed '<目标工作区>'
```

SEA 不提供递归删除或“强制覆盖整个配置根”的安装命令。目标工作区可能有自有
agents、skills 和规则，升级必须以 diff 为基础。

## 框架升级

1. 阅读 `SEA/CHANGELOG.md`；`[BREAKING]` 版本必须先在临时分支验证。
2. 对比并同步 `SEA/`、`AGENTS.md`、根 `VERSION`。
3. 重新安装 `SEA/requirements.txt`。
4. 运行 `framework-version.py --check` 及全部相关 validator/test。
5. 对 pending 候选重新生成 v2 judge 请求；旧请求的哈希快照不得跨版本复用。
6. 验证通过后提交，保留可回滚点。

## 卸载

SEA 没有自动卸载器。根据最初接入 diff，逐项移除仅由 SEA 引入的文件；若
`AGENTS.md`、技能或记忆已与项目内容合并，应人工反向合并，不得删除整个工作区或
`.opencode` 目录。
