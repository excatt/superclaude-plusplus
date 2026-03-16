# Context Budget Management

컨텍스트 윈도우는 유한하다. 불필요한 파일 로딩은 성능을 직접 저하시킨다.

---

## Core Principles

1. **전체 파일 읽기 최소화** — 필요한 함수/클래스만 읽기
2. **중복 읽기 금지** — 이미 읽은 파일 재읽기 하지 않기
3. **지연 로딩** — 리소스는 필요할 때만 로드
4. **읽기 추적** — 읽은 파일과 심볼을 머릿속에 기록

---

## File Reading Strategy

### 대형 파일 (500줄+)
```
BAD:  Read("app/services/user_service.py")              ← 전체 파일 800줄
GOOD: Read("app/services/user_service.py", offset=45, limit=30)  ← 해당 함수만
GOOD: Grep("def create_user", path="app/services/")     ← 위치 먼저 찾기
```

### 표준 파일 (100-500줄)
```
OK:   Read 전체 (한 번만)
GOOD: Grep으로 대상 위치 확인 → Read offset/limit
```

### 소형 파일 (<100줄)
```
OK:   Read 전체 (효율적)
```

### 탐색 순서
1. **Glob** — 파일 위치 파악
2. **Grep** — 대상 심볼/패턴 위치 찾기
3. **Read** (offset/limit) — 필요한 부분만 읽기
4. **Read** (전체) — 소형 파일이거나 전체 이해 필요 시만

---

## Budget by Difficulty

### Simple Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| 파일 읽기 | 1-2개 전체 | 대상 파일만 |
| 탐색 | Grep 1-2회 | 최소 탐색 |
| **총 컨텍스트** | **~2K tokens** | |

### Medium Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| 파일 읽기 | 3-5개 | 대상 + 관련 파일 |
| 탐색 | Grep/Glob 3-5회 | 패턴 확인 |
| 참조 문서 | optional/ 1-2개 | 필요 시 |
| **총 컨텍스트** | **~5-10K tokens** | |

### Complex Tasks
| Category | Budget | Notes |
|----------|--------|-------|
| 파일 읽기 | 제한 없음 (중복 주의) | 심볼 단위 선호 |
| 탐색 | 필요한 만큼 | 체계적 탐색 |
| 참조 문서 | optional/ 필요한 만큼 | |
| **총 컨텍스트** | **~15-30K tokens** | 효율 유지 |

---

## Read Tracking (Mental Model)

대규모 작업 시, 읽은 파일을 머릿속에 추적:

```
## Read Files
- app/api/todos.py:23-55 (create_todo, update_todo)
- app/models/todo.py (전체, 40줄 소형 파일)
- app/schemas/todo.py:1-20 (TodoCreate 스키마만)

## Not Yet Read (다음 단계)
- app/services/todo_service.py (구현 시 읽기)
- tests/test_todos.py (테스트 작성 시 참조)
```

**목적**:
- 같은 파일 두 번 읽기 방지
- 다음에 할 일 명확화
- 에이전트 스폰 시 컨텍스트 전달 효율화

---

## Context Overflow Symptoms & Response

| 증상 | 원인 | 대응 |
|------|------|------|
| 이전에 읽은 코드를 잊음 | 컨텍스트 윈도우 포화 | 핵심 정보 메모, 재참조 가능하게 |
| 같은 파일을 다시 읽음 | 추적 미흡 | Read Tracking 확인 |
| 출력이 갑자기 짧아짐 | 출력 토큰 부족 | 핵심만 작성, 부가 설명 생략 |
| 지시사항을 무시함 | 규칙 파일 내용 잊음 | 핵심 규칙만 재참조 |
| 중간 작업 결과가 사라짐 | 컨텍스트 압축 발생 | `/note` 활용, 상태 저장 |

**예방**: `--uc` 모드 활성화, 에이전트 위임으로 컨텍스트 분산

---

## Agent Spawn Context Efficiency

워커 에이전트 스폰 시 컨텍스트 최적화:

```
GOOD: "app/api/todos.py의 create_todo() 함수(line 23-55)를 수정해줘.
       현재 TodoCreate 스키마(app/schemas/todo.py:5-15)에 priority 필드를 추가하고,
       create_todo에서 이를 처리하도록 변경."

BAD:  "todos 관련 코드를 수정해줘." (에이전트가 전체 탐색 필요)
```

**원칙**: 워커에게 파일 경로 + 라인 번호 + 구체적 변경 사항을 전달.
탐색 비용을 오케스트레이터가 부담하고, 워커는 실행에 집중.
