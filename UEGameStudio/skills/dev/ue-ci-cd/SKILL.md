---
name: ue-ci-cd
description: 设计和验证 UE BuildCookRun、自动化测试、制品、签名与部署流水线，确保构建可复现、证据可追踪、权限最小化。Use when 新建或修改 CI/CD、平台构建或发布自动化。
---

# UE CI/CD

## 流程
1. 盘点 CI 平台、UE 安装/源码构建方式、BuildGraph/UAT、目标 Target/Configuration/平台、缓存、许可证、签名与分支保护。
2. 设计阶段：validate→compile→automation→cook/package→artifact→security/compliance→deploy approval；每阶段声明输入、输出、超时、重试、owner 与失败策略。
3. 固定引擎/toolchain/plugin/SDK 版本；生成 manifest（commit、UE version、参数、依赖哈希、制品哈希），禁止 `latest`。
4. 缓存键含 UE/toolchain/platform/config；缓存恢复失败须安全退化，不得污染 DDC/Intermediate。
5. 测试由 `ue-test-automation-engineer` 复核；制品含 logs、JUnit/Automation report、symbols、pak/IoStore 清单与 SBOM。
6. secret 仅从 CI secret store 注入并最小权限；日志脱敏。部署需环境保护、人工批准、灰度、健康检查与回滚。
7. 先 dry-run/lint，再在非生产分支验证；展示 diff 与证据，经批准才写配置或触发外部流水线。

## 约束
- 不提交 secret、证书或明文凭据；不默认有云权限。
- 未获授权不触发生产构建/部署，不修改外部 CI 状态。

## 反例
- 使用浮动 UE/SDK 版本。
- 构建成功但不保存 manifest、日志和符号。
- 在 PR 流程直接拿生产部署凭据。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “latest 方便自动升级” | 浮动依赖破坏构建复现和事故回滚。 |
| “日志里短暂打印 secret 没关系” | CI 日志会长期复制与共享，泄露窗口不可控。 |

## Red Flags
- pipeline 使用浮动版本或分支名作为唯一缓存键。
- 制品无法追溯到 commit/UE/toolchain/参数。
- 未授权触发生产流水线或部署。

## Verification
- [ ] pipeline 各阶段有输入/输出/owner/超时/失败策略。
- [ ] 制品绑定 commit、UE/toolchain、参数和哈希。
- [ ] secret/签名/部署权限最小化且日志脱敏。
- [ ] 设计或 dry-run 模式下外部状态和仓库不变。
