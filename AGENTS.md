# AGENTS.md — UEGameStudio 仓库指南

## 项目定位

本仓库**不包含游戏代码**，其产品是：面向 **UE 游戏项目开发**的 opencode Agent 成品包（用于生成可在目标 UE 项目中直接安装使用的 subagent 阵容与治理文档）。目标 LLM 客户端为 opencode。

## 目录结构

```
E:\GitHub\UEGameStudio\
├── UEGameStudio\          ← 成品目录（自包含，可独立安装）
│   ├── agents\            ← 28 个 opencode subagent（按 7 个分层子目录组织）
│   │   ├── orchestration\   总控编排专家（工作流引擎，建议入口）
│   │   ├── directors\       游戏总设计师、技术总监、游戏制作人、视听总监
│   │   ├── academic\        人类学家、地理学家、历史学家、叙事学家、心理学家
│   │   ├── design\          数值、经济、关卡与任务设计
│   │   ├── technical\       UE 核心系统、Gameplay、AI、世界构建、动画、UI、技术美术、音频、工具管线、性能、构建
│   │   ├── production\      资产生产管理、视觉资产制作
│   │   ├── qa\              资产合规审计、QA 测试
│   │   └── _template.md     新 Agent 编写模板（不安装）
│   ├── docs\               治理文档（不随安装部署，仅作参考）
│   │   ├── session-handoff.md
│   │   └── agent-roster-report.md
│   └── INSTALL.md          安装到目标项目的标准流程
└── AGENTS.md               ← 本文件
```

## 蒸馏来源

本仓库中的 agents 与 skills 通过总结提取与蒸馏以下仓库形成：

- <https://github.com/addyosmani/agent-skills>
- <https://github.com/msitarzewski/agency-agents>
- <https://github.com/Donchitos/Claude-Code-Game-Studios>
- <https://github.com/jnMetaCode/agency-agents-zh>

**注意**：成品目录 `UEGameStudio/` 已作自包含处理，其中不保留上述来源仓库的名称与链接；本文件恢复来源信息仅供仓库维护参考，不要将其写回成品目录内部。

## 治理规范（在本仓库作业时必须遵守）

1. **先设计、确认后落盘**：新增、合并或修订任何 Agent 前，先展示分析、职责边界与设计，取得用户明确确认（用户说"落盘"）后才写文件。
2. **Agent 规范**：全部 `mode: subagent`；英文 kebab-case ID；正文中文，保持专业工业级风格。
3. **权限收窄**：agent frontmatter 默认 `"*": deny`，只显式放开最小必要能力；不把权限改为 `"*": allow`。
4. **三权分离**：决策、实施与独立验证保持分离，不合并职责边界。
5. **`.uasset` 安全**：二进制资产只能通过 UE Editor、Editor API、Editor Utility 或 Commandlet 修改，禁止文本/字节补丁；编辑器或 DCC 不可用时必须返回 `BLOCKED_TOOLING`，不得声称二进制资产已完成。
6. **实际阵容为准**：作业前先读 `docs/session-handoff.md` 与 `docs/agent-roster-report.md`，并扫描 `agents/` 实际文件；不依据 git 删除记录或历史推测当前阵容，不恢复已删除的旧 Agent。
7. **Git 安全**：不执行 `git reset --hard`、`git checkout --`，不把 git 历史中被删除的 Agent 重新纳入成品。

## 常用入口

- 会话交接 / 下个会话启动要求：`UEGameStudio/docs/session-handoff.md`
- 阵容与权限报告：`UEGameStudio/docs/agent-roster-report.md`
- 成品安装到目标项目：`UEGameStudio/INSTALL.md`
- 新 Agent 编写模板：`UEGameStudio/agents/_template.md`