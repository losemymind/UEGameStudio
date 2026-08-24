---
name: ue-test-driven-development
description: 对 UE C++、Blueprint 可测逻辑、网络与功能场景执行 Red-Green-Refactor，并保存真实失败/通过证据。Use when 新增行为、修复缺陷或改变可观察规则。
---

# UE 测试驱动开发

## 流程
1. 从 story/bug 提取单一可观察行为、测试层级和目标平台；先盘点项目已有 Automation Spec/Simple/Complex、Functional Test、Gauntlet 与自有 fixtures，禁止假设 helper 存在。
2. RED：先写最小失败测试，运行最窄测试过滤器；保存命令、UE 版本、退出码、失败断言与日志，确认失败原因正是缺失行为。
3. GREEN：写最小实现使测试通过；运行同一过滤器并保存证据。
4. REFACTOR：只在绿灯后去重复、调整边界；重跑目标测试与受影响回归。
5. Replication 需 server/client/late join/packet loss 场景；GAS 需 authority/prediction/cost/cooldown；存档需版本迁移与损坏输入。
6. 由 `ue-test-automation-engineer` 复核层级、过滤器、flakiness 风险和 CI 可运行性。
7. 用户明确决定先实现后补测试时，记录方法变更为 `test-after`（含决定者与原因），不得继续称为 TDD；否则坚持 RED-GREEN-REFACTOR。

## 约束
- 没有可复现 RED 不得声称 TDD；仅截图不是自动化通过证据。
- 不生成或依赖未在仓库中验证存在的预置通用 helper；需要 helper 时先定义最小本地接口及测试。
- 禁止外网、时间、随机种子不固定或共享状态造成不确定性。

## 反例
- 先实现后补一个永远通过的测试。
- RED 因编译错误失败却当作行为失败。
- 只跑单测，不跑受影响回归。

## 反合理化表
| 借口 | 反驳 |
|---|---|
| “测试后补效果一样” | 没有先失败的证据就无法证明测试能捕获缺失行为。 |
| “这个测试偶尔失败没关系” | 不确定测试不能作为棘轮证据，须先消除 flakiness。 |

## Red Flags
- RED/GREEN 测试标识不同或缺退出码。
- RED 失败原因是编译/环境错误。
- 引用仓库无法定位的 helper。

## Verification
- [ ] RED/GREEN 使用同一测试标识并保留命令、退出码和日志。
- [ ] RED 原因对应缺失行为，GREEN 对应最小实现。
- [ ] refactor 后目标与受影响回归均通过。
- [ ] 计划模式下工作树不变。
