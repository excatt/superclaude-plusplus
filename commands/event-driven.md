# Event-Driven Architecture Skill

이벤트 기반 아키텍처 설계 가이드를 실행합니다.

## 핵심 개념

```
Event Producer → Event Channel → Event Consumer
                    │
                    ├── Message Broker (Kafka, RabbitMQ)
                    ├── Event Store (EventStoreDB)
                    └── Streaming (Kafka Streams)

이벤트 유형:
├── Domain Event: 비즈니스 발생 사실 (OrderPlaced)
├── Integration Event: 시스템 간 통신 (OrderPlacedIntegrationEvent)
├── Command: 작업 요청 (PlaceOrder)
└── Query: 데이터 요청 (GetOrderById)
```

## 프로젝트 구조

```
src/
├── domain/
│   ├── events/
│   │   ├── OrderPlaced.ts
│   │   ├── OrderShipped.ts
│   │   └── index.ts
│   └── aggregates/
│       └── Order.ts
├── application/
│   ├── commands/
│   │   └── PlaceOrderCommand.ts
│   ├── handlers/
│   │   ├── PlaceOrderHandler.ts
│   │   └── OrderEventHandler.ts
│   └── sagas/
│       └── OrderSaga.ts
├── infrastructure/
│   ├── messaging/
│   │   ├── KafkaProducer.ts
│   │   ├── KafkaConsumer.ts
│   │   └── RabbitMQClient.ts
│   └── eventstore/
│       └── EventStoreRepository.ts
└── api/
    └── controllers/
```

## Domain Event

```typescript
// domain/events/base/DomainEvent.ts
export interface DomainEvent {
  readonly eventId: string;
  readonly eventType: string;
  readonly aggregateId: string;
  readonly aggregateType: string;
  readonly occurredAt: Date;
  readonly version: number;
  readonly payload: Record<string, unknown>;
  readonly metadata?: Record<string, unknown>;
}

export abstract class BaseDomainEvent implements DomainEvent {
  readonly eventId: string;
  readonly occurredAt: Date;

  constructor(
    public readonly aggregateId: string,
    public readonly aggregateType: string,
    public readonly version: number,
    public readonly payload: Record<string, unknown>
  ) {
    this.eventId = crypto.randomUUID();
    this.occurredAt = new Date();
  }

  abstract get eventType(): string;
}

// domain/events/OrderPlaced.ts
export class OrderPlacedEvent extends BaseDomainEvent {
  get eventType(): string {
    return 'ORDER_PLACED';
  }

  constructor(
    orderId: string,
    version: number,
    public readonly customerId: string,
    public readonly items: OrderItem[],
    public readonly totalAmount: number
  ) {
    super(orderId, 'Order', version, {
      customerId,
      items,
      totalAmount,
    });
  }
}

// domain/events/OrderShipped.ts
export class OrderShippedEvent extends BaseDomainEvent {
  get eventType(): string {
    return 'ORDER_SHIPPED';
  }

  constructor(
    orderId: string,
    version: number,
    public readonly trackingNumber: string,
    public readonly carrier: string
  ) {
    super(orderId, 'Order', version, {
      trackingNumber,
      carrier,
    });
  }
}
```

## Event Sourcing

```typescript
// domain/aggregates/Order.ts
export class Order {
  private _id: string;
  private _customerId: string;
  private _items: OrderItem[] = [];
  private _status: OrderStatus = 'PENDING';
  private _version: number = 0;
  private _uncommittedEvents: DomainEvent[] = [];

  get id(): string { return this._id; }
  get version(): number { return this._version; }
  get uncommittedEvents(): DomainEvent[] { return [...this._uncommittedEvents]; }

  // Factory Method (새 주문)
  static create(customerId: string, items: OrderItem[]): Order {
    const order = new Order();
    const orderId = crypto.randomUUID();

    order.applyChange(new OrderPlacedEvent(
      orderId,
      1,
      customerId,
      items,
      items.reduce((sum, i) => sum + i.price * i.quantity, 0)
    ));

    return order;
  }

  // Rehydrate from events
  static fromHistory(events: DomainEvent[]): Order {
    const order = new Order();
    events.forEach(event => order.apply(event, false));
    return order;
  }

  // Apply event
  private applyChange(event: DomainEvent): void {
    this.apply(event, true);
    this._uncommittedEvents.push(event);
  }

  private apply(event: DomainEvent, isNew: boolean): void {
    switch (event.eventType) {
      case 'ORDER_PLACED':
        this.applyOrderPlaced(event as OrderPlacedEvent);
        break;
      case 'ORDER_SHIPPED':
        this.applyOrderShipped(event as OrderShippedEvent);
        break;
      case 'ORDER_CANCELLED':
        this.applyOrderCancelled(event as OrderCancelledEvent);
        break;
    }

    if (!isNew) {
      this._version = event.version;
    }
  }

  private applyOrderPlaced(event: OrderPlacedEvent): void {
    this._id = event.aggregateId;
    this._customerId = event.customerId;
    this._items = event.items;
    this._status = 'PENDING';
    this._version = event.version;
  }

  private applyOrderShipped(event: OrderShippedEvent): void {
    this._status = 'SHIPPED';
    this._version = event.version;
  }

  // Commands
  ship(trackingNumber: string, carrier: string): void {
    if (this._status !== 'CONFIRMED') {
      throw new Error('Order must be confirmed before shipping');
    }

    this.applyChange(new OrderShippedEvent(
      this._id,
      this._version + 1,
      trackingNumber,
      carrier
    ));
  }

  clearUncommittedEvents(): void {
    this._uncommittedEvents = [];
  }
}
```

## Event Store

```typescript
// infrastructure/eventstore/EventStore.ts
export interface EventStore {
  saveEvents(
    aggregateId: string,
    events: DomainEvent[],
    expectedVersion: number
  ): Promise<void>;

  getEvents(aggregateId: string): Promise<DomainEvent[]>;

  getEventsByType(eventType: string): Promise<DomainEvent[]>;
}

// infrastructure/eventstore/PostgresEventStore.ts
export class PostgresEventStore implements EventStore {
  constructor(private readonly db: Pool) {}

  async saveEvents(
    aggregateId: string,
    events: DomainEvent[],
    expectedVersion: number
  ): Promise<void> {
    const client = await this.db.connect();

    try {
      await client.query('BEGIN');

      // Optimistic Concurrency Check
      const result = await client.query(
        'SELECT MAX(version) as version FROM events WHERE aggregate_id = $1',
        [aggregateId]
      );

      const currentVersion = result.rows[0]?.version ?? 0;
      if (currentVersion !== expectedVersion) {
        throw new ConcurrencyError(
          `Expected version ${expectedVersion}, but got ${currentVersion}`
        );
      }

      // Insert events
      for (const event of events) {
        await client.query(
          `INSERT INTO events (
            event_id, event_type, aggregate_id, aggregate_type,
            version, payload, metadata, occurred_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            event.eventId,
            event.eventType,
            event.aggregateId,
            event.aggregateType,
            event.version,
            JSON.stringify(event.payload),
            JSON.stringify(event.metadata),
            event.occurredAt,
          ]
        );
      }

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getEvents(aggregateId: string): Promise<DomainEvent[]> {
    const result = await this.db.query(
      `SELECT * FROM events WHERE aggregate_id = $1 ORDER BY version ASC`,
      [aggregateId]
    );

    return result.rows.map(row => this.mapToEvent(row));
  }

  private mapToEvent(row: any): DomainEvent {
    // Event type별 매핑
    return {
      eventId: row.event_id,
      eventType: row.event_type,
      aggregateId: row.aggregate_id,
      aggregateType: row.aggregate_type,
      version: row.version,
      payload: row.payload,
      metadata: row.metadata,
      occurredAt: row.occurred_at,
    };
  }
}
```

## Message Broker (Kafka)

```typescript
// infrastructure/messaging/KafkaProducer.ts
import { Kafka, Producer, CompressionTypes } from 'kafkajs';

export class KafkaEventPublisher {
  private producer: Producer;

  constructor(private readonly kafka: Kafka) {
    this.producer = kafka.producer();
  }

  async connect(): Promise<void> {
    await this.producer.connect();
  }

  async publish(topic: string, event: DomainEvent): Promise<void> {
    await this.producer.send({
      topic,
      compression: CompressionTypes.GZIP,
      messages: [
        {
          key: event.aggregateId,
          value: JSON.stringify(event),
          headers: {
            eventType: event.eventType,
            correlationId: event.metadata?.correlationId as string,
          },
        },
      ],
    });
  }

  async publishBatch(topic: string, events: DomainEvent[]): Promise<void> {
    await this.producer.send({
      topic,
      compression: CompressionTypes.GZIP,
      messages: events.map(event => ({
        key: event.aggregateId,
        value: JSON.stringify(event),
        headers: {
          eventType: event.eventType,
        },
      })),
    });
  }
}

// infrastructure/messaging/KafkaConsumer.ts
import { Kafka, Consumer, EachMessagePayload } from 'kafkajs';

export class KafkaEventConsumer {
  private consumer: Consumer;

  constructor(
    private readonly kafka: Kafka,
    private readonly groupId: string
  ) {
    this.consumer = kafka.consumer({ groupId });
  }

  async subscribe(
    topics: string[],
    handler: (event: DomainEvent) => Promise<void>
  ): Promise<void> {
    await this.consumer.connect();

    for (const topic of topics) {
      await this.consumer.subscribe({ topic, fromBeginning: false });
    }

    await this.consumer.run({
      eachMessage: async ({ topic, partition, message }: EachMessagePayload) => {
        try {
          const event = JSON.parse(message.value!.toString()) as DomainEvent;
          await handler(event);
        } catch (error) {
          console.error('Error processing message:', error);
          // Dead Letter Queue로 전송
          await this.sendToDeadLetter(topic, message);
        }
      },
    });
  }

  private async sendToDeadLetter(topic: string, message: any): Promise<void> {
    // DLQ 구현
  }
}
```

## Event Handler

```typescript
// application/handlers/OrderEventHandler.ts
export class OrderEventHandler {
  constructor(
    private readonly emailService: EmailService,
    private readonly inventoryService: InventoryService,
    private readonly analyticsService: AnalyticsService
  ) {}

  async handle(event: DomainEvent): Promise<void> {
    switch (event.eventType) {
      case 'ORDER_PLACED':
        await this.handleOrderPlaced(event as OrderPlacedEvent);
        break;
      case 'ORDER_SHIPPED':
        await this.handleOrderShipped(event as OrderShippedEvent);
        break;
      case 'ORDER_CANCELLED':
        await this.handleOrderCancelled(event as OrderCancelledEvent);
        break;
    }
  }

  private async handleOrderPlaced(event: OrderPlacedEvent): Promise<void> {
    // 병렬 처리
    await Promise.all([
      this.emailService.sendOrderConfirmation(event.customerId, event.aggregateId),
      this.inventoryService.reserveItems(event.items),
      this.analyticsService.trackOrder(event),
    ]);
  }

  private async handleOrderShipped(event: OrderShippedEvent): Promise<void> {
    await this.emailService.sendShippingNotification(
      event.aggregateId,
      event.trackingNumber
    );
  }
}
```

## Saga Pattern

```typescript
// application/sagas/OrderSaga.ts
export class OrderSaga {
  private steps: SagaStep[] = [];

  constructor(
    private readonly orderService: OrderService,
    private readonly paymentService: PaymentService,
    private readonly inventoryService: InventoryService,
    private readonly eventPublisher: KafkaEventPublisher
  ) {}

  async execute(command: PlaceOrderCommand): Promise<string> {
    const sagaId = crypto.randomUUID();
    const compensations: Array<() => Promise<void>> = [];

    try {
      // Step 1: Create Order
      const order = await this.orderService.create(command);
      compensations.push(() => this.orderService.cancel(order.id));

      // Step 2: Reserve Inventory
      await this.inventoryService.reserve(order.id, command.items);
      compensations.push(() => this.inventoryService.release(order.id));

      // Step 3: Process Payment
      await this.paymentService.charge(order.id, command.totalAmount);
      compensations.push(() => this.paymentService.refund(order.id));

      // Step 4: Confirm Order
      await this.orderService.confirm(order.id);

      // Publish success event
      await this.eventPublisher.publish('order-events', new OrderCompletedEvent(
        order.id,
        order.version + 1
      ));

      return order.id;

    } catch (error) {
      // Compensate in reverse order
      for (const compensate of compensations.reverse()) {
        try {
          await compensate();
        } catch (compensationError) {
          console.error('Compensation failed:', compensationError);
          // Log for manual intervention
        }
      }

      // Publish failure event
      await this.eventPublisher.publish('order-events', new OrderFailedEvent(
        sagaId,
        error.message
      ));

      throw error;
    }
  }
}
```

## CQRS 통합

```typescript
// 읽기 모델 프로젝션
export class OrderProjection {
  constructor(private readonly readDb: Pool) {}

  async handle(event: DomainEvent): Promise<void> {
    switch (event.eventType) {
      case 'ORDER_PLACED':
        await this.createOrderView(event as OrderPlacedEvent);
        break;
      case 'ORDER_SHIPPED':
        await this.updateOrderStatus(event.aggregateId, 'SHIPPED');
        break;
    }
  }

  private async createOrderView(event: OrderPlacedEvent): Promise<void> {
    await this.readDb.query(
      `INSERT INTO order_views (id, customer_id, total_amount, status, created_at)
       VALUES ($1, $2, $3, $4, $5)`,
      [event.aggregateId, event.customerId, event.totalAmount, 'PENDING', event.occurredAt]
    );
  }

  private async updateOrderStatus(orderId: string, status: string): Promise<void> {
    await this.readDb.query(
      `UPDATE order_views SET status = $1, updated_at = NOW() WHERE id = $2`,
      [status, orderId]
    );
  }
}
```

## 체크리스트

- [ ] Domain Event 정의
- [ ] Event Store 구현
- [ ] Message Broker 설정 (Kafka/RabbitMQ)
- [ ] Event Handler 구현
- [ ] Saga 패턴 (분산 트랜잭션)
- [ ] 읽기 모델 프로젝션
- [ ] 멱등성 보장
- [ ] Dead Letter Queue
- [ ] 모니터링/추적

## 출력 형식

```
## Event-Driven Architecture

### Events
| Event | Aggregate | Trigger |
|-------|-----------|---------|
| OrderPlaced | Order | Create order |
| OrderShipped | Order | Ship order |

### Event Flow
```
Order Created → OrderPlacedEvent
    ├── EmailService: Send confirmation
    ├── InventoryService: Reserve items
    └── AnalyticsService: Track order
```

### Saga Steps
| Step | Service | Compensation |
|------|---------|--------------|
| 1 | Order | Cancel order |
| 2 | Inventory | Release items |
| 3 | Payment | Refund |
```

---

요청에 맞는 이벤트 기반 아키텍처를 설계하세요.
