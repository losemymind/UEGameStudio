# VERSION.md — Unreal Engine 版本锚定（单一事实源）

> 本文件是 `engine/unreal/*` agent「版本纪律」的单一事实源。断言任何 UE API、上限或能力前，必须先读本文件确认锚定版本；超出知识截止的内容显式标注 `may have changed — verify`，无法核实就明说。

## 锚定版本

| 项 | 值 | 说明 |
|---|---|---|
| Engine Version | **UE 5.7** | 参考业界 UE 项目常用版本锚定实践（2025-11 发布）。**安装后必须按项目实际引擎版本更新本行** |
| LLM 知识截止 | 2025-05 | 训练数据覆盖上限 |
| 知识缺口区间 | UE 5.4 – 5.7 | 该区间新增/变更的 API 超出训练数据，必须联网核实或标注未核实 |

## 核实状态

- [ ] 已按项目实际安装的引擎版本更新「Engine Version」
- [ ] 已确认知识缺口区间与实际引擎版本匹配

> 未完成核实的条目视为 `verified: false`，不得作为断言依据（先核实再断言）。

## 使用规则（对所有 engine/unreal/* agent 强制）

1. 断言 UE API / 上限 / 能力前，先读本文件确认版本。
2. 涉及 5.4–5.7 新 API 时，标注 `may have changed in [version] — verify`，或联网核实后写明来源。
3. 核实到的事实写入 `SEA/memory/verified_facts.yaml`（`verified: true` + 来源 + 版本）；失效事实标记 `deprecated` 并触发修订。
4. 每 90 天或引擎版本变更后跑 `python SEA/scripts/verify-versions.py` 检查逾期与未核实条目。

## 支撑文件（渐进披露，按需创建/核实）

| 文件 | 内容 | 状态 |
|---|---|---|
| `current-best-practices.md` | Nanite/Lumen/Substrate 选型、C++20、TObjectPtr GC 安全 | 待按锚定版本核实后填充 |
| `breaking-changes.md` | 锚定版本内的破坏性变更 | 待核实后填充 |
| `deprecated-apis.md` | 废弃 API 清单 | 待核实后填充 |
| `modules/` | 分模块（animation/audio/input/navigation/networking/physics/rendering/ui）版本验证要点 | 待按需创建 |
| `plugins/` | GAS / CommonUI / Gameplay Camera / PCG 等插件专页 | 待按需创建 |

> 支撑文件未核实前不可断言其内容；先核实再断言（框架硬规则 7）。
