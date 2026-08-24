# VERSION.md — Unreal Engine 版本锚定（单一事实源）

> 本文件是 `engine/unreal/*` agent「版本纪律」的单一事实源。断言任何 UE API、上限或能力前，必须先读本文件确认锚定版本；超出知识截止的内容显式标注 `may have changed — verify`，无法核实就明说。

## 锚定版本

| 项 | 值 | 说明 |
|---|---|---|
| Engine Version | **UNINITIALIZED** | 安装时必须从目标项目 `.uproject`、Engine Association 或用户确认取得；禁止用模板默认值代替 |
| Verified On | — | 初始化时填写 YYYY-MM-DD |
| Official Documentation | — | 初始化时填写与实际版本匹配的 Epic Developer Community URL |

## 核实状态

- [ ] 已从项目文件/安装环境取得实际 Engine Version
- [ ] 已记录匹配版本的 Epic 官方文档 URL 与核实日期
- [ ] 项目使用的插件（GAS/CommonUI/PCG/Iris 等）已逐项记录启用状态与版本

> 任一项未完成时，所有 UE 版本敏感结论均视为 `verified: false`。Agent 必须先请求版本或查项目文件并 fail-closed，不得继续给出精确 API/CVar/上限断言。

## 使用规则（对所有 engine/unreal/* agent 强制）

1. 断言 UE API / 上限 / 能力前，先读本文件确认版本；`UNINITIALIZED` 时立即停止事实型裁决。
2. 版本敏感内容必须链接到与项目版本匹配的 Epic 官方文档或项目源码位置；仅写 `may have changed` 不能替代核实。
3. 核实到的事实写入项目版本锚定事实记录（`verified: true` + 来源 + 版本）；失效事实标记 `deprecated` 并触发修订。
4. 每 90 天或引擎版本变更后做版本事实健康检查，发现逾期或未核实条目即修订。

## 支撑文件（渐进披露，按需创建/核实）

| 文件 | 内容 | 状态 |
|---|---|---|
| `current-best-practices.md` | 已核实实践的索引；仅收录带版本、日期、官方 URL 的条目 | 已初始化，随项目填充 |
| `breaking-changes.md` | 当前项目版本升级的破坏性变更记录 | 已初始化，默认无事实断言 |
| `deprecated-apis.md` | 当前项目实际命中的废弃 API 清单 | 已初始化，默认无事实断言 |
| `modules/performance.md` | Unreal Insights/Stat/平台实测的证据契约 | 已初始化 |
| `plugins/README.md` | GAS/CommonUI/PCG/Iris 等插件核实模板 | 已初始化 |

> 支撑文件未核实前不可断言其内容；先核实再断言（框架硬规则 7）。
