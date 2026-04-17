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

## 기타 선재 통합 구성요소

본 NOTICE는 Impeccable 통합 시점(2026-04-17)에 추가되었습니다. `skills/` 내 다른 외부 유래 skill (예: `frontend-design`, `ui-ux-pro-max`, `brand-guidelines`, `algorithmic-art`, `canvas-design`, `slack-gif-creator`, `artifacts-builder`, `pptx`, `xlsx`, `pdf`, `webapp-testing`, `agent-browser`, `mcp-builder`, `skill-creator`, `theme-factory`, `internal-comms` 등)의 출처·라이선스는 각 skill 디렉터리 내 `LICENSE`/`SKILL.md`에 기록되어 있으며, 추후 본 파일에 순차적으로 통합 예정.

---

## Apache License 2.0

전문: https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
