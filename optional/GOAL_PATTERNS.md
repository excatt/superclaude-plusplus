# GOAL_PATTERNS.md

`/goal` 명령(Claude Code 2.1.139+, 2026-05-12 출시)을 SuperClaude++ 워크플로우 안에서 안전하게 사용하기 위한 패턴 가이드.

---

## /goal이란

Claude Code 빌트인 명령. 완료 조건을 선언하면 매 턴 후 작은 모델이 충족 여부를 확인하고, 충족될 때까지 자동으로 다음 턴을 이어 실행한다.

- **세션당 1개 활성** — 새 `/goal`은 기존을 대체
- **`/goal clear`로 해제** — 또는 조건 충족 시 자동 해제
- **`◎ /goal active` 표시기** — 활성 시간 표시
- **interactive / `-p` / Remote Control** 모두 지원

---

## 핵심 원칙

### 1. 조건은 검증 가능한 명령으로 표현하라

`/goal`의 종료 판정은 **작은 모델의 소프트 체크**다. 조건이 주관적이면 환각으로 종료되거나 무한히 지속될 수 있다.

| 종류 | 예시 | 신뢰도 |
|------|------|--------|
| Exit code | `pnpm test → 0 failures` | ✅ 높음 |
| Count | `grep -r legacyAuth src/ returns 0` | ✅ 높음 |
| File existence | `dist/bundle.js exists` | ✅ 높음 |
| GH state | `gh pr view --json state → "MERGED"` | ✅ 높음 |
| Subjective | `"리팩토링 잘 됐으면"` | ❌ 금지 |
| Vague | `"기능이 완성되면"` | ❌ 금지 |

### 2. SC++ Safety Net과 함께 사용하라

`/goal`은 의지력만 제공한다. 품질 게이트는 SC++ 안전장치가 담당.

| 게이트 | 역할 | `/goal`과의 관계 |
|--------|------|------------------|
| **Verification Iron Law** | 명령 exit code 기반 hard evidence | 최종 완료 주장 차단 |
| **3+ Fixes / Circuit Breaker** | 동일 에러 3회 반복 시 auto-halt | `/goal`을 override함 |
| **Two-Stage Review** | Spec 준수 + 코드 품질 | 루프 종료 후에도 강제 |
| **Cascade Impact (Complex)** | 4+ 모듈 영향 검사 | DELIVER 전 필수 |

### 3. Weak Criteria는 절대 `/goal`에 넣지 마라

`/goal "기능을 더 좋게 만들어"` → 작은 모델이 매 턴 "조금 더 좋아질 여지가 있다"고 판정 가능 → 무한 루프 + 토큰 폭주.

**약한 기준이면 먼저 명확화 (Goal Definition Protocol Step 1)** → 강한 기준으로 변환된 후에만 `/goal` 진입.

---

## 안전 패턴 (Use)

### Pattern A: Test-Driven Goal

```
/goal "pnpm test → 0 failures AND pnpm typecheck exit 0 AND pnpm lint exit 0"
```

**적합**: 버그 수정, 기능 추가, 리팩토링 (테스트 인프라 있음)
**왜 안전한가**: 3개 모두 exit code 기반. 작은 모델이 잘못 판단할 여지가 적음.

### Pattern B: Migration Drain

```
/goal "grep -rn 'from legacyAuth' src/ returns 0 AND pnpm test → 0 failures"
```

**적합**: API/라이브러리 마이그레이션, 데드 코드 제거
**왜 안전한가**: count = 0 조건은 결정적. 잔존 호출처가 0개일 때만 종료.

### Pattern C: Backlog Drain

```
/goal "gh issue list --label harness --state open returns empty AND main branch CI green"
```

**적합**: 라벨링된 이슈 처리, 큐 소진
**왜 안전한가**: GitHub API state는 외부 진실. 모델이 조작 불가.

### Pattern D: Size Budget

```
/goal "no file in src/ exceeds 300 lines AND pnpm test → 0 failures"
```

**적합**: 대형 파일 분할, 컴포넌트 추출
**왜 안전한가**: `wc -l` 기반 결정적 체크.

### Pattern E: PR Acceptance

```
/goal "gh pr view --json state,reviewDecision → MERGED AND CI green"
```

**적합**: PR 머지까지 자율 진행
**왜 안전한가**: 외부 시스템(GitHub) 상태가 단일 진실원.

---

## 안티 패턴 (Avoid)

### Anti A: 주관적 종료

```
❌ /goal "코드가 깔끔해지면 종료"
❌ /goal "UI가 예뻐지면 멈춰"
❌ /goal "성능이 충분히 좋아지면"
```

**왜 위험한가**: 깔끔/예쁨/충분은 작은 모델의 주관 판정. 환각으로 조기 종료되거나 무한 지속.

### Anti B: 측정 없는 성능 목표

```
❌ /goal "API가 빨라지면"
✅ /goal "p95 latency < 100ms in load-test.json AND tests green"
```

### Anti C: 모호한 부정문

```
❌ /goal "버그가 없으면"
✅ /goal "tests green AND no error logs in last 100 lines of error.log"
```

### Anti D: 안전장치 우회

```
❌ /goal "테스트가 통과할 때까지 어떻게든 고쳐" — Circuit Breaker 우회 시도
✅ /goal "tests green" + 3+ Fixes Rule 도달 시 Agent Struggle Report 생성
```

`/goal`은 Circuit Breaker를 override하지 못한다. 3회 동일 에러 시 자동 halt.

### Anti E: 다중 goal 시도

```
❌ /goal "X" → 작업 중 → /goal "Y" (X 진행 상태 망실)
✅ /goal "X" → 완료 또는 /goal clear → /goal "Y"
```

세션당 1개. 새 `/goal`은 기존을 silently 대체하므로 명시적 clear 후 시작.

---

## `/loop` vs `/goal` 결정표

두 명령은 자주 혼동되지만 사용 시점이 다르다.

| 축 | `/loop` | `/goal` |
|----|---------|---------|
| **종료 조건** | 시간 / 횟수 기반 | 의미 조건 기반 |
| **반복 주기** | 명시적 interval (또는 model self-pace) | 매 턴 자동 |
| **적합 작업** | 외부 상태 폴링 (CI 감시, deploy 추적, queue 대기) | 자율 구현 (마이그레이션, 백로그 처리) |
| **종료 판정** | 사용자 또는 모델 자체 | 작은 모델의 조건 체크 |
| **예시** | `/loop 5m gh pr checks` | `/goal "all PRs merged"` |
| **세션 제약** | 다수 동시 가능 | 1개만 활성 |
| **권장 시점** | 변화가 외부 시스템에서 일어남 | 변화가 코드 안에서 일어남 |

**결정 흐름**:
```
작업이 코드 변경을 동반하는가?
├─ YES → /goal (조건 작성 가능?)
│   ├─ YES → /goal 진입
│   └─ NO → Goal Definition Protocol로 조건 명확화 먼저
└─ NO (외부 상태 대기) → /loop
```

**조합 예**:
- `/goal "feature shipped"` (작업) + 별도 세션에서 `/loop 10m gh pr checks` (감시)
- 단, **한 세션에서 둘을 함께 쓰면 책임 경계가 흐려진다** — 권장하지 않음.

---

## SC++ 워크플로우 진입점

| 진입 시점 | 동작 |
|-----------|------|
| **Step 0 Difficulty = Simple** | `/goal` 불필요 (1턴 내 종료) |
| **Medium + Strong criteria** | `/confidence-check ≥90%` → `/goal <condition>` → Implement |
| **Complex + autonomous** | `/feature-planner` → SCAFFOLD 승인 → `/goal <DELIVER condition>` |
| **Harness Mode** | INTENT → SCAFFOLD → `/goal` (DELIVER 조건) → IMPLEMENT 자율 루프 |
| **`--safe-mode` 활성** | `/goal` 사용 금지 — safe-mode는 phase별 사용자 승인 요구 |

---

## 운영 체크리스트

작업 시작 전:
- [ ] 조건이 exit code / count / file existence 기반인가?
- [ ] Verification Iron Law Matrix와 일치하는가?
- [ ] Circuit Breaker가 활성화되어 있는가? (`circuit-breaker.sh` hook)
- [ ] Scope Lock이 명확한가? (변경 허용 디렉토리·금지 파일)

작업 중:
- [ ] `◎ /goal active` 표시기 확인
- [ ] 토큰 사용량 모니터링 (장기 작업은 비용 폭증 위험)
- [ ] 방향 이탈 감지 시 즉시 `/goal clear`

작업 후:
- [ ] Two-Stage Review 실행
- [ ] `/verify` → `/audit`
- [ ] `/goal clear` (자동 해제 안 됐다면)
- [ ] `/learn` (반복 가능한 패턴이면 저장)

---

## 참고 자료

- [Claude Code Docs — Keep Claude working toward a goal](https://code.claude.com/docs/en/goal)
- RULES.md → Goal Definition Protocol, Persistence Enforcement, Verification Iron Law, 3+ Fixes Architecture Rule
- MODES.md → Harness Mode (Autonomous Loop via `/goal`)
- optional/MODE_Harness.md → 상세 워크플로우
