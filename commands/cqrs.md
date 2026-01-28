# CQRS Skill

CQRS (Command Query Responsibility Segregation) 패턴 가이드를 실행합니다.

## 핵심 개념

```
┌────────────────────────────────────────────────────────────┐
│                        Client                              │
└────────────────────────┬───────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
┌─────────────────┐            ┌─────────────────┐
│    Commands     │            │     Queries     │
│  (Write Model)  │            │  (Read Model)   │
└────────┬────────┘            └────────┬────────┘
         │                               │
         ▼                               ▼
┌─────────────────┐            ┌─────────────────┐
│  Command Bus    │            │   Query Bus     │
│   Validation    │            │    Caching      │
└────────┬────────┘            └────────┬────────┘
         │                               │
         ▼                               ▼
┌─────────────────┐   Events   ┌─────────────────┐
│  Write Database │───────────►│  Read Database  │
│   (PostgreSQL)  │            │ (Redis/Elastic) │
└─────────────────┘            └─────────────────┘
```

## 프로젝트 구조

```
src/
├── domain/
│   ├── aggregates/
│   │   └── Order.ts
│   └── events/
│       └── OrderEvents.ts
├── application/
│   ├── commands/
│   │   ├── CreateOrderCommand.ts
│   │   └── handlers/
│   │       └── CreateOrderHandler.ts
│   ├── queries/
│   │   ├── GetOrderQuery.ts
│   │   └── handlers/
│   │       └── GetOrderHandler.ts
│   └── projections/
│       └── OrderProjection.ts
├── infrastructure/
│   ├── bus/
│   │   ├── CommandBus.ts
│   │   └── QueryBus.ts
│   ├── persistence/
│   │   ├── WriteRepository.ts
│   │   └── ReadRepository.ts
│   └── projectors/
│       └── OrderProjector.ts
└── api/
    └── controllers/
        └── OrderController.ts
```

## Command (쓰기)

### Command 정의
```typescript
// application/commands/CreateOrderCommand.ts
export interface Command {
  readonly type: string;
}

export class CreateOrderCommand implements Command {
  readonly type = 'CreateOrder';

  constructor(
    public readonly customerId: string,
    public readonly items: Array<{
      productId: string;
      quantity: number;
      unitPrice: number;
    }>,
    public readonly shippingAddress: Address
  ) {}
}

// application/commands/CancelOrderCommand.ts
export class CancelOrderCommand implements Command {
  readonly type = 'CancelOrder';

  constructor(
    public readonly orderId: string,
    public readonly reason: string
  ) {}
}
```

### Command Handler
```typescript
// application/commands/handlers/CreateOrderHandler.ts
export interface CommandHandler<T extends Command> {
  handle(command: T): Promise<void>;
}

export class CreateOrderHandler implements CommandHandler<CreateOrderCommand> {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async handle(command: CreateOrderCommand): Promise<void> {
    // 비즈니스 규칙 검증
    this.validateOrder(command);

    // Aggregate 생성
    const order = Order.create({
      customerId: command.customerId,
      items: command.items.map(item => OrderItem.create(item)),
      shippingAddress: command.shippingAddress,
    });

    // 저장
    await this.orderRepository.save(order);

    // 이벤트 발행 (읽기 모델 업데이트 트리거)
    const events = order.getUncommittedEvents();
    for (const event of events) {
      await this.eventPublisher.publish(event);
    }
    order.clearUncommittedEvents();
  }

  private validateOrder(command: CreateOrderCommand): void {
    if (command.items.length === 0) {
      throw new ValidationError('Order must have at least one item');
    }
    // 추가 검증...
  }
}
```

### Command Bus
```typescript
// infrastructure/bus/CommandBus.ts
export interface CommandBus {
  dispatch<T extends Command>(command: T): Promise<void>;
  register<T extends Command>(
    commandType: string,
    handler: CommandHandler<T>
  ): void;
}

export class InMemoryCommandBus implements CommandBus {
  private handlers = new Map<string, CommandHandler<any>>();

  register<T extends Command>(
    commandType: string,
    handler: CommandHandler<T>
  ): void {
    this.handlers.set(commandType, handler);
  }

  async dispatch<T extends Command>(command: T): Promise<void> {
    const handler = this.handlers.get(command.type);

    if (!handler) {
      throw new Error(`No handler registered for command: ${command.type}`);
    }

    await handler.handle(command);
  }
}

// 미들웨어 지원 버전
export class CommandBusWithMiddleware implements CommandBus {
  private handlers = new Map<string, CommandHandler<any>>();
  private middlewares: Middleware[] = [];

  use(middleware: Middleware): void {
    this.middlewares.push(middleware);
  }

  async dispatch<T extends Command>(command: T): Promise<void> {
    const handler = this.handlers.get(command.type);

    if (!handler) {
      throw new Error(`No handler registered for command: ${command.type}`);
    }

    // 미들웨어 체인 실행
    const chain = this.middlewares.reduceRight(
      (next, middleware) => () => middleware.execute(command, next),
      () => handler.handle(command)
    );

    await chain();
  }
}

// 미들웨어 예시
export class LoggingMiddleware implements Middleware {
  async execute(command: Command, next: () => Promise<void>): Promise<void> {
    console.log(`Executing command: ${command.type}`);
    const start = Date.now();

    await next();

    console.log(`Command ${command.type} executed in ${Date.now() - start}ms`);
  }
}

export class ValidationMiddleware implements Middleware {
  async execute(command: Command, next: () => Promise<void>): Promise<void> {
    await this.validate(command);
    await next();
  }
}
```

## Query (읽기)

### Query 정의
```typescript
// application/queries/GetOrderQuery.ts
export interface Query<TResult> {
  readonly type: string;
}

export class GetOrderQuery implements Query<OrderView> {
  readonly type = 'GetOrder';

  constructor(public readonly orderId: string) {}
}

export class GetOrdersQuery implements Query<OrderView[]> {
  readonly type = 'GetOrders';

  constructor(
    public readonly customerId?: string,
    public readonly status?: string,
    public readonly page: number = 1,
    public readonly limit: number = 20
  ) {}
}

// Read Model (View)
export interface OrderView {
  id: string;
  customerId: string;
  customerName: string;
  items: Array<{
    productId: string;
    productName: string;
    quantity: number;
    unitPrice: number;
    subtotal: number;
  }>;
  totalAmount: number;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}
```

### Query Handler
```typescript
// application/queries/handlers/GetOrderHandler.ts
export interface QueryHandler<T extends Query<TResult>, TResult> {
  handle(query: T): Promise<TResult>;
}

export class GetOrderHandler implements QueryHandler<GetOrderQuery, OrderView> {
  constructor(
    private readonly readRepository: OrderReadRepository,
    private readonly cache: Cache
  ) {}

  async handle(query: GetOrderQuery): Promise<OrderView> {
    // 캐시 확인
    const cacheKey = `order:${query.orderId}`;
    const cached = await this.cache.get<OrderView>(cacheKey);

    if (cached) {
      return cached;
    }

    // 읽기 DB에서 조회
    const order = await this.readRepository.findById(query.orderId);

    if (!order) {
      throw new NotFoundError(`Order ${query.orderId} not found`);
    }

    // 캐시 저장
    await this.cache.set(cacheKey, order, { ttl: 300 });

    return order;
  }
}

export class GetOrdersHandler implements QueryHandler<GetOrdersQuery, OrderView[]> {
  constructor(private readonly readRepository: OrderReadRepository) {}

  async handle(query: GetOrdersQuery): Promise<OrderView[]> {
    return this.readRepository.findAll({
      customerId: query.customerId,
      status: query.status,
      skip: (query.page - 1) * query.limit,
      take: query.limit,
    });
  }
}
```

### Query Bus
```typescript
// infrastructure/bus/QueryBus.ts
export interface QueryBus {
  execute<TResult>(query: Query<TResult>): Promise<TResult>;
  register<T extends Query<TResult>, TResult>(
    queryType: string,
    handler: QueryHandler<T, TResult>
  ): void;
}

export class InMemoryQueryBus implements QueryBus {
  private handlers = new Map<string, QueryHandler<any, any>>();

  register<T extends Query<TResult>, TResult>(
    queryType: string,
    handler: QueryHandler<T, TResult>
  ): void {
    this.handlers.set(queryType, handler);
  }

  async execute<TResult>(query: Query<TResult>): Promise<TResult> {
    const handler = this.handlers.get(query.type);

    if (!handler) {
      throw new Error(`No handler registered for query: ${query.type}`);
    }

    return handler.handle(query);
  }
}
```

## Projection (읽기 모델 업데이트)

```typescript
// application/projections/OrderProjection.ts
export class OrderProjection {
  constructor(private readonly readDb: ReadDatabase) {}

  // Event Handler로 호출됨
  async apply(event: DomainEvent): Promise<void> {
    switch (event.type) {
      case 'OrderCreated':
        await this.handleOrderCreated(event as OrderCreatedEvent);
        break;
      case 'OrderItemAdded':
        await this.handleOrderItemAdded(event as OrderItemAddedEvent);
        break;
      case 'OrderStatusChanged':
        await this.handleOrderStatusChanged(event as OrderStatusChangedEvent);
        break;
    }
  }

  private async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    await this.readDb.orders.insert({
      id: event.orderId,
      customerId: event.customerId,
      customerName: await this.getCustomerName(event.customerId),
      items: [],
      totalAmount: 0,
      status: 'PENDING',
      createdAt: event.occurredAt,
      updatedAt: event.occurredAt,
    });
  }

  private async handleOrderItemAdded(event: OrderItemAddedEvent): Promise<void> {
    const product = await this.getProduct(event.productId);

    await this.readDb.orders.update(
      { id: event.orderId },
      {
        $push: {
          items: {
            productId: event.productId,
            productName: product.name,
            quantity: event.quantity,
            unitPrice: event.unitPrice,
            subtotal: event.quantity * event.unitPrice,
          },
        },
        $inc: { totalAmount: event.quantity * event.unitPrice },
        $set: { updatedAt: event.occurredAt },
      }
    );
  }

  private async handleOrderStatusChanged(event: OrderStatusChangedEvent): Promise<void> {
    await this.readDb.orders.update(
      { id: event.orderId },
      {
        $set: {
          status: event.newStatus,
          updatedAt: event.occurredAt,
        },
      }
    );

    // 캐시 무효화
    await this.cache.delete(`order:${event.orderId}`);
  }
}
```

## API Controller

```typescript
// api/controllers/OrderController.ts
export class OrderController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus
  ) {}

  // Command (POST/PUT/DELETE)
  async createOrder(req: Request, res: Response): Promise<void> {
    const command = new CreateOrderCommand(
      req.body.customerId,
      req.body.items,
      req.body.shippingAddress
    );

    await this.commandBus.dispatch(command);

    res.status(202).json({ message: 'Order creation accepted' });
  }

  async cancelOrder(req: Request, res: Response): Promise<void> {
    const command = new CancelOrderCommand(
      req.params.orderId,
      req.body.reason
    );

    await this.commandBus.dispatch(command);

    res.status(202).json({ message: 'Order cancellation accepted' });
  }

  // Query (GET)
  async getOrder(req: Request, res: Response): Promise<void> {
    const query = new GetOrderQuery(req.params.orderId);
    const order = await this.queryBus.execute(query);

    res.json(order);
  }

  async getOrders(req: Request, res: Response): Promise<void> {
    const query = new GetOrdersQuery(
      req.query.customerId as string,
      req.query.status as string,
      Number(req.query.page) || 1,
      Number(req.query.limit) || 20
    );

    const orders = await this.queryBus.execute(query);

    res.json(orders);
  }
}
```

## 읽기/쓰기 저장소 분리

```typescript
// infrastructure/persistence/WriteRepository.ts
export class OrderWriteRepository {
  constructor(private readonly db: PostgresClient) {}

  async save(order: Order): Promise<void> {
    await this.db.transaction(async (trx) => {
      await trx.query(
        `INSERT INTO orders (id, customer_id, status, created_at)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (id) DO UPDATE SET status = $3`,
        [order.id, order.customerId, order.status, order.createdAt]
      );

      for (const item of order.items) {
        await trx.query(
          `INSERT INTO order_items (order_id, product_id, quantity, unit_price)
           VALUES ($1, $2, $3, $4)`,
          [order.id, item.productId, item.quantity, item.unitPrice]
        );
      }
    });
  }

  async findById(id: string): Promise<Order | null> {
    const result = await this.db.query(
      `SELECT * FROM orders WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) return null;

    return this.mapToAggregate(result.rows[0]);
  }
}

// infrastructure/persistence/ReadRepository.ts
export class OrderReadRepository {
  constructor(private readonly db: MongoClient) {}

  async findById(id: string): Promise<OrderView | null> {
    return this.db.collection('order_views').findOne({ id });
  }

  async findAll(filter: OrderFilter): Promise<OrderView[]> {
    const query: any = {};

    if (filter.customerId) query.customerId = filter.customerId;
    if (filter.status) query.status = filter.status;

    return this.db
      .collection('order_views')
      .find(query)
      .skip(filter.skip)
      .limit(filter.take)
      .toArray();
  }
}
```

## Event Synchronization

```typescript
// infrastructure/projectors/EventSynchronizer.ts
export class EventSynchronizer {
  constructor(
    private readonly eventConsumer: EventConsumer,
    private readonly projections: Projection[]
  ) {}

  async start(): Promise<void> {
    await this.eventConsumer.subscribe(
      ['orders', 'customers', 'products'],
      async (event: DomainEvent) => {
        for (const projection of this.projections) {
          try {
            await projection.apply(event);
          } catch (error) {
            console.error(`Projection error: ${error.message}`);
            // Retry 또는 DLQ
          }
        }
      }
    );
  }
}
```

## 체크리스트

- [ ] Command/Query 분리
- [ ] Command Bus 구현
- [ ] Query Bus 구현
- [ ] Command Handler 작성
- [ ] Query Handler 작성
- [ ] Projection 구현
- [ ] 읽기/쓰기 저장소 분리
- [ ] 이벤트 동기화
- [ ] 캐싱 전략
- [ ] Eventual Consistency 처리

## 출력 형식

```
## CQRS Architecture

### Commands
| Command | Handler | Result |
|---------|---------|--------|
| CreateOrder | CreateOrderHandler | Async |
| CancelOrder | CancelOrderHandler | Async |

### Queries
| Query | Handler | Cache |
|-------|---------|-------|
| GetOrder | GetOrderHandler | 5min |
| GetOrders | GetOrdersHandler | No |

### Data Flow
```
Command → CommandBus → Handler → WriteDB → Event → Projection → ReadDB
Query → QueryBus → Handler → Cache/ReadDB → Response
```
```

---

요청에 맞는 CQRS 아키텍처를 설계하세요.
