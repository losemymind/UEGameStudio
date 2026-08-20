# ue-gameplay-code — 玩法代码路径规则

> 路径作用域：`Source/<GameModule>/Gameplay/**`（如 `Source/MyGame/Gameplay/`）。该路径下所有代码自动受此规则约束。

## 强制要点

- 数值全部外部配置（Data Table / Data Asset / 配置文件），**禁止硬编码**到逻辑中。
- 所有基于时间的逻辑用 delta time，禁止假设固定帧率。
- **禁止直接引用 UI**：玩法代码不持有、不操作任何 Widget/UMG 对象。
- **禁止静态单例**（gameplay 状态经 GameState / GameInstance 归属明确持有）。
- 状态变更走权威路径（服务器权威或明确的状态机），不散落全局。

## 反例（违规信号）

- 伤害值、冷却时间写死在 `.cpp` 里。
- `tick` 中直接 `GetHUD()` 或操作 Widget。
- `static` 全局变量承载游戏状态。

## 来源

业界游戏工作室路径作用域编码规则。
