# SPEC-T0-02A v0.1.0 — Tenant-Bound Durable Outbox

**Status:** APPROVED DERIVATIVE — owner explicitly accepted SPEC-T0-02A v0.1.0 on 2026-11-17. Independent review of the derived ticket graph and implementation readiness remain separate gates.
**Governing JIP:** APPROVED `planning/jips/JIP-T0-02A_v0.2.1.md` on `main@28517865d8a6bbabf14ac8631798f3e79d29002e`.
**Execution:** Plane TICK-65. **Installed authority:** CANON-1 2.0.20, EVT-1 3.0.0, OBQC-1 2.2.0, TEN-1 2.0.1 and other applicable installed contracts.
**Baseline:** Ash 3.37.6, AshPostgres 2.16.0, Ash SQL 0.8.9, Ecto 3.14.3; AshOban 0.10.3 and direct Oban 2.24.x (reviewed 2.24.2) remain uninstalled JIP-approved prerequisites.
**Authority boundary:** This spec clarifies implementation verification and task boundaries; it cannot create or replace JIP/CANON semantics. The JIP's full field lists, guards, errors and tests remain binding.

## 1. Scope and completion line
Build `Ticketing.Outbox` Ash Domain with `OutboxEvent`, `OutboxDedupeKey`, and `OutboxStreamCursor`; static registry-backed descriptor and test-only dispatcher; single-transaction enqueue and generated durable job; tenant-bound delivery; fenced lifecycle, replay and observability.
No production descriptors, event-to-handler mapping, occurrence/policy, publication, inventory, quote, checkout, payment, ticket, external broker, human replay API, tenant-wide scheduler or cross-tenant privileged role. T0-02B governs the first real producer. JIP §§5–6 are complete non-goals; no future work is pulled forward.

## 2. Resource/action ownership map
| Owner | Required identity and database invariant | Only permitted internal intent |
|---|---|---|
| `Ticketing.Outbox` Domain | Owns all three resources | Private `Ticketing.Outbox.enqueue/…` inside producer's governed transaction; never public CRUD |
| `OutboxDedupeKey` | Unique `(org_id,event_type,dedupe_key_sha256)`; DB-time `active_until_utc`; lowercase SHA-256 | Ash expiry-aware reserve/create-upsert |
| `OutboxStreamCursor` | Unique `(org_id,ordering_key_sha256)`; `enqueued >= 1`, `0 <= delivered <= enqueued` | Ash CAS sequence allocation and contiguous acknowledgement |
| `OutboxEvent` | PK `(org_id,outbox_event_id)`; unique `(org_id,ordering_key_sha256,ordering_sequence)` | Immutable event insert, governed claim/ack/retry/recovery/replay |
All immutable envelope and mutable delivery fields are specified in JIP §8.4. Event and CloudEvent identities are UUIDv7. No generic update writes to protected tenant/identity/payload/stream fields. Tenant-scoped tables use org-first keys/indexes, DB-owned time and `ENABLE/FORCE RLS` with transaction-local `app.current_org_id` and constrained runtime role.
No `authorize?: false` or direct runtime Repo/Ecto/raw SQL persistence. Exact private helper/module layout is implementation-free; infrastructure DDL and isolated fixture mechanics remain subject to scoped AGENTS. JIP §§7–8, 13, 19 govern.

## 3. Static registry validation and canonical hashing
Only EVT-1 registered type/source/topic, required keys, dedupe-key field order/window and ordering-key field order/mode may be configured in a static descriptor. Unknown type fails `EVT_INVALID_TYPE`, missing context `EVT_CONTEXT_MISSING`, and unsupported ordering mode fails registration. Production mappings remain zero.
Dedupe digest: lowercase `sha256(utf8(JCS({event_type, ordered_dedupe_fields: [[field_name, canonical_value], ...]})))`. Ordering digest: lowercase `sha256(utf8(JCS({ordered_fields: [[field_name, canonical_value], ...]})))`. The former binds the event type; the latter deliberately does **not**, so different event types may share a monotonic stream. Preserve registry field order; do not infer a default type. JIP §9.

## 4. Atomic enqueue proof (release blocker)
Within one governed outer PostgreSQL transaction, validate tenant/descriptor/envelope; generate UUIDv7 IDs; reserve finite dedupe window under database time; allocate stream sequence through Ash upsert; persist immutable `OutboxEvent(state=pending)`; insert initial tenant-bound AshOban job **before commit**. Actual delivery is post-commit.
Expired dedupe is replaceable only when `active_until_utc <= database_now`; active duplicate, including identical payload, must fail `ERR_CONFLICT / EVT_IDEMPOTENCY_REPLAY`. First cursor sequence is 1 with last delivered 0; subsequent increments are atomic. Distinct types with shared ordering key join one stream.
Positive integration evidence must show the dedupe reservation, cursor increment, outbox row and Oban job commit together. Forced rollback after job insertion must remove **all four**. An orphan event or orphan job is forbidden. A future producer must join the same outer `Ash.transact` transaction, but no real producer is implemented in 02A. AshOban generated `after_action` insertion must be proven transactional, not assumed. Failed proof triggers STOP/Plane blocker rather than direct Repo/Ecto workaround. JIP §§8–10, 24.

## 5. Lifecycle transition table
| From → To | Initiator/guard | Side effects |
|---|---|---|
| absent → `pending` | Governed internal enqueue with validated tenant/descriptor, dedupe and sequence | Atomic event + job insert |
| `pending` → `claimed` | Tenant-bound generated worker; contiguous stream head, pending CAS, no active competing claim | Increment generation/attempt; record job, claim and lease |
| `claimed` → `delivered` | Matching generation, explicit handler success and cursor CAS | Set delivered timestamp, advance delivered cursor exactly once in same transaction |
| `claimed` → `pending` | Matching generation with retryable failure | Clear claim, record safe error, return failure to Oban retry |
| `claimed` → `pending` | Expired lease under DB time | Reclaim abandoned claim; subsequent claim increments generation |
| `claimed` → `recovery_required` | Matching generation; permanent/exhausted failure | Set safe recovery record; cursor unchanged |
| `recovery_required` → `pending` | Trusted same-tenant internal replay, no active claim | New tenant-bound job, unchanged event/dedupe/order/CloudEvent ID |
| `delivered` → any | Forbidden; delivered terminal | No mutation |
All other transitions fail closed. Stale claim generation cannot ack/release/recover; unexpired claim cannot be stolen. Claim lease 120 seconds; handler timeout maximum 60 seconds, strictly shorter than lease. No attacker-controlled actor or wrong tenant may mutate lifecycle. JIP §11.
For stream `last_delivered_sequence=N`, only event `N+1` may claim; successors snooze 30 seconds without consuming attempt. Recovery-required head blocks all later events; independent streams proceed independently; ack plus cursor CAS atomic. No session-level advisory lock. JIP §12.

## 6. Generated job and delivery boundary
AshOban **0.10.3 generated** OutboxEvent trigger: `scheduler_cron false`, `trigger_once? false`, `actor_persister :none`; stable `Ticketing.Outbox.Jobs.DeliverEventWorker` and `Ticketing.Outbox.Jobs.DeliverEventScheduler` (scheduler disabled). Primary queue `integrations`, latency `STANDARD`, retry class `recovery`. Seven total attempts; explicit jittered 15/30/60/300/900/3600-second delays, not library default. Head-of-line snooze does not consume retries.
Certified Oban outer envelope plus versioned `action_arguments.ticketing_payload` with v1 pointers `org_id` and `outbox_event_id` only. Framework tenant must equal nested org before any governed Ash read. Unknown semantic payload versions/replaced reserved framework keys fail closed. Read current and previous versions once applicable. Full args <8192 bytes (aim <=2048). No persisted actor, credential, PII or permissions snapshot. Oban uniqueness is nonauthoritative; verify required available-job priority index via `pg_catalog`, compute runtime concurrency from OBQC DB pool/topology and queue max, and prohibit tenantless scheduler/fan-out. JIP §§13–14.
Static internal dispatcher maps only **test** types to handlers. Success must be explicitly acknowledged; Oban job success alone does not mean event delivered. Retryable result releases to pending and Oban retry; permanent/missing handler/exhaustion enters recovery_required without cursor advance. Crash after handler effect before ack must be replay-safe with an idempotent test handler. Replay is same immutable event with a new job; no second event or dedupe reservation. Production handlers/sinks are deferred to a later JIP. JIP §§15–16.

## 7. Canonical errors, observability, retention
Canonical outward results only: `EVT_INVALID_TYPE`, `EVT_CONTEXT_MISSING`, `ERR_CONFLICT / EVT_IDEMPOTENCY_REPLAY`, `ERR_CONFLICT / LOCKS_OPTIMISTIC_CONFLICT` if stale CAS is surfaced, and canonical TEN/ERR hide-existence posture. Handler errors are safe internal classifications; no public error invention.
Spans `outbox.enqueue`, `outbox.delivery_attempt`, `outbox.replay`; enqueue/delivery/retry/recovery counts, oldest pending age, latency, blocked-order and stale-fence metrics. No high-cardinality IDs as metric labels. Logs contain only permitted bounded identifiers, never event payload, credentials, PII or raw provider responses. JIP §§17–18.
Persist canonical EVT-1 retention deadline (currently 365 days). No tenant-wide purge scheduler; pending/claimed/recovery_required rows cannot be deleted just because deadline passes. Tenant-bound purge of safely delivered historical rows is optional; before any future production producer revisit retention policy. JIP §20.

## 8. Sequenced implementation and rollback
1. Add only approved `ash_oban ~> 0.10.3` and direct `oban ~> 2.24` prerequisites plus canonical Oban migration; inspect exact resolved lock before proceeding.
2. Add three tables, org-first constraints, checks, indexes and FORCE RLS; verify constrained role, transaction-local tenancy and generated migration snapshots.
3. Define Ash Domain/resources and private actions, then test finite expiry-upsert and cursor CAS races under the merged AshPostgres baseline.
4. Implement atomic enqueue plus generated tenant-bound job, demonstrate four-way rollback and commit.
5. Add generated delivery trigger and static test-only dispatcher, fenced lifecycle, error/recovery/replay, observability and complete integration tests.
6. Configure `integrations` queue within OBQC pool/topology limits, with zero production descriptors; pass `mix precommit`, exact-head CI, Dialyzer and independent review.
Initial rollback of schema/dependencies only after verifying **no live outbox rows/jobs**. After future producer activation, destructive rollback is forbidden without draining or preserving durable data. No operational DB, secret or deployment change is authorized by this planning spec. JIP §21.

## 9. Acceptance matrix
| Category | Required focused evidence |
|---|---|
| Identity/registry | Unknown type/context denial; correct JCS digest field order, different-type dedupe and shared ordering stream |
| Dedupe | First success; identical/changed payload active replay denied; exact expiry success; race one winner; cross-tenant independence |
| Cursor | Monotonic sequence, independent streams, head-only claim, cursor ack CAS, head blocked, snooze non-attempt |
| Atomicity | Four-way commit; forced four-way rollback; no event/job orphans |
| Lifecycle | Every allowed/forbidden transition; terminal delivered; generation fences, leases, concurrent one-owner claim, permanent/exhausted failure |
| Tenancy | Missing/mismatched tenant denial **before** Ash read; wrong-tenant hiding; constrained-role FORCE RLS; no actor/secret leakage |
| AshOban | Stable generated identities, no scheduler, canonical payload/versions, reserved keys and total size, explicit retry, priority index |
| Delivery | Explicit success, missing handler recovery, retry, permanent, exhaustion, replay, crash duplication with idempotent test handler |
| Quality | Migration/snapshot audit, safe isolated rollback, `mix precommit`, CI, Dialyzer, no production mapping or extra domain work |
These classes are mandatory JIP §22 minimums, not optional suggestions. Real DB/worker execution is required for atomicity, concurrency, RLS and final-error path, not an inferred package-documentation claim.

## 10. Context Docs, status and stop conditions
As in JIP §23: UPDATE `ticketing/docs/README.md`, `ticketing/docs/platform/database.md`, `runtime.md`, `tenancy-and-authorization.md`, `testing-and-quality-gates.md`; CREATE `ticketing/docs/platform/outbox-and-job-delivery.md`, `ticketing/docs/handoffs/JIP-T0-02A.md`. Docs must describe merged code only; no speculative Occurrence dossier.
Owner acceptance of SPEC-T0-02A v0.1.0 was explicitly given in the Ticketing control-tower conversation on 2026-11-17; planning PR #62 has merged. Independent review of this derivative and the Plane decomposition, verified merged-main CI, and dependency/freshness clearance remain mandatory before any implementation child becomes READY. Owner acceptance of the spec does not itself authorize implementation.
TICK-68 remains open as a separate credential-exposure incident. TICK-69 PostgreSQL 18.7 security applicability must be reviewed before claiming affected RLS/upsert implementation secure/READY. This spec neither rotates credentials nor upgrades PostgreSQL. If Ash expiry-upsert, cursor CAS, four-way atomicity, tenant/RLS or generated-final-error proof fails, STOP, record Plane blocker, targeted JIT; no direct Repo bypass, new semantic state or unapproved change.
