# Remix Skill

Remix 풀스택 웹 프레임워크 패턴 가이드를 실행합니다.

## 프로젝트 구조

```
app/
├── root.tsx                # 루트 레이아웃
├── entry.client.tsx        # 클라이언트 진입점
├── entry.server.tsx        # 서버 진입점
├── routes/
│   ├── _index.tsx          # / 라우트
│   ├── users._index.tsx    # /users
│   ├── users.$id.tsx       # /users/:id
│   ├── users.$id_.edit.tsx # /users/:id/edit
│   └── api.users.tsx       # /api/users (Resource Route)
├── components/
├── models/
├── services/
└── utils/
```

## 라우팅 (v2 Flat Routes)

### 파일 규칙
```
routes/
├── _index.tsx              # /
├── about.tsx               # /about
├── users._index.tsx        # /users
├── users.$userId.tsx       # /users/:userId
├── users.$userId_.edit.tsx # /users/:userId/edit (탈출)
├── blog_.tsx               # /blog (레이아웃 없음)
├── _auth.tsx               # 레이아웃 (URL 없음)
├── _auth.login.tsx         # /login (auth 레이아웃)
└── $.tsx                   # Splat (catch-all)
```

## Loader (데이터 로딩)

```typescript
// routes/users.$userId.tsx
import { json, type LoaderFunctionArgs } from "@remix-run/node";
import { useLoaderData, useNavigation } from "@remix-run/react";
import { db } from "~/db.server";

export async function loader({ params, request }: LoaderFunctionArgs) {
  const userId = params.userId;

  const user = await db.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new Response("Not Found", { status: 404 });
  }

  return json({ user });
}

export default function UserPage() {
  const { user } = useLoaderData<typeof loader>();
  const navigation = useNavigation();

  if (navigation.state === "loading") {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

## Action (폼 처리)

```typescript
// routes/users.new.tsx
import { json, redirect, type ActionFunctionArgs } from "@remix-run/node";
import { Form, useActionData, useNavigation } from "@remix-run/react";
import { z } from "zod";

const UserSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email"),
});

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  const data = Object.fromEntries(formData);

  const result = UserSchema.safeParse(data);

  if (!result.success) {
    return json(
      { errors: result.error.flatten().fieldErrors },
      { status: 400 }
    );
  }

  const user = await db.user.create({
    data: result.data,
  });

  return redirect(`/users/${user.id}`);
}

export default function NewUser() {
  const actionData = useActionData<typeof action>();
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";

  return (
    <Form method="post">
      <div>
        <label htmlFor="name">Name</label>
        <input type="text" name="name" id="name" />
        {actionData?.errors?.name && (
          <p className="error">{actionData.errors.name}</p>
        )}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input type="email" name="email" id="email" />
        {actionData?.errors?.email && (
          <p className="error">{actionData.errors.email}</p>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Creating..." : "Create User"}
      </button>
    </Form>
  );
}
```

## Resource Routes (API)

```typescript
// routes/api.users.tsx
import { json, type ActionFunctionArgs, type LoaderFunctionArgs } from "@remix-run/node";

// GET /api/users
export async function loader({ request }: LoaderFunctionArgs) {
  const url = new URL(request.url);
  const search = url.searchParams.get("search") || "";

  const users = await db.user.findMany({
    where: {
      name: { contains: search },
    },
  });

  return json({ users });
}

// POST /api/users
export async function action({ request }: ActionFunctionArgs) {
  const data = await request.json();

  const user = await db.user.create({ data });

  return json({ user }, { status: 201 });
}
```

## 에러 처리

```typescript
// routes/users.$userId.tsx
import { isRouteErrorResponse, useRouteError } from "@remix-run/react";

export function ErrorBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    return (
      <div>
        <h1>{error.status} {error.statusText}</h1>
        <p>{error.data}</p>
      </div>
    );
  }

  if (error instanceof Error) {
    return (
      <div>
        <h1>Error</h1>
        <p>{error.message}</p>
      </div>
    );
  }

  return <h1>Unknown Error</h1>;
}
```

## 인증 (Session)

```typescript
// app/services/session.server.ts
import { createCookieSessionStorage, redirect } from "@remix-run/node";

const sessionStorage = createCookieSessionStorage({
  cookie: {
    name: "__session",
    httpOnly: true,
    maxAge: 60 * 60 * 24 * 7, // 1 week
    path: "/",
    sameSite: "lax",
    secrets: [process.env.SESSION_SECRET!],
    secure: process.env.NODE_ENV === "production",
  },
});

export async function getSession(request: Request) {
  const cookie = request.headers.get("Cookie");
  return sessionStorage.getSession(cookie);
}

export async function createUserSession(userId: string, redirectTo: string) {
  const session = await sessionStorage.getSession();
  session.set("userId", userId);

  return redirect(redirectTo, {
    headers: {
      "Set-Cookie": await sessionStorage.commitSession(session),
    },
  });
}

export async function requireUserId(request: Request) {
  const session = await getSession(request);
  const userId = session.get("userId");

  if (!userId) {
    throw redirect("/login");
  }

  return userId;
}

export async function logout(request: Request) {
  const session = await getSession(request);

  return redirect("/", {
    headers: {
      "Set-Cookie": await sessionStorage.destroySession(session),
    },
  });
}
```

## useFetcher (비폼 데이터)

```typescript
import { useFetcher } from "@remix-run/react";

function LikeButton({ postId }: { postId: string }) {
  const fetcher = useFetcher();
  const isLiking = fetcher.state !== "idle";

  return (
    <fetcher.Form method="post" action="/api/like">
      <input type="hidden" name="postId" value={postId} />
      <button type="submit" disabled={isLiking}>
        {isLiking ? "Liking..." : "Like"}
      </button>
    </fetcher.Form>
  );
}

// Optimistic UI
function TodoItem({ todo }: { todo: Todo }) {
  const fetcher = useFetcher();

  const isDeleting = fetcher.formData?.get("intent") === "delete";

  if (isDeleting) return null; // Optimistic delete

  return (
    <li>
      {todo.title}
      <fetcher.Form method="post">
        <input type="hidden" name="id" value={todo.id} />
        <button name="intent" value="delete">Delete</button>
      </fetcher.Form>
    </li>
  );
}
```

## Meta & Links

```typescript
import type { MetaFunction, LinksFunction } from "@remix-run/node";

export const meta: MetaFunction<typeof loader> = ({ data }) => {
  return [
    { title: data?.user?.name ?? "User" },
    { name: "description", content: "User profile page" },
  ];
};

export const links: LinksFunction = () => {
  return [
    { rel: "stylesheet", href: "/styles/user.css" },
    { rel: "preload", href: "/fonts/inter.woff2", as: "font" },
  ];
};
```

## Defer (스트리밍)

```typescript
import { defer } from "@remix-run/node";
import { Await, useLoaderData } from "@remix-run/react";
import { Suspense } from "react";

export async function loader({ params }: LoaderFunctionArgs) {
  const user = await db.user.findUnique({ where: { id: params.id } });

  // 느린 쿼리는 defer
  const postsPromise = db.post.findMany({ where: { authorId: params.id } });

  return defer({
    user,
    posts: postsPromise,
  });
}

export default function UserPage() {
  const { user, posts } = useLoaderData<typeof loader>();

  return (
    <div>
      <h1>{user.name}</h1>

      <Suspense fallback={<div>Loading posts...</div>}>
        <Await resolve={posts}>
          {(posts) => (
            <ul>
              {posts.map((post) => (
                <li key={post.id}>{post.title}</li>
              ))}
            </ul>
          )}
        </Await>
      </Suspense>
    </div>
  );
}
```

## 체크리스트

- [ ] v2 Flat Routes 사용
- [ ] Loader/Action 분리
- [ ] 에러 바운더리 설정
- [ ] 세션 기반 인증
- [ ] useFetcher로 인터랙션
- [ ] Defer로 스트리밍
- [ ] Meta/Links 설정

## 출력 형식

```
## Remix Implementation

### Routes
| Route | File | Description |
|-------|------|-------------|
| /users | users._index.tsx | 사용자 목록 |
| /users/:id | users.$userId.tsx | 사용자 상세 |

### Data Flow
- Loader: 서버 → 클라이언트
- Action: 폼 → 서버 → 리다이렉트

### Code
```typescript
// 구현 코드
```
```

---

요청에 맞는 Remix 구현을 설계하세요.
