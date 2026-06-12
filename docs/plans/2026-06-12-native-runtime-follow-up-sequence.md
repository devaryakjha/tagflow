# Native Runtime Follow-up Sequence

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Baseline commit: `9491aa5 docs(benchmarks): document profile dpr qualification`
- Latest coordinator evidence refresh:
  `0203f66 docs(benchmarks): record ios simulator smoke`
- Scope: coordinator sequencing after native-runtime API, adapter metadata,
  equivalent fixture, and DPR feasibility work

This note is the current coordinator sequence. It does not authorize publishing,
tagging, package-version changes, beta wording, benchmark claims, or broad
runtime expansion.

Current local gate evidence after the README, `tagflow_table` docs cleanup, and
simulator smoke refresh:

- `PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate`
  passed on the coordinator branch at `b9a8906`.
- `PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run publish:dry-run`
  exited 0 and reported no unpublished packages, so no publishable package
  payload changed after the docs-only cleanup.
- GitHub Actions `CI / Validate` passed on PR #72 at head `0203f66`.
- iOS Simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442` passed the native JSON
  debug route smoke for `tagflow_native_json:native_ai_answer`.
- `benchmark:profile:baselines` on that same Simulator failed before launch
  because Flutter rejects iOS Simulator profile/release builds.
- The worktree still has unrelated local `.vscode/settings.json` and `.codex/`
  changes that are not part of this coordinator sequence.

External gate trackers:

- Real-app route evidence is tracked in
  https://github.com/devaryakjha/tagflow/issues/73.
  Qualification rules and candidate-route stop rules are recorded in
  `docs/plans/2026-06-12-real-app-route-qualification.md`.
- Qualified benchmark/device evidence is tracked in
  https://github.com/devaryakjha/tagflow/issues/74.
  The PR #72 benchmark gate is satisfied by the accepted synthetic
  report-only path recorded in
  `docs/benchmarks/2026-06-12-benchmark-gate-decision.md`; physical,
  observed-host, memory, frame-budget, beta/stable, and comparative
  performance gates remain separate future work.

## Current Read

The native runtime direction is structurally in place:

- `TagflowDocument` is the canonical runtime input.
- `Tagflow.document(...)` and `Tagflow.html(...)` both route through the
  semantic runtime unless legacy custom converters are explicitly supplied.
- Native block JSON document and patch transport are strict and data-only.
- View-owned node taps and adapter metadata inspectors exist.
- The first equivalent HTML/native fixture family has repeat-5 local evidence.

The remaining blocking evidence gap is now the real-app route gate:

- Kite production-route evidence still depends on Kite GitLab/DNS or an
  approved equivalent real Flutter app route. A local Kite supporting branch
  exists at `codex/tagflow-ipo-native-route` with commits `355c79d6`,
  `e9a86803`, and `50bee7ce`. The latest local simulator smoke opens the real
  Bids -> IPO -> AFCONS -> `IPOInstrumentSheet` path against Kite's debug
  `main_local.dart` fixture and captures visible Tagflow-rendered IPO tables,
  with hosted `tagflow 1.0.0-alpha.3` and `tagflow_table 1.0.0-alpha.1`
  resolved from pub.dev. It is still not pushed/reviewable through Kite's
  intended source-control path and uses local fixture/auth constraints, so it
  does not close #73;
- the PR #72 benchmark gate is satisfied by synthetic report-only evidence,
  while physical-device, observed-host, frame-budget, memory, beta/stable, and
  comparative performance evidence remain future benchmark work;
- Simulator evidence remains useful only as debug route smoke unless Flutter
  tooling proves profile-mode support for the selected simulator/runtime.

## Next Slices

### 1. Reconcile Stale Planning Docs With Landed Runtime Surface

Type: example/docs slice
Status: completed in `fb9e20e docs(specs): reconcile native runtime current state`
Recommended first: completed

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
Status: completed in `246e33a docs(specs): decide patch result semantics`

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
Status: no-change; current example and tests already cover the reference path

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
Status: local Kite production-file migration and production-sheet widget
evidence prepared; local debug simulator route smoke captured; still blocked
by source-control/review and approved real app-route evidence for Kite;
replaceable by an approved equivalent real Flutter app route

The beta-readiness docs already identify Kite as the live-app evidence path.
Widget-test evidence exists, and a local Kite branch now migrates the IPO
production sheet file to `Tagflow.html(..., registry: ...)` with a
production-sheet harness that pumps `IPOInstrumentSheet` using real IPO fixture
content. A local `main_local.dart` fixture now also supports a simulator smoke
through Bids -> IPO -> AFCONS -> `IPOInstrumentSheet`, including the
Tagflow-rendered table section, while the app resolves hosted alpha packages.
Push/merge and approved real app-route evidence are still not complete.

The current route qualification plan is
`docs/plans/2026-06-12-real-app-route-qualification.md`.
The local non-closing Kite evidence note is
`docs/validation/evidence/2026-06-12-kite-ipo-native-route-local.md`.

Blocked until:

- `gitlab.zerodha.tech` DNS/access works for the Kite repo, or an approved
  equivalent real app route is available.

Acceptance after unblock:

- branch with `Tagflow.html(..., registry: ...)` production route is pushed or
  merged;
- route opens through the intended app path with real fixture/data constraints;
- any profile evidence stays separate from widget-test evidence.

### 5. Keep Physical/Observed-host Profile Evidence Separate

Type: benchmark/device/reference-target slice
Status: PR #72 benchmark gate satisfied by synthetic report-only evidence;
physical and observed-host qualification remain future work

#74 is satisfied for PR #72 by the accepted synthetic viewport path. That
evidence proves internal harness stability only. It does not qualify this Mac
as a real `2.0x` reference target, does not qualify a physical iOS/Android
target, and does not support public benchmark, frame-budget, memory, beta,
stable, or comparative performance claims.

The equivalent answer-detail repeat-5 synthetic run is useful local evidence
for PR #72, but repeating the observed-host command on the current `1.0x`
display is still not expected to satisfy the `2.0x` observed-host policy.

Future physical/observed-host work is blocked until one of these is true:

- a reviewed macOS target produces the expected observed `800x600 @ 2.0x`
  metadata; or
- a physical iOS/Android profile target is connected, signed, installed, and
  qualified.

Acceptance after unblock:

- repeat-5 collection completes for the equivalent fixture family;
- policy check passes or any failure is documented as a blocker;
- raw artifacts remain under ignored `build/benchmarks/`;
- tracked notes remain report-only and avoid faster/slower or memory claims.

## Coordinator Recommendation

Slices 1 and 2 are complete. Slice 3 is currently a no-change reference-path
confirmation because `examples/tagflow/lib/screens/native_json_example.dart`
and `examples/tagflow/test/native_json_example_test.dart` already cover document
decode/render, patch envelope apply, revision updates, removal/reset behavior,
and public metadata helper tap summaries.

Do not start another repeat-5 profile rerun until the target qualification
blocker changes, unless a future PR explicitly targets a different benchmark
policy. The next useful physical/observed-host benchmark move is first
qualifying a connected physical iOS target across Flutter and Apple tooling,
then fixing signing for `dev.aryak.tagflow` if that remains the blocker; or
attaching a real Android profile target. Rerun the same one-repeat native JSON
pair before collecting any larger physical/observed-host baseline. The current
Simulator route smoke is useful for app-path confidence but cannot replace that
physical/profile qualification gate.
