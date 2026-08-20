---
name: onboard
description: 为加入项目的新成员或新 agent 生成上下文化的上手文档：总结项目状态、架构、约定与当前优先事项。Use when 有新人/新 agent 加入，需要快速上手。
---

# 新人上手

## 何时使用
- 新贡献者或新 agent 加入项目
- 需要按角色/领域生成针对性的上下文文档

## 流程
### 加载项目上下文
1. 读 CLAUDE.md 获取项目概览与标准；若指定了角色，读对应 agent 定义。

### 扫描相关领域
1. 按角色扫描：程序员→`src/` 架构与关键文件；设计→`design/`；叙事→`design/narrative/`；QA→`tests/`；生产→`production/` 当前 sprint 与里程碑。读 git log 了解当前进展。

### 生成上手文档
1. 按模板输出：项目摘要、角色职责、架构、关键目录/文件表、约定、该领域现状、当前 sprint 上下文、关键依赖、常见坑、首批任务、待问问题。

### 保存与后续
1. 展示文档，询问是否写入 `production/onboarding/onboard-[role]-[date].md`；提示分享给新成员并跑 sprint-status 展示进度。

## 输入/输出
- 输入：角色/领域参数、项目文件与 git 历史。
- 输出：`production/onboarding/onboard-[role]-[date].md` 上手文档。

## 约束
- 内容按角色裁剪，只给该角色相关的架构与约定。
- 写文件前询问批准。

## 反例（不要这样）
- 生成与角色无关的泛泛文档，塞入所有角色内容。
- 不读 git log，忽略项目当前进展与"常见坑"。
- 未经批准就写文件。
