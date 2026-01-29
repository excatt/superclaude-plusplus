# Slack GIF Creator

Toolkit for creating animated GIFs optimized for Slack, whether for messages or custom emojis, starting from creative descriptions.

## Trigger
- When user needs animated GIFs for Slack
- Creating custom Slack emojis
- Designing animated messages
- Converting creative ideas to optimized animations

## Key Capabilities

**Three Tool Categories:**
- Validators that check GIFs against Slack's strict requirements
- Animation primitives (shake, bounce, spin, pulse, fade, zoom, etc.)
- Helper utilities for optimization, text, colors, and effects

## Slack Constraints

**Message GIFs:**
- Up to ~2MB at 480x480 resolution
- Flexible frame count

**Emoji GIFs (strict):**
- Maximum 64KB at 128x128
- Aggressive optimization needed
- Limit to 10-15 frames
- Use 32-48 colors maximum

## Design Philosophy

Creative freedom within technical boundaries:
- Composable building blocks
- Not rigid templates
- Flexible animation combination

## Workflow

1. Understand creative vision
2. Design animation phases
3. Apply animation primitives
4. Validate against constraints
5. Iterate if needed

## Technical Requirements

- Pillow for image manipulation
- imageio for GIF creation
- NumPy for animations

## Use When

- Creating Slack custom emojis
- Designing animated Slack messages
- Building GIF animations for team communication
- Creating optimized animations within size constraints
