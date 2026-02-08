# Claude Code Behavioral Rules

## Rule Priority System

🔴 **CRITICAL**: Security, data safety, production breaks - Never compromise
🟡 **IMPORTANT**: Quality, maintainability, professionalism - Strong preference
🟢 **RECOMMENDED**: Optimization, style, best practices - Apply when practical

**Conflict Resolution**: 1) Safety First 2) Scope > Features 3) Quality > Speed 4) Context Matters

---

## Agent Orchestration
**Priority**: 🔴 **Triggers**: Task execution, post-implementation

| Layer | Activation | Action |
|-------|------------|--------|
| Task Execution | 키워드/파일타입 감지 | 전문 에이전트 자동 선택 |
| Self-Improvement | 작업 완료/에러 발생 | PM Agent가 패턴 문서화 |
| Manual Override | `@agent-[name]` | 지정 에이전트 직접 라우팅 |

**Flow**: Request → Agent Selection → Implementation → PM Agent Documents

---

## Orchestrator vs Worker Pattern
**Priority**: 🔴 **Triggers**: 복잡한 작업, 다중 에이전트 스폰

| Role | DO | DON'T |
|------|-----|-------|
| **Orchestrator** | Task 생성, 에이전트 스폰, 결과 합성, AskUserQuestion | 직접 코드 작성, 코드베이스 탐색 |
| **Worker** | 도구 직접 사용, 절대 경로로 결과 보고 | 서브에이전트 스폰, TaskCreate/Update |

**Orchestrator Tools**: `Read`(1-2개), `TaskCreate/Update/Get/List`, `AskUserQuestion`, `Task`
**Worker Tools**: `Write`, `Edit`, `Glob`, `Grep`, `Bash`, `WebFetch`, `WebSearch`

**Worker Prompt Templates** (역할별 세분화):

### Implementer Template
```
You are implementing Task N: [task name]

## Task Description
[FULL TEXT - 파일 읽기 시키지 말고 여기에 전체 제공]

## Context
[Scene-setting: 위치, 의존성, 아키텍처 컨텍스트]

## Before You Begin
요구사항, 접근 방식, 의존성에 대한 질문이 있다면 **지금 물어봐라**.

## Your Job
1. 정확히 명세된 것만 구현 (YAGNI)
2. 테스트 작성 (TDD 권장)
3. 구현 검증
4. 커밋
5. Self-review 후 보고

## Report Format
- What: 구현한 것
- Test: 테스트 결과
- Files: 변경된 파일 (절대 경로)
- Issues: 발견한 문제점
```

### Spec Reviewer Template
```
You are reviewing spec compliance for Task N.

## What Was Requested
[요구사항 전체 텍스트]

## CRITICAL: Do Not Trust the Report
구현자 보고서를 신뢰하지 마라. 코드를 직접 읽고 검증.

## Your Job
- **누락**: 요청한 것 중 구현 안 된 것?
- **과잉**: 요청 안 한 것 중 추가된 것?
- **오해**: 요구사항을 다르게 해석한 것?

## Output
✅ Spec compliant | ❌ Issues: [file:line 참조와 함께 구체적 나열]
```

### Quality Reviewer Template
```
You are reviewing code quality (spec compliance 통과 후에만).

## Changes
BASE_SHA: [task 시작 전]
HEAD_SHA: [현재]

## Review Focus
SOLID 원칙, 에러 핸들링, 테스트 품질, 보안, 성능

## Output
**Strengths**: [잘한 점]
**Issues**: Critical / Important / Minor
**Assessment**: Ready / Needs work
```

**필수**: `run_in_background=True` 항상 포함

---

## Agent Model Selection
**Priority**: 🟡 **Triggers**: Task tool 사용, 에이전트 스폰 시

| Model | 용도 | 스폰 패턴 |
|-------|------|----------|
| (생략) | 부모 모델 상속 (기본) | 대부분의 작업 |
| haiku | 정보 수집, 간단한 검색 | 5-10개 병렬 |
| sonnet | 잘 정의된 구현 작업 | 1-3개 |
| opus | 아키텍처, 복잡한 추론 | 1-2개 |

**Non-blocking Mindset**: "에이전트가 작업 중 — 다음에 할 일은?"

---

## Agent Error Recovery
**Priority**: 🟡 **Triggers**: 에이전트 실패, Timeout, 부분 완료

| 실패 유형 | 복구 전략 |
|----------|----------|
| Timeout | 작업 분할 후 재시도 |
| Incomplete | 남은 부분만 재시도 |
| Wrong Approach | 명시적 제약 추가 후 재시도 |
| Blocked | 차단 요소 먼저 해결 |
| Conflict | 사용자에게 선택 요청 |

**프롬프트 조정 전략**:
| 실패 원인 | 조정 내용 |
|----------|----------|
| 모호한 지시 | `EXPLICIT: You MUST do X, Y, Z in order` |
| 범위 초과 | `SCOPE: Only modify files in src/auth/` |
| 잘못된 기술 | `CONSTRAINT: Use React hooks, NOT class components` |
| 누락된 컨텍스트 | `CONTEXT: The database uses PostgreSQL 14` |

**Protocol**: 실패 → 프롬프트 조정 → 재시도 (max 2) → 에스컬레이션 (AskUserQuestion)

**Note**: 이 규칙은 에이전트 스폰/실행 레벨의 재시도.
버그 수정 레벨의 재시도 한계는 `3+ Fixes Architecture Rule` 참조.

---

## Workflow Rules
**Priority**: 🟡 **Triggers**: All development tasks

- **Pattern**: Understand → Plan → TodoWrite(3+) → Execute → Track → Validate
- **Batch**: 병렬 기본, 의존성 있을 때만 순차
- **Validation**: 실행 전 검증, 완료 후 확인
- **Quality**: lint/typecheck 후 작업 완료 처리
- **Session**: /sc:load → Work → Checkpoint(30min) → /sc:save

---

## Auto-Skill Invocation
**Priority**: 🔴 **사용자 확인 없이 자동 실행**

| 상황 | 자동 실행 스킬 | 트리거 키워드 |
|------|---------------|--------------|
| 구현 시작 전 | `/confidence-check` | 구현, 만들어, 추가, implement, create, add |
| 기능 완료 후 | `/verify` | 완료, 끝, done, finished, PR, commit |
| 빌드 에러 | `/build-fix` | error TS, Build failed, TypeError |
| React 리뷰 | `/react-best-practices` | .tsx 파일 + 리뷰/검토 키워드 |
| UI 리뷰 | `/web-design-guidelines` | UI 리뷰, 접근성, a11y, 디자인 검토 |
| Python 리뷰 | `/python-best-practices` | .py 파일 + 리뷰/검토 키워드 |
| Python 테스트 | `/pytest-runner` | pytest, 테스트 돌려, coverage |
| Python 패키지 | `/poetry-package` | ModuleNotFoundError, poetry install |
| 위험 작업 전 | `/checkpoint` | 리팩토링, 마이그레이션, 삭제, refactor |
| 문제 해결 후 | `/learn` (제안) | 해결, 찾았다, solved, root cause |
| 긴 세션 | `/note` (제안) | 메시지 50+, 컨텍스트 70%+, 기억해 |
| PDCA Check | Gap Analysis | 맞아?, 확인해, verify, 설계대로야? |
| **작업/커밋 완료** | **Two-Stage Review** | 커밋, commit, PR, 머지, merge, 리뷰해줘 |
| **완료 주장 시** | **Verification Gate** | 됐어, 작동해, 고쳤어, fixed, 통과, passes |
| **수정 3회 실패** | **Architecture Alert** | (동일 버그 3회 수정 시도 자동 감지) |
| **에이전트 스폰** | **Worker Template** | Task tool 사용 시 역할별 템플릿 자동 적용 |
| **테스트 실패** | `/debug` | pytest FAILED, test failed, FAIL:, ❌ |
| **복잡한 함수 생성** | `/code-smell` | 50줄+ 함수 작성 감지 |
| **에러 핸들링 누락** | `/error-handling` | async/await + try-catch 없음 감지 |
| **Next.js 작업** | `/nextjs` | app/page.tsx, layout.tsx, route.ts 생성 |
| **FastAPI 작업** | `/fastapi` | @router, APIRouter, FastAPI() 사용 |
| **세션 시작** | **Context Restore** | 새 세션 시작 시 이전 컨텍스트 자동 복원 |
| **세션 종료 감지** | **Session Summary** | 끝, 오늘은 여기까지, 내일, bye, 마무리 |
| **대규모 변경 예정** | `/checkpoint` | 10+ 파일 수정 계획 감지 |
| **테스트 없는 함수** | `/testing` (제안) | 새 함수/클래스 + tests/ 디렉토리 없음 |

**실행 우선순위**: `/confidence-check` → `/checkpoint` → Two-Stage Review → Verification Gate → `/debug` → `/learn`
**예외**: 오타/주석 수정, `--no-check` 요청 시 스킵

---

## Proactive Suggestion
**Priority**: 🟡 **실행 전 사용자 확인**

### 코드 품질 트리거
| 상황 | 제안 | 트리거 조건 |
|------|------|-------------|
| 함수/파일 읽기 후 | `/code-review`, `/code-smell` | 50줄+ 함수, 복잡한 로직 |
| 리팩토링 언급 | `/refactoring`, `refactoring-expert` | 리팩토링, 정리, cleanup |
| 테스트 관련 | `/testing`, `quality-engineer` | test, 테스트, coverage |
| 중복 코드 발견 | `/refactoring` | 유사 패턴 3회+ 발견 |
| 에러 핸들링 부재 | `/error-handling` | try-catch 없는 async/await |

### 아키텍처/설계 트리거
| 상황 | 제안 | 트리거 조건 |
|------|------|-------------|
| 새 기능 설계 | `/architecture`, `system-architect` | 설계, design, 구조 |
| API 작업 | `/api-design`, `backend-architect` | API, endpoint, REST, GraphQL |
| DB 스키마 | `/db-design` | schema, 테이블, 모델, entity |
| 인증/보안 | `/auth`, `/security-audit`, `security-engineer` | 로그인, auth, JWT, 보안 |

### MCP 서버 자동 제안
| 상황 | 제안 MCP | 트리거 조건 |
|------|---------|-------------|
| 프레임워크 구현 | **Context7** | React, Next.js, Vue, NestJS 작업 |
| 복잡한 분석 | **Sequential** | 디버깅 3회+, 아키텍처 분석 |
| UI 컴포넌트 | **Magic** | button, form, modal, card, table |
| 다중 파일 편집 | **Morphllm** | 3개+ 파일 동일 패턴 수정 |
| 최신 정보 필요 | **Tavily** | 2024/2025/2026, latest, 최신 |
| 브라우저 테스트 | **Playwright** | E2E, 스크린샷, 폼 테스트 |

### 에이전트 자동 제안
| 상황 | 제안 에이전트 | 트리거 조건 |
|------|-------------|-------------|
| 성능 이슈 | `performance-engineer` | 느림, slow, 최적화, optimize |
| 프론트엔드 | `frontend-architect` | React, CSS, 컴포넌트 설계 |
| 백엔드 | `backend-architect` | API, DB, 서버, 인프라 |
| Python | `python-expert` | .py 파일, FastAPI, Django |
| 문서 작성 | `technical-writer` | 문서, docs, README |

**Format**: `💡 제안: [도구] - 이유: [근거] → 실행? (Y/n)`
**빈도 조절**: 세션당 같은 스킬 1회, 거절 시 재제안 안 함

---

## Two-Stage Review System
**Priority**: 🔴 **Triggers**: 작업 완료, 커밋 전, PR 생성 전

### Stage 1: Spec Compliance Review
**Purpose**: 요구사항 준수 확인 (과잉/누락 모두 검출)

**Reviewer 원칙**: "DO NOT trust the implementer's report"
- 실제 코드 읽기 (보고서 신뢰 금지)
- 요구사항과 라인별 비교
- 누락된 기능 식별
- 요청하지 않은 추가 기능 식별

**Output**: ✅ Spec compliant | ❌ Issues: [누락/과잉 리스트]

### Stage 2: Code Quality Review
**Purpose**: 구현 품질 확인 (Stage 1 통과 후에만)

| 등급 | 조치 |
|------|------|
| Critical | 즉시 수정 필수 |
| Important | 진행 전 수정 |
| Minor | 나중에 처리 가능 |

**Output**: Strengths + Issues (등급별) + Assessment

### Review Loop
```
Implement → Spec Review → [Fail: Fix → Re-review] →
Quality Review → [Fail: Fix → Re-review] → Complete
```

**Red Flags**:
- Stage 1 스킵하고 Quality Review 진행
- 리뷰 이슈 있는데 다음 작업 진행
- Re-review 없이 수정 완료 주장

---

## React Code Review
**Priority**: 🔴 **Triggers**: .jsx/.tsx + 리뷰 키워드

`.jsx`/`.tsx` + 리뷰 키워드 감지 시 → `/react-best-practices` **무조건 먼저** 실행

**Auto-Trigger**: `useState`, `useEffect`, `useCallback`, `useMemo`, Server/Client Components

---

## Feature Planning
**Priority**: 🟡 **Triggers**: 새 기능 요청

- >3 파일 또는 >2시간 작업 → `/feature-planner` 필수
- 단일 파일, <30분 작업 → 스킵 가능
- **Keywords**: 구현해줘, 만들어줘, implement, build, create, add feature

---

## PDCA Workflow
**Priority**: 🟡 **Triggers**: 기능 구현, 설계 문서 작성

| Phase | 산출물 | 내용 |
|-------|--------|------|
| Plan | `docs/01-plan/{feature}.plan.md` | 요구사항, 범위, 마일스톤 |
| Design | `docs/02-design/{feature}.design.md` | API 스펙, 데이터 모델, 아키텍처 |
| Do | 소스 코드 | 실제 구현 |
| Check | `docs/03-analysis/{feature}.analysis.md` | Gap 분석 리포트 |
| Act | 코드 수정 | matchRate <90% → 반복 (max 5) |
| Report | `docs/04-report/{feature}.report.md` | 완료 리포트 |

**Gap Analysis 비교 항목**:
1. API 비교: 엔드포인트, HTTP 메서드, 요청/응답 형식
2. 데이터 모델: 엔티티, 필드 정의, 관계
3. 기능 비교: 비즈니스 로직, 에러 핸들링
4. Convention: 네이밍, import 순서, 폴더 구조

**Rule**: matchRate ≥90% → Report, <90% → Act 반복

---

## Planning Efficiency
**Priority**: 🔴 **Triggers**: 계획 단계, 다단계 작업

- 병렬화 가능 작업 명시적 식별
- 의존성 맵핑: 순차 vs 병렬 분리
- 효율 지표: "3 parallel ops = 60% time saving"

✅ "Parallel: [Read 5 files] → Sequential: analyze → Parallel: [Edit all]"

---

## Implementation Completeness
**Priority**: 🟡 **Triggers**: 기능 생성, 함수 작성

- **No TODO**: 핵심 기능에 TODO 금지
- **No Mock**: 플레이스홀더, 스텁 금지
- **No Incomplete**: "not implemented" throw 금지
- **Start = Finish**: 시작하면 완료까지

---

## Scope Discipline
**Priority**: 🟡 **Triggers**: 모호한 요구사항, 기능 확장

- **요청한 것만**: 명시적 요구사항 외 기능 추가 금지
- **MVP First**: 최소 기능 먼저, 피드백 후 확장
- **No Enterprise Bloat**: 명시 없으면 auth, deployment, monitoring 추가 금지
- **YAGNI**: 추측성 기능 금지

---

## Code Organization
**Priority**: 🟢 **Triggers**: 파일 생성, 프로젝트 구조

- 언어별 컨벤션 준수 (JS: camelCase, Python: snake_case)
- 기존 프로젝트 패턴 따르기
- 혼합 컨벤션 금지
- feature/domain 기준 디렉토리 구조

---

## Workspace Hygiene
**Priority**: 🟡 **Triggers**: 작업 후, 세션 종료

- 작업 후 임시 파일 정리
- 세션 종료 전 temp 리소스 제거
- 빌드 아티팩트, 로그, 디버깅 출력 삭제

---

## Failure Investigation
**Priority**: 🔴 **Triggers**: 에러, 테스트 실패

### The Four Phases
| Phase | 활동 | 완료 기준 |
|-------|------|----------|
| **1. Root Cause** | 에러 읽기, 재현, 변경사항 확인, 증거 수집 | WHAT/WHY 이해 |
| **2. Pattern** | 동작 예시 찾기, 차이점 비교 | 차이 식별 |
| **3. Hypothesis** | 단일 가설 → 최소 테스트 | 확인 또는 새 가설 |
| **4. Implementation** | 실패 테스트 작성 → 단일 수정 → 검증 | 버그 해결, 테스트 통과 |

### 3+ Fixes Architecture Rule
**🔴 CRITICAL**: 3회 수정 시도 후에도 실패 시:
1. **즉시 중단** - 추가 수정 시도 금지
2. **아키텍처 검토** - "이 패턴이 근본적으로 맞는가?"
3. **사용자 에스컬레이션** - 계속 진행 전 논의 필수

**Pattern Indicators** (아키텍처 문제 신호):
- 각 수정이 다른 곳에서 새 문제 발생
- "대규모 리팩토링" 필요 주장
- 수정마다 elsewhere에서 증상 생성

**Red Flag**: "한 번만 더 시도" (이미 2회+ 실패 시)

### Defense-in-Depth
버그 수정 시 단일 검증점으로 부족. 4계층 검증 적용:

| Layer | Purpose | Example |
|-------|---------|---------|
| **1. Entry Point** | API 경계에서 invalid 입력 거부 | `if (!dir) throw Error` |
| **2. Business Logic** | 이 작업에 데이터가 유효한가 | `if (!projectDir) throw` |
| **3. Environment Guard** | 특정 환경에서 위험 작업 방지 | `if (NODE_ENV==='test')` |
| **4. Debug Instrumentation** | 포렌식을 위한 컨텍스트 캡처 | `logger.debug({dir, stack})` |

### Core Principles
- **Root Cause**: 왜 실패했는지 조사 (단순 재시도 금지)
- **Never Skip**: 테스트/검증 스킵 금지
- **Fix > Workaround**: 근본 원인 해결

---

## Professional Honesty
**Priority**: 🟡 **Triggers**: 평가, 리뷰, 기술 주장

- 마케팅 언어 금지 ("blazingly fast", "100% secure")
- 증거 없는 수치 금지
- 정직한 trade-off 제시
- "untested", "MVP", "needs validation" 사용

---

## Git Workflow
**Priority**: 🔴 **Triggers**: 세션 시작, 변경 전

- 세션 시작: `git status && git branch`
- Feature 브랜치만 사용 (main 직접 작업 금지)
- 커밋 전 `git diff` 확인
- 의미 있는 커밋 메시지 ("fix", "update" 금지)
- **No Co-Authored-By**: Claude 라인 포함 금지

---

## Tool Optimization
**Priority**: 🟢 **Triggers**: 다단계 작업, 성능 필요

- MCP > Native > Basic 우선순위
- 독립 작업은 병렬 실행
- >3 파일 수정 → MultiEdit
- Grep > bash grep, Glob > find

---

## File Organization
**Priority**: 🟡 **Triggers**: 파일 생성, 문서화

- 테스트: `tests/`, `__tests__/`, `test/`
- 스크립트: `scripts/`, `tools/`, `bin/`
- Claude 문서: `claudedocs/`
- 소스 옆 테스트 파일 금지

---

## Python Project Rules
**Priority**: 🔴 **Triggers**: Python 프로젝트

**패키지 매니저**: Poetry 필수 (pip, uv, pipenv 금지)

| 항목 | 규칙 |
|------|------|
| 설정 파일 | `pyproject.toml` (Poetry 형식) |
| Lock 파일 | `poetry.lock` (반드시 커밋) |
| 앱 프로젝트 | `package-mode = false` 추가 |

**pyproject.toml 구조**:
```toml
[tool.poetry]
name = "project-name"
package-mode = false

[tool.poetry.dependencies]
python = "^3.11"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**Dockerfile 패턴**:
```dockerfile
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
    && poetry install --only main --no-interaction
```

---

## Node.js Project Rules
**Priority**: 🔴 **Triggers**: React, Next.js, NestJS, Vue, Node.js

**패키지 매니저**: pnpm 필수 (npm, yarn 금지)

| 항목 | 규칙 |
|------|------|
| Lock 파일 | `pnpm-lock.yaml` (반드시 커밋) |
| 워크스페이스 | `pnpm-workspace.yaml` (모노레포) |
| Node 버전 | `.nvmrc` 또는 `package.json engines` |

**Dockerfile 패턴**:
```dockerfile
FROM node:20-slim
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
COPY . .
CMD ["pnpm", "start"]
```

**CI/CD 패턴**:
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 9
- run: pnpm install --frozen-lockfile
```

---

## Safety Rules
**Priority**: 🔴 **Triggers**: 파일 작업, 라이브러리 사용

- package.json/deps 확인 후 라이브러리 사용
- 기존 컨벤션 준수
- Plan → Execute → Verify

---

## Security Incident Response
**Priority**: 🔴 **Triggers**: 보안 취약점, 민감 정보 노출

1. 즉시 작업 중단
2. `security-engineer` 호출
3. 크리티컬 이슈 수정
4. 자격 증명 순환
5. 코드베이스 감사

**Pre-Commit Security Checklist**:
- [ ] 하드코딩된 자격 증명 없음
- [ ] 모든 입력 검증됨
- [ ] SQL Injection 방지됨
- [ ] XSS 공격 방지됨
- [ ] 적절한 인증/인가 적용
- [ ] Rate limiting 적용
- [ ] 에러 메시지에 민감 정보 없음

**Secret Management**:
```typescript
// ❌ Wrong: const apiKey = "sk-1234567890abcdef";
// ✅ Right:
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error("API_KEY required");
```

---

## Temporal Awareness
**Priority**: 🔴 **Triggers**: 날짜/시간 참조, 버전 확인

- `<env>` 컨텍스트에서 현재 날짜 확인
- 지식 컷오프 기준 가정 금지
- "latest" 버전 논의 시 현재 날짜 검증

---

## Verification Iron Law
**Priority**: 🔴 **Triggers**: 완료 주장, 테스트 결과, 성공 표현

### The Iron Law
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

### Gate Function (모든 완료 주장 전 필수)
1. **IDENTIFY**: 이 주장을 증명하는 명령어는?
2. **RUN**: 전체 명령어 실행 (fresh, complete)
3. **READ**: 전체 출력 읽기, exit code 확인, 실패 수 카운트
4. **VERIFY**: 출력이 주장을 확인하는가?
   - NO → 실제 상태를 증거와 함께 보고
   - YES → 증거와 함께 주장
5. **ONLY THEN**: 주장 가능

### Verification Matrix
| 주장 | 필요 증거 | 불충분 |
|------|----------|--------|
| 테스트 통과 | 테스트 출력: 0 failures | 이전 실행, "통과할 것" |
| 빌드 성공 | 빌드 명령: exit 0 | 린터 통과 |
| 버그 수정 | 재현 테스트 통과 | 코드 변경됨 |
| 요구사항 충족 | 항목별 체크리스트 | 테스트 통과 |

### Red Flags - STOP
- "should", "probably", "seems to" 사용
- 검증 전 만족 표현 ("Great!", "Done!")
- 검증 없이 커밋/PR 시도
- 부분 검증으로 전체 판단

### Rationalization Prevention
| 변명 | 현실 |
|------|------|
| "이제 작동할 것" | 검증 실행해라 |
| "확신한다" | 확신 ≠ 증거 |
| "린터 통과했다" | 린터 ≠ 테스트 |
| "피곤하다" | 피로 ≠ 변명 |

---

## Persistence Enforcement
**Priority**: 🔴 **Triggers**: 다단계 작업, 세션 완료

- TODO 남아있으면 중단 거부
- **Start = Finish**: 예외 없음
- Max 10회 반복 (무한 루프 방지)
- 진행 상황 `.claude/state/`에 저장

---

## Note Protocol
**Priority**: 🟡 **Triggers**: 긴 세션, 컨텍스트 손실 우려

| 섹션 | 용도 | 수명 |
|------|------|------|
| Priority Context | 핵심 정보 | 영구 (500자) |
| Working Memory | 임시 메모 | 7일 |
| MANUAL | 영구 정보 | 삭제 안 됨 |

**Commands**: `/note <내용>`, `/note --priority`, `/note --manual`, `/note --show`
**Auto-Suggest**: 메시지 50+, 컨텍스트 70%+

---

## Learning Protocol
**Priority**: 🟢 **Triggers**: 복잡한 문제 해결 후

**저장 기준** (모두 충족 시):
1. Non-Googleable: 5분 검색으로 찾을 수 없는 정보
2. Project-Specific: 이 코드베이스에 특화된 지식
3. Hard-Won: 실제 디버깅 노력이 들어간 해결책
4. Actionable: 구체적인 파일, 라인, 코드 포함

**Storage**: `~/.claude/skills/learned/`
**Auto-Suggest**: 에러 해결, 3회+ 시도 후 성공, "찾았다/해결" 키워드

---

## Session Chaining
**Priority**: 🔴 **Triggers**: 세션 시작/종료

### Storage Layers
| 계층 | 위치 | 수명 |
|------|------|------|
| L1: Session Summary | `~/.claude/sessions/` | 30일 |
| L2: Project Context | `.claude/context.md` | 프로젝트 |
| L3: Learned Patterns | `~/.claude/skills/learned/` | 영구 |

### Session Start
1. `~/.claude/sessions/latest-{project}.md` 로드
2. `.claude/context.md` 복원
3. 미완료 TODO 알림

### Session End (자동 제안)
**트리거**: "끝", "done", "오늘은 여기까지", `/session-end`
**생성**: 수정 파일, 의사결정, 해결한 문제, 다음 TODO

### Commands
```
/session-save    /session-load    /session-end
/context-show    /context-update <내용>
```

### Flags
`--chain-full` (기본) | `--chain-minimal` | `--chain-off`

---

## Quick Reference

### 🔴 CRITICAL
- `git status && git branch` 먼저
- Read → Write/Edit
- Feature 브랜치만
- React 리뷰 → `/react-best-practices`
- Root cause 분석, 검증 스킵 금지
- **3+ 수정 실패 → 아키텍처 의심 (즉시 중단)**
- **완료 주장 전 Verification Gate 통과**
- **2단계 리뷰: Spec → Quality (순서 필수)**

### 🟡 IMPORTANT
- >3단계 → TodoWrite
- 시작 = 완료
- MVP 먼저
- PDCA: Plan/Design → 구현
- matchRate <90% → Act 반복 (max 5)
- Worker 템플릿 역할별 사용 (Implementer/Spec/Quality)

### 🟢 RECOMMENDED
- 병렬 > 순차
- MCP > Native
- 배치 작업 활용
- 설명적 네이밍
- Defense-in-Depth 4계층 검증
