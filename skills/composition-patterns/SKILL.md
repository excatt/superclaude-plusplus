---
name: composition-patterns
description: |
  React 컴포지션 패턴 - 유연하고 유지보수 가능한 컴포넌트 구조.
  Boolean prop 남용을 방지하고 Compound Components로 확장 가능한 아키텍처 구축.

  Use proactively when:
  - Boolean props가 많은 컴포넌트 리팩토링
  - 재사용 가능한 컴포넌트 라이브러리 구축
  - 유연한 컴포넌트 API 설계
  - 컴포넌트 아키텍처 리뷰
  - Compound components 또는 Context providers 작업

  Triggers: composition, compound component, boolean props, 컴포넌트 구조,
  아키텍처 리뷰, provider pattern, context, 리팩토링 컴포넌트

  Do NOT use for: 성능 최적화 (→ react-best-practices), UI/UX 검사 (→ web-design-guidelines)
user-invocable: true
metadata:
  author: vercel (adapted for SuperClaude)
  version: "1.0.0"
  source: https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns
---

# React Composition Patterns

유연하고 유지보수 가능한 React 컴포넌트를 위한 컴포지션 패턴.
Boolean prop 남용을 피하고, compound components, state lifting, composing internals를 사용합니다.

## 규칙 카테고리 (우선순위별)

| Priority | Category | Impact | 설명 |
|:--------:|----------|:------:|------|
| 1 | Component Architecture | HIGH | 컴포넌트 구조화 |
| 2 | State Management | MEDIUM | 상태 관리 패턴 |
| 3 | Implementation Patterns | MEDIUM | 구현 패턴 |
| 4 | React 19 APIs | MEDIUM | React 19 변경사항 |

---

## 1. Component Architecture (HIGH)

### 1.1 Boolean Prop 남용 방지

**Impact: CRITICAL**

Boolean props는 조합이 기하급수적으로 증가. Composition 사용 권장.

```tsx
// ❌ Boolean props 폭발 - 유지보수 불가
function Composer({
  isThread,
  isDMThread,
  isEditing,
  isForwarding,
}: Props) {
  return (
    <form>
      {isDMThread ? <DMField /> : isThread ? <ThreadField /> : null}
      {isEditing ? <EditActions /> : isForwarding ? <ForwardActions /> : <DefaultActions />}
    </form>
  )
}

// ✅ Composition - 명시적 variant
function ThreadComposer({ channelId }: { channelId: string }) {
  return (
    <Composer.Frame>
      <Composer.Input />
      <AlsoSendToChannelField id={channelId} />
      <Composer.Footer>
        <Composer.Submit />
      </Composer.Footer>
    </Composer.Frame>
  )
}

function EditComposer() {
  return (
    <Composer.Frame>
      <Composer.Input />
      <Composer.Footer>
        <Composer.CancelEdit />
        <Composer.SaveEdit />
      </Composer.Footer>
    </Composer.Frame>
  )
}
```

### 1.2 Compound Components 사용

**Impact: HIGH**

복잡한 컴포넌트를 공유 context로 연결된 subcomponents로 구조화.

```tsx
// ❌ Monolithic + render props
function Composer({
  renderHeader,
  renderFooter,
  showAttachments,
}: Props) {
  return (
    <form>
      {renderHeader?.()}
      <Input />
      {showAttachments && <Attachments />}
      {renderFooter?.()}
    </form>
  )
}

// ✅ Compound components + shared context
const ComposerContext = createContext<ComposerContextValue | null>(null)

function ComposerProvider({ children, state, actions, meta }: ProviderProps) {
  return (
    <ComposerContext value={{ state, actions, meta }}>
      {children}
    </ComposerContext>
  )
}

function ComposerInput() {
  const { state, actions: { update } } = use(ComposerContext)
  return <TextInput value={state.input} onChangeText={text => update(s => ({ ...s, input: text }))} />
}

// Export as compound component
const Composer = {
  Provider: ComposerProvider,
  Frame: ComposerFrame,
  Input: ComposerInput,
  Submit: ComposerSubmit,
  Footer: ComposerFooter,
}

// 사용
<Composer.Provider state={state} actions={actions} meta={meta}>
  <Composer.Frame>
    <Composer.Input />
    <Composer.Footer>
      <Composer.Submit />
    </Composer.Footer>
  </Composer.Frame>
</Composer.Provider>
```

---

## 2. State Management (MEDIUM)

### 2.1 State 구현과 UI 분리

**Impact: MEDIUM**

Provider만 state 구현을 알고, UI는 context interface만 사용.

```tsx
// ❌ UI가 state 구현에 결합
function ChannelComposer({ channelId }: { channelId: string }) {
  const state = useGlobalChannelState(channelId)  // 특정 구현에 결합
  const { submit } = useChannelSync(channelId)
  return <Composer.Input value={state.input} />
}

// ✅ State 관리는 Provider에서 분리
function ChannelProvider({ channelId, children }: Props) {
  const { state, update, submit } = useGlobalChannel(channelId)
  return (
    <Composer.Provider state={state} actions={{ update, submit }}>
      {children}
    </Composer.Provider>
  )
}

// UI는 interface만 알면 됨
function ChannelComposer() {
  return (
    <Composer.Frame>
      <Composer.Input />  {/* context에서 state 읽음 */}
      <Composer.Submit />
    </Composer.Frame>
  )
}
```

### 2.2 Generic Context Interface 정의

**Impact: HIGH**

`state`, `actions`, `meta` 3부분으로 generic interface 정의.

```tsx
// Generic interface - 어떤 provider든 구현 가능
interface ComposerContextValue {
  state: {
    input: string
    attachments: Attachment[]
    isSubmitting: boolean
  }
  actions: {
    update: (updater: (state: State) => State) => void
    submit: () => void
  }
  meta: {
    inputRef: React.RefObject<TextInput>
  }
}

// Provider A: Local state
function ForwardMessageProvider({ children }) {
  const [state, setState] = useState(initialState)
  return <ComposerContext value={{ state, actions: { update: setState, submit }, meta }}>{children}</ComposerContext>
}

// Provider B: Global synced state
function ChannelProvider({ channelId, children }) {
  const { state, update, submit } = useGlobalChannel(channelId)
  return <ComposerContext value={{ state, actions: { update, submit }, meta }}>{children}</ComposerContext>
}

// 같은 UI가 두 Provider 모두에서 동작!
```

### 2.3 State를 Provider로 Lift

**Impact: HIGH**

State를 Provider로 올려서 형제 컴포넌트들이 접근 가능하게.

```tsx
// ❌ State가 컴포넌트 내부에 갇힘
function ForwardMessageDialog() {
  return (
    <Dialog>
      <ForwardMessageComposer />  {/* state 여기 안에 */}
      <MessagePreview />          {/* state 접근 불가! */}
      <ForwardButton />           {/* submit 호출 불가! */}
    </Dialog>
  )
}

// ✅ State를 Provider로 lift
function ForwardMessageDialog() {
  return (
    <ForwardMessageProvider>
      <Dialog>
        <ForwardMessageComposer />
        <MessagePreview />    {/* context로 state 접근 */}
        <ForwardButton />     {/* context로 submit 호출 */}
      </Dialog>
    </ForwardMessageProvider>
  )
}

// Provider 내부면 어디서든 state/actions 접근 가능
function ForwardButton() {
  const { actions } = use(ComposerContext)
  return <Button onPress={actions.submit}>Forward</Button>
}
```

---

## 3. Implementation Patterns (MEDIUM)

### 3.1 명시적 Component Variants 생성

**Impact: MEDIUM**

Boolean props 대신 명시적 variant 컴포넌트 생성.

```tsx
// ❌ 무슨 UI가 렌더링되는지 불명확
<Composer isThread isEditing={false} channelId="abc" showAttachments />

// ✅ 즉시 명확
<ThreadComposer channelId="abc" />
<EditMessageComposer messageId="xyz" />
<ForwardMessageComposer messageId="123" />
```

### 3.2 Render Props보다 Children 선호

**Impact: MEDIUM**

`renderX` props 대신 `children`으로 composition.

```tsx
// ❌ Render props - 읽기 어려움
<Composer
  renderHeader={() => <CustomHeader />}
  renderFooter={() => <><Formatting /><Emojis /></>}
/>

// ✅ Children - 자연스러운 composition
<Composer.Frame>
  <CustomHeader />
  <Composer.Input />
  <Composer.Footer>
    <Composer.Formatting />
    <Composer.Emojis />
  </Composer.Footer>
</Composer.Frame>
```

**Render props가 적절한 경우**: 부모가 데이터를 자식에게 전달해야 할 때

```tsx
<List data={items} renderItem={({ item, index }) => <Item item={item} />} />
```

---

## 4. React 19 APIs (MEDIUM)

> **⚠️ React 19+ 전용**. React 18 이하면 이 섹션 스킵.

### 4.1 React 19 API 변경

```tsx
// ❌ forwardRef (React 19에서 불필요)
const ComposerInput = forwardRef<TextInput, Props>((props, ref) => {
  return <TextInput ref={ref} {...props} />
})

// ✅ ref는 일반 prop
function ComposerInput({ ref, ...props }: Props & { ref?: React.Ref<TextInput> }) {
  return <TextInput ref={ref} {...props} />
}

// ❌ useContext (React 19)
const value = useContext(MyContext)

// ✅ use() 사용 - 조건부 호출도 가능
const value = use(MyContext)
```

---

## Quick Checklist

| 체크 | 규칙 |
|:----:|------|
| [ ] | Boolean props 3개 이상? → Composition으로 리팩토링 |
| [ ] | 조건부 렌더링 복잡? → Explicit variants 생성 |
| [ ] | State가 컴포넌트에 갇힘? → Provider로 lift |
| [ ] | renderX props? → children으로 변경 |
| [ ] | React 19? → forwardRef 제거, use() 사용 |

## 관련 스킬

- `/react-best-practices` - 성능 최적화 (워터폴, 번들, 렌더링)
- `/web-design-guidelines` - UI/UX 품질 (접근성, 인터랙션)
- `/design-patterns` - 일반 디자인 패턴
