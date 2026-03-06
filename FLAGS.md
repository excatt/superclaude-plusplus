# SuperClaude Framework Flags

행동 플래그 빠른 참조. 상세 모드 설명은 MODES.md 참조.

---

## Mode Activation

상세 내용은 MODES.md Mode Quick Reference 참조.

`--brainstorm` | `--introspect` | `--task-manage` | `--orchestrate` | `--token-efficient` (`--uc`) | `--harness`

---

## MCP Server Flags

상세 내용은 MCP_SERVERS.md 참조.

`--c7`/`--context7` Context7 | `--seq`/`--sequential` Sequential | `--magic` Magic | `--morph`/`--morphllm` Morphllm | `--serena` Serena | `--play`/`--playwright` Playwright | `--tavily` Tavily | `--all-mcp` All | `--no-mcp` None

---

## Analysis Depth

| Flag | Tokens | Triggers | Enables |
|------|--------|----------|---------|
| `--think` | ~4K | 중간 복잡도 | Sequential |
| `--think-hard` | ~10K | 아키텍처 분석 | Sequential + Context7 |
| `--ultrathink` | ~32K | 시스템 재설계 | 전체 MCP |

---

## Execution Control

| Flag | Description |
|------|-------------|
| `--delegate [auto\|files\|folders]` | 서브에이전트 병렬 처리 |
| `--concurrency [n]` | 최대 동시 작업 (1-15) |
| `--loop` | 반복 개선 사이클 |
| `--iterations [n]` | 개선 사이클 수 (1-10) |
| `--validate` | 실행 전 위험 평가 |
| `--safe-mode` | 최대 검증, 보수적 실행 |

---

## Output & Scope

| Flag | Description |
|------|-------------|
| `--uc`, `--ultracompressed` | 심볼 시스템, 토큰 감소 |
| `--scope [file\|module\|project\|system]` | 분석 범위 정의 |
| `--focus [performance\|security\|quality\|...]` | 특정 도메인 집중 |

---

## Proactive Suggestion

| Flag | Description |
|------|-------------|
| `--suggest-all` | 모든 관련 도구 적극 제안 (기본값) |
| `--suggest-minimal` | 핵심 도구만 제안 |
| `--suggest-off`, `--no-suggest` | 자동 제안 비활성화 |
| `--auto-agent` | 에이전트 자동 제안 활성화 |
| `--auto-mcp` | MCP 서버 자동 활성화 제안 |

---

## Model Selection

| Flag | 강점 | Use Case |
|------|------|----------|
| `--model haiku` | 빠른 응답, 경량 | 탐색, 간단한 질문, 단일 파일 |
| `--model sonnet` | 균형 (기본값) | 구현, 리뷰, 오케스트레이션 |
| `--model opus` | 최고 추론력 | 아키텍처, 딥 리서치 |

---

## Context Mode

상세 내용은 CONTEXTS.md 참조.

| Flag | Mode | Priority |
|------|------|----------|
| `--ctx dev` | 개발 | 작동 > 완벽, 코드 먼저 |
| `--ctx review` | 리뷰 | 심층 분석, 심각도별 정리 |
| `--ctx research` | 리서치 | 완전성 > 속도, 증거 기반 |

---

## Priority Rules

```
Safety: --safe-mode > --validate > optimization
Override: User flags > auto-detection
Depth: --ultrathink > --think-hard > --think
MCP: --no-mcp overrides individual flags
Scope: system > project > module > file
Model: --model flag > auto-selection
```
