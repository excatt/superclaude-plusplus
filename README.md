# SuperClaude++

Claude Code를 위한 고급 프레임워크 - 생산성 향상, 자동화, 전문가 수준 워크플로우를 제공합니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## About

SuperClaude++는 [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)를 기반으로 개인 사용에 맞게 확장한 프로젝트입니다. 원본 SuperClaude의 강력한 구조 위에 다양한 커뮤니티 베스트 프랙티스, 자동화 워크플로우, 전문가 에이전트 시스템을 통합하여 Claude Code의 잠재력을 최대한 끌어냅니다.

## Features

### 🎯 Core Framework
| 파일 | 설명 |
|------|------|
| **CLAUDE.md** | 엔트리 포인트 및 언어 설정 (한국어) |
| **FLAGS.md** | 행동 플래그 시스템 (`--think`, `--ultrathink`, `--uc` 등) |
| **RULES.md** | 개발 규칙 및 자동화 트리거 (17k, 최적화됨) |
| **PRINCIPLES.md** | SOLID, DRY, KISS 등 소프트웨어 엔지니어링 원칙 |
| **MODES.md** | 상황별 행동 모드 (Brainstorming, Orchestration, Token Efficiency 등) |
| **MCP_SERVERS.md** | MCP 서버 통합 가이드 (Context7, Magic, Serena 등) |
| **CONTEXTS.md** | DEV/REVIEW/RESEARCH/PLANNING 컨텍스트 모드 |
| **CONVENTIONS.md** | 네이밍 컨벤션 + 패키지 관리 규칙 (Poetry/pnpm 필수) |
| **PATTERNS.md** | 재사용 가능한 코드 패턴 모음 |
| **KNOWLEDGE.md** | 축적된 인사이트 및 트러블슈팅 가이드 |

### 🤖 Specialist Agents
| Agent | 역할 |
|-------|------|
| `backend-architect` | 백엔드 시스템 설계 |
| `frontend-architect` | UI/UX 및 프론트엔드 아키텍처 |
| `security-engineer` | 보안 취약점 분석 |
| `performance-engineer` | 성능 최적화 |
| `deep-research-agent` | 심층 리서치 |
| `business-panel-experts` | 비즈니스 전략 분석 (9명의 전문가 패널) |
| 그 외 10+ agents | system-architect, quality-engineer, pm-agent 등 |

### 📚 Skills (40+)

#### Core Skills
| Skill | 설명 |
|-------|------|
| `/confidence-check` | 구현 전 신뢰도 평가 (≥90% 필요) |
| `/verify` | 완료 후 6단계 검증 체크리스트 |
| `/checkpoint` | 위험 작업 전 복원 지점 생성 |
| `/note` | 컴팩션에서 살아남는 영구 메모 시스템 |
| `/learn` | 재사용 가능한 패턴 추출 및 저장 |

#### Development Skills
| Skill | 설명 |
|-------|------|
| `/react-best-practices` | React/Next.js 코드 리뷰 (40+ 규칙) |
| `/web-design-guidelines` | Vercel UI/UX 리뷰 (100+ 규칙) |
| `/composition-patterns` | React Compound Components 패턴 |
| `/python-best-practices` | Python 코드 리뷰 및 베스트 프랙티스 |
| `/pytest-runner` | pytest 실행, 커버리지 분석 |
| `/poetry-package` | Poetry 패키지 관리 |
| `/feature-planner` | 기능 구현 계획 수립 |
| `/gap-analysis` | 설계-구현 비교, Match Rate 계산 |

#### Document Skills (NEW)
| Skill | 설명 |
|-------|------|
| `/docx` | Word 문서 생성/편집 (OOXML 기반) |
| `/pdf` | PDF 폼 처리 및 조작 |
| `/pptx` | PowerPoint 프레젠테이션 생성 |
| `/xlsx` | Excel 스프레드시트 처리 |

#### Domain Skills
- **Architecture**: `/architecture`, `/api-design`, `/db-design`, `/design-patterns`
- **Security**: `/security-audit`, `/auth`, `/error-handling`
- **Performance**: `/perf-optimize`, `/caching`, `/scaling`
- **DevOps**: `/docker`, `/cicd`, `/monitoring`, `/env`
- **Quality**: `/clean-code`, `/refactoring`, `/testing`, `/code-review`

### 🔧 Automation

#### Auto-Invoked Skills (24개)
| 트리거 | 스킬 | 키워드 |
|--------|------|--------|
| 구현 시작 전 | `/confidence-check` | 구현, 만들어, implement |
| 기능 완료 후 | `/verify` | 완료, done, PR |
| 빌드 에러 | `/build-fix` | error TS, Build failed |
| React 파일 리뷰 | `/react-best-practices` | .tsx + 리뷰 |
| UI 리뷰 | `/web-design-guidelines` | UI 리뷰, 접근성, a11y |
| Python 파일 리뷰 | `/python-best-practices` | .py + 리뷰 |
| 위험 작업 전 | `/checkpoint` | 리팩토링, 삭제, 10+ 파일 |
| PDCA Check | `/gap-analysis` | 맞아?, 확인해, 설계대로야? |
| 커밋/PR | Two-Stage Review | commit, PR, 머지 |
| 완료 주장 | Verification Gate | 됐어, 작동해, fixed |
| 수정 3회 실패 | Architecture Alert | (자동 감지) |
| 테스트 실패 | `/debug` | pytest FAILED, test failed |
| 복잡한 함수 | `/code-smell` | 50줄+ 함수 생성 |
| 에러 핸들링 누락 | `/error-handling` | async/await + no try-catch |
| Next.js 작업 | `/nextjs` | page.tsx, layout.tsx |
| FastAPI 작업 | `/fastapi` | @router, APIRouter |

#### Proactive Suggestions (NEW)
작업 컨텍스트에 맞는 스킬/에이전트/MCP 서버를 **적극 제안** (확인 후 실행):

| 상황 | 제안 도구 | 트리거 조건 |
|------|----------|-------------|
| 복잡한 함수 | `/code-review`, `/code-smell` | 50줄+ 함수 |
| API 설계 | `/api-design`, `backend-architect` | endpoint, REST |
| 성능 이슈 | `performance-engineer` | 느림, slow, optimize |
| 보안 관련 | `security-engineer`, `/auth` | 로그인, JWT, 보안 |
| 프레임워크 | **Context7** MCP | React, Next.js, Vue |
| UI 컴포넌트 | **Magic** MCP | button, form, modal |
| 복잡한 분석 | **Sequential** MCP | 디버깅 3회+, 설계 |

**제안 강도 플래그**: `--suggest-all` (기본) | `--suggest-minimal` | `--suggest-off`

#### Hooks
| Hook | 기능 |
|------|------|
| `todo-continuation` | TODO 미완료 시 작업 중단 방지 |
| `pre-compact-note` | 컴팩션 전 자동 노트 저장 요청 |
| `pre-compact-save` | 컴팩션 전 상태 저장 |
| `post-write-check` | 파일 작성 후 Convention 체크 |
| `suggest-compact` | 컨텍스트 임계치 도달 시 컴팩션 제안 |
| `evaluate-session` | 세션 종료 시 패턴 추출 제안 |

### 🎛️ Flags & Modes

#### Analysis Depth
| Flag | 토큰 | 용도 |
|------|------|------|
| `--think` | ~4K | 중간 복잡도 |
| `--think-hard` | ~10K | 아키텍처 분석 |
| `--ultrathink` | ~32K | 시스템 재설계 |

#### MCP Server Flags
| Flag | 서버 | 용도 |
|------|------|------|
| `--c7` | Context7 | 공식 문서 조회 |
| `--magic` | Magic | UI 컴포넌트 생성 |
| `--seq` | Sequential | 다단계 추론 |
| `--serena` | Serena | 시맨틱 코드 이해 |
| `--tavily` | Tavily | 웹 검색/리서치 |

#### Context Modes
| Flag | 모드 | 특성 |
|------|------|------|
| `--ctx dev` | 개발 | 작동 > 완벽, 코드 먼저 |
| `--ctx review` | 리뷰 | 심층 분석, 심각도별 정리 |
| `--ctx research` | 리서치 | 완전성 > 속도, 증거 기반 |

#### Proactive Suggestion Flags (NEW)
| Flag | 설명 |
|------|------|
| `--suggest-all` | 모든 관련 도구 적극 제안 (기본값) |
| `--suggest-minimal` | 핵심 도구만 제안 |
| `--suggest-off` | 자동 제안 비활성화 |
| `--auto-agent` | 에이전트 자동 제안 활성화 |
| `--auto-mcp` | MCP 서버 자동 활성화 제안 |

## Installation

### Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/excatt/superclaude-plusplus/main/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/excatt/superclaude-plusplus.git
cd superclaude-plusplus
./install.sh
```

### 설치 후
1. **Claude Code 재시작** - 변경 사항 적용
2. `/note --show` - 노트 시스템 확인
3. 기존 `settings.json`이 있었다면 hooks 설정 병합 필요

## Directory Structure

```
~/.claude/
├── CLAUDE.md              # 메인 엔트리 포인트
├── FLAGS.md               # 플래그 시스템
├── RULES.md               # 행동 규칙
├── PRINCIPLES.md          # 엔지니어링 원칙
├── MODES.md               # 행동 모드
├── MCP_SERVERS.md         # MCP 서버 가이드
├── CONTEXTS.md            # 컨텍스트 모드
├── CONVENTIONS.md         # 네이밍 컨벤션
├── PATTERNS.md            # 코드 패턴
├── KNOWLEDGE.md           # 인사이트/트러블슈팅
├── notepad.md             # 영구 메모
├── settings.json          # hooks, statusLine 설정
├── scripts/
│   ├── statusline.sh       # 상태바 스크립트
│   ├── convention-check.sh # 네이밍 컨벤션 자동 체크
│   ├── post-write-check.sh # Convention 체크
│   └── pre-compact-save.sh # 컴팩션 전 저장
├── optional/               # 선택적 로딩 문서
│   ├── MCP_*.md            # MCP 서버별 상세 가이드 (7개)
│   ├── MODE_*.md           # MODE별 상세 가이드 (7개)
│   └── *.md                # 기타 참조 문서 (6개)
├── skills/
│   ├── confidence-check/SKILL.md
│   ├── verify/SKILL.md
│   ├── gap-analysis/SKILL.md      # 설계-구현 비교
│   ├── web-design-guidelines/     # UI/UX 리뷰
│   ├── composition-patterns/      # React 패턴
│   ├── document-skills/   # docx, pdf, pptx, xlsx
│   └── ...                # 40+ skills
├── agents/                # 전문가 에이전트 정의
├── commands/              # 슬래시 커맨드 정의
└── templates/
    ├── plan.template.md       # PDCA Plan
    ├── design.template.md     # PDCA Design
    ├── analysis.template.md   # PDCA Check (Gap Analysis)
    ├── report.template.md     # PDCA Report
    └── hooks.json             # 훅 설정 예시
```

## Key Concepts

### PDCA Workflow (NEW)
체계적인 개발 사이클을 위한 Plan-Do-Check-Act 워크플로우:
```
Plan → Design → Do → Check → Act → Report
```
- **Match Rate 기반 품질 게이트**: ≥90% 통과, 70-89% 자동 수정, <70% 설계 재검토
- **Gap Analysis**: 설계 문서와 구현 코드 자동 비교
- **템플릿 제공**: `plan.template.md`, `design.template.md`, `analysis.template.md`, `report.template.md`

### Confidence Check (신뢰도 체크)
구현 전 90% 이상의 신뢰도가 필요합니다:
- 중복 구현 확인
- 아키텍처 준수 검증
- 공식 문서 검토
- 근본 원인 파악

### Persistence Enforcement (끈기 강제)
TODO 항목이 남아있으면 작업 중단을 방지합니다:
- 최대 10회 반복 후 자동 해제 (무한 루프 방지)
- `.claude/state/`에 진행 상황 저장

### Note System (노트 시스템)
세션 컴팩션에서 중요 정보를 보존합니다:
```bash
/note <content>            # Working Memory (7일 후 정리)
/note --priority <content> # Priority Context (항상 로드, 500자)
/note --manual <content>   # MANUAL (영구 저장)
```

### Token Efficiency Mode
컨텍스트 >75% 시 자동 활성화:
- 심볼 시스템 사용 (→, ⇒, ✅, ❌, ⚠️)
- 30-50% 토큰 감소, ≥95% 정보 품질 유지

### Orchestrator/Worker Pattern (NEW)
에이전트 역할 분리를 통한 효율적인 작업 분배:

| 역할 | 책임 | 도구 |
|------|------|------|
| **Orchestrator** | 작업 분해, 에이전트 스폰, 결과 합성 | Task, AskUserQuestion, TaskCreate/Update |
| **Worker** | 구체적 작업 실행, 결과 보고 | Read, Write, Edit, Bash, Grep |

- Worker 프롬프트 템플릿 필수 (CONTEXT + RULES + TASK)
- `run_in_background=True` 항상 사용
- 부모 모델 상속 기본, 필요시 명시적 지정 (haiku/sonnet/opus)

### Orchestration Pipeline (NEW)
4단계 오케스트레이션 파이프라인:
```
Step 1: CLARIFY (AskUserQuestion 4×4)
    ↓
Step 2: PARALLELIZE (의존성 분석)
    ↓
Step 3: EXECUTE (병렬 스폰)
    ↓
Step 4: SYNTHESIZE (결과 합성)
```

- **4×4 전략**: 4 questions × 4 options, Rich descriptions
- **의존성 분석**: 독립 작업 → 병렬, 의존 작업 → 순차
- **Non-blocking Mindset**: 에이전트 작업 중 다음 할 일 준비

### Agent Error Recovery (NEW)
에이전트 실패 시 자동 복구 전략:

| 실패 유형 | 복구 전략 |
|----------|----------|
| **Timeout** | 작업 분할 후 재시도 |
| **Incomplete** | 남은 부분만 재시도 |
| **Wrong Approach** | 명시적 제약과 함께 재시도 |
| **Blocked** | 차단 요소 먼저 해결 |
| **Conflict** | 사용자에게 선택 요청 |

- **최대 2회 재시도**: 프롬프트 조정 후 재스폰
- **에스컬레이션**: 2회 실패 시 AskUserQuestion으로 사용자에게 선택권 부여
- **부분 성공 활용**: 50-99% 완료 시 완료된 부분 사용 + 나머지 재처리

### Memory Management
Claude Code의 내장 Auto Memory를 활용한 세션 간 연속성:

**Auto Memory** (`~/.claude/projects/<project>/memory/`):
- 프로젝트 패턴, 디버깅 인사이트, 아키텍처 노트 자동 저장
- 세션 시작 시 MEMORY.md 자동 로드 (첫 200줄)

**명시적 저장 요청**:
```
"이 프로젝트는 pnpm 사용한다고 기억해"
"API 테스트는 로컬 Redis 필요하다고 저장해"
```

**CLAUDE.md 계층**:
| 용도 | 위치 |
|------|------|
| 팀 공유 규칙 | `./CLAUDE.md`, `.claude/rules/` |
| 개인 전역 | `~/.claude/CLAUDE.md` |
| 개인 프로젝트 | `./CLAUDE.local.md` |

**확인/편집**: `/memory` 명령어

### Two-Stage Review System (NEW)
작업 완료 시 2단계 리뷰 자동 실행:

| Stage | 목적 | 검증 항목 |
|-------|------|----------|
| **Stage 1: Spec Compliance** | 요구사항 준수 | 누락 기능, 과잉 구현, 스펙 일치 |
| **Stage 2: Code Quality** | 코드 품질 | Critical/Important/Minor 이슈 |

- **Reviewer 원칙**: "DO NOT trust the implementer's report" - 실제 코드 직접 확인
- **Review Loop**: Implement → Spec Review → Quality Review → Complete

### Verification Iron Law (NEW)
완료 주장 시 자동 검증 게이트:
```
"NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE"
```

| 검증 타입 | 필수 증거 |
|----------|----------|
| 테스트 통과 | 실제 출력 로그 |
| 기능 완료 | 각 요구사항 체크리스트 |
| 버그 수정 | 재현 테스트 결과 |

### 3+ Fixes Architecture Rule (NEW)
동일 버그 3회 수정 실패 시:
1. 즉시 코딩 중단
2. 아키텍처/설계 재검토
3. 근본 원인 재분석
4. 사용자에게 방향 확인 (AskUserQuestion)

### Package Management Rules
프로젝트별 패키지 매니저 강제:

| 언어 | 필수 | 금지 |
|------|------|------|
| **Python** | Poetry | pip, uv, pipenv |
| **Node.js** | pnpm | npm, yarn |

- 자동 감지: `requirements.txt`, `uv.lock`, `package-lock.json`, `yarn.lock` 발견 시 마이그레이션 제안
- Dockerfile/CI 패턴 예시 포함

## Configuration

### Language
기본값: 한국어

CLAUDE.md에서 변경:
```markdown
## Language
- **ALWAYS respond in English**
```

### Hooks Customization
`settings.json`의 `hooks` 섹션에서 스크립트 추가/제거 가능.

### StatusLine
`scripts/statusline.sh`를 수정하여 표시 항목 커스터마이즈.

**기본 3-Line 레이아웃**:

| Line | 내용 | 예시 |
|------|------|------|
| **1** | 디렉토리, Git, 언어, 모델, CC 버전(업데이트 체크), Vim, Agent, 변경 라인 | `📁 ~/proj  🌿 main  🤖 Opus 4.6  📟 v2.1.39 ⬆️2.2.0  📝 +56/-165` |
| **2** | Transcript 경로 (클릭 가능 링크) | `📜 ~/.claude/projects/.../session.jsonl` |
| **3** | Context 사용량 + compact 경고 | `🟢 🧠 Context: 64K/200K (68% remaining)` |

**Context 경고 단계**:
- 🟢 < 60% 사용 (정상)
- 🟡 60~80% 사용 (주의)
- 🔴 80%+ 사용 + `⚠️ COMPACT SOON`
- 🚨 200K 초과 시 `EXCEEDS 200K TOKENS`

**CC 버전 업데이트 체크**: 첫 실행 시 1회 npm 체크, `~/.claude/.cc_version_cache`에 캐시.

## Updating

```bash
cd superclaude-plusplus
git pull
./install.sh
```

## Uninstall

```bash
# 전체 제거
rm -rf ~/.claude
```

## Requirements

- [Claude Code](https://docs.anthropic.com/claude-code) CLI
- Claude Max/Pro 구독 또는 Anthropic API 키
- macOS/Linux (Windows는 WSL 권장)
- `jq` (선택사항, 일부 스크립트에서 사용)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Credits & Acknowledgements

### 🙏 Special Thanks

이 프로젝트는 [**SuperClaude Framework**](https://github.com/SuperClaude-Org/SuperClaude_Framework)의 뛰어난 기반 위에 구축되었습니다. SuperClaude 팀의 혁신적인 접근 방식과 잘 설계된 아키텍처 덕분에 이 확장이 가능했습니다.

> *"거인의 어깨 위에 서서 더 멀리 본다"* - SuperClaude가 그 거인입니다.

### Inspirations & Integrations

- **[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)** - 핵심 프레임워크 구조 및 모드 시스템
- **[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)** - 자동화 훅 및 워크플로우 아이디어
- **[cc-statusline](https://www.npmjs.com/package/@chongdashu/cc-statusline)** - 상태바 구현 참고
- **Business Panel** - 클래식 비즈니스 문헌 기반 전문가 패널 방법론 (Christensen, Porter, Drucker 등)

### What's Added

SuperClaude++ = SuperClaude + 다음 요소들의 통합:
- 🔄 PDCA 워크플로우 및 Gap Analysis
- 🤖 Orchestrator/Worker 패턴 및 에이전트 에러 복구
- 💡 Proactive Suggestion (스킬/에이전트/MCP 적극 제안)
- 🧠 Auto Memory 활용 가이드 (Claude Code 내장 기능)
- ⚡ Superpowers 통합 (Two-Stage Review, Verification Iron Law, 3+ Fixes Rule)
- 📝 Note 시스템 (컴팩션 대응)
- 🎯 40+ 도메인별 Skills
- 🔧 자동 스킬 호출 시스템 (24개 Auto-Invoke 트리거)
- 📦 패키지 관리 규칙 강제 (Poetry/pnpm)
- 🌐 한국어 우선 지원

## License

MIT License - see [LICENSE](LICENSE) for details.
