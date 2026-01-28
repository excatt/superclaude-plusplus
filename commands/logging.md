# Logging Skill

로깅 및 모니터링 전략을 위한 가이드를 실행합니다.

## 로그 레벨

```
FATAL   시스템 중단 필요한 심각한 에러
ERROR   에러, 하지만 시스템은 계속 동작
WARN    잠재적 문제, 주의 필요
INFO    주요 이벤트, 정상 동작 확인
DEBUG   디버깅용 상세 정보
TRACE   매우 상세한 추적 정보
```

### 레벨 선택 가이드
```
✅ ERROR: 예외 발생, 요청 실패, 데이터 손실
✅ WARN:  재시도, 폴백, 성능 저하
✅ INFO:  요청 시작/완료, 상태 변경, 배포
✅ DEBUG: 변수값, 조건문, 외부 호출
❌ 절대 로깅 X: 비밀번호, 토큰, 개인정보
```

## 구조화된 로깅

### JSON 형식 (권장)
```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "service": "user-api",
  "traceId": "abc-123-def",
  "spanId": "span-456",
  "message": "User created",
  "context": {
    "userId": "user-789",
    "action": "CREATE",
    "duration": 150
  }
}
```

### 필수 필드
```
timestamp   ISO 8601 형식
level       로그 레벨
service     서비스 이름
traceId     분산 추적 ID
message     사람이 읽을 수 있는 메시지
```

## 언어별 구현

### Node.js (Pino)
```javascript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
});

// 사용
logger.info({ userId, action: 'login' }, 'User logged in');
logger.error({ err, userId }, 'Login failed');
```

### Python (structlog)
```python
import structlog

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ]
)

logger = structlog.get_logger()

# 사용
logger.info("user_created", user_id=user_id, email=email)
logger.error("login_failed", user_id=user_id, error=str(e))
```

## 분산 추적

### OpenTelemetry 통합
```javascript
const { trace } = require('@opentelemetry/api');

function handleRequest(req, res) {
  const span = trace.getActiveSpan();
  const traceId = span?.spanContext().traceId;

  logger.info({ traceId, path: req.path }, 'Request received');
}
```

### 상관관계 ID
```
Request → API Gateway → Service A → Service B → DB
           traceId: abc-123 (동일)
           spanId:  각 서비스마다 다름
```

## 모니터링 연동

### 메트릭 수집
```javascript
// 요청 카운터
requestCounter.inc({ method, path, status });

// 응답 시간
responseTime.observe({ method, path }, duration);

// 에러율
errorCounter.inc({ type: error.name });
```

### 알림 규칙
```yaml
alerts:
  - name: HighErrorRate
    condition: error_rate > 5%
    duration: 5m
    severity: critical

  - name: SlowResponse
    condition: p99_latency > 2s
    duration: 10m
    severity: warning
```

## 로깅 체크리스트

### DO
- [ ] 구조화된 JSON 로깅
- [ ] 분산 추적 ID 포함
- [ ] 적절한 로그 레벨
- [ ] 컨텍스트 정보 포함
- [ ] 타임스탬프 (UTC)
- [ ] 에러 스택트레이스

### DON'T
- [ ] 민감 정보 로깅 금지
- [ ] console.log 사용 금지 (프로덕션)
- [ ] 과도한 로깅 금지
- [ ] 동기 파일 로깅 금지

## 로그 관리

### 로테이션
```
일별 로테이션
7일 보관
압축 저장
```

### 중앙화
```
애플리케이션 → Fluentd → Elasticsearch → Kibana
            → CloudWatch
            → Datadog
```

## 출력 형식

```
## Logging Strategy

### Configuration
```javascript
// 로거 설정 코드
```

### Log Levels by Environment
| 환경 | 기본 레벨 |
|------|----------|
| development | DEBUG |
| staging | INFO |
| production | INFO |

### Key Events to Log
| 이벤트 | 레벨 | 필드 |
|--------|------|------|
| Request received | INFO | traceId, path, method |
| Request completed | INFO | traceId, duration, status |
| Error occurred | ERROR | traceId, error, stack |

### Monitoring Integration
- APM: [Datadog/NewRelic/etc]
- Logs: [ELK/CloudWatch/etc]
- Alerts: [PagerDuty/Slack/etc]
```

---

요청에 맞는 로깅 전략을 설계하세요.
