# Microservices Skill

마이크로서비스 아키텍처 설계 가이드를 실행합니다.

## 마이크로서비스 원칙

```
1. 단일 책임: 하나의 비즈니스 기능
2. 독립 배포: 다른 서비스와 독립적 배포
3. 분산 데이터: 서비스별 데이터베이스
4. 자율성: 기술 스택 자율 선택
5. 회복성: 장애 격리 및 복구
```

## 아키텍처 패턴

### 전체 구조
```
                    ┌─────────────────┐
                    │   API Gateway   │
                    │    (Kong/AWS)   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  User Service │  │ Order Service │  │Product Service│
│   (Node.js)   │  │   (Python)    │  │    (Go)       │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        ▼                  ▼                  ▼
    PostgreSQL         PostgreSQL         MongoDB
```

### API Gateway
```yaml
# Kong 설정 예시
services:
  - name: user-service
    url: http://user-service:3000
    routes:
      - name: user-route
        paths: ["/api/users"]
        strip_path: false

  - name: order-service
    url: http://order-service:8000
    routes:
      - name: order-route
        paths: ["/api/orders"]
        strip_path: false

plugins:
  - name: rate-limiting
    config:
      minute: 100
  - name: jwt
  - name: cors
```

## 서비스 간 통신

### 동기 통신 (REST/gRPC)

```protobuf
// user.proto (gRPC)
syntax = "proto3";
package user;

service UserService {
  rpc GetUser (GetUserRequest) returns (UserResponse);
  rpc CreateUser (CreateUserRequest) returns (UserResponse);
}

message GetUserRequest {
  int32 id = 1;
}

message UserResponse {
  int32 id = 1;
  string email = 2;
  string name = 3;
}
```

```typescript
// gRPC 클라이언트 (TypeScript)
import { credentials } from '@grpc/grpc-js';
import { UserServiceClient } from './generated/user_grpc_pb';

const client = new UserServiceClient(
  'user-service:50051',
  credentials.createInsecure()
);

async function getUser(id: number) {
  return new Promise((resolve, reject) => {
    const request = new GetUserRequest();
    request.setId(id);

    client.getUser(request, (err, response) => {
      if (err) reject(err);
      else resolve(response.toObject());
    });
  });
}
```

### 비동기 통신 (Message Queue)

```typescript
// RabbitMQ Producer
import amqp from 'amqplib';

async function publishEvent(queue: string, message: object) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();

  await channel.assertQueue(queue, { durable: true });
  channel.sendToQueue(queue, Buffer.from(JSON.stringify(message)), {
    persistent: true,
  });

  await channel.close();
  await connection.close();
}

// 주문 생성 시 이벤트 발행
await publishEvent('order.created', {
  orderId: order.id,
  userId: order.userId,
  items: order.items,
  totalAmount: order.totalAmount,
});
```

```typescript
// RabbitMQ Consumer
async function consumeEvents(queue: string, handler: (msg: any) => Promise<void>) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();

  await channel.assertQueue(queue, { durable: true });
  channel.prefetch(1);

  channel.consume(queue, async (msg) => {
    if (msg) {
      try {
        const content = JSON.parse(msg.content.toString());
        await handler(content);
        channel.ack(msg);
      } catch (error) {
        channel.nack(msg, false, true); // 재시도
      }
    }
  });
}

// 이메일 서비스에서 주문 이벤트 처리
consumeEvents('order.created', async (event) => {
  await sendOrderConfirmationEmail(event.userId, event.orderId);
});
```

## Saga 패턴 (분산 트랜잭션)

### Choreography (이벤트 기반)
```
Order Service          Payment Service         Inventory Service
     │                      │                       │
     │ OrderCreated         │                       │
     │─────────────────────►│                       │
     │                      │ PaymentProcessed      │
     │                      │──────────────────────►│
     │                      │                       │ InventoryReserved
     │◄─────────────────────┼───────────────────────│
     │ OrderCompleted       │                       │
```

```typescript
// Order Service
class OrderSaga {
  async createOrder(orderData: CreateOrderDTO) {
    // 1. 주문 생성 (PENDING)
    const order = await this.orderRepo.create({
      ...orderData,
      status: 'PENDING',
    });

    // 2. 결제 요청 이벤트 발행
    await this.eventBus.publish('order.created', {
      orderId: order.id,
      userId: orderData.userId,
      amount: orderData.totalAmount,
    });

    return order;
  }

  // Payment 성공 이벤트 처리
  @OnEvent('payment.completed')
  async onPaymentCompleted(event: PaymentCompletedEvent) {
    await this.orderRepo.updateStatus(event.orderId, 'PAID');

    // 재고 예약 요청
    await this.eventBus.publish('order.paid', {
      orderId: event.orderId,
      items: event.items,
    });
  }

  // Payment 실패 이벤트 처리 (보상 트랜잭션)
  @OnEvent('payment.failed')
  async onPaymentFailed(event: PaymentFailedEvent) {
    await this.orderRepo.updateStatus(event.orderId, 'CANCELLED');
  }
}
```

### Orchestration (중앙 조정자)
```typescript
// Order Orchestrator
class OrderOrchestrator {
  async processOrder(orderData: CreateOrderDTO) {
    const saga = await this.sagaRepo.create({ status: 'STARTED' });

    try {
      // Step 1: 주문 생성
      const order = await this.orderService.create(orderData);
      await this.sagaRepo.updateStep(saga.id, 'ORDER_CREATED');

      // Step 2: 결제 처리
      const payment = await this.paymentService.process({
        orderId: order.id,
        amount: orderData.totalAmount,
      });
      await this.sagaRepo.updateStep(saga.id, 'PAYMENT_PROCESSED');

      // Step 3: 재고 예약
      await this.inventoryService.reserve({
        orderId: order.id,
        items: orderData.items,
      });
      await this.sagaRepo.updateStep(saga.id, 'INVENTORY_RESERVED');

      // 완료
      await this.sagaRepo.complete(saga.id);
      return order;

    } catch (error) {
      // 보상 트랜잭션 실행
      await this.compensate(saga);
      throw error;
    }
  }

  private async compensate(saga: Saga) {
    const steps = saga.completedSteps.reverse();

    for (const step of steps) {
      switch (step) {
        case 'INVENTORY_RESERVED':
          await this.inventoryService.release(saga.orderId);
          break;
        case 'PAYMENT_PROCESSED':
          await this.paymentService.refund(saga.orderId);
          break;
        case 'ORDER_CREATED':
          await this.orderService.cancel(saga.orderId);
          break;
      }
    }
  }
}
```

## 서비스 디스커버리

```yaml
# Docker Compose with Consul
services:
  consul:
    image: consul:latest
    ports:
      - "8500:8500"

  user-service:
    build: ./user-service
    environment:
      - CONSUL_HOST=consul
    depends_on:
      - consul

  order-service:
    build: ./order-service
    environment:
      - CONSUL_HOST=consul
    depends_on:
      - consul
```

```typescript
// 서비스 등록
import Consul from 'consul';

const consul = new Consul({ host: process.env.CONSUL_HOST });

await consul.agent.service.register({
  name: 'user-service',
  address: 'user-service',
  port: 3000,
  check: {
    http: 'http://user-service:3000/health',
    interval: '10s',
  },
});

// 서비스 조회
const services = await consul.catalog.service.nodes('order-service');
const serviceUrl = `http://${services[0].ServiceAddress}:${services[0].ServicePort}`;
```

## Circuit Breaker

```typescript
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(async (userId: string) => {
  const response = await fetch(`${USER_SERVICE_URL}/users/${userId}`);
  if (!response.ok) throw new Error('Service unavailable');
  return response.json();
}, {
  timeout: 3000,           // 타임아웃 3초
  errorThresholdPercentage: 50,  // 50% 실패 시 open
  resetTimeout: 30000,     // 30초 후 half-open
});

breaker.fallback(() => ({ id: 'unknown', name: 'Guest' }));

breaker.on('open', () => console.log('Circuit opened'));
breaker.on('close', () => console.log('Circuit closed'));

// 사용
const user = await breaker.fire(userId);
```

## Health Check & Monitoring

```typescript
// 종합 헬스체크
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalApi: await checkExternalApi(),
  };

  const healthy = Object.values(checks).every(c => c.status === 'healthy');

  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    checks,
    timestamp: new Date().toISOString(),
  });
});

// Prometheus 메트릭
import { collectDefaultMetrics, Registry } from 'prom-client';

const register = new Registry();
collectDefaultMetrics({ register });

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

## 체크리스트

- [ ] 서비스 경계 정의 (도메인 기반)
- [ ] API Gateway 설정
- [ ] 서비스 간 통신 방식 선택
- [ ] 분산 트랜잭션 전략 (Saga)
- [ ] 서비스 디스커버리
- [ ] Circuit Breaker
- [ ] 중앙 집중 로깅
- [ ] 분산 트레이싱
- [ ] Health Check
- [ ] 모니터링/알림

## 출력 형식

```
## Microservices Architecture

### Services
| Service | Responsibility | Tech Stack | Database |
|---------|---------------|------------|----------|
| User | 사용자 관리 | Node.js | PostgreSQL |
| Order | 주문 처리 | Python | PostgreSQL |

### Communication
- Sync: gRPC (내부), REST (외부)
- Async: RabbitMQ

### Data Flow
```
[Diagram]
```

### Saga Pattern
| Step | Service | Action | Compensation |
|------|---------|--------|--------------|
| 1 | Order | Create | Cancel |
| 2 | Payment | Charge | Refund |
```

---

요청에 맞는 마이크로서비스 아키텍처를 설계하세요.
