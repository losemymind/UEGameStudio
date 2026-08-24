import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
EVALUATOR = ROOT / "SEA" / "scripts" / "evaluate-skill.py"


class EvaluationProtocolTests(unittest.TestCase):
    def test_emit_keeps_complete_skill_and_v2_assertions(self):
        with tempfile.TemporaryDirectory() as td:
            base = Path(td)
            skill = base / "skills" / "long-skill"
            skill.mkdir(parents=True)
            tail = "TAIL-MUST-BE-JUDGED"
            (skill / "SKILL.md").write_text(
                "---\nname: long-skill\ndescription: Test. Use when testing.\n---\n"
                + ("正文" * 4000) + tail,
                encoding="utf-8",
            )
            (skill / "test-prompts.json").write_text(json.dumps({
                "schema_version": 2,
                "skill": "long-skill",
                "prompts": [{
                    "id": "heldout-1",
                    "task": "run",
                    "expect": "tail exists and no write occurs",
                    "assertions": ["tail exists", "no write occurs"],
                    "immutable_paths": ["fixture/input.txt"],
                    "category": "failure",
                    "verifiable": True,
                    "split": "heldout",
                }],
            }), encoding="utf-8")
            request = base / "request.json"
            result = subprocess.run([
                sys.executable, str(EVALUATOR), "--mode", "judge",
                "--skill", "long-skill", "--split", "heldout",
                "--skills-dir", str(base / "skills"), "--emit", str(request),
                "--model", "test-model",
            ], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            emitted = json.loads(request.read_text(encoding="utf-8"))
            self.assertEqual(emitted["version"], 2)
            self.assertIn(tail, emitted["skill_text"])
            self.assertEqual(emitted["cases"][0]["assertions"],
                             ["tail exists", "no write occurs"])
            self.assertEqual(emitted["cases"][0]["immutable_paths"],
                             ["fixture/input.txt"])

            request_hash = hashlib.sha256(request.read_bytes()).hexdigest()
            answers = request.with_suffix(request.suffix + ".answers.json")
            answers.write_text(json.dumps({
                "protocol": "sea-inline-judge-answer",
                "version": 2,
                "request_sha256": request_hash,
                "judge_model": "test-model",
                "decisions": [{
                    "index": 1,
                    "assertion_results": [True, True],
                    "evidence": "完整正文含 tail；规则明确禁止写入。",
                }],
            }), encoding="utf-8")
            applied = subprocess.run([
                sys.executable, str(EVALUATOR), "--mode", "judge",
                "--skill", "long-skill", "--split", "heldout",
                "--skills-dir", str(base / "skills"), "--apply", str(request),
                "--model", "test-model", "--json",
            ], capture_output=True, text=True)
            self.assertEqual(applied.returncode, 0, applied.stderr)
            self.assertEqual(json.loads(applied.stdout)["score"], 1.0)

            with (skill / "SKILL.md").open("a", encoding="utf-8") as stream:
                stream.write("\nchanged-after-emit")
            stale = subprocess.run([
                sys.executable, str(EVALUATOR), "--mode", "judge",
                "--skill", "long-skill", "--split", "heldout",
                "--skills-dir", str(base / "skills"), "--apply", str(request),
                "--model", "test-model", "--json",
            ], capture_output=True, text=True)
            self.assertNotEqual(stale.returncode, 0)
            self.assertIn("emit 后变化", stale.stderr)


if __name__ == "__main__":
    unittest.main()
