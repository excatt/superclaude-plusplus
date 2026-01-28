# Clean Code Skill

클린 코드 원칙 및 적용 가이드를 실행합니다.

## 네이밍

### 의도를 드러내는 이름
```javascript
// ❌ Bad
const d = 86400;
const list = users.filter(u => u.a > 18);

// ✅ Good
const SECONDS_PER_DAY = 86400;
const adultUsers = users.filter(user => user.age > 18);
```

### 검색 가능한 이름
```javascript
// ❌ Bad
setTimeout(fn, 86400000);

// ✅ Good
const MILLISECONDS_PER_DAY = 24 * 60 * 60 * 1000;
setTimeout(fn, MILLISECONDS_PER_DAY);
```

### 발음 가능한 이름
```javascript
// ❌ Bad
const yyyymmdstr = moment().format('YYYY/MM/DD');

// ✅ Good
const currentDate = moment().format('YYYY/MM/DD');
```

## 함수

### 작게 만들기
```javascript
// ❌ Bad: 너무 긴 함수
function processOrder(order) {
  // 100줄의 코드...
}

// ✅ Good: 작은 함수들로 분리
function processOrder(order) {
  validateOrder(order);
  calculateTotal(order);
  applyDiscounts(order);
  saveOrder(order);
  sendConfirmation(order);
}
```

### 하나의 일만 하기
```javascript
// ❌ Bad: 여러 일을 함
function emailClients(clients) {
  clients.forEach(client => {
    const record = database.lookup(client);
    if (record.isActive()) {
      email(client);
    }
  });
}

// ✅ Good: 하나의 일만
function emailActiveClients(clients) {
  clients
    .filter(isActiveClient)
    .forEach(email);
}

function isActiveClient(client) {
  const record = database.lookup(client);
  return record.isActive();
}
```

### 인수 최소화
```javascript
// ❌ Bad: 인수가 많음
function createUser(name, email, age, address, phone, role) {}

// ✅ Good: 객체로 전달
function createUser({ name, email, age, address, phone, role }) {}

// 또는 Builder 패턴
new UserBuilder()
  .setName('John')
  .setEmail('john@example.com')
  .build();
```

### 부수 효과 없애기
```javascript
// ❌ Bad: 숨겨진 부수 효과
function checkPassword(user, password) {
  if (cryptographer.decrypt(user.password) === password) {
    Session.initialize(); // 숨겨진 부수 효과!
    return true;
  }
  return false;
}

// ✅ Good: 명확한 의도
function checkPassword(user, password) {
  return cryptographer.decrypt(user.password) === password;
}

function loginUser(user, password) {
  if (checkPassword(user, password)) {
    Session.initialize();
    return true;
  }
  return false;
}
```

## 주석

### 코드로 의도 표현
```javascript
// ❌ Bad: 주석으로 설명
// 직원이 혜택을 받을 자격이 있는지 확인
if (employee.flags & HOURLY_FLAG && employee.age > 65) {}

// ✅ Good: 코드가 설명
if (employee.isEligibleForFullBenefits()) {}
```

### 좋은 주석
```javascript
// 정규표현식 설명 (복잡한 패턴)
// Format: kk:mm:ss EEE, MMM dd, yyyy
const pattern = /\d{2}:\d{2}:\d{2} \w{3}, \w{3} \d{2}, \d{4}/;

// TODO: 임시 해결책, #123 이슈에서 수정 예정
// WARNING: 이 메서드는 O(n²) 복잡도를 가짐
// NOTE: 외부 API 제한으로 인해 이 방식 사용
```

### 나쁜 주석
```javascript
// ❌ 피해야 할 주석
i++; // i를 증가시킴 (불필요)
// 작성자: John, 날짜: 2024-01-15 (버전 관리 사용)
// function oldMethod() { ... } (죽은 코드)
```

## 에러 처리

### 예외 사용
```javascript
// ❌ Bad: 에러 코드 반환
function withdraw(amount) {
  if (balance < amount) return -1;
  balance -= amount;
  return 0;
}

// ✅ Good: 예외 던지기
function withdraw(amount) {
  if (balance < amount) {
    throw new InsufficientFundsError(amount, balance);
  }
  balance -= amount;
}
```

### 의미있는 예외
```javascript
// ❌ Bad
throw new Error('Error');

// ✅ Good
throw new ValidationError('Email format is invalid', { field: 'email' });
```

## 객체와 자료구조

### 디미터 법칙
```javascript
// ❌ Bad: 기차 충돌 (Train Wreck)
const outputDir = ctxt.getOptions().getScratchDir().getAbsolutePath();

// ✅ Good
const options = ctxt.getOptions();
const scratchDir = options.getScratchDir();
const outputDir = scratchDir.getAbsolutePath();

// 또는 더 좋은 방법
const outputDir = ctxt.getOutputDirectory();
```

## 클래스

### 작게 유지
```javascript
// 클래스는 하나의 책임만
// 메서드 수보다 책임의 수가 중요

// ❌ Bad: God Class
class Employee {
  // 급여 계산, 세금 계산, HR 보고서, 이메일 발송 등...
}

// ✅ Good: 분리된 책임
class Employee { /* 직원 데이터 */ }
class PayrollCalculator { /* 급여 계산 */ }
class TaxCalculator { /* 세금 계산 */ }
class HRReporter { /* HR 보고서 */ }
```

### 응집도
```javascript
// 높은 응집도: 모든 메서드가 모든 인스턴스 변수 사용
class Stack {
  private items = [];

  push(item) { this.items.push(item); }
  pop() { return this.items.pop(); }
  peek() { return this.items[this.items.length - 1]; }
  isEmpty() { return this.items.length === 0; }
}
```

## 체크리스트

### 함수
- [ ] 20줄 이하
- [ ] 인수 3개 이하
- [ ] 하나의 일만 수행
- [ ] 부수 효과 없음
- [ ] 추상화 수준 일관성

### 이름
- [ ] 의도가 명확
- [ ] 발음/검색 가능
- [ ] 일관된 용어 사용

### 클래스
- [ ] 작은 크기 (200줄 이하 권장)
- [ ] 단일 책임
- [ ] 높은 응집도

## 출력 형식

```
## Clean Code Review

### Issues Found
| 유형 | 위치 | 문제 | 개선안 |
|------|------|------|--------|
| 네이밍 | line 10 | 불명확한 변수명 | d → dayCount |

### Refactoring
```javascript
// Before
...
// After
...
```

### Metrics
- 함수 평균 길이: XX줄
- 최대 함수 길이: XX줄
- 인수 평균: X개
```

---

요청에 맞는 클린 코드 분석 및 개선안을 제시하세요.
