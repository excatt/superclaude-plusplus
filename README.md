# SuperClaude++

[SuperClaude](https://github.com/supertools-ai/superclaude)를 기반으로 확장/커스터마이징한 Claude Code 프레임워크입니다.

다양한 소스에서 영감을 받아 통합하고, 직접 제작한 스킬과 규칙들을 추가했습니다.

## Features

- **153개 마크다운 설정 파일** - 에이전트, 커맨드, 스킬, 모드 등
- **17개 전문 에이전트** - 백엔드, 프론트엔드, 보안, 성능 등 도메인별 전문가
- **56개+ 커맨드** - 아키텍처, 테스팅, 리팩토링 등 개발 워크플로우
- **29개 스킬** - 자동화된 작업 패턴
- **7개 유틸리티 스크립트** - 세션 관리, 포맷팅 등

## Quick Start

### 1. 설치

```bash
# 기존 설정 백업 (있다면)
[ -d ~/.claude ] && mv ~/.claude ~/.claude.backup

# 저장소 클론
git clone https://github.com/excatt/superclaude-plusplus.git

# 설정 복사
cd superclaude-plusplus
./install.sh
```

### 2. 수동 설치

```bash
# ~/.claude 디렉토리 생성
mkdir -p ~/.claude/{agents,commands/sc,skills,scripts}

# 핵심 파일 복사
cp core/*.md ~/.claude/

# 에이전트, 커맨드, 스킬 복사
cp -r agents/* ~/.claude/agents/
cp -r commands/* ~/.claude/commands/
cp -r skills/* ~/.claude/skills/
cp -r optional/* ~/.claude/  # 선택적
cp scripts/*.sh ~/.claude/scripts/

# 스크립트 실행 권한
chmod +x ~/.claude/scripts/*.sh
```

## Directory Structure

```
superclaude-plusplus/
├── core/                    # 핵심 설정 파일
│   ├── CLAUDE.md           # 진입점 (자동 로드)
│   ├── FLAGS.md            # 플래그 시스템
│   ├── RULES.md            # 행동 규칙
│   ├── PRINCIPLES.md       # 엔지니어링 원칙
│   ├── MODES.md            # 행동 모드
│   └── MCP_SERVERS.md      # MCP 서버 가이드
│
├── agents/                  # 전문 에이전트 (17개)
│   ├── backend-architect.md
│   ├── frontend-architect.md
│   ├── security-engineer.md
│   ├── pm-agent.md         # 프로젝트 관리 에이전트
│   └── ...
│
├── commands/                # 슬래시 커맨드 (56개+)
│   ├── architecture.md
│   ├── clean-code.md
│   ├── testing.md
│   ├── sc/                 # Serena MCP 커맨드
│   │   ├── analyze.md
│   │   ├── implement.md
│   │   └── ...
│   └── ...
│
├── skills/                  # 스킬 (29개)
│   ├── confidence-check/   # 구현 전 신뢰도 검증
│   ├── verify/             # 완료 후 검증
│   ├── react-best-practices/
│   ├── python-best-practices/
│   └── ...
│
├── optional/                # 선택적 상세 설정
│   ├── CONTEXTS.md
│   ├── PATTERNS.md
│   ├── MODE_*.md           # 상세 모드 설명
│   └── MCP_*.md            # 상세 MCP 설정
│
└── scripts/                 # 유틸리티 스크립트
    ├── auto-format.sh
    ├── type-check.sh
    └── ...
```

## Core Concepts

### 플래그 시스템

```bash
# 분석 깊이
--think          # 중간 복잡도 (~4K tokens)
--think-hard     # 아키텍처 분석 (~10K tokens)
--ultrathink     # 시스템 재설계 (~32K tokens)

# MCP 서버 활성화
--c7, --context7   # 공식 문서 조회
--seq, --sequential # 복잡한 분석
--magic            # UI 컴포넌트 생성

# 실행 제어
--delegate         # 서브에이전트 병렬 처리
--validate         # 실행 전 위험 평가
--safe-mode        # 최대 검증
```

### 자동 스킬 트리거

| 상황 | 자동 실행 스킬 | 트리거 키워드 |
|------|---------------|--------------|
| 구현 시작 전 | `/confidence-check` | 구현, 만들어, implement |
| 기능 완료 후 | `/verify` | 완료, done, PR |
| 빌드 에러 | `/build-fix` | error TS, Build failed |
| React 리뷰 | `/react-best-practices` | .tsx + 리뷰 |
| Python 리뷰 | `/python-best-practices` | .py + 리뷰 |

### 전문 에이전트

| 에이전트 | 역할 |
|----------|------|
| `backend-architect` | 백엔드 시스템 설계 |
| `frontend-architect` | UI/UX 아키텍처 |
| `security-engineer` | 보안 취약점 분석 |
| `performance-engineer` | 성능 최적화 |
| `quality-engineer` | 테스트 전략 |
| `pm-agent` | 프로젝트/작업 관리 |
| `deep-research-agent` | 심층 리서치 |

## Commands Reference

### 아키텍처 & 설계

```
/architecture    # 시스템 아키텍처 분석/설계
/api-design      # API 설계 가이드
/db-design       # 데이터베이스 설계
/design-patterns # 디자인 패턴 적용
/clean-arch      # 클린 아키텍처
/hexagonal       # 헥사고날 아키텍처
/ddd             # 도메인 주도 설계
```

### 코드 품질

```
/clean-code      # 클린 코드 원칙
/code-review     # 코드 리뷰
/code-smell      # 코드 스멜 탐지
/refactoring     # 리팩토링 가이드
/solid           # SOLID 원칙
/naming          # 네이밍 컨벤션
```

### 테스팅 & 품질

```
/testing         # 테스트 전략
/security-audit  # 보안 감사
/perf-optimize   # 성능 최적화
/a11y            # 접근성 검사
```

### DevOps & 인프라

```
/docker          # Docker 설정
/cicd            # CI/CD 파이프라인
/monitoring      # 모니터링 설정
/env             # 환경 설정
```

### Serena MCP 커맨드 (/sc:*)

```
/sc:load         # 프로젝트 컨텍스트 로드
/sc:save         # 세션 저장
/sc:analyze      # 종합 코드 분석
/sc:implement    # 기능 구현
/sc:research     # 딥 리서치
/sc:git          # Git 워크플로우
```

## Skills

### 품질 보증

| 스킬 | 설명 |
|------|------|
| `/confidence-check` | 구현 전 신뢰도 평가 (≥90% 필요) |
| `/verify` | 완료 후 6단계 검증 |
| `/checkpoint` | 위험 작업 전 체크포인트 |

### 언어별 베스트 프랙티스

| 스킬 | 설명 |
|------|------|
| `/react-best-practices` | React/Next.js 40+ 규칙 |
| `/python-best-practices` | Python 코드 품질 |
| `/pytest-runner` | pytest 실행 및 분석 |
| `/poetry-package` | Poetry 패키지 관리 |

### 생산성

| 스킬 | 설명 |
|------|------|
| `/feature-planner` | 기능 구현 계획 |
| `/build-fix` | 빌드 에러 자동 수정 |
| `/learn` | 패턴 학습 및 저장 |
| `/note` | 컴팩션 대응 메모 |

## Configuration

### CLAUDE.md 커스터마이징

`core/CLAUDE.md`를 수정하여 프레임워크 동작을 조정할 수 있습니다:

```markdown
# 언어 설정
- **ALWAYS respond in Korean (한글)**  # 원하는 언어로 변경

# 자동 스킬 활성화/비활성화
| 구현 전 | `/confidence-check` | 구현, 만들어 |
```

### MCP 서버 설정

`core/MCP_SERVERS.md`에서 MCP 서버 우선순위와 사용 조건을 설정합니다.

## Requirements

- **Claude Code CLI** - [설치 가이드](https://docs.anthropic.com/en/docs/claude-code)
- **MCP Servers** (선택적)
  - Context7 - 공식 문서 조회
  - Sequential Thinking - 복잡한 분석
  - Magic (21st.dev) - UI 컴포넌트
  - Serena - 심볼 작업

## Credits & Inspirations

- [SuperClaude](https://github.com/supertools-ai/superclaude) - 원본 프레임워크
- [Claude Code](https://claude.ai/claude-code) - Anthropic의 공식 CLI

## License

MIT License - 자유롭게 사용, 수정, 배포할 수 있습니다.

---

**Note**: 이 프레임워크는 개인 사용을 위해 커스터마이징된 것입니다. 원하는 대로 수정하여 사용하세요.
