# Debug Skill

체계적 디버깅을 위한 구조화된 접근법을 실행합니다.

## 디버깅 프레임워크

### 1단계: 문제 정의
```
질문:
- 예상 동작은?
- 실제 동작은?
- 언제부터 발생?
- 재현 가능한가?
- 재현 조건은?
```

### 2단계: 정보 수집
```
수집 대상:
├── 에러 메시지 (전체)
├── 스택 트레이스
├── 로그 (시간순)
├── 입력 데이터
├── 환경 정보
│   ├── OS / 브라우저
│   ├── 버전 정보
│   └── 환경변수
└── 최근 변경사항
```

### 3단계: 가설 수립
```
가설 우선순위:
1. 가장 최근 변경된 코드
2. 가장 단순한 원인
3. 과거 유사 버그
4. 외부 의존성
```

### 4단계: 격리 및 검증
```
기법:
- 이진 탐색 (bisect)
- 최소 재현 케이스
- 변수 하나씩 제거
- 로그/브레이크포인트 추가
- 단위 테스트 작성
```

### 5단계: 수정 및 확인
```
체크리스트:
- [ ] 근본 원인 해결 (증상만 X)
- [ ] 사이드 이펙트 확인
- [ ] 회귀 테스트 추가
- [ ] 문서화 (필요시)
```

## 디버깅 도구

### 언어별 도구
```
Python:  pdb, ipdb, py-spy, cProfile
JS/TS:   Chrome DevTools, node --inspect
Java:    jdb, VisualVM
Go:      delve
Rust:    rust-gdb, rust-lldb
```

### 공통 기법
```bash
# Git bisect
git bisect start
git bisect bad HEAD
git bisect good <commit>

# 로그 레벨 조정
DEBUG=* node app.js
LOG_LEVEL=debug python app.py
```

## 일반적인 버그 패턴

### 동시성
- Race condition
- Deadlock
- 순서 의존성

### 메모리
- Null/undefined 참조
- 메모리 누수
- 버퍼 오버플로우

### 상태
- 초기화 안됨
- 잘못된 상태 전이
- 캐시 불일치

### 타입
- 암시적 형변환
- 정수 오버플로우
- 부동소수점 오차

### 외부 의존성
- 네트워크 타임아웃
- API 변경
- 환경 차이

## 출력 형식

```
## Debug Report

### Problem Statement
- 예상: [예상 동작]
- 실제: [실제 동작]
- 재현: [재현 단계]

### Investigation

#### Hypothesis 1: [가설]
- 검증: [검증 방법]
- 결과: ✅/❌

#### Root Cause
- 위치: 파일:라인
- 원인: [근본 원인]
- 증거: [로그/스택트레이스]

### Solution
```code
// 수정 전
...
// 수정 후
...
```

### Prevention
- [ ] 테스트 추가
- [ ] 타입 강화
- [ ] 문서화
```

---

위 프레임워크를 사용하여 체계적으로 디버깅하세요.
