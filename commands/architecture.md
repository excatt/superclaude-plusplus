# Architecture Skill

소프트웨어 아키텍처 패턴 및 설계 가이드를 실행합니다.

## 아키텍처 스타일

### 모놀리식
```
┌─────────────────────────────────┐
│           Monolith              │
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │ UI  │ │Logic│ │ DB  │       │
│  └─────┘ └─────┘ └─────┘       │
└─────────────────────────────────┘

장점: 단순, 배포 쉬움, 트랜잭션 쉬움
단점: 확장 어려움, 기술 스택 고정
적합: 초기 스타트업, 작은 팀, MVP
```

### 마이크로서비스
```
┌─────────┐  ┌─────────┐  ┌─────────┐
│ User    │  │ Order   │  │ Payment │
│ Service │  │ Service │  │ Service │
│   DB    │  │   DB    │  │   DB    │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
─────┴────────────┴────────────┴─────
              API Gateway

장점: 독립 배포, 기술 다양성, 확장성
단점: 복잡성, 분산 트랜잭션, 운영 부담
적합: 대규모 팀, 복잡한 도메인
```

### 이벤트 기반
```
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Producer │────▶│ Event Broker│────▶│Consumer │
└─────────┘     │(Kafka/SQS)  │     └─────────┘
                └─────────────┘

장점: 느슨한 결합, 비동기 처리
단점: 복잡성, 디버깅 어려움
적합: 실시간 처리, 대용량 데이터
```

### 서버리스
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ API GW   │────▶│ Lambda   │────▶│ DynamoDB │
└──────────┘     └──────────┘     └──────────┘

장점: 인프라 관리 없음, 자동 확장
단점: 콜드 스타트, 벤더 종속
적합: 이벤트 처리, API 백엔드
```

## 레이어드 아키텍처

### 전통적 3계층
```
┌─────────────────────────────┐
│      Presentation Layer     │  UI, Controllers
├─────────────────────────────┤
│       Business Layer        │  Services, Logic
├─────────────────────────────┤
│         Data Layer          │  Repositories, DB
└─────────────────────────────┘
```

### 클린 아키텍처
```
        ┌───────────────────────────┐
        │        Frameworks         │ (Express, React)
        │    ┌───────────────┐      │
        │    │   Adapters    │      │ (Controllers, Gateways)
        │    │  ┌─────────┐  │      │
        │    │  │Use Cases│  │      │ (Application Logic)
        │    │  │┌───────┐│  │      │
        │    │  ││Entity ││  │      │ (Domain Models)
        │    │  │└───────┘│  │      │
        │    │  └─────────┘  │      │
        │    └───────────────┘      │
        └───────────────────────────┘

의존성 방향: 바깥 → 안쪽 (역전)
```

### 헥사고날 (포트 & 어댑터)
```
              ┌─────────────┐
   Primary    │             │   Secondary
   Adapters ─▶│   Domain    │◀─ Adapters
   (API)      │   (Core)    │   (DB, Queue)
              │             │
              └─────────────┘

포트: 인터페이스 정의
어댑터: 포트 구현
```

## 패턴 카탈로그

### CQRS
```
Command (쓰기) ─────▶ Write Model ─────▶ DB
Query (읽기)   ─────▶ Read Model  ─────▶ Read DB (최적화)
```

### Event Sourcing
```
State = f(Events)

Events: [UserCreated, EmailChanged, ...]
Current State: aggregate(Events)
```

### Saga Pattern
```
Service A ──▶ Service B ──▶ Service C
    │             │             │
    └── Compensate if any fails ─┘
```

### API Gateway
```
Client ──▶ API Gateway ──┬──▶ Service A
                         ├──▶ Service B
                         └──▶ Service C

기능: 라우팅, 인증, 레이트리밋, 로깅
```

## 설계 원칙

### SOLID
- **S**ingle Responsibility
- **O**pen/Closed
- **L**iskov Substitution
- **I**nterface Segregation
- **D**ependency Inversion

### 기타 원칙
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple)
- YAGNI (You Aren't Gonna Need It)
- 관심사 분리
- 느슨한 결합, 높은 응집

## 선택 가이드

### 팀 규모별
```
1-3명:   모놀리식 + 모듈화
3-10명:  모듈러 모놀리스
10+명:   마이크로서비스 고려
```

### 트래픽별
```
< 1K RPS:  모놀리식 충분
1K-10K:   모놀리식 + 캐싱/CDN
10K+:     마이크로서비스 + 로드밸런싱
```

### 복잡도별
```
단순 CRUD:     모놀리식
복잡한 도메인:  DDD + 클린 아키텍처
실시간 처리:   이벤트 기반
```

## 체크리스트

### 설계 검토
- [ ] 요구사항 명확
- [ ] 확장성 고려
- [ ] 장애 복구 전략
- [ ] 보안 고려
- [ ] 모니터링/로깅

### 문서화
- [ ] 시스템 다이어그램
- [ ] 데이터 흐름
- [ ] API 명세
- [ ] 의사결정 기록 (ADR)

## 출력 형식

```
## Architecture Design

### Overview
[아키텍처 스타일 및 선택 이유]

### System Diagram
```
[ASCII 다이어그램]
```

### Components
| 컴포넌트 | 책임 | 기술 |
|---------|------|------|
| API Gateway | 라우팅, 인증 | Kong |
| User Service | 사용자 관리 | Node.js |

### Data Flow
```
[데이터 흐름 다이어그램]
```

### Trade-offs
| 결정 | 장점 | 단점 |
|------|------|------|
| 마이크로서비스 | 확장성 | 복잡성 |

### ADR (Architecture Decision Record)
- 상황: [컨텍스트]
- 결정: [선택한 옵션]
- 결과: [예상 결과]
```

---

요청에 맞는 아키텍처를 설계하세요.
