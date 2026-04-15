#!/usr/bin/env python3
"""Skill Matcher - UserPromptSubmit hook script

Reads the user's prompt from stdin, matches it against skill activation
rules in .claude/skill-rules.json, and outputs context injection text
for auto-activated or suggested skills.

Exit 0 always (non-blocking). Uses only Python stdlib.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path

RULES_FILENAME = ".claude/skill-rules.json"
DEFAULT_LOG_PATH = ".claude/state/skill-activation.log"


def load_rules(project_dir: str) -> dict | None:
    """Load skill rules from project dir, then fall back to ~/.claude/."""
    candidates = [
        Path(project_dir) / RULES_FILENAME,
        Path.home() / ".claude" / "skill-rules.json",
    ]
    for path in candidates:
        if path.is_file():
            try:
                with open(path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except (json.JSONDecodeError, OSError):
                continue
    return None


def read_log(log_path: Path) -> dict[str, float]:
    """Read activation log and return {skill_name: last_activation_timestamp}."""
    activations: dict[str, float] = {}
    if not log_path.is_file():
        return activations
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    skill = entry.get("skill", "")
                    ts = entry.get("timestamp", 0.0)
                    if skill and ts:
                        activations[skill] = max(activations.get(skill, 0.0), ts)
                except json.JSONDecodeError:
                    continue
    except OSError:
        pass
    return activations


def write_log_entry(log_path: Path, skill: str, mode: str, prompt_snippet: str) -> None:
    """Append a single activation entry to the log file."""
    log_path.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": time.time(),
        "skill": skill,
        "mode": mode,
        "prompt_snippet": prompt_snippet[:80],
    }
    try:
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except OSError:
        pass


def is_cooldown_active(
    skill: str,
    cooldown_seconds: int,
    activations: dict[str, float],
    now: float,
) -> bool:
    """Check if the skill is within its cooldown window."""
    if cooldown_seconds <= 0:
        return False
    last = activations.get(skill, 0.0)
    return (now - last) < cooldown_seconds


def matches_prompt_patterns(prompt: str, patterns: list[str]) -> bool:
    """Return True if any regex pattern matches the prompt."""
    for pattern in patterns:
        try:
            if re.search(pattern, prompt, re.IGNORECASE):
                return True
        except re.error:
            continue
    return False


def matches_file_patterns(file_patterns: list[str], project_dir: str) -> bool:
    """Check if any file matching the glob patterns exists in the project.

    Uses a shallow check: walks the project tree once and tests each
    filename against the patterns. Skips hidden dirs and node_modules
    for performance.
    """
    import fnmatch

    skip_dirs = {".git", "node_modules", ".next", "__pycache__", ".venv", "venv"}
    project = Path(project_dir)

    for pattern in file_patterns:
        # Strip leading **/ for simple filename matching
        simple_pattern = pattern.lstrip("*").lstrip("/")

        for root, dirs, files in os.walk(project):
            # Prune hidden and heavy directories
            dirs[:] = [d for d in dirs if d not in skip_dirs and not d.startswith(".")]

            for filename in files:
                rel_path = os.path.relpath(os.path.join(root, filename), project)
                if fnmatch.fnmatch(filename, simple_pattern) or fnmatch.fnmatch(
                    rel_path, pattern
                ):
                    return True
    return False


def evaluate_conditions(conditions: list[str], project_dir: str) -> bool:
    """Evaluate structural conditions against the project directory.

    Supported conditions:
    - tests_dir_exists: checks for tests/, __tests__/, test/
    - audit_rules_dir_exists: checks for .claude/audit-rules/
    - difficulty >= medium: always True (actual difficulty is assessed by Claude)
    - function_lines >= N: always False (requires AST analysis, not done here)
    - no_try_catch: always False (requires AST analysis, not done here)
    """
    project = Path(project_dir)

    for condition in conditions:
        condition = condition.strip()

        if condition == "tests_dir_exists":
            test_dirs = ["tests", "__tests__", "test"]
            if not any((project / d).is_dir() for d in test_dirs):
                return False

        elif condition == "audit_rules_dir_exists":
            if not (project / ".claude" / "audit-rules").is_dir():
                return False

        elif condition.startswith("difficulty"):
            # Difficulty is assessed by Claude at runtime, not by this script.
            # Pass through: let Claude decide whether to actually invoke.
            continue

        elif condition.startswith("function_lines") or condition == "no_try_catch":
            # These require AST analysis beyond this script's scope.
            # Return False to avoid false-positive suggestions.
            return False

    return True


def match_rules(
    prompt: str,
    rules_data: dict,
    project_dir: str,
) -> list[tuple[dict, str]]:
    """Match prompt against all rules and return matched (rule, output_text) pairs."""
    rules = rules_data.get("rules", [])
    settings = rules_data.get("settings", {})
    log_rel = settings.get("log_file", DEFAULT_LOG_PATH)
    log_path = Path(project_dir) / log_rel

    activations = read_log(log_path)
    now = time.time()
    matched: list[tuple[dict, str]] = []

    for rule in rules:
        skill = rule.get("skill", "")
        mode = rule.get("mode", "suggest")
        triggers = rule.get("triggers", {})
        cooldown = rule.get("cooldown", 0)

        # Check cooldown for auto-mode skills
        if mode == "auto" and is_cooldown_active(skill, cooldown, activations, now):
            continue

        # Evaluate prompt patterns
        prompt_patterns = triggers.get("prompt_patterns", [])
        has_prompt_match = matches_prompt_patterns(prompt, prompt_patterns) if prompt_patterns else False

        # Evaluate file patterns
        file_patterns = triggers.get("file_patterns", [])
        has_file_match = matches_file_patterns(file_patterns, project_dir) if file_patterns else False

        # Evaluate conditions
        conditions = triggers.get("conditions", [])
        conditions_met = evaluate_conditions(conditions, project_dir) if conditions else True

        # Determine if rule triggers:
        # - If both prompt_patterns and file_patterns exist, both must match
        # - If only prompt_patterns, prompt must match
        # - If only file_patterns, file must match
        # - If only conditions, conditions must be met
        # - conditions are always required when present
        has_prompt_spec = len(prompt_patterns) > 0
        has_file_spec = len(file_patterns) > 0
        has_conditions = len(conditions) > 0

        if not has_prompt_spec and not has_file_spec and not has_conditions:
            continue

        if has_conditions and not conditions_met:
            continue

        if has_prompt_spec and has_file_spec:
            triggered = has_prompt_match and has_file_match
        elif has_prompt_spec:
            triggered = has_prompt_match
        elif has_file_spec:
            triggered = has_file_match
        else:
            # Only conditions, already verified above
            triggered = True

        if not triggered:
            continue

        # Build output
        if mode == "auto":
            output = f"⚡ Auto-activating /{skill} based on pattern detection"
        else:
            output = rule.get("message", f"💡 제안: /{skill} (Y/n)")

        matched.append((rule, output))

        # Log the activation
        write_log_entry(log_path, skill, mode, prompt)

    return matched


def find_project_dir() -> str:
    """Determine the project root directory.

    Uses CLAUDE_PROJECT_DIR env var if available, otherwise walks up
    from cwd looking for .claude/ or .git/.
    """
    env_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if env_dir and os.path.isdir(env_dir):
        return env_dir

    cwd = Path.cwd()
    for parent in [cwd, *cwd.parents]:
        if (parent / ".claude").is_dir() or (parent / ".git").is_dir():
            return str(parent)

    return str(cwd)


def main() -> None:
    try:
        # Read prompt from stdin (non-blocking: read whatever is available)
        prompt = ""
        if not sys.stdin.isatty():
            prompt = sys.stdin.read().strip()

        if not prompt:
            sys.exit(0)

        project_dir = find_project_dir()
        rules_data = load_rules(project_dir)
        if not rules_data:
            sys.exit(0)

        settings = rules_data.get("settings", {})
        max_auto = settings.get("max_auto_per_session", 10)

        matches = match_rules(prompt, rules_data, project_dir)

        # Respect max_auto_per_session: count only auto-mode activations
        auto_count = 0
        output_lines = []
        for rule, text in matches:
            if rule.get("mode") == "auto":
                auto_count += 1
                if auto_count > max_auto:
                    continue
            output_lines.append(text)

        if output_lines:
            print("\n".join(output_lines))

    except Exception:
        # Never crash; exit silently on any unexpected error
        pass

    sys.exit(0)


if __name__ == "__main__":
    main()
