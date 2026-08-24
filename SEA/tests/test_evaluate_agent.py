import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "evaluate_agent", ROOT / "SEA" / "scripts" / "evaluate-agent.py")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AgentEvaluatorTests(unittest.TestCase):
    def test_default_deny_and_fail_closed_are_independent_assertions(self):
        text = """---
name: sample
description: Use when testing an agent.
mode: subagent
permission:
  "*": deny
  read: allow
  task: deny
  external_directory: deny
---
# Sample
## 职责边界
不做最终用户决策。
先解析配置根；读取 docs/VERSION.md，未核实时 fail-closed。
输出证据与交付清单。
"""
        result = MODULE.evaluate_text("agents/sample.md", text)
        self.assertEqual(result["score"], 1.0)
        self.assertTrue(all(result["assertions"].values()))

        permissive = text.replace('  "*": deny\n', "")
        result = MODULE.evaluate_text("agents/sample.md", permissive)
        self.assertFalse(result["assertions"]["default_deny"])
        self.assertEqual(result["score"], 0.9)

    def test_general_academic_profile_rejects_ue_binding(self):
        text = """---
name: historian
description: 通用历史顾问，不绑定行业。Use when 核实历史事实。
mode: subagent
permission:
  "*": deny
  task: deny
  external_directory: deny
---
# 通用历史顾问
## 职责边界
不替代档案鉴定；输出证据报告。
## 证据纪律
优先使用档案和同行评审研究；无法核实时标记 UNVERIFIED。
"""
        path = "UEGameStudio/agents/academic/historian.md"
        result = MODULE.evaluate_text(path, text)
        self.assertIn(result["profile"], {"general-academic", "general-core"})
        self.assertEqual(result["score"], 1.0)

        coupled = text + "读取 UEGameStudio 的 engine-reference/unreal。"
        result = MODULE.evaluate_text(path, coupled)
        self.assertFalse(result["assertions"]["engine_independent"])
        self.assertEqual(result["score"], 0.9)

    def test_neutral_template_cannot_seed_unreal_coupling(self):
        text = """---
name: <kebab-name>
description: 通用模板。Use when 创建角色。
mode: subagent
permission:
  "*": deny
  task: deny
  external_directory: deny
---
## 职责边界
不替代调用方；输出证据与验证结果。
无法核实时标记 UNVERIFIED。
"""
        result = MODULE.evaluate_text("UEGameStudio/agents/_template.md", text)
        self.assertEqual(result["profile"], "neutral-template")
        self.assertEqual(result["score"], 1.0)
        coupled = text + "读取 Unreal Engine VERSION.md。"
        result = MODULE.evaluate_text("UEGameStudio/agents/_template.md", coupled)
        self.assertFalse(result["assertions"]["engine_independent"])


if __name__ == "__main__":
    unittest.main()
