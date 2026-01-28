# Scaling Skill

확장성 설계 가이드를 실행합니다.

## 확장 유형

### 수직 확장 (Scale Up)
```
┌─────────────┐      ┌─────────────┐
│   Server    │  →   │   Server    │
│  4 CPU      │      │  16 CPU     │
│  8GB RAM    │      │  64GB RAM   │
└─────────────┘      └─────────────┘

장점: 단순함, 애플리케이션 변경 불필요
단점: 물리적 한계, 단일 장애점, 비용
```

### 수평 확장 (Scale Out)
```
┌─────────────┐      ┌─────────────┐
│   Server    │  →   │  Server x N │
│             │      │  Load       │
│             │      │  Balancer   │
└─────────────┘      └─────────────┘

장점: 무한 확장 가능, 고가용성
단점: 복잡성, 상태 관리 어려움
```

## 무상태 설계 (Stateless)

### 세션 외부화
```javascript
// ❌ Bad: 서버 메모리에 세션
const sessions = {};
app.use((req, res, next) => {
  const session = sessions[req.cookies.sid];
});

// ✅ Good: 외부 저장소
const RedisStore = require('connect-redis').default;
app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: 'secret',
}));
```

### 파일 저장소 외부화
```javascript
// ❌ Bad: 로컬 파일 시스템
fs.writeFile('/uploads/file.jpg', data);

// ✅ Good: 객체 스토리지 (S3)
await s3.upload({
  Bucket: 'my-bucket',
  Key: 'uploads/file.jpg',
  Body: data,
}).promise();
```

## 로드 밸런싱

### 알고리즘
```
Round Robin     순차적 분배
Weighted        가중치 기반
Least Connections  연결 수 기반
IP Hash         클라이언트 IP 기반
```

### Nginx 설정
```nginx
upstream backend {
    least_conn;
    server backend1:3000 weight=3;
    server backend2:3000 weight=2;
    server backend3:3000 weight=1;

    keepalive 32;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

### Health Check
```nginx
upstream backend {
    server backend1:3000;
    server backend2:3000;

    health_check interval=5s fails=3 passes=2;
}
```

## 데이터베이스 확장

### 읽기 복제 (Read Replica)
```
┌────────────┐
│   Master   │ ← Write
│  (Primary) │
└─────┬──────┘
      │ Replication
┌─────┴──────┐
│  Replica   │ ← Read
│ (Secondary)│
└────────────┘
```

```javascript
// 연결 분리
const writeDb = new Pool({ host: 'master' });
const readDb = new Pool({ host: 'replica' });

async function getUser(id) {
  return readDb.query('SELECT * FROM users WHERE id = $1', [id]);
}

async function createUser(data) {
  return writeDb.query('INSERT INTO users ...', [data]);
}
```

### 샤딩 (Sharding)
```
User ID 1-1000    → Shard 1
User ID 1001-2000 → Shard 2
User ID 2001-3000 → Shard 3

// 샤드 결정 함수
function getShard(userId) {
  return shards[userId % shards.length];
}
```

### 파티셔닝
```sql
-- 시간 기반 파티셔닝
CREATE TABLE orders (
    id SERIAL,
    created_at TIMESTAMP,
    ...
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_01 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

## 캐싱 전략

### 다중 레이어 캐싱
```
Browser Cache → CDN → App Cache → Redis → Database
```

### CDN 활용
```nginx
# 정적 자원
location /static/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# API 응답
location /api/ {
    add_header Cache-Control "private, max-age=60";
}
```

### 애플리케이션 캐시
```javascript
const cache = new Map();
const CACHE_TTL = 60000;

async function getCachedData(key, fetchFn) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.time < CACHE_TTL) {
    return cached.data;
  }

  const data = await fetchFn();
  cache.set(key, { data, time: Date.now() });
  return data;
}
```

## 비동기 처리

### 메시지 큐
```
┌────────┐    ┌─────────┐    ┌──────────┐
│Producer│ →  │  Queue  │ →  │ Consumer │
└────────┘    │(RabbitMQ│    └──────────┘
              │ /Kafka) │
              └─────────┘
```

```javascript
// Producer
await channel.sendToQueue('tasks', Buffer.from(JSON.stringify(task)));

// Consumer
channel.consume('tasks', async (msg) => {
  const task = JSON.parse(msg.content.toString());
  await processTask(task);
  channel.ack(msg);
});
```

### 백그라운드 작업
```javascript
// Bull Queue (Redis 기반)
const Queue = require('bull');
const emailQueue = new Queue('email');

// 작업 추가
await emailQueue.add({ to: 'user@example.com', subject: 'Hello' });

// 처리
emailQueue.process(async (job) => {
  await sendEmail(job.data);
});
```

## 자동 확장

### Kubernetes HPA
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### AWS Auto Scaling
```yaml
# 조건 기반 확장
ScalingPolicy:
  - Metric: CPUUtilization
    Threshold: 70%
    ScaleOut: +2 instances
    ScaleIn: -1 instance
    Cooldown: 300s
```

## 확장성 체크리스트

### 애플리케이션
- [ ] 무상태 설계
- [ ] 세션 외부화
- [ ] 파일 저장소 외부화
- [ ] 환경 설정 외부화

### 데이터베이스
- [ ] 읽기 복제 구성
- [ ] 커넥션 풀링
- [ ] 인덱스 최적화
- [ ] 쿼리 캐싱

### 인프라
- [ ] 로드 밸런서 구성
- [ ] 자동 확장 설정
- [ ] 헬스 체크
- [ ] 모니터링/알림

## 출력 형식

```
## Scaling Strategy

### Current Bottlenecks
| 구성요소 | 현재 | 병목 | 해결책 |
|---------|------|------|--------|
| API | 1 instance | CPU 90% | Scale Out |
| DB | Single | Read heavy | Read Replica |

### Architecture
```
[LB] → [App x3] → [Cache] → [DB Master]
                           → [DB Replica]
```

### Scaling Plan
1. [단기] 읽기 복제 구성
2. [중기] 캐싱 레이어 추가
3. [장기] 샤딩 검토

### Cost Estimation
| 구성 | 현재 | 확장 후 |
|------|------|---------|
| Compute | $100 | $300 |
| Database | $200 | $400 |
```

---

요청에 맞는 확장 전략을 설계하세요.
