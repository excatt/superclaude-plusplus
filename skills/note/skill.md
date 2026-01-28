---
name: note
description: 세션 컴팩션에서 살아남는 영구 메모 시스템. 중요한 컨텍스트를 .claude/notepad.md에 저장하여 긴 세션에서도 정보 손실을 방지합니다. Keywords: note, memo, remember, context, save, 메모, 기억, 저장, 컨텍스트.
---

# Note Skill

## Purpose
세션 컴팩션(context compaction)에서 살아남는 영구 메모 시스템입니다. 긴 세션에서 중요한 컨텍스트가 압축으로 손실되는 것을 방지합니다.

**핵심 원칙**: 중요한 정보 → 메모 저장 → 컴팩션 후에도 유지 → 다음 세션에서도 활용

## Storage Location
- **프로젝트 레벨**: `.claude/notepad.md` (프로젝트 루트)
- **글로벌 레벨**: `~/.claude/notepad.md` (모든 프로젝트 공용)

---

## Commands

| Command | Description |
|---------|-------------|
| `/note <content>` | Working Memory에 타임스탬프와 함께 추가 |
| `/note --priority <content>` | Priority Context에 추가 (항상 로드) |
| `/note --manual <content>` | MANUAL 섹션에 추가 (절대 삭제 안 됨) |
| `/note --show` | 현재 notepad 내용 표시 |
| `/note --prune` | 7일 이상 된 Working Memory 항목 정리 |
| `/note --clear` | Working Memory만 삭제 (Priority, MANUAL 유지) |

---

## Sections

### 1. Priority Context (항상 로드)
```markdown
## Priority Context
<!-- 500자 제한 - 세션 시작 시 항상 주입됨 -->
- Project uses pnpm, not npm
- API client: src/api/client.ts
- Auth: NextAuth + Prisma adapter
```

**용도**:
- 프로젝트 핵심 정보
- 매 세션 시작 시 알아야 할 것
- **500자 제한** (컨텍스트 예산 고려)

### 2. Working Memory (임시 메모)
```markdown
## Working Memory
<!-- 타임스탬프 포함, 7일 후 자동 정리 -->
[2025-01-28 14:30] Auth 버그 발견 - UserContext에서 useEffect 의존성 누락
[2025-01-28 15:45] RLS 정책 문제 해결 - service_role 키로 테스트 필요
```

**용도**:
- 디버깅 중 발견한 것
- 현재 작업 중인 내용
- 7일 후 자동 정리 (--prune)

### 3. MANUAL (영구 저장)
```markdown
## MANUAL
<!-- 절대 자동 삭제 안 됨 -->
- Backend Team: backend@company.com
- Production DB: readonly, 절대 직접 수정 금지
- Deploy: main 브랜치 push → Vercel 자동 배포
```

**용도**:
- 팀 연락처
- 배포 정보
- 프로젝트 규칙
- 절대 잊으면 안 되는 정보

---

## Notepad File Format

```markdown
# Notepad
<!-- 컴팩션에서 살아남는 세션 메모 -->
<!-- 저장 위치: .claude/notepad.md -->

## Priority Context
<!-- 500자 제한 - 항상 로드됨 -->
- Project uses TypeScript strict mode
- All files in src/, tests in tests/
- API endpoints: /api/v1/*

## Working Memory
<!-- 타임스탬프 포함, 7일 후 자동 정리 -->
[2025-01-28 14:30] Found race condition in worker.ts:89

## MANUAL
<!-- 영구 저장 - 절대 자동 삭제 안 됨 -->
- Contact: api-team@company.com for backend questions
- NEVER commit to main directly
```

---

## Workflow

### Adding a Note

```
User: /note Auth 모듈에서 JWT 만료 처리 필요

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 [Note] Working Memory에 추가됨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[2025-01-28 14:30] Auth 모듈에서 JWT 만료 처리 필요

저장 위치: .claude/notepad.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Adding Priority Context

```
User: /note --priority 이 프로젝트는 pnpm 사용, npm 명령어 금지

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 [Note] Priority Context에 추가됨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 이 프로젝트는 pnpm 사용, npm 명령어 금지

⚠️ Priority Context: 127/500자 사용 중
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Showing Notes

```
User: /note --show

Claude:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 [Note] 현재 Notepad 내용
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Priority Context (127/500자)
- 이 프로젝트는 pnpm 사용, npm 명령어 금지
- API: src/api/client.ts

## Working Memory (2 items)
[2025-01-28 14:30] Auth 모듈에서 JWT 만료 처리 필요
[2025-01-28 15:00] UserService.ts:45 타입 에러 해결함

## MANUAL (1 item)
- Backend Team: backend@company.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Implementation

### On Skill Invocation

1. **Parse Arguments**
   - 옵션 확인: `--priority`, `--manual`, `--show`, `--prune`, `--clear`
   - 내용 추출

2. **Load/Create Notepad**
   - `.claude/notepad.md` 읽기 또는 생성
   - 섹션별 파싱

3. **Execute Action**
   - 기본: Working Memory에 타임스탬프와 함께 추가
   - `--priority`: Priority Context에 추가 (500자 제한 체크)
   - `--manual`: MANUAL 섹션에 추가
   - `--show`: 전체 내용 표시
   - `--prune`: 7일 이상 된 Working Memory 삭제
   - `--clear`: Working Memory 전체 삭제

4. **Save Notepad**
   - 변경 사항 저장

---

## Session Integration

### Session Start
세션 시작 시 자동으로 notepad 확인:
1. `.claude/notepad.md` 또는 `~/.claude/notepad.md` 존재 확인
2. Priority Context 로드 (항상)
3. 최근 Working Memory 로드 (24시간 이내)

### Session End
세션 종료 전 중요 정보 메모 제안:
- 해결한 복잡한 문제
- 발견한 프로젝트 규칙
- 다음 세션에 필요한 컨텍스트

---

## Best Practices

### Priority Context 작성 팁
```markdown
✅ Good (간결하고 핵심적)
- pnpm 사용, npm 금지
- API: src/api/client.ts
- Auth: NextAuth + Prisma

❌ Bad (너무 상세)
- 이 프로젝트는 pnpm 패키지 매니저를 사용합니다.
  npm이나 yarn을 사용하면 lock 파일 충돌이 발생할 수
  있으므로 반드시 pnpm을 사용해주세요...
```

### Working Memory 작성 팁
```markdown
✅ Good (구체적, 파일/라인 포함)
[2025-01-28] worker.ts:89 Promise.all에 await 누락 - race condition 원인

❌ Bad (모호함)
[2025-01-28] 버그 발견
```

### MANUAL 작성 팁
```markdown
✅ Good (영구적으로 유용한 정보)
- Production DB: readonly 접근만 허용
- Deploy: main push → Vercel 자동 배포
- Hotfix: hotfix/* 브랜치 → 즉시 배포

❌ Bad (임시 정보)
- 오늘 회의 3시
```

---

## Related

- `/learn` - 패턴 추출 및 스킬 저장
- `/checkpoint` - 작업 전 복원 지점 생성
- `/sc:save` - 세션 전체 상태 저장
