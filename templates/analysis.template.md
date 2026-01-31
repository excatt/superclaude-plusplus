# {feature} Gap Analysis Report

> **Analysis Type**: Gap Analysis (Design vs Implementation)
>
> **Project**: {프로젝트명}
> **Analyst**: {분석자}
> **Date**: {YYYY-MM-DD}
> **Design Doc**: [design.md](../02-design/features/{feature}.design.md)

---

## 1. Analysis Overview

### 1.1 Analysis Purpose
{이 분석의 목적}

### 1.2 Analysis Scope
- **설계 문서**: `docs/02-design/features/{feature}.design.md`
- **구현 경로**: `src/features/{feature}/`
- **분석 일시**: {YYYY-MM-DD HH:mm}

---

## 2. Match Rate Summary

| 카테고리 | 점수 | 상태 |
|----------|:----:|:----:|
| API 일치율 | {N}% | ✅/⚠️/❌ |
| 데이터 모델 | {N}% | ✅/⚠️/❌ |
| 기능 구현 | {N}% | ✅/⚠️/❌ |
| Convention | {N}% | ✅/⚠️/❌ |
| **전체** | **{N}%** | ✅/⚠️/❌ |

```
판정 기준:
✅ >= 90%  : PASS (Report 단계로 진행)
⚠️ 70-89% : WARN (Act 단계 - 수정 필요)
❌ < 70%  : FAIL (설계 재검토 필요)
```

---

## 3. Gap Analysis Detail

### 3.1 API Endpoints

| 설계 | 구현 | 상태 | 비고 |
|------|------|:----:|------|
| GET /api/{feature} | GET /api/{feature} | ✅ | |
| POST /api/{feature} | POST /api/{feature} | ✅ | |
| PUT /api/{feature}/:id | PUT /api/{feature}/:id | ✅ | |
| DELETE /api/{feature}/:id | - | ❌ | 미구현 |

### 3.2 Data Model

| 필드 | 설계 타입 | 구현 타입 | 상태 |
|------|----------|----------|:----:|
| id | string | string | ✅ |
| name | string | string | ✅ |
| createdAt | Date | Date | ✅ |
| metadata | - | object | ⚠️ |

### 3.3 Components

| 설계 컴포넌트 | 구현 파일 | 상태 |
|--------------|----------|:----:|
| {Feature}Form | src/components/{Feature}Form.tsx | ✅ |
| {Feature}List | src/components/{Feature}List.tsx | ✅ |
| {Feature}Detail | - | ❌ |

### 3.4 Convention Compliance

| 항목 | 규칙 | 실제 | 상태 |
|------|------|------|:----:|
| 컴포넌트 네이밍 | PascalCase | PascalCase | ✅ |
| 함수 네이밍 | camelCase | camelCase | ✅ |
| 파일 구조 | feature-based | feature-based | ✅ |
| Import 순서 | 외부→내부→상대 | 혼재 | ⚠️ |

---

## 4. Gap Classification

### 🔴 Missing (설계 O, 구현 X)
> 설계에 있지만 구현되지 않은 항목 → **구현 필요**

| 항목 | 설계 위치 | 설명 | 우선순위 |
|------|----------|------|----------|
| {항목1} | design.md:L45 | {설명} | High |
| {항목2} | design.md:L78 | {설명} | Medium |

### 🟡 Added (설계 X, 구현 O)
> 설계에 없지만 구현된 항목 → **문서화 필요 또는 제거**

| 항목 | 구현 위치 | 설명 | 조치 |
|------|----------|------|------|
| {항목1} | src/{file}.ts:L23 | {설명} | 문서화 |
| {항목2} | src/{file}.ts:L56 | {설명} | 검토 필요 |

### 🔵 Changed (설계 ≠ 구현)
> 설계와 구현이 다른 항목 → **동기화 필요**

| 항목 | 설계 | 구현 | 영향도 | 권장 조치 |
|------|------|------|--------|----------|
| {항목1} | {설계값} | {구현값} | High | 구현 수정 |
| {항목2} | {설계값} | {구현값} | Low | 설계 업데이트 |

---

## 5. Recommended Actions

### 5.1 Immediate Actions (matchRate < 90%)
1. [ ] {즉시 조치 1}
2. [ ] {즉시 조치 2}
3. [ ] {즉시 조치 3}

### 5.2 Documentation Updates
1. [ ] {문서 업데이트 1}
2. [ ] {문서 업데이트 2}

### 5.3 Future Considerations
- {향후 고려사항 1}
- {향후 고려사항 2}

---

## 6. Next Steps

```
현재 Match Rate: {N}%

[ ] matchRate >= 90% → /pdca report {feature}로 완료 리포트 생성
[ ] matchRate < 90%  → Act 단계 진행 (Gap 수정 후 재분석)
```

---

## 7. Analysis Evidence

### 7.1 Analyzed Files
```
설계 문서:
- docs/02-design/features/{feature}.design.md

구현 파일:
- src/features/{feature}/index.ts
- src/features/{feature}/api/routes.ts
- src/features/{feature}/services/{feature}.service.ts
- src/features/{feature}/components/{Feature}Form.tsx
- src/features/{feature}/types/{feature}.types.ts
```

### 7.2 Test Results
```
테스트 실행 결과 (있는 경우 첨부)
```

---

## Changelog

| 버전 | 날짜 | 변경 내용 | 분석자 |
|------|------|----------|--------|
| 0.1 | {YYYY-MM-DD} | 초기 분석 | {분석자} |
