# Performance Optimization Skill

성능 분석 및 최적화를 위한 체계적 가이드를 실행합니다.

## 성능 분석 프레임워크

### 1. 측정 우선 (Measure First)
```
"추측하지 말고 측정하라"

측정 도구:
- 프로파일러 (cProfile, py-spy, Chrome DevTools)
- APM (Application Performance Monitoring)
- 로그 기반 분석
- 벤치마크 테스트
```

### 2. 병목 식별
```
성능 병목 위치:
├── CPU Bound
│   ├── 알고리즘 복잡도
│   ├── 반복 연산
│   └── 직렬화/역직렬화
├── I/O Bound
│   ├── 데이터베이스 쿼리
│   ├── 네트워크 호출
│   ├── 파일 시스템
│   └── 외부 API
└── Memory Bound
    ├── 메모리 누수
    ├── 큰 객체 복사
    └── 캐시 미스
```

## 최적화 체크리스트

### 알고리즘 & 데이터 구조
- [ ] 시간 복잡도 분석 (O notation)
- [ ] 적절한 자료구조 선택
- [ ] 불필요한 반복 제거
- [ ] 조기 종료 (early return)

### 데이터베이스
- [ ] 쿼리 실행 계획 분석 (EXPLAIN)
- [ ] N+1 문제 해결
- [ ] 적절한 인덱스
- [ ] 쿼리 캐싱
- [ ] Connection pooling
- [ ] 배치 처리

### 캐싱 전략
```
캐싱 계층:
L1: 메모리 캐시 (ms)
L2: Redis/Memcached (10ms)
L3: CDN (50ms)
L4: 데이터베이스 (100ms+)

캐시 무효화:
- TTL 기반
- 이벤트 기반
- Write-through
- Write-behind
```

### 비동기 & 병렬 처리
- [ ] 블로킹 I/O → 비동기
- [ ] 독립 작업 병렬화
- [ ] 백그라운드 작업 분리
- [ ] 메시지 큐 활용

### 프론트엔드
- [ ] 번들 크기 최적화
- [ ] 코드 스플리팅
- [ ] 이미지 최적화
- [ ] 레이지 로딩
- [ ] 렌더링 최적화
- [ ] Web Vitals (LCP, FID, CLS)

### 네트워크
- [ ] 요청 수 최소화
- [ ] 압축 (gzip, brotli)
- [ ] HTTP/2 활용
- [ ] Connection keep-alive
- [ ] DNS prefetch

## 성능 지표

### 백엔드
```
응답 시간 (p50, p95, p99)
처리량 (RPS)
에러율
CPU/메모리 사용률
```

### 프론트엔드
```
LCP (Largest Contentful Paint): < 2.5s
FID (First Input Delay): < 100ms
CLS (Cumulative Layout Shift): < 0.1
TTI (Time to Interactive): < 3.8s
```

## 출력 형식

```
## Performance Analysis Report

### Executive Summary
- 현재 상태: [Good/Needs Improvement/Critical]
- 주요 병목: [식별된 병목]
- 예상 개선: [X% 성능 향상 가능]

### Profiling Results
| 구간 | 현재 | 목표 | 상태 |
|------|------|------|------|
| API 응답 | 500ms | 200ms | ❌ |
| DB 쿼리 | 300ms | 50ms | ❌ |

### Bottleneck Analysis

#### [병목 1] 설명
- 위치: 파일:라인
- 영향: 전체 응답 시간의 60%
- 원인: N+1 쿼리
- 해결: Eager loading 적용

### Optimization Plan
1. [즉시] 퀵윈 최적화
2. [단기] 캐싱 도입
3. [중기] 아키텍처 개선

### Before/After Comparison
```
Before: 500ms (p95)
After:  150ms (p95) - 예상
개선:   70% 성능 향상
```
```

---

위 가이드를 기반으로 성능 분석 및 최적화 방안을 제시하세요.
