---
name: composition-patterns
description: |
  React composition patterns - Flexible and maintainable component structure.
  Prevent boolean prop abuse and build extensible architecture with Compound Components.

  Use proactively when:
  - Refactoring components with many boolean props
  - Building reusable component libraries
  - Designing flexible component APIs
  - Reviewing component architecture
  - Working with compound components or Context providers

  Triggers: composition, compound component, boolean props, component structure,
  architecture review, provider pattern, context, refactor component

  Do NOT use for: Performance optimization (→ react-best-practices), UI/UX inspection (→ web-design-guidelines)
user-invocable: true
metadata:
  author: vercel (adapted for SuperClaude)
  version: "1.0.0"
  source: https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns
---

# React Composition Patterns

Composition patterns for flexible and maintainable React components.
Avoid boolean prop abuse, use compound components, state lifting, and composing internals.

## Rule Categories (by Priority)

| Priority | Category | Impact | Description |
|:--------:|----------|:------:|-------------|
| 1 | Component Architecture | HIGH | Component structuring |
| 2 | State Management | MEDIUM | State management patterns |
| 3 | Implementation Patterns | MEDIUM | Implementation patterns |
| 4 | React 19 APIs | MEDIUM | React 19 changes |

---

## 1. Component Architecture (HIGH)

### 1.1 Prevent Boolean Prop Abuse

**Impact: CRITICAL**

Boolean props lead to combinatorial explosion. Use composition instead.

```tsx
// ❌ Boolean prop explosion - unmaintainable
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

// ✅ Composition - explicit variants
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

### 1.2 Use Compound Components

**Impact: HIGH**

Structure complex components into subcomponents connected by shared context.

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

// Usage
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

### 2.1 Separate State Implementation from UI

**Impact: MEDIUM**

Provider knows state implementation, UI only uses context interface.

```tsx
// ❌ UI coupled to state implementation
function ChannelComposer({ channelId }: { channelId: string }) {
  const state = useGlobalChannelState(channelId)  // Coupled to specific implementation
  const { submit } = useChannelSync(channelId)
  return <Composer.Input value={state.input} />
}

// ✅ State management separated in Provider
function ChannelProvider({ channelId, children }: Props) {
  const { state, update, submit } = useGlobalChannel(channelId)
  return (
    <Composer.Provider state={state} actions={{ update, submit }}>
      {children}
    </Composer.Provider>
  )
}

// UI only needs interface
function ChannelComposer() {
  return (
    <Composer.Frame>
      <Composer.Input />  {/* Reads state from context */}
      <Composer.Submit />
    </Composer.Frame>
  )
}
```

### 2.2 Define Generic Context Interface

**Impact: HIGH**

Define generic interface with 3 parts: `state`, `actions`, `meta`.

```tsx
// Generic interface - any provider can implement
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

// Same UI works with both providers!
```

### 2.3 Lift State to Provider

**Impact: HIGH**

Lift state to Provider so sibling components can access it.

```tsx
// ❌ State trapped inside component
function ForwardMessageDialog() {
  return (
    <Dialog>
      <ForwardMessageComposer />  {/* state trapped here */}
      <MessagePreview />          {/* Cannot access state! */}
      <ForwardButton />           {/* Cannot call submit! */}
    </Dialog>
  )
}

// ✅ Lift state to Provider
function ForwardMessageDialog() {
  return (
    <ForwardMessageProvider>
      <Dialog>
        <ForwardMessageComposer />
        <MessagePreview />    {/* Access state via context */}
        <ForwardButton />     {/* Call submit via context */}
      </Dialog>
    </ForwardMessageProvider>
  )
}

// Anywhere inside Provider can access state/actions
function ForwardButton() {
  const { actions } = use(ComposerContext)
  return <Button onPress={actions.submit}>Forward</Button>
}
```

---

## 3. Implementation Patterns (MEDIUM)

### 3.1 Create Explicit Component Variants

**Impact: MEDIUM**

Create explicit variant components instead of boolean props.

```tsx
// ❌ Unclear what UI renders
<Composer isThread isEditing={false} channelId="abc" showAttachments />

// ✅ Immediately clear
<ThreadComposer channelId="abc" />
<EditMessageComposer messageId="xyz" />
<ForwardMessageComposer messageId="123" />
```

### 3.2 Prefer Children over Render Props

**Impact: MEDIUM**

Use `children` for composition instead of `renderX` props.

```tsx
// ❌ Render props - hard to read
<Composer
  renderHeader={() => <CustomHeader />}
  renderFooter={() => <><Formatting /><Emojis /></>}
/>

// ✅ Children - natural composition
<Composer.Frame>
  <CustomHeader />
  <Composer.Input />
  <Composer.Footer>
    <Composer.Formatting />
    <Composer.Emojis />
  </Composer.Footer>
</Composer.Frame>
```

**When render props appropriate**: Parent needs to pass data to children

```tsx
<List data={items} renderItem={({ item, index }) => <Item item={item} />} />
```

---

## 4. React 19 APIs (MEDIUM)

> **⚠️ React 19+ only**. Skip this section for React 18 or below.

### 4.1 React 19 API Changes

```tsx
// ❌ forwardRef (unnecessary in React 19)
const ComposerInput = forwardRef<TextInput, Props>((props, ref) => {
  return <TextInput ref={ref} {...props} />
})

// ✅ ref as regular prop
function ComposerInput({ ref, ...props }: Props & { ref?: React.Ref<TextInput> }) {
  return <TextInput ref={ref} {...props} />
}

// ❌ useContext (React 19)
const value = useContext(MyContext)

// ✅ use() - conditional calls possible
const value = use(MyContext)
```

---

## Quick Checklist

| Check | Rule |
|:----:|------|
| [ ] | 3+ Boolean props? → Refactor to composition |
| [ ] | Complex conditional rendering? → Create explicit variants |
| [ ] | State trapped in component? → Lift to Provider |
| [ ] | renderX props? → Change to children |
| [ ] | React 19? → Remove forwardRef, use use() |

## Related Skills

- `/react-best-practices` - Performance optimization (waterfall, bundle, rendering)
- `/web-design-guidelines` - UI/UX quality (accessibility, interaction)
- `/design-patterns` - General design patterns
