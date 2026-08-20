---
name: ux-design
description: 逐节引导撰写屏幕/流程/HUD 的 UX 规格——读取游戏概念、玩家旅程与相关 GDD，产出 ux-spec.md 或 hud-design.md。Use when：设计某个屏幕、HUD 或交互模式库时。
---

# UX 规格设计

## 何时使用
- 设计一个屏幕或流程（`/ux-design [screen-name]`）
- 设计游戏 HUD（`/ux-design hud`）或交互模式库（`/ux-design patterns`）
- 三种模式输出：`design/ux/[name].md`、`design/ux/hud.md`、`design/ux/interaction-patterns.md`

## 流程
### 1. 解析参数与模式
1. 按参数确定模式；无参数则 AskUserQuestion 询问设计对象
2. 屏幕名归一化为 kebab-case

### 2. 收集上下文（先读再问）
1. 读 `game-concept.md`（缺失则警告）、`player-journey.md`（缺失则记到 Open Questions）
2. Glob GDD 的 UI Requirements 节，作为本规格的需求输入（HUD 需读全部系统的）
3. 读既有 `design/ux/*.md` 的导航/流程节、交互模式库目录、art-bible 视觉方向、无障碍需求、`docs/technical-preferences.md` 的输入与平台
4. 呈现上下文摘要，问是否还有要读的

### 3. 创建文件骨架
1. 检测 retrofit 模式（目标文件已存在则只补空/占位节）
2. 立即创建含空节标题的骨架，问"May I create the skeleton?"

### 4. 逐节撰写（每节循环 Context→Questions→Options→Decision→Draft→Approval→Write）
1. **UX Spec 模式**：Purpose & Player Need → Player Context on Arrival → Navigation Position → Entry & Exit Points → Layout（信息层级/布局分区/组件清单/ASCII 线框）→ States & Variants → Interaction Map → Events Fired → Transitions & Animations → Data Requirements → Accessibility → Localization → Acceptance Criteria
2. **HUD 模式**：HUD Philosophy → Information Architecture（全量清单 + Must Show/Contextual/On Demand/Hidden 分类）→ Layout Zones → HUD Elements → Dynamic Behaviors / Platform Variants / Accessibility
3. **Pattern Library 模式**：先盘点现有模式 → 逐一形式化（When to Use / When NOT to Use）→ 识别缺口

### 5. 交叉引用检查
1. GDD 需求覆盖、模式库对齐、导航一致性、无障碍覆盖、空状态，逐项呈现

### 6. 交接
更新会话状态；提示必须先 `/ux-review`；建议下一步

## 输入/输出
- 输入：game-concept、player-journey、GDD UI Requirements、既有 UX 规格、模式库、art-bible、无障碍文档、输入平台配置
- 输出：`design/ux/[filename].md`（或 hud.md / interaction-patterns.md）

## 约束
- 审美归用户：布局/视觉选择时呈现选项并确认，不以"标准"为由自选
- GDD 需求与屏幕空间冲突时，surface 冲突并给方案，绝不默默丢弃需求或扩张布局
- 每节草稿需批准；交互映射用 tech-prefs 里的输入方法，不反复询问
- 强制 ≥5 条可测验收标准，至少覆盖性能/导航/错误或空状态/无障碍/核心目的各一条
- 绝不自动生成完整规格当既成事实；绝不未经批准写节

## 反例（不要这样）
- 跳过信息架构直接画布局（HUD 尤其禁止）
- 用"标准做法"替用户决定审美
- 数据需求把 UI 写成游戏状态的所有者
- 忘了空状态/错误状态/加载状态
- 验收标准少于 5 条或不可测

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「HUD 直接画布局更快，信息架构后面补」 | 信息架构是全量清单与分类的根基，跳过会导致元素遗漏或层级混乱 |
| 「这个布局是标准做法，不用问用户」 | 审美归用户，布局/视觉选择必须呈现选项并确认，不能以标准为由自选 |
| 「GDD 需求放不下，悄悄砍掉一两条」 | 需求与空间冲突必须 surface 并给方案，绝不默默丢弃或扩张布局 |
| 「数据需求里 UI 就写成状态所有者」 | UI 只读/呈现数据，不得成为游戏状态所有者，否则破坏数据架构 |

## Red Flags（违规信号）
- HUD 模式跳过信息架构直接画布局分区
- 验收标准少于 5 条或不可测
- 忘掉空状态/错误状态/加载状态
- 用"标准做法"替用户决定审美
- 数据需求把 UI 写成游戏状态所有者

## Verification（证据化验证门）
- [ ] 验收标准 ≥5 条且可测，逐项覆盖性能/导航/错误或空状态/无障碍/核心目的
- [ ] 每节草稿经用户批准后再写入，无整份既成事实生成
- [ ] 交互映射使用 tech-prefs 中的输入方法，未反复询问
- [ ] 交叉引用检查已呈现 GDD 覆盖、模式库对齐、导航一致、无障碍覆盖与空状态
