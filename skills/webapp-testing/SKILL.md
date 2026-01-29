# Web Application Testing

This toolkit enables testing of local web applications through native Python Playwright scripts, supporting frontend verification, UI debugging, screenshot capture, and browser log inspection.

## Trigger
- When user requests testing of web applications
- Frontend verification and UI debugging needed
- Screenshot capture or visual validation required
- Browser console log inspection needed

## Capabilities

**Available Helper Scripts:**
- `scripts/with_server.py` - Manages server lifecycle for single or multiple servers

## Core Workflow

### Decision Tree

1. **Static HTML?** → Read the file directly and identify CSS selectors
2. **Dynamic webapp with no running server?** → Use `with_server.py` helper
3. **Server already running?** → Apply reconnaissance-then-action pattern

### Reconnaissance-Then-Action Pattern

Recommended sequence:
1. Navigate to the application and wait for `networkidle` state
2. Capture screenshots or inspect the DOM
3. Discover selectors from the rendered page
4. Execute automation actions using those selectors

## Critical Best Practices

- Always run scripts with `--help` first before reading source code
- Wait for `page.wait_for_load_state('networkidle')` before inspection
- Use `sync_playwright()` for synchronous automation
- Employ descriptive selectors (text=, role=, CSS, IDs)
- Always close browsers when finished

## Use When

- Verifying web application functionality
- Testing form interactions
- Capturing screenshots for documentation
- Debugging layout issues
- Automating user workflows
- Running E2E test scenarios
