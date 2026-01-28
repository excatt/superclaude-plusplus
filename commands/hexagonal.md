# Hexagonal Architecture Skill

헥사고날 아키텍처 (Ports & Adapters) 설계 가이드를 실행합니다.

## 핵심 개념

```
             ┌─────────────────────────────────────────┐
             │           Primary Adapters              │
             │     (Controllers, CLI, GraphQL)         │
             └────────────────┬────────────────────────┘
                              │
                              ▼
             ┌────────────────────────────────────────┐
             │         Primary Ports (Inbound)         │
             │           (Use Case Interfaces)         │
             └────────────────┬───────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Application Core                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Domain Layer                       │   │
│  │   Entities, Value Objects, Domain Services           │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Application Layer                    │   │
│  │        Use Cases, Application Services               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
             ┌────────────────────────────────────────┐
             │       Secondary Ports (Outbound)        │
             │    (Repository, Gateway Interfaces)     │
             └────────────────┬───────────────────────┘
                              │
                              ▼
             ┌────────────────────────────────────────┐
             │         Secondary Adapters             │
             │   (Database, External APIs, Queue)     │
             └────────────────────────────────────────┘
```

## 프로젝트 구조

```
src/
├── core/                          # Application Core (Framework 독립)
│   ├── domain/
│   │   ├── entities/
│   │   │   └── Order.ts
│   │   ├── value-objects/
│   │   │   └── Money.ts
│   │   ├── services/
│   │   │   └── PricingService.ts
│   │   └── events/
│   │       └── OrderEvents.ts
│   ├── application/
│   │   ├── ports/
│   │   │   ├── inbound/          # Primary Ports (Use Cases)
│   │   │   │   └── CreateOrderUseCase.ts
│   │   │   └── outbound/         # Secondary Ports
│   │   │       ├── OrderRepository.ts
│   │   │       └── PaymentGateway.ts
│   │   ├── services/
│   │   │   └── OrderApplicationService.ts
│   │   └── dto/
│   │       └── OrderDTO.ts
│   └── shared/
│       └── Result.ts
├── adapters/
│   ├── primary/                   # Driving Adapters
│   │   ├── http/
│   │   │   └── OrderController.ts
│   │   ├── graphql/
│   │   │   └── OrderResolver.ts
│   │   └── cli/
│   │       └── OrderCommand.ts
│   └── secondary/                 # Driven Adapters
│       ├── persistence/
│       │   └── PostgresOrderRepository.ts
│       ├── payment/
│       │   └── StripePaymentGateway.ts
│       └── messaging/
│           └── RabbitMQEventPublisher.ts
└── infrastructure/
    ├── config/
    ├── di/
    │   └── container.ts
    └── bootstrap.ts
```

## Domain Layer

### Entity
```typescript
// core/domain/entities/Order.ts
import { Entity } from '../shared/Entity';
import { Money } from '../value-objects/Money';
import { OrderItem } from './OrderItem';
import { OrderStatus, OrderStatusValue } from '../value-objects/OrderStatus';
import { OrderCreatedEvent, OrderConfirmedEvent } from '../events/OrderEvents';

export interface OrderProps {
  customerId: string;
  items: OrderItem[];
  status: OrderStatus;
  totalAmount: Money;
  createdAt: Date;
}

export class Order extends Entity<OrderProps> {
  private _domainEvents: DomainEvent[] = [];

  private constructor(props: OrderProps, id?: string) {
    super(props, id);
  }

  // Factory Method
  static create(customerId: string, items: OrderItem[]): Order {
    if (items.length === 0) {
      throw new DomainError('Order must have at least one item');
    }

    const totalAmount = items.reduce(
      (sum, item) => sum.add(item.subtotal),
      Money.zero('USD')
    );

    const order = new Order({
      customerId,
      items,
      status: OrderStatus.pending(),
      totalAmount,
      createdAt: new Date(),
    });

    order.addDomainEvent(new OrderCreatedEvent(order));

    return order;
  }

  // Reconstitute from persistence
  static reconstitute(props: OrderProps, id: string): Order {
    return new Order(props, id);
  }

  // Business Methods
  confirm(): void {
    if (!this.props.status.canTransitionTo('CONFIRMED')) {
      throw new DomainError('Cannot confirm order in current status');
    }
    this.props.status = OrderStatus.confirmed();
    this.addDomainEvent(new OrderConfirmedEvent(this));
  }

  addItem(item: OrderItem): void {
    if (this.props.status.value !== 'PENDING') {
      throw new DomainError('Cannot modify non-pending order');
    }
    this.props.items.push(item);
    this.recalculateTotal();
  }

  private recalculateTotal(): void {
    this.props.totalAmount = this.props.items.reduce(
      (sum, item) => sum.add(item.subtotal),
      Money.zero('USD')
    );
  }

  // Getters
  get customerId(): string { return this.props.customerId; }
  get items(): OrderItem[] { return [...this.props.items]; }
  get status(): OrderStatusValue { return this.props.status.value; }
  get totalAmount(): Money { return this.props.totalAmount; }
  get createdAt(): Date { return this.props.createdAt; }

  get domainEvents(): DomainEvent[] { return [...this._domainEvents]; }

  private addDomainEvent(event: DomainEvent): void {
    this._domainEvents.push(event);
  }

  clearDomainEvents(): void {
    this._domainEvents = [];
  }
}
```

### Value Object
```typescript
// core/domain/value-objects/Money.ts
export class Money {
  private constructor(
    private readonly amount: number,
    private readonly currency: string
  ) {
    if (amount < 0) {
      throw new DomainError('Amount cannot be negative');
    }
  }

  static create(amount: number, currency: string): Money {
    return new Money(amount, currency);
  }

  static zero(currency: string): Money {
    return new Money(0, currency);
  }

  add(other: Money): Money {
    this.ensureSameCurrency(other);
    return new Money(this.amount + other.amount, this.currency);
  }

  subtract(other: Money): Money {
    this.ensureSameCurrency(other);
    return new Money(this.amount - other.amount, this.currency);
  }

  multiply(factor: number): Money {
    return new Money(this.amount * factor, this.currency);
  }

  private ensureSameCurrency(other: Money): void {
    if (this.currency !== other.currency) {
      throw new DomainError('Cannot operate on different currencies');
    }
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }

  getAmount(): number { return this.amount; }
  getCurrency(): string { return this.currency; }
}
```

## Application Layer (Ports)

### Primary Port (Inbound - Use Case Interface)
```typescript
// core/application/ports/inbound/CreateOrderUseCase.ts
export interface CreateOrderCommand {
  customerId: string;
  items: Array<{
    productId: string;
    quantity: number;
  }>;
}

export interface CreateOrderResult {
  orderId: string;
  totalAmount: number;
  currency: string;
}

export interface CreateOrderUseCase {
  execute(command: CreateOrderCommand): Promise<Result<CreateOrderResult>>;
}

// core/application/ports/inbound/GetOrderUseCase.ts
export interface GetOrderQuery {
  orderId: string;
}

export interface GetOrderResult {
  orderId: string;
  customerId: string;
  items: Array<{
    productId: string;
    productName: string;
    quantity: number;
    unitPrice: number;
  }>;
  totalAmount: number;
  status: string;
  createdAt: Date;
}

export interface GetOrderUseCase {
  execute(query: GetOrderQuery): Promise<Result<GetOrderResult>>;
}
```

### Secondary Port (Outbound - Repository/Gateway Interface)
```typescript
// core/application/ports/outbound/OrderRepository.ts
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
  findByCustomerId(customerId: string): Promise<Order[]>;
  save(order: Order): Promise<void>;
  delete(id: string): Promise<void>;
}

// core/application/ports/outbound/ProductCatalog.ts
export interface ProductInfo {
  id: string;
  name: string;
  price: Money;
  available: boolean;
}

export interface ProductCatalog {
  findById(productId: string): Promise<ProductInfo | null>;
  checkAvailability(productId: string, quantity: number): Promise<boolean>;
}

// core/application/ports/outbound/PaymentGateway.ts
export interface PaymentResult {
  transactionId: string;
  status: 'SUCCESS' | 'FAILED';
  errorMessage?: string;
}

export interface PaymentGateway {
  charge(orderId: string, amount: Money): Promise<PaymentResult>;
  refund(transactionId: string): Promise<PaymentResult>;
}

// core/application/ports/outbound/EventPublisher.ts
export interface EventPublisher {
  publish(event: DomainEvent): Promise<void>;
  publishAll(events: DomainEvent[]): Promise<void>;
}
```

### Application Service (Use Case Implementation)
```typescript
// core/application/services/OrderApplicationService.ts
export class OrderApplicationService implements CreateOrderUseCase, GetOrderUseCase {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly productCatalog: ProductCatalog,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: CreateOrderCommand): Promise<Result<CreateOrderResult>> {
    try {
      // 1. 제품 정보 조회 및 검증
      const orderItems: OrderItem[] = [];

      for (const item of command.items) {
        const product = await this.productCatalog.findById(item.productId);

        if (!product) {
          return Result.fail(`Product ${item.productId} not found`);
        }

        if (!await this.productCatalog.checkAvailability(item.productId, item.quantity)) {
          return Result.fail(`Product ${item.productId} is not available`);
        }

        orderItems.push(OrderItem.create({
          productId: product.id,
          productName: product.name,
          quantity: item.quantity,
          unitPrice: product.price,
        }));
      }

      // 2. 도메인 객체 생성
      const order = Order.create(command.customerId, orderItems);

      // 3. 저장
      await this.orderRepository.save(order);

      // 4. 도메인 이벤트 발행
      await this.eventPublisher.publishAll(order.domainEvents);
      order.clearDomainEvents();

      // 5. 결과 반환
      return Result.ok({
        orderId: order.id,
        totalAmount: order.totalAmount.getAmount(),
        currency: order.totalAmount.getCurrency(),
      });

    } catch (error) {
      return Result.fail(error.message);
    }
  }
}
```

## Adapters

### Primary Adapter (HTTP Controller)
```typescript
// adapters/primary/http/OrderController.ts
export class OrderController {
  constructor(
    private readonly createOrderUseCase: CreateOrderUseCase,
    private readonly getOrderUseCase: GetOrderUseCase
  ) {}

  async createOrder(req: Request, res: Response): Promise<void> {
    const command: CreateOrderCommand = {
      customerId: req.body.customerId,
      items: req.body.items,
    };

    const result = await this.createOrderUseCase.execute(command);

    if (result.isFailure) {
      res.status(400).json({ error: result.error });
      return;
    }

    res.status(201).json(result.value);
  }

  async getOrder(req: Request, res: Response): Promise<void> {
    const query: GetOrderQuery = {
      orderId: req.params.orderId,
    };

    const result = await this.getOrderUseCase.execute(query);

    if (result.isFailure) {
      res.status(404).json({ error: result.error });
      return;
    }

    res.json(result.value);
  }
}
```

### Primary Adapter (GraphQL Resolver)
```typescript
// adapters/primary/graphql/OrderResolver.ts
@Resolver()
export class OrderResolver {
  constructor(
    private readonly createOrderUseCase: CreateOrderUseCase,
    private readonly getOrderUseCase: GetOrderUseCase
  ) {}

  @Mutation(() => CreateOrderResult)
  async createOrder(
    @Arg('input') input: CreateOrderInput
  ): Promise<CreateOrderResult> {
    const result = await this.createOrderUseCase.execute(input);

    if (result.isFailure) {
      throw new UserInputError(result.error);
    }

    return result.value;
  }

  @Query(() => OrderResult)
  async order(@Arg('id') id: string): Promise<OrderResult> {
    const result = await this.getOrderUseCase.execute({ orderId: id });

    if (result.isFailure) {
      throw new ApolloError(result.error, 'NOT_FOUND');
    }

    return result.value;
  }
}
```

### Secondary Adapter (Repository)
```typescript
// adapters/secondary/persistence/PostgresOrderRepository.ts
export class PostgresOrderRepository implements OrderRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findById(id: string): Promise<Order | null> {
    const data = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true },
    });

    if (!data) return null;

    return Order.reconstitute(
      {
        customerId: data.customerId,
        items: data.items.map(item => OrderItem.reconstitute({
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: Money.create(item.unitPrice, item.currency),
        }, item.id)),
        status: OrderStatus.fromValue(data.status),
        totalAmount: Money.create(data.totalAmount, data.currency),
        createdAt: data.createdAt,
      },
      data.id
    );
  }

  async save(order: Order): Promise<void> {
    await this.prisma.order.upsert({
      where: { id: order.id },
      create: {
        id: order.id,
        customerId: order.customerId,
        status: order.status,
        totalAmount: order.totalAmount.getAmount(),
        currency: order.totalAmount.getCurrency(),
        createdAt: order.createdAt,
        items: {
          create: order.items.map(item => ({
            id: item.id,
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice.getAmount(),
            currency: item.unitPrice.getCurrency(),
          })),
        },
      },
      update: {
        status: order.status,
        totalAmount: order.totalAmount.getAmount(),
      },
    });
  }
}
```

### Secondary Adapter (External Service)
```typescript
// adapters/secondary/payment/StripePaymentGateway.ts
import Stripe from 'stripe';

export class StripePaymentGateway implements PaymentGateway {
  private stripe: Stripe;

  constructor(apiKey: string) {
    this.stripe = new Stripe(apiKey);
  }

  async charge(orderId: string, amount: Money): Promise<PaymentResult> {
    try {
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: amount.getAmount() * 100, // Convert to cents
        currency: amount.getCurrency().toLowerCase(),
        metadata: { orderId },
      });

      return {
        transactionId: paymentIntent.id,
        status: 'SUCCESS',
      };
    } catch (error) {
      return {
        transactionId: '',
        status: 'FAILED',
        errorMessage: error.message,
      };
    }
  }

  async refund(transactionId: string): Promise<PaymentResult> {
    try {
      const refund = await this.stripe.refunds.create({
        payment_intent: transactionId,
      });

      return {
        transactionId: refund.id,
        status: 'SUCCESS',
      };
    } catch (error) {
      return {
        transactionId: '',
        status: 'FAILED',
        errorMessage: error.message,
      };
    }
  }
}
```

## Dependency Injection

```typescript
// infrastructure/di/container.ts
import { Container } from 'inversify';

const container = new Container();

// Secondary Adapters (Outbound)
container.bind<OrderRepository>('OrderRepository')
  .to(PostgresOrderRepository).inSingletonScope();

container.bind<ProductCatalog>('ProductCatalog')
  .to(ApiProductCatalog).inSingletonScope();

container.bind<PaymentGateway>('PaymentGateway')
  .to(StripePaymentGateway).inSingletonScope();

container.bind<EventPublisher>('EventPublisher')
  .to(RabbitMQEventPublisher).inSingletonScope();

// Application Services (Use Cases)
container.bind<CreateOrderUseCase>('CreateOrderUseCase')
  .to(OrderApplicationService).inRequestScope();

container.bind<GetOrderUseCase>('GetOrderUseCase')
  .to(OrderApplicationService).inRequestScope();

// Primary Adapters (Inbound)
container.bind<OrderController>('OrderController')
  .to(OrderController).inRequestScope();

export { container };
```

## 체크리스트

- [ ] Domain Layer (Entities, Value Objects)
- [ ] Primary Ports (Use Case Interfaces)
- [ ] Secondary Ports (Repository/Gateway Interfaces)
- [ ] Application Services (Use Case Implementations)
- [ ] Primary Adapters (Controllers, Resolvers)
- [ ] Secondary Adapters (Repositories, Gateways)
- [ ] Dependency Injection 설정
- [ ] 도메인 이벤트 발행
- [ ] 테스트 (Port Mock)

## 출력 형식

```
## Hexagonal Architecture

### Ports
| Type | Port | Adapters |
|------|------|----------|
| Primary | CreateOrderUseCase | HTTP, GraphQL |
| Secondary | OrderRepository | PostgreSQL |
| Secondary | PaymentGateway | Stripe |

### Dependency Flow
```
Controller → UseCase Interface → Application Service
                                        ↓
                              Repository Interface → PostgresAdapter
                              Gateway Interface → StripeAdapter
```

### Core Domain
- Entities: Order, OrderItem
- Value Objects: Money, OrderStatus
- Domain Events: OrderCreated, OrderConfirmed
```

---

요청에 맞는 헥사고날 아키텍처를 설계하세요.
