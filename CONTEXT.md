# CONTEXT — SuperClaude++

SuperClaude++ 자체의 도메인 어휘 사전(glossary)이다. `/grill-with-docs` 세션에서 stress-test 기준점으로 쓰이며, 프레임워크 내부 용어가 흔들리는 것을 막는다.

> **규칙**: 어휘 사전일 뿐이다. 구현 세부사항(파일 경로, 함수 이름, 스키마)은 적지 않는다. 형식은 [`skills/grill-with-docs/CONTEXT-FORMAT.md`](skills/grill-with-docs/CONTEXT-FORMAT.md).

---

### Skill

특정 작업 영역에 대한 행동 지시를 담은 단위. `skills/<name>/SKILL.md`로 정의되며 idle 상태에서는 토큰을 소비하지 않는다. 사용자가 `/<name>`으로 명시 호출하거나, `skill-rules.json`의 트리거에 의해 자동 활성화된다. 슬래시 명령처럼 보이지만 *실행 가능한 명령*은 아니며, Claude의 행동 모드를 전환하는 *컨텍스트 트리거*다.

### Agent

특정 역할로 작업을 수행하는 독립 Claude 인스턴스. `agents/<name>.md`의 frontmatter로 `model`, `tools`, `maxTurns`, `effort` 등이 선언적으로 강제된다. Orchestrator(부모 Claude)가 `Agent` 도구로 spawn하며, 결과만 부모로 돌려준다. Skill과 달리 *독립 컨텍스트 윈도우*를 가진다.

### Orchestrator vs Worker

Orchestrator는 Task를 만들고 Agent를 spawn하고 결과를 종합하는 역할이다. **코드를 직접 쓰지 않는다.** Worker는 Write/Edit/Bash로 실제 작업을 수행한다. **하위 Agent를 spawn하지 않는다.** 한 Claude 인스턴스는 한 가지 역할만 한다.

### Skill vs Command

이 프로젝트에서 "command"라는 단어는 **사용하지 않는다**. v2.0에서 `commands/` 디렉토리는 폐기되었고 모든 것이 `skills/`로 통합되었다. 슬래시 호출은 모두 "skill"이라 부른다.

### Hook

Claude Code 라이프사이클의 특정 이벤트(`UserPromptSubmit`, `PreToolUse`, `PostToolUse` 등)에 자동 실행되는 셸 스크립트. `settings.json`에 등록되며 Claude의 prompt가 아니라 *시스템 수준*에서 강제된다. v2.0의 "system-enforced" 패러다임의 근간이다.

### Harness Mode

엔지니어가 의도와 환경 설계에만 집중하고, 구현 전체를 Agent가 주도하는 작업 모드. INTENT → SCAFFOLD → IMPLEMENT → VERIFY → DELIVER 단계를 가지며, IMPLEMENT는 worktree에서 격리 실행된다. `--harness` 플래그 또는 "에이전트한테 맡겨" 류 트리거로 진입.

### Harness Engineering

레포지토리 자체가 Agent의 지식 베이스(self-documenting repo)가 되어야 한다는 엔지니어링 원칙. 디렉토리 구조·네이밍·타입 시스템이 도메인을 설명하며, Agent가 실패할 때마다 "레포에서 무엇이 빠졌는가"를 진단해 보강한다. **Harness Mode와는 다른 개념** — 후자는 작업 모드, 전자는 메타 원칙.

### /goal (Goal Lock)

Claude Code 2.1.139+의 빌트인 자율 실행 루프. **검증 가능한 종료 조건**(command exit code, test count, file existence 기반)을 인자로 받아, 조건 충족 시까지 IMPLEMENT → VERIFY를 자동 반복한다. 종료 판정은 *작은 모델의 soft check*이므로 환각 위험이 있다 — 따라서 안전망(Circuit Breaker, Verification Iron Law, Two-Stage Review)이 항상 함께 동작한다.

### Strong vs Weak Criteria

`/goal`에 전달할 수 있는 종료 조건의 분류. **Strong**은 명령 종료 코드/카운트/파일 존재 등 객관 증거에 기반한다. **Weak**는 "잘 동작하면", "개선되면" 같은 주관 평가다. Weak를 `/goal`에 넘기면 무한 루프가 보장된다 — 절대 금지.

### Verification Iron Law

완료 주장 전에 **반드시 fresh verification evidence**가 있어야 한다는 규칙. "테스트 통과"는 *방금 실행한* 테스트 출력이어야 하며, "이전 실행 결과"나 "통과할 것이다"는 증거가 아니다. `/goal`의 soft check는 이 Iron Law를 대체하지 않는다.

### Confidence Check

구현 시작 전 5가지 항목(중복 체크, 아키텍처 정합, 공식 문서 확인, OSS 레퍼런스, 근본 원인 이해)을 정량 점수화하는 게이트. 0.9 이상에서만 구현 진행 가능. 잘못된 방향으로의 5,000~50,000 토큰 낭비를 100~200 토큰으로 예방한다.

### Two-Stage Review

작업 완료 후 강제되는 리뷰 절차. **Stage 1**은 요구사항 정합(스펙 누락/초과) 검증, **Stage 2**는 코드 품질 검증이다. Complex 난이도에서는 **Stage 3 Cascade Impact Review**(변경이 다른 모듈에 미치는 영향 확인)가 추가된다. "구현자의 보고를 믿지 말고 실제 코드를 읽으라"는 원칙으로 운영된다.

### Difficulty Assessment (Step 0)

작업 시작 전 Simple/Medium/Complex로 난이도를 판정해 프로토콜 깊이를 분기시키는 단계. 파일 수, 패턴 일치도, 설계 결정의 유무, 모듈 횡단성, 변경 성격, 예상 diff 크기 6개 신호의 다수결로 판정한다. 불확실하면 한 단계 위로 평가한다.

### Circuit Breaker

같은 에러가 3회 반복되면 Claude를 자동 정지시키는 hook. 4번째 fix 시도를 막고 "아키텍처적으로 잘못된 패턴 아닌가"를 점검하도록 강제한다. v2.0의 system-enforced 안전망 중 하나.

### Agent Struggle Report

Circuit Breaker가 발동했을 때 Claude가 작성하는 **진단 전용** 보고서. 자동 수정은 하지 않는다(struggle = signal). 실패를 다섯 분류(Repo Gap / Architecture / External / Requirement / Capability) 중 하나로 분류하고 사용자가 다음 행동을 결정한다.

### Persona

Claude가 작업 중 일시적으로 채택하는 전문가 역할(architect, security, frontend 등). Agent와 달리 *독립 인스턴스가 아니라 단일 Claude의 모드 전환*이다. `/brainstorm`이 다중 페르소나 코디네이션을 수행할 때는 한 Claude가 차례로 여러 페르소나를 입었다 벗었다 한다.

### MCP Server

Model Context Protocol을 통해 Claude에 외부 도구·자원을 제공하는 서버. Context7(공식 문서), Magic(UI 생성), Sequential(다단 추론), Serena(시맨틱 코드 이해), Playwright(브라우저 자동화), Morphllm(대량 편집), Tavily(웹 검색) 등이 있다. *Tool*과 다른 개념 — MCP Server가 Tool들을 묶어 노출한다.

### Worktree (Isolation)

Agent 실행 시 git worktree를 따로 만들어 메인 작업 트리와 격리된 독립 브랜치에서 작업하게 하는 메커니즘. `harness-worker`, `team-implementer`, `generator` 등이 사용한다. 실패해도 메인 트리에 영향이 없고, 성공 시에만 머지된다.

### Generator + Validator

코드 생성과 검증을 분리한 페어 패턴. Generator는 Write 권한으로 worktree에서 코드를 만들고, Validator는 Read-only로 검증한다. 같은 Claude가 자기 코드를 검증하는 confirmation bias를 막는다.

### Goal vs Loop

| | `/goal` | `/loop` |
|--|---------|---------|
| 종료 | 검증 가능한 조건 충족 시 | 고정 횟수 또는 사용자 중단 |
| 적합 | Strong criteria가 있는 자율 실행 | 단순 반복 작업 |
| 안전망 | Circuit Breaker, Verification Iron Law 자동 적용 | 직접 챙겨야 함 |

### NOT-skills (혼동 방지)

- `CLAUDE.md`, `RULES.md`, `MODES.md` 등 — **frame work 문서**다. Skill이 아니다.
- `pre-commit.sh` 같은 hook 스크립트 — **Hook**이지 Skill이 아니다.
- `business-panel-experts` — **Agent**(다중 페르소나 패널)지 Skill이 아니다. (그러나 `/business-panel`은 Skill이다 — Agent를 호출하는 Skill.)

### 도메인 헷갈리기 쉬운 짝

| Term A | Term B | 구분 |
|--------|--------|------|
| Skill | Command | Command는 폐기. 모두 Skill이라 부른다. |
| Agent | Persona | Agent는 독립 인스턴스, Persona는 단일 Claude의 모드 전환. |
| Harness Mode | Harness Engineering | Mode는 작업 모드, Engineering은 메타 원칙. |
| /goal | /loop | /goal은 조건 기반 종료, /loop는 횟수 기반 종료. |
| Verification (Iron Law) | Goal Soft Check | Iron Law는 hard evidence 요구, Soft Check는 작은 모델의 추정. |
| Two-Stage Review Stage 1 | Stage 2 | Stage 1은 스펙 정합, Stage 2는 코드 품질. |
| MCP Server | Tool | Server가 Tool을 묶어 노출한다. |
