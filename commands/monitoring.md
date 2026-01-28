# Monitoring Skill

모니터링 및 알림 시스템 설계 가이드를 실행합니다.

## 모니터링 계층

```
          ┌─────────────┐
          │  Business   │  매출, 전환율, 사용자 행동
          ├─────────────┤
          │ Application │  응답시간, 에러율, 처리량
          ├─────────────┤
          │   Service   │  가용성, 지연시간, 의존성
          ├─────────────┤
          │Infrastructure│ CPU, 메모리, 디스크, 네트워크
          └─────────────┘
```

## 핵심 메트릭 (Golden Signals)

### Four Golden Signals
```
1. Latency    - 요청 처리 시간 (p50, p95, p99)
2. Traffic    - 요청량 (RPS)
3. Errors     - 에러율 (5xx, 4xx)
4. Saturation - 자원 포화도 (CPU, 메모리)
```

### RED Method (서비스)
```
Rate   - 초당 요청 수
Errors - 실패한 요청 수
Duration - 요청 처리 시간
```

### USE Method (인프라)
```
Utilization - 자원 사용률 (%)
Saturation  - 대기열 길이, 지연
Errors      - 에러 이벤트 수
```

## 메트릭 수집

### Prometheus
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
```

### 애플리케이션 메트릭 (Node.js)
```javascript
const client = require('prom-client');

// 히스토그램 (응답 시간)
const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5],
});

// 카운터 (요청 수)
const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
});

// 게이지 (현재 값)
const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
});

// 미들웨어
app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    end({ method: req.method, route: req.route?.path, status: res.statusCode });
    httpRequests.inc({ method: req.method, route: req.route?.path, status: res.statusCode });
  });
  next();
});
```

## 로그 집계

### ELK Stack
```
App → Filebeat → Logstash → Elasticsearch → Kibana
```

### 구조화된 로깅
```javascript
// 검색/분석 가능한 JSON 로그
logger.info({
  event: 'order_created',
  orderId: '12345',
  userId: 'user-789',
  amount: 150.00,
  duration: 230,
});
```

## 분산 추적

### OpenTelemetry
```javascript
const { trace } = require('@opentelemetry/api');

const tracer = trace.getTracer('my-service');

async function handleRequest(req) {
  const span = tracer.startSpan('handle-request');

  try {
    span.setAttribute('user.id', req.userId);
    const result = await processRequest(req);
    span.setStatus({ code: SpanStatusCode.OK });
    return result;
  } catch (error) {
    span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    throw error;
  } finally {
    span.end();
  }
}
```

### 추적 흐름
```
[Service A] ─── traceId: abc123 ───→ [Service B] ───→ [Service C]
   spanId: 1                            spanId: 2       spanId: 3
```

## 알림 설계

### 알림 규칙
```yaml
# Prometheus Alertmanager
groups:
  - name: app-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: SlowResponse
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Slow response time"
          description: "95th percentile latency is {{ $value }}s"
```

### 알림 채널
```yaml
# alertmanager.yml
receivers:
  - name: 'slack-critical'
    slack_configs:
      - channel: '#alerts-critical'
        send_resolved: true

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: '<key>'

route:
  receiver: 'slack-critical'
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
```

### 알림 원칙
```
1. 실행 가능한 알림만 (actionable)
2. 적절한 심각도 설정
3. 충분한 컨텍스트 포함
4. 알림 피로도 관리
5. 에스컬레이션 정책
```

## 대시보드 설계

### Grafana 대시보드 구조
```
┌─────────────────────────────────────────────────┐
│              Overview (상태 요약)                │
├─────────────┬─────────────┬─────────────────────┤
│   Traffic   │   Latency   │      Errors         │
├─────────────┴─────────────┴─────────────────────┤
│              Detailed Metrics                   │
├─────────────────────────────────────────────────┤
│              Resource Usage                     │
└─────────────────────────────────────────────────┘
```

### 핵심 패널
```
1. 트래픽: RPS, 동시 접속자
2. 지연시간: p50, p95, p99
3. 에러율: 5xx, 4xx 비율
4. 자원: CPU, 메모리, 디스크
5. 의존성: DB, 캐시, 외부 API 상태
```

## SLI/SLO/SLA

### 정의
```
SLI (Service Level Indicator)
- 측정 가능한 지표
- 예: 응답 시간 p99, 가용성 %

SLO (Service Level Objective)
- 내부 목표치
- 예: p99 < 200ms, 가용성 99.9%

SLA (Service Level Agreement)
- 고객과의 계약
- 예: 99.5% 가용성 보장, 위반 시 환불
```

### Error Budget
```
SLO: 99.9% 가용성
= 월간 43.2분 다운타임 허용

Error Budget = 100% - SLO = 0.1%
사용량 추적하여 배포/변경 속도 조절
```

## 체크리스트

### 메트릭
- [ ] Golden Signals 수집
- [ ] 비즈니스 메트릭 정의
- [ ] 커스텀 메트릭 구현
- [ ] 메트릭 보존 기간 설정

### 로깅
- [ ] 구조화된 로그 형식
- [ ] 로그 레벨 적절히 설정
- [ ] 로그 집계 시스템
- [ ] 로그 검색/분석 가능

### 알림
- [ ] 실행 가능한 알림만
- [ ] 심각도별 채널 분리
- [ ] 에스컬레이션 정책
- [ ] 온콜 로테이션

### 추적
- [ ] 분산 추적 구현
- [ ] 서비스 간 컨텍스트 전파
- [ ] 샘플링 전략

## 출력 형식

```
## Monitoring Design

### Metrics Strategy
| 계층 | 메트릭 | 수집 방법 |
|------|--------|----------|
| App | 응답시간, 에러율 | Prometheus |
| Infra | CPU, Memory | node_exporter |

### Alert Rules
| 알림 | 조건 | 심각도 | 채널 |
|------|------|--------|------|
| HighErrorRate | >5% | critical | PagerDuty |

### Dashboard Layout
[대시보드 구조 설명]

### SLO Definition
| 서비스 | SLI | SLO |
|--------|-----|-----|
| API | p99 latency | < 200ms |
```

---

요청에 맞는 모니터링 전략을 설계하세요.
