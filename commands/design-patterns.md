# Design Patterns Skill

GoF 디자인 패턴 및 활용 가이드를 실행합니다.

## 생성 패턴 (Creational)

### Singleton
```typescript
// 인스턴스가 하나만 존재
class Database {
  private static instance: Database;
  private constructor() {}

  static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
  }
}

// 사용 시점: 전역 상태, 설정, 연결 풀
```

### Factory Method
```typescript
// 객체 생성을 서브클래스에 위임
interface Product { operation(): string; }

abstract class Creator {
  abstract createProduct(): Product;

  someOperation(): string {
    const product = this.createProduct();
    return product.operation();
  }
}

// 사용 시점: 객체 타입이 런타임에 결정될 때
```

### Builder
```typescript
// 복잡한 객체를 단계별로 생성
class QueryBuilder {
  private query: Query = new Query();

  select(fields: string[]): this { /* ... */ return this; }
  from(table: string): this { /* ... */ return this; }
  where(condition: string): this { /* ... */ return this; }
  build(): Query { return this.query; }
}

// 사용
const query = new QueryBuilder()
  .select(['name', 'email'])
  .from('users')
  .where('active = true')
  .build();

// 사용 시점: 생성자 파라미터가 많을 때, 선택적 설정이 많을 때
```

## 구조 패턴 (Structural)

### Adapter
```typescript
// 호환되지 않는 인터페이스를 연결
interface Target { request(): string; }

class Adaptee {
  specificRequest(): string { return 'specific'; }
}

class Adapter implements Target {
  constructor(private adaptee: Adaptee) {}
  request(): string { return this.adaptee.specificRequest(); }
}

// 사용 시점: 레거시 코드 통합, 외부 라이브러리 래핑
```

### Decorator
```typescript
// 객체에 동적으로 기능 추가
interface Component { operation(): string; }

class ConcreteComponent implements Component {
  operation(): string { return 'Component'; }
}

class Decorator implements Component {
  constructor(protected component: Component) {}
  operation(): string { return this.component.operation(); }
}

class LoggingDecorator extends Decorator {
  operation(): string {
    console.log('Before');
    const result = super.operation();
    console.log('After');
    return result;
  }
}

// 사용 시점: 상속 없이 기능 확장, 조합 가능한 기능들
```

### Facade
```typescript
// 복잡한 서브시스템에 단순한 인터페이스 제공
class OrderFacade {
  constructor(
    private inventory: InventoryService,
    private payment: PaymentService,
    private shipping: ShippingService
  ) {}

  placeOrder(order: Order): Result {
    this.inventory.reserve(order.items);
    this.payment.process(order.payment);
    this.shipping.schedule(order.address);
    return { success: true };
  }
}

// 사용 시점: 복잡한 시스템 단순화, API 진입점
```

## 행동 패턴 (Behavioral)

### Strategy
```typescript
// 알고리즘을 캡슐화하여 교체 가능하게
interface PaymentStrategy {
  pay(amount: number): void;
}

class CreditCardPayment implements PaymentStrategy {
  pay(amount: number): void { /* 카드 결제 */ }
}

class PayPalPayment implements PaymentStrategy {
  pay(amount: number): void { /* PayPal 결제 */ }
}

class PaymentContext {
  constructor(private strategy: PaymentStrategy) {}
  executePayment(amount: number): void {
    this.strategy.pay(amount);
  }
}

// 사용 시점: 런타임에 알고리즘 선택, if-else 제거
```

### Observer
```typescript
// 상태 변경을 구독자에게 알림
interface Observer { update(data: any): void; }

class Subject {
  private observers: Observer[] = [];

  subscribe(observer: Observer): void {
    this.observers.push(observer);
  }

  notify(data: any): void {
    this.observers.forEach(o => o.update(data));
  }
}

// 사용 시점: 이벤트 시스템, 상태 동기화, 느슨한 결합
```

### Command
```typescript
// 요청을 객체로 캡슐화
interface Command { execute(): void; undo(): void; }

class AddItemCommand implements Command {
  constructor(private cart: Cart, private item: Item) {}

  execute(): void { this.cart.add(this.item); }
  undo(): void { this.cart.remove(this.item); }
}

// 사용 시점: 실행 취소, 트랜잭션, 작업 큐
```

### Template Method
```typescript
// 알고리즘 골격 정의, 세부 단계는 서브클래스에서
abstract class DataProcessor {
  process(): void {
    this.readData();
    this.processData();
    this.saveData();
  }

  abstract readData(): void;
  abstract processData(): void;
  protected saveData(): void { /* 기본 구현 */ }
}

// 사용 시점: 알고리즘 구조는 동일, 단계별 구현만 다를 때
```

## 패턴 선택 가이드

| 문제 | 패턴 |
|------|------|
| 객체 생성 복잡 | Builder, Factory |
| 전역 인스턴스 필요 | Singleton |
| 인터페이스 불일치 | Adapter |
| 기능 동적 추가 | Decorator |
| 복잡한 시스템 단순화 | Facade |
| 알고리즘 교체 필요 | Strategy |
| 상태 변경 알림 | Observer |
| 실행 취소 필요 | Command |
| 알고리즘 골격 재사용 | Template Method |

## 안티패턴 주의

```
❌ 과도한 패턴 사용 (over-engineering)
❌ 문제 없이 패턴 적용
❌ 패턴 이름만 따라하기
✅ 실제 문제 해결에 필요할 때만 사용
```

## 출력 형식

```
## Design Pattern Recommendation

### Problem Analysis
[해결하려는 문제 설명]

### Recommended Pattern: [패턴명]

#### Why This Pattern
[선택 이유]

#### Implementation
```typescript
// 구현 코드
```

#### Usage Example
```typescript
// 사용 예시
```

#### Trade-offs
- 장점: ...
- 단점: ...
```

---

요청에 맞는 디자인 패턴을 추천하고 구현하세요.
