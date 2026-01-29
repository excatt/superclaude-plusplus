---
name: learn
description: 세션에서 재사용 가능한 패턴을 추출하여 스킬로 저장합니다. 복잡한 문제 해결 후, 유용한 워크어라운드 발견 시, 프로젝트별 컨벤션 정립 시 사용합니다. Keywords: learn, pattern, extract, skill, knowledge, save, remember, 학습, 패턴, 추출, 기억.
---

# Learn Skill

## Purpose
세션에서 발생한 문제 해결 패턴, 디버깅 기법, 워크어라운드를 분석하여 재사용 가능한 스킬로 저장합니다.

**핵심 원칙**: 반복되는 문제 해결 → 패턴 추출 → 스킬화 → 미래 세션에서 재사용

## Activation Triggers
- 복잡한 에러 해결 후
- 유용한 워크어라운드 발견 시
- 프로젝트별 컨벤션 정립 시
- 세션 종료 전 학습 정리
- 사용자 명시적 요청: `/learn`, `이거 기억해`, `패턴 저장`

---

## Pattern Extraction Focus

### 추출 대상 ✅
| 카테고리 | 예시 |
|----------|------|
| **에러 해결 패턴** | TypeScript 타입 에러 해결법, 빌드 실패 수정 |
| **디버깅 기법** | 특정 도구 조합, 로그 분석 방법 |
| **라이브러리 quirks** | 문서화되지 않은 동작, 버전별 차이 |
| **API 워크어라운드** | Rate limit 우회, 인증 처리 패턴 |
| **프로젝트 컨벤션** | 네이밍 규칙, 파일 구조, 코드 스타일 |
| **아키텍처 결정** | 특정 패턴 선택 이유, 트레이드오프 |

### 추출 제외 ❌
| 카테고리 | 이유 |
|----------|------|
| 단순 오타 수정 | 재사용 가치 없음 |
| 일회성 문제 | 외부 서비스 장애 등 |
| 문법 에러 | 기본 지식 범위 |
| 환경별 설정 | 범용성 부족 |

---

## Workflow

### Step 1: 세션 분석
```
/learn

🔍 세션 분석 중...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
메시지 수: 47
도구 호출: 89
에러 해결: 3건
주요 작업: Auth 시스템 구현
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2: 패턴 식별
```
💡 추출 가능한 패턴 발견
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [HIGH VALUE] NextAuth + Prisma 세션 타입 확장
   - 문제: Session 타입에 userId 누락
   - 해결: next-auth.d.ts 타입 확장
   - 재사용성: ⭐⭐⭐⭐⭐

2. [MEDIUM VALUE] Supabase RLS 디버깅 패턴
   - 문제: RLS 정책으로 인한 빈 결과
   - 해결: service_role 키로 테스트 후 정책 수정
   - 재사용성: ⭐⭐⭐⭐

3. [LOW VALUE] ESLint 규칙 비활성화
   - 문제: unused-vars 경고
   - 해결: .eslintrc 수정
   - 재사용성: ⭐⭐ (프로젝트별 상이)

저장할 패턴을 선택하세요 [1,2,3 또는 all]:
```

### Step 3: 스킬 문서 생성
```
📝 스킬 문서 생성 중...

파일: ~/.claude/skills/learned/nextauth-prisma-session-type.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NextAuth + Prisma Session Type Extension

## Problem
NextAuth 세션에서 userId 접근 시 타입 에러 발생
`Property 'userId' does not exist on type 'Session'`

## Solution
`types/next-auth.d.ts` 파일 생성:
\`\`\`typescript
import { DefaultSession } from "next-auth"

declare module "next-auth" {
  interface Session {
    user: {
      id: string
    } & DefaultSession["user"]
  }
}
\`\`\`

## When to Apply
- NextAuth + Prisma 조합 사용 시
- 세션에 커스텀 필드 추가 필요 시

## Related
- NextAuth 공식 문서: TypeScript 섹션
- Prisma adapter 설정
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 스킬 저장 완료
```

### Step 4: 확인
```
저장된 스킬을 확인하시겠습니까? [y/N]
```

---

## Learned Skills Storage

### 저장 위치
```
~/.claude/skills/learned/
├── nextauth-prisma-session-type.md
├── supabase-rls-debugging.md
├── react-hydration-mismatch-fix.md
└── vercel-edge-function-timeout.md
```

### 스킬 파일 구조
```markdown
---
name: pattern-name
description: 간단한 설명
learned_at: 2025-01-26
source_project: project-name
tags: [nextauth, prisma, typescript]
---

# Pattern Name

## Problem
문제 상황 설명

## Cause
근본 원인 분석

## Solution
해결 방법 (코드 예시 포함)

## When to Apply
이 패턴이 적용되는 상황

## Caveats
주의사항, 엣지 케이스

## Related
관련 문서, 리소스 링크
```

---

## Auto-Learning (Stop Hook)

### 세션 종료 시 자동 분석
`.claude/settings.json`:
```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "~/.claude/scripts/evaluate-session.sh"
      }
    ]
  }
}
```

### 자동 학습 설정
`.claude/learn.config.json`:
```json
{
  "auto_learn": {
    "enabled": true,
    "min_session_length": 10,
    "extraction_threshold": "medium",
    "auto_approve": false
  },
  "storage": {
    "path": "~/.claude/skills/learned/",
    "max_skills": 100
  },
  "filters": {
    "ignore_patterns": [
      "typo",
      "syntax_error",
      "one_time_fix"
    ],
    "focus_patterns": [
      "error_resolution",
      "debugging_technique",
      "workaround",
      "architecture_decision"
    ]
  }
}
```

---

## Integration

### With PM Agent
PM Agent의 자기 개선 레이어와 연동:
```
세션 완료
    │
    ├─→ /learn (패턴 추출)
    │
    └─→ PM Agent (문서화, 지식 베이스 업데이트)
```

### With `/checkpoint`
```
/checkpoint create "before-experiment"
... 실험적 해결 시도 ...
... 성공! ...
/learn  # 성공한 패턴 저장
```

### With Future Sessions
저장된 스킬은 유사한 문제 발생 시 자동 참조:
```
🔍 유사한 패턴 발견
━━━━━━━━━━━━━━━━━━━━━━━━━━
이전에 학습한 패턴이 있습니다:
- nextauth-prisma-session-type.md

적용하시겠습니까? [y/N]
```

---

## Quality Filters

### Value Assessment
| 기준 | 가중치 |
|------|--------|
| 해결 복잡도 | 30% |
| 재사용 가능성 | 40% |
| 시간 절약 효과 | 20% |
| 문서화 가치 | 10% |

### Extraction Threshold
- **Low**: 대부분의 패턴 추출 (노이즈 많음)
- **Medium**: 중간 가치 이상만 추출 (권장)
- **High**: 높은 가치 패턴만 추출 (엄격)

---

## Commands

| Command | Description |
|---------|-------------|
| `/learn` | 현재 세션 분석 및 패턴 추출 |
| `/learn list` | 저장된 스킬 목록 |
| `/learn show <name>` | 특정 스킬 내용 보기 |
| `/learn delete <name>` | 스킬 삭제 |
| `/learn search <keyword>` | 스킬 검색 |

---

## Best Practices

### 좋은 패턴 예시
```markdown
# React Server Component Data Fetching

## Problem
클라이언트 컴포넌트에서 서버 데이터 fetch 시
waterfall 문제 발생

## Solution
서버 컴포넌트에서 데이터 fetch 후 props로 전달
또는 Suspense + parallel fetch 사용

## Code Example
\`\`\`tsx
// ✅ Good: Server Component
async function Page() {
  const data = await fetchData()
  return <ClientComponent data={data} />
}
\`\`\`
```

### 피해야 할 패턴
```markdown
# Fix Typo in Config  ❌
## Problem
오타로 인한 빌드 실패
## Solution
오타 수정

→ 재사용 가치 없음, 저장하지 않음
```
