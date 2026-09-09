# ReplaySubsystem - 概述（UE 5.6）

## 库功能概述

`UReplaySubsystem` 是 UE 5.6 中专门用于录制与回放游戏会话（Replay）的子系统。它支持录制游戏过程中的关键数据（如 Actor 位置、旋转、状态变化），并能够在后续播放时精确还原整个游戏场景。这在游戏测试、 debugging、演示与视频录制中非常有用。

Replay 系统的工作原理是记录游戏会话中的所有"可录制Actor"（Replayable Actors）的快照与状态变化，播放时按时间重放这些记录。

## 核心用途与场景

### 1. 游戏测试与调试
- **Bug 复现**：录制包含 Bug 的游戏会话，供开发者回放分析
- **自动化测试**：回放固定测试场景，验证修复效果
- **性能分析**：录制后分析帧时间、内存使用等指标

### 2. 演示与视频录制
- **预录制视频**：录制预告片、演示视频，无需实时渲染
- **无损录制**：录制高帧率视频，后期压缩处理
- **批量演示**：录制多个游戏流程，供玩家选择观看

### 3. 网络一致性验证
- **Replay 同步检查**：验证客户端-服务器状态一致性
- **预测修正回放**：分析预测与修正的差异
- **网络延迟模拟**：录制后分析网络条件影响

## 更多使用示例

### 示例 1：启动录制
```python
import unreal

def start_replay_recording():
    """启动游戏会话录制"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING", "reason": "ReplaySubsystem not available in this world"}
    
    # 启动录制
    # 注意：ReplayRecordingName 需要配置 DefaultReplaySettings
    subsystem.start_recording_replay()
    
    return {"status": "OK", "action": "recording_started"}

def start_recording_with_custom_name(filename):
    """使用自定义文件名启动录制"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 设置录制文件名
    subsystem.set_replay_name(filename)
    
    # 启动录制
    subsystem.start_recording_replay()
    
    return {"status": "OK", "filename": filename}

# 注意：录制需要在 Playback/PIE 模式下进行
# 编辑器主世界不支持 ReplaySubsystem
```

### 示例 2：停止录制与保存
```python
import unreal

def stop_replay_recording():
    """停止当前录制"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 停止录制
    subsystem.stop_recording_replay()
    
    return {"status": "OK", "action": "recording_stopped"}

def save_replay_to_disk():
    """将录制数据保存到磁盘"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 确保录制已停止
    subsystem.stop_recording_replay()
    
    # 保存到默认目录
    # 通常保存在 ProjectDir/Replays/ 目录
    subsystem.save_replay()
    
    return {"status": "OK", "action": "replay_saved"}
```

### 示例 3：回放录制
```python
import unreal

def playback_recording(filename):
    """回放录制文件"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 设置回放文件
    subsystem.set_replay_to_playback(filename)
    
    # 启动回放
    subsystem.start_playback()
    
    return {"status": "OK", "filename": filename}

def check_playback_status():
    """检查回放状态"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取回放状态
    is_playing = subsystem.is_playback_active()
    playback_time = subsystem.get_playback_time_seconds()
    total_duration = subsystem.get_replay_duration_seconds()
    
    return {
        "status": "OK",
        "is_playing": is_playing,
        "current_time": playback_time,
        "total_duration": total_duration,
        "progress_percent": (playback_time / total_duration * 100) if total_duration > 0 else 0
    }

def seek_to_time(seconds):
    """快进/快退到指定时间"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    subsystem.seek_to_time(seconds)
    
    return {"status": "OK", "seek_to": seconds}
```

### 示例 4：录制配置与高级选项
```python
import unreal

def configure_replay_settings():
    """配置录制设置"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 获取默认设置
    settings = unreal.get_default_object(unreal.ReplaySettings)
    
    # 配置选项（示例）
    settings.set_replay_enable_recording(True)
    settings.set_replay_compression_enabled(True)
    settings.set_replay_compression_quality(0.9)
    
    # 设置录制时长限制（秒）
    # settings.set_replay_max_duration(300)  # 5分钟
    
    return {"status": "OK", "settings_configured": True}

def list_available_replays():
    """列出所有可用的录制文件"""
    # 通常从 ProjectDir/Replays/ 目录读取
    import os
    project_dir = unreal.Paths.project_dir()
    replays_dir = os.path.join(project_dir, "Replays")
    
    if not os.path.exists(replays_dir):
        return {"status": "NO_REPLAYS_DIR", "path": replays_dir}
    
    replay_files = [f for f in os.listdir(replays_dir) if f.endswith('.replay')]
    
    return {
        "status": "OK",
        "directory": replays_dir,
        "replay_count": len(replay_files),
        "files": replay_files[:10]  # 限制返回数量
    }
```

### 示例 5：网络录制与一致性检查
```python
import unreal

def start_network_recording():
    """启动网络同步录制（用于网络一致性验证）"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 启动录制时启用网络一致性检查
    subsystem.start_recording_replay_with_network_consistency()
    
    return {"status": "OK", "action": "network_recording_started"}

def verify_network_consistency():
    """验证网络一致性（播放时）"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 检查是否启用一致性验证
    is_consistency_enabled = subsystem.is_network_consistency_check_enabled()
    
    # 获取一致性违规统计
    violations = subsystem.get_network_consistency_violations()
    
    return {
        "status": "OK",
        "consistency_enabled": is_consistency_enabled,
        "violation_count": violations
    }
```

## 高级用法与最佳实践

### 1. 录制性能优化
- **选择性录制**：仅录制关键 Actor，减少数据量
- **压缩配置**：调整压缩质量平衡文件大小与精度
- **时长控制**：设置最大录制时长，避免磁盘溢出

### 2. 回放精准度控制
- **时间戳同步**：确保客户端-服务器时间同步
- **插值平滑**：开启插值减少回放抖动
- **帧速率匹配**：回放帧速率与录制时一致

### 3. 错误处理与调试
- **录制失败处理**：捕获启动录制时的异常
- **回放中断恢复**：支持从断点继续回放
- **详细日志**：启用 Replay 系统详细日志

### 4. 与 GameplayStatics 集成
```python
import unreal

def use_gameplay_Statics_with_replay():
    """结合 GameplayStatics 进行录制控制"""
    world = unreal.get_editor_subsystem(unreal.UnrealEngineSubsystem).get_game_instance().get_world()
    subsystem = world.get_subsystem(unreal.ReplaySubsystem)
    
    if subsystem is None:
        return {"status": "BLOCKED_TOOLING"}
    
    # 使用 GameplayStatics 播放回放
    # unreal.GameplayStatics.play_replay(world, "filename.replay")
    
    return {"status": "OK", "method": "use_GameplayStatics"}
```

## 常见问题与注意事项

### 1. 运行时环境限制
- **仅运行时支持**：ReplaySubsystem 仅在 PIE/Play 会话中可用，编辑器主世界不支持
- **主机端录制**：网络游戏中仅主机端可以录制
- **平台限制**：某些平台（如 consoles）可能有额外限制

### 2. 存储与权限
- **目录权限**：确保项目目录有写权限
- **磁盘空间**：录制文件可能很大，定期清理
- **路径配置**：录制文件默认保存在 `ProjectDir/Replays/`

### 3. 常见错误
- `BLOCKED_TOOLING`：世界不支持 ReplaySubsystem（非运行时环境）
- `BLOCKED_INPUT`：录制文件名无效或路径不存在
- **权限错误**：磁盘写入权限不足

### 4. 文件格式
- **.replay 格式**：二进制格式，包含所有录制数据
- **压缩支持**： 支持多种压缩算法（ZIP、LZ4 等）
- **版本兼容**：录制文件可能与特定 UE 版本绑定

### 5. 未实测声明
- 本概述基于 UE 5.6 文档与反射定义整理，精确 Python 方法名需在目标编辑器中通过 `dir(unreal.ReplaySubsystem)` 实测确认
- 个别方法（如 `start_recording_replay_with_network_consistency`）可能因插件而异

详细 API 与完整示例请参阅 `SKILL.md` 中的逐方法清单与快速示例。