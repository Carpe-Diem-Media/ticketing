# JIP-T0-02A v0.2.0 — Durable Domain Outbox and Tenant-Bound Delivery Substrate

**Status:** DRAFT  
**Approval:** Explicit user approval required. This document does not self-approve.  
**Roadmap:** T0 — Tenant-scoped GA pending sale  
**Increment:** T0-02A platform prerequisite only  
**Plane discovery:** TICK-65  
**Resolved authority gap:** TICK-66

## 1. Objective

Establish the smallest reusable Ash-native durable domain-event outbox and delivery substrate required before implementing root Occurrence creation.

This increment creates no product event producer and no production delivery mapping. Its purpose is to make the later producer transaction capable of atomically committing domain state and a canonical durable event, then delivering that event at least once through a tenant-bound AshOban worker without tenant-wide scanning, ordering overtakes, duplicate emission within EVT-1 dedupe windows, or silent job-loss gaps.

T0-02A must be merged and verified before T0-02B may implement OccurrenceAdmissionPolicy persistence plus root `EVT-2.create_occurrence` and `ticketing.occurrence.created.v1` emission.

## 2. Fresh baseline and governing evidence

Canonical repository baseline for this JIP:

`main@937a811f6558dcebb8de430175e1e79f25f5ca19`

This is the verified merge of PR #58 from accepted authority head:

`96e7b97c33e21ec2f9e1ef2a41cb13588be2a3b5`

Fresh post-merge evidence on the exact main SHA:

| Evidence | Result |
|---|---|
| Authority checks `41047438102` | PASS |
| CI `41047438333` — bootstrap | PASS |
| CI `41047438333` — check_types / Dialyzer | PASS |
| CANON selected | CANON-1 2.0.20 |
| Roadmap | B0 COMPLETE; T0 NEXT |
| TICK-66 | Done / resolved |
| TICK-65 | Planning / non-READY |

The active tracer's `Contracts baseline = 51c47fe7a10b3a04b95a1b7fe85999217e660449` is generation provenance for CANON-1 2.0.20, not an assertion that current GitHub HEAD must equal that SHA. The merged planning snapshot gate deliberately fixes that provenance value. Current implementation and authority freshness are established independently from verified current `main`.

Material governing authority includes:

| Authority | Installed version | Relevance |
|---|---:|---|
| CANON-1 | 2.0.20 | Canonical suite pinning |
| EVT-1 | 3.0.0 | Event envelope, registry, dedupe and ordering |
| EVT-2 | 3.1.0 | T0 event producer semantics; future occurrence event |
| TEN-1 | 2.0.1 | Tenant key, RLS and fail-closed tenant access |
| IAM-1 | 4.2.0 | Actor/capability model |
| IAM-2 | 1.5.0 | Authorization support |
| ERR-1 | 2.0.1 | Canonical error registry |
| OBS-1 | 2.9.1 | Tracing, metrics and logs |
| LOCKS-1 | 3.0.0 | DB-authoritative concurrency/idempotency rules |
| OBQC-1 | 2.2.0 | AshOban/Oban jobs, tenant-safe envelopes, queues and retries |

The installed EVT-1 3.0.0 contract artifact governing registry emission has SHA-256:

`8c49bdee785f70cd26cece299f7251a854eaa7c2de4ca34fe2904a48024db0bf`

A material authority change to these governing semantics makes this JIP stale.

## 3. Technical baseline and capability decisions

Current application baseline remains Elixir 1.20.4 / OTP 29.1.2, Phoenix 1.8.16 resolved, LiveView 1.2.13 resolved, Ash 3.37.2, AshPhoenix 2.3.25, AshPostgres 2.15.2, Postgrex 0.22.4 and PostgreSQL 18.6.

| Capability | Decision | Reason |
|---|---|---|
| Ash 3.37.2 | ADOPT existing | Current stable baseline and compatible |
| AshPostgres 2.15.2 | ADOPT existing | Current stable baseline |
| AshOban 0.10.3 | PREREQUISITE + ADOPT | OBQC-1 2.2.0 profiles this exact capability and source behavior |
| Oban 2.24.x, lock current 2.24.2 | PREREQUISITE + ADOPT as direct dependency | Ticketing will own Oban configuration, migration and job infrastructure |
| Elixir 1.20.5 | DEFER | Patch maintenance; not required by AshOban 0.10.3 |
| AshPhoenix 2.3.26 | DEFER | Patch maintenance; unrelated to this platform prerequisite |
| Tenant-wide AshOban scheduler | REJECT for tenant-scoped outbox work | Contradicts current TEN-1 / OBQC tenant boundary |
| Tenantless scheduled-action fan-out | REJECT for tenant-scoped outbox work | Same reason |
| Hand-written ad-hoc Oban delivery worker | REJECT | OBQC requires participating Ash side-effect workflows to use AshOban |
| External event broker | DEFER | Canonical authority does not select one and 02A ships no production mapping |

No dependency upgrade beyond adding the approved AshOban and Oban prerequisites may be hidden in implementation.

## 4. Reference repositories

`Store_Blueprint_Hardening@cc696a6c076603485d10c65bf6e8a8d174e06e62`

Classification:

- Durable row, indexing, idempotency and retry operational patterns: **ADAPT**.
- Event/email-specific schema semantics: **REFERENCE_ONLY**.
- Hand-written `Oban.Worker` delivery implementation: **REFERENCE_ONLY / MUST NOT be copied as the 02A execution model**.

`LiveFrames@0f50d7a66af5c2f559dfd9431189ed2b73ba150d`

Classification: **NOT_APPLICABLE**. T0-02A has no frontend/UI surface.

References never override canonical authority.

## 5. Scope

T0-02A includes:

1. `Ticketing.Outbox` Ash Domain.
2. Tenant-scoped `Ticketing.Outbox.OutboxEvent`.
3. Tenant-scoped `Ticketing.Outbox.OutboxDedupeKey`.
4. Tenant-scoped `Ticketing.Outbox.OutboxStreamCursor`.
5. Static event-descriptor and delivery-handler interfaces.
6. Same-transaction dedupe reservation, ordering-sequence allocation, event persistence and durable AshOban job insertion.
7. Tenant-bound AshOban delivery execution.
8. Explicit outbox lifecycle, claim lease and generation fencing.
9. EVT-1 finite-window dedupe enforcement.
10. Monotonic ordering enforcement.
11. Retry, recovery-required and governed internal replay.
12. Oban/AshOban dependency, migration and runtime configuration.
13. RLS, authorization, telemetry, tests and implementation documentation.

## 6. Explicit non-goals

T0-02A MUST NOT implement:

- `OccurrenceAdmissionPolicy`;
- `EVT-2.set_occurrence_admission_policy`;
- `Occurrence`;
- `EVT-2.create_occurrence`;
- Event publication;
- occurrence sales opening;
- pricing, offers, inventory or checkout;
- payment behavior;
- `ticketing.occurrence.created.v1` production registration in application code;
- any other production event-to-handler mapping;
- a no-op handler presented as successful delivery;
- an external broker selection;
- a tenant-wide scheduler;
- tenantless fan-out;
- a new cross-tenant privileged database role;
- an operator-facing replay API/UI;
- unrelated dependency upgrades.

Zero production event mappings MUST exist at the end of this increment.

## 7. Decision classification

| Decision | Classification |
|---|---|
| Events are outbox-driven and committed atomically with producer mutation | CONTRACT_LOCKED |
| Tenant scoping, `org_id`, FORCE RLS and transaction-local tenant context | CONTRACT_LOCKED |
| EVT-1 event envelope and registry metadata | CONTRACT_LOCKED |
| Event-specific finite dedupe windows | CONTRACT_LOCKED |
| Replay within dedupe window → `EVT_IDEMPOTENCY_REPLAY` | CONTRACT_LOCKED |
| Registry ordering-key semantics | CONTRACT_LOCKED |
| At-least-once delivery | CONTRACT_LOCKED |
| AshOban 0.10.3 generated envelope and tenant restrictions | CONTRACT_LOCKED |
| Canonical queue/retry restrictions | CONTRACT_LOCKED |
| `Ticketing.Outbox` domain and three-resource persistence model | IMPLEMENTATION_LOCKED by approved JIP |
| Finite-window dedupe resource using expiry-aware DB upsert | IMPLEMENTATION_LOCKED |
| Cursor with last-enqueued and last-delivered sequence | IMPLEMENTATION_LOCKED |
| Claim-generation fencing | IMPLEMENTATION_LOCKED |
| Static dispatcher/handler behavior | IMPLEMENTATION_LOCKED |
| `integrations` queue for primary durable event delivery | IMPLEMENTATION_LOCKED |
| Exact internal helper/file layout not named here | IMPLEMENTATION_FREE |
| Exact nonsemantic index/constraint names | IMPLEMENTATION_FREE |
| Production sink/transport | DEFERRED to producer JIP |
| Current unresolved authority gaps | NONE |

Any implementation discovery that changes a locked decision requires stop → re-Grill → JIP amendment/reapproval.

## 8. Resource ownership and interfaces

### 8.1 Domain

`Ticketing.Outbox`

The domain owns all durable event-delivery infrastructure. Product domains do not own or directly mutate outbox tables.

The product-facing internal interface is:

`Ticketing.Outbox.enqueue/…`

It is a governed internal application interface, not a public API endpoint.

Later producer actions must invoke it inside the producer's governed transaction.

### 8.2 `OutboxDedupeKey`

Purpose: enforce each EVT-1 event type's finite dedupe window without imposing permanent uniqueness on retained historical `OutboxEvent` rows.

Core persisted fields:

- `org_id`
- `event_type`
- `dedupe_key_sha256`
- `active_until_utc`
- `reserved_outbox_event_id`
- database-generated timestamps

Identity / DB constraint:

`(org_id, event_type, dedupe_key_sha256)` MUST be unique.

`dedupe_key_sha256` is lowercase 64-character SHA-256 hex.

The reservation action uses an Ash create/upsert. Conflict replacement is allowed only when:

`active_until_utc <= database_now`

The accepted reservation atomically writes the new active-until value and proposed outbox-event identity.

If an unexpired row already exists, enqueue fails:

`ERR_CONFLICT / EVT_IDEMPOTENCY_REPLAY`

This applies even when the replayed payload is byte-identical.

At the exact expiry boundary, `database_now >= active_until_utc` means the previous dedupe window has expired and a new reservation may succeed.

No permanent uniqueness is imposed on `OutboxEvent` dedupe values.

### 8.3 `OutboxStreamCursor`

Purpose: allocate deterministic per-stream delivery sequence and prevent later events from overtaking an earlier non-delivered event.

Core persisted fields:

- `org_id`
- `ordering_key_sha256`
- `last_enqueued_sequence`
- `last_delivered_sequence`
- database-generated timestamps

Identity / DB constraint:

`(org_id, ordering_key_sha256)` MUST be unique.

Invariants:

`last_enqueued_sequence >= 1`

`0 <= last_delivered_sequence <= last_enqueued_sequence`

Sequence allocation uses one concurrency-safe Ash upsert:

- absent cursor → `last_enqueued_sequence = 1`, `last_delivered_sequence = 0`;
- existing cursor → atomically increment `last_enqueued_sequence`;
- returned value becomes the new `OutboxEvent.ordering_sequence`.

Acknowledgement advances `last_delivered_sequence` only with CAS:

current `last_delivered_sequence == event.ordering_sequence - 1`.

The cursor is not deleted when historical events are later purged; otherwise monotonic sequence could reset.

### 8.4 `OutboxEvent`

Core immutable event fields:

- `org_id`
- `outbox_event_id` UUIDv7
- `cloud_event_id` UUIDv7
- `specversion`
- `source`
- `event_type`
- `event_time_utc`
- `datacontenttype`
- `topic`
- `registry_version_sha`
- `trace_id`
- `request_id`
- `data` JSONB
- `dedupe_key_sha256`
- `dedupe_window_seconds`
- `dedupe_active_until_utc`
- `ordering_key_sha256`
- `ordering_sequence`

Mutable delivery fields:

- `state`
- `claim_generation`
- `claim_job_id`
- `claimed_at_utc`
- `lease_expires_at_utc`
- `attempt_count`
- `delivered_at_utc`
- `recovery_required_at_utc`
- safe `last_error_code`
- safe `last_error_category`
- safe `last_error_at_utc`
- database-generated timestamps

Composite primary identity is org-first:

`(org_id, outbox_event_id)`

Unique ordering constraint:

`(org_id, ordering_key_sha256, ordering_sequence)`

Payload, envelope, dedupe and ordering identity are immutable after enqueue. Lifecycle actions may mutate only delivery-state fields.

## 9. Event descriptor and canonical hashing

02A defines an internal static descriptor behavior but ships zero production descriptors.

A future production descriptor must provide the exact canonical registry facts for its event type, including:

- registered type;
- source/topic;
- required payload keys;
- dedupe-key fields;
- dedupe window normalized to seconds;
- ordering-key fields;
- supported ordering mode;
- delivery handler.

Descriptors MUST be backed by tests against the installed EVT-1 authority that governs emission.

Unknown/unregistered event type fails closed as `EVT_INVALID_TYPE`.

Missing required envelope/context fails as `EVT_CONTEXT_MISSING`.

### Dedupe digest

The dedupe digest MUST bind the event type because EVT-1 dedupe identity is event-type-specific.

Conceptually the JCS input is:

`{event_type, ordered_dedupe_fields: [[field_name, canonical_value], ...]}`

The field order is the registry order.

Digest:

`sha256(utf8(JCS(value)))`

Different event types with identical field values MUST NOT collide.

### Ordering digest

The ordering digest MUST NOT add the event type.

Conceptually:

`{ordered_fields: [[field_name, canonical_value], ...]}`

This deliberately allows different lifecycle event types with the same canonical ordering key to share one stream and prevents them from overtaking each other.

Digest:

`sha256(utf8(JCS(value)))`

02A supports the monotonic ordering mode required by the current T0 path. A descriptor requiring a different ordering model MUST fail registration until a future reviewed JIP adds that capability.

## 10. Enqueue transaction and atomicity

For every accepted enqueue the following operations MUST share one PostgreSQL transaction:

1. Validate tenant and static descriptor.
2. Validate event envelope and required payload keys.
3. Generate UUIDv7 outbox and CloudEvent identities.
4. Reserve the finite dedupe window.
5. Allocate the next ordering-stream sequence.
6. Persist `OutboxEvent` in `pending`.
7. Insert the tenant-bound AshOban delivery job.

The job MUST therefore be durable before the transaction commits, while actual delivery MUST occur only after commit.

AshOban 0.10.3's generated-trigger insertion may be used from an Ash `after_action` because that hook executes before the Ash transaction closes. The implementation MUST nevertheless prove this with integration tests against `Ticketing.Repo`.

A forced rollback after the enqueue step MUST leave:

- no dedupe reservation;
- no cursor increment;
- no `OutboxEvent`;
- no Oban job.

A successful commit MUST persist all four.

Later producer JIPs must include the producer resource and the outbox resources in the same outer `Ash.transact` boundary.

If Ash/AshPostgres/AshOban cannot prove this exact atomicity, implementation MUST STOP and report a technical blocker. That is not permission for an unapproved direct Repo or raw-SQL workaround.

## 11. OutboxEvent lifecycle

Persisted states:

`pending`  
`claimed`  
`delivered`  
`recovery_required`

`delivered` is terminal.

`recovery_required` is nonterminal but may leave only through the governed replay transition.

| From | To | Initiator | Required guards | Side effects |
|---|---|---|---|---|
| absent | pending | internal enqueue | valid tenant, descriptor, context, dedupe reservation and sequence | persist event + AshOban job |
| pending | claimed | tenant-bound AshOban delivery | event is stream head; CAS pending; tenant matches | increment generation and attempt; set job, claim time and lease |
| claimed | delivered | delivery orchestration | matching generation; explicit handler success; cursor CAS succeeds | set delivered time; advance cursor |
| claimed | pending | delivery orchestration | matching generation; retryable failure | clear active claim; record safe failure; Oban retry remains authoritative |
| claimed | pending | delivery orchestration | lease expired | recover abandoned claim; clear lease; next claim receives new generation |
| claimed | recovery_required | delivery orchestration / final error path | matching generation; permanent failure or attempts exhausted | record recovery timestamp and safe failure |
| recovery_required | pending | trusted internal replay | same tenant; immutable event identity/payload; no active claim | clear recovery state and enqueue new tenant-bound delivery job |
| delivered | any other state | none | always forbidden | none |

Claim generation is a monotonically increasing integer fence.

Every acknowledge, retry-release or recovery transition from `claimed` MUST supply the generation returned by the successful claim.

A stale generation MUST fail closed and MUST NOT mutate the row.

Claim lease default:

`120 seconds`

Maximum handler execution timeout:

`60 seconds`

Changing either relationship materially requires re-review; the handler timeout MUST remain strictly shorter than the claim lease.

An unexpired claimed row cannot be stolen.

## 12. Ordering algorithm

For a stream cursor with `last_delivered_sequence = N`, only event sequence `N + 1` may become claimed.

An event with sequence greater than `N + 1` is blocked by an earlier event.

Blocked jobs MUST use AshOban/Oban snooze semantics rather than consuming retry attempts. The initial implementation uses a fixed 30-second snooze for head-of-line blocking.

A head event in `recovery_required` leaves the cursor unchanged. All successors remain blocked until that head is replayed and eventually delivered.

Acknowledging sequence `N + 1` and advancing the cursor to `N + 1` MUST happen atomically.

Independent ordering-key digests MUST remain independently executable and must not serialize each other.

No session-level advisory locks are permitted.

## 13. Tenancy, authorization and RLS

All three resources are tenant scoped by `org_id`.

Required PostgreSQL posture:

- `ENABLE ROW LEVEL SECURITY`;
- `FORCE ROW LEVEL SECURITY`;
- transaction-local `app.current_org_id`;
- org-first primary/unique/index design;
- application runtime role without superuser or `BYPASSRLS`.

Every tenant-scoped Ash operation requires an explicit tenant.

AshOban delivery jobs require:

- framework `tenant`;
- `ticketing_payload.args.org_id`;
- exact equality between those two values;
- tenant establishment before governed Ash access.

Missing or mismatched identity fails closed before resource access.

Tenant-wide scheduler discovery is prohibited.

Scheduled-action tenantless fan-out/fallback is prohibited.

The generated delivery trigger uses:

`actor_persister :none`

No raw actor, bearer token, PII or full permission snapshot is serialized into the job.

No action uses `authorize?: false`.

Delivery actions may authorize through the canonical AshOban internal-interaction context, restricted to the delivery actions.

Non-worker infrastructure actions use a dedicated private Ticketing outbox interaction context and remain inaccessible through HTTP/LiveView/public API surfaces.

Replay is internal/system-only in 02A. No human-facing replay capability is invented.

Wrong-tenant access follows canonical TEN/ERR existence-hiding behavior.

## 14. AshOban/Oban delivery profile

Delivery MUST use an AshOban-generated trigger attached to `OutboxEvent`.

Locked trigger posture:

- `scheduler_cron false`;
- direct tenant-bound trigger insertion;
- `trigger_once? false` so governed replay remains possible;
- `actor_persister :none`;
- job context available to the orchestration action;
- stable explicit worker and scheduler identities.

Stable generated names:

`Ticketing.Outbox.Jobs.DeliverEventWorker`

`Ticketing.Outbox.Jobs.DeliverEventScheduler`

The scheduler module identity is reserved/stable even though scheduler execution is disabled.

Primary queue:

`integrations`

Reason: delivery is a durable cross-boundary event-integration path and must not be coupled to low-priority housekeeping. No new queue name is introduced.

Latency profile:

`STANDARD`

Retry class/profile:

`recovery`

Maximum attempts:

`7` total attempts: initial attempt plus six retry delays.

Recovery delays use the canonical sequence:

`15, 30, 60, 300, 900, 3600 seconds`

with jitter.

Library-default backoff MUST NOT be relied upon.

Head-of-line snoozes do not consume attempts.

Full persisted Oban args, including framework metadata, MUST remain below 8192 bytes and SHOULD remain at or below 2048 bytes.

Ticketing-controlled job payload:

`action_arguments.ticketing_payload`

Payload v1 contains only the minimum required pointer material:

`org_id`  
`outbox_event_id`

Current and immediately previous semantic payload versions MUST remain readable during rolling deploys. Unknown versions fail closed.

Oban uniqueness is a duplicate-job helper only. Database constraints and outbox lifecycle remain the correctness authority.

The canonical required Oban available-job priority index MUST be verified through `pg_catalog`.

Worker concurrency MUST satisfy OBQC's DB-pool/topology formula and the canonical queue maximum. The implementation may choose the concrete environment value only after calculating it from the actual runtime pool/topology; it may not blindly copy the queue maximum.

## 15. Delivery dispatcher boundary

02A defines a static internal dispatcher and handler behavior.

The database MUST NOT contain arbitrary module names used for dynamic dispatch.

Conceptual handler result surface:

- explicit success;
- explicit retryable failure with safe classification;
- explicit permanent failure with safe classification.

An event becomes `delivered` only after explicit handler success.

A successful Oban process by itself is NOT proof of event delivery.

An unregistered handler is a permanent configuration failure and MUST transition the event to `recovery_required`; it MUST NOT silently acknowledge the event.

Production handlers MUST be idempotent or perform durable deduplication using the stable event identity because at-least-once execution permits this sequence:

1. handler side effect succeeds;
2. process crashes before outbox acknowledgement;
3. lease expires;
4. worker runs again;
5. handler receives the same event again.

02A MUST include a test handler that proves this crash/replay behavior.

02A MUST NOT ship a production event mapping.

A later producer JIP cannot activate an event type until it defines and verifies a real production handler/sink. A no-op handler is not an acceptable production sink.

## 16. Retry and recovery behavior

Retryable handler failure:

- transition `claimed → pending`;
- preserve immutable event data and ordering sequence;
- return failure to Oban;
- use the explicit recovery backoff.

Permanent handler failure:

- transition `claimed → recovery_required`;
- complete the current job without pretending delivery succeeded.

Final retry exhaustion:

- transition to `recovery_required` through the AshOban final-error path;
- do not advance the ordering cursor.

Unexpected crash while claimed:

- leave durable claim intact;
- retrying worker may not steal it until lease expiry;
- expired claim returns to `pending`;
- subsequent claim increments `claim_generation`.

Replay:

- only from `recovery_required`;
- same event row;
- same CloudEvent ID;
- same event type;
- same payload;
- same dedupe identity;
- same ordering sequence;
- new tenant-bound AshOban job;
- no new event emission record and no new dedupe reservation.

## 17. Canonical errors

No new public error code is introduced by 02A.

Applicable existing mappings:

| Condition | Canonical result |
|---|---|
| unknown/unregistered event type | `EVT_INVALID_TYPE` |
| missing required event context | `EVT_CONTEXT_MISSING` |
| dedupe-key replay inside active EVT-1 window | `ERR_CONFLICT / EVT_IDEMPOTENCY_REPLAY` |
| stale lifecycle/CAS fence if surfaced | `ERR_CONFLICT / LOCKS_OPTIMISTIC_CONFLICT` |
| missing/wrong tenant | canonical TEN/ERR fail-closed existence-hiding behavior |

Delivery-provider/handler failures remain safe internal background error records unless a later authority contract defines a public surface.

Payloads, secrets, tokens and sensitive raw provider responses MUST NOT appear in error records.

## 18. Observability and audit

Required traces/spans:

`outbox.enqueue`  
`outbox.delivery_attempt`  
`outbox.replay`

Structured logging includes only safe bounded identifiers/context:

- `org_id` in structured logs where canonically permitted;
- `outbox_event_id`;
- event type;
- lifecycle state;
- attempt;
- claim generation;
- trace ID;
- request ID;
- safe error classification.

Never log event payloads, bearer tokens, secrets or raw PII.

Required metrics include:

- enqueue count by registered event type;
- delivery success count;
- retry count;
- recovery-required count;
- oldest pending age;
- delivery latency;
- ordering-blocked count;
- stale-fence rejection count.

High-cardinality identifiers such as `org_id`, outbox event ID, request ID and trace ID MUST NOT be metric labels.

Telemetry must allow detection of:

- growing recovery-required backlog;
- head-of-line blocked streams;
- abnormal retry rates;
- oldest-pending SLO degradation;
- unknown handler/configuration failures.

## 19. Persistence constraints and indexes

At minimum the generated migrations must create:

### `outbox_dedupe_keys`

- org-first composite identity;
- unique `(org_id, event_type, dedupe_key_sha256)`;
- active-until index suitable for maintenance;
- digest format/length validation;
- FORCE RLS.

### `outbox_stream_cursors`

- unique `(org_id, ordering_key_sha256)`;
- nonnegative sequence checks;
- `last_delivered_sequence <= last_enqueued_sequence`;
- FORCE RLS.

### `outbox_events`

- composite primary key `(org_id, outbox_event_id)`;
- unique `(org_id, ordering_key_sha256, ordering_sequence)`;
- state/check constraints;
- nonnegative claim generation and attempt count;
- tenant/state indexes needed by delivery/recovery;
- stream/sequence indexes;
- immutable-event-field posture through governed action accepts and no generic lifecycle mutation;
- FORCE RLS.

No raw SQL or direct Repo implementation path is permitted merely for convenience.

If an exact DB correctness requirement cannot be expressed safely through AshPostgres generated migrations/actions, implementation must stop and identify the specific limitation before proposing a narrow infrastructure exception.

## 20. Retention

EVT-1 currently records 365-day event-data retention.

`OutboxEvent` MUST persist the canonical retention deadline required for the event.

02A does not introduce a tenant-wide purge scheduler because current authority prohibits the required cross-tenant scheduler model.

It may define a tenant-bound internal purge action for safely purgeable historical delivered rows, but no production-wide scheduler is authorized by this JIP.

No pending, claimed or recovery-required event may be deleted merely because a retention deadline elapsed without first resolving the conflict between delivery durability and retention authority.

Before any production producer is activated, retention invocation/orchestration must be re-checked against the then-current canonical privacy/retention authority.

This is not a blocker for 02A because 02A creates no production event mappings.

## 21. Migration, rollout and rollback

Implementation adds only the approved dependency surface:

- `ash_oban ~> 0.10.3`;
- direct `oban ~> 2.24`, resolving to the reviewed compatible 2.24.x release.

Required migrations include:

- canonical Oban migration for the selected Oban release;
- outbox dedupe table;
- outbox stream cursor table;
- outbox event table;
- RLS;
- constraints/indexes;
- required Oban index verification.

Rollout sequence:

1. Add dependencies and Oban database support.
2. Add outbox schema/RLS.
3. Add Ash resources/domain.
4. Add enqueue transaction.
5. Add generated tenant-bound delivery trigger.
6. Add dispatcher with test-only mapping.
7. Run migration, RLS, transaction, race and job-version tests.
8. Enable configured queue with no production event descriptors.
9. Merge only after independent exact-diff review and fresh CI.

Because 02A ships no production producer/mapping, initial rollback may remove the dependency/config/schema only after confirming no live outbox rows/jobs exist.

After a future producer becomes active, destructive rollback is prohibited until durable events/jobs are drained or a compatible rollback path preserves them.

## 22. Required tests

The derivative spec and implementation tickets MUST cover at least the following test classes.

### Dedupe

- first reservation succeeds;
- identical dedupe replay within the registered window fails `EVT_IDEMPOTENCY_REPLAY`;
- changed payload with the same active dedupe key also remains a replay conflict;
- exact expiry boundary allows a new reservation;
- same key after expiry succeeds;
- same field values under different event types do not collide;
- concurrent reservation race produces exactly one success;
- same logical identity across two tenants remains independent.

### Ordering

- same stream receives strictly increasing sequences;
- different event types sharing the same canonical ordering key share one stream;
- independent ordering keys proceed concurrently;
- successor cannot claim before predecessor delivery;
- delivered acknowledgement advances cursor exactly once;
- recovery-required head blocks successors;
- replayed head preserves original sequence;
- head-of-line snooze does not consume retry attempts.

### Transactionality

- dedupe + cursor + outbox + Oban job commit together;
- forced rollback removes all four;
- no durable outbox row may exist without its initial job after a committed enqueue;
- no initial job may exist without its committed event row;
- later producer integration must prove producer mutation joins this same transaction.

### Lifecycle/concurrency

- all valid transitions;
- every invalid transition;
- delivered is terminal;
- stale generation cannot acknowledge;
- stale generation cannot release retry;
- stale generation cannot enter recovery;
- unexpired claim cannot be stolen;
- expired claim can be recovered;
- concurrent claims result in one current owner;
- cursor CAS prevents out-of-order acknowledgement.

### Tenancy/security

- missing tenant fails closed;
- framework tenant/payload org mismatch fails before Ash access;
- wrong-tenant event is hidden according to TEN/ERR;
- FORCE RLS is verified under constrained DB role;
- runtime role has no superuser/BYPASSRLS;
- generated scheduler does not exist/run for tenant-scoped delivery;
- tenantless scheduled-action fan-out is absent;
- actor is not persisted;
- no payload/token/PII leakage into job args or logs.

### Delivery/recovery

- explicit handler success delivers;
- job completion without handler acknowledgement cannot deliver;
- retryable failure returns to pending and retries;
- permanent failure enters recovery-required;
- retry exhaustion enters recovery-required;
- missing handler enters recovery-required;
- recovery-required does not advance cursor;
- replay queues a new job without changing event identity;
- crash after handler side effect but before acknowledgement causes duplicate handler invocation rather than event loss;
- idempotent test handler proves duplicate delivery is safe.

### AshOban/Oban compatibility

- exact AshOban 0.10.3 capability profile;
- stable generated module names;
- `scheduler_cron false`;
- current payload version accepted;
- immediately previous payload version accepted once one exists;
- unknown payload version rejected;
- framework reserved keys cannot be replaced;
- complete args remain under absolute size cap;
- required Oban `pg_catalog` index exists;
- custom recovery backoff is used instead of library default.

### Quality/rollback

- generated migration checks;
- clean migration up;
- safe rollback test where applicable;
- no production descriptor/mapping exists;
- no Occurrence/policy/product work entered the diff;
- `mix precommit`;
- application CI;
- Dialyzer.

## 23. Documentation impact

Implementation documentation describes merged state only and remains derived, nonsemantic documentation.

Required documentation impact:

`UPDATE ticketing/docs/README.md`

`UPDATE ticketing/docs/platform/database.md`

`UPDATE ticketing/docs/platform/runtime.md`

`UPDATE ticketing/docs/platform/tenancy-and-authorization.md`

`UPDATE ticketing/docs/platform/testing-and-quality-gates.md`

`CREATE ticketing/docs/platform/outbox-and-job-delivery.md`

`CREATE ticketing/docs/handoffs/JIP-T0-02A.md`

Do not create Occurrence or admission-policy implementation dossiers in 02A.

The handoff must record the exact merged main SHA, governing JIP, dependency versions, migrations, tests, implementation decisions and remaining producer prerequisites.

## 24. Risks and implementation stop conditions

There is no known canonical authority gap blocking this DRAFT.

The following are technical proof obligations, not permission to improvise:

**Ash transaction + Oban insertion:** implementation must prove the Oban row participates in the same PostgreSQL transaction as the outbox rows.

**Expiry-aware Ash upsert:** implementation must prove `OutboxDedupeKey` can atomically replace only an expired reservation using database time under concurrency.

**Cursor atomicity:** implementation must prove sequence allocation and delivered-cursor CAS under concurrent requests.

**AshOban generic orchestration/final error path:** exact 0.10.3 behavior must be tested for retry exhaustion and recovery transition.

If any proof fails, stop the affected implementation and return to JIT. Do not replace it with direct Repo/raw SQL/ad-hoc workers without reviewed JIP amendment.

Production delivery transport remains deliberately deferred. That becomes a blocker only when a future producer attempts to activate a production mapping.

## 25. Derivative spec requirement

After explicit approval of this JIP, run `to-spec`.

The derivative spec is warranted because implementation spans three resources, a shared transaction, generated AshOban execution, finite-window concurrency, a lifecycle state machine, ordering cursor CAS, replay and rollout behavior.

The spec may make implementation mechanics more precise but MUST NOT change semantics locked by this JIP or canonical authority.

After the spec is reviewed, run `to-tickets` and create one `[JIP]` parent plus small dependency-linked child tickets.

No implementation child becomes READY merely because this JIP is approved.

## 26. Definition of Done

JIP-T0-02A is complete only when:

- this JIP was explicitly approved;
- required derivative spec and Plane decomposition were completed;
- AshOban and Oban decisions were implemented without unrelated upgrades;
- the three Ash resources and domain are implemented;
- all tenancy/RLS constraints pass;
- finite-window event dedupe passes;
- stream ordering and cursor CAS pass race tests;
- the outbox lifecycle and all invalid transitions pass;
- same-transaction dedupe/cursor/event/Oban insertion is proven;
- retry, crash, exhaustion and replay tests pass;
- no production event mapping exists;
- migration/generated-code checks pass;
- `mix precommit` passes;
- exact-head CI and Dialyzer pass;
- independent PR review verifies authority + JIP/spec + Plane + exact diff;
- required implementation docs are updated;
- `ticketing/docs/handoffs/JIP-T0-02A.md` is verified against merged main;
- no unresolved blocker or authority gap remains.

After merge and verified closeout, re-pin `main` and run a targeted re-Grill before drafting T0-02B for OccurrenceAdmissionPolicy persistence, root Occurrence creation and atomic `ticketing.occurrence.created.v1` enqueue.

---

**Approval boundary**

This document remains `DRAFT` until the user explicitly accepts **JIP-T0-02A v0.2.0**.

Approval authorizes derivative specification and ticket decomposition only. It does not by itself authorize arbitrary implementation work, future T0 scope, dependency upgrades outside the decisions above, or a production event sink.