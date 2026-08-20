# ue-test-standards — 测试标准路径规则

> 路径作用域：`Source/**/Tests/**`（UE 自动化测试，`IMPLEMENT_SIMPLE_AUTOMATION_TEST`；同模块内 `Source/<GameModule>/Tests/` 或独立 `Source/<GameModule>.Tests/`）。该路径下所有测试代码自动受此规则约束。

## 强制要点

- **命名规范**：`[System]_[Behavior]_[ExpectedResult]`，测试名自解释。
- 遵循 **AAA**（Arrange / Act / Assert）结构。
- **每个 bug 修复必须有回归测试**（先写复现测试再修，修完测试转绿）。
- 测试隔离：不依赖执行顺序、不依赖共享可变状态。

## 反例（违规信号）

- bug 修复无对应回归测试提交。
- 测试依赖全局状态/执行顺序（跑全量才过）。
- 断言写"不为空"而非精确预期值。

## 来源

Claude-Code-Game-Studios 路径作用域规则，蒸馏基准见仓库根 `DISTILLED-REFERENCE.md` §6.3。
