# Message Queue Skill

메시지 큐 설계 가이드를 실행합니다.

## 메시지 큐 개념

```
┌──────────┐    ┌─────────┐    ┌──────────┐
│ Producer │ →  │  Queue  │ →  │ Consumer │
└──────────┘    └─────────┘    └──────────┘

비동기 통신, 느슨한 결합, 버퍼링
```

## 사용 사례

```
1. 비동기 처리: 이메일 발송, 알림
2. 부하 분산: 요청 피크 완화
3. 마이크로서비스 통신
4. 이벤트 소싱
5. 로그 수집
```

## 큐 유형

### Point-to-Point
```
Producer → Queue → Consumer (1:1)

한 메시지는 하나의 컨슈머만 처리
작업 큐, 태스크 분배
```

### Pub/Sub
```
Publisher → Topic → Subscriber A
                 → Subscriber B
                 → Subscriber C

한 메시지를 여러 구독자가 수신
이벤트 브로드캐스트
```

## RabbitMQ

### 기본 구조
```
Producer → Exchange → Queue → Consumer
                  ↘ Queue → Consumer

Exchange Types:
- direct: 라우팅 키 정확히 일치
- fanout: 모든 큐에 브로드캐스트
- topic: 패턴 매칭 (*.error, log.#)
- headers: 헤더 기반 라우팅
```

### Node.js 구현
```javascript
const amqp = require('amqplib');

// Producer
async function sendMessage(queue, message) {
  const connection = await amqp.connect('amqp://localhost');
  const channel = await connection.createChannel();

  await channel.assertQueue(queue, { durable: true });
  channel.sendToQueue(queue, Buffer.from(JSON.stringify(message)), {
    persistent: true,
  });

  await channel.close();
  await connection.close();
}

// Consumer
async function consumeMessages(queue, handler) {
  const connection = await amqp.connect('amqp://localhost');
  const channel = await connection.createChannel();

  await channel.assertQueue(queue, { durable: true });
  channel.prefetch(1); // 동시 처리 제한

  channel.consume(queue, async (msg) => {
    try {
      const data = JSON.parse(msg.content.toString());
      await handler(data);
      channel.ack(msg); // 성공 확인
    } catch (error) {
      channel.nack(msg, false, true); // 재시도
    }
  });
}

// 사용
sendMessage('emails', { to: 'user@example.com', subject: 'Hello' });
consumeMessages('emails', async (data) => {
  await sendEmail(data);
});
```

### Exchange 설정
```javascript
// Direct Exchange
await channel.assertExchange('logs', 'direct', { durable: true });
channel.publish('logs', 'error', Buffer.from(message));

// Topic Exchange
await channel.assertExchange('events', 'topic', { durable: true });
channel.publish('events', 'order.created', Buffer.from(message));

// 구독
await channel.bindQueue(queue, 'events', 'order.*');
```

## Apache Kafka

### 기본 구조
```
Producer → Topic (Partitions) → Consumer Group
                               → Consumer Group

Topic: 메시지 카테고리
Partition: 병렬 처리 단위
Consumer Group: 파티션 분배
```

### Node.js 구현 (KafkaJS)
```javascript
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: ['localhost:9092'],
});

// Producer
const producer = kafka.producer();

async function sendMessage(topic, message) {
  await producer.connect();
  await producer.send({
    topic,
    messages: [
      { key: message.id, value: JSON.stringify(message) },
    ],
  });
}

// Consumer
const consumer = kafka.consumer({ groupId: 'my-group' });

async function consumeMessages(topic, handler) {
  await consumer.connect();
  await consumer.subscribe({ topic, fromBeginning: true });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const data = JSON.parse(message.value.toString());
      await handler(data);
    },
  });
}
```

### 파티션 전략
```javascript
// 키 기반 파티셔닝 (같은 키는 같은 파티션)
await producer.send({
  topic: 'orders',
  messages: [
    { key: order.userId, value: JSON.stringify(order) },
  ],
});

// 순서 보장: 같은 키의 메시지는 순서대로 처리
```

## Bull (Redis 기반)

### 작업 큐
```javascript
const Queue = require('bull');

// 큐 생성
const emailQueue = new Queue('email', {
  redis: { host: 'localhost', port: 6379 },
  defaultJobOptions: {
    attempts: 3,
    backoff: { type: 'exponential', delay: 1000 },
    removeOnComplete: true,
  },
});

// 작업 추가
await emailQueue.add(
  { to: 'user@example.com', subject: 'Hello' },
  { priority: 1, delay: 5000 } // 우선순위, 지연
);

// 작업 처리
emailQueue.process(async (job) => {
  console.log('Processing:', job.data);
  await sendEmail(job.data);
  return { sent: true };
});

// 이벤트
emailQueue.on('completed', (job, result) => {
  console.log('Completed:', job.id, result);
});

emailQueue.on('failed', (job, err) => {
  console.error('Failed:', job.id, err);
});
```

### 스케줄링
```javascript
// 반복 작업
await emailQueue.add(
  { type: 'daily-report' },
  { repeat: { cron: '0 9 * * *' } } // 매일 9시
);

// 지연 작업
await emailQueue.add(
  { type: 'reminder' },
  { delay: 24 * 60 * 60 * 1000 } // 24시간 후
);
```

## 메시지 패턴

### Request-Reply
```javascript
// Requester
const replyQueue = await channel.assertQueue('', { exclusive: true });
const correlationId = uuid();

channel.consume(replyQueue.queue, (msg) => {
  if (msg.properties.correlationId === correlationId) {
    console.log('Reply:', msg.content.toString());
  }
});

channel.sendToQueue('rpc_queue', Buffer.from(request), {
  correlationId,
  replyTo: replyQueue.queue,
});

// Responder
channel.consume('rpc_queue', async (msg) => {
  const result = await processRequest(msg.content);
  channel.sendToQueue(msg.properties.replyTo, Buffer.from(result), {
    correlationId: msg.properties.correlationId,
  });
  channel.ack(msg);
});
```

### Dead Letter Queue
```javascript
// 실패한 메시지 처리
await channel.assertQueue('main_queue', {
  durable: true,
  deadLetterExchange: 'dlx',
  deadLetterRoutingKey: 'failed',
});

await channel.assertQueue('dead_letter_queue', { durable: true });
await channel.bindQueue('dead_letter_queue', 'dlx', 'failed');
```

## 안정성 패턴

### 멱등성 보장
```javascript
async function processMessage(message) {
  const messageId = message.id;

  // 중복 체크
  if (await redis.get(`processed:${messageId}`)) {
    return; // 이미 처리됨
  }

  // 처리
  await doWork(message);

  // 처리 완료 기록
  await redis.set(`processed:${messageId}`, '1', 'EX', 86400);
}
```

### 재시도 전략
```javascript
const options = {
  attempts: 5,
  backoff: {
    type: 'exponential',
    delay: 1000, // 1s, 2s, 4s, 8s, 16s
  },
};
```

## 체크리스트

### 설계
- [ ] 메시지 형식 정의
- [ ] 큐/토픽 구조 설계
- [ ] 파티션/샤딩 전략
- [ ] 보존 정책

### 안정성
- [ ] 메시지 지속성
- [ ] 재시도 정책
- [ ] Dead Letter Queue
- [ ] 멱등성 보장

### 운영
- [ ] 모니터링/알림
- [ ] 백프레셔 처리
- [ ] 확장 전략

## 출력 형식

```
## Message Queue Design

### Architecture
```
[Producer] → [Exchange/Topic] → [Queue] → [Consumer]
```

### Queue Configuration
| 큐 | 용도 | 설정 |
|----|------|------|
| emails | 이메일 발송 | durable, 3 retries |
| orders | 주문 처리 | partitioned by user |

### Implementation
```javascript
// 핵심 구현 코드
```

### Error Handling
- 재시도: exponential backoff
- DLQ: 5회 실패 후 이동
```

---

요청에 맞는 메시지 큐 전략을 설계하세요.
