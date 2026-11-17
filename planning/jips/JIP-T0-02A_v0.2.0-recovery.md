# JIP-T0-02A v0.2.0 recovery record

Status: source text recovered; original acceptance message not recovered.
Task: TICK-65, planning/document recovery only.
Verified main: `937a811f6558dcebb8de430175e1e79f25f5ca19`.

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

TICK-65's live description records explicit user acceptance on 2026-10-30. Control-tower comment `703e95a5-73b3-4238-abe5-400d521cf1cd` reiterates that approval record on 2026-11-17. The current owner recovery instruction also identifies v0.2.0 as approved.

The recovered session's final assistant response says that the attachment is a draft and asks whether to review or approve it. That session contains no subsequent user acceptance. No original acceptance message or immutable approval-to-document hash binding was recovered. The available earlier planning thread contains rejected drafts and PR #58 authority-repair evidence; neither substitutes for this packet or its acceptance.

This recovery therefore proves the full v0.2.0 source text, while approval identity remains supported by the tracker and current owner instruction rather than the original acceptance message. Do not claim that original message was verified. SPEC derivation remains blocked pending owner/control-tower confirmation that this exact recovered digest is the accepted packet, or recovery of the original acceptance record tied to this text. No new semantic approval is inferred from this PR.

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

`git diff --cached --check` reports 11 trailing-whitespace findings at packet lines 3, 4, 5, 6, 7, 385, 386, 387, 539, 642 and 643. Each is an original two-space Markdown hard break. They are retained to preserve the source bytes. This is a disclosed check failure requiring reviewer acceptance of source preservation, not a passing whitespace check. No Git whitespace rule was weakened.

Review the exact recovery PR and evidence. Confirm the accepted packet's identity before deriving SPEC-T0-02A. This PR grants no implementation readiness, ticket decomposition or merge authorization.
