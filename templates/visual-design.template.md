# Design System: {Project Name}

> **Inspired by**: {brand/reference or "custom"}
> **Format**: [Google Stitch DESIGN.md](https://stitch.withgoogle.com/docs/design-md/format/)
> **Date**: {YYYY-MM-DD}
> **Status**: Draft | Active

---

## 1. Visual Theme & Atmosphere

{Describe the overall mood, density, and design philosophy.
Include key characteristics as a bullet list:}

**Key Characteristics:**
- {Characteristic 1 — e.g., font with specific letter-spacing}
- {Characteristic 2 — e.g., shadow-as-border technique}
- {Characteristic 3 — e.g., color temperature and contrast approach}
- {Characteristic 4 — e.g., accent color strategy}

---

## 2. Color Palette & Roles

### Primary
- **{Name}** (`{hex}`): {functional role — e.g., primary text, headings}
- **{Name}** (`{hex}`): {functional role — e.g., page background, card surfaces}

### Accent
- **{Name}** (`{hex}`): {functional role — e.g., CTA, links}
- **{Name}** (`{hex}`): {functional role — e.g., secondary accent}

### Neutral Scale
- **Gray 900** (`{hex}`): Primary text
- **Gray 600** (`{hex}`): Secondary text
- **Gray 400** (`{hex}`): Placeholder, disabled
- **Gray 100** (`{hex}`): Borders, dividers
- **Gray 50** (`{hex}`): Subtle surface tint

### Semantic
- **Success** (`{hex}`): Positive states
- **Warning** (`{hex}`): Caution states
- **Error** (`{hex}`): Error states, destructive actions
- **Info** (`{hex}`): Informational states

---

## 3. Typography Rules

### Font Family
- **Primary**: `{font-family}`, fallbacks: `{fallbacks}`
- **Monospace**: `{mono-font}`, fallbacks: `{fallbacks}`

### Hierarchy

| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
|------|------|------|--------|-------------|----------------|-------|
| Display Hero | {font} | {size} | {weight} | {lh} | {ls} | {notes} |
| Section Heading | {font} | {size} | {weight} | {lh} | {ls} | |
| Sub-heading | {font} | {size} | {weight} | {lh} | {ls} | |
| Card Title | {font} | {size} | {weight} | {lh} | {ls} | |
| Body Large | {font} | {size} | {weight} | {lh} | {ls} | |
| Body | {font} | {size} | {weight} | {lh} | {ls} | |
| Caption | {font} | {size} | {weight} | {lh} | {ls} | |
| Mono Code | {mono} | {size} | {weight} | {lh} | {ls} | |

### Principles
- {Typography principle 1}
- {Typography principle 2}
- {Typography principle 3}

---

## 4. Component Stylings

### Buttons

**Primary**
- Background: `{hex}`
- Text: `{hex}`
- Padding: {padding}
- Radius: {radius}
- Hover: {hover state}
- Focus: {focus state}

**Secondary**
- Background: `{hex}`
- Text: `{hex}`
- Border: {border or shadow}
- Hover: {hover state}

### Cards & Containers
- Background: `{hex}`
- Border: {border technique}
- Radius: {radius}
- Shadow: {shadow values}
- Hover: {hover state}

### Inputs & Forms
- Border: {border technique}
- Focus: {focus ring}
- Radius: {radius}
- Placeholder: {color}

### Navigation
- {Navigation layout description}
- Logo: {placement}
- Links: {font, weight, color}
- Active state: {treatment}
- Mobile: {collapse strategy}

---

## 5. Layout Principles

### Spacing System
- Base unit: {base}px
- Scale: {list of spacing values}

### Grid & Container
- Max content width: {max-width}
- Columns: {column strategy}
- Gutter: {gutter width}

### Whitespace Philosophy
- {Whitespace principle — e.g., generous vertical padding between sections}
- {Rhythm principle — e.g., alternating density patterns}

### Border Radius Scale
| Name | Value | Use |
|------|-------|-----|
| Small | {value} | {use case} |
| Standard | {value} | {use case} |
| Large | {value} | {use case} |
| Full | 9999px | Pills, badges |

---

## 6. Depth & Elevation

| Level | Treatment | Use |
|-------|-----------|-----|
| Flat (0) | No shadow | Page background |
| Subtle (1) | {shadow value} | Cards, containers |
| Elevated (2) | {shadow value} | Dropdowns, popovers |
| Modal (3) | {shadow value} | Modals, dialogs |
| Focus | {focus ring value} | Keyboard focus |

### Shadow Philosophy
- {Describe approach — e.g., shadow-as-border, layered stacks, elevation metaphor}

---

## 7. Do's and Don'ts

### Do
- {Design guideline 1}
- {Design guideline 2}
- {Design guideline 3}
- {Design guideline 4}

### Don't
- {Anti-pattern 1}
- {Anti-pattern 2}
- {Anti-pattern 3}
- {Anti-pattern 4}

---

## 8. Responsive Behavior

### Breakpoints
| Name | Width | Key Changes |
|------|-------|-------------|
| Mobile | <640px | Single column, stacked |
| Tablet | 640-1024px | 2-column grids |
| Desktop | 1024-1440px | Full layout |
| Large | >1440px | Centered, max-width |

### Touch Targets
- Minimum: 44x44px
- {Touch-specific guidance}

### Collapsing Strategy
- {Hero behavior on mobile}
- {Navigation collapse}
- {Grid column reduction}
- {Spacing reduction}

---

## 9. Agent Prompt Guide

### Quick Color Reference
- Primary CTA: `{hex}`
- Background: `{hex}`
- Heading text: `{hex}`
- Body text: `{hex}`
- Border: `{value}`
- Link: `{hex}`
- Focus ring: `{value}`

### Example Component Prompts
- "{Hero section prompt with exact values}"
- "{Card component prompt with exact values}"
- "{Navigation prompt with exact values}"

### Iteration Guide
1. {Key implementation rule 1}
2. {Key implementation rule 2}
3. {Key implementation rule 3}

---

## Reference

- **Source**: {URL or "custom design"}
- **Tool**: `npx getdesign@latest add {brand}` (if from awesome-design-md)
- **Collection**: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
