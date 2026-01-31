---
name: gap-analysis
description: |
  설계 문서와 실제 구현 코드 간의 차이를 분석하는 스킬.
  PDCA Check 단계의 핵심으로, Match Rate를 계산하고 Gap 목록을 생성합니다.

  Use proactively when:
  - 구현 완료 후 설계 문서와 비교 필요
  - "설계대로야?", "맞아?", "확인해줘" 요청
  - PR/코드 리뷰 전 검증
  - PDCA Check 단계 실행

  Triggers: gap analysis, 갭 분석, 설계-구현 비교, 검증, 확인, 맞아?,
  설계대로야?, verify implementation, compare design, check implementation,
  design vs code, 설계 vs 구현

  Do NOT use for: 단순 코드 리뷰, 설계 문서 작성, 버그 수정
user-invocable: true
argument-hint: "[feature-name]"
---

# Gap Analysis Skill

> 설계 문서와 실제 구현 코드 간의 차이를 분석하여 Match Rate를 계산합니다.

## 사용법

```bash
/gap-analysis user-auth          # user-auth 기능 Gap 분석
/gap-analysis                    # 현재 PDCA 상태의 기능 분석
```

## 분석 워크플로우

### Step 1: 문서 및 코드 탐색

```
1. 설계 문서 찾기
   - docs/02-design/features/{feature}.design.md
   - docs/02-design/{feature}.design.md
   - docs/design/{feature}.md

2. 구현 코드 찾기
   - src/features/{feature}/
   - src/{feature}/
   - app/{feature}/
   - lib/{feature}/
```

### Step 2: 비교 항목

#### 2.1 API 비교
| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| 엔드포인트 URL | 설계 명세 | 실제 라우트 | ✅/❌ |
| HTTP 메서드 | GET/POST/PUT/DELETE | 실제 메서드 | ✅/❌ |
| 요청 파라미터 | 스키마 정의 | 실제 타입 | ✅/❌ |
| 응답 형식 | 설계 스키마 | 실제 응답 | ✅/❌ |
| 에러 코드 | 정의된 에러 | 실제 에러 | ✅/❌ |

#### 2.2 데이터 모델 비교
| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| 엔티티 목록 | 설계 ERD | 실제 모델 | ✅/❌ |
| 필드 정의 | 스키마 | 타입 정의 | ✅/❌ |
| 관계 정의 | 설계 관계 | 실제 관계 | ✅/❌ |

#### 2.3 기능 비교
| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| 기능 목록 | 요구사항 | 실제 함수 | ✅/❌ |
| 비즈니스 로직 | 설계 흐름 | 실제 로직 | ✅/❌ |
| 에러 핸들링 | 설계 케이스 | 실제 처리 | ✅/❌ |

#### 2.4 Convention 준수
| 항목 | 규칙 | 실제 | 상태 |
|------|------|------|------|
| 네이밍 | PascalCase/camelCase | 실제 네이밍 | ✅/❌ |
| 폴더 구조 | 설계 구조 | 실제 구조 | ✅/❌ |
| Import 순서 | 규칙 | 실제 순서 | ✅/❌ |

### Step 3: Match Rate 계산

```
Match Rate = (일치 항목 / 전체 비교 항목) × 100

상태 판정:
├─ >= 90%  → ✅ PASS (Report 단계로)
├─ 70-89%  → ⚠️ WARN (Act 단계 - 자동 수정)
└─ < 70%   → ❌ FAIL (설계 재검토 필요)
```

### Step 4: Gap 분류

```markdown
## Gap 분류

### 🔴 Missing (설계 O, 구현 X)
설계에 있지만 구현되지 않은 항목
→ 구현 필요

### 🟡 Added (설계 X, 구현 O)
설계에 없지만 구현된 항목
→ 설계 문서 업데이트 또는 코드 제거

### 🔵 Changed (설계 ≠ 구현)
설계와 구현이 다른 항목
→ 동기화 필요 (설계 또는 구현 수정)
```

## 출력 형식

```markdown
# Gap Analysis Report: {feature}

## 분석 개요
- **분석 대상**: {feature}
- **설계 문서**: docs/02-design/features/{feature}.design.md
- **구현 경로**: src/features/{feature}/
- **분석 일시**: YYYY-MM-DD HH:mm

## Match Rate

| 카테고리 | 점수 | 상태 |
|----------|:----:|:----:|
| API 일치율 | 85% | ⚠️ |
| 데이터 모델 | 100% | ✅ |
| 기능 구현 | 80% | ⚠️ |
| Convention | 90% | ✅ |
| **전체** | **88%** | ⚠️ |

## Gap 목록

### 🔴 Missing (구현 필요)
| 항목 | 설계 위치 | 설명 |
|------|----------|------|
| 비밀번호 찾기 | design.md:45 | POST /auth/forgot-password 미구현 |

### 🟡 Added (문서화 필요)
| 항목 | 구현 위치 | 설명 |
|------|----------|------|
| 소셜 로그인 | src/auth/social.ts | 설계에 없는 기능 추가됨 |

### 🔵 Changed (동기화 필요)
| 항목 | 설계 | 구현 | 영향도 |
|------|------|------|--------|
| 응답 형식 | { data: [] } | { items: [] } | High |

## 권장 조치

### 즉시 조치 (matchRate < 90%)
1. Missing 항목 구현 또는 설계에서 제거
2. Changed 항목 동기화

### 문서 업데이트
1. Added 항목을 설계 문서에 반영
```

## PDCA 상태 업데이트

분석 완료 시 `.pdca-status.json` 업데이트:

```json
{
  "feature": "{feature}",
  "phase": "check",
  "matchRate": 88,
  "gaps": {
    "missing": 1,
    "added": 1,
    "changed": 1
  },
  "lastAnalysis": "2025-01-31T10:00:00Z",
  "iteration": 0
}
```

## 다음 단계 안내

```
matchRate >= 90%:
  → "Gap 분석 통과! /pdca report {feature}로 완료 리포트를 생성하세요."

matchRate < 90%:
  → "Gap이 발견되었습니다. 자동 수정을 시작할까요? (Act 단계)"
  → 사용자 승인 시 Gap 기반 수정 진행
  → 수정 후 자동 re-analysis
```

## 관련 스킬

- `/feature-planner` - Plan 단계
- `/verify` - 일반 검증 (Gap Analysis는 설계-구현 비교에 특화)
- `/code-review` - 코드 품질 리뷰
