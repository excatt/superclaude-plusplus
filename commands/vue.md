# Vue Skill

Vue 3 Composition API 패턴 가이드를 실행합니다.

## 프로젝트 구조

```
src/
├── main.ts
├── App.vue
├── components/
│   ├── common/
│   └── features/
├── composables/           # Composition 함수
│   ├── useAuth.ts
│   └── useFetch.ts
├── stores/                # Pinia 스토어
│   └── user.ts
├── views/                 # 페이지 컴포넌트
├── router/
│   └── index.ts
├── types/
└── utils/
```

## Composition API 기본

### Script Setup
```vue
<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'

// Props 정의
const props = defineProps<{
  title: string
  count?: number
}>()

// Emits 정의
const emit = defineEmits<{
  (e: 'update', value: number): void
  (e: 'close'): void
}>()

// Reactive State
const count = ref(0)
const user = ref<User | null>(null)

// Computed
const doubleCount = computed(() => count.value * 2)

// Methods
function increment() {
  count.value++
  emit('update', count.value)
}

// Lifecycle
onMounted(async () => {
  user.value = await fetchUser()
})

// Watch
watch(count, (newVal, oldVal) => {
  console.log(`Count changed from ${oldVal} to ${newVal}`)
})
</script>

<template>
  <div>
    <h1>{{ props.title }}</h1>
    <p>Count: {{ count }} (Double: {{ doubleCount }})</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

## Composables (커스텀 훅)

### useFetch
```typescript
// composables/useFetch.ts
import { ref, shallowRef } from 'vue'

interface UseFetchOptions {
  immediate?: boolean
}

export function useFetch<T>(url: string, options: UseFetchOptions = {}) {
  const data = shallowRef<T | null>(null)
  const error = ref<Error | null>(null)
  const isLoading = ref(false)

  async function execute() {
    isLoading.value = true
    error.value = null

    try {
      const response = await fetch(url)
      if (!response.ok) throw new Error('Network error')
      data.value = await response.json()
    } catch (e) {
      error.value = e as Error
    } finally {
      isLoading.value = false
    }
  }

  if (options.immediate !== false) {
    execute()
  }

  return { data, error, isLoading, execute }
}

// 사용
const { data: users, isLoading, execute: refetch } = useFetch<User[]>('/api/users')
```

### useAuth
```typescript
// composables/useAuth.ts
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const user = ref<User | null>(null)
const token = ref<string | null>(localStorage.getItem('token'))

export function useAuth() {
  const router = useRouter()

  const isAuthenticated = computed(() => !!token.value)

  async function login(email: string, password: string) {
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })
    const data = await response.json()

    token.value = data.token
    user.value = data.user
    localStorage.setItem('token', data.token)

    router.push('/dashboard')
  }

  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    router.push('/login')
  }

  return { user, token, isAuthenticated, login, logout }
}
```

## Pinia (State Management)

### Store 정의
```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // State
  const users = ref<User[]>([])
  const currentUser = ref<User | null>(null)
  const isLoading = ref(false)

  // Getters
  const activeUsers = computed(() =>
    users.value.filter(u => u.isActive)
  )

  const userCount = computed(() => users.value.length)

  // Actions
  async function fetchUsers() {
    isLoading.value = true
    try {
      const response = await fetch('/api/users')
      users.value = await response.json()
    } finally {
      isLoading.value = false
    }
  }

  async function createUser(data: CreateUserDTO) {
    const response = await fetch('/api/users', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    const newUser = await response.json()
    users.value.push(newUser)
    return newUser
  }

  function setCurrentUser(user: User) {
    currentUser.value = user
  }

  // Persist (with pinia-plugin-persistedstate)
  return {
    users,
    currentUser,
    isLoading,
    activeUsers,
    userCount,
    fetchUsers,
    createUser,
    setCurrentUser,
  }
}, {
  persist: true,
})

// 사용
const userStore = useUserStore()
await userStore.fetchUsers()
```

## Vue Router

### 설정
```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/views/Home.vue'),
  },
  {
    path: '/users',
    component: () => import('@/views/Users.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/users/:id',
    component: () => import('@/views/UserDetail.vue'),
    props: true,
  },
  {
    path: '/:pathMatch(.*)*',
    component: () => import('@/views/NotFound.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation Guard
router.beforeEach((to, from) => {
  const { isAuthenticated } = useAuth()

  if (to.meta.requiresAuth && !isAuthenticated.value) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }
})

export default router
```

### useRoute / useRouter
```vue
<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { watch } from 'vue'

const route = useRoute()
const router = useRouter()

// 파라미터 접근
const userId = computed(() => route.params.id as string)

// 쿼리 접근
const page = computed(() => Number(route.query.page) || 1)

// 라우트 변경 감지
watch(() => route.params.id, (newId) => {
  fetchUser(newId)
})

// 프로그래매틱 네비게이션
function goToUser(id: string) {
  router.push({ name: 'user', params: { id } })
}
</script>
```

## 컴포넌트 패턴

### v-model 커스텀
```vue
<!-- components/CustomInput.vue -->
<script setup lang="ts">
const model = defineModel<string>()
</script>

<template>
  <input v-model="model" />
</template>

<!-- 사용 -->
<CustomInput v-model="username" />
```

### Slots
```vue
<!-- components/Card.vue -->
<script setup lang="ts">
defineSlots<{
  default(): any
  header?(): any
  footer?(): any
}>()
</script>

<template>
  <div class="card">
    <div v-if="$slots.header" class="card-header">
      <slot name="header" />
    </div>
    <div class="card-body">
      <slot />
    </div>
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>
```

### Provide / Inject
```typescript
// 부모 컴포넌트
import { provide, ref } from 'vue'

const theme = ref('dark')
provide('theme', theme)

// 자식 컴포넌트
import { inject } from 'vue'

const theme = inject<Ref<string>>('theme', ref('light'))
```

## Form Handling

### VeeValidate + Zod
```vue
<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

const schema = toTypedSchema(
  z.object({
    email: z.string().email('Invalid email'),
    password: z.string().min(8, 'Min 8 characters'),
  })
)

const { handleSubmit, errors, defineField, isSubmitting } = useForm({
  validationSchema: schema,
})

const [email, emailAttrs] = defineField('email')
const [password, passwordAttrs] = defineField('password')

const onSubmit = handleSubmit(async (values) => {
  await login(values.email, values.password)
})
</script>

<template>
  <form @submit="onSubmit">
    <div>
      <input v-model="email" v-bind="emailAttrs" type="email" />
      <span v-if="errors.email">{{ errors.email }}</span>
    </div>
    <div>
      <input v-model="password" v-bind="passwordAttrs" type="password" />
      <span v-if="errors.password">{{ errors.password }}</span>
    </div>
    <button type="submit" :disabled="isSubmitting">Login</button>
  </form>
</template>
```

## Suspense & 비동기 컴포넌트

```vue
<!-- 비동기 컴포넌트 -->
<script setup lang="ts">
const user = await fetchUser() // top-level await
</script>

<!-- 부모에서 Suspense 사용 -->
<template>
  <Suspense>
    <template #default>
      <UserProfile />
    </template>
    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>
```

## 체크리스트

- [ ] Composition API (script setup)
- [ ] TypeScript 타입 정의
- [ ] Pinia 상태 관리
- [ ] Composables 추출
- [ ] Vue Router 설정
- [ ] 폼 검증
- [ ] 에러 핸들링

## 출력 형식

```
## Vue Implementation

### Components
| Component | Props | Emits |
|-----------|-------|-------|
| UserCard | user: User | select |

### Composables
| Hook | Returns | Usage |
|------|---------|-------|
| useAuth | user, login, logout | 인증 |

### Stores
| Store | State | Actions |
|-------|-------|---------|
| user | users[], isLoading | fetchUsers |
```

---

요청에 맞는 Vue 3 구현을 설계하세요.
