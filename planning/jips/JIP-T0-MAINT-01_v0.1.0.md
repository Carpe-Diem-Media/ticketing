# JIP-T0-MAINT-01 v0.1.0: TICK-67 dependency-baseline decision

**Status:** DRAFT, pending independent control-tower review and explicit owner decision.
**Nature:** Technical-maintenance decision packet, not canonical product authority or implementation readiness.
**Verified:** 2026-11-17 against GitHub `main` `937a811f6558dcebb8de430175e1e79f25f5ca19`.
**Execution record:** TICK-67, `3396dad8-815a-4c6d-85aa-4b0584cca0f4`, Planning, High.
**Separate incident:** TICK-68, `cde188cf-b669-4829-aa1c-c2b09f14564e`, Planning, High.
**Context Docs:** this packet, root `AGENTS.md`, `planning/WORKFLOW.md`, and the exact candidate/review below.

## 1. Decision requested and authorization boundary

Choose between accepting the complete existing PR #60 dependency baseline through governed review, or authorizing preparation of a smaller security-only candidate. Neither option is approved by this draft. Neither the prior request to continue maintenance nor green CI established an approved maintenance JIP or READY work item. The earlier implementation preceded that gate; this packet records the gap rather than backdating approval.

The candidate is [PR #60](https://github.com/Carpe-Diem-Media/ticketing/pull/60), exactly `2fa4a87fe5ffb9cff595ab9a4e6b5113313cb966`, tree `615670dc20518417a43f816dee9cd6a1f34761d9`. [Independent review 5933916940](https://github.com/Carpe-Diem-Media/ticketing/pull/60#pullrequestreview-5933916940) remains **CHANGES REQUESTED**. Its technical checks pass; maintenance-scope approval and secret-exposure triage block merge. No review is dismissed or superseded here.

Only this planning document changes. PR #60's branch/head, dependencies, source, configuration and existing CI evidence are preserved. Do not merge PR #60 or PR #59, change ticket readiness, derive SPEC-T0-02A, rotate credentials, or operate shared infrastructure under this packet.

## 2. Freshness and authority evidence

- GitHub `main` and PR #60 base: `937a811f6558dcebb8de430175e1e79f25f5ca19`; candidate commit signature verified by GitHub. Remote branch/head were checked independently of the local checkout.
- Root `AGENTS.md` blob: `169e6b99cb699c4faeaa89892bf82b8199b2d86d`; `planning/WORKFLOW.md`: `0b3599281587dba0dde7576e46b8f7e19221b269`; scoped `ticketing/AGENTS.md`: `020b5dfe8900d65b3ff83e89c0c37a5b8c7a2614`.
- ROADMAP blob: `6c7d6cd09f79eb12803ac1032089cfaa304c6921`; active tracer `authority/planning/tracers/T0-tenant-scoped-ga-pending-sale.md` blob: `d018703915cff95fb4bf30b02e117b0e2ab0b9fd`. T0 remains NEXT and ends at a persisted draft Order. Maintenance adds no tracer capability.
- Manifest blob: `88acda4a454bae2efaf8c23889f414b17c10d926`; SHA-256: `0c110b2237e186cbf402521e983374f64dc2d5d09b34ae3335cd0e833f611317`. Fresh manifest verification found 58 contracts VALID; CANON-1 2.0.20 verification found 56 member pins VALID. The latest main commit touching installed contracts is `96e7b97c33e21ec2f9e1ef2a41cb13588be2a3b5`; tracer `Contracts baseline` `51c47fe7a10b3a04b95a1b7fe85999217e660449` remains generation provenance, not current implementation HEAD.
- Applicable unchanged authority includes ARCH-1 3.0.4, TEN-1 2.0.1, IAM-1 4.2.0, IAM-2 1.5.0, EVT-2 3.1.0, ERR-1 2.0.1, OBS-1 2.9.1, EVT-1 3.0.0, LOCKS-1 3.0.0 and OBQC-1 2.2.0. The installed suite and CANON remain controlling; this list does not narrow their applicability.
- TICK-67/TICK-68 records were independently retrieved by the connected ChatGPT control tower and supplied by the owner in this session. This coding session has no Plane tool/CLI. Their supplied states are Planning, not READY. Live dependencies, parentage, native blocker relations and later changes are not independently accessible here. The control tower will reconcile them after packet review; no ticket update is claimed.
- [PR #59](https://github.com/Carpe-Diem-Media/ticketing/pull/59) remains OPEN at `1b7e26fcef0a95a558ae00cc443393d9d55438ad`. Its recovered JIP-T0-02A v0.2.0 is DRAFT and records the old Ash/AshPostgres baseline. It forbids hidden dependency upgrades. TICK-65 and that packet need targeted freshness/re-Grill after any accepted maintenance merge; do not derive a spec or promote readiness from this analysis.

### Exact implementation diff

The complete base-to-head diff contains one commit and eight files, 57 additions and 66 deletions:

- `ticketing/mix.exs`, `ticketing/mix.lock`, `ticketing/config/config.exs`;
- `scripts/ci/ensure-tailwind-binary.sh`, `scripts/ci/test-tailwind-acquisition.sh`;
- `.agents/skills/ash-framework/SKILL.md`, `.agents/skills/elixir-otp/SKILL.md`, `.agents/skills/phoenix-framework/SKILL.md`.

There are 31 Hex version changes, two removed unused lock entries and zero added packages. No domain source, migration, resource snapshot, authority, toolchain pin, credential, or UI composition changes. The three UsageRules changes update generated task indexes only. The fetched `gh pr diff 60` text has SHA-256 `500cc498ab7f1c5abf68b25f613fdbbfd91a4c83b66879b0eaac78237356ab71`; base/head and per-file diff remain the governing comparison.

## 3. Upgrade classification

Classes express maintenance rationale, not approval. **S** means security-required replacement or security-retirement remediation. **C** means compatibility-required only after selecting another candidate upgrade. **E** means elective maintenance; a transitive relationship alone does not make a version change required. An S package can include optional changes beyond its minimum repaired version.

Release dependency evidence is the exact base/candidate `mix.lock` entries and the versioned [Hex release API](https://hex.pm/api/packages/ash_postgres/releases/2.16.0), with the corresponding package/version endpoint for every row. All 31 candidate release records were fetched; none reports retirement. Package metadata and existing CI support compatibility, not an assurance that every upstream path has been tested.

| Package | Base to candidate | Class and necessity |
| --- | --- | --- |
| ash | 3.37.2 to 3.37.6 | C. AshPostgres 2.16.0 and Ash SQL 0.8.9 require at least 3.37.6. This core upgrade is not needed by Ash SQL 0.8.6. |
| ash_phoenix | 2.3.25 to 2.3.26 | E. Existing compatible integration can remain for the narrow option. |
| ash_postgres | 2.15.2 to 2.16.0 | E. Material data-layer/generator changes; not compelled by the security-only chain. |
| ash_sql | 0.8.4 to 0.8.9 | S. 0.8.4 is security-retired and directs upgrading to 0.8.6. Selecting 0.8.9 exceeds that floor and is required by elected AshPostgres 2.16.0. |
| bandit | 1.14.1 to 1.15.0 | S, subject to advisory reconciliation below. Newly published HTTP/2 trailer-logging advisory lists versions 0.3.7 through 1.14.1 as affected; 1.15.0 source/release notes contain its fix. |
| crux | 0.1.4 to 0.1.5 | E. Ash's compatible minimum remains 0.1.2; the old lock satisfies it. |
| dialyxir | 1.4.8 to 1.4.9 | E. Development/test analysis tool. |
| dns_cluster | 0.2.0 to 0.3.1 | E. Runtime discovery changes; independent of the security chain. |
| ecto | 3.14.2 to 3.14.3 | S. Minimum repaired 3.14 branch for EEF-CVE-2026-118391. |
| elixir_make | 0.10.0 to 0.10.1 | E. LazyHTML/cc_precompiler ranges admit the old version. |
| esbuild | 0.10.0 to 0.10.1 | E. Mix wrapper update; the binary remains 0.28.2. |
| fine | 0.1.6 to 0.2.0 | C. Elected LazyHTML 0.1.14 requires Fine `~> 0.2.0`. |
| idna | 6.1.1 to 7.1.0 | E. Swoosh accepts both through `>= 6.0.0 and < 8.0.0`. |
| igniter | 0.8.4 to 0.8.5 | E. Development/test generation tooling; compatible constraints admit the old version. |
| lazy_html | 0.1.13 to 0.1.14 | E. Test-only HTML/NIF tooling; causes the Fine compatibility change. |
| nimble_options | 1.1.1 to 1.2.0 | E. Finch 0.24.0 accepts `~> 0.4 or ~> 1.0`; old version fits. |
| nimble_pool | 1.1.0 to 1.2.0 | E. Finch 0.24.0 accepts `~> 1.1`; old version fits. |
| phoenix_html | 4.3.0 to 4.4.0 | S. Minimum repaired 4.x branch for EEF-CVE-2026-117645. |
| phoenix_live_dashboard | 0.8.7 to 0.9.1 | E. Direct integration update; not required by Phoenix.HTML 4.4.0. |
| phoenix_live_reload | 1.6.2 to 1.7.0 | E. Direct DEV dependency; Tidewave's minimum 1.6.1 admits the old version. |
| sobelow | 0.16.0 to 0.19.0 | E. Security-analysis tooling maintenance, not a demonstrated security-required package repair. |
| sourceror | 1.12.3 to 1.13.0 | E. Igniter/Rewrite ranges admit the old version. |
| spark | 2.7.6 to 2.7.10 | E. Ash's minimum remains 2.7.6. |
| spitfire | 0.4.2 to 0.4.3 | E. Igniter's minimum/range admits the old version. |
| splode | 0.3.2 to 0.3.3 | E. Ash/Reactor compatible ranges admit the old version. |
| swoosh | 1.29.0 to 1.29.3 | E. Direct mail dependency; no required security movement established. |
| tailwind | 0.5.1 to 0.5.2 | E. Mix acquisition/build wrapper; separate from the binary below. |
| telemetry | 1.4.2 to 1.4.3 | E. Existing Ash/Bandit/Ecto ranges admit the old version. |
| telemetry_metrics | 1.1.0 to 1.2.0 | E. Direct metrics dependency; Dashboard accepts both through `~> 1.0`. |
| usage_rules | 1.2.8 to 1.3.1 | E. Development/test generated documentation tooling. |
| websock_adapter | 0.6.0 to 0.7.2 | E. Phoenix/Tidewave accept `~> 0.5`; old version fits. |
| Tailwind CSS binary | 4.3.3 to 4.3.5 | E. Build-time patch update. No advisory necessity established from its release notes. |

There are four S, two C and 25 E Hex updates, plus the E Tailwind binary update. Removed `libgraph` 0.16.0 was already unused in the base graph, not newly replaced by this PR. Removed `unicode_util_compat` 0.7.1 was required by IDNA 6.1.1; IDNA 7.1.0 removes that edge. Those cleanups belong to the complete-refresh option; they are not security-only requirements.

### Security evidence and uncertainty

- [Ecto advisory](https://osv.dev/vulnerability/EEF-CVE-2026-118391): attacker-influenced JSON paths/list shapes can grow query-cache memory. The candidate reaches 3.14.3. [Phoenix.HTML advisory](https://osv.dev/vulnerability/EEF-CVE-2026-117645): untrusted attribute names permit injection; candidate reaches 4.4.0. Application exploitability was not independently demonstrated here.
- [Ash SQL 0.8.4 retirement metadata](https://hex.pm/api/packages/ash_sql/releases/0.8.4) explicitly records reason `security` and directs upgrading to 0.8.6 for query-planning/cache correctness. This is a security-retirement requirement even without a separate CVE for this version. The exact 0.8.9 target is not the minimum fix.
- New evidence beyond the supplied TICK-67 description: [Bandit GHSA-j9wq-h5xx-5qx5](https://github.com/mtrudel/bandit/security/advisories/GHSA-j9wq-h5xx-5qx5), published 2026-11-16, lists versions 0.3.7 through 1.14.1 as affected but its patched field still says `None`. The [tagged 1.15.0 changelog](https://github.com/mtrudel/bandit/blob/1.15.0/CHANGELOG.md) identifies the advisory fix, and [tagged source](https://github.com/mtrudel/bandit/blob/1.15.0/lib/bandit/http2/stream.ex#L390) logs only the field count. Therefore classify the upgrade as security remediation, while requiring independent reconciliation of this metadata discrepancy before accepting the security claim. Historical clean Hex audit alone does not resolve it. Do not retain 1.14.1 as a supposedly safe narrow-option default.

## 4. Technical JIT assessment and inherited constraints

**CONTRACT_LOCKED:** domain ownership, actor/tenant proof, fail-closed authorization, transaction-local tenant GUC, FORCE RLS, canonical errors, transaction/rollback guarantees, event/outbox ownership and existing lifecycle boundaries remain unchanged. Ordinary canonical reads/writes remain governed Ash actions/interfaces through AshPostgres. No direct Repo/SQL bypass, new actions/resources, authorization exceptions, events, jobs, inventory or money behavior are selected.

**Proposed IMPLEMENTATION_LOCKED, conditional on owner approval:** either option A's exact immutable package/binary set, or option B's authorized preparation boundary. These are not currently locked decisions. Source formatting and evidence presentation are IMPLEMENTATION_FREE. No new product AUTHORITY_GAP was found; missing maintenance approval and incident disposition are governance/operational blockers, not permission to invent product semantics.

### Ash, persistence and tenancy

Ash 3.37.6 changes filtering/calculations, generic action defaults, policy context and bulk-action cleanup relative to 3.37.2. Those are material framework behaviors even without application-source edits. The prior tenant-security baseline is retained; this is not permission to change policies. Existing Event-create authorization/rollback and concurrent-slug tests, Identity runtime RLS tests, tenant-GUC continuity/cleanup and privacy tests ran in the candidate's 119-test suite. Those tests support existing flows, not all upstream bulk-action or relationship permutations. See [versioned Ash changes](https://github.com/ash-project/ash/blob/v3.37.6/CHANGELOG.md).

AshPostgres 2.16.0 changes default-prefix handling for upserts/merges, identity-constraint error mapping, synthetic-create support, canonical snapshot hashing and migration rollback ordering for deferrable references/custom indexes. It requires Ash >= 3.37.6 and Ash SQL >= 0.8.9. These capabilities are not required merely to replace retired Ash SQL 0.8.4. No resource/migration/snapshot changes exist in PR #60, and `ash.codegen --check` passed in hosted `mix check`. That does not prove every migration downgrade path or future generator output. Existing runtime RLS, actor and tenant checks remain necessary defense in depth. See [2.16.0 changes](https://github.com/ash-project/ash_postgres/blob/v2.16.0/CHANGELOG.md).

Ash SQL 0.8.6 addresses the retired query-planning behavior; later candidate patches change aggregate/subquery/type handling. Ecto 3.14.3 repairs cache handling, including tenant-relevant query-prefix distinctions. The candidate keeps Ecto SQL 3.14.0, Postgrex 0.22.4, Decimal 3.2.0 and DBConnection 2.10.2. Metadata constraints admit this combination and exact-head CI exercised it. There is no DB engine/role/schema upgrade, no new migration, no changed RLS policy, and no data conversion. See [Ash SQL changes](https://github.com/ash-project/ash_sql/blob/v0.8.9/CHANGELOG.md) and [Ecto changes](https://github.com/elixir-ecto/ecto/blob/v3.14.3/CHANGELOG.md).

AshPhoenix 2.3.26 fixes deep nested-form handling and Elixir 1.20 warnings. Prior tenant propagation/security fixes were already in 2.3.25. Existing integration compatibility is evidenced by compilation/tests, but deep nested forms are not a current maintenance acceptance claim. Existing resource ownership stays in `Ticketing.Identity` and `Ticketing.Events`; `Ticketing.Events.create_event/2` retains one governed `Ash.transact` boundary, required actor/tenant context and one Event insert. No lifecycle transition is introduced.

### Runtime and HTTP

DNSCluster 0.3.1 changes discovery behavior, including `{basename, query}` hostname lookup. Ticketing starts it with configured query or `:ignore`; local/CI default startup does not prove real clustered DNS discovery, reconnect behavior or production query shape. Option A needs owner acceptance of that unexercised operational path or an authorized bounded smoke check. No production DNS operation was performed. See [DNSCluster 0.3.1](https://hexdocs.pm/dns_cluster/0.3.1/DNSCluster.html).

Bandit 1.15.0 fixes trailer logging but also changes HTTP/2 validation/CONNECT, WebSocket fragmentation limits, compression decisions, HEAD handling and connection hibernation. Plug, Thousand Island, HPAX, WebSock, Phoenix and LiveView stay at their existing locks. The candidate suite includes real HTTP and LiveView WebSocket smoke tests. Those do not exercise all changed HTTP/2 paths or reproduce the new logging advisory. Option A/B must explicitly record reliance on reviewed upstream regression evidence or authorize a bounded regression test; no unbounded exploit traffic is authorized.

Phoenix.HTML 4.4.0 validates attribute names and adds JSON-escape behavior. Invalid attribute keys may now fail where the prior release accepted them; that is security-relevant externally observable behavior. Tests/build passed; application-specific hostile-key regressions were not added. LiveDashboard 0.9.1 requires LiveView >= 1.0, satisfied by unchanged 1.2.13, and changes Ecto extras handling. Dashboard routes remain development-only; CI startup is not a human dashboard interaction check. These changes require explicit maintenance acceptance, not new authorization/product rules.

### Other transitive and build implications

Fine/LazyHTML change native test tooling and precompiled NIF selection; local acquisition and hosted compilation/tests passed on Linux. Other OS/architecture combinations were not tested. IDNA 7.1.0 changes domain-name handling for Swoosh; 8.0.0 is excluded by Swoosh's declared range. No outbound mail/provider delivery was tested. Finch's unchanged 0.24.0 lock admits the elective Nimble options/pool changes; deployment-specific HTTP pool behavior was not load-tested. Telemetry/metrics updates do not authorize new labels, payload logging or PII exposure.

Crux remains part of Ash's SAT dependency path; SimpleSat 0.1.4 remains the selected backend and PicoSAT is not introduced. The Crux patch does not authorize changing policy semantics. Splode 0.3.3 changes JSON error-variable decoding, so canonical error normalization and information hiding must remain fixed. WebSockAdapter 0.7.x changes adapter dispatch and adds an optional Roadrunner integration; no Roadrunner package is added or selected. Existing real Bandit/LiveView WebSocket tests cover the configured adapter, not every optional adapter.

Igniter, Spark, Sourceror, Spitfire, UsageRules and analyzer updates can change generators, compilation, task discovery and diagnostics. Only three managed task indexes changed; human-maintained skills and generated reference content remain outside this diff. UsageRules emits an optional ExDoc dependency type warning during dependency compilation; application warnings-as-errors and Dialyzer pass. Sobelow's configured Medium gate passes with six low-confidence findings in unchanged infrastructure code. No security gate or warning suppression was weakened.

The Tailwind Hex wrapper and binary are independent choices. The binary pin/URL/destination and test expectation consistently select 4.3.5. Its SHA-256 is `e47695cee3f0d90623a91f3939b08bdee610eb5ad99340adff9d4145b284d6cc`, matching the upstream release asset digest; download-failure/checksum tests and the assets build passed. No new composition or visual design was authored. No browser/visual Hallmark verification is claimed. If acceptance requires visual-regression evidence for this build-tool change, authorize that bounded check before accepting option A. See [Tailwind 4.3.5](https://github.com/tailwindlabs/tailwindcss/releases/tag/v4.3.5).

### Capability/reference and stack decisions

For option A, propose ADOPT the existing candidate Ash core/AshPostgres/Ash SQL/AshPhoenix mechanisms at the classified versions, without adding capability or changing ownership. For option B, propose DEFER the elective AshPostgres/AshPhoenix refresh and retain their accepted main versions. No bespoke mechanism is proposed. Signals, Temporal Resources, Ash Storage, AshStateMachine, AshAuthentication, history/archival and additional Reactor machinery are NOT_APPLICABLE to package remediation. AshOban/Oban adoption remains a separate TICK-65/PR #59 decision, not hidden maintenance work.

Store Blueprint accepted main was observed at `db291befdd22fdc2591bfd33cf4273e6a0510762`; classification NOT_APPLICABLE because this packet implements no commerce mechanism. LiveFrames accepted main was observed at `ed0f0e152828b931e85ab255b582485246065f7d`; classification NOT_APPLICABLE because no component, token, layout or design-conversion mechanism is created. No reference code is copied or imported.

Candidate Elixir 1.20.4 / OTP 29.1.2 pins are unchanged; official sources list [Elixir 1.20.5](https://elixir-lang.org/install/) and [OTP 29.1.2](https://www.erlang.org/downloads). Elixir patch maintenance is DEFERRED, not hidden here. Phoenix 1.8.16, LiveView 1.2.13, Postgrex 0.22.4, Req 0.7.5, Heroicons 2.2.0, esbuild binary 0.28.2 and pinned Python authority dependencies are unchanged. No RC is selected. Postgrex 1.0.0-rc.1 declares older DBConnection/Decimal requirements incompatible with the current Ecto stack; Req RC and Jason alpha are unnecessary for this repair.

Separate freshness discovery: [PostgreSQL 18.7, released 2026-11-12](https://www.postgresql.org/docs/release/18.7/), contains security fixes beyond the approved/tested 18.6 baseline, including RLS-policy modification and view/upsert visibility concerns. This is not evidence that Ticketing's specific paths are exploitable, nor that Hex audit covers the database engine. The control tower/DB owner must record applicability and a separately governed prerequisite or explicit deferral before claiming the entire stack safe. Do not change CI images, local clusters, role privileges, backups or database data here. Workstation DevCore remains externally owned; Redis remains N/A.

## 5. Alternatives, rollback and required acceptance

### A. Complete existing PR, conditional adoption

Owner explicitly approves the entire eight-file diff at `2fa4a87fe5ffb9cff595ab9a4e6b5113313cb966`, including all 31 versions, both lock cleanups, Tailwind binary and generated task indexes. Approval must name the elective AshPostgres, DNSCluster, Dashboard and tooling/runtime changes, and accept or require evidence for the bounded gaps in section 4. It does not assert those choices were previously authorized or retrospectively make TICK-67 READY.

This option preserves the tested candidate and minimizes further resolver churn. Its tradeoff is accepting materially broader behavior than the original three findings. Any extra regression code or package/base change requires separate authorization and fresh exact-head checks/review. Recommendation for control-tower review: evaluate A only if the owner intends to maintain the complete refreshed baseline and explicitly accepts its wider risk/evidence profile. Green CI alone is not the reason to choose A.

### B. Narrow security-only preparation, not yet a tested candidate

Proposed minimum starting set is Ecto 3.14.3, Phoenix.HTML 4.4.0, Ash SQL 0.8.6 and Bandit 1.15.0, subject to the new Bandit advisory reconciliation. Main Ash 3.37.2, AshPostgres 2.15.2 and Ecto SQL 3.14.0 admit that set in versioned release metadata: Ash SQL 0.8.6 accepts Ash `~> 3.34`; AshPostgres 2.15.2 accepts Ash SQL >= 0.8.4 and Ash >= 3.37.1; Ecto SQL accepts Ecto `~> 3.14.0`. This is a compatibility hypothesis, not a resolver/test result or an approved lockfile.

Retain the other 27 Hex locks, Tailwind binary 4.3.3, existing tools, and generated indexes unless the narrow resolver/generation proves a necessary change. Do not independently update AshPostgres to 2.16.0, DNSCluster or Dashboard. Owner authorizes narrowly scoped preparation only after the governing packet/Plane gate. Use a new dependency-clear implementation item rather than backdating TICK-67's readiness. Preserve PR #60's current head as comparison evidence; prepare the smaller candidate on a separate branch/PR unless the owner later explicitly authorizes rewriting #60. Its current green CI cannot certify that new candidate.

If only the original three findings are accepted for scope, record the newly discovered Bandit advisory as an unresolved security blocker with a separate disposition; do not label that result globally secure. No minimum-set resolution or application change was executed during this planning task.

### Rollback and deployment posture

Do not deploy or merge under this draft. There is no new data migration to reverse. A later authorized rollback must preserve Ecto >= 3.14.3, Phoenix.HTML >= 4.4.0, non-retired Ash SQL >= 0.8.6 and the independently accepted Bandit repair. Reverting blindly to current main would restore known findings. A rollback that lowers AshPostgres/Ash SQL must also revise their coupled Ash constraints, resolve a secure set and rerun checks; selective manual lock edits are not a rollback procedure.

No database reset, migration downgrade, container lifecycle operation or secret rotation is authorized. Existing tenant, action, uniqueness, transaction, error and event semantics are guards for any later implementation. Failed resolution, new generator drift, altered RLS/actor behavior, broader dependency movement or a new advisory stops that work and returns to the control tower.

## 6. Verification record and limits

Reverified [CI run 44027334325](https://github.com/Carpe-Diem-Media/ticketing/actions/runs/44027334325) for exact head `2fa4a87fe5ffb9cff595ab9a4e6b5113313cb966`: `bootstrap` SUCCESS at 05:58:11Z and `check_types` SUCCESS at 06:01:43Z on 2026-11-17. Hosted logs independently show 119 application tests, 26 partitioned PostgreSQL tests, and Dialyzer 0 errors/0 skipped warnings. `bootstrap` includes checksum acquisition, its failure tests, setup and `mix check`; that includes formatting, application compile, Ash codegen check, authority verification, tests, Credo, Sobelow and assets build. The unchanged candidate retains that evidence. These checks do not grant approval or prove the unexercised paths identified above.

Earlier author-side local `mix precommit`, `mix check`, `mix check.types`, locked fetch, clean Hex audit and 303 authority tests remain historical evidence reported in PR #60. The separate Authority workflow did not run for #60 because its path filter excludes this diff. This planning pass freshly reran authority tests: **303 passed**. It also freshly verified the manifest and CANON. It did not rerun application tests against the planning branch's old main dependencies or change the candidate merely to refresh timestamps.

The separate planning PR is based on unchanged main, whose old lock still has the TICK-67 findings. Its application audit can therefore fail on inherited dependencies. Keep that check visible and attributed to TICK-67; do not import #60's implementation into the planning branch, suppress the audit or present #60's green checks as planning-PR CI results. Planning-file validation and candidate verification are distinct evidence sets.

Reproduction commands used in this planning pass:

```sh
git ls-remote origin refs/heads/main refs/heads/chore/dependency-refresh-2026-11-17
gh pr view 60 --repo Carpe-Diem-Media/ticketing --json headRefOid,baseRefOid,state,files,reviews,statusCheckRollup
gh api repos/Carpe-Diem-Media/ticketing/pulls/60/reviews/5933916940
gh pr diff 60 --repo Carpe-Diem-Media/ticketing
git diff 937a811f6558dcebb8de430175e1e79f25f5ca19 2fa4a87fe5ffb9cff595ab9a4e6b5113313cb966
gh run view 44027334325 --repo Carpe-Diem-Media/ticketing --json headSha,conclusion,jobs,url
python authority/tools/contract_manifest.py verify --root authority
python authority/tools/generate_canon.py verify --root authority
cd authority
python -m pytest -q
```

Python commands use the existing temporary virtual environment with repository-pinned validation dependencies; they do not inject DB credentials. Future authorized database checks must first run `devcore-project doctor`, then use `devcore-project run test -- ...` with a unique `MIX_TEST_PARTITION`. Never target DEV or reset/drop a database without separate authorization.

After a scope choice and before any implementation merge, independently recheck main/base/head, entire diff, current advisories, exact-head CI, ticket dependencies, unresolved review comments and TICK-68 disposition. Any changed candidate needs full applicable local gates and fresh hosted tests/Dialyzer. No tests or evidence may be copied from A to B. No new regression implementation is authorized by this draft.

## 7. TICK-68 sanitized service-owner coordination

Known incident: a broad process-command diagnostic during dependency maintenance displayed Erlang runtime cookie values in a tool response. No values are included here. The reviewed eight-file patch contains no evident cookie value; that does not establish that diagnostic retention, local artifacts, viewers or other services are safe. Do not inspect or publish the crash dump, secret files, environment values, full process arguments, or raw diagnostic transcript to determine scope.

The supplied TICK-68 record has no named service owner/contact, environment classification, or project lead. Service identity, active/shared/production status, access audience, rotation authorization, replacement verification and prior-cookie invalidation remain **UNVERIFIED**. No owner acknowledgement, rotation, revocation or incident closure is claimed. Workstation stack visibility does not establish Ticketing ownership.

Coordination handoff for the control tower, using the connected Plane session:

1. Assign an authorized operational incident coordinator and identify responsible service owners through an approved private channel. Do not put cookie values into that channel or its ticket.
2. Have owners identify affected services, credential type, environment and exposure period from their own controlled inventory. Determine whether shared/production credentials or accessible distribution endpoints require prompt escalation.
3. Establish who could access the tool output and its retention/access controls without copying it into GitHub/Plane. Preserve any necessary evidence under the owners' incident process.
4. Obtain service-specific rotation/revocation and maintenance-window authorization. Only authorized owners should replace credentials, update approved secret storage, coordinate dependent nodes and verify connectivity plus old-value invalidation. Never request the old/new cookie value in chat.
5. Record sanitized owner acknowledgement, authorization, timestamps, replacement validation, invalidation result and residual exposure in TICK-68. Any containment/access restriction also needs authorized ownership.
6. Prevent recurrence by using allowlisted process fields such as PID, executable name and elapsed time. Do not emit command arguments, environment, distribution cookies or inspect secret-bearing dumps. The agent has stopped using argument-bearing process diagnostics; durable tooling/redaction changes require separately scoped owner approval.

This section is the coordination request, not proof coordination occurred. The user will reconcile TICK-68 after reviewing this packet. Its control-tower blocker remains until an authorized incident disposition is accepted; maintenance-scope approval cannot waive it silently.

## 8. Documentation, execution guards and owner questions

**Documentation Impact:** CREATE `planning/jips/JIP-T0-MAINT-01_v0.1.0.md` only. Do not update `ticketing/docs/` as though an unmerged dependency baseline were current. After any authorized implementation merge, a separately governed closeout should UPDATE `ticketing/docs/platform/runtime.md` and `ticketing/docs/platform/testing-and-quality-gates.md`, and CREATE `ticketing/docs/handoffs/JIP-T0-MAINT-01.md`, all against actual merged main. These are proposed follow-up paths, not current edits or approved work items.

Planning lifecycle: DRAFT remains non-executable while scope, incident and evidence decisions are open. Only explicit owner acceptance after independent control-tower review can make the selected packet APPROVED. A relevant authority/base/head/scope/advisory change makes its evidence stale. The control tower reconciles native dependencies and selects any future genuinely dependency-clear work. Do not retrospectively promote already-performed work to READY. No TICK-67 or TICK-68 closure follows from this document.

Required owner questions, after control-tower challenge of this draft:

1. **Scope:** approve A's entire existing diff at `2fa4a87fe5ffb9cff595ab9a4e6b5113313cb966`, including the elective choices and section 4 evidence limits, or authorize B's narrow preparation under a separate governed execution item? If B, preserve #60 unchanged and prepare a separate candidate unless explicitly directed otherwise. Neither answer authorizes merge.
2. **Security/evidence disposition:** include the newly discovered Bandit advisory in TICK-67 and require independent confirmation of the tagged fix despite stale advisory metadata? For A, accept the stated DNS/deep-form/migration-downgrade/visual evidence limits, or specify bounded checks before final approval? Recommendation: include Bandit, require source/regression review, and do not claim untested production paths verified.
3. **Operational gate:** who is authorized to coordinate TICK-68 and contact the service owners? What sanitized owner-confirmed incident disposition must the control tower accept before it clears review blocker 2? No rotation is requested until those owners authorize it.
4. **Separate freshness discovery:** route PostgreSQL 18.7 applicability/security triage to the DB owner as a separately governed prerequisite or explicit deferral. This does not authorize infrastructure changes or widen #60. Any later maintenance merge also requires targeted TICK-65/JIP-T0-02A and PR #59 freshness review before progression.

Definition of Done for this planning task is an auditable DRAFT, complete classification and risk/alternative evidence, an isolated planning PR, preserved #60 head/CI, and an explicit owner/control-tower handoff. It does not mean the governance gap or incident is resolved. Maintenance acceptance, live Plane reconciliation, incident disposition, final fresh exact-diff/CI PASS and explicit user merge authorization remain separate gates.
