---
name: web-design-guidelines
description: |
  UI code review skill based on Vercel's Web Interface Guidelines.
  Inspects accessibility, performance, and UX with 100+ rules.

  Use proactively when:
  - UI code review requested
  - Accessibility (a11y) check requested
  - Design audit requested
  - UX review requested
  - Best practices check requested

  Triggers: review UI, check accessibility, audit design, review UX,
  check best practices, UI review, accessibility check, design review, UX review,
  web guidelines, a11y check

  Do NOT use for: backend code, API design, database
user-invocable: true
argument-hint: <file-or-pattern>
metadata:
  author: vercel (adapted for SuperClaude)
  version: "1.0.0"
  source: https://github.com/vercel-labs/web-interface-guidelines
---

# Web Interface Guidelines

Review UI code according to Vercel Web Interface Guidelines.

## Usage

```bash
/web-design-guidelines src/components/Button.tsx
/web-design-guidelines "src/**/*.tsx"
/web-design-guidelines                          # prompt for file
```

## Review Rules

### Accessibility

- Icon-only buttons require `aria-label`
- Form controls require `<label>` or `aria-label`
- Interactive elements require keyboard handlers (`onKeyDown`/`onKeyUp`)
- Use `<button>` for actions, `<a>`/`<Link>` for navigation (no `<div onClick>`)
- Images require `alt` (use `alt=""` for decorative)
- Decorative icons require `aria-hidden="true"`
- Async updates (toasts, validation) require `aria-live="polite"`
- Prefer semantic HTML over ARIA (`<button>`, `<a>`, `<label>`, `<table>`)
- Maintain heading hierarchy `<h1>`–`<h6>`; include skip link to main content
- Anchor headings require `scroll-margin-top`

### Focus States

- Interactive elements require visible focus: `focus-visible:ring-*` or equivalent
- Using `outline-none` / `outline: none` requires alternative focus indicator
- Use `:focus-visible` over `:focus` (prevents focus ring on click)
- Use `:focus-within` on compound controls for group focus

### Forms

- Inputs require `autocomplete` and meaningful `name`
- Use correct `type` (`email`, `tel`, `url`, `number`) and `inputmode`
- Never block paste (`onPaste` + `preventDefault`)
- Labels must be clickable (`htmlFor` or wrap control)
- Disable spellcheck for email, code, username (`spellCheck={false}`)
- Checkbox/Radio: label + control = single hit target (no dead zone)
- Submit button active until request starts; show spinner during request
- Errors shown inline next to field; focus first error on submit
- Placeholders end with `…` and show example pattern
- Use `autocomplete="off"` on non-auth fields (prevent password manager trigger)
- Warn on navigation with unsaved changes (`beforeunload` or router guard)

### Animation

- Respect `prefers-reduced-motion` (provide reduced version or disable)
- Animate only `transform`/`opacity` (compositor-friendly)
- Forbid `transition: all`—list properties explicitly
- Set correct `transform-origin`
- SVG: transforms on `<g>` wrapper, `transform-box: fill-box; transform-origin: center`
- Animations must be interruptible—respond to user input during animation

### Typography

- Use `…` instead of `...`
- Use curly quotes `"` `"` instead of straight `"`
- Non-breaking spaces: `10&nbsp;MB`, `⌘&nbsp;K`, brand names
- Loading states end with `…`: `"Loading…"`, `"Saving…"`
- Numeric columns/comparisons: `font-variant-numeric: tabular-nums`
- Headings: `text-wrap: balance` or `text-pretty` (prevent widows)

### Content Handling

- Text containers handle long content: `truncate`, `line-clamp-*`, or `break-words`
- Flex children need `min-w-0` (allow text truncation)
- Handle empty states—no broken UI for empty strings/arrays
- User-generated content: expect short, average, very long inputs

### Images

- `<img>` requires explicit `width` and `height` (prevent CLS)
- Below-fold images: `loading="lazy"`
- Above-fold critical images: `priority` or `fetchpriority="high"`

### Performance

- Large lists (>50 items): virtualize (`virtua`, `content-visibility: auto`)
- Never read layout in render (`getBoundingClientRect`, `offsetHeight`, etc.)
- Batch DOM reads/writes; avoid interleaving
- Prefer uncontrolled inputs; controlled inputs must be cheap per keystroke
- Add `<link rel="preconnect">` for CDN/asset domains
- Critical fonts: `<link rel="preload" as="font">` with `font-display: swap`

### Navigation & State

- URL reflects state—filters, tabs, pagination, expanded panels in query params
- Links use `<a>`/`<Link>` (support Cmd/Ctrl+click, middle-click)
- Deep-link all state UI (consider nuqs etc. to sync URL when using `useState`)
- Destructive actions require confirmation modal or undo window—no instant execution

### Touch & Interaction

- `touch-action: manipulation` (prevent double-tap zoom delay)
- Set `-webkit-tap-highlight-color` intentionally
- Modals/drawers/sheets: `overscroll-behavior: contain`
- During drag: disable text selection, `inert` on dragged element
- Use `autoFocus` carefully—desktop only, single primary input; avoid on mobile

### Safe Areas & Layout

- Full-bleed layouts require `env(safe-area-inset-*)` for notch
- Prevent unwanted scrollbars: `overflow-x-hidden` on container, fix content overflow
- Prefer flex/grid over JS measurement

### Dark Mode & Theming

- Dark theme requires `color-scheme: dark` on `<html>` (fixes scrollbar, inputs)
- `<meta name="theme-color">` matches page background
- Native `<select>`: explicit `background-color` and `color` (Windows dark mode)

### Locale & i18n

- Dates/times: use `Intl.DateTimeFormat` instead of hardcoded format
- Numbers/currency: use `Intl.NumberFormat` instead of hardcoded format
- Language detection: `Accept-Language` / `navigator.languages` instead of IP

### Hydration Safety

- Input with `value` requires `onChange` (or use `defaultValue` for uncontrolled)
- Date/time rendering: prevent hydration mismatch (server vs client)
- Use `suppressHydrationWarning` only where truly needed

### Hover & Interactive States

- Buttons/links require `hover:` state (visual feedback)
- Interactive states increase contrast: hover/active/focus more visible than rest

### Content & Copy

- Active voice: "Install the CLI" not "The CLI will be installed"
- Title Case for headings/buttons (Chicago style)
- Numerals for counts: "8 deployments" not "eight"
- Specific button labels: "Save API Key" not "Continue"
- Error messages include fix/next step, not just problem
- Use second person; avoid first person
- Use `&` over "and" when space-constrained

## Anti-patterns - Must Flag

- `user-scalable=no` or `maximum-scale=1` (disables zoom)
- `onPaste` with `preventDefault`
- `transition: all`
- `outline-none` without focus-visible alternative
- Inline `onClick` navigation without `<a>`
- `<div>` or `<span>` with click handler (must use `<button>`)
- Images without dimensions
- Large array `.map()` without virtualization
- Form inputs without labels
- Icon buttons without `aria-label`
- Hardcoded date/number format (must use `Intl.*`)
- `autoFocus` without clear justification

## Output Format

Group by file. Use `file:line` format (VS Code clickable). Concise findings.

```text
## src/Button.tsx

src/Button.tsx:42 - icon button missing aria-label
src/Button.tsx:18 - input lacks label
src/Button.tsx:55 - animation missing prefers-reduced-motion
src/Button.tsx:67 - transition: all → list properties

## src/Modal.tsx

src/Modal.tsx:12 - missing overscroll-behavior: contain
src/Modal.tsx:34 - "..." → "…"

## src/Card.tsx

✓ pass
```

State issue + location. Skip explanation if fix is obvious. No preamble.

## Related Skills

- `/react-best-practices` - React/Next.js performance optimization
- `/a11y` - Deep accessibility analysis
- `/frontend-design` - Frontend UI generation
- `/responsive` - Responsive design review
