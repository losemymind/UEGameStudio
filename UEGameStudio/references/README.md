# references/ — 共享清单

本目录存放被多个 UE 技能/agent 引用的共享参考（渐进披露：技能 SKILL.md 是入口，此处按需加载，省 token）。

## 约定

- 命名：`lowercase-hyphen-separated.md`
- 一份清单只服务一类主题，避免复制漂移
- 技能通过相对路径引用（如 `../../references/definition-of-done.md`）

## 建议清单（按需创建）

| 文件 | 内容 | 被谁引用 |
|---|---|---|
| `definition-of-done.md` | 项目级完成标准（Correctness/Quality/Integration/Documentation/Ship-readiness） | design-system / code-review / release-checklist |
| `ue-naming-conventions.md` | UE 命名规范速查（A/U/F/E/I 前缀、BP_/BPI_/BPFL_ 前缀、变量 PascalCase） | ue-blueprint-specialist（agent）/ code-review |
| `ue-review-checklist.md` | 五轴 + UE 专项审查清单 | code-review |
| `ue-gate-artifacts.md` | 各阶段门的 Required Artifacts 清单 | gate-check |

> 当前版本暂未内置清单文件，先留目录与约定；首个共享清单随技能演进按需创建。
