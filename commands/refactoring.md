# Refactoring Skill

리팩토링 패턴 및 기법 가이드를 실행합니다.

## 리팩토링 원칙

```
1. 동작을 변경하지 않고 구조만 개선
2. 작은 단계로 점진적으로
3. 각 단계 후 테스트
4. 한 번에 하나의 리팩토링만
```

## 함수 리팩토링

### Extract Function
```javascript
// Before
function printOwing(invoice) {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");

  let outstanding = 0;
  for (const o of invoice.orders) {
    outstanding += o.amount;
  }

  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}

// After
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}

function printBanner() {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
}

function calculateOutstanding(invoice) {
  return invoice.orders.reduce((sum, o) => sum + o.amount, 0);
}

function printDetails(invoice, outstanding) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

### Inline Function
```javascript
// Before: 함수가 너무 단순
function getRating(driver) {
  return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
  return driver.lateDeliveries > 5;
}

// After
function getRating(driver) {
  return driver.lateDeliveries > 5 ? 2 : 1;
}
```

### Replace Temp with Query
```javascript
// Before
function calculateTotal(order) {
  const basePrice = order.quantity * order.itemPrice;
  if (basePrice > 1000) return basePrice * 0.95;
  return basePrice * 0.98;
}

// After
function calculateTotal(order) {
  if (basePrice(order) > 1000) return basePrice(order) * 0.95;
  return basePrice(order) * 0.98;
}

function basePrice(order) {
  return order.quantity * order.itemPrice;
}
```

## 조건문 리팩토링

### Replace Nested Conditional with Guard Clauses
```javascript
// Before
function getPayAmount(employee) {
  let result;
  if (employee.isSeparated) {
    result = { amount: 0, reason: "separated" };
  } else {
    if (employee.isRetired) {
      result = { amount: 0, reason: "retired" };
    } else {
      result = calculateNormalPay(employee);
    }
  }
  return result;
}

// After
function getPayAmount(employee) {
  if (employee.isSeparated) return { amount: 0, reason: "separated" };
  if (employee.isRetired) return { amount: 0, reason: "retired" };
  return calculateNormalPay(employee);
}
```

### Replace Conditional with Polymorphism
```javascript
// Before
function getSpeed(vehicle) {
  switch (vehicle.type) {
    case 'car': return vehicle.baseSpeed * 1.0;
    case 'bike': return vehicle.baseSpeed * 0.8;
    case 'truck': return vehicle.baseSpeed * 0.6;
  }
}

// After
class Vehicle {
  getSpeed() { return this.baseSpeed; }
}

class Car extends Vehicle {
  getSpeed() { return this.baseSpeed * 1.0; }
}

class Bike extends Vehicle {
  getSpeed() { return this.baseSpeed * 0.8; }
}

class Truck extends Vehicle {
  getSpeed() { return this.baseSpeed * 0.6; }
}
```

### Decompose Conditional
```javascript
// Before
if (date.before(SUMMER_START) || date.after(SUMMER_END)) {
  charge = quantity * winterRate + winterServiceCharge;
} else {
  charge = quantity * summerRate;
}

// After
if (isSummer(date)) {
  charge = summerCharge(quantity);
} else {
  charge = winterCharge(quantity);
}

function isSummer(date) {
  return !date.before(SUMMER_START) && !date.after(SUMMER_END);
}
```

## 데이터 리팩토링

### Replace Magic Number with Constant
```javascript
// Before
function potentialEnergy(mass, height) {
  return mass * height * 9.81;
}

// After
const GRAVITATIONAL_CONSTANT = 9.81;

function potentialEnergy(mass, height) {
  return mass * height * GRAVITATIONAL_CONSTANT;
}
```

### Introduce Parameter Object
```javascript
// Before
function amountInvoiced(startDate, endDate) {}
function amountReceived(startDate, endDate) {}
function amountOverdue(startDate, endDate) {}

// After
class DateRange {
  constructor(start, end) {
    this.start = start;
    this.end = end;
  }
}

function amountInvoiced(dateRange) {}
function amountReceived(dateRange) {}
function amountOverdue(dateRange) {}
```

### Encapsulate Collection
```javascript
// Before
class Person {
  get courses() { return this._courses; }
  set courses(list) { this._courses = list; }
}

// After
class Person {
  get courses() { return [...this._courses]; } // 복사본 반환
  addCourse(course) { this._courses.push(course); }
  removeCourse(course) {
    const index = this._courses.indexOf(course);
    if (index > -1) this._courses.splice(index, 1);
  }
}
```

## 클래스 리팩토링

### Extract Class
```javascript
// Before: 클래스가 너무 큼
class Person {
  get officeAreaCode() { return this._officeAreaCode; }
  get officeNumber() { return this._officeNumber; }
  get name() { return this._name; }
}

// After
class Person {
  get name() { return this._name; }
  get officePhone() { return this._officePhone; }
}

class PhoneNumber {
  get areaCode() { return this._areaCode; }
  get number() { return this._number; }
}
```

### Move Method
```javascript
// Before: 메서드가 다른 클래스 데이터를 더 많이 사용
class Account {
  overdraftCharge() {
    if (this.type.isPremium()) {
      return this.daysOverdrawn * 1.75;
    }
    return this.daysOverdrawn * 2.0;
  }
}

// After
class AccountType {
  overdraftCharge(daysOverdrawn) {
    if (this.isPremium()) {
      return daysOverdrawn * 1.75;
    }
    return daysOverdrawn * 2.0;
  }
}
```

## 코드 스멜 → 리팩토링

| 코드 스멜 | 리팩토링 |
|----------|---------|
| 긴 메서드 | Extract Function |
| 긴 매개변수 목록 | Introduce Parameter Object |
| 중복 코드 | Extract Function, Pull Up Method |
| 큰 클래스 | Extract Class |
| 기능 편애 | Move Method |
| 데이터 뭉치 | Extract Class |
| Switch 문 | Replace with Polymorphism |
| 주석 | Extract Function (이름으로 설명) |
| 죽은 코드 | Remove Dead Code |

## 리팩토링 절차

```
1. 테스트 확인 (모두 통과)
2. 작은 변경 수행
3. 테스트 실행
4. 커밋
5. 반복
```

## 출력 형식

```
## Refactoring Plan

### Code Smells Detected
| 스멜 | 위치 | 심각도 |
|------|------|--------|
| Long Method | func:50 | High |

### Refactoring Steps

#### Step 1: Extract Function
```javascript
// Before
...
// After
...
```

#### Step 2: ...

### Test Plan
- [ ] 기존 테스트 통과 확인
- [ ] 리팩토링 후 테스트

### Risk Assessment
- 영향 범위: [파일/모듈 목록]
- 예상 시간: [추정치]
```

---

요청에 맞는 리팩토링 계획을 수립하세요.
