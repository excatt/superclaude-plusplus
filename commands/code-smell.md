# Code Smell Skill

코드 스멜 감지 및 개선 가이드를 실행합니다.

## 코드 스멜이란?

```
코드 스멜 = 더 깊은 문제의 표면적 징후
- 버그는 아니지만 문제를 암시
- 리팩토링이 필요하다는 신호
- 기술 부채의 원인
```

## Bloaters (비대함)

### Long Method
```javascript
// 스멜: 메서드가 너무 김 (>20줄)
function processOrder(order) {
  // 100줄의 코드...
}

// 해결: Extract Function
function processOrder(order) {
  validateOrder(order);
  calculatePricing(order);
  applyDiscounts(order);
  processPayment(order);
  sendConfirmation(order);
}
```

### Large Class
```javascript
// 스멜: 클래스가 너무 많은 책임
class User {
  // 사용자 데이터, 인증, 이메일, 보고서, 결제...
  // 500줄 이상
}

// 해결: Extract Class
class User { /* 사용자 데이터만 */ }
class AuthService { /* 인증 */ }
class EmailService { /* 이메일 */ }
```

### Primitive Obsession
```javascript
// 스멜: 기본 타입 남용
const price = 1000; // 통화는? 단위는?
const phone = "010-1234-5678"; // 검증은?

// 해결: Replace Primitive with Object
class Money {
  constructor(amount, currency) {}
  add(other) {}
}

class PhoneNumber {
  constructor(number) { this.validate(number); }
}
```

### Long Parameter List
```javascript
// 스멜: 매개변수가 너무 많음
function createUser(name, email, age, address, city, country, phone, role) {}

// 해결: Introduce Parameter Object
function createUser(userParams) {}
// 또는 Builder 패턴
```

### Data Clumps
```javascript
// 스멜: 항상 함께 다니는 데이터 그룹
function renderMap(startX, startY, endX, endY) {}
function calculateDistance(x1, y1, x2, y2) {}

// 해결: Extract Class
class Point { constructor(x, y) {} }
function renderMap(start: Point, end: Point) {}
```

## Object-Orientation Abusers

### Switch Statements
```javascript
// 스멜: switch/if-else 반복
function getArea(shape) {
  switch (shape.type) {
    case 'circle': return Math.PI * shape.r ** 2;
    case 'rectangle': return shape.w * shape.h;
    // 새 타입 추가 시 모든 switch 수정...
  }
}

// 해결: Replace with Polymorphism
interface Shape { getArea(): number; }
class Circle implements Shape { getArea() { return Math.PI * this.r ** 2; } }
class Rectangle implements Shape { getArea() { return this.w * this.h; } }
```

### Refused Bequest
```javascript
// 스멜: 상속받았지만 사용 안 함
class Bird {
  fly() {}
  eat() {}
}

class Penguin extends Bird {
  fly() { throw new Error("Can't fly"); } // 거부!
}

// 해결: Replace Inheritance with Delegation
interface Flyable { fly(): void; }
class Penguin implements Eatable { /* fly 없음 */ }
```

### Temporary Field
```javascript
// 스멜: 특정 상황에서만 사용되는 필드
class Order {
  items = [];
  tempDiscount = null; // 특정 계산에서만 사용
  tempTax = null;
}

// 해결: Extract Class 또는 Introduce Null Object
class OrderCalculation {
  constructor(order) {}
  calculateDiscount() {}
  calculateTax() {}
}
```

## Change Preventers

### Divergent Change
```javascript
// 스멜: 한 클래스가 여러 이유로 변경됨
class Report {
  // DB 변경 시 수정
  // 출력 형식 변경 시 수정
  // 계산 로직 변경 시 수정
}

// 해결: Extract Class (각 변경 이유별로)
class ReportData { /* DB 관련 */ }
class ReportFormatter { /* 출력 형식 */ }
class ReportCalculator { /* 계산 로직 */ }
```

### Shotgun Surgery
```javascript
// 스멜: 하나의 변경이 여러 클래스에 영향
// 사용자 이름 형식 변경 → 10개 파일 수정

// 해결: Move Method, Move Field
// 관련 코드를 한 곳으로 모음
```

### Parallel Inheritance Hierarchies
```javascript
// 스멜: 한 클래스 계층 추가 시 다른 계층도 추가 필요
// Shape 추가 시 ShapeRenderer도 추가

// 해결: Move Method
// 일반적으로 한 계층을 다른 계층으로 통합
```

## Dispensables (불필요함)

### Comments (과도한 주석)
```javascript
// 스멜: 코드 설명을 위한 과도한 주석
// 이 함수는 사용자가 성인인지 확인합니다
// 18세 이상이면 true를 반환합니다
function check(u) {
  return u.a >= 18;
}

// 해결: Rename, Extract Function
function isAdult(user) {
  return user.age >= 18;
}
```

### Duplicate Code
```javascript
// 스멜: 동일하거나 유사한 코드 반복

// 해결: Extract Function, Pull Up Method, Form Template Method
```

### Dead Code
```javascript
// 스멜: 사용되지 않는 코드
function oldMethod() { /* 아무데서도 호출 안 됨 */ }
if (false) { /* 절대 실행 안 됨 */ }

// 해결: Remove Dead Code
```

### Speculative Generality
```javascript
// 스멜: "나중에 필요할 것 같아서" 만든 코드
class AbstractFactory { } // 구현체 1개뿐
function process(data, options = {}, callback, errorHandler, logger) {
  // options, callback 등 사용 안 됨
}

// 해결: Remove (YAGNI 적용)
```

## Couplers (결합)

### Feature Envy
```javascript
// 스멜: 다른 클래스 데이터를 과도하게 사용
class Order {
  getDiscount() {
    return this.customer.loyaltyPoints > 100
      ? this.customer.membershipLevel === 'gold'
        ? this.total * 0.2
        : this.total * 0.1
      : 0;
  }
}

// 해결: Move Method to Customer
class Customer {
  getDiscount(orderTotal) { /* ... */ }
}
```

### Inappropriate Intimacy
```javascript
// 스멜: 클래스 간 과도한 결합
class A {
  constructor() {
    this.b = new B();
    this.b._privateField = 10; // private 접근
  }
}

// 해결: Move Method, Extract Class, 인터페이스 도입
```

### Message Chains
```javascript
// 스멜: 긴 메서드 체인 (디미터 법칙 위반)
const zip = person.getDepartment().getAddress().getZipCode();

// 해결: Hide Delegate
class Person {
  getDepartmentZipCode() {
    return this.department.getZipCode();
  }
}
```

## 스멜 감지 체크리스트

| 카테고리 | 스멜 | 징후 |
|---------|------|------|
| Bloaters | Long Method | >20줄 |
| Bloaters | Large Class | >200줄, 많은 필드 |
| Bloaters | Long Parameter List | >3개 |
| OO Abusers | Switch | 반복되는 switch/if-else |
| Change Preventers | Shotgun Surgery | 작은 변경 → 많은 파일 수정 |
| Dispensables | Dead Code | 호출되지 않는 코드 |
| Couplers | Feature Envy | 다른 클래스 데이터 과다 사용 |

## 출력 형식

```
## Code Smell Analysis

### Summary
- Critical: N개
- Warning: N개
- Info: N개

### Detected Smells

#### [Critical] Long Method
- 위치: `processOrder()` (85줄)
- 문제: 메서드가 너무 길어 이해/유지보수 어려움
- 해결: Extract Function으로 분리

```javascript
// Before (85 lines)
function processOrder() { ... }

// After (분리된 함수들)
function validateOrder() { ... }
function calculateTotal() { ... }
```

### Prioritized Actions
1. [High] Long Method 분리
2. [Medium] Duplicate Code 제거
```

---

요청에 맞는 코드 스멜 분석을 수행하세요.
