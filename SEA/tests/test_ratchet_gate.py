import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RATCHET = ROOT / "SEA" / "scripts" / "ratchet-gate.py"


class RatchetGateTests(unittest.TestCase):
    def test_emit_collect_waits_for_hitl_without_mutating_registry(self):
        with tempfile.TemporaryDirectory() as td:
            base = Path(td)
            skills = base / "skills"
            skill = skills / "sample"
            registry = skills / "_evolutions" / "evolutions.json"
            skill.mkdir(parents=True)
            registry.parent.mkdir(parents=True)
            (skill / "SKILL.md").write_text(
                "---\nname: sample\ndescription: Test. Use when testing.\n---\n"
                "Always preserve input.txt and report evidence.",
                encoding="utf-8",
            )
            (skill / "test-prompts.json").write_text(json.dumps({
                "schema_version": 2,
                "skill": "sample",
                "prompts": [{
                    "id": "heldout-1",
                    "task": "inspect fixture",
                    "expect": "input is preserved",
                    "assertions": ["input.txt is not modified"],
                    "immutable_paths": ["input.txt"],
                    "category": "failure",
                    "verifiable": True,
                    "split": "heldout",
                }],
            }), encoding="utf-8")
            initial_registry = {
                "schema_version": 1,
                "evolutions": [{
                    "id": "ev-test-001",
                    "skill": "sample",
                    "status": "pending",
                    "score_before": 0.5,
                }],
            }
            registry.write_text(json.dumps(initial_registry), encoding="utf-8")
            requests = base / "requests"

            emitted = subprocess.run([
                sys.executable, str(RATCHET), "--skills-dir", str(skills),
                "--emit-dir", str(requests), "--model", "test-model",
            ], capture_output=True, text=True)
            self.assertEqual(emitted.returncode, 2, emitted.stderr)
            self.assertEqual(json.loads(registry.read_text(encoding="utf-8")),
                             initial_registry)

            request = requests / "sample.json"
            answer = request.with_suffix(request.suffix + ".answers.json")
            answer.write_text(json.dumps({
                "protocol": "sea-inline-judge-answer",
                "version": 2,
                "request_sha256": hashlib.sha256(request.read_bytes()).hexdigest(),
                "judge_model": "test-model",
                "decisions": [{
                    "index": 1,
                    "assertion_results": [True],
                    "evidence": "SKILL.md explicitly requires preserving input.txt.",
                }],
            }), encoding="utf-8")

            collected = subprocess.run([
                sys.executable, str(RATCHET), "--skills-dir", str(skills),
                "--collect-dir", str(requests), "--model", "test-model",
            ], capture_output=True, text=True)
            self.assertEqual(collected.returncode, 0, collected.stderr)
            self.assertIn("PASS-AWAITING-HITL", collected.stdout)
            self.assertEqual(json.loads(registry.read_text(encoding="utf-8")),
                             initial_registry)


if __name__ == "__main__":
    unittest.main()
