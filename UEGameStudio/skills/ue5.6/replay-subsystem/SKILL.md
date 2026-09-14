---
name: replay-subsystem
description: UReplaySubsystem（UE 5.6）Replay 回放子系统 - 录制/回放名称与时间查询、录制状态判断、请求检查点写入；在 Agent 需要通过 unreal Python 查询回放状态或请求检查点时使用
risk: safe
category: development
tags: [ue5.6, replay, network, python, subsystem]
---

# ReplaySubsystem - Replay 回放（UE 5.6）

## 何时使用此技能

- 当 Agent 需要通过 unreal Python 查询回放状态或请求检查点时使用本 skill（description 触发场景）。
- 本 skill 只在与 replay-subsystem 相关的模块/插件/API 操作时加载，不用于无关通用任务。

本 skill 描述 UE 5.6 引擎 `UReplaySubsystem` 暴露给 Python 的回放操作方法。方法名与签名依据 `Engine/Source/Runtime/Engine/Public/ReplaySubsystem.h` 中带 `UFUNCTION(BlueprintCallable)` 标记的成员整理。

## 入口说明

从 UE Python 获取本子系统（`UGameInstanceSubsystem` 派生）：

```python
import unreal
api = unreal.get_game_instance().get_subsystem(unreal.ReplaySubsystem)
```

- `unreal.get_game_instance()` 获取当前 GameInstance；无 PIE/运行时游戏会话时返回 `None`，按 `BLOCKED_TOOLING` 处理并停止。
- `api` 为 `None`（子系统未实例化）时按阻塞规则处理。
- Python 方法名取 `meta=(ScriptMethod=...)` 值转 snake_case；无则按 C++ 函数名转 snake_case。精确 Python 暴露名需实测确认。
- 录制/回放属运行时多人/回放能力：多人网络同步与 Replay 业务归属 `ue-gameplay-engineer`，本 skill 只提供 ReplaySubsystem 的 Python 调用 API。

## 可用操作

| 类别 | Python 方法名 | C++ 签名 | Python 返回值 |
| --- | --- | --- | --- |
| 查询 | `get_active_replay_name()` | `FString GetActiveReplayName() const` | `str` |
| 查询 | `get_replay_total_time()` | `float GetReplayTotalTime() const` | `float` |
| 查询 | `get_replay_current_time()` | `float GetReplayCurrentTime() const` | `float` |
| 状态 | `is_recording()` | `bool IsRecording() const` | `bool` |
| 状态 | `is_playing()` | `bool IsPlaying() const` | `bool` |
| 控制 | `request_checkpoint()` | `void RequestCheckpoint()` | `None` |

## 示例

```python
import unreal

api = unreal.get_game_instance().get_subsystem(unreal.ReplaySubsystem)
if api is None:
    print("BLOCKED_TOOLING: ReplaySubsystem 未实例化（无运行时会话）")
else:
    print("recording:", api.is_recording())
    print("playing:", api.is_playing())
    if api.is_recording():
        print("replay:", api.get_active_replay_name())
        print("elapsed:", api.get_replay_current_time())
        api.request_checkpoint()
```

## 限制和注意事项

- 录制/回放为运行时多人/回放能力：监听服务器、专用服务器或回放会话存在时才可用；运行时环境不可用 → `BLOCKED_TOOLING`，缺少回放输入（回放名、会话等）→ `BLOCKED_INPUT`。
- Python 方法名按 C++ 函数名转 snake_case；本类成员的精确 Python 暴露名需实测确认。
- 多人在线属项目边界（本地构建包范围），不做线上承诺。
- 未在真实 UE 5.6 环境实测的调用不做"已验证"断言。

本 SKILL.md 已收录该类全部可由 Python 直接调用的成员，正文即完整参考。