# Clean Architecture Skill

클린 아키텍처 설계 가이드를 실행합니다.

## 핵심 원칙

```
┌────────────────────────────────────────┐
│           Frameworks & Drivers         │ ← 외부 (DB, Web, UI)
│  ┌──────────────────────────────────┐  │
│  │      Interface Adapters          │  │ ← Controllers, Gateways
│  │  ┌────────────────────────────┐  │  │
│  │  │    Application Business    │  │  │ ← Use Cases
│  │  │  ┌──────────────────────┐  │  │  │
│  │  │  │ Enterprise Business  │  │  │  │ ← Entities (핵심)
│  │  │  └──────────────────────┘  │  │  │
│  │  └────────────────────────────┘  │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘

의존성 규칙: 바깥 → 안쪽 (안쪽은 바깥을 모름)
```

## 프로젝트 구조

```
src/
├── domain/                    # Enterprise Business Rules
│   ├── entities/
│   │   └── User.ts
│   ├── value-objects/
│   │   └── Email.ts
│   └── errors/
│       └── DomainError.ts
│
├── application/               # Application Business Rules
│   ├── use-cases/
│   │   ├── CreateUser.ts
│   │   └── GetUser.ts
│   ├── interfaces/            # Port (추상화)
│   │   ├── repositories/
│   │   │   └── UserRepository.ts
│   │   └── services/
│   │       └── EmailService.ts
│   └── dtos/
│       └── UserDTO.ts
│
├── infrastructure/            # Interface Adapters (Adapters)
│   ├── repositories/
│   │   └── PostgresUserRepository.ts
│   ├── services/
│   │   └── SendGridEmailService.ts
│   └── persistence/
│       └── prisma/
│
└── presentation/              # Frameworks & Drivers
    ├── http/
    │   ├── controllers/
    │   │   └── UserController.ts
    │   ├── middlewares/
    │   └── routes/
    └── cli/
```

## Domain Layer (Entities)

```typescript
// domain/entities/User.ts
import { Email } from '../value-objects/Email';

export interface UserProps {
  id: string;
  email: Email;
  name: string;
  createdAt: Date;
}

export class User {
  private constructor(private props: UserProps) {}

  static create(props: Omit<UserProps, 'id' | 'createdAt'>): User {
    return new User({
      ...props,
      id: crypto.randomUUID(),
      createdAt: new Date(),
    });
  }

  static reconstitute(props: UserProps): User {
    return new User(props);
  }

  get id(): string { return this.props.id; }
  get email(): Email { return this.props.email; }
  get name(): string { return this.props.name; }
  get createdAt(): Date { return this.props.createdAt; }

  changeName(newName: string): void {
    if (!newName || newName.trim().length < 2) {
      throw new Error('Name must be at least 2 characters');
    }
    this.props.name = newName.trim();
  }

  changeEmail(newEmail: Email): void {
    this.props.email = newEmail;
  }
}

// domain/value-objects/Email.ts
export class Email {
  private constructor(private readonly value: string) {}

  static create(email: string): Email {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new Error('Invalid email format');
    }
    return new Email(email.toLowerCase());
  }

  getValue(): string {
    return this.value;
  }

  equals(other: Email): boolean {
    return this.value === other.value;
  }
}
```

## Application Layer (Use Cases)

```typescript
// application/interfaces/repositories/UserRepository.ts (Port)
import { User } from '@/domain/entities/User';

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}

// application/interfaces/services/EmailService.ts (Port)
export interface EmailService {
  sendWelcomeEmail(email: string, name: string): Promise<void>;
}

// application/use-cases/CreateUser.ts
import { User } from '@/domain/entities/User';
import { Email } from '@/domain/value-objects/Email';
import { UserRepository } from '../interfaces/repositories/UserRepository';
import { EmailService } from '../interfaces/services/EmailService';

export interface CreateUserInput {
  email: string;
  name: string;
}

export interface CreateUserOutput {
  id: string;
  email: string;
  name: string;
}

export class CreateUserUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly emailService: EmailService
  ) {}

  async execute(input: CreateUserInput): Promise<CreateUserOutput> {
    // 비즈니스 규칙 검증
    const email = Email.create(input.email);

    const existingUser = await this.userRepository.findByEmail(email.getValue());
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // 엔티티 생성
    const user = User.create({
      email,
      name: input.name,
    });

    // 영속화
    await this.userRepository.save(user);

    // 부수 효과
    await this.emailService.sendWelcomeEmail(
      user.email.getValue(),
      user.name
    );

    return {
      id: user.id,
      email: user.email.getValue(),
      name: user.name,
    };
  }
}

// application/use-cases/GetUser.ts
export class GetUserUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(id: string): Promise<CreateUserOutput | null> {
    const user = await this.userRepository.findById(id);

    if (!user) {
      return null;
    }

    return {
      id: user.id,
      email: user.email.getValue(),
      name: user.name,
    };
  }
}
```

## Infrastructure Layer (Adapters)

```typescript
// infrastructure/repositories/PostgresUserRepository.ts
import { PrismaClient } from '@prisma/client';
import { User } from '@/domain/entities/User';
import { Email } from '@/domain/value-objects/Email';
import { UserRepository } from '@/application/interfaces/repositories/UserRepository';

export class PostgresUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { id } });

    if (!data) return null;

    return User.reconstitute({
      id: data.id,
      email: Email.create(data.email),
      name: data.name,
      createdAt: data.createdAt,
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { email } });

    if (!data) return null;

    return User.reconstitute({
      id: data.id,
      email: Email.create(data.email),
      name: data.name,
      createdAt: data.createdAt,
    });
  }

  async save(user: User): Promise<void> {
    await this.prisma.user.upsert({
      where: { id: user.id },
      create: {
        id: user.id,
        email: user.email.getValue(),
        name: user.name,
        createdAt: user.createdAt,
      },
      update: {
        email: user.email.getValue(),
        name: user.name,
      },
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({ where: { id } });
  }
}

// infrastructure/services/SendGridEmailService.ts
import { EmailService } from '@/application/interfaces/services/EmailService';

export class SendGridEmailService implements EmailService {
  constructor(private readonly apiKey: string) {}

  async sendWelcomeEmail(email: string, name: string): Promise<void> {
    // SendGrid API 호출
    console.log(`Sending welcome email to ${email}`);
  }
}
```

## Presentation Layer (Controllers)

```typescript
// presentation/http/controllers/UserController.ts
import { Request, Response } from 'express';
import { CreateUserUseCase } from '@/application/use-cases/CreateUser';
import { GetUserUseCase } from '@/application/use-cases/GetUser';

export class UserController {
  constructor(
    private readonly createUserUseCase: CreateUserUseCase,
    private readonly getUserUseCase: GetUserUseCase
  ) {}

  async create(req: Request, res: Response): Promise<void> {
    try {
      const result = await this.createUserUseCase.execute(req.body);
      res.status(201).json(result);
    } catch (error) {
      if (error.message === 'Email already registered') {
        res.status(409).json({ error: error.message });
      } else if (error.message === 'Invalid email format') {
        res.status(400).json({ error: error.message });
      } else {
        res.status(500).json({ error: 'Internal server error' });
      }
    }
  }

  async getById(req: Request, res: Response): Promise<void> {
    const result = await this.getUserUseCase.execute(req.params.id);

    if (!result) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    res.json(result);
  }
}
```

## Dependency Injection

```typescript
// main.ts (Composition Root)
import { PrismaClient } from '@prisma/client';
import express from 'express';

// Infrastructure
const prisma = new PrismaClient();
const userRepository = new PostgresUserRepository(prisma);
const emailService = new SendGridEmailService(process.env.SENDGRID_API_KEY);

// Application
const createUserUseCase = new CreateUserUseCase(userRepository, emailService);
const getUserUseCase = new GetUserUseCase(userRepository);

// Presentation
const userController = new UserController(createUserUseCase, getUserUseCase);

// Routes
const app = express();
app.use(express.json());

app.post('/users', (req, res) => userController.create(req, res));
app.get('/users/:id', (req, res) => userController.getById(req, res));

app.listen(3000);
```

## 테스트

```typescript
// Unit Test (Use Case)
describe('CreateUserUseCase', () => {
  let useCase: CreateUserUseCase;
  let mockUserRepository: jest.Mocked<UserRepository>;
  let mockEmailService: jest.Mocked<EmailService>;

  beforeEach(() => {
    mockUserRepository = {
      findById: jest.fn(),
      findByEmail: jest.fn(),
      save: jest.fn(),
      delete: jest.fn(),
    };
    mockEmailService = {
      sendWelcomeEmail: jest.fn(),
    };
    useCase = new CreateUserUseCase(mockUserRepository, mockEmailService);
  });

  it('should create user successfully', async () => {
    mockUserRepository.findByEmail.mockResolvedValue(null);

    const result = await useCase.execute({
      email: 'test@example.com',
      name: 'John Doe',
    });

    expect(result.email).toBe('test@example.com');
    expect(mockUserRepository.save).toHaveBeenCalled();
    expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalled();
  });

  it('should throw error if email exists', async () => {
    mockUserRepository.findByEmail.mockResolvedValue(
      User.create({ email: Email.create('test@example.com'), name: 'Existing' })
    );

    await expect(
      useCase.execute({ email: 'test@example.com', name: 'John' })
    ).rejects.toThrow('Email already registered');
  });
});
```

## 체크리스트

- [ ] 의존성 방향 (외부 → 내부)
- [ ] 도메인 레이어 순수성 (프레임워크 의존 X)
- [ ] Use Case 단일 책임
- [ ] Port/Adapter 패턴 (인터페이스)
- [ ] Composition Root에서 DI
- [ ] 테스트 용이성 확인

## 출력 형식

```
## Clean Architecture Design

### Layer Structure
```
src/
├── domain/
├── application/
├── infrastructure/
└── presentation/
```

### Dependencies
| Layer | Depends On | Used By |
|-------|------------|---------|
| Domain | - | Application |
| Application | Domain | Infrastructure |

### Use Cases
| Use Case | Input | Output |
|----------|-------|--------|
| CreateUser | email, name | User |

### Ports & Adapters
| Port | Adapter |
|------|---------|
| UserRepository | PostgresUserRepository |
| EmailService | SendGridEmailService |
```

---

요청에 맞는 클린 아키텍처를 설계하세요.
