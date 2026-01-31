# {feature} Completion Report

> **Report Type**: PDCA Completion Report
>
> **Project**: {프로젝트명}
> **Author**: {작성자}
> **Date**: {YYYY-MM-DD}
> **Final Match Rate**: {N}%

---

## 1. Executive Summary

### 1.1 Feature Overview
{기능에 대한 간략한 설명}

### 1.2 Completion Status
| 항목 | 상태 |
|------|:----:|
| Plan 문서 | ✅ |
| Design 문서 | ✅ |
| 구현 완료 | ✅ |
| Gap Analysis | ✅ |
| Match Rate >= 90% | ✅ |

### 1.3 Key Achievements
- {주요 성과 1}
- {주요 성과 2}
- {주요 성과 3}

---

## 2. PDCA Cycle Summary

### 2.1 Plan Phase
- **문서**: [plan.md](../01-plan/features/{feature}.plan.md)
- **완료일**: {YYYY-MM-DD}
- **주요 내용**:
  - 요구사항 {N}개 정의
  - 마일스톤 {N}개 설정

### 2.2 Design Phase
- **문서**: [design.md](../02-design/features/{feature}.design.md)
- **완료일**: {YYYY-MM-DD}
- **주요 내용**:
  - API 엔드포인트 {N}개 설계
  - 데이터 모델 {N}개 정의
  - 컴포넌트 {N}개 설계

### 2.3 Do Phase
- **구현 경로**: `src/features/{feature}/`
- **완료일**: {YYYY-MM-DD}
- **주요 내용**:
  - 파일 {N}개 생성/수정
  - 테스트 커버리지 {N}%

### 2.4 Check Phase (Gap Analysis)
- **문서**: [analysis.md](../03-analysis/{feature}.analysis.md)
- **분석일**: {YYYY-MM-DD}
- **결과**:

| 카테고리 | 점수 |
|----------|:----:|
| API 일치율 | {N}% |
| 데이터 모델 | {N}% |
| 기능 구현 | {N}% |
| Convention | {N}% |
| **전체** | **{N}%** |

### 2.5 Act Phase (Iterations)
| 반복 | 수정 내용 | Match Rate |
|:----:|----------|:----------:|
| 1 | {수정 내용} | {N}% |
| 2 | {수정 내용} | {N}% |
| Final | - | **{N}%** |

---

## 3. Deliverables

### 3.1 Documentation
| 문서 | 경로 | 상태 |
|------|------|:----:|
| Plan | docs/01-plan/features/{feature}.plan.md | ✅ |
| Design | docs/02-design/features/{feature}.design.md | ✅ |
| Analysis | docs/03-analysis/{feature}.analysis.md | ✅ |
| Report | docs/04-report/{feature}.report.md | ✅ |

### 3.2 Source Code
| 파일 | 설명 | LOC |
|------|------|----:|
| src/features/{feature}/index.ts | 메인 엔트리 | {N} |
| src/features/{feature}/api/routes.ts | API 라우트 | {N} |
| src/features/{feature}/services/*.ts | 서비스 로직 | {N} |
| src/features/{feature}/components/*.tsx | UI 컴포넌트 | {N} |
| **Total** | | **{N}** |

### 3.3 Tests
| 테스트 유형 | 파일 수 | 테스트 수 | 통과율 |
|------------|--------:|----------:|-------:|
| Unit | {N} | {N} | 100% |
| Integration | {N} | {N} | 100% |
| E2E | {N} | {N} | 100% |

---

## 4. Technical Details

### 4.1 API Endpoints Implemented
| Method | Endpoint | Status |
|--------|----------|:------:|
| GET | /api/{feature} | ✅ |
| GET | /api/{feature}/:id | ✅ |
| POST | /api/{feature} | ✅ |
| PUT | /api/{feature}/:id | ✅ |
| DELETE | /api/{feature}/:id | ✅ |

### 4.2 Database Changes
- [ ] 마이그레이션 파일: `{migration_file}`
- [ ] 새 테이블: {테이블명}
- [ ] 새 인덱스: {인덱스명}

### 4.3 Dependencies Added
| 패키지 | 버전 | 용도 |
|--------|------|------|
| {package1} | ^{version} | {용도} |
| {package2} | ^{version} | {용도} |

---

## 5. Quality Metrics

### 5.1 Code Quality
| 메트릭 | 값 | 목표 | 상태 |
|--------|---:|-----:|:----:|
| Test Coverage | {N}% | 80% | ✅/❌ |
| Type Coverage | {N}% | 90% | ✅/❌ |
| Lint Errors | {N} | 0 | ✅/❌ |
| Complexity | {N} | <10 | ✅/❌ |

### 5.2 Performance
| 메트릭 | 값 | 목표 | 상태 |
|--------|---:|-----:|:----:|
| API Response Time | {N}ms | <200ms | ✅/❌ |
| Bundle Size Impact | +{N}KB | <50KB | ✅/❌ |

### 5.3 Security Checklist
- [x] 입력 검증 적용
- [x] SQL Injection 방지
- [x] XSS 방지
- [x] 인증/인가 적용
- [x] Rate Limiting 적용

---

## 6. Lessons Learned

### 6.1 What Went Well
- {잘된 점 1}
- {잘된 점 2}

### 6.2 What Could Be Improved
- {개선점 1}
- {개선점 2}

### 6.3 Action Items for Future
- [ ] {향후 액션 1}
- [ ] {향후 액션 2}

---

## 7. Sign-off

| 역할 | 담당자 | 승인일 | 서명 |
|------|--------|--------|:----:|
| Developer | {이름} | {YYYY-MM-DD} | ✅ |
| Reviewer | {이름} | {YYYY-MM-DD} | ✅ |
| Owner | {이름} | {YYYY-MM-DD} | ⏳ |

---

## Appendix

### A. Related Links
- PR: {PR 링크}
- Issue: {Issue 링크}
- Deployment: {배포 링크}

### B. Screenshots
{스크린샷이 필요한 경우 첨부}

---

## Changelog

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 1.0 | {YYYY-MM-DD} | 최종 리포트 | {작성자} |
