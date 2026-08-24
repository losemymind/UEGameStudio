#!/usr/bin/env python3
"""对 OpenCode Markdown agent 定义做可复现的静态前后测。

同一套断言可评当前工作树或 Git ref，供 definition improvement 的
score_before/score_after 使用。目录目标按其中全部 Markdown 文件的平均分计分。
该评估是结构/安全 L0 门，不替代领域行为 L1 与 HITL。
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

try:
    from yaml import safe_load
except ImportError:  # pragma: no cover
    sys.stderr.write("缺少依赖：请先 `pip install -r SEA/requirements.txt`\n")
    sys.exit(2)


REPO = Path(__file__).resolve().parents[2]
MANIFEST_PATH = REPO / "UEGameStudio" / "manifest.json"
FRONTMATTER_RE = re.compile(r"\A---\s*\r?\n(?P<yaml>.*?)\r?\n---(?:\s*\r?\n|\Z)", re.DOTALL)
CORE_FORBIDDEN_RE = re.compile(
    r"(?i)UEGameStudio|engine-reference/unreal|ue-studio-orchestrator|"
    r"\bUnreal(?:\s+Engine)?\b|\bUE[45]?\b|\bEpic\b|\bGAS\b|GameplayAbility|"
    r"GameplayTags?|World Partition|Nanite|Lumen|Niagara|MetaSounds?|"
    r"\bUMG\b|CommonUI|Blueprint|UObject|UPROPERTY|UFUNCTION|BuildGraph|"
    r"\bUAT\b|\bUBT\b|Gauntlet|Unreal Insights|\bFText\b|Sequencer|Enhanced Input"
)


def manifest_profiles():
    if not MANIFEST_PATH.exists():
        return {}
    try:
        manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}
    return {
        Path(item["path"]).as_posix(): item.get("evaluation_profile")
        for item in manifest.get("agents", [])
        if isinstance(item, dict) and item.get("path") and item.get("evaluation_profile")
    }


def git_output(*args):
    command = ["git", "-c", f"safe.directory={REPO.as_posix()}", *args]
    result = subprocess.run(command, cwd=REPO, capture_output=True, text=True,
                            encoding="utf-8")
    return result.stdout if result.returncode == 0 else None


def validate_target(target):
    path = Path(target)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError("target 必须是仓库内相对路径且不能含 '..'")
    return path.as_posix()


def current_files(target):
    path = REPO / target
    if path.is_file():
        return [target]
    if path.is_dir():
        return sorted(p.relative_to(REPO).as_posix() for p in path.rglob("*.md"))
    return []


def git_files(target, ref):
    exact = git_output("cat-file", "-t", f"{ref}:{target}")
    if exact and exact.strip() == "blob":
        return [target]
    listed = git_output("ls-tree", "-r", "--name-only", ref, "--", target)
    if listed is None:
        return []
    return sorted(line for line in listed.splitlines() if line.endswith(".md"))


def read_text(path, ref=None):
    if ref:
        return git_output("show", f"{ref}:{path}") or ""
    file_path = REPO / path
    return file_path.read_text(encoding="utf-8") if file_path.exists() else ""


def evaluation_profile(path):
    """从 manifest 职责契约选择断言，路径只保留兼容回退。"""
    normalized = Path(path).as_posix()
    if normalized.endswith("agents/_template.md"):
        return "neutral-template"
    relative = normalized
    prefix = "UEGameStudio/"
    if relative.startswith(prefix):
        relative = relative[len(prefix):]
    profile = manifest_profiles().get(relative)
    if profile:
        return profile
    if "/agents/academic/" in f"/{normalized}":
        return "general-academic"
    return "unreal-specialist"


def evaluate_text(path, text):
    match = FRONTMATTER_RE.search(text)
    frontmatter = {}
    if match:
        try:
            frontmatter = safe_load(match.group("yaml")) or {}
        except Exception:
            frontmatter = {}
    permission = frontmatter.get("permission") if isinstance(frontmatter, dict) else None
    permission = permission if isinstance(permission, dict) else {}
    task = permission.get("task")
    task_is_closed = task == "deny" or (isinstance(task, dict) and task.get("*") == "deny")
    description = str(frontmatter.get("description", ""))
    body = text[match.end():] if match else text
    expected_name = Path(path).stem
    profile = evaluation_profile(path)
    assertions = {
        "valid_frontmatter": bool(match and isinstance(frontmatter, dict)),
        "canonical_name": frontmatter.get("name") == expected_name
        or (profile == "neutral-template" and frontmatter.get("name") == "<kebab-name>"),
        "trigger_description": bool(description and re.search(r"(?i)use\s+when|使用\s*when|何时使用", description)),
        "subagent_mode": frontmatter.get("mode") == "subagent",
        "default_deny": permission.get("*") == "deny",
        "task_closed_or_whitelisted": task_is_closed,
        "external_directory_denied": permission.get("external_directory") == "deny",
        "boundary_and_evidence": bool(re.search(r"职责边界|边界|不做|不得替代", body))
        and bool(re.search(r"证据|输出|交付", body)),
    }
    if profile in {"general-core", "game-core", "general-academic", "neutral-template"}:
        assertions.update({
            "engine_independent": not bool(CORE_FORBIDDEN_RE.search(text)),
            "domain_evidence_discipline": bool(re.search(
                r"证据|来源|实测|研究|验证|可追溯", body))
            and bool(re.search(r"UNVERIFIED|无法核实|不确定|假设|置信度|适用边界", body)),
        })
    elif profile == "integration":
        assertions.update({
            "canonical_router": bool(re.search(r"Canonical|canonical", body))
            and isinstance(task, dict) and task.get("*") == "deny",
            "version_sensitive_routing": "VERSION.md" in body and bool(re.search(
                r"(?i)fail-closed|BLOCKED_UNVERIFIED|未核实", body)),
        })
    else:  # unreal-specialist
        assertions.update({
            "version_fail_closed": "VERSION.md" in body and bool(re.search(
                r"(?i)fail-closed|BLOCKED_UNVERIFIED|未核实|未经版本验证", body)),
            "no_integration_reverse_dependency": "UEGameStudio" not in body
            and "ue-studio-orchestrator" not in body,
        })
    score = round(sum(assertions.values()) / len(assertions), 3)
    return {"path": path, "profile": profile, "score": score, "assertions": assertions}


def evaluate_target(target, ref=None):
    paths = git_files(target, ref) if ref else current_files(target)
    if not paths:
        return {"target": target, "ref": ref or "WORKTREE", "score": 0.0,
                "files": [], "missing": True, "eval_source": "l0-static"}
    files = [evaluate_text(path, read_text(path, ref)) for path in paths]
    return {"target": target, "ref": ref or "WORKTREE",
            "score": round(sum(item["score"] for item in files) / len(files), 3),
            "files": files, "missing": False, "eval_source": "l0-static"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", action="append", required=True,
                        help="仓库内 agent Markdown 文件或目录；可重复")
    parser.add_argument("--git-ref", help="评 Git 快照（如 HEAD）；不填评当前工作树")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        targets = [validate_target(value) for value in args.target]
    except ValueError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1
    results = [evaluate_target(target, args.git_ref) for target in targets]
    if args.json:
        print(json.dumps({"schema_version": 1, "results": results},
                         ensure_ascii=False, indent=2))
    else:
        for result in results:
            print(f"{result['target']}: {result['score']:.3f} "
                  f"({result['ref']}, {len(result['files'])} files, l0-static)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
