# JIP-T0-02A v0.2.0 recovery record

Status: source text recovered; original approval evidence recovered by the control tower; immutable acceptance-to-attachment-hash linkage unverified.
Task: TICK-65, planning/document recovery only.
Original recovery baseline: `937a811f6558dcebb8de430175e1e79f25f5ca19`.
Targeted refresh baseline, 2026-11-17: `62bce2950229208d25817ac48e3c005146830fb4`.

## Recovered source

`JIP-T0-02A_v0.2.0.md` preserves the complete attached document as captured by the original command output. No requirements, status text, punctuation or whitespace were rewritten. Its retained `DRAFT` status is part of the source, not a new decision about approval.

- UTF-8 size: 35,704 bytes.
- SHA-256: `aa4ce2afdc931b37aa03fef75115ab5b2a1d4b0d5a626c1ab72cc1717e9833b9`.
- Original attachment name: `pasted-text.txt`.
- Original attachment reference: `file_ebd3caca-63c8-4afb-8325-a2d3158604e5`.
- Original attachment ID: `65f9bd82-1216-47db-9088-9a40f20e7e49-893c6038-d0d1-4058-8e3b-0cf0c465269f-txt`.
- Original path, currently missing: `/home/jcschoeman96/.t3/userdata/attachments/65f9bd82-1216-47db-9088-9a40f20e7e49-893c6038-d0d1-4058-8e3b-0cf0c465269f-txt.txt`.
- Recovery source: `/home/jcschoeman96/.codex/sessions/2026/10/30/rollout-2026-10-30T13-53-34-01a18ca8-7a2d-7c51-9424-73143f1196b2.jsonl.zst`.
- Source record: decompressed JSONL line 29, command-execution event at `2026-10-30T11:53:55.652Z`, command ID `exec-e77ab72b-3ff7-43a0-8742-27b15bdea7a3`.

The command concatenated the Unslop skill and the attachment. Recovery removed the exact skill-file prefix from the untruncated `aggregated_output`. The remaining bytes match the attachment's recorded `sizeBytes = 35704`. The user-message attachment metadata is at decompressed line 14. The recovery does not use a model-generated reconstruction or combine earlier drafts. The original upload is missing, so an independent comparison with its original hash is unavailable.

## Approval evidence and limit

The independent control tower recovered original approval evidence from the Ticketing account conversation context. Its [formal PR #59 review](https://github.com/Carpe-Diem-Media/ticketing/pull/59#pullrequestreview-5933424581), submitted on 2026-11-17 against head `dedacf525f86771dcde9d8652e5b8beef35ef48b`, and TICK-65 comment `27f4c2c2-c794-453c-822e-6b052f1bc43b` record this timeline on 2026-10-30, all against `main@937a811f6558dcebb8de430175e1e79f25f5ca19`:

- 11:43:58 UTC: the assistant identified the approval candidate as JIP-T0-02A v0.2.0.
- 11:53:55 UTC: the recovered attachment-source command event occurred, with the precise log timestamp `2026-10-30T11:53:55.652Z`.
- 12:01:38 UTC: the original user response was `accepted`.
- 12:07:23 UTC: the assistant recorded `JIP-T0-02A v0.2.0 is now APPROVED`.

This is strong version/title/timeline evidence of original user approval, beyond the tracker summary. The attachment-source event precedes acceptance and follows identification of the candidate. The narrower attachment-reading session ends awaiting approval; that local session's lack of a later acceptance does not negate the approval recovered from the account conversation context. The correction relies on the control tower's cited evidence; this recovery agent has not independently accessed that underlying account conversation.

The remaining limit is exact-byte linkage. No immutable record binding the acceptance to the recovered attachment's SHA-256 was available in that conversation context. Matching version, title and chronology do not prove that hash binding. The recovered file's byte count and digest remain verified independently, and its original DRAFT text remains unchanged. This correction records existing approval; it neither requests semantic reapproval nor claims a new approval. If the control tower requires further source-identity evidence before SPEC derivation, owner confirmation should identify the recovered digest, rather than reapprove the JIP's semantics. The current task authorizes no SPEC derivation or downstream progression.

## Installed OBQC comparison

The comparison uses installed `authority/contracts/OBQC-1/extracted/OBQC-1_Contract_v2.2.0.json`, SHA-256 `5875ceb178aa543dfc187ccc7d69513fb98620c1975dbecf7a00afcab6cf0a6e`.

No material contradiction was found in the reviewed job-envelope and tenant-execution requirements:

- JIP sections 3, 6, 13 and 14 prohibit tenant-wide scheduling and tenantless scheduled-action fan-out/fallback. Section 14 requires `scheduler_cron false` and direct tenant-bound trigger insertion. These match OBQC's `tenant_scoped_resource_policy` and ASHOBAN tenant-bound execution rule.
- Sections 13 and 14 require the framework tenant and matching `ticketing_payload.args.org_id` before governed Ash access, with `actor_persister :none`.
- Section 14 places Ticketing input at `action_arguments.ticketing_payload` and requires current/previous semantic-version compatibility and unknown-version rejection. OBQC still controls the exact `{version, args}` shape, certified outer-key allowlist, previous-deployed-source fixtures and first-deployment evidence. The packet does not replace those requirements.
- Sections 14 and 22 retain the complete-args size cap, stable worker/scheduler names, capability checks, explicit recovery backoff and required database index verification.
- Section 14's retry delays match OBQC's recovery profile: 15, 30, 60, 300, 900 and 3600 seconds with jitter.

This is a document comparison, not proof of framework integration or application correctness. No dependencies, runtime code, migrations or production mappings changed. Technical/reference release freshness must be checked before resumed derivation; the recovered historical version decisions were not rewritten.

## Verification and next gate

Recovery checks confirmed exact equality between the preserved file and the extracted source bytes, the recorded byte count and SHA-256, and all 26 numbered sections plus the approval boundary.

The original `git diff --cached --check` reported 11 trailing-whitespace findings at packet lines 3, 4, 5, 6, 7, 385, 386, 387, 539, 642 and 643. Each is an original two-space Markdown hard break. They remain unchanged for byte fidelity. The formal review accepts their treatment as a documented preservation exception. A full PR whitespace check still reports them; it must not be described as passing. No Git whitespace rule was weakened.

Historical CI run `44023186299` on reviewed head `dedacf525f86771dcde9d8652e5b8beef35ef48b` passed `check_types` but failed `bootstrap` at `mix check`. The review records security-audit failures for retired `ash_sql 0.8.4`, `phoenix_html 4.3.0` advisory `EEF-CVE-2026-117645`, and `ecto 3.14.2` advisory `EEF-CVE-2026-118391` / `GHSA-cxjx-vmm2-qr8r`. The subsequent run `44025302809` on `1b7e26fcef0a95a558ae00cc443393d9d55438ad` also failed bootstrap and passed check_types. Those failures remain historical evidence, not a diagnosis of the refreshed dependency baseline.

## Targeted refresh after merged maintenance

PR #60 merged dependency maintenance at `e6456d7148fa10d7ca239cdc9f4e241f9ccde4db`; PR #61 merged the approved Option A maintenance JIP at `62bce2950229208d25817ac48e3c005146830fb4`. GitHub reports the current main signature verified. Its own post-merge CI run `44043426567` completed successfully. This does not replace fresh checks or review on PR #59's updated head.

The original JIP remains byte-for-byte preserved, including its DRAFT text and 11 hard breaks. Its Ash 3.37.2 / AshPostgres 2.15.2 technical baseline is stale for current execution. The accompanying `JIP-T0-02A_v0.2.1.md` is a DRAFT technical-baseline amendment for independent review and explicit owner acceptance. It records merged Ash 3.37.6, AshPostgres 2.16.0, Ash SQL 0.8.9, Ecto 3.14.3 and Phoenix.HTML 4.4.0, rechecks AshOban/Oban compatibility, and preserves the original product/domain requirements. It does not modify or retroactively reapprove v0.2.0.

Installed CANON-1 2.0.20, OBQC-1 2.2.0, the entire authority tree, root governance, ROADMAP, tracer, domain source, migrations and snapshots are unchanged since the original baseline. The source approval evidence and immutable attachment-hash linkage limit above remain effective. Neither a maintenance merge nor the amendment creates the missing hash binding.

TICK-67 still has live Plane state Planning and a native blocked_by relation from TICK-65. Its latest control-tower comment records both maintenance merges. Record merged remediation as observed; leave closeout, blocker disposition and readiness to the control tower. TICK-68 incident disposition and TICK-69 PostgreSQL 18.7 security applicability remain separately unresolved. No operational secret, database or infrastructure action is authorized here.

Targeted local verification on 2026-11-17:

- `PYTHONPATH=authority /tmp/tick65-authority-venv/bin/python -m pytest -q authority/tests`: 303 passed in 20.13 seconds.
- `python3 authority/tools/contract_manifest.py verify --root authority`: VALID, 58 contracts, unchanged manifest SHA-256.
- `/tmp/tick65-authority-venv/bin/python authority/tools/generate_canon.py verify --root authority`: VALID, CANON-1 2.0.20, 56 pins.
- `/tmp/tick65-authority-venv/bin/python authority/tools/reconcile_contracts.py audit --canonical --strict --root authority --json-output /tmp/tick65-refresh-audit.json --markdown-output /tmp/tick65-refresh-audit.md`: PASS, 58 ZIPs and 729 dependency edges.
- Source-checksum and normalized section comparisons pass: v0.2.0 unchanged; v0.2.1 sections 5–26 preserve requirements apart from version references and Markdown spacing. The new draft and recovery-record correction introduce no whitespace findings; the full PR retains only the original 11 disclosed source findings.

Keep PR #59 open and draft for fresh independent review of the updated head and amendment. Preserve the source-identity caveat, obtain the required amendment acceptance and reconcile current CI/Plane gates before downstream progression. This refresh grants no SPEC derivation, ticket decomposition, READY transition, product implementation or merge authorization.

## 2026-11-17 owner disposition of recovered reference

Following independent control-tower review `5935091166`, the owner explicitly accepted **JIP-T0-02A v0.2.1** and accepted the preserved v0.2.0 source SHA-256 `aa4ce2afdc931b37aa03fef75115ab5b2a1d4b0d5a626c1ab72cc1717e9833b9` **as the recovery reference**. This is a present-day acceptance of the recovered artifact identity for continuity, **not** proof that the original 2026-10-30 acceptance was immutably bound to this digest. The historical limitation, source bytes and timeline above remain unchanged.

The owner separately authorized merging PR #59 **after final exact-head CI and independent review**. The previously stated DRAFT/merge restrictions describe the pre-approval state and are superseded only as to owner approval and conditional merge authorization. Implementation READY, specification/ticket decomposition and downstream execution remain subject to merged-main and Plane gates. This decision does not authorize credential or database operations, resolve TICK-68/TICK-69, or modify the recovered v0.2.0 source.
