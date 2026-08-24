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

## UX 评审（合并自 ux-review）

设计完成后，必须跑 UX 评审验证。评审为只读操作，不修改任何文件，产出 APPROVED / NEEDS REVISION / MAJOR REVISION 判定。

### 评审时机
- `/ux-design` 完成后、交接给 `unreal-ui-developer` / `art-director` 之前
- Pre-Production→Production 门检查前（关键屏幕需有已评审规格）
- UX 规格大修订后

### 评审范围
- 支持：具体文件路径 / `all`（验证 `design/ux/` 全部）/ `hud` / `patterns`
- `all` 先输出汇总表（文件 | 判定 | 主要问题）再逐个详情

### 校验清单
1. **UX Spec 评审**：完整性（必需节）+ 质量（玩家需求清晰/状态完整/输入覆盖/数据架构/无障碍/GDD 对齐/模式库一致/本地化/验收标准质量）
2. **HUD 评审**：HUD 哲学、信息架构覆盖全部系统、布局分区、元素规格、玩法上下文状态、视觉预算、平台适配、调优旋钮
3. **Pattern Library 评审**：目录索引最新、标准控件齐全、每个模式含 When to Use/When NOT to Use/状态/无障碍/实施笔记、动画与声音标准表、模式间无冲突

### 无障碍审计
- 按承诺层级核对：颜色不得唯一承载信息
- 检查输入方法：以 tech-prefs 为权威来源，不以规格自身头部判断
- 验证屏幕阅读器兼容性、可缩放文本、字幕/视觉替代方案

### 设计系统一致性检查
- 对照 design-system 中的规范检查组件命名、间距、颜色令牌、字体层级
- 检查模式库中已注册的交互模式是否被正确引用
- 新组件是否应注册到模式库

### 数据架构检查
- UI 不得列为游戏状态所有者
- 实时数据必须说明更新触发机制
- 数据流向简图验证单向数据流（游戏状态 → UI 呈现）

### 评审输出
- 按模板输出完整性/质量问题/GDD 对齐/无障碍/模式库一致
- 最终判定：APPROVED / NEEDS REVISION / MAJOR REVISION
- 列出 BLOCKING 与 ADVISORY 问题数
- 判定是建议性的，用户选择带着 NEEDS REVISION 推进即自担风险

### 评审约束
- **只读**：绝不修改被评审文件，不编辑不写文件，只报告发现
- 评审必须覆盖 happy path + 错误/空/加载状态，不可只审正常流程
- 输入方法以 tech-prefs 为权威来源，规格头部可能是错的或过期的

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
- 评审时修改被评审文件（本技能评审只读）
- 只用规格自身头部判断输入方法而非 tech-prefs
- 评审只看 happy path 漏掉错误/空/加载状态
- 判定后强行阻止用户推进

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「HUD 直接画布局更快，信息架构后面补」 | 信息架构是全量清单与分类的根基，跳过会导致元素遗漏或层级混乱 |
| 「这个布局是标准做法，不用问用户」 | 审美归用户，布局/视觉选择必须呈现选项并确认，不能以标准为由自选 |
| 「GDD 需求放不下，悄悄砍掉一两条」 | 需求与空间冲突必须 surface 并给方案，绝不默默丢弃或扩张布局 |
| 「数据需求里 UI 就写成状态所有者」 | UI 只读/呈现数据，不得成为游戏状态所有者，否则破坏数据架构 |
| 「顺手把规格里的错误直接改掉更省事」 | 评审只读，改文件会让评审与被评审者职责混淆、丢失独立判断 |
| 「用规格自己的头部判断输入方法更快」 | 输入方法以 tech-prefs 为权威来源，规格头部可能是错的或过期的 |
| 「主要看 happy path，错误/空/加载状态不重要」 | 漏掉这些状态等于评审不完整，会放大交付后的边界缺陷 |
| 「评出 MAJOR REVISION 就坚决拦住不让推进」 | 判定是建议性的，用户有权自担风险推进 |

## Red Flags（违规信号）
- HUD 模式跳过信息架构直接画布局分区
- 验收标准少于 5 条或不可测
- 忘掉空状态/错误状态/加载状态
- 用"标准做法"替用户决定审美
- 数据需求把 UI 写成游戏状态所有者
- 对任何被评审文件执行写入或编辑操作
- 用规格自身头部而非 tech-prefs 判断输入方法
- 数据架构检查漏掉"UI 被写成游戏状态所有者"或实时数据未说明更新触发
- 判定后强行阻止用户推进
- 无障碍核对未按承诺层级检查颜色是否唯一承载信息

## Verification（证据化验证门）
- [ ] 验收标准 ≥5 条且可测，逐项覆盖性能/导航/错误或空状态/无障碍/核心目的
- [ ] 每节草稿经用户批准后再写入，无整份既成事实生成
- [ ] 交互映射使用 tech-prefs 中的输入方法，未反复询问
- [ ] 交叉引用检查已呈现 GDD 覆盖、模式库对齐、导航一致、无障碍覆盖与空状态
- [ ] 评审输出判定为 APPROVED / NEEDS REVISION / MAJOR REVISION 之一，并附 BLOCKING 与 ADVISORY 问题数
- [ ] 数据架构核对已确认 UI 非游戏状态所有者、实时数据说明更新触发
- [ ] 无障碍核对按承诺层级验证，颜色未唯一承载信息
- [ ] 评审全程未修改任何被评审文件

## 合并覆盖
- **ux-review**：UX 评审工作流（评审时机/范围、校验清单含 UX Spec/HUD/Pattern Library 三类、无障碍审计、设计系统一致性检查、数据架构检查、只读约束、APPROVED/NEEDS REVISION/MAJOR REVISION 判定），反例/反合理化表/Red Flags/Verification 条目同步合并