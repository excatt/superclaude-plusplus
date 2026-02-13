# Changelog

모든 주요 변경 사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따르며,
[Semantic Versioning](https://semver.org/lang/ko/)을 준수합니다.

## [0.8.4] - 2026-02-13

### Changed
- **Python 패키지 매니저 Poetry → uv 전환**:
  - 모든 규칙/컨벤션 문서에서 Poetry 참조를 uv로 교체
  - `pyproject.toml` 형식: `[tool.poetry]` → `[project]` (PEP 621 표준)
  - Lock 파일: `poetry.lock` → `uv.lock`
  - Dockerfile 패턴: `pip install poetry` → `COPY --from=ghcr.io/astral-sh/uv`
  - CI/CD 패턴: `snok/install-poetry` → `astral-sh/setup-uv`
  - 금지 목록: `pip, uv, pipenv` → `pip, poetry, pipenv`
- **스킬 리네임**: `skills/poetry-package/` → `skills/uv-package/` (내용 전면 재작성)
- **python-best-practices 스킬**: uv 기반 명령어 및 PEP 621 pyproject.toml 예시로 교체

### Files Changed
- `RULES.md`, `CONVENTIONS.md`, `CLAUDE.md`, `README.md`
- `skills/uv-package/SKILL.md` (신규, poetry-package 대체)
- `skills/python-best-practices/SKILL.md`
- `.claude/context.md`

## [0.8.3] - 2026-02-11

### Added
- **Session Summary Hook** (`scripts/session-summary.py`):
  - Stop hook에서 매 응답 완료 시 세션 요약 자동 생성
  - `<project>/memory/last-session.md`에 저장 (덮어쓰기 방식)
  - 다음 세션에서 이전 컨텍스트 빠르게 파악 가능
  - 크기 제한: 처음 3개 + 마지막 5개 메시지, 파일 최대 15개
  - JSONL 트랜스크립트에서 `entry.message.role` 구조 파싱
- **convention-check.sh** PostToolUse hook 추가 (templates/settings.json)

## [0.8.2] - 2026-02-11

### Changed
- **statusline.sh 3-Line 간소화 레이아웃 리팩토링**:
  - Line 1: 핵심 정보 (모델, 프로젝트, Git, 언어, Vim, Agent)
  - Line 2: Transcript 경로 (OSC 8 하이퍼링크)
  - Line 3: Context 사용량 + compact 경고
- CC 버전 업데이트 체크 추가 (`~/.claude/.cc_version_cache` 캐시)
- Compact 경고 기능 (context 80%+ 사용 시)

### Removed
- Output style 표시, 토큰 상세, Session ID/시간, TODO 진행상황, Progress bar

## [0.8.1] - 2026-02-09

### Changed
- **Session Chaining → Auto Memory**: Claude Code 내장 Auto Memory 기능 활용으로 전환
  - 커스텀 Session Chaining 기능 제거 (중복 기능)
  - Auto Memory 활용 가이드로 대체
  - `/memory` 명령어로 메모리 확인/편집 안내

### Removed
- **Session Chaining 섹션** (CLAUDE.md, RULES.md)
- **Session Chaining 플래그** (FLAGS.md):
  - `--chain-full`, `--chain-minimal`, `--chain-off`
  - `--auto-restore`, `--no-restore`
- **자동 트리거**: Context Restore, Session Summary
- **커맨드**: `/session-save`, `/session-load`, `/session-end`, `/context-show`, `/context-update`
- **Auto-Invoke 항목**: 세션 시작/종료 관련 2개 항목

### Added
- **Memory Management 섹션** (CLAUDE.md, RULES.md):
  - Auto Memory 내장 기능 설명
  - CLAUDE.md 계층 구조 가이드
  - 명시적 저장 요청 예시

## [0.8.0] - 2026-02-09

### Added
- **Superpowers 통합** (RULES.md):
  - Two-Stage Review System (Spec Compliance → Code Quality)
  - Verification Iron Law ("NO COMPLETION CLAIMS WITHOUT FRESH EVIDENCE")
  - 3+ Fixes Architecture Rule (동일 버그 3회 실패 시 아키텍처 재검토)
  - Worker Templates (Implementer, Spec Reviewer, Quality Reviewer)
- **Auto-Invoke 확장** (17개 → 24개):
  - 테스트 실패 시 `/debug` 자동 실행
  - 복잡한 함수(50줄+) 생성 시 `/code-smell` 자동 실행
  - 에러 핸들링 누락 시 `/error-handling` 자동 실행
  - Next.js 작업 시 `/nextjs` 자동 실행
  - FastAPI 작업 시 `/fastapi` 자동 실행
  - 대규모 변경(10+ 파일) 시 `/checkpoint` 자동 실행
  - 테스트 없는 함수 생성 시 `/testing` 제안

### Changed
- **CLAUDE.md**: Auto-Invoke 테이블 확장
- **README.md**: Auto-Invoke 섹션 업데이트, Superpowers 통합 내용 추가

## [0.7.1] - 2026-02-06

### Changed
- **RULES.md 최적화**: 42.3k → 17k (60% 압축)
  - ASCII 다이어그램 → 테이블 변환
  - 중복 예시 제거, 핵심 템플릿 유지
  - 모든 Auto-Skill 트리거 키워드 보존
  - Python/Node.js 코드 템플릿 보존 (pyproject.toml, Dockerfile)
  - Security Checklist 및 프롬프트 조정 전략 보존
  - 글로벌(`~/.claude/RULES.md`)과 프로젝트 레벨 동기화

## [0.7.0] - 2026-02-06

### Added
- **Proactive Suggestion Rule** (RULES.md):
  - 작업 컨텍스트에 맞는 스킬/에이전트/MCP 서버 적극 제안
  - 실행 전 사용자 확인으로 안전성 보장
  - 코드 품질 트리거 (50줄+ 함수, 복잡한 로직, 중복 코드)
  - 아키텍처/설계 트리거 (API, DB, 패턴, 마이크로서비스)
  - MCP 서버 자동 제안 (Context7, Sequential, Magic, Morphllm, Tavily, Playwright)
  - 에이전트 자동 제안 (10개 전문가 에이전트)
  - 제안 강도 조절 (`--suggest-all`, `--suggest-minimal`, `--suggest-off`)
- **Proactive Suggestion Flags** (FLAGS.md):
  - `--suggest-all`: 모든 관련 도구 적극 제안 (기본값)
  - `--suggest-minimal`: 핵심 도구만 제안
  - `--suggest-off`, `--no-suggest`: 자동 제안 비활성화
  - `--auto-agent`: 에이전트 자동 제안 활성화
  - `--auto-mcp`: MCP 서버 자동 활성화 제안
### Changed
- **CLAUDE.md**: Proactive Suggestions 섹션, Workflow Integration 업데이트
- **README.md**: Proactive Suggestions 섹션 추가, 플래그 문서화

## [0.6.1] - 2026-02-04

### Added
- **Progress Communication** (MODES.md - Orchestration Mode):
  - 핵심 원칙: "Absorb complexity, radiate simplicity"
  - 상황별 자연어 표현 가이드 (기술 용어 → 자연어)
  - 마일스톤 박스 형식 (Phase 완료 시 시각적 피드백)
  - 숨겨야 할 것 vs 보여줄 것 가이드라인

## [0.6.0] - 2026-02-04

### Added
- **Agent Error Recovery** (RULES.md):
  - 실패 유형 분류 (Timeout, Incomplete, Wrong Approach, Blocked, Conflict)
  - 복구 프로토콜 (최대 2회 재시도 → 에스컬레이션)
  - 프롬프트 조정 전략 (EXPLICIT, SCOPE, CONSTRAINT, CONTEXT, REDUCED SCOPE)
  - 에스컬레이션 규칙 (AskUserQuestion으로 4가지 선택지 제공)
  - 부분 성공 처리 (50-99% 완료 시 활용 전략)

### Changed
- **README.md**: Agent Error Recovery 섹션 추가

## [0.5.0] - 2026-02-04

### Added
- **Orchestrator vs Worker Pattern** (RULES.md):
  - 에이전트 역할 분리 (Orchestrator: 조율, Worker: 실행)
  - Worker 프롬프트 템플릿 (CONTEXT + RULES + TASK)
  - 도구 소유권 가이드라인 (Orchestrator용 vs Worker용)
- **Agent Model Selection** (RULES.md):
  - 기본: 부모 모델 상속 (model 파라미터 생략)
  - 필요시 명시적 지정 (haiku/sonnet/opus)
  - Background Agent 필수 규칙 (`run_in_background=True`)
  - Non-blocking Mindset 가이드
- **Orchestration Pipeline** (MODES.md):
  - 4단계 파이프라인: Clarify → Parallelize → Execute → Synthesize
  - AskUserQuestion 4×4 전략 (4 questions × 4 options, Rich descriptions)
  - 의존성 분석 기준 (파일/데이터/논리적 독립)
  - 복잡도별 스폰 패턴 (1-2개 ~ 4+개)

### Changed
- **MODES.md - Orchestration Mode**: 기존 Tool Selection Matrix에 4단계 파이프라인 통합
- **README.md**: Orchestrator/Worker Pattern, Orchestration Pipeline 섹션 추가

## [0.4.0] - 2026-02-02

### Added
- **optional/ 디렉토리**: 선택적 로딩을 위한 상세 문서 분리 (20개 파일)
  - MCP 서버별 상세 가이드 (Context7, Magic, Morphllm, Playwright, Sequential, Serena, Tavily)
  - MODE별 상세 가이드 (Brainstorming, Business_Panel, DeepResearch, Introspection, Orchestration, Task_Management, Token_Efficiency)
  - BUSINESS_PANEL_EXAMPLES.md, BUSINESS_SYMBOLS.md, CONTEXTS.md, KNOWLEDGE.md, PATTERNS.md, RESEARCH_CONFIG.md
- **scripts/convention-check.sh**: 네이밍 컨벤션 자동 체크 스크립트
  - Python snake_case 검사
  - TypeScript camelCase 검사
  - 파일명 규칙 검사

### Changed
- **CONVENTIONS.md**:
  - Python 패키지 관리 규칙 추가 (Poetry 필수, pip/uv/pipenv 금지)
  - Node.js/TypeScript 패키지 관리 규칙 추가 (pnpm 필수, npm/yarn 금지)
  - pyproject.toml, Dockerfile, CI/CD 패턴 예시 추가
- **RULES.md**:
  - Python Project Rules 추가 (Poetry 필수, Detection 규칙)
  - Node.js Project Rules 추가 (pnpm 필수, Detection 규칙)
- **skills/python-best-practices/SKILL.md**:
  - Poetry 필수 규칙 추가
  - pyproject.toml Poetry 형식 예시
  - Docker 패턴 추가
  - poetry run 명령어 사용 가이드
- **skills/react-best-practices/SKILL.md**:
  - Priority 0: Package Management (MANDATORY) 섹션 추가
  - pnpm 필수 규칙 (npm, yarn 금지)
  - Dockerfile 패턴, CI/CD 패턴 추가

## [0.3.0] - 2026-01-31

### Added
- **PDCA Workflow Rule**: 체계적인 개발 사이클 (Plan → Design → Do → Check → Act → Report)
  - Match Rate 기반 품질 게이트 (≥90% 통과, 70-89% 자동 수정, <70% 설계 재검토)
  - Gap Analysis 자동 트리거 ("맞아?", "확인해", "설계대로야?")
  - `.pdca-status.json` 상태 추적
- **새로운 스킬 3개**:
  - `/web-design-guidelines` - Vercel Web Interface Guidelines 기반 UI/UX 리뷰 (100+ 규칙)
  - `/composition-patterns` - React Compound Components 패턴 가이드
  - `/gap-analysis` - 설계-구현 비교 및 Match Rate 계산
- **PDCA 템플릿 4개**:
  - `templates/plan.template.md` - 기능 계획 문서
  - `templates/design.template.md` - 설계 문서
  - `templates/analysis.template.md` - Gap 분석 리포트
  - `templates/report.template.md` - 완료 리포트
- **훅 스크립트**:
  - `scripts/post-write-check.sh` - 파일 작성 후 Convention 체크
  - `scripts/pre-compact-save.sh` - 컴팩션 전 상태 저장
- `templates/hooks.json` - SuperClaude 훅 설정 예시

### Changed
- **CLAUDE.md**:
  - Auto-Invoke 테이블에 UI 리뷰(`/web-design-guidelines`) 추가
  - Frontend 도메인에 `/composition-patterns`, `/web-design-guidelines` 추가
  - Review 워크플로우에 `/web-design-guidelines` 추가
- **RULES.md**:
  - Auto-Skill Invocation Rule에 PDCA Check/Act 트리거 추가
  - Quick Reference에 PDCA Workflow 의사결정 트리 추가
  - IMPORTANT 우선순위에 PDCA 관련 규칙 추가

## [0.2.0] - 2025-01-30

### Added
- **Document Skills**: Word, PDF, PowerPoint, Excel 문서 처리 스킬 추가
  - `skills/document-skills/docx/` - OOXML 기반 Word 문서 생성/편집
  - `skills/document-skills/pdf/` - PDF 폼 처리 스크립트
  - `skills/document-skills/pptx/` - PowerPoint 프레젠테이션 생성
  - `skills/document-skills/xlsx/` - Excel 스프레드시트 처리
- **CONTEXTS.md**: DEV/REVIEW/RESEARCH/PLANNING 컨텍스트 모드 상세 문서
- **CONVENTIONS.md**: Python, TypeScript, React, CSS 등 네이밍 컨벤션 가이드
- **PATTERNS.md**: API Response, Repository, Custom Hooks 등 재사용 가능한 코드 패턴
- **KNOWLEDGE.md**: PM Agent ROI, Parallel Execution, 트러블슈팅 가이드
- **BUSINESS_PANEL_EXAMPLES.md**: 비즈니스 패널 사용 예시 및 통합 패턴
- **BUSINESS_SYMBOLS.md**: 비즈니스 분석용 심볼 시스템
- **RESEARCH_CONFIG.md**: Deep Research 설정 및 최적화 옵션
- `scripts/statusline.sh`: 상태바 스크립트
- `templates/`: 템플릿 파일 디렉토리
- 다양한 스킬 리소스 추가:
  - `skills/frontend-design/LICENSE.txt`
  - `skills/internal-comms/examples/`
  - `skills/mcp-builder/reference/`, `scripts/`
  - `skills/skill-creator/scripts/`
  - `skills/theme-factory/themes/`, `theme-showcase.pdf`

### Changed
- **디렉토리 구조 단순화**:
  - `core/` 디렉토리 제거 → 파일들을 루트로 이동
  - `optional/` 디렉토리 제거 → 파일들을 루트로 이동 또는 통합
- **MCP 문서 통합**:
  - `optional/MCP_Context7.md`, `MCP_Magic.md` 등 7개 파일 → `MCP_SERVERS.md`로 통합
- **MODE 문서 통합**:
  - `optional/MODE_Brainstorming.md`, `MODE_Orchestration.md` 등 7개 파일 → `MODES.md`로 통합
- **스킬 파일 리네임**:
  - `skills/*/skill.md` → `skills/*/SKILL.md` (대문자로 통일, 28개 파일)
- README.md 전면 개편:
  - 프로젝트명: My Claude Config → SuperClaude++
  - GitHub URL 업데이트
  - 새로운 기능 문서화
  - 설치 방법 개선

### Removed
- `core/` 디렉토리 (내용은 루트로 이동)
- `optional/` 디렉토리 (내용은 루트로 이동 또는 통합)
- 개별 MCP 서버 문서 (MCP_SERVERS.md로 통합)
- 개별 MODE 문서 (MODES.md로 통합)

### Fixed
- **install.sh 디렉토리 구조 보존 버그 수정**:
  - 기존 설치 시 이전 파일과 새 파일이 혼합되던 문제 해결 (백업 후 정리)
  - `cp -r` trailing slash 버그로 스킬 디렉토리가 평탄화되던 문제 수정
  - 이제 모든 30개 스킬이 올바른 디렉토리 구조로 설치됨

## [0.1.0] - 2025-01-29

### Added
- 초기 릴리스: SuperClaude++ 프레임워크
- **Core Framework**:
  - CLAUDE.md - 엔트리 포인트
  - FLAGS.md - 플래그 시스템
  - RULES.md - 행동 규칙
  - PRINCIPLES.md - 엔지니어링 원칙
  - MODES.md - 행동 모드
  - MCP_SERVERS.md - MCP 서버 가이드
- **Agents**: 19개 전문가 에이전트
- **Skills**: 28개 스킬
- **Commands**: 50+ 슬래시 커맨드
- MIT 라이선스

---

## Version History Summary

| 버전 | 날짜 | 주요 변경 |
|------|------|----------|
| 0.8.4 | 2026-02-13 | Python 패키지 매니저 Poetry → uv 전환 |
| 0.8.1 | 2026-02-09 | Session Chaining → Auto Memory 전환 (내장 기능 활용) |
| 0.8.0 | 2026-02-09 | Superpowers 통합 + Auto-Invoke 확장 (17→24개) |
| 0.7.1 | 2026-02-06 | RULES.md 최적화 (42.3k → 17k, 60% 압축) |
| 0.7.0 | 2026-02-06 | Proactive Suggestion 추가 |
| 0.6.1 | 2026-02-04 | Progress Communication (자연어 표현, 마일스톤 박스) |
| 0.6.0 | 2026-02-04 | Agent Error Recovery (실패 복구, 재시도, 에스컬레이션) |
| 0.5.0 | 2026-02-04 | Orchestrator/Worker 패턴, Orchestration Pipeline 4단계 |
| 0.4.0 | 2026-02-02 | optional/ 디렉토리, 패키지 관리 규칙 (uv/pnpm 필수) |
| 0.3.0 | 2026-01-31 | PDCA Workflow, 새 스킬 3개, 템플릿 4개 |
| 0.2.0 | 2025-01-30 | Document Skills 추가, 디렉토리 구조 단순화 |
| 0.1.0 | 2025-01-29 | 초기 릴리스 |
