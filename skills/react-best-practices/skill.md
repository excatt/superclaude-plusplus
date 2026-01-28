---
name: react-best-practices
description: Vercel Engineering's React & Next.js performance optimization guide. Use when writing React components, implementing data fetching, reviewing code for performance, refactoring, or optimizing bundle size. Contains 40+ rules across 8 priority categories.
source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
version: 1.0.0
---

# Vercel React Best Practices

Comprehensive performance optimization guide for React and Next.js applications, maintained by Vercel Engineering. Contains 40+ rules across 8 categories prioritized by impact.

## When to Apply

Reference these guidelines when:
- Writing new React components or Next.js pages
- Implementing data fetching patterns
- Reviewing code for performance issues
- Refactoring existing code
- Optimizing bundle size or load times

---

## Priority 1: Eliminating Waterfalls (CRITICAL)

**Impact**: 2-10x performance improvement

### Rule 1.1: Defer await to Point of Use

Move `await` statements to where the data is actually needed.

```tsx
// ❌ Incorrect - blocks entire function
async function Page() {
  const data = await fetchData();
  const user = await fetchUser();
  return <Component data={data} user={user} />;
}

// ✅ Correct - parallel fetching
async function Page() {
  const dataPromise = fetchData();
  const userPromise = fetchUser();
  return <Component dataPromise={dataPromise} userPromise={userPromise} />;
}
```

### Rule 1.2: Use Promise.all for Independent Operations

Execute independent operations concurrently.

```tsx
// ❌ Incorrect - sequential
const users = await getUsers();
const posts = await getPosts();
const comments = await getComments();

// ✅ Correct - parallel
const [users, posts, comments] = await Promise.all([
  getUsers(),
  getPosts(),
  getComments()
]);
```

### Rule 1.3: Dependency-Based Parallelization

Use `better-all` for operations with complex dependencies.

```tsx
import { all } from 'better-all';

// ✅ Correct - handles dependencies automatically
const { user, posts, notifications } = await all({
  user: () => fetchUser(userId),
  posts: ({ user }) => fetchPosts(user.id),
  notifications: ({ user }) => fetchNotifications(user.id)
});
```

### Rule 1.4: Strategic Suspense Boundaries

Deploy Suspense boundaries for faster initial paint.

```tsx
// ✅ Correct - progressive loading
function Page() {
  return (
    <div>
      <Header /> {/* Renders immediately */}
      <Suspense fallback={<Skeleton />}>
        <SlowContent /> {/* Streams in when ready */}
      </Suspense>
    </div>
  );
}
```

---

## Priority 2: Bundle Size Optimization (CRITICAL)

**Impact**: 200-800ms faster load times

### Rule 2.1: Avoid Barrel File Imports

Use direct source imports instead of barrel files.

```tsx
// ❌ Incorrect - imports entire barrel
import { Button } from '@/components';
import { formatDate } from '@/utils';

// ✅ Correct - direct imports
import { Button } from '@/components/Button';
import { formatDate } from '@/utils/formatDate';
```

### Rule 2.2: Dynamic Import Heavy Components

Lazy-load components that aren't immediately needed.

```tsx
import dynamic from 'next/dynamic';

// ✅ Correct - lazy load heavy component
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false // Skip SSR for client-only components
});
```

### Rule 2.3: Defer Third-Party Scripts

Load non-critical scripts after hydration.

```tsx
import Script from 'next/script';

// ✅ Correct - deferred loading
<Script
  src="https://analytics.example.com/script.js"
  strategy="lazyOnload"
/>
```

### Rule 2.4: Conditional Module Loading

Load modules only when features are active.

```tsx
// ✅ Correct - load only when needed
async function handleAdvancedFeature() {
  const { advancedFunction } = await import('./advancedModule');
  return advancedFunction();
}
```

### Rule 2.5: Intent-Based Preloading

Preload bundles based on user intent.

```tsx
// ✅ Correct - preload on hover
function NavLink({ href, children }) {
  const handleMouseEnter = () => {
    import(`./pages${href}`); // Preload the route
  };

  return (
    <Link href={href} onMouseEnter={handleMouseEnter}>
      {children}
    </Link>
  );
}
```

---

## Priority 3: Server-Side Performance (HIGH)

### Rule 3.1: Use React.cache for Request Deduplication

Deduplicate data fetching within a single request.

```tsx
import { cache } from 'react';

// ✅ Correct - cached per request
export const getUser = cache(async (id: string) => {
  return await db.user.findUnique({ where: { id } });
});
```

### Rule 3.2: Cross-Request LRU Caching

Cache expensive computations across requests.

```tsx
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, any>({ max: 500 });

// ✅ Correct - cross-request cache
export async function getExpensiveData(key: string) {
  if (cache.has(key)) return cache.get(key);
  const data = await computeExpensive(key);
  cache.set(key, data);
  return data;
}
```

### Rule 3.3: Minimize RSC Serialization

Reduce data passed across RSC boundaries.

```tsx
// ❌ Incorrect - passes entire object
<ClientComponent user={fullUserObject} />

// ✅ Correct - minimal data
<ClientComponent
  userName={user.name}
  userAvatar={user.avatar}
/>
```

### Rule 3.4: Parallel Data Fetching via Composition

Structure components to enable parallel fetching.

```tsx
// ✅ Correct - parallel through composition
function Page() {
  return (
    <>
      <UserSection userId={id} />      {/* fetches user */}
      <PostsSection userId={id} />     {/* fetches posts in parallel */}
      <CommentsSection postId={pid} /> {/* fetches comments in parallel */}
    </>
  );
}
```

### Rule 3.5: Non-Blocking Operations with after()

Schedule operations that don't block the response.

```tsx
import { after } from 'next/server';

// ✅ Correct - non-blocking analytics
export async function GET() {
  const data = await fetchData();

  after(() => {
    logAnalytics(data); // Runs after response sent
  });

  return Response.json(data);
}
```

---

## Priority 4: Client-Side Data Fetching (MEDIUM-HIGH)

### Rule 4.1: Automatic Deduplication with SWR

Use SWR for client-side data fetching with built-in deduplication.

```tsx
import useSWR from 'swr';

// ✅ Correct - deduplicated across components
function useUser(id: string) {
  return useSWR(`/api/user/${id}`, fetcher);
}
```

### Rule 4.2: useSWRSubscription for Event Listeners

Deduplicate global event listeners.

```tsx
import useSWRSubscription from 'swr/subscription';

// ✅ Correct - single listener, shared state
function useOnlineStatus() {
  return useSWRSubscription('online-status', (key, { next }) => {
    const handler = () => next(null, navigator.onLine);
    window.addEventListener('online', handler);
    window.addEventListener('offline', handler);
    return () => {
      window.removeEventListener('online', handler);
      window.removeEventListener('offline', handler);
    };
  });
}
```

---

## Priority 5: Re-render Optimization (MEDIUM)

### Rule 5.1: Defer State Reads

Read state at the point of use, not at the top of components.

```tsx
// ❌ Incorrect - reads at top, re-renders entire tree
function Parent() {
  const count = useStore(state => state.count);
  return <Child count={count} />;
}

// ✅ Correct - reads where needed
function Parent() {
  return <Child />;
}

function Child() {
  const count = useStore(state => state.count);
  return <span>{count}</span>;
}
```

### Rule 5.2: Extract Work into Memoized Components

Isolate expensive renders.

```tsx
// ✅ Correct - isolated expensive render
const ExpensiveList = memo(function ExpensiveList({ items }) {
  return items.map(item => <ExpensiveItem key={item.id} item={item} />);
});

function Parent({ items, otherState }) {
  return (
    <div>
      <ExpensiveList items={items} />
      <CheapComponent state={otherState} />
    </div>
  );
}
```

### Rule 5.3: Narrow Effect Dependencies

Use primitives instead of objects in dependency arrays.

```tsx
// ❌ Incorrect - object reference changes
useEffect(() => {
  fetchData(user);
}, [user]);

// ✅ Correct - stable primitive
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

### Rule 5.4: Functional setState Updates

Prevent stale closures with functional updates.

```tsx
// ❌ Incorrect - may use stale count
setCount(count + 1);

// ✅ Correct - always uses current value
setCount(prev => prev + 1);
```

### Rule 5.5: Lazy State Initialization

Defer expensive initial state computation.

```tsx
// ❌ Incorrect - runs every render
const [data, setData] = useState(expensiveComputation());

// ✅ Correct - runs once
const [data, setData] = useState(() => expensiveComputation());
```

### Rule 5.6: Mark Non-Urgent Updates as Transitions

Use transitions for non-critical updates.

```tsx
import { useTransition } from 'react';

function SearchResults() {
  const [isPending, startTransition] = useTransition();

  const handleSearch = (query) => {
    startTransition(() => {
      setSearchResults(filterResults(query));
    });
  };
}
```

---

## Priority 6: Rendering Performance (MEDIUM)

### Rule 6.1: Hoist Static JSX

Move static elements outside components.

```tsx
// ✅ Correct - static JSX hoisted
const StaticHeader = <header><h1>Welcome</h1></header>;

function Page() {
  return (
    <div>
      {StaticHeader}
      <DynamicContent />
    </div>
  );
}
```

### Rule 6.2: Use content-visibility for Long Lists

Apply CSS containment for off-screen content.

```css
/* ✅ Correct - skip rendering off-screen items */
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 50px;
}
```

### Rule 6.3: Activity Components for Frequent Toggles

Use Activity (or custom equivalent) for frequently shown/hidden content.

```tsx
// ✅ Correct - preserves state, skips unmount/remount
<Activity mode={isVisible ? 'visible' : 'hidden'}>
  <ExpensiveComponent />
</Activity>
```

### Rule 6.4: Hardware-Accelerated SVG Animation

Animate wrapper elements for better performance.

```tsx
// ✅ Correct - hardware acceleration
<motion.div animate={{ x: 100 }}>
  <svg>{/* static SVG content */}</svg>
</motion.div>
```

### Rule 6.5: Explicit Conditional Rendering

Use ternary operators for clearer render paths.

```tsx
// ❌ Incorrect - implicit falsy render
{items.length && <List items={items} />}

// ✅ Correct - explicit conditional
{items.length > 0 ? <List items={items} /> : null}
```

---

## Priority 7: JavaScript Performance (LOW-MEDIUM)

### Rule 7.1: Build Index Maps for Lookups

Replace repeated array searches with Map lookups.

```tsx
// ❌ Incorrect - O(n) per lookup
const user = users.find(u => u.id === targetId);

// ✅ Correct - O(1) lookup
const userMap = new Map(users.map(u => [u.id, u]));
const user = userMap.get(targetId);
```

### Rule 7.2: Use Set for Membership Checks

O(1) instead of O(n) for includes checks.

```tsx
// ❌ Incorrect - O(n)
if (allowedIds.includes(id)) { }

// ✅ Correct - O(1)
const allowedSet = new Set(allowedIds);
if (allowedSet.has(id)) { }
```

### Rule 7.3: Cache Property Access in Loops

Avoid repeated property lookups.

```tsx
// ❌ Incorrect - repeated access
for (let i = 0; i < arr.length; i++) {
  process(obj.nested.value);
}

// ✅ Correct - cached access
const { length } = arr;
const { value } = obj.nested;
for (let i = 0; i < length; i++) {
  process(value);
}
```

### Rule 7.4: Batch DOM CSS Changes

Use classes or cssText for multiple style changes.

```tsx
// ❌ Incorrect - multiple reflows
el.style.width = '100px';
el.style.height = '100px';
el.style.margin = '10px';

// ✅ Correct - single reflow
el.classList.add('active-state');
// or
el.style.cssText = 'width:100px;height:100px;margin:10px';
```

### Rule 7.5: Hoist RegExp Outside Renders

Avoid recreating RegExp on every render.

```tsx
// ❌ Incorrect - creates new RegExp each render
function Component({ value }) {
  const isValid = /^[a-z]+$/.test(value);
}

// ✅ Correct - single instance
const ALPHA_REGEX = /^[a-z]+$/;
function Component({ value }) {
  const isValid = ALPHA_REGEX.test(value);
}
```

### Rule 7.6: Early Returns

Exit functions early when possible.

```tsx
// ✅ Correct - early return pattern
function processUser(user) {
  if (!user) return null;
  if (!user.active) return null;
  return performExpensiveOperation(user);
}
```

### Rule 7.7: Prefer .toSorted() Over .sort()

Avoid mutating original arrays.

```tsx
// ❌ Incorrect - mutates original
const sorted = items.sort((a, b) => a.id - b.id);

// ✅ Correct - returns new array
const sorted = items.toSorted((a, b) => a.id - b.id);
```

---

## Priority 8: Advanced Patterns (LOW)

### Rule 8.1: Store Event Handlers in Refs

Stable subscriptions without effect re-runs.

```tsx
// ✅ Correct - stable callback reference
const callbackRef = useRef(callback);
callbackRef.current = callback;

useEffect(() => {
  return subscribe(() => callbackRef.current());
}, []); // Empty deps - never re-subscribes
```

### Rule 8.2: useEffectEvent for Fresh Callbacks

Access latest values without re-running effects.

```tsx
// ✅ Correct - stable effect with fresh values
const onTick = useEffectEvent(() => {
  logCurrentState(state); // Always has latest state
});

useEffect(() => {
  const id = setInterval(onTick, 1000);
  return () => clearInterval(id);
}, []); // Never re-creates interval
```

---

## Important Caveats

1. **React Compiler**: Some optimizations (memo, useMemo hoisting) are handled automatically by React Compiler when enabled.

2. **Measure First**: Apply optimizations based on measured bottlenecks, not assumptions.

3. **Context Matters**: Pattern selection depends on specific use cases and trade-offs.

4. **Progressive Enhancement**: Start with critical optimizations (Priority 1-2) before lower priorities.

---

## Tools Referenced

- **better-all**: Dependency-based parallelization
- **lru-cache**: Cross-request caching
- **SWR**: Client-side data fetching with deduplication
- **SVGO**: SVG optimization
- **Motion**: Animation library for React
