# Artifacts Builder

**Artifacts Builder** is a toolkit for creating sophisticated Claude.ai HTML artifacts using modern frontend technologies.

## Trigger
- When user requests complex interactive HTML interfaces
- Building React-based applications within Claude
- Creating self-contained bundled artifacts
- Developing UI with Tailwind CSS and shadcn/ui

## Capabilities

The suite leverages "React 18 + TypeScript + Vite + Parcel (bundling) + Tailwind CSS + shadcn/ui" to build multi-component interfaces requiring state management or routing capabilities.

## Main Workflow

1. **Initialize**: Frontend repository via `scripts/init-artifact.sh`
2. **Develop**: Code editing with React and TypeScript
3. **Bundle**: Create single HTML file using `scripts/bundle-artifact.sh`
4. **Present**: Show artifact to user
5. **Test**: Optionally test the result

## Automatic Setup

The initialization script automatically configures:
- React and TypeScript development environment
- Tailwind CSS with shadcn/ui theming
- Path aliases and component libraries
- Parcel bundler with appropriate configurations
- Node 18+ compatibility

## Output Format

Creates self-contained `bundle.html` file with:
- All JavaScript embedded
- CSS fully compiled
- Dependencies bundled
- Standalone and shareable

## Design Principles

- Avoid excessive centered layouts
- Minimize purple gradients
- Reduce uniform rounded corners
- Consider font choices beyond Inter

## Use When

- Building interactive dashboards
- Creating form-heavy applications
- Developing state-managed components
- Need cross-browser compatibility
- Sharing self-contained web applications
