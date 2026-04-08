#!/usr/bin/env python3
"""Injection Scanner - PostToolUse hook for mcp__* matchers

Reads MCP tool output from stdin (or CLAUDE_TOOL_OUTPUT env var),
scans for prompt injection patterns, data exfiltration attempts,
encoded payloads, and secret leakage.

Exit 0 always (warning only, non-blocking). Uses only Python stdlib.
"""

import base64
import json
import os
import re
import sys
from dataclasses import dataclass, field

# ---------------------------------------------------------------------------
# Pattern definitions
# ---------------------------------------------------------------------------

HIDDEN_INSTRUCTION_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"<\s*system\s*>", re.IGNORECASE),
    re.compile(r"<\s*instructions?\s*>", re.IGNORECASE),
    re.compile(r"<\s*override\s*>", re.IGNORECASE),
    re.compile(r"<\s*ignore\s*>", re.IGNORECASE),
    re.compile(r"<\s*prompt\s*>", re.IGNORECASE),
    re.compile(r"<!--\s*instructions?", re.IGNORECASE),
]

ROLE_CONFUSION_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"you\s+are\s+now\b", re.IGNORECASE),
    re.compile(r"ignore\s+previous\b", re.IGNORECASE),
    re.compile(r"forget\s+your\s+instructions?\b", re.IGNORECASE),
    re.compile(r"new\s+system\s+prompt\b", re.IGNORECASE),
    re.compile(r"disregard\s+(all\s+)?(previous|prior|above)\b", re.IGNORECASE),
    re.compile(r"act\s+as\s+(a\s+)?different\b", re.IGNORECASE),
]

EXFILTRATION_PATTERNS: list[re.Pattern[str]] = [
    # URLs with base64-encoded data segments (long b64 blocks in path/query)
    re.compile(r"https?://[^\s]*[A-Za-z0-9+/]{40,}={0,2}"),
    # Shell / network commands in unexpected output
    re.compile(r"\bfetch\s*\(", re.IGNORECASE),
    re.compile(r"\bcurl\s+", re.IGNORECASE),
    re.compile(r"\bwget\s+", re.IGNORECASE),
    re.compile(r"\bnc\s+-", re.IGNORECASE),  # netcat
]

SECRET_PATTERNS: list[re.Pattern[str]] = [
    # API key prefixes
    re.compile(r"\bsk-[A-Za-z0-9]{20,}"),         # OpenAI
    re.compile(r"\bsk-ant-[A-Za-z0-9]{20,}"),      # Anthropic
    re.compile(r"\bghp_[A-Za-z0-9]{36,}"),          # GitHub PAT
    re.compile(r"\bgho_[A-Za-z0-9]{36,}"),          # GitHub OAuth
    re.compile(r"\bglpat-[A-Za-z0-9\-]{20,}"),      # GitLab PAT
    re.compile(r"\bAKIA[A-Z0-9]{16}"),               # AWS access key
    re.compile(r"\bxoxb-[0-9]+-[A-Za-z0-9]+"),       # Slack bot token
    re.compile(r"\bxoxp-[0-9]+-[A-Za-z0-9]+"),       # Slack user token
    # Generic patterns
    re.compile(r"(?i)password\s*[:=]\s*[\"'][^\"']{8,}[\"']"),
    re.compile(r"(?i)api[_-]?key\s*[:=]\s*[\"'][^\"']{8,}[\"']"),
    re.compile(r"(?i)secret\s*[:=]\s*[\"'][^\"']{8,}[\"']"),
    re.compile(r"(?i)token\s*[:=]\s*[\"'][^\"']{8,}[\"']"),
    # Private keys
    re.compile(r"-----BEGIN\s+(RSA|EC|DSA|OPENSSH)?\s*PRIVATE\s+KEY-----"),
]

# Minimum length for a base64 segment to be worth decoding
_B64_MIN_LENGTH = 40

# Suspicious words to look for inside decoded base64 payloads
_B64_SUSPICIOUS_WORDS: list[str] = [
    "system",
    "ignore",
    "override",
    "instructions",
    "prompt",
    "password",
    "secret",
    "api_key",
    "token",
    "curl",
    "wget",
    "fetch",
]


# ---------------------------------------------------------------------------
# Finding data class
# ---------------------------------------------------------------------------

@dataclass
class Finding:
    category: str
    pattern_desc: str
    matched_text: str
    line_number: int = 0


# ---------------------------------------------------------------------------
# Scanning logic
# ---------------------------------------------------------------------------

def _truncate(text: str, max_len: int = 80) -> str:
    """Truncate text for display, avoiding secret leakage in output."""
    if len(text) <= max_len:
        return text
    return text[:max_len] + "..."


def scan_hidden_instructions(content: str) -> list[Finding]:
    findings: list[Finding] = []
    for pattern in HIDDEN_INSTRUCTION_PATTERNS:
        for match in pattern.finditer(content):
            findings.append(Finding(
                category="Hidden Instruction",
                pattern_desc=pattern.pattern,
                matched_text=_truncate(match.group()),
            ))
    return findings


def scan_role_confusion(content: str) -> list[Finding]:
    findings: list[Finding] = []
    for pattern in ROLE_CONFUSION_PATTERNS:
        for match in pattern.finditer(content):
            findings.append(Finding(
                category="Role Confusion",
                pattern_desc=pattern.pattern,
                matched_text=_truncate(match.group()),
            ))
    return findings


def scan_exfiltration(content: str) -> list[Finding]:
    findings: list[Finding] = []
    for pattern in EXFILTRATION_PATTERNS:
        for match in pattern.finditer(content):
            findings.append(Finding(
                category="Data Exfiltration",
                pattern_desc=pattern.pattern,
                matched_text=_truncate(match.group()),
            ))
    return findings


def scan_secrets(content: str) -> list[Finding]:
    findings: list[Finding] = []
    for pattern in SECRET_PATTERNS:
        for match in pattern.finditer(content):
            # Mask the actual secret value in output
            raw = match.group()
            masked = raw[:8] + "*" * min(len(raw) - 8, 20)
            findings.append(Finding(
                category="Secret/Credential",
                pattern_desc=pattern.pattern,
                matched_text=masked,
            ))
    return findings


def scan_encoded_payloads(content: str) -> list[Finding]:
    """Find base64-encoded strings and check decoded content for suspicion."""
    findings: list[Finding] = []
    b64_pattern = re.compile(r"[A-Za-z0-9+/]{%d,}={0,2}" % _B64_MIN_LENGTH)

    for match in b64_pattern.finditer(content):
        candidate = match.group()
        try:
            # Attempt decode
            decoded = base64.b64decode(candidate, validate=True).decode(
                "utf-8", errors="ignore"
            )
        except Exception:
            continue

        decoded_lower = decoded.lower()
        for word in _B64_SUSPICIOUS_WORDS:
            if word in decoded_lower:
                findings.append(Finding(
                    category="Encoded Payload",
                    pattern_desc=f"base64 decoded contains '{word}'",
                    matched_text=_truncate(candidate, 40),
                ))
                break  # one finding per b64 block is enough

    return findings


def scan(content: str) -> list[Finding]:
    """Run all scanners against content and return findings."""
    all_findings: list[Finding] = []
    all_findings.extend(scan_hidden_instructions(content))
    all_findings.extend(scan_role_confusion(content))
    all_findings.extend(scan_exfiltration(content))
    all_findings.extend(scan_secrets(content))
    all_findings.extend(scan_encoded_payloads(content))
    return all_findings


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

def format_warning(findings: list[Finding], source: str) -> str:
    """Format findings into a human-readable warning string."""
    lines: list[str] = []
    lines.append(
        "\u26a0\ufe0f Injection Scanner: "
        "MCP \uc751\ub2f5\uc5d0\uc11c \uc758\uc2ec\uc2a4\ub7ec\uc6b4 "
        "\ud328\ud134 \uac10\uc9c0"
    )

    # Deduplicate by category + matched_text
    seen: set[tuple[str, str]] = set()
    for f in findings:
        key = (f.category, f.matched_text)
        if key in seen:
            continue
        seen.add(key)
        lines.append(f"  Pattern: [{f.category}] {f.matched_text}")

    lines.append(f"  Source: {source}")
    lines.append(
        "  Action: \ucd9c\ub825\uc744 "
        "\uac80\ud1a0\ud558\uc138\uc694."
    )
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def get_tool_source() -> str:
    """Determine which MCP tool produced the output, if available."""
    return os.environ.get("CLAUDE_TOOL_NAME", "unknown MCP tool")


def read_input() -> str:
    """Read tool output from stdin or CLAUDE_TOOL_OUTPUT env var."""
    # Prefer env var if set (some hook frameworks pass output there)
    env_output = os.environ.get("CLAUDE_TOOL_OUTPUT", "")
    if env_output:
        return env_output

    # Fall back to stdin
    if not sys.stdin.isatty():
        return sys.stdin.read()

    return ""


def main() -> None:
    try:
        content = read_input()
        if not content:
            sys.exit(0)

        findings = scan(content)
        if not findings:
            sys.exit(0)

        source = get_tool_source()
        warning = format_warning(findings, source)
        print(warning)

    except Exception:
        # Never crash; exit silently on any unexpected error
        pass

    sys.exit(0)


if __name__ == "__main__":
    main()
