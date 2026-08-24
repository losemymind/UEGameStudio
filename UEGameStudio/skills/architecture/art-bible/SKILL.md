---
name: art-bible
description: 逐节引导撰写美术圣经（Art Bible）——创建约束所有资产生成的视觉身份规格书（9 节）。Use when：`/brainstorm` 获批之后、`/map-systems` 或任何 GDD 撰写之前。
---

# 美术圣经

## 何时使用
- `/brainstorm` 获批之后、`/map-systems` 或 GDD 撰写之前
- retrofit：`design/art/art-bible.md` 已存在则只补空/占位节

## 流程
### 阶段 0：参数与上下文检查
1. 解析 `--review [full|lean|solo]`
2. 读 `game-concept.md`（缺失则报错），提取标题/核心幻想/支柱/视觉锚点/平台
3. 读 `docs/technical-preferences.md` 的性能预算与引擎

### 阶段 1：框架
AskUserQuestion 询问范围（全 9 节 / 视觉核心 1–4 / 仅资产标准 / 续补）与参考作品（自由文本）

### 阶段 2：视觉身份基础（1–4 节）
1. **Visual Identity Statement**：一句话视觉规则 + 2–3 条支撑原则（各锚定一个支柱）
2. **Mood & Atmosphere**：按游戏状态定义情绪目标/光照特征/氛围形容词/能量等级
3. **Shape Language**：角色剪影/环境几何/UI 形状语法/英雄形状 vs 支撑形状
4. **Color System**：主调色板 + 语义色 + 分区域色温 + UI 调色板 + 色盲安全
5. 每节强制派 `art-director` agent 起草，经批准即写文件

### 阶段 3：制作指南（5–8 节）
1. **Character Design Direction**、**Environment Design Language**：派 art-director
2. **UI/HUD Visual Direction**：并行派 art-director + ux-designer，冲突时 surface 双方立场让用户决定
3. **Asset Standards**：并行派 art-director + technical-artist，艺术偏好与技术约束冲突时明确权衡（如 4K vs 2K）

### 阶段 4：参考方向（第 9 节）
派 art-director 编 3–5 个参考源，每个注明"取什么、避开什么"，不得两个参考指向同一方向

### 阶段 5-6：签收与收尾
1. `full` 模式跑 AD-ART-BIBLE 门，判定记入状态头
2. 按项目状态检查后给出下一步选项（map-systems / setup-engine / design-system / create-architecture 等），`/create-architecture` 与"停止"恒为选项

## 输入/输出
- 输入：`game-concept.md`、可选视觉锚点、参考作品、tech-prefs
- 输出：`design/art/art-bible.md`（9 节）

## 约束
- 每节必须先派相关 agent 再起草，绝不跳过
- 每节批准后立即写文件，不批量
- 艺术与技术冲突绝不默默解决，surface 双方立场
- 美术圣经是约束文档：以视觉一致性换取限制未来决策
- 参考必须"加法式"，各指向不同方向

## 反例（不要这样）
- 不派 art-director 就自己写视觉身份语句
- 语义色不给理由（为何红=危险）就直接定
- 4K 偏好与 2K 预算冲突时默默选一个
- 参考条目只写"取其整体美学"而不具体到某个技巧/色彩/构图

## 反合理化表（借口 → 反驳）
| 借口（会怎么说） | 反驳（为什么不对） |
|---|---|
| 「视觉身份语句我自己写更快，不用派 art-director」 | 每节强制派相关 agent，跳过会丢失美术专业视角与支柱锚定 |
| 「4K 和 2K 冲突，默认选 4K 更好看」 | 艺术与技术冲突必须 surface 双方立场让用户决定，默默解决会破坏预算或质量 |
| 「参考就写『取其整体美学』够用了」 | 参考必须具体到某个技巧/色彩/构图，模糊描述无法指导资产生成 |
| 「几节攒到一起写更高效」 | 每节批准后立即写文件，批量会因会话中断丢失已批准内容 |

## Red Flags（违规信号）
- 未派 art-director 就自行起草视觉身份语句
- 语义色不给理由（为何红=危险）就直接定
- 4K/2K 等艺术与技术冲突被默默选择一个
- 参考条目仅写"取其整体美学"而非具体技巧/色彩/构图
- 两个参考指向同一方向

## Verification（证据化验证门）
- [ ] 每节有对应 agent 委派记录（art-director，UI/HUD 加 ux-designer，资产标准加 technical-artist）
- [ ] 每节批准后已立即写文件，无批量写入
- [ ] 语义色附理由；参考条目具体到技巧/色彩/构图且各不同向
- [ ] 冲突场景（若有）已 surface 双方立场并经用户决策
