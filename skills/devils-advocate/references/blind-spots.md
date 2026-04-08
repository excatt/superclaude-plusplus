# Engineering Blind Spots

Categories of issues that engineers consistently miss during design, implementation, and review. For each category: what it is, why it gets missed, key questions to surface it, and concrete examples.

---

## 1. Security

### Why It's Missed

Security is invisible when it works. Engineers optimize for functionality — "does it do the thing?" — and security failures only manifest under adversarial conditions that normal testing doesn't simulate.

### Key Questions

| Area | Question |
|------|----------|
| Authentication | "What happens if the JWT is expired but the request is already in flight?" |
| Authorization | "Can user A access user B's resources by changing the ID in the URL?" |
| Input validation | "What happens if this field contains 10MB of data? SQL? JavaScript? Unicode control characters?" |
| Data exposure | "What fields in this API response should the requesting user NOT see?" |
| Secrets | "If this log line is captured, does it contain anything sensitive?" |
| CSRF/SSRF | "Can this endpoint be triggered by a malicious page the user visits?" |
| Rate limiting | "What's the cost if someone calls this endpoint 10,000 times per second?" |

### Common Misses

- **BOLA:** Endpoint checks authentication but not whether the authenticated user owns the requested resource.
- **Mass assignment:** Accepting all fields from request body. User sends `{"role": "admin"}` in a profile update.
- **Verbose error messages:** Stack traces, SQL errors, or internal paths in production API responses.
- **Insecure direct object references:** Sequential integer IDs that allow enumeration.
- **Missing security headers:** No CSP, no HSTS, no X-Frame-Options.

---

## 2. Scalability

### Why It's Missed

Systems that work at current scale feel correct. Scaling failures are nonlinear — a query that takes 50ms with 1,000 rows takes 30 seconds with 1,000,000.

### Key Questions

| Area | Question |
|------|----------|
| Data growth | "What happens to this query when the table has 10M rows? 100M?" |
| Traffic | "If traffic increases 10x, which component fails first?" |
| Storage | "How much storage does this consume per user per month?" |
| Fan-out | "How many downstream calls does a single user action trigger?" |
| Cost | "What's the cloud cost of this at 100x current usage?" |
| Hotspots | "Is there a single row, key, or partition that gets disproportionate traffic?" |

### Common Misses

- **N+1 queries:** Fetching a list then querying each item individually.
- **Unbounded queries:** `SELECT * FROM table` with no LIMIT.
- **Missing pagination:** Endpoints that return all results.
- **Cache stampede:** Cache expires, 1,000 concurrent requests all miss cache and hit database simultaneously.
- **Linear algorithms on growing data:** O(n) loops that become O(n^2) when nested.

---

## 3. Data Lifecycle

### Why It's Missed

Engineers focus on data creation and reading. The full lifecycle — creation, transformation, archival, deletion, compliance — is rarely considered upfront.

### Key Questions

| Area | Question |
|------|----------|
| Retention | "How long do we keep this? Is there a legal or business requirement?" |
| Deletion | "If a user requests account deletion, what happens to their data across all tables?" |
| Cascade | "If this record is deleted, what references it? Do foreign keys cascade or orphan?" |
| PII | "Which fields in this table are personally identifiable?" |
| Migration | "If the schema changes, what happens to existing data? Is backfill needed?" |

### Common Misses

- **Orphaned records:** Parent deleted, children remain with dangling foreign keys.
- **Soft-delete inconsistency:** Some queries filter `deleted_at IS NULL`, others don't.
- **PII in logs:** Structured logging captures request bodies containing email, phone, address.
- **GDPR right-to-erasure gaps:** User deleted from `users` table but data persists in `audit_log`, `analytics_events`, third-party integrations.

---

## 4. Integration Points

### Why It's Missed

Engineers test their own code, not the boundary between their code and external systems. Integrations work in dev (mocked or always-available) and fail in production (flaky, slow, or unexpected responses).

### Key Questions

| Area | Question |
|------|----------|
| Availability | "What happens when this dependency is down for 30 minutes? 4 hours?" |
| Latency | "What if this API call takes 30 seconds instead of 200ms?" |
| Response shape | "What if the response includes fields we don't expect? Or is missing fields we do?" |
| Retry safety | "Is this operation idempotent? What happens if we retry and the first attempt actually succeeded?" |
| Blast radius | "If this integration fails, what else breaks? Can we degrade gracefully?" |

### Common Misses

- **Timeout misconfiguration:** Default HTTP timeout of 30s or infinity. Slow dependency blocks threads.
- **No circuit breaker:** Failed dependency called repeatedly, consuming resources.
- **Webhook delivery assumptions:** Assuming webhooks arrive once, in order, and promptly.
- **Schema coupling:** Deserializing entire response into strict type. Any field change causes failures.

---

## 5. Failure Modes

### Why It's Missed

Engineers think in terms of success paths. Failure handling is added as an afterthought — often just `catch (e) { log(e) }`.

### Key Questions

| Area | Question |
|------|----------|
| Partial failure | "What if step 3 of 5 fails? What state is the system in?" |
| Retry behavior | "If this is retried, is the result identical? Or do we get duplicates?" |
| Poison messages | "What if one message in the queue is malformed? Does it block all processing?" |
| Resource exhaustion | "What happens when disk is full? Memory exhausted? Connection pool depleted?" |
| Recovery | "After the failure is resolved, does the system self-heal or require manual intervention?" |

### Common Misses

- **Inconsistent state from partial operations:** Multi-step process fails at step 2. No compensation logic.
- **Retry storms:** Service A retries failed calls to overloaded Service B. No exponential backoff with jitter.
- **Silent failures:** Exception caught and logged but not propagated. System appears healthy while producing wrong results.
- **Deadletter neglect:** Failed messages go to a dead letter queue that nobody monitors.

---

## 6. Concurrency

### Why It's Missed

Developers write and test code sequentially. Concurrency bugs are non-deterministic — they depend on timing, load, and scheduling.

### Key Questions

| Area | Question |
|------|----------|
| Race conditions | "If two users do this simultaneously, what happens?" |
| Double-submit | "If the user clicks the button twice quickly, do we create two records?" |
| Read-modify-write | "Between reading this value and writing the update, can another process change it?" |
| Idempotency | "If this operation runs twice with the same input, is the result the same?" |

### Common Misses

- **Check-then-act without locking:** `if not exists(email): create_user(email)` — two concurrent requests both pass the check.
- **Lost updates:** Two requests read balance=100, both add 50, both write 150. Expected: 200.
- **Double-submit on forms:** No idempotency key, no client-side guard.
- **Connection pool exhaustion:** Long-running transactions or leaked connections deplete the pool.

---

## 7. Environment Gaps

### Why It's Missed

"Works on my machine." Development environments differ from production in invisible ways.

### Key Questions

| Area | Question |
|------|----------|
| Data volume | "Dev has 100 rows. Production has 10M. Have we tested with production-scale data?" |
| Network | "Does this assume localhost latency? What about cross-region calls in prod?" |
| Resource limits | "What are the memory/CPU/disk limits in production?" |
| Dependencies | "Are all dependency versions pinned? Could a `latest` tag differ between environments?" |

### Common Misses

- **Timezone differences:** Dev and prod configured with different timezone defaults.
- **File system assumptions:** Code writes to `/tmp` expecting unlimited space. Production container has 512MB tmpfs.
- **SSL/TLS in production only:** Dev uses HTTP. First production deploy fails.
- **Missing environment variables:** App starts fine in dev (defaults used). Production crashes on startup.

---

## 8. Observability

### Why It's Missed

Observability has zero user-facing value until something breaks — then it's the most important thing.

### Key Questions

| Area | Question |
|------|----------|
| Debugging | "If this fails in production at 3am, what information does the on-call engineer have?" |
| Metrics | "What metrics tell us this system is healthy? What threshold means 'unhealthy'?" |
| Tracing | "Can we trace a user request across all services it touches?" |
| Cost | "Do we know the per-request cost of this operation?" |

### Common Misses

- **Missing request correlation:** No way to trace a single user request through multiple services.
- **Metric cardinality explosion:** Metrics tagged with user ID or request ID overwhelm monitoring.
- **Alert fatigue:** Too many non-actionable alerts. Real alerts get lost in noise.
- **No business metrics:** Technical metrics exist but nobody tracks orders per minute, conversion rate.

---

## 9. Deployment

### Why It's Missed

Deployment is treated as "push code, it's live." The transition period — where old code and new code coexist — is rarely considered.

### Key Questions

| Area | Question |
|------|----------|
| Rollback | "Can we roll back this deployment in under 5 minutes? What breaks if we do?" |
| Migration | "Is this migration backward-compatible? Can old code work with the new schema?" |
| Cache invalidation | "Do cached values still make sense after this deployment?" |
| Feature flags | "Can this feature be turned off without a deployment?" |

### Common Misses

- **Non-reversible migrations:** Column renamed or dropped. Rollback to previous code fails.
- **Breaking API changes without versioning:** Frontend and backend disagree on the API contract.
- **Stale caches:** Deployment changes response format. CDN serves old format.
- **Database migration under load:** Migration locks a table. All queries timeout.

---

## 10. Multi-Tenancy

### Why It's Missed

Multi-tenancy is an architectural constraint that touches everything but is owned by no single feature.

### Key Questions

| Area | Question |
|------|----------|
| Data isolation | "If I substitute a different tenant ID, do I see their data?" |
| Query filtering | "Does every query in this feature filter by tenant? Including joins and subqueries?" |
| Resource fairness | "Can one tenant's usage degrade performance for all others?" |
| Caching | "Are cache keys namespaced by tenant?" |

### Common Misses

- **Missing tenant filter in new queries:** One missed filter = cross-tenant data leak.
- **Global caches:** Cache key `user:123` without tenant prefix.
- **Shared rate limits:** One tenant's burst blocks all other tenants.
- **Background job context leakage:** Job processes tenant A, then B, but context from A persists.

---

## 11. Edge Cases

### Why It's Missed

Edge cases are, by definition, not the common case. But edge cases are where bugs hide, data corrupts, and security vulnerabilities live.

### Key Questions

| Area | Question |
|------|----------|
| Empty state | "What does this look like with zero data? First-time user?" |
| Boundaries | "What happens at the maximum? Minimum? Exactly zero? Negative values?" |
| Unicode | "What happens with emoji, RTL text, or characters outside ASCII?" |
| Timezone | "What happens at midnight? DST transitions?" |
| Precision | "Are we using floats for money?" |
| Nulls | "Which of these fields can be null in practice?" |

### Common Misses

- **Empty state panic:** Feature works beautifully with data. With no data: blank screen, undefined errors.
- **Float precision:** `0.1 + 0.2 !== 0.3` in IEEE 754. Currency calculations drift.
- **Timezone-naive datetime:** Storing `datetime` without timezone info.
- **Off-by-one in pagination:** Page boundaries duplicating or missing items.
- **Maximum payload:** File upload with no size limit. User uploads 5GB.

---

## Quick Reference: The Question That Catches Each Blind Spot

| Blind Spot | Single Most Revealing Question |
|------------|-------------------------------|
| Security | "Can user A access user B's data by manipulating the request?" |
| Scalability | "What happens at 100x current scale?" |
| Data lifecycle | "If we delete this user, what happens to their data everywhere?" |
| Integration | "What happens when this dependency is down for an hour?" |
| Failure modes | "If step 3 of 5 fails, what state is the system in?" |
| Concurrency | "If two users do this at the exact same time, what happens?" |
| Environment | "What's different about production that we're not testing?" |
| Observability | "Can the on-call engineer debug this at 3am with available tools?" |
| Deployment | "Can we roll this back in 5 minutes without data loss?" |
| Multi-tenancy | "Does every query filter by tenant, including this new one?" |
| Edge cases | "What does this look like with zero data? Maximum data? Unicode?" |
