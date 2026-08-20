---
name: team-ui
description: 编排 UI 团队走完 UX 全流程（UX 规格 → 视觉设计 → 实现 → 评审 → 打磨），含 UMG vs CommonUI 等引擎 UI 选型。Use when 需要一个界面的端到端制作，或用户请求"做一个完整 UI 功能"。
---

# UI 团队编排

## 何时使用
- 需要从零到打磨交付一个完整界面/HUD/交互流程
- 涉及 UX 规格、视觉设计、实现与无障碍合规的端到端工作
- 仅小改动请用 quick-design，不要启动全流程

## 流程
### 阶段 0：解析评审模式
1. 优先用 `--review full|lean|solo` 参数；否则读 `production/review-mode.txt`；再否则默认 `lean`
2. `solo` 跳过所有总监门；`lean` 仅跑 PHASE-GATE 类型；`full` 全跑

### 团队组成（哪些 agent 参与）
- **ux-designer** — 用户流程、线框图、无障碍、输入处理
- **ui-programmer** — UI 框架、屏幕、控件、数据绑定、实现
- **art-director** — 视觉风格、布局打磨、与美术圣经一致性
- **引擎 UI 专家** — 校验实现是否符合引擎惯用法（从技术偏好文档读取）
- **accessibility-specialist** — 阶段 4 无障碍合规审计

### 阶段 1：上下文与 UX 规格
1. 读取 game-concept、player-journey、GDD 的 UI 需求、interaction-patterns、accessibility-requirements
2. 若 `interaction-patterns.md` 不存在，立即上报并让用户选择：先建模式库，或继续并把新发现模式全部登记
3. ux-designer 产出 `design/ux/[feature-name].md`（HUD 用 hud-design 模板）
4. 跑 UX 评审，未 APPROVED 不得进入下一阶段

### 阶段 2：视觉设计（art-director）
- 依据美术圣经定义配色/排版/间距/动画，校验对比度且颜色不得是唯一状态指示，输出资源清单（尺寸/格式）

### 阶段 3：实现（先引擎专家后 ui-programmer）
1. 引擎 UI 专家先评审：该用哪个 UI 框架（UMG vs CommonUI 等）、引擎特有坑、推荐控件结构
2. ui-programmer 实现：复用已有交互模式、UI 不得直接改游戏状态（只显示+发事件）、文本全走本地化、键鼠+手柄双支持、按无障碍等级实现

### 阶段 4：评审（并行）
- ux-designer 验线框图/交互，键鼠与手柄导航测试；art-director 验视觉一致与分辨率；accessibility-specialist 按等级查合规，违规即 blocker

### 阶段 5：打磨
- 处理所有评审反馈；动画可跳过并尊重减少动效偏好；UI 音效走音频事件系统；全分辨率测试；确认模式库已更新、HUD 遵守视觉预算

## 输入/输出
- 输入：UI 功能描述、GDD、player-journey、交互模式库、无障碍等级、美术圣经
- 输出：UX 规格、视觉设计规格、已实现 UI、评审结论、汇总报告（COMPLETE/BLOCKED）

## 约束
- 每个阶段转换前必须用决策点向用户确认，用户批准才进入下一阶段
- 不臆造交互模式；缺失模式库必须显式上报
- 编排器不直接写文件，一律委托子 agent 并走"可否写入"协议
- 引擎未配置时跳过引擎 UI 专家步骤

## 反例（不要这样）
- 阶段 1 未 APPROVED 就进入视觉设计
- ui-programmer 直接修改游戏状态或在 UI 里硬编码玩家可见字符串
- 忽略 interaction-patterns.md 缺失，凭空从功能名臆造模式
- 无障碍只在最后阶段才想起来补
