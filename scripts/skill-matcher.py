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
LOG_MAX_LINES = 500      # rotate when the log grows past this ...
LOG_KEEP_LINES = 250     # ... keeping only the newest entries


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


def read_log(log_path: Path, session_id: str = "") -> tuple[dict[str, float], int]:
    """Read the activation log.

    Returns ({skill_name: last_activation_timestamp}, auto_count_this_session).
    The per-session auto count is what makes settings.max_auto_per_session a
    real session limit instead of a per-prompt one.
    """
    activations: dict[str, float] = {}
    session_auto = 0
    if not log_path.is_file():
        return activations, session_auto
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                skill = entry.get("skill", "")
                ts = entry.get("timestamp", 0.0)
                if skill and ts:
                    activations[skill] = max(activations.get(skill, 0.0), ts)
                if (
                    session_id
                    and entry.get("mode") == "auto"
                    and entry.get("session_id") == session_id
                ):
                    session_auto += 1
    except OSError:
        pass
    return activations, session_auto


def rotate_log(log_path: Path) -> None:
    """Keep the log bounded: past LOG_MAX_LINES, retain the newest LOG_KEEP_LINES."""
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        if len(lines) <= LOG_MAX_LINES:
            return
        with open(log_path, "w", encoding="utf-8") as f:
            f.writelines(lines[-LOG_KEEP_LINES:])
    except OSError:
        pass


def write_log_entry(
    log_path: Path, skill: str, mode: str, prompt_snippet: str, session_id: str = ""
) -> None:
    """Append a single activation entry to the log file."""
    log_path.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": time.time(),
        "skill": skill,
        "mode": mode,
        "session_id": session_id,
        "prompt_snippet": prompt_snippet[:80],
    }
    try:
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except OSError:
        pass
    rotate_log(log_path)


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


_REGEX_METACHARS = set("\\^$.|?*+()[]{}")


def compile_pattern(pattern: str) -> str:
    """Prepare a pattern for matching.

    Plain ASCII literals (no regex metacharacters) get word boundaries on
    word-character ends so short tokens like "PR" or "fix" cannot match
    inside "projects" or "prefix". Non-ASCII (e.g. Korean) patterns keep
    substring semantics because verb stems match conjugations that way.
    Patterns containing regex metacharacters pass through unchanged.
    """
    if not pattern.isascii() or any(c in _REGEX_METACHARS for c in pattern):
        return pattern
    escaped = re.escape(pattern)
    if pattern and (pattern[0].isalnum() or pattern[0] == "_"):
        escaped = r"\b" + escaped
    if pattern and (pattern[-1].isalnum() or pattern[-1] == "_"):
        escaped = escaped + r"\b"
    return escaped


def matches_prompt_patterns(prompt: str, patterns: list[str]) -> bool:
    """Return True if any regex pattern matches the prompt."""
    for pattern in patterns:
        try:
            if re.search(compile_pattern(pattern), prompt, re.IGNORECASE):
                return True
        except re.error:
            continue
    return False


MAX_WALK_DEPTH = 4
MAX_WALK_ENTRIES = 20000


class ProjectFiles:
    """Lazily-built, bounded listing of project files for glob matching.

    The tree is walked at most once per hook invocation, and only when a rule
    actually needs a file check (i.e. its prompt patterns already matched).
    Skips hidden dirs and node_modules; refuses to scan the home directory or
    filesystem root; bounds depth/entries so a large tree cannot stall the
    prompt hook.
    """

    SKIP_DIRS = {".git", "node_modules", ".next", "__pycache__", ".venv", "venv"}

    def __init__(self, project_dir: str) -> None:
        self.project = Path(project_dir).resolve()
        self._names: list[str] | None = None      # basenames
        self._rel_paths: list[str] | None = None  # paths relative to project

    def _walk(self) -> None:
        self._names, self._rel_paths = [], []
        if self.project == Path.home() or self.project == Path(self.project.anchor):
            return
        base_depth = len(self.project.parts)
        seen = 0
        for root, dirs, files in os.walk(self.project):
            if len(Path(root).parts) - base_depth >= MAX_WALK_DEPTH:
                dirs[:] = []
            else:
                dirs[:] = [d for d in dirs if d not in self.SKIP_DIRS and not d.startswith(".")]
            for filename in files:
                seen += 1
                if seen > MAX_WALK_ENTRIES:
                    return
                self._names.append(filename)
                self._rel_paths.append(os.path.relpath(os.path.join(root, filename), self.project))

    def matches_any(self, file_patterns: list[str]) -> bool:
        import fnmatch

        if self._names is None:
            self._walk()
        assert self._names is not None and self._rel_paths is not None
        for pattern in file_patterns:
            # "**/x" means "x at any depth"; a pattern without "/" is a basename glob.
            bare = pattern[3:] if pattern.startswith("**/") else pattern
            if "/" in bare:
                if any(fnmatch.fnmatch(rp, bare) for rp in self._rel_paths):
                    return True
            elif any(fnmatch.fnmatch(name, bare) for name in self._names):
                return True
        return False


def matches_file_patterns(file_patterns: list[str], project_dir: str) -> bool:
    """One-off convenience wrapper around ProjectFiles (tests, callers)."""
    return ProjectFiles(project_dir).matches_any(file_patterns)


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
    session_id: str = "",
) -> list[tuple[dict, str]]:
    """Match prompt against all rules and return matched (rule, output_text) pairs.

    Auto-mode activations are capped by settings.max_auto_per_session, counted
    across the whole session via the activation log; suggestions are never capped.
    """
    rules = rules_data.get("rules", [])
    settings = rules_data.get("settings", {})
    log_rel = settings.get("log_file", DEFAULT_LOG_PATH)
    log_path = Path(project_dir) / log_rel
    max_auto = settings.get("max_auto_per_session", 10)

    activations, session_auto = read_log(log_path, session_id)
    files = ProjectFiles(project_dir)
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

        prompt_patterns = triggers.get("prompt_patterns", [])
        file_patterns = triggers.get("file_patterns", [])
        conditions = triggers.get("conditions", [])
        has_prompt_spec = len(prompt_patterns) > 0
        has_file_spec = len(file_patterns) > 0
        has_conditions = len(conditions) > 0

        if not has_prompt_spec and not has_file_spec and not has_conditions:
            continue

        # Session-wide cap on auto activations (suggestions are never capped)
        if mode == "auto" and session_auto >= max_auto:
            continue

        # Cheapest checks first; the filesystem walk runs only when a rule
        # still can trigger after its prompt patterns matched.
        if has_prompt_spec and not matches_prompt_patterns(prompt, prompt_patterns):
            continue
        if has_conditions and not evaluate_conditions(conditions, project_dir):
            continue
        if has_file_spec and not files.matches_any(file_patterns):
            continue

        # Build output
        if mode == "auto":
            output = f"⚡ Auto-activating /{skill} based on pattern detection"
        else:
            output = rule.get("message", f"💡 제안: /{skill} (Y/n)")

        matched.append((rule, output))
        if mode == "auto":
            session_auto += 1

        # Log the activation (auto entries feed the cooldown and the session cap)
        write_log_entry(log_path, skill, mode, prompt, session_id)

    return matched


def find_project_dir(cwd_hint: str = "") -> str:
    """Determine the project root directory.

    Uses CLAUDE_PROJECT_DIR env var if available, otherwise walks up
    from the hook payload's cwd (or the process cwd) looking for
    .claude/ or .git/.
    """
    env_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if env_dir and os.path.isdir(env_dir):
        return env_dir

    cwd = Path(cwd_hint) if cwd_hint and os.path.isdir(cwd_hint) else Path.cwd()
    for parent in [cwd, *cwd.parents]:
        if (parent / ".claude").is_dir() or (parent / ".git").is_dir():
            return str(parent)

    return str(cwd)


def read_hook_input() -> tuple[str, str, str]:
    """Read the UserPromptSubmit payload from stdin → (prompt, cwd, session_id).

    Claude Code sends a JSON object like {"prompt": ..., "cwd": ...,
    "session_id": ..., "transcript_path": ...}. Only the prompt field may be
    pattern-matched; matching the raw payload makes patterns hit path
    fragments such as "projects" on every message. Raw text stdin is kept as
    a fallback for manual testing.
    """
    if sys.stdin.isatty():
        return "", "", ""
    raw = sys.stdin.read().strip()
    if raw.startswith("{"):
        try:
            payload = json.loads(raw)
            return (
                str(payload.get("prompt", "")),
                str(payload.get("cwd", "")),
                str(payload.get("session_id", "")),
            )
        except json.JSONDecodeError:
            pass
    return raw, "", ""


def main() -> None:
    try:
        prompt, cwd_hint, session_id = read_hook_input()

        if not prompt:
            sys.exit(0)

        project_dir = find_project_dir(cwd_hint)
        rules_data = load_rules(project_dir)
        if not rules_data:
            sys.exit(0)

        matches = match_rules(prompt, rules_data, project_dir, session_id)

        # UserPromptSubmit: plain stdout on exit 0 is injected as context.
        output_lines = [text for _, text in matches]
        if output_lines:
            print("\n".join(output_lines))

    except Exception:
        # Never crash; exit silently on any unexpected error
        pass

    sys.exit(0)


if __name__ == "__main__":
    main()
