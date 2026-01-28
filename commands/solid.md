# SOLID Principles Skill

SOLID 원칙 적용 가이드를 실행합니다.

## S - Single Responsibility Principle

**하나의 클래스는 하나의 책임만**

```typescript
// ❌ Bad: 여러 책임
class User {
  saveToDatabase() { /* DB 저장 */ }
  sendEmail() { /* 이메일 발송 */ }
  generateReport() { /* 리포트 생성 */ }
}

// ✅ Good: 단일 책임
class User {
  constructor(public name: string, public email: string) {}
}

class UserRepository {
  save(user: User) { /* DB 저장 */ }
}

class EmailService {
  send(to: string, message: string) { /* 이메일 발송 */ }
}

class UserReportGenerator {
  generate(user: User) { /* 리포트 생성 */ }
}
```

**판단 기준**: "이 클래스를 변경해야 하는 이유가 몇 가지인가?"

## O - Open/Closed Principle

**확장에는 열려있고, 수정에는 닫혀있어야**

```typescript
// ❌ Bad: 새 타입 추가 시 수정 필요
class AreaCalculator {
  calculate(shape: Shape) {
    if (shape.type === 'circle') {
      return Math.PI * shape.radius ** 2;
    } else if (shape.type === 'rectangle') {
      return shape.width * shape.height;
    }
    // 새 도형 추가 시 여기 수정 필요
  }
}

// ✅ Good: 확장으로 새 타입 추가
interface Shape {
  area(): number;
}

class Circle implements Shape {
  constructor(private radius: number) {}
  area(): number { return Math.PI * this.radius ** 2; }
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  area(): number { return this.width * this.height; }
}

// 새 도형 추가: 기존 코드 수정 없이 새 클래스만 추가
class Triangle implements Shape {
  constructor(private base: number, private height: number) {}
  area(): number { return 0.5 * this.base * this.height; }
}
```

## L - Liskov Substitution Principle

**서브타입은 기반 타입으로 대체 가능해야**

```typescript
// ❌ Bad: 서브클래스가 기반 클래스 계약 위반
class Rectangle {
  constructor(protected width: number, protected height: number) {}
  setWidth(w: number) { this.width = w; }
  setHeight(h: number) { this.height = h; }
  area(): number { return this.width * this.height; }
}

class Square extends Rectangle {
  setWidth(w: number) { this.width = this.height = w; } // 위반!
  setHeight(h: number) { this.width = this.height = h; } // 위반!
}

// rect.setWidth(5); rect.setHeight(10); rect.area() === 50
// square.setWidth(5); square.setHeight(10); square.area() === 100 (예상과 다름)

// ✅ Good: 별도 추상화
interface Shape {
  area(): number;
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {}
  area(): number { return this.width * this.height; }
}

class Square implements Shape {
  constructor(private side: number) {}
  area(): number { return this.side ** 2; }
}
```

**테스트**: 기반 클래스 사용하는 모든 곳에서 서브클래스로 대체해도 동작하는가?

## I - Interface Segregation Principle

**클라이언트가 사용하지 않는 인터페이스에 의존하지 않아야**

```typescript
// ❌ Bad: 뚱뚱한 인터페이스
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

class Robot implements Worker {
  work() { /* OK */ }
  eat() { throw new Error('로봇은 먹지 않음'); } // 불필요
  sleep() { throw new Error('로봇은 자지 않음'); } // 불필요
}

// ✅ Good: 분리된 인터페이스
interface Workable {
  work(): void;
}

interface Eatable {
  eat(): void;
}

interface Sleepable {
  sleep(): void;
}

class Human implements Workable, Eatable, Sleepable {
  work() { /* ... */ }
  eat() { /* ... */ }
  sleep() { /* ... */ }
}

class Robot implements Workable {
  work() { /* ... */ }
}
```

## D - Dependency Inversion Principle

**고수준 모듈이 저수준 모듈에 의존하지 않고, 둘 다 추상화에 의존**

```typescript
// ❌ Bad: 구체 클래스에 직접 의존
class UserService {
  private database = new MySQLDatabase(); // 직접 의존

  getUser(id: string) {
    return this.database.query(`SELECT * FROM users WHERE id = ${id}`);
  }
}

// ✅ Good: 추상화에 의존
interface Database {
  query(sql: string): any;
}

class MySQLDatabase implements Database {
  query(sql: string) { /* MySQL 구현 */ }
}

class PostgreSQLDatabase implements Database {
  query(sql: string) { /* PostgreSQL 구현 */ }
}

class UserService {
  constructor(private database: Database) {} // 추상화에 의존

  getUser(id: string) {
    return this.database.query(`SELECT * FROM users WHERE id = ${id}`);
  }
}

// 의존성 주입
const userService = new UserService(new PostgreSQLDatabase());
```

## SOLID 체크리스트

### 코드 리뷰 시
- [ ] **S**: 클래스가 하나의 이유로만 변경되는가?
- [ ] **O**: 새 기능 추가 시 기존 코드 수정 없이 가능한가?
- [ ] **L**: 서브클래스가 기반 클래스 대체 시 문제없는가?
- [ ] **I**: 인터페이스가 너무 크지 않은가?
- [ ] **D**: 구체 클래스가 아닌 추상화에 의존하는가?

### 위반 징후
```
SRP 위반: 클래스가 여러 이유로 자주 변경됨
OCP 위반: if-else/switch 문이 자주 추가됨
LSP 위반: instanceof 검사가 많음
ISP 위반: 빈 메서드 구현, NotImplementedException
DIP 위반: new 키워드가 비즈니스 로직에 많음
```

## 출력 형식

```
## SOLID Analysis

### Current Issues
| 원칙 | 위반 | 위치 | 설명 |
|------|------|------|------|
| SRP | ✅ | UserService | 여러 책임 혼재 |

### Refactoring Suggestions

#### Before
```typescript
// 문제 코드
```

#### After
```typescript
// 개선 코드
```

### Applied Principles
- [x] SRP: 책임 분리
- [ ] OCP: 확장성 개선 필요
```

---

요청에 맞는 SOLID 원칙 분석 및 개선안을 제시하세요.
