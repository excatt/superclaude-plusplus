# Session Protocols

세션 관리, 학습, 메모리 관련 프로토콜 상세.

## Note Protocol
**Priority**: 🟡 **Triggers**: 긴 세션, 컨텍스트 손실 우려

| Section | Purpose | Lifetime |
|------|------|------|
| Priority Context | Core info | Permanent (500 chars) |
| Working Memory | Temp notes | 7 days |
| MANUAL | Permanent info | Never deleted |

**Commands**: `/note <content>`, `/note --priority`, `/note --manual`, `/note --show`
**Auto-Suggest**: 50+ messages, 70%+ context

## Learning Protocol
**Priority**: 🟢 **Triggers**: 복잡한 문제 해결 후

**Save Criteria** (must meet all):
1. Non-Googleable: Not findable in 5 min search
2. Project-Specific: Specific to this codebase
3. Hard-Won: Actual debugging effort involved
4. Actionable: Includes specific files, lines, code

**Storage**: `~/.claude/skills/learned/`
**Auto-Suggest**: 에러 해결, 3회+ 시도 후 성공, "해결/찾았다/solved" 키워드

## Memory Management
**Priority**: 🟢 **Triggers**: 중요 정보 발견, 패턴 학습

### Auto Memory (built-in)
Claude auto-records to `~/.claude/projects/<project>/memory/`:
- Project patterns, debugging insights, architecture notes, preferences

### Explicit Save
- "기억해", "저장해", "remember this" 요청 시 → Auto Memory에 기록
- `/memory` 명령어로 확인/편집

### CLAUDE.md Hierarchy
| Purpose | Location |
|------|------|
| Team rules | `./CLAUDE.md`, `.claude/rules/` |
| Personal global | `~/.claude/CLAUDE.md` |
| Personal project | `./CLAUDE.local.md` |
