"""Unit tests for scripts/skill-matcher.py (UserPromptSubmit hook).

Run: python3 -m unittest tests/test_skill_matcher.py
"""
from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "skill-matcher.py"

spec = importlib.util.spec_from_file_location("skill_matcher", SCRIPT)
sm = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(sm)


def make_project(rules: dict, files: list[str] = ()) -> str:
    d = tempfile.mkdtemp()
    (Path(d) / ".claude").mkdir()
    (Path(d) / ".claude" / "skill-rules.json").write_text(json.dumps(rules))
    for f in files:
        p = Path(d) / f
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text("x")
    return d


def rules(*rule_list, max_auto=10):
    return {"settings": {"max_auto_per_session": max_auto}, "rules": list(rule_list)}


class FilePatternTests(unittest.TestCase):
    def test_star_ext_matches_basename(self):
        # Regression: pattern.lstrip("*") turned "*.tsx" into ".tsx" (never matched)
        d = make_project({}, ["src/App.tsx"])
        self.assertTrue(sm.matches_file_patterns(["*.tsx"], d))
        self.assertFalse(sm.matches_file_patterns(["*.py"], d))

    def test_double_star_prefix(self):
        d = make_project({}, ["a/b/pyproject.toml"])
        self.assertTrue(sm.matches_file_patterns(["**/pyproject.toml"], d))
        self.assertTrue(sm.matches_file_patterns(["pyproject.toml"], d))

    def test_path_pattern_matches_rel_path(self):
        d = make_project({}, ["src/components/Button.tsx", "docs/x.tsx"])
        self.assertTrue(sm.matches_file_patterns(["src/*/*.tsx"], d))
        self.assertFalse(sm.matches_file_patterns(["lib/*.tsx"], d))

    def test_walk_is_lazy_and_single(self):
        d = make_project({}, ["a.py"])
        pf = sm.ProjectFiles(d)
        self.assertIsNone(pf._names)             # nothing walked yet
        pf.matches_any(["*.py"])
        pf.matches_any(["*.tsx"])
        self.assertIsNotNone(pf._names)
        walked = pf._names
        pf.matches_any(["*.md"])
        self.assertIs(pf._names, walked)         # same listing reused


class MatchRulesTests(unittest.TestCase):
    def test_no_walk_when_prompt_does_not_match(self):
        # file_patterns present but prompt miss → filesystem must not be touched
        d = make_project({}, ["App.tsx"])
        r = rules({"skill": "react", "mode": "auto",
                   "triggers": {"prompt_patterns": ["review"], "file_patterns": ["*.tsx"]}})
        calls = []
        orig = sm.ProjectFiles._walk
        sm.ProjectFiles._walk = lambda self: calls.append(1) or orig(self)
        try:
            self.assertEqual(sm.match_rules("fix the bug", r, d, "s1"), [])
            self.assertEqual(calls, [])
            self.assertEqual(len(sm.match_rules("please review", r, d, "s1")), 1)
            self.assertEqual(calls, [1])
        finally:
            sm.ProjectFiles._walk = orig

    def test_max_auto_is_per_session_not_per_prompt(self):
        d = make_project({})
        r = rules(
            {"skill": "a", "mode": "auto", "triggers": {"prompt_patterns": ["go"]}},
            {"skill": "b", "mode": "auto", "triggers": {"prompt_patterns": ["go"]}},
            {"skill": "s", "mode": "suggest", "triggers": {"prompt_patterns": ["go"]}},
            max_auto=3,
        )
        names = lambda m: [rule["skill"] for rule, _ in m]
        self.assertEqual(names(sm.match_rules("go", r, d, "sess")), ["a", "b", "s"])  # 2 auto
        self.assertEqual(names(sm.match_rules("go", r, d, "sess")), ["a", "s"])       # 3rd auto, cap hit
        self.assertEqual(names(sm.match_rules("go", r, d, "sess")), ["s"])            # suggestions never capped
        self.assertEqual(names(sm.match_rules("go", r, d, "other")), ["a", "b", "s"]) # new session, fresh cap

    def test_cooldown_applies_to_auto(self):
        d = make_project({})
        r = rules({"skill": "v", "mode": "auto", "cooldown": 600,
                   "triggers": {"prompt_patterns": ["commit"]}})
        self.assertEqual(len(sm.match_rules("commit it", r, d, "s")), 1)
        self.assertEqual(len(sm.match_rules("commit it", r, d, "s")), 0)

    def test_log_entry_has_session_and_rotates(self):
        d = make_project({})
        log = Path(d) / ".claude" / "state" / "skill-activation.log"
        r = rules({"skill": "x", "mode": "suggest", "triggers": {"prompt_patterns": ["hi"]}})
        sm.match_rules("hi", r, d, "sess-1")
        entry = json.loads(log.read_text().splitlines()[-1])
        self.assertEqual(entry["session_id"], "sess-1")
        # rotation
        log.write_text("".join(json.dumps({"skill": "x", "mode": "suggest", "timestamp": 1}) + "\n"
                               for _ in range(sm.LOG_MAX_LINES + 5)))
        sm.write_log_entry(log, "x", "suggest", "p", "s")
        self.assertEqual(len(log.read_text().splitlines()), sm.LOG_KEEP_LINES)


class EndToEndTests(unittest.TestCase):
    def test_hook_payload_roundtrip(self):
        d = make_project(rules({"skill": "tdd", "mode": "suggest",
                                "message": "💡 /tdd?",
                                "triggers": {"prompt_patterns": ["test"]}}))
        payload = json.dumps({"prompt": "write a test", "cwd": d, "session_id": "e2e"})
        out = subprocess.run([sys.executable, str(SCRIPT)], input=payload, text=True,
                             capture_output=True, env={**os.environ, "CLAUDE_PROJECT_DIR": d})
        self.assertEqual(out.returncode, 0)
        self.assertIn("/tdd", out.stdout)

    def test_silent_on_garbage(self):
        out = subprocess.run([sys.executable, str(SCRIPT)], input="{not json", text=True, capture_output=True)
        self.assertEqual(out.returncode, 0)


if __name__ == "__main__":
    unittest.main()
