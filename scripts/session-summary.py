#!/usr/bin/env python3
"""Session Summary Generator - Stop hook script

Every Stop, parses the current session transcript and overwrites
<project>/memory/last-session.md with a concise summary.
Next session, Claude can read this for prior context.
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path


def find_transcript():
    path = os.environ.get("CLAUDE_TRANSCRIPT_PATH", "")
    if path and os.path.isfile(path):
        return path

    # Fallback: most recent .jsonl in project directories
    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        return None

    latest = None
    latest_mtime = 0
    for jsonl in projects_dir.rglob("*.jsonl"):
        if jsonl.parent.name in ("memory", "backup", "logs"):
            continue
        mtime = jsonl.stat().st_mtime
        if mtime > latest_mtime:
            latest_mtime = mtime
            latest = jsonl

    return str(latest) if latest else None


def parse_transcript(path):
    user_messages = []
    files_edited = set()
    files_created = set()

    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg = entry.get("message", {})
            if not msg:
                continue

            role = msg.get("role", "")
            content = msg.get("content", "")

            # User messages
            if role == "user":
                if isinstance(content, str):
                    text = content.strip()
                elif isinstance(content, list):
                    text = " ".join(
                        p.get("text", "")
                        for p in content
                        if isinstance(p, dict) and p.get("type") == "text"
                    ).strip()
                else:
                    text = ""

                if text and not text.startswith("<"):
                    user_messages.append(text[:300])

            # Tool usage from assistant messages
            if role == "assistant" and isinstance(content, list):
                for part in content:
                    if not isinstance(part, dict) or part.get("type") != "tool_use":
                        continue

                    tool = part.get("name", "")
                    inp = part.get("input", {})

                    if tool == "Write":
                        fp = inp.get("file_path", "")
                        if fp:
                            files_created.add(fp)
                    elif tool == "Edit":
                        fp = inp.get("file_path", "")
                        if fp:
                            files_edited.add(fp)

    return user_messages, files_edited, files_created


MAX_FIRST = 3   # session intent
MAX_LAST = 5    # recent context
MAX_FILES = 15  # file list cap


def truncate_messages(messages):
    """Keep first N + last M messages, skip middle."""
    total = len(messages)
    if total <= MAX_FIRST + MAX_LAST:
        return messages, False

    first = messages[:MAX_FIRST]
    last = messages[-MAX_LAST:]
    skipped = total - MAX_FIRST - MAX_LAST
    return first + [f"... ({skipped} messages skipped) ..."] + last, True


def generate_summary(path, user_messages, files_edited, files_created):
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    session_id = Path(path).stem[:8]
    display_msgs, was_truncated = truncate_messages(user_messages)

    lines = [
        "# Last Session Summary",
        "",
        f"- **Date**: {now}",
        f"- **Session**: `{session_id}...`",
        f"- **Messages**: {len(user_messages)}",
        "",
        "## Conversation",
    ]

    for i, msg in enumerate(display_msgs, 1):
        clean = msg.replace("\n", " ").strip()
        if len(clean) > 150:
            clean = clean[:147] + "..."
        lines.append(f"{i}. {clean}")

    all_files = (
        [(f, "edit") for f in sorted(files_edited)]
        + [(f, "new") for f in sorted(files_created)]
    )
    if all_files:
        lines.append("")
        lines.append("## Files Changed")
        for f, kind in all_files[:MAX_FILES]:
            lines.append(f"- ({kind}) `{f}`")
        remaining = len(all_files) - MAX_FILES
        if remaining > 0:
            lines.append(f"- ... and {remaining} more files")

    lines.append("")
    return "\n".join(lines)


def main():
    try:
        path = find_transcript()
        if not path:
            return

        user_messages, files_edited, files_created = parse_transcript(path)

        if len(user_messages) < 2:
            return

        project_dir = os.path.dirname(path)
        memory_dir = os.path.join(project_dir, "memory")
        os.makedirs(memory_dir, exist_ok=True)

        summary = generate_summary(path, user_messages, files_edited, files_created)

        summary_path = os.path.join(memory_dir, "last-session.md")
        with open(summary_path, "w") as f:
            f.write(summary)

    except Exception:
        pass


if __name__ == "__main__":
    main()
