#!/usr/bin/env python3
"""validate-topology.py — 校验 manifest 驱动的 SEA/agents/topology.json。

检查项:
  1. 顶层结构：topologies 数组存在
  2. 每个候选：id 唯一、必填字段完整（id/name/description/agents/status）
  3. status 枚举合法：pending / approved / reverted
  4. registry_source 指向 package manifest schema v2
  5. integration orchestrator 唯一，manifest 所有叶子均单向归属它
  6. scope/engine_dependency/evaluation_profile 契约一致

用法:
    python SEA/scripts/validate-topology.py [--agents-dir <agent 定义目录>]

退出码: 0 全部通过; 1 存在错误。
零第三方依赖（仅标准库）。
"""

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOPO_PATH = ROOT / "agents" / "topology.json"
REPO = ROOT.parent
VALID_STATUS = {"pending", "approved", "reverted"}
REQUIRED_FIELDS = ["id", "name", "description", "registry_source",
                   "orchestrator", "edge_policy", "status"]
VALID_SCOPES = {"general", "game", "unreal", "integration"}
VALID_PROFILES = {"general-core", "game-core", "unreal-specialist", "integration"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--agents-dir", type=str, default=None,
                    help="agent 定义目录（默认 cwd/.opencode/agents，回退模板目录）")
    args = ap.parse_args()

    if not TOPO_PATH.exists():
        print(f"[ERROR] 拓扑注册表不存在: {TOPO_PATH}", file=sys.stderr)
        return 1
    try:
        data = json.loads(TOPO_PATH.read_text(encoding="utf-8"))
    except ValueError as e:
        print(f"[ERROR] topology.json 解析失败: {e}", file=sys.stderr)
        return 1

    if args.agents_dir:
        agents_dir = Path(args.agents_dir)
    else:
        candidates = [Path.cwd() / ".opencode" / "agents", ROOT.parent / "UEGameStudio" / "agents"]
        agents_dir = next((p for p in candidates if p.exists()), candidates[0])
    templates_dir = ROOT / "templates"

    topos = data.get("topologies", [])
    if not isinstance(topos, list):
        print("[ERROR] topologies 应为数组", file=sys.stderr)
        return 1

    errors = []
    seen_ids = set()
    for i, t in enumerate(topos, 1):
        loc = f"topologies 候选#{i}"
        if not isinstance(t, dict):
            errors.append(f"{loc}: 应为对象")
            continue
        for f in REQUIRED_FIELDS:
            if f not in t or t[f] in (None, ""):
                errors.append(f"{loc} ({t.get('id', '?')}): 缺少必填字段 {f}")
        eid = t.get("id")
        if eid:
            if eid in seen_ids:
                errors.append(f"{loc}: id 重复 {eid}")
            seen_ids.add(eid)
        if t.get("status") not in VALID_STATUS:
            errors.append(f"{loc} ({eid}): status 非法 {t.get('status')}（应为 {sorted(VALID_STATUS)}）")

        registry_source = t.get("registry_source")
        if registry_source != "UEGameStudio/manifest.json":
            errors.append(f"{loc} ({eid}): registry_source 必须是 UEGameStudio/manifest.json")
            continue
        manifest_path = REPO / registry_source
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            errors.append(f"{loc} ({eid}): manifest 无法读取: {exc}")
            continue
        if manifest.get("schema_version") != 2:
            errors.append(f"{loc} ({eid}): manifest 必须是 schema v2")
        entries = manifest.get("agents", [])
        agent_ids = {entry.get("id") for entry in entries if isinstance(entry, dict)}
        orchestrator = t.get("orchestrator")
        if orchestrator not in agent_ids:
            errors.append(f"{loc} ({eid}): orchestrator 不在 manifest: {orchestrator}")
        if t.get("edge_policy") != "orchestrator-to-all-leaves":
            errors.append(f"{loc} ({eid}): edge_policy 必须是 orchestrator-to-all-leaves")
        for entry in entries:
            if not isinstance(entry, dict):
                errors.append(f"{loc} ({eid}): manifest agent entry 非对象")
                continue
            aid = entry.get("id")
            scope = entry.get("scope")
            profile = entry.get("evaluation_profile")
            dependency = entry.get("engine_dependency")
            if scope not in VALID_SCOPES or profile not in VALID_PROFILES:
                errors.append(f"{loc} ({eid}): {aid} scope/profile 非法 {scope}/{profile}")
            if aid == orchestrator:
                if scope != "integration" or profile != "integration" or entry.get("integration_owner") is not None:
                    errors.append(f"{loc} ({eid}): orchestrator integration 契约错误 {aid}")
            else:
                if entry.get("integration_owner") != orchestrator:
                    errors.append(f"{loc} ({eid}): leaf integration_owner 错误 {aid}")
                if scope in {"general", "game"} and dependency != "none":
                    errors.append(f"{loc} ({eid}): core agent 不得依赖引擎 {aid}")
                if scope == "unreal" and dependency != "required":
                    errors.append(f"{loc} ({eid}): Unreal specialist 必须 required {aid}")
            fname = f"{aid}.md"
            matches = list(agents_dir.rglob(fname)) if agents_dir.exists() else []
            if not matches and not (templates_dir / fname).exists():
                errors.append(f"{loc} ({eid}): agent 定义文件缺失 {fname}")

    if errors:
        for e in errors:
            print(f"[ERROR] {e}", file=sys.stderr)
        print(f"\n{len(errors)} 个问题，请修正后重跑。", file=sys.stderr)
        return 1
    print(f"OK：{len(topos)} 个拓扑候选校验通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
