# DDD Skill

Domain-Driven Design 패턴 가이드를 실행합니다.

## DDD 핵심 개념

```
Strategic Design (전략적 설계)
├── Bounded Context: 도메인 경계
├── Ubiquitous Language: 공통 언어
├── Context Map: 컨텍스트 관계
└── Subdomain: 핵심/지원/일반

Tactical Design (전술적 설계)
├── Entity: 식별자로 구분되는 객체
├── Value Object: 값으로 동등성 판단
├── Aggregate: 일관성 경계
├── Repository: 영속성 추상화
├── Domain Service: 도메인 로직
├── Domain Event: 도메인 이벤트
└── Factory: 객체 생성 캡슐화
```

## 프로젝트 구조

```
src/
├── domain/                 # 도메인 레이어 (핵심)
│   ├── order/
│   │   ├── Order.ts           # Aggregate Root
│   │   ├── OrderItem.ts       # Entity
│   │   ├── Money.ts           # Value Object
│   │   ├── OrderStatus.ts     # Value Object
│   │   ├── OrderRepository.ts # Repository Interface
│   │   ├── OrderService.ts    # Domain Service
│   │   └── events/            # Domain Events
│   │       ├── OrderCreated.ts
│   │       └── OrderShipped.ts
│   └── shared/
│       ├── Entity.ts
│       ├── ValueObject.ts
│       └── AggregateRoot.ts
├── application/            # 애플리케이션 레이어
│   ├── commands/
│   │   └── CreateOrderCommand.ts
│   ├── queries/
│   │   └── GetOrderQuery.ts
│   └── handlers/
│       └── CreateOrderHandler.ts
├── infrastructure/         # 인프라 레이어
│   ├── persistence/
│   │   └── TypeOrmOrderRepository.ts
│   └── messaging/
│       └── RabbitMQEventPublisher.ts
└── presentation/           # 프레젠테이션 레이어
    └── api/
        └── OrderController.ts
```

## Entity & Value Object

### Base Classes
```typescript
// domain/shared/Entity.ts
export abstract class Entity<T> {
  protected readonly _id: T;

  constructor(id: T) {
    this._id = id;
  }

  get id(): T {
    return this._id;
  }

  equals(other: Entity<T>): boolean {
    if (other === null || other === undefined) return false;
    if (!(other instanceof Entity)) return false;
    return this._id === other._id;
  }
}

// domain/shared/ValueObject.ts
export abstract class ValueObject<T> {
  protected readonly props: T;

  constructor(props: T) {
    this.props = Object.freeze(props);
  }

  equals(other: ValueObject<T>): boolean {
    if (other === null || other === undefined) return false;
    return JSON.stringify(this.props) === JSON.stringify(other.props);
  }
}
```

### Value Object 예시
```typescript
// domain/order/Money.ts
interface MoneyProps {
  amount: number;
  currency: string;
}

export class Money extends ValueObject<MoneyProps> {
  private constructor(props: MoneyProps) {
    super(props);
  }

  static create(amount: number, currency: string): Money {
    if (amount < 0) {
      throw new Error('Amount cannot be negative');
    }
    return new Money({ amount, currency });
  }

  get amount(): number {
    return this.props.amount;
  }

  get currency(): string {
    return this.props.currency;
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error('Cannot add different currencies');
    }
    return Money.create(this.amount + other.amount, this.currency);
  }

  multiply(factor: number): Money {
    return Money.create(this.amount * factor, this.currency);
  }
}

// domain/order/OrderStatus.ts
export class OrderStatus extends ValueObject<{ value: string }> {
  private static readonly VALID_STATUSES = [
    'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'
  ] as const;

  private constructor(value: string) {
    super({ value });
  }

  static create(value: string): OrderStatus {
    if (!this.VALID_STATUSES.includes(value as any)) {
      throw new Error(`Invalid order status: ${value}`);
    }
    return new OrderStatus(value);
  }

  static pending(): OrderStatus {
    return new OrderStatus('PENDING');
  }

  get value(): string {
    return this.props.value;
  }

  canTransitionTo(newStatus: OrderStatus): boolean {
    const transitions: Record<string, string[]> = {
      PENDING: ['CONFIRMED', 'CANCELLED'],
      CONFIRMED: ['SHIPPED', 'CANCELLED'],
      SHIPPED: ['DELIVERED'],
      DELIVERED: [],
      CANCELLED: [],
    };
    return transitions[this.value]?.includes(newStatus.value) ?? false;
  }
}
```

## Aggregate

```typescript
// domain/shared/AggregateRoot.ts
import { Entity } from './Entity';

export abstract class AggregateRoot<T> extends Entity<T> {
  private _domainEvents: DomainEvent[] = [];

  get domainEvents(): DomainEvent[] {
    return [...this._domainEvents];
  }

  protected addDomainEvent(event: DomainEvent): void {
    this._domainEvents.push(event);
  }

  clearDomainEvents(): void {
    this._domainEvents = [];
  }
}

// domain/order/Order.ts
export class Order extends AggregateRoot<string> {
  private _customerId: string;
  private _items: OrderItem[];
  private _status: OrderStatus;
  private _totalAmount: Money;
  private _createdAt: Date;

  private constructor(
    id: string,
    customerId: string,
    items: OrderItem[],
    status: OrderStatus,
    totalAmount: Money
  ) {
    super(id);
    this._customerId = customerId;
    this._items = items;
    this._status = status;
    this._totalAmount = totalAmount;
    this._createdAt = new Date();
  }

  // Factory Method
  static create(customerId: string, items: CreateOrderItemDTO[]): Order {
    if (items.length === 0) {
      throw new Error('Order must have at least one item');
    }

    const orderItems = items.map(item =>
      OrderItem.create(item.productId, item.quantity, item.unitPrice)
    );

    const totalAmount = orderItems.reduce(
      (sum, item) => sum.add(item.subtotal),
      Money.create(0, 'KRW')
    );

    const order = new Order(
      generateId(),
      customerId,
      orderItems,
      OrderStatus.pending(),
      totalAmount
    );

    order.addDomainEvent(new OrderCreatedEvent(order));
    return order;
  }

  // Business Methods
  confirm(): void {
    if (!this._status.canTransitionTo(OrderStatus.create('CONFIRMED'))) {
      throw new Error('Cannot confirm order in current status');
    }
    this._status = OrderStatus.create('CONFIRMED');
    this.addDomainEvent(new OrderConfirmedEvent(this));
  }

  ship(): void {
    if (!this._status.canTransitionTo(OrderStatus.create('SHIPPED'))) {
      throw new Error('Cannot ship order in current status');
    }
    this._status = OrderStatus.create('SHIPPED');
    this.addDomainEvent(new OrderShippedEvent(this));
  }

  cancel(): void {
    if (!this._status.canTransitionTo(OrderStatus.create('CANCELLED'))) {
      throw new Error('Cannot cancel order in current status');
    }
    this._status = OrderStatus.create('CANCELLED');
    this.addDomainEvent(new OrderCancelledEvent(this));
  }

  addItem(productId: string, quantity: number, unitPrice: Money): void {
    if (this._status.value !== 'PENDING') {
      throw new Error('Cannot modify confirmed order');
    }
    const newItem = OrderItem.create(productId, quantity, unitPrice);
    this._items.push(newItem);
    this._totalAmount = this._totalAmount.add(newItem.subtotal);
  }

  // Getters
  get customerId(): string { return this._customerId; }
  get items(): OrderItem[] { return [...this._items]; }
  get status(): OrderStatus { return this._status; }
  get totalAmount(): Money { return this._totalAmount; }
}
```

## Repository

```typescript
// domain/order/OrderRepository.ts (Interface)
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
  findByCustomerId(customerId: string): Promise<Order[]>;
  save(order: Order): Promise<void>;
  delete(id: string): Promise<void>;
}

// infrastructure/persistence/TypeOrmOrderRepository.ts
export class TypeOrmOrderRepository implements OrderRepository {
  constructor(
    private readonly dataSource: DataSource,
    private readonly eventPublisher: EventPublisher
  ) {}

  async findById(id: string): Promise<Order | null> {
    const data = await this.dataSource
      .getRepository(OrderEntity)
      .findOne({
        where: { id },
        relations: ['items'],
      });

    return data ? this.toDomain(data) : null;
  }

  async save(order: Order): Promise<void> {
    const entity = this.toEntity(order);
    await this.dataSource.getRepository(OrderEntity).save(entity);

    // Domain Events 발행
    for (const event of order.domainEvents) {
      await this.eventPublisher.publish(event);
    }
    order.clearDomainEvents();
  }

  private toDomain(entity: OrderEntity): Order {
    // Entity -> Domain Object 매핑
  }

  private toEntity(domain: Order): OrderEntity {
    // Domain Object -> Entity 매핑
  }
}
```

## Domain Service

```typescript
// domain/order/OrderService.ts
export class OrderPricingService {
  constructor(
    private readonly discountPolicy: DiscountPolicy,
    private readonly taxCalculator: TaxCalculator
  ) {}

  calculateFinalPrice(order: Order, customer: Customer): Money {
    const subtotal = order.totalAmount;

    // 할인 적용
    const discount = this.discountPolicy.calculate(order, customer);
    const afterDiscount = subtotal.subtract(discount);

    // 세금 계산
    const tax = this.taxCalculator.calculate(afterDiscount);

    return afterDiscount.add(tax);
  }
}
```

## Domain Event

```typescript
// domain/order/events/OrderCreated.ts
export class OrderCreatedEvent implements DomainEvent {
  readonly occurredOn: Date;
  readonly orderId: string;
  readonly customerId: string;
  readonly totalAmount: number;

  constructor(order: Order) {
    this.occurredOn = new Date();
    this.orderId = order.id;
    this.customerId = order.customerId;
    this.totalAmount = order.totalAmount.amount;
  }

  get eventName(): string {
    return 'order.created';
  }
}

// Application Layer에서 핸들링
@EventHandler(OrderCreatedEvent)
export class SendOrderConfirmationHandler {
  constructor(private readonly emailService: EmailService) {}

  async handle(event: OrderCreatedEvent): Promise<void> {
    await this.emailService.sendOrderConfirmation(
      event.customerId,
      event.orderId
    );
  }
}
```

## Application Layer (Use Case)

```typescript
// application/commands/CreateOrderCommand.ts
export class CreateOrderCommand {
  constructor(
    public readonly customerId: string,
    public readonly items: CreateOrderItemDTO[]
  ) {}
}

// application/handlers/CreateOrderHandler.ts
export class CreateOrderHandler {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly customerRepository: CustomerRepository
  ) {}

  async execute(command: CreateOrderCommand): Promise<string> {
    // 고객 존재 확인
    const customer = await this.customerRepository.findById(command.customerId);
    if (!customer) {
      throw new CustomerNotFoundError(command.customerId);
    }

    // 도메인 객체 생성 (비즈니스 규칙 검증)
    const order = Order.create(command.customerId, command.items);

    // 영속화
    await this.orderRepository.save(order);

    return order.id;
  }
}
```

## Context Map

```
┌─────────────────┐    Partnership    ┌─────────────────┐
│  Order Context  │◄─────────────────►│ Inventory Context│
└────────┬────────┘                   └─────────────────┘
         │
         │ Customer/Supplier
         ▼
┌─────────────────┐    Conformist     ┌─────────────────┐
│ Payment Context │─────────────────►│ External Payment │
└─────────────────┘                   │    (Stripe)     │
                                      └─────────────────┘
```

## 체크리스트

- [ ] Bounded Context 정의
- [ ] Ubiquitous Language 문서화
- [ ] Aggregate 경계 설정
- [ ] Entity vs Value Object 구분
- [ ] Repository 인터페이스 정의
- [ ] Domain Event 설계
- [ ] Application Service 작성
- [ ] 레이어 의존성 방향 확인

## 출력 형식

```
## DDD Design

### Bounded Contexts
| Context | Responsibility | Core Domain? |
|---------|---------------|--------------|
| Order | 주문 관리 | Yes |
| Inventory | 재고 관리 | No |

### Aggregates
| Aggregate | Root Entity | Entities | Value Objects |
|-----------|-------------|----------|---------------|
| Order | Order | OrderItem | Money, Status |

### Domain Events
| Event | Publisher | Subscribers |
|-------|-----------|-------------|
| OrderCreated | Order | Email, Inventory |

### Code Structure
```typescript
// 핵심 도메인 코드
```
```

---

요청에 맞는 DDD 설계를 수행하세요.
