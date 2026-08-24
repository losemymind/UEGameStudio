#!/usr/bin/env python3
"""校验 UEGameStudio 7 阶段 workflow catalog 与 manifest 的引用完整性。"""

import argparse
import json
import sys
from pathlib import Path

try:
    from yaml import safe_load
except ImportError:  # pragma: no cover
    sys.stderr.write("缺少依赖：请先 `pip install -r SEA/requirements.txt`\n")
    sys.exit(2)


REPO = Path(__file__).resolve().parents[2]
EXPECTED_PHASES = [
    "concept", "systems-design", "technical-setup", "pre-production",
    "production", "polish", "release",
]
REQUIRED_PHASE_FIELDS = {
    "id", "order", "name", "owner", "reviewers", "skills", "entry", "exit",
    "on_reject", "max_retries",
}


def load_yaml(path, errors):
    try:
        return safe_load(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"workflow YAML 解析失败: {exc}")
        return {}


def load_json(path, errors):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"manifest JSON 解析失败: {exc}")
        return {}


def validate(catalog_path, manifest_path):
    errors = []
    catalog = load_yaml(catalog_path, errors) or {}
    manifest = load_json(manifest_path, errors) or {}
    agent_ids = {item.get("id") for item in manifest.get("agents", [])}
    skill_ids = {item.get("id") for item in manifest.get("skills", [])}
    if catalog.get("schema_version") != 2:
        errors.append("workflow schema_version 必须为 2")
    phases = catalog.get("phases")
    if not isinstance(phases, list):
        return [*errors, "workflow phases 必须为数组"]
    ids = [phase.get("id") for phase in phases if isinstance(phase, dict)]
    orders = [phase.get("order") for phase in phases if isinstance(phase, dict)]
    if ids != EXPECTED_PHASES or orders != list(range(1, 8)):
        errors.append(f"workflow 必须按固定 7 阶段排序: {EXPECTED_PHASES}")
    if len(set(ids)) != len(ids):
        errors.append("workflow phase id 重复")
    for index, phase in enumerate(phases, 1):
        loc = f"phase#{index}({phase.get('id') if isinstance(phase, dict) else '?'})"
        if not isinstance(phase, dict):
            errors.append(f"{loc} 必须为对象")
            continue
        missing = REQUIRED_PHASE_FIELDS - set(phase)
        if missing:
            errors.append(f"{loc} 缺少字段 {sorted(missing)}")
        owner = phase.get("owner")
        if owner not in agent_ids:
            errors.append(f"{loc} owner 悬空: {owner}")
        reviewers = phase.get("reviewers")
        if not isinstance(reviewers, list) or not reviewers:
            errors.append(f"{loc} reviewers 必须为非空数组")
        else:
            for reviewer in reviewers:
                if reviewer not in agent_ids:
                    errors.append(f"{loc} reviewer 悬空: {reviewer}")
        skills = phase.get("skills")
        if not isinstance(skills, list) or not skills:
            errors.append(f"{loc} skills 必须为非空数组")
        else:
            for skill in skills:
                if skill not in skill_ids:
                    errors.append(f"{loc} skill 悬空: {skill}")
        for gate in ("entry", "exit"):
            value = phase.get(gate)
            if not isinstance(value, dict) or not isinstance(value.get("artifacts"), list):
                errors.append(f"{loc} {gate}.artifacts 必须为数组")
        exit_gate = phase.get("exit") if isinstance(phase.get("exit"), dict) else {}
        if not exit_gate.get("evidence_fields") or not exit_gate.get("checks"):
            errors.append(f"{loc} exit 必须含非空 evidence_fields/checks")
        if not isinstance(phase.get("on_reject"), str) or not phase.get("on_reject").strip():
            errors.append(f"{loc} on_reject 必须为非空字符串")
        retries = phase.get("max_retries")
        if not isinstance(retries, int) or retries < 1:
            errors.append(f"{loc} max_retries 必须为正整数")
    for skill in ("start", "project-stage-detect", "gate-check"):
        matches = list((manifest_path.parent / "skills").rglob(f"{skill}/SKILL.md"))
        if len(matches) != 1 or "workflow-catalog.yaml" not in matches[0].read_text(encoding="utf-8"):
            errors.append(f"{skill} 必须唯一存在并读取 workflow-catalog.yaml")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog", type=Path,
                        default=REPO / "UEGameStudio" / "docs" / "workflow-catalog.yaml")
    parser.add_argument("--manifest", type=Path,
                        default=REPO / "UEGameStudio" / "manifest.json")
    args = parser.parse_args()
    errors = validate(args.catalog, args.manifest)
    if errors:
        for error in errors:
            print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    print("OK：workflow schema v2、7 阶段顺序、owner/reviewer/skill 路由与 gate 消费契约通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
