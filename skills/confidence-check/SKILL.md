---
name: confidence-check
description: 구현 전 신뢰도 평가 (≥90% 필요). 중복 확인, 아키텍처 준수, 공식 문서, OSS 참조, 근본 원인 파악을 검증합니다. Keywords: confidence, check, verify, before, implement, 신뢰도, 확인, 검증.
---

# Confidence Check Skill

## Purpose

잘못된 방향의 실행을 방지하기 위해 구현 **시작 전** 신뢰도를 평가합니다.

**요구사항**: 구현 진행을 위해 ≥90% 신뢰도 필요

**ROI**: 100-200 토큰의 신뢰도 체크 → 5,000-50,000 토큰의 잘못된 방향 작업 방지

## When to Use

구현 작업 시작 전 사용하여 다음을 확인:
- 중복 구현이 존재하지 않음
- 아키텍처 준수 확인됨
- 공식 문서 검토됨
- 작동하는 OSS 구현 찾음
- 근본 원인 적절히 파악됨

## Confidence Assessment Criteria

5가지 체크 기반으로 신뢰도 점수 (0.0 - 1.0) 계산:

### 1. 중복 구현 없음? (25%)

**체크**: 기존 기능에 대해 코드베이스 검색

```bash
# 유사 함수 검색
grep -r "function featureName" src/
grep -r "def feature_name" src/

# 관련 모듈 찾기
find src/ -name "*feature*"
```

✅ 중복 없으면 통과
❌ 유사 구현 있으면 실패

### 2. 아키텍처 준수? (25%)

**체크**: 기술 스택 정렬 확인

- `CLAUDE.md`, `package.json`, `requirements.txt` 읽기
- 기존 패턴 사용 확인
- 기존 솔루션 재발명 피하기

```bash
# 기술 스택 확인
cat package.json | grep -E "(supabase|prisma|firebase|next)"
```

✅ 기존 기술 스택 사용하면 통과 (예: Supabase, UV, pytest)
❌ 불필요하게 새 의존성 도입하면 실패

### 3. 공식 문서 확인? (20%)

**체크**: 구현 전 공식 문서 검토

- Context7 MCP로 공식 문서 조회
- WebFetch로 문서 URL 접근
- API 호환성 확인

✅ 공식 문서 검토되면 통과
❌ 가정에 의존하면 실패

### 4. 작동하는 OSS 구현 참조? (15%)

**체크**: 검증된 구현 찾기

- Tavily MCP 또는 WebSearch 사용
- GitHub에서 예시 검색
- 작동하는 코드 샘플 확인

✅ OSS 참조 찾으면 통과
❌ 작동하는 예시 없으면 실패

### 5. 근본 원인 파악? (15%)

**체크**: 실제 문제 이해

- 에러 메시지 분석
- 로그 및 스택 트레이스 확인
- 근본 이슈 식별

✅ 근본 원인 명확하면 통과
❌ 증상 불명확하면 실패

---

## Confidence Score Calculation

```
Total = Check1 (25%) + Check2 (25%) + Check3 (20%) + Check4 (15%) + Check5 (15%)

If Total >= 0.90:  ✅ 구현 진행
If Total >= 0.70:  ⚠️  대안 제시, 질문
If Total < 0.70:   ❌ STOP - 더 많은 컨텍스트 요청
```

---

## Output Format

### High Confidence (≥90%)
```
📋 Confidence Checks:
   ✅ 중복 구현 없음
   ✅ 기존 기술 스택 사용
   ✅ 공식 문서 확인됨
   ✅ 작동하는 OSS 구현 찾음
   ✅ 근본 원인 파악됨

📊 Confidence: 1.00 (100%)
✅ High confidence - 구현 진행
```

### Medium Confidence (70-89%)
```
📋 Confidence Checks:
   ✅ 중복 구현 없음
   ✅ 기존 기술 스택 사용
   ⚠️  공식 문서 부분 확인
   ❌ OSS 구현 못 찾음
   ✅ 근본 원인 파악됨

📊 Confidence: 0.75 (75%)
⚠️  Medium confidence - 대안 제시

💡 선택지:
1. JWT 기반 인증 (권장) - 기존 패턴과 일치
2. OAuth 통합 - 추가 설정 필요
3. 세션 기반 - 레거시 접근법

어떤 방향으로 진행할까요?
```

### Low Confidence (<70%)
```
📋 Confidence Checks:
   ❌ 중복 확인 실패 - 검색 필요
   ⚠️  아키텍처 불명확
   ❌ 공식 문서 미확인
   ❌ OSS 참조 없음
   ❌ 근본 원인 불명확

📊 Confidence: 0.45 (45%)
❌ Low confidence - STOP

❓ 진행하려면 다음 정보가 필요합니다:
1. 인증에 JWT를 사용해야 하나요, OAuth를 사용해야 하나요?
2. 예상 세션 타임아웃은 얼마인가요?
3. 2FA 지원이 필요한가요?

확신을 가지고 진행할 수 있도록 안내해 주세요.
```

---

## Workflow Integration

### Before Any Implementation
```
사용자 요청 수신
    │
    ▼
┌─────────────────────┐
│  /confidence-check  │
└─────────────────────┘
    │
    ├─→ ≥90%: 구현 진행
    │
    ├─→ 70-89%: 대안 제시 → 사용자 선택 → 진행
    │
    └─→ <70%: STOP → 질문 → 답변 대기 → 재평가
```

### With /feature-planner
```
/confidence-check        # 먼저 신뢰도 확인
    │
    └─→ ≥90%
          │
          ▼
/feature-planner        # 계획 수립
    │
    ▼
구현 진행
```

### With /verify
```
/confidence-check       # 구현 전 신뢰도
    │
    ▼
구현 작업
    │
    ▼
/verify                 # 구현 후 검증
```

---

## Check Implementation Details

### Check 1: Duplicate Search
```bash
# 함수명으로 검색
grep -rn "function ${feature_name}" src/
grep -rn "def ${feature_name}" src/
grep -rn "const ${feature_name}" src/

# 파일명으로 검색
find . -name "*${feature}*" -type f

# 클래스명으로 검색
grep -rn "class ${FeatureName}" src/
```

### Check 2: Architecture Verification
```bash
# package.json 기술 스택 확인
cat package.json | jq '.dependencies'

# CLAUDE.md 아키텍처 가이드 확인
cat CLAUDE.md | grep -A 10 "Architecture"

# 기존 패턴 확인
ls -la src/
```

### Check 3: Documentation Review
```bash
# Context7 MCP로 공식 문서 조회
# WebFetch로 문서 URL 접근
# README 및 내부 문서 확인
```

### Check 4: OSS Reference Search
```bash
# GitHub 검색
# Tavily/WebSearch로 구현 예시 검색
# npm/pip 패키지 확인
```

### Check 5: Root Cause Analysis
```bash
# 에러 로그 분석
# 스택 트레이스 검토
# 재현 단계 확인
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/confidence-check` | 전체 신뢰도 평가 |
| `/confidence-check --quick` | 빠른 체크 (1, 2번만) |
| `/confidence-check --verbose` | 각 체크 상세 출력 |

---

## Best Practices

### 항상 사용해야 할 때
- 새 기능 구현 전
- 버그 수정 전 (근본 원인 파악)
- 리팩토링 전 (아키텍처 확인)
- 외부 API 통합 전

### 스킵 가능한 때
- 오타 수정
- 주석 추가
- 포맷팅 변경
- 단순 설정 변경

### Red Flags
신뢰도가 낮은데 진행하고 싶은 유혹이 있다면:
- 🚩 "아마 괜찮을 것 같아" - 확인 필요
- 🚩 "시간이 없어" - 잘못된 방향이 더 많은 시간 소비
- 🚩 "나중에 고치면 돼" - 기술 부채 누적
