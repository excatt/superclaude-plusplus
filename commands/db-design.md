# Database Design Skill

스키마 설계 및 쿼리 최적화를 위한 가이드를 실행합니다.

## 스키마 설계 원칙

### 정규화 체크리스트
- [ ] 1NF: 원자값, 중복 컬럼 없음
- [ ] 2NF: 부분 함수 종속 제거
- [ ] 3NF: 이행 함수 종속 제거
- [ ] 적절한 비정규화 고려 (성능)

### 테이블 설계
- [ ] 명확한 Primary Key
- [ ] 적절한 Foreign Key 관계
- [ ] NOT NULL 제약조건 검토
- [ ] UNIQUE 제약조건 검토
- [ ] DEFAULT 값 설정
- [ ] CHECK 제약조건 (필요시)

### 인덱스 전략
- [ ] WHERE 절 컬럼 인덱스
- [ ] JOIN 컬럼 인덱스
- [ ] ORDER BY 컬럼 인덱스
- [ ] 복합 인덱스 순서 최적화
- [ ] 커버링 인덱스 고려
- [ ] 불필요한 인덱스 제거

### 데이터 타입 선택
```
# 권장 데이터 타입
ID:        BIGINT / UUID
금액:      DECIMAL(19,4)
날짜:      TIMESTAMP WITH TIME ZONE
문자열:    VARCHAR(n) - 적절한 길이
불리언:    BOOLEAN
JSON:      JSONB (PostgreSQL)
```

## 쿼리 최적화

### 성능 체크리스트
- [ ] SELECT * 대신 필요한 컬럼만
- [ ] N+1 쿼리 문제 해결
- [ ] 적절한 JOIN 사용
- [ ] 서브쿼리 vs JOIN 비교
- [ ] LIMIT/OFFSET 페이징 (큰 offset 주의)
- [ ] 인덱스 활용 확인 (EXPLAIN)

### 안티패턴 감지
```sql
-- 피해야 할 패턴
SELECT * FROM ...           -- 불필요한 컬럼
WHERE column LIKE '%value'  -- 인덱스 무효화
WHERE FUNCTION(column)      -- 인덱스 무효화
OR 조건 남발                 -- 인덱스 비효율
NOT IN (subquery)           -- NULL 문제
```

### EXPLAIN 분석 포인트
- Seq Scan vs Index Scan
- Nested Loop vs Hash Join
- Sort 연산 비용
- 예상 rows vs 실제 rows

## 출력 형식

```
## Database Design Review

### Schema Analysis
- 테이블 수: N
- 관계: [1:N, M:N 등]
- 정규화 수준: [1NF/2NF/3NF]

### Findings

#### Schema Issues
- [테이블명] 이슈 설명 및 권장사항

#### Index Recommendations
- [테이블명] 권장 인덱스: (col1, col2)
- 이유: WHERE/JOIN 패턴 분석

#### Query Optimization
- [쿼리 위치] 현재 비용 → 예상 개선
- 수정 방법: 구체적 쿼리 제안

### ERD (텍스트)
```
[User] 1──N [Order] N──M [Product]
```

### Migration Plan
1. [스키마 변경 단계]
2. [데이터 마이그레이션]
3. [인덱스 생성]
```

---

위 가이드를 기반으로 데이터베이스 설계를 분석하세요.
