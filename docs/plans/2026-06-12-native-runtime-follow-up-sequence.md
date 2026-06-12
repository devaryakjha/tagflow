# Native Runtime Follow-up Sequence

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Baseline commit: `9491aa5 docs(benchmarks): document profile dpr qualification`
- Scope: coordinator sequencing after native-runtime API, adapter metadata,
  equivalent fixture, and DPR feasibility work

This note is the current coordinator sequence. It does not authorize publishing,
tagging, package-version changes, beta wording, benchmark claims, or broad
runtime expansion.

## Current Read

The native runtime direction is structurally in place:

- `TagflowDocument` is the canonical runtime input.
- `Tagflow.document(...)` and `Tagflow.html(...)` both route through the
  semantic runtime unless legacy custom converters are explicitly supplied.
- Native block JSON document and patch transport are strict and data-only.
- View-owned node taps and adapter metadata inspectors exist.
- The first equivalent HTML/native fixture family has repeat-5 local evidence.

The blocking evidence gaps are now mostly external-state or qualification
gates:

- the local equivalent profile run completed but failed the `2.0x` viewport
  policy on this `1.0x` display;
- a silent DPR override would change benchmark semantics, so the profile lane
  must wait for a reviewed target or an explicit synthetic-viewport design;
- Kite production-route evidence still depends on GitLab/DNS or route access;
- physical-device profile evidence still depends on a normal connected iOS or
  Android target.

## Next Slices

### 1. Reconcile Stale Planning Docs With Landed Runtime Surface

Type: example/docs slice
Status: unblocked
Recommended first: yes

Some planning docs still describe work as planned even though it has landed.
The most visible drift is the adapter metadata inspection SPEC, which still
uses proposed language for public helpers that are now implemented, exported,
tested, and used by the native JSON example.

Scope:

- update stale SPEC sections that still say implemented APIs are proposed;
- keep historical context where useful, but mark current implementation status;
- do not change package metadata or runtime code;
- keep benchmark wording report-only.

Acceptance:

- docs identify adapter metadata inspectors, node taps, strict native transport,
  and equivalent fixture evidence as current-state work where applicable;
- docs still distinguish future real-app and benchmark evidence blockers;
- `git diff --check` passes.

### 2. Audit Dynamic Patch Result Semantics Before Adding More APIs

Type: package runtime/API code slice
Status: unblocked for audit; code change requires a narrow SPEC decision

`docs/specs/2026-06-11-dynamic-document-updates.md` still leaves open whether
patch application should expose a `TagflowDocumentPatchResult` with changed
IDs, warnings, or applied-operation metadata. This is a beta-shape decision
because it affects how apps observe streaming or AI-authored updates.

Scope:

- audit current `TagflowDocumentPatch` and `applyPatches(...)` call sites;
- decide whether result metadata is needed before beta or should remain
  deferred;
- if implemented, add a focused additive API with tests and no controller or
  sync policy;
- keep revision conflict handling app-owned.

Acceptance:

- the decision is recorded in the dynamic update SPEC or a focused follow-up;
- if code lands, package tests cover replace, append, insert-before, remove,
  duplicate-ID rejection, and result metadata;
- no app router, CMS protocol, or patch queue is introduced.

### 3. Harden The Native JSON Example As The App-Integration Reference

Type: example/docs slice
Status: unblocked

The example app should demonstrate the intended app boundary: native JSON is
data-only, patch revision/conflict handling is app-owned, and routing actions
read adapter metadata through public helpers.

Scope:

- make the native JSON example the canonical demo for document decode, patch
  decode, patch apply, node tap routing, and metadata inspection;
- avoid production-app assumptions;
- keep routing behavior local to the example screen.

Acceptance:

- focused example tests prove the displayed content updates through native
  patches and tap summaries use public metadata helpers;
- package docs link to or describe the example without performance claims;
- `PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter test` passes for touched
  example tests.

### 4. Land Real-App Route Evidence When External Access Is Available

Type: real-app evidence slice
Status: blocked by external state

The beta-readiness docs already identify Kite as the live-app evidence path.
Widget-test evidence exists, but production-route push/merge/profile evidence
is still not complete.

Blocked until:

- `gitlab.zerodha.tech` DNS/access works for the Kite repo, or an approved
  equivalent real app route is available.

Acceptance after unblock:

- branch with `Tagflow.html(..., registry: ...)` production route is pushed or
  merged;
- route opens through the intended app path with real fixture/data constraints;
- any profile evidence stays separate from widget-test evidence.

### 5. Refresh Equivalent Profile Evidence Only On A Qualified Target

Type: benchmark/device/reference-target slice
Status: blocked by target qualification

The equivalent answer-detail repeat-5 run is useful local evidence, but it is
not claim-ready. Repeating the same command on the current `1.0x` display is
not expected to satisfy the current `2.0x` policy.

Blocked until one of these is true:

- a reviewed macOS target produces the expected observed `800x600 @ 2.0x`
  metadata; or
- a physical iOS/Android profile target is connected and qualified; or
- a synthetic viewport mode is explicitly designed with separate requested and
  observed viewport metadata.

Acceptance after unblock:

- repeat-5 collection completes for the equivalent fixture family;
- policy check passes or any failure is documented as a blocker;
- raw artifacts remain under ignored `build/benchmarks/`;
- tracked notes remain report-only and avoid faster/slower or memory claims.

## Coordinator Recommendation

Execute Slice 1 first. It is unblocked, prevents stale plans from sending future
workers into already-landed work, and keeps the release/API review aligned with
the actual package surface.

After Slice 1, delegate Slice 2 as the next package-runtime decision. Do not
start another profile rerun until the target qualification blocker changes.
