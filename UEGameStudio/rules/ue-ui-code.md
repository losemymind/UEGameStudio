# ue-ui-code — UI 代码路径规则

> 路径作用域：`Source/<GameModule>/UI/**`（C++ UUserWidget 子类）+ `Content/UI/**`（UMG 蓝图资产，虚拟路径 `/Game/UI/**`）。该路径下所有代码/资产自动受此规则约束。

## 强制要点

- **UI 绝不拥有游戏状态**：UI 只经 command/event 请求变更，不直接改状态。
- 全部文本走本地化（`FText` / 字符串表），无硬编码字符串。
- **键鼠 + 手柄双支持**：所有交互同时覆盖两套输入（`UCommonInputSubsystem`）。
- UI 不阻塞主线程：耗时操作异步，widget 隐藏用 `Collapsed` 而非 `Hidden`。

## 反例（违规信号）

- Widget 直接改 GameState / AttributeSet。
- 界面文本硬编码英文/中文字符串。
- 只有鼠标点击响应，无手柄焦点/确认路径。

## 来源

业界游戏工作室路径作用域编码规则。
