# Next.js Skill

Next.js 14+ App Router 패턴 가이드를 실행합니다.

## App Router 구조

```
app/
├── layout.tsx          # 루트 레이아웃
├── page.tsx            # 홈페이지
├── loading.tsx         # 로딩 UI
├── error.tsx           # 에러 UI
├── not-found.tsx       # 404 UI
├── globals.css
├── (auth)/             # Route Group (URL 영향 X)
│   ├── login/page.tsx
│   └── register/page.tsx
├── dashboard/
│   ├── layout.tsx      # 중첩 레이아웃
│   ├── page.tsx
│   └── [id]/           # 동적 라우트
│       └── page.tsx
├── api/                # API Routes
│   └── users/
│       └── route.ts
└── _components/        # Private folder
    └── Header.tsx
```

## Server Components (기본)

```tsx
// app/users/page.tsx
// 기본적으로 Server Component

async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    cache: 'force-cache',      // 기본값: 정적
    // cache: 'no-store',      // 동적
    // next: { revalidate: 60 }, // ISR
  });
  return res.json();
}

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

## Client Components

```tsx
// app/_components/Counter.tsx
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}
```

## Server Actions

```tsx
// app/actions.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const schema = z.object({
  title: z.string().min(1),
  content: z.string().min(10),
});

export async function createPost(formData: FormData) {
  const data = schema.parse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  await db.post.create({ data });

  revalidatePath('/posts');
  redirect('/posts');
}

// 폼에서 사용
// app/posts/new/page.tsx
export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

### Server Actions with useFormState

```tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { createPost } from './actions';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create'}
    </button>
  );
}

export function PostForm() {
  const [state, action] = useFormState(createPost, { error: null });

  return (
    <form action={action}>
      <input name="title" required />
      <textarea name="content" required />
      {state?.error && <p className="error">{state.error}</p>}
      <SubmitButton />
    </form>
  );
}
```

## Data Fetching 패턴

### Parallel Data Fetching
```tsx
// ✅ 병렬 fetch
async function Page() {
  const [users, posts] = await Promise.all([
    getUsers(),
    getPosts(),
  ]);

  return <div>...</div>;
}
```

### Sequential Data Fetching
```tsx
// 의존성이 있는 경우
async function Page({ params }: { params: { id: string } }) {
  const user = await getUser(params.id);
  const posts = await getPostsByUser(user.id); // user 필요

  return <div>...</div>;
}
```

### Preloading
```tsx
// lib/data.ts
import { cache } from 'react';

export const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`);
  return res.json();
});

export const preloadUser = (id: string) => {
  void getUser(id);
};

// 사용
import { preloadUser } from '@/lib/data';

export default function UserLayout({ params, children }) {
  preloadUser(params.id); // 미리 fetch 시작
  return children;
}
```

## Route Handlers (API)

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = searchParams.get('q');

  const users = await db.user.findMany({
    where: query ? { name: { contains: query } } : undefined,
  });

  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const user = await db.user.create({ data: body });

  return NextResponse.json(user, { status: 201 });
}

// app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 });
  }

  return NextResponse.json(user);
}
```

## Metadata

```tsx
// app/layout.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: {
    default: 'My Site',
    template: '%s | My Site',
  },
  description: 'Site description',
  openGraph: {
    type: 'website',
    locale: 'ko_KR',
    siteName: 'My Site',
  },
};

// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }): Promise<Metadata> {
  const post = await getPost(params.slug);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
    },
  };
}
```

## Streaming & Suspense

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* 즉시 렌더링 */}
      <StaticContent />

      {/* 스트리밍 */}
      <Suspense fallback={<ChartSkeleton />}>
        <SlowChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <SlowTable />
      </Suspense>
    </div>
  );
}

// loading.tsx 대신 세분화된 로딩 UI
```

## Middleware

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // 인증 체크
  const token = request.cookies.get('token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // 헤더 추가
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');

  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```

## Caching 전략

```tsx
// 정적 (기본)
fetch('https://api.example.com/data');
fetch('https://api.example.com/data', { cache: 'force-cache' });

// 동적
fetch('https://api.example.com/data', { cache: 'no-store' });

// ISR (시간 기반)
fetch('https://api.example.com/data', { next: { revalidate: 60 } });

// 태그 기반
fetch('https://api.example.com/posts', { next: { tags: ['posts'] } });

// 재검증
import { revalidatePath, revalidateTag } from 'next/cache';

revalidatePath('/posts');        // 경로 재검증
revalidateTag('posts');          // 태그 재검증
```

## 동적 라우트 생성

```tsx
// app/posts/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await getPosts();

  return posts.map((post) => ({
    slug: post.slug,
  }));
}

// 동적 설정
export const dynamic = 'force-dynamic'; // 항상 동적
export const revalidate = 60;           // ISR
```

## Error Handling

```tsx
// app/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// app/global-error.tsx (루트 레이아웃 에러)
'use client';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html>
      <body>
        <h2>Something went wrong!</h2>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  );
}
```

## 환경 변수

```bash
# .env.local
DATABASE_URL=...           # 서버만
NEXT_PUBLIC_API_URL=...    # 클라이언트 노출

# 사용
process.env.DATABASE_URL           // 서버
process.env.NEXT_PUBLIC_API_URL    // 클라이언트
```

## 체크리스트

- [ ] Server Components 우선 사용
- [ ] 'use client' 최소화 (리프 컴포넌트)
- [ ] Server Actions 활용
- [ ] 적절한 캐싱 전략
- [ ] Suspense로 스트리밍
- [ ] Metadata API 사용
- [ ] 이미지 최적화 (next/image)
- [ ] 폰트 최적화 (next/font)

## 출력 형식

```
## Next.js Implementation

### Route Structure
```
app/
├── ...
```

### Data Fetching Strategy
| 페이지 | 방식 | 캐싱 |
|--------|------|------|
| Home | Static | ISR 60s |
| Dashboard | Dynamic | No cache |

### Server Actions
```typescript
// actions.ts
```

### Components
- Server: [컴포넌트 목록]
- Client: [컴포넌트 목록]

### Caching
- Static: [페이지 목록]
- Dynamic: [페이지 목록]
- ISR: [페이지 + 주기]
```

---

요청에 맞는 Next.js 구현을 설계하세요.
