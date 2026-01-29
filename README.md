# My Claude Config

Claude Code를 위한 생산성 향상 설정 모음입니다.

## Features

### 🎯 Core Framework
- **CLAUDE.md** - 엔트리 포인트 및 언어 설정 (한국어)
- **FLAGS.md** - 행동 플래그 시스템 (`--think`, `--ultrathink`, `--uc` 등)
- **RULES.md** - 개발 규칙 및 자동화 트리거
- **PRINCIPLES.md** - 소프트웨어 엔지니어링 원칙
- **MODES.md** - 상황별 행동 모드 (Brainstorming, Orchestration 등)
- **MCP_SERVERS.md** - MCP 서버 통합 가이드

### 🔧 Automation Hooks
| Hook | 기능 |
|------|------|
| **todo-continuation** | TODO 미완료 시 작업 중단 방지 |
| **pre-compact-note** | 컴팩션 전 자동 노트 저장 요청 |
| **suggest-compact** | 컨텍스트 임계치 도달 시 컴팩션 제안 |
| **evaluate-session** | 세션 종료 시 패턴 추출 제안 |
| **type-check** | 파일 수정 후 타입 체크 |
| **auto-format** | 파일 수정 후 자동 포맷팅 |

### 📚 Skills
| Skill | 설명 |
|-------|------|
| `/note` | 컴팩션에서 살아남는 영구 메모 시스템 |
| `/learn` | 세션에서 재사용 가능한 패턴 추출 |
| `/confidence-check` | 구현 전 신뢰도 평가 |
| `/verify` | 완료 후 검증 체크리스트 |
| `/checkpoint` | 위험 작업 전 복원 지점 생성 |
| `/build-fix` | 빌드 에러 자동 수정 |
| `/feature-planner` | 기능 구현 계획 수립 |
| `/react-best-practices` | React 코드 리뷰 |
| `/python-best-practices` | Python 코드 리뷰 |
| `/pytest-runner` | pytest 실행 및 분석 |
| `/poetry-package` | Poetry 패키지 관리 |

### 📊 HUD StatusLine
실시간 상태 표시:
- 컨텍스트 사용량 (🟢/🟡/🔴)
- TODO 진행률
- 세션 정보
- 토큰 사용량

## Installation

### Quick Install (추천)
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/my-claude-config/main/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/YOUR_USERNAME/my-claude-config.git
cd my-claude-config
./install.sh
```

### 설치 후
1. **Claude Code 재시작** - 변경 사항 적용
2. `/note --show` - 노트 시스템 확인
3. 기존 `settings.json`이 있었다면 hooks 설정 병합 필요

## Directory Structure

```
~/.claude/
├── CLAUDE.md           # 메인 설정
├── FLAGS.md            # 플래그 참조
├── RULES.md            # 규칙 정의
├── PRINCIPLES.md       # 원칙
├── MODES.md            # 모드 정의
├── MCP_SERVERS.md      # MCP 서버 참조
├── notepad.md          # 영구 메모
├── settings.json       # hooks, statusLine 설정
├── scripts/            # hook 스크립트
│   ├── todo-continuation.sh
│   ├── pre-compact-note.sh
│   ├── suggest-compact.sh
│   └── ...
├── skills/             # 스킬 정의
│   ├── note/
│   ├── learn/
│   └── ...
└── state/              # 런타임 상태
```

## Key Concepts

### Persistence Enforcement
TODO 항목이 남아있으면 작업 중단을 방지합니다.
- 최대 10회 반복 후 자동 해제 (무한 루프 방지)
- `.claude/state/`에 진행 상황 저장

### Note System
세션 컴팩션에서 중요 정보를 보존합니다.
```bash
/note <content>           # Working Memory (7일 후 정리)
/note --priority <content> # Priority Context (항상 로드, 500자)
/note --manual <content>   # MANUAL (영구 저장)
```

### Auto-Skill Invocation
특정 상황에서 자동으로 스킬이 실행됩니다:
| 상황 | 스킬 |
|------|------|
| 구현 시작 전 | `/confidence-check` |
| 기능 완료 후 | `/verify` |
| 빌드 에러 | `/build-fix` |
| React 리뷰 | `/react-best-practices` |
| Python 리뷰 | `/python-best-practices` |

## Configuration

### Language
기본값: 한국어

`settings.json`에서 변경:
```json
{
  "language": "English"
}
```

### Hooks Customization
`settings.json`의 `hooks` 섹션에서 스크립트 추가/제거 가능.

### StatusLine
`statusline.sh`를 수정하여 표시 항목 커스터마이즈.

## Updating

```bash
cd my-claude-config
git pull
./install.sh
```

## Uninstall

```bash
# 설정 파일만 제거 (스킬, 스크립트 유지)
rm ~/.claude/CLAUDE.md ~/.claude/FLAGS.md ~/.claude/RULES.md \
   ~/.claude/PRINCIPLES.md ~/.claude/MODES.md ~/.claude/MCP_SERVERS.md

# 전체 제거
rm -rf ~/.claude/scripts ~/.claude/skills ~/.claude/state
```

## Requirements

- [Claude Code](https://docs.anthropic.com/claude-code) CLI
- Claude Max/Pro 구독 또는 Anthropic API 키
- macOS/Linux (Windows는 WSL 권장)
- `jq` (선택사항, 일부 스크립트에서 사용)

## Credits

- Inspired by [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [cc-statusline](https://www.npmjs.com/package/@chongdashu/cc-statusline)

## License

MIT
