# State Management Skill

상태 관리 패턴 가이드를 실행합니다.

## 상태 유형

```
Local State      컴포넌트 내부 (useState)
Shared State     여러 컴포넌트 공유 (Zustand, Jotai)
Server State     서버 데이터 (TanStack Query, SWR)
URL State        URL 파라미터 (Router)
Form State       폼 데이터 (React Hook Form)
```

## 상태 선택 가이드

| 상태 유형 | 2024 권장 도구 |
|----------|---------------|
| 단순 로컬 | useState |
| 복잡한 로컬 | useReducer |
| 전역 클라이언트 | **Zustand** (1순위), Jotai |
| 서버 데이터 | **TanStack Query** (1순위) |
| 폼 | React Hook Form + Zod |
| URL | nuqs, next-usequerystate |

## Zustand v5 (2024 권장)

### 기본 사용
```typescript
import { create } from 'zustand';

interface CounterStore {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useCounterStore = create<CounterStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

// 사용
function Counter() {
  const { count, increment } = useCounterStore();
  return <button onClick={increment}>{count}</button>;
}
```

### 선택적 구독 (리렌더 최적화)
```typescript
// ❌ 전체 store 구독 (불필요한 리렌더)
const { count, user } = useCounterStore();

// ✅ 필요한 값만 구독
const count = useCounterStore((state) => state.count);
const user = useCounterStore((state) => state.user);

// ✅ 여러 값 선택 (shallow 비교)
import { useShallow } from 'zustand/react/shallow';

const { count, user } = useCounterStore(
  useShallow((state) => ({ count: state.count, user: state.user }))
);
```

### 미들웨어
```typescript
import { create } from 'zustand';
import { persist, devtools, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface UserStore {
  user: User | null;
  preferences: { theme: 'light' | 'dark' };
  setUser: (user: User) => void;
  updatePreferences: (prefs: Partial<UserStore['preferences']>) => void;
}

const useUserStore = create<UserStore>()(
  devtools(
    persist(
      immer((set) => ({
        user: null,
        preferences: { theme: 'light' },
        setUser: (user) => set({ user }),
        updatePreferences: (prefs) =>
          set((state) => {
            Object.assign(state.preferences, prefs);
          }),
      })),
      {
        name: 'user-storage',
        partialize: (state) => ({ preferences: state.preferences }), // 일부만 저장
      }
    ),
    { name: 'UserStore' }
  )
);
```

### 슬라이스 패턴 (대규모)
```typescript
// stores/userSlice.ts
export interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
});

// stores/cartSlice.ts
export interface CartSlice {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
}

export const createCartSlice: StateCreator<CartSlice> = (set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({
    items: state.items.filter((i) => i.id !== id)
  })),
});

// stores/index.ts
type StoreState = UserSlice & CartSlice;

export const useStore = create<StoreState>()((...a) => ({
  ...createUserSlice(...a),
  ...createCartSlice(...a),
}));
```

## Jotai v2 (Atomic)

### 기본 사용
```typescript
import { atom, useAtom, useAtomValue, useSetAtom } from 'jotai';

// Primitive atom
const countAtom = atom(0);

// Derived atom (읽기 전용)
const doubleCountAtom = atom((get) => get(countAtom) * 2);

// Derived atom (읽기/쓰기)
const incrementAtom = atom(
  null,
  (get, set) => set(countAtom, get(countAtom) + 1)
);

// Async atom
const userAtom = atom(async () => {
  const response = await fetch('/api/user');
  return response.json();
});

// 사용
function Counter() {
  const count = useAtomValue(countAtom);        // 읽기만
  const setCount = useSetAtom(countAtom);       // 쓰기만
  const [value, setValue] = useAtom(countAtom); // 둘 다

  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Atom 패밀리
```typescript
import { atomFamily } from 'jotai/utils';

const todoAtomFamily = atomFamily((id: string) =>
  atom({
    id,
    text: '',
    completed: false,
  })
);

// 사용
function TodoItem({ id }: { id: string }) {
  const [todo, setTodo] = useAtom(todoAtomFamily(id));
  // ...
}
```

### 로컬 스토리지 연동
```typescript
import { atomWithStorage } from 'jotai/utils';

const themeAtom = atomWithStorage('theme', 'light');
```

## TanStack Query v5 (Server State)

### 기본 조회
```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// 조회
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => fetch('/api/users').then((r) => r.json()),
    staleTime: 5 * 60 * 1000,    // 5분간 fresh
    gcTime: 30 * 60 * 1000,      // 30분 캐시 유지 (v5: cacheTime → gcTime)
  });
}

// 상세 조회
function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => fetch(`/api/users/${id}`).then((r) => r.json()),
    enabled: !!id, // id가 있을 때만 실행
  });
}
```

### Mutation + Optimistic Updates
```typescript
function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (newUser: NewUser) =>
      fetch('/api/users', {
        method: 'POST',
        body: JSON.stringify(newUser),
      }).then((r) => r.json()),

    // Optimistic update
    onMutate: async (newUser) => {
      await queryClient.cancelQueries({ queryKey: ['users'] });
      const previous = queryClient.getQueryData(['users']);

      queryClient.setQueryData(['users'], (old: User[]) => [
        ...old,
        { ...newUser, id: 'temp-id' },
      ]);

      return { previous };
    },

    onError: (err, newUser, context) => {
      queryClient.setQueryData(['users'], context?.previous);
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

### Infinite Query (무한 스크롤)
```typescript
function useInfiniteUsers() {
  return useInfiniteQuery({
    queryKey: ['users', 'infinite'],
    queryFn: ({ pageParam }) =>
      fetch(`/api/users?cursor=${pageParam}`).then((r) => r.json()),
    initialPageParam: 0,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  });
}

// 사용
function UserList() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteUsers();

  return (
    <>
      {data?.pages.map((page) =>
        page.users.map((user) => <UserCard key={user.id} user={user} />)
      )}
      {hasNextPage && (
        <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
          {isFetchingNextPage ? 'Loading...' : 'Load More'}
        </button>
      )}
    </>
  );
}
```

## React Hook Form + Zod

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('유효한 이메일을 입력하세요'),
  password: z.string().min(8, '8자 이상 입력하세요'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: '비밀번호가 일치하지 않습니다',
  path: ['confirmPassword'],
});

type FormData = z.infer<typeof schema>;

function SignupForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await signup(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}

      <input type="password" {...register('confirmPassword')} />
      {errors.confirmPassword && <span>{errors.confirmPassword.message}</span>}

      <button disabled={isSubmitting}>Sign Up</button>
    </form>
  );
}
```

## URL State (nuqs)

```typescript
import { useQueryState, parseAsInteger, parseAsString } from 'nuqs';

function ProductList() {
  const [search, setSearch] = useQueryState('q', parseAsString.withDefault(''));
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1));
  const [sort, setSort] = useQueryState('sort', parseAsString.withDefault('newest'));

  // URL: /products?q=shoes&page=2&sort=price

  return (
    <div>
      <input value={search} onChange={(e) => setSearch(e.target.value)} />
      <button onClick={() => setPage(page + 1)}>Next Page</button>
    </div>
  );
}
```

## 체크리스트

- [ ] 상태 유형 분류 (client vs server)
- [ ] 서버 데이터 → TanStack Query
- [ ] 전역 클라이언트 → Zustand/Jotai
- [ ] 폼 → React Hook Form + Zod
- [ ] URL 동기화 필요 → nuqs
- [ ] 불필요한 리렌더링 방지

## 출력 형식

```
## State Management Design

### State Classification
| 상태 | 유형 | 도구 |
|------|------|------|
| 사용자 정보 | Server | TanStack Query |
| 테마 설정 | Global | Zustand (persist) |
| 검색 필터 | URL | nuqs |
| 로그인 폼 | Form | React Hook Form |

### Implementation
```typescript
// 상태 관리 코드
```

### Store Structure
```
stores/
├── useUserStore.ts    # Zustand
├── atoms/             # Jotai (선택)
│   └── themeAtom.ts
└── queries/           # TanStack Query
    └── useUsers.ts
```

### Optimization
- 선택적 구독으로 리렌더 최소화
- 서버 상태 캐싱 전략
- Devtools 연동
```

---

요청에 맞는 상태 관리 전략을 설계하세요.
