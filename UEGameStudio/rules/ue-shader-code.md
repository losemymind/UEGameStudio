# ue-shader-code — 着色器代码路径规则

> 路径作用域：`Shaders/**`（模块级 USF/USH，如 `Source/MyGame/Shaders/`）+ `Content/Shaders/**`（虚拟路径 `/Game/Shaders/**`）。该路径下所有 shader 自动受此规则约束。

## 强制要点

- **命名规范**：`M_Env_Water` 式（类型_类别_名称），材质实例 `MI_` 前缀。
- **禁 magic number**：所有常量命名并文档化。
- 精度用 `half`（移动端友好），仅在需要处用 `float`。
- **禁循环内读纹理**（采样尽量摊平/预计算）。
- 模糊效果用两 pass 分离（先水平再垂直）。

## 反例（违规信号）

- shader 中出现裸数字常量。
- 循环体内部 texture sample。
- 命名无规律、材质与实例混淆。

## 来源

业界游戏工作室路径作用域编码规则。
