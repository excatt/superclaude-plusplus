---
name: security-audit
description: |
  Comprehensive security audit with OWASP Top 10, STRIDE threat model,
  and LLM/AI-specific security analysis. Covers traditional web security
  plus AI-era attack surfaces: prompt injection, tool call validation,
  skill supply chain, and cost amplification.

  Use proactively when:
  - Security review requested
  - Auth/authz implementation
  - API endpoint exposure
  - LLM/AI integration code
  - Dependency updates
  - Pre-deployment audit

  Triggers: security audit, security review, vulnerability check,
  pentest, threat model, OWASP, security scan

  Do NOT use for: performance optimization, code style review
user-invocable: true
argument-hint: [path-or-scope]
---

# Security Audit Skill

## Purpose
Systematic security audit covering traditional web security and AI-era attack surfaces.

## Usage

```bash
/security-audit src/api/           # audit specific directory
/security-audit                    # full project audit
/security-audit --focus llm        # LLM security only
/security-audit --focus deps       # dependency audit only
```

## Audit Pipeline

Execute phases sequentially. Each finding gets a Confidence score (1-10).
Only report findings with Confidence >= 6. Below 6 = informational note only.

---

### Phase 1: Architecture & Attack Surface Census

**Goal**: Map the application's trust boundaries and entry points.

1. Identify all entry points (HTTP endpoints, WebSocket handlers, CLI args, file uploads, queue consumers)
2. Map trust boundaries (public internet, authenticated zone, admin zone, internal services)
3. Identify data flows crossing trust boundaries
4. List all external service integrations (databases, APIs, cloud services)

**Output**: Attack surface diagram (text-based)

---

### Phase 2: Secrets Archaeology

**Goal**: Find hardcoded credentials, leaked keys, weak secret management.

```bash
# Pattern scan
grep -rn "password\s*=\|api_key\s*=\|secret\s*=\|token\s*=" --include="*.{py,ts,js,go,rs,java}" .
grep -rn "BEGIN.*PRIVATE KEY" .
grep -rn "sk-[a-zA-Z0-9]" .           # OpenAI keys
grep -rn "anthropic-[a-zA-Z0-9]" .    # Anthropic keys
grep -rn "ghp_[a-zA-Z0-9]" .          # GitHub tokens
```

**Check**:
- [ ] No secrets in source code
- [ ] `.env` files in `.gitignore`
- [ ] No secrets in git history (`git log -p | grep -i "password\|secret\|api_key"`)
- [ ] Environment variables used for all credentials
- [ ] Rotation policy documented for all secrets

---

### Phase 3: Dependency Supply Chain

**Goal**: Identify vulnerable or malicious dependencies.

```bash
# Node.js
pnpm audit
# Python
uv pip audit   # or pip-audit
# Check for typosquatting
# Check for abandoned packages (no updates >2 years)
```

**Check**:
- [ ] No critical/high CVEs in direct dependencies
- [ ] Lock file committed and up to date
- [ ] No wildcard version ranges (`*`, `latest`)
- [ ] No postinstall scripts from untrusted packages
- [ ] Dependencies match expected scope (no unexpected network/fs access)

---

### Phase 4: OWASP Top 10 Scan

| # | Vulnerability | What to Check |
|---|---------------|---------------|
| A01 | Broken Access Control | Missing auth middleware, IDOR, path traversal, CORS misconfiguration |
| A02 | Cryptographic Failures | Weak hashing (MD5/SHA1 for passwords), missing TLS, plaintext secrets |
| A03 | Injection | SQL injection, NoSQL injection, command injection, XSS, template injection |
| A04 | Insecure Design | Missing rate limits, no abuse controls, business logic flaws |
| A05 | Security Misconfiguration | Debug mode in prod, default credentials, unnecessary features enabled |
| A06 | Vulnerable Components | Known CVEs in dependencies (Phase 3 overlap) |
| A07 | Auth Failures | Weak passwords allowed, missing MFA, session fixation, JWT issues |
| A08 | Data Integrity Failures | Missing integrity checks on updates, insecure deserialization |
| A09 | Logging Failures | Missing security event logs, logging sensitive data |
| A10 | SSRF | Unvalidated URLs in server-side requests, internal network access |

**For each finding**: `[A0X] file:line — description (Confidence: N/10)`

---

### Phase 5: STRIDE Threat Model

For each major component/flow, evaluate:

| Threat | Question | Mitigation Check |
|--------|----------|------------------|
| **S**poofing | Can an attacker impersonate a user/service? | Auth tokens, mutual TLS, API keys |
| **T**ampering | Can data be modified in transit/at rest? | Integrity checks, signed payloads, HMAC |
| **R**epudiation | Can actions be denied? | Audit logs, signed events |
| **I**nformation Disclosure | Can sensitive data leak? | Encryption, access controls, error messages |
| **D**enial of Service | Can the service be overwhelmed? | Rate limits, resource quotas, circuit breakers |
| **E**levation of Privilege | Can a user gain higher access? | RBAC, least privilege, input validation |

---

### Phase 6: LLM & AI Security

**This phase applies when the project uses LLM/AI integrations.**

Skip if no AI/LLM usage detected. This is the AI-era extension to traditional security auditing.

#### 6.1 Prompt Injection Vectors

Scan for paths where user input reaches LLM prompts:

```
User Input → [transform?] → System/User Prompt → LLM → [tool calls?] → Response
```

**Check**:
- [ ] User input never concatenated directly into system prompts without sanitization
- [ ] Retrieval-augmented content (RAG) treated as untrusted (can contain injected instructions)
- [ ] Tool/function call results validated before re-injection into prompt
- [ ] Multi-turn conversations don't allow context manipulation via crafted history
- [ ] File uploads (PDF, images) scanned for embedded prompt injection payloads

**Injection patterns to grep**:
```bash
grep -rn "system.*\+.*user\|f\".*{user\|\.format(.*user" --include="*.py" .
grep -rn "role.*system.*\$\|`\$.*`.*system" --include="*.{ts,js}" .
```

#### 6.2 Tool/Function Call Validation

When LLMs invoke tools (function calling, MCP tools, agent actions):

- [ ] Tool inputs are validated/sanitized before execution
- [ ] Tool permissions follow least privilege (no shell access unless required)
- [ ] Destructive tools (delete, write, execute) require confirmation or are sandboxed
- [ ] Tool output is bounded (prevent memory exhaustion from large responses)
- [ ] Tool call chains have depth limits (prevent infinite agent loops)

#### 6.3 API Key & Cost Exposure

- [ ] LLM API keys not exposed to client-side code
- [ ] Per-user/per-session token limits enforced
- [ ] No unbounded loops that could amplify API costs (e.g., recursive agent calls)
- [ ] Rate limiting on LLM-powered endpoints
- [ ] Cost monitoring/alerting configured for LLM API usage
- [ ] Model selection not controllable by end-user input (prevent expensive model switching)

#### 6.4 Output Security

- [ ] LLM output not rendered as raw HTML (XSS via generated content)
- [ ] LLM-generated code not executed without sandboxing
- [ ] LLM responses not used to construct SQL/shell commands without parameterization
- [ ] Sensitive data not leaked through LLM responses (PII in training data, context leakage)
- [ ] Content filtering applied to user-facing LLM output

#### 6.5 Skill & Plugin Supply Chain

When the project loads external skills, plugins, or MCP servers:

- [ ] Skill source verified (official registry, known author, signed)
- [ ] Skill permissions audited (what tools/files can it access?)
- [ ] No skills with `Bash` or `Write` access to sensitive paths without justification
- [ ] Skill updates don't auto-apply without review
- [ ] MCP server configurations reviewed for excessive permissions
- [ ] Third-party MCP servers pinned to specific versions

---

### Phase 7: False Positive Filtering

Before reporting, apply these exclusion rules:

- Test files (`test_*`, `*.test.*`, `*.spec.*`) — secrets in fixtures are expected
- Example/template files with placeholder values (`example.env`, `*.template`)
- Documentation code blocks showing patterns (not actual credentials)
- Disabled/commented-out code (flag as informational, not critical)
- Development-only configurations (`if (process.env.NODE_ENV === 'development')`)

**Confidence recalibration**: If finding depends on assumptions about deployment, reduce Confidence by 2.

---

## Output Format

### Summary Table

```
## Security Audit Summary

| Severity | Count | Status |
|----------|-------|--------|
| Critical | 0     | -      |
| High     | 2     | Fix required before deploy |
| Medium   | 3     | Fix before next release |
| Low      | 5     | Track and address |
| Info     | 2     | No action needed |

LLM Security: [Applicable/Not Applicable]
Overall Risk: [Critical/High/Medium/Low]
```

### Finding Format

```
### [CRITICAL] A03 — SQL Injection in user search
- **File**: src/api/users.ts:47
- **Confidence**: 9/10
- **Description**: User input interpolated directly into SQL query
- **Impact**: Full database read/write access
- **Fix**: Use parameterized query
- **Evidence**: `db.query(\`SELECT * FROM users WHERE name = '${name}'\`)`
```

### Severity Definitions

| Severity | Definition | Action |
|----------|-----------|--------|
| **Critical** | Actively exploitable, data breach risk | Stop and fix immediately |
| **High** | Exploitable with moderate effort | Fix before deploy |
| **Medium** | Requires specific conditions to exploit | Fix before next release |
| **Low** | Defense-in-depth improvement | Track in backlog |
| **Info** | Best practice recommendation | No immediate action |

## Related Skills

- `/auth` - Authentication & authorization patterns
- `/error-handling` - Secure error handling
- `/verify` - General verification pipeline
- `/cso` - Extended security officer review (gstack-compatible)
