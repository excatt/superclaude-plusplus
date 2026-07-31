# Project Context - superclaude-plusplus

## 핵심 정보 (항상 로드)
- **기술 스택**: Markdown documentation framework for Claude Code
- **아키텍처**: Plugin-based distribution (60 skills, 9 agents, 16 hook types)
- **컨벤션**: Korean responses, English code, pnpm/uv required

## 진행 중인 작업
- (새 작업 추가 시 여기에 기록)

## 의사결정 히스토리
| 날짜 | 결정 | 이유 |
|------|------|------|
| 2026-02-06 | Proactive Suggestion Rule 추가 | 스킬/에이전트 활용률 향상 |
| 2026-02-06 | Session Chaining Rule 추가 | 세션 간 컨텍스트 연속성 보장 |
| 2026-04-08 | v2.0 마이그레이션 | commands/ 삭제, 120 skills + 23 agents 플러그인 기반 배포 구조로 전환. prompt-dependent → system-enforced 패러다임 전환 |
| 2026-07-31 | v3.0 harness-aware slim | 하네스/모델 내재화 행동과 중복 제거. 상시 로드 -66%, 스킬 139→60, 에이전트 23→9. "모델이 못 하는 것만 남긴다" |

## 알려진 이슈
- (이슈 발견 시 여기에 기록)

## 세션 히스토리
- 2026-02-06: v0.7.0 릴리스 (Proactive Suggestion + Session Chaining)
- 2026-04-08: v2.0.0 릴리스 (System-Enforced Framework)
- 2026-07-31: v3.0.0 릴리스 (Harness-Aware Slim)

---
Last updated: 2026-07-31
