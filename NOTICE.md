# Third-Party Notices

SuperClaude++ (MIT License)는 다음 오픈소스 구성요소를 통합합니다. 각 구성요소의 원본 라이선스와 저작권 표시는 아래에 보존되어 있으며, Apache License 2.0 §4에 따라 라이선스 전문과 NOTICE 파일을 함께 배포합니다.

---

## Impeccable Design Language

- **출처 (upstream)**: https://github.com/pbakaus/impeccable
- **버전**: v2.1.1
- **라이선스**: Apache License 2.0 — 전문은 [`skills/impeccable/LICENSE`](skills/impeccable/LICENSE) 참조
- **NOTICE**: [`skills/impeccable/NOTICE.md`](skills/impeccable/NOTICE.md) (원본 verbatim 보존)
- **저작권**: Copyright 2025-2026 Paul Bakaus

### 통합 범위 (18개 skill)
`skills/impeccable/`, `skills/shape/`, `skills/layout/`, `skills/typeset/`, `skills/colorize/`, `skills/animate/`, `skills/delight/`, `skills/polish/`, `skills/critique/`, `skills/design-audit/`, `skills/harden/`, `skills/optimize/`, `skills/clarify/`, `skills/distill/`, `skills/quieter/`, `skills/bolder/`, `skills/adapt/`, `skills/overdrive/`

### SuperClaude++ 통합 시 수정사항 (Apache 2.0 §4(b) 고지)
상세 변경 내역은 각 skill의 `SKILL.md` frontmatter `modifications` 필드에 기록되어 있음.

| 파일 | 변경 |
|------|------|
| `skills/design-audit/` | 원본 이름 `audit`에서 리네이밍 — SuperClaude++의 기존 `/audit` (프로젝트 룰 검증) 네임스페이스와 충돌 회피 |
| `skills/design-audit/SKILL.md`, `skills/critique/SKILL.md` | 내부 `/audit` 커맨드 참조를 `/design-audit`로 일괄 치환 |
| `skills/impeccable/SKILL.md` | `<post-update-cleanup>` 블록 제거 (신규 설치 시 불필요한 마이그레이션 지시) |

### 상위 계보 (Apache 2.0 §4(c) 귀속 보존)
Impeccable은 Anthropic의 frontend-design skill에서 파생되었으며, 해당 귀속은 [`skills/impeccable/NOTICE.md`](skills/impeccable/NOTICE.md)에 보존되어 있음:
- **원본**: https://github.com/anthropics/skills/tree/main/skills/frontend-design
- **저작권**: Copyright 2025 Anthropic, PBC
- **라이선스**: Apache License 2.0

---

## grill-with-docs (Domain Modeling Skill)

- **출처 (upstream)**: https://github.com/mattpocock/skills
- **원본 경로**: `skills/engineering/grill-with-docs/` (그리고 `skills/productivity/grill-me/`의 행동 규칙 일부)
- **라이선스**: MIT License — 전문은 [`skills/grill-with-docs/LICENSE`](skills/grill-with-docs/LICENSE) 참조
- **저작권**: Copyright (c) 2026 Matt Pocock
- **통합 시점**: 2026-05-20 (SuperClaude++ v2.3.0)

### 통합 범위 (1개 skill + 부속 문서)
- `skills/grill-with-docs/SKILL.md` — 본 스킬
- `skills/grill-with-docs/CONTEXT-FORMAT.md` — 도메인 어휘 사전 형식 가이드
- `skills/grill-with-docs/ADR-FORMAT.md` — 아키텍처 의사결정 기록 형식 가이드
- `skills/grill-with-docs/LICENSE` — 원본 MIT 라이선스 전문

### SuperClaude++ 통합 시 수정사항
| 파일 | 변경 |
|------|------|
| `skills/grill-with-docs/SKILL.md` | SuperClaude++ frontmatter 컨벤션 적용 (`user-invocable: true`, `argument-hint`). 한국어 사용자 가이드 보강. `/brainstorm`과의 역할 분리 명시. |
| `skills/brainstorm/SKILL.md` | 원본 `grill-me`의 3대 행동 규칙 흡수: (1) 한 번에 한 질문 (2) 추천답 동반 제시 (3) 코드베이스로 답할 수 있으면 코드부터 탐색. 다중 페르소나 코디네이션은 그대로 유지. |
| 루트 `CONTEXT.md` 신규 | SuperClaude++ 자체 도메인 어휘 사전 (skill, agent, harness, /goal 등). `/grill-with-docs` 사용 시 stress-test 기준점. |

### 결합한 두 원본 스킬의 관계
- `grill-me` (`skills/productivity/grill-me/`) — 기본 인터뷰 행동 규칙. SuperClaude++에서는 별도 스킬을 만들지 않고 `/brainstorm`에 행동 규칙만 흡수함 (중복 방지).
- `grill-with-docs` (`skills/engineering/grill-with-docs/`) — `grill-me` 위에 도메인 어휘 사전(CONTEXT.md)과 ADR 인라인 갱신을 추가한 확장판. SuperClaude++에서는 `/grill-with-docs`로 그대로 포팅.

---

## Ponytail (개념 차용 — 코드 미포함)

- **출처 (upstream)**: https://github.com/DietrichGebert/ponytail
- **라이선스**: MIT License
- **통합 시점**: 2026-08-11 (SuperClaude++ v3.1.0)
- **통합 형태**: **개념 차용만**. 원본의 파일(`skills/`, `hooks/`, `commands/`)은 **하나도 복제하지 않았음**. MIT의 고지 의무는 "substantial portions of the Software" 복제 시 발생하므로 본 항목은 법적 의무가 아니라 SuperClaude++의 출처 추적 관례에 따른 기록임.

### 차용한 것 (2건)

| 차용 | 반영 위치 | 원본과의 차이 |
|------|-----------|---------------|
| **Decision Ladder의 순서화된 조기 종료 구조**, 특히 rung 0("존재할 필요가 있는가")과 "래더는 문제를 *이해한 후에* 돈다"는 단서 | `PRINCIPLES.md` — 기존 gstack 유래 Search Before Building을 **Build Ladder** 8단(rung 0–7) 표로 재작성 | 원본 7단을 SC++의 기존 Layer 1/2/3와 병합해 8단으로 확장. 원본의 "one line → one line" rung은 **의도적으로 제외**. v3.0 상시 로드 감량 기조에 맞춰 표만 상주시키고 적용 규칙 3종은 `optional/`로 분리 |
| **과설계 함정 사례** (네이티브 플랫폼 기능이 존재하는데 컴포넌트 의존성을 끌어오는 패턴) | `optional/OVERENGINEERING_TRAPS.md` 신규 | 원본 벤치마크에서 실측된 2건(date picker 404→23줄, color picker 287→23줄)만 인용하고, 나머지 항목은 SC++가 같은 종류의 함정으로 일반화한 것. 측정 한계를 문서 내에 명시 |

### 차용하지 않은 것과 그 이유

| 원본 구성요소 | 제외 사유 |
|---------------|-----------|
| `hooks/` 전체 (11개 파일: `ponytail-instructions.js`, `ponytail-activate.js`, `ponytail-mode-tracker.js`, `ponytail-subagent.js`, statusline 등) | SC++의 기존 `UserPromptSubmit` 훅(`scripts/skill-matcher.py`) 및 `circuit-breaker.sh`와 실행 순서 충돌. 매 프롬프트 주입은 v3.0의 상시 로드 감량 기조와 정면 배치 |
| 항시 활성 주입 (*"Active by default; only 'stop ponytail' disables it"*) | 원본 이슈 #245가 보고한 misplaced laziness(증상 패치 편향)가 root-cause-first 디버깅과 충돌. root-cause-first는 v3.0 `RULES.md` 서두가 밝힌 **하네스 보장 항목**이라 규칙으로 재진술하지 않는 대신, Build Ladder에 **"디버깅에는 적용하지 않음"** scope limit을 두는 것으로 대체 |
| `ponytail:` 부채 마커 + `/ponytail-debt` 원장 | 상환 강제 장치가 없다. 읽지 않는 원장은 접두어만 바뀐 TODO다. (v2.x의 "No TODO in core functionality" 규칙은 v3.0에서 모델 기본값과 중복되어 삭제됐으므로 직접적 규칙 충돌은 해소됐으나, 채택 근거도 함께 사라졌다) |
| lite / full / ultra 강도 레벨 | SC++의 난이도 분기(Simple/Medium/Complex)와 `--uc` 플래그가 같은 축을 이미 담당 |
| `/ponytail-review`, `/ponytail-audit`, `/ponytail-gain` 등 6개 스킬 | `/distill`, `/audit`, `codebase-gc`와 기능 중복. v3.0이 스킬을 139→60으로 감축한 직후에 6개를 되돌리는 것은 방향 역행이며, 스킬 수 증가는 `skill-matcher.py` 오발화 확률을 높임 |

### 인용 시 필수 동반 캐비엇
원본 README의 "54% less code / 20% cheaper / 27% faster"는 **저자 자체 벤치마크(Haiku 4.5 단일 모델, 태스크당 n=4, 표준편차·신뢰구간 미보고)** 수치이며, 12개 태스크 중 2개(date/color picker)가 평균을 지배한다. 백엔드 태스크는 전 arm 수렴(이득 없음). 저자 본인도 *"Bigger models may close the over-build gap ... or widen it"* 이라고 유보했다. SC++ 문서에서 이 수치를 근거로 사용하지 말 것 — 상세는 `optional/OVERENGINEERING_TRAPS.md` "근거와 한계" 절.

---

## 기타 선재 통합 구성요소

본 NOTICE는 Impeccable 통합 시점(2026-04-17)에 추가되었습니다. `skills/` 내 다른 외부 유래 skill (예: `frontend-design`, `ui-ux-pro-max`, `brand-guidelines`, `algorithmic-art`, `canvas-design`, `slack-gif-creator`, `artifacts-builder`, `pptx`, `xlsx`, `pdf`, `webapp-testing`, `agent-browser`, `mcp-builder`, `skill-creator`, `theme-factory`, `internal-comms` 등)의 출처·라이선스는 각 skill 디렉터리 내 `LICENSE`/`SKILL.md`에 기록되어 있으며, 추후 본 파일에 순차적으로 통합 예정.

---

## Apache License 2.0

전문: https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
