# Svelte Skill

Svelte 5 (Runes) 패턴 가이드를 실행합니다.

## 프로젝트 구조 (SvelteKit)

```
src/
├── app.html
├── app.d.ts
├── lib/
│   ├── components/
│   ├── stores/
│   ├── utils/
│   └── server/           # 서버 전용
├── routes/
│   ├── +page.svelte
│   ├── +page.server.ts
│   ├── +layout.svelte
│   ├── api/
│   │   └── users/
│   │       └── +server.ts
│   └── users/
│       ├── +page.svelte
│       ├── +page.ts
│       └── [id]/
│           └── +page.svelte
└── hooks.server.ts
```

## Svelte 5 Runes

### State ($state)
```svelte
<script lang="ts">
  // 반응형 상태
  let count = $state(0)
  let user = $state<User | null>(null)

  // 객체/배열도 반응형
  let todos = $state<Todo[]>([])

  function addTodo(text: string) {
    todos.push({ id: Date.now(), text, done: false })
  }

  function toggleTodo(id: number) {
    const todo = todos.find(t => t.id === id)
    if (todo) todo.done = !todo.done
  }
</script>

<p>Count: {count}</p>
<button onclick={() => count++}>Increment</button>

{#each todos as todo}
  <div>
    <input type="checkbox" checked={todo.done} onchange={() => toggleTodo(todo.id)} />
    {todo.text}
  </div>
{/each}
```

### Derived ($derived)
```svelte
<script lang="ts">
  let count = $state(0)
  let multiplier = $state(2)

  // 자동 계산되는 값
  let doubled = $derived(count * 2)
  let result = $derived(count * multiplier)

  // 복잡한 계산
  let stats = $derived.by(() => {
    const total = items.reduce((sum, i) => sum + i.price, 0)
    const average = items.length ? total / items.length : 0
    return { total, average }
  })
</script>
```

### Effects ($effect)
```svelte
<script lang="ts">
  let count = $state(0)

  // 의존성 자동 추적
  $effect(() => {
    console.log(`Count changed to ${count}`)
  })

  // 클린업
  $effect(() => {
    const interval = setInterval(() => count++, 1000)
    return () => clearInterval(interval)
  })

  // Pre-effect (DOM 업데이트 전)
  $effect.pre(() => {
    // DOM 업데이트 전에 실행
  })
</script>
```

### Props ($props)
```svelte
<!-- UserCard.svelte -->
<script lang="ts">
  interface Props {
    user: User
    showEmail?: boolean
    onSelect?: (user: User) => void
  }

  let { user, showEmail = true, onSelect }: Props = $props()
</script>

<div class="card" onclick={() => onSelect?.(user)}>
  <h3>{user.name}</h3>
  {#if showEmail}
    <p>{user.email}</p>
  {/if}
</div>
```

### Bindable ($bindable)
```svelte
<!-- TextInput.svelte -->
<script lang="ts">
  let { value = $bindable('') }: { value: string } = $props()
</script>

<input bind:value />

<!-- 사용 -->
<script lang="ts">
  let name = $state('')
</script>

<TextInput bind:value={name} />
```

## SvelteKit 라우팅

### Page Load
```typescript
// routes/users/+page.ts (클라이언트 & 서버)
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ fetch, params }) => {
  const response = await fetch('/api/users')
  const users: User[] = await response.json()

  return { users }
}

// routes/users/+page.server.ts (서버 전용)
import type { PageServerLoad } from './$types'
import { db } from '$lib/server/db'

export const load: PageServerLoad = async ({ params }) => {
  const users = await db.user.findMany()
  return { users }
}
```

### Page Component
```svelte
<!-- routes/users/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types'

  let { data }: { data: PageData } = $props()
</script>

<h1>Users</h1>
{#each data.users as user}
  <UserCard {user} />
{/each}
```

### Form Actions
```typescript
// routes/users/+page.server.ts
import type { Actions } from './$types'
import { fail, redirect } from '@sveltejs/kit'

export const actions: Actions = {
  create: async ({ request }) => {
    const formData = await request.formData()
    const name = formData.get('name') as string
    const email = formData.get('email') as string

    if (!name || !email) {
      return fail(400, { error: 'Name and email required', name, email })
    }

    const user = await db.user.create({ data: { name, email } })
    throw redirect(303, `/users/${user.id}`)
  },

  delete: async ({ request }) => {
    const formData = await request.formData()
    const id = formData.get('id') as string

    await db.user.delete({ where: { id } })
    return { success: true }
  }
}
```

```svelte
<!-- routes/users/+page.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms'
  import type { ActionData, PageData } from './$types'

  let { data, form }: { data: PageData, form: ActionData } = $props()
</script>

<form method="POST" action="?/create" use:enhance>
  <input name="name" value={form?.name ?? ''} />
  <input name="email" value={form?.email ?? ''} />
  {#if form?.error}
    <p class="error">{form.error}</p>
  {/if}
  <button type="submit">Create User</button>
</form>
```

### API Routes
```typescript
// routes/api/users/+server.ts
import { json, error } from '@sveltejs/kit'
import type { RequestHandler } from './$types'

export const GET: RequestHandler = async ({ url }) => {
  const search = url.searchParams.get('search') || ''

  const users = await db.user.findMany({
    where: { name: { contains: search } }
  })

  return json(users)
}

export const POST: RequestHandler = async ({ request }) => {
  const data = await request.json()

  if (!data.email) {
    throw error(400, 'Email is required')
  }

  const user = await db.user.create({ data })
  return json(user, { status: 201 })
}
```

## Stores (Svelte 5)

### Writable Store with Runes
```typescript
// lib/stores/counter.svelte.ts
class Counter {
  count = $state(0)

  increment() {
    this.count++
  }

  decrement() {
    this.count--
  }

  reset() {
    this.count = 0
  }
}

export const counter = new Counter()

// 사용
<script lang="ts">
  import { counter } from '$lib/stores/counter.svelte'
</script>

<p>{counter.count}</p>
<button onclick={() => counter.increment()}>+</button>
```

### Auth Store
```typescript
// lib/stores/auth.svelte.ts
import { goto } from '$app/navigation'

class AuthStore {
  user = $state<User | null>(null)
  token = $state<string | null>(null)

  isAuthenticated = $derived(!!this.token)

  async login(email: string, password: string) {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })
    const data = await response.json()

    this.user = data.user
    this.token = data.token

    goto('/dashboard')
  }

  logout() {
    this.user = null
    this.token = null
    goto('/login')
  }
}

export const auth = new AuthStore()
```

## 컴포넌트 패턴

### Snippets (Svelte 5)
```svelte
<script lang="ts">
  import type { Snippet } from 'svelte'

  interface Props {
    items: Item[]
    header?: Snippet
    row: Snippet<[Item]>
  }

  let { items, header, row }: Props = $props()
</script>

<table>
  {#if header}
    <thead>
      {@render header()}
    </thead>
  {/if}
  <tbody>
    {#each items as item}
      {@render row(item)}
    {/each}
  </tbody>
</table>

<!-- 사용 -->
<Table {items}>
  {#snippet header()}
    <tr><th>Name</th><th>Email</th></tr>
  {/snippet}
  {#snippet row(item)}
    <tr><td>{item.name}</td><td>{item.email}</td></tr>
  {/snippet}
</Table>
```

### Context
```svelte
<!-- Provider.svelte -->
<script lang="ts">
  import { setContext } from 'svelte'

  const theme = $state({ mode: 'dark', primary: '#007bff' })
  setContext('theme', theme)
</script>

<slot />

<!-- Consumer.svelte -->
<script lang="ts">
  import { getContext } from 'svelte'

  const theme = getContext<{ mode: string; primary: string }>('theme')
</script>

<div style="color: {theme.primary}">...</div>
```

## Hooks

```typescript
// src/hooks.server.ts
import type { Handle } from '@sveltejs/kit'

export const handle: Handle = async ({ event, resolve }) => {
  // 인증 체크
  const token = event.cookies.get('token')

  if (token) {
    const user = await verifyToken(token)
    event.locals.user = user
  }

  // 보호된 라우트
  if (event.url.pathname.startsWith('/dashboard')) {
    if (!event.locals.user) {
      return new Response(null, {
        status: 303,
        headers: { location: '/login' }
      })
    }
  }

  return resolve(event)
}
```

## 체크리스트

- [ ] Svelte 5 Runes ($state, $derived, $effect)
- [ ] SvelteKit 라우팅
- [ ] Form Actions
- [ ] API Routes
- [ ] Class-based Stores
- [ ] TypeScript 타입
- [ ] Hooks 설정

## 출력 형식

```
## Svelte Implementation

### Routes
| Route | Load | Actions |
|-------|------|---------|
| /users | PageServerLoad | create, delete |

### Components
| Component | Props | Events |
|-----------|-------|--------|
| UserCard | user: User | onclick |

### Stores
| Store | State | Methods |
|-------|-------|---------|
| auth | user, token | login, logout |
```

---

요청에 맞는 Svelte 5 구현을 설계하세요.
