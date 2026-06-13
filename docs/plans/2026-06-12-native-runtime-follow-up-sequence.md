# Native Runtime Follow-up Sequence

## Status

- Date: 2026-06-12
- Branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Recorded CI-validated PR anchor:
  `01149ac test(gates): pin current native runtime evidence`
- Recorded anchored coordinator evidence:
  `01149ac test(gates): pin current native runtime evidence`, after target
  availability refresh in `83ec72d`, native-block example semantics in
  `a1ecfdd`, HTML and document semantics activation in `79d859d` and
  `0035b58`, example validation in `f4df58f`, native JSON route coverage in
  `f6ce373`, node-tap semantics in `f044844`, and gate-tooling updates in
  `8897929` and `b4ff260`
- Scope: coordinator sequencing after native-runtime API, adapter metadata,
  equivalent fixture, and DPR feasibility work

This note records coordinator sequencing history plus the current handoff
checks. Use `docs/plans/native-runtime-gate-status.json`, PR #72 hosted checks,
and live tracker state for the current branch-head readiness decision. It does
not authorize publishing, tagging, package-version changes, beta wording,
benchmark claims, or broad runtime expansion.

Current anchored gate evidence:

- `PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate`
  passed locally for the PR #72 branch; hosted `CI / Validate` passed for
  `01149ac`.
- `PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run publish:dry-run`
  previously exited 0 at `94008de` and reported no unpublished packages; later
  work added benchmark-only target-audit tooling and docs, not a package
  release payload.
- GitHub Actions `CI / Validate` passed on PR #72 for `01149ac` in run
  `27436534000`.
- Use PR #72 checks, not this historical anchor, for the current branch-head
  validation state.
- iOS Simulator `3BA9E377-4B6F-49A7-83FA-F640060D6442` passed the native JSON
  debug route smoke for `tagflow_native_json:native_ai_answer`.
- `benchmark:profile:baselines` on that same Simulator failed before launch
  because Flutter rejects iOS Simulator profile/release builds.
- The latest target-audit refresh returned
  `canRunPhysicalProfileProbe=false` for run
  `2026-06-13-current-machine-r1`: one iOS Simulator signal, two wireless iOS
  signals, no connected physical iOS target in Flutter, no xctrace-online
  physical iOS target, seven xctrace-offline physical iOS targets, two
  CoreDevice available-paired summary signals, seven CoreDevice blocking ids,
  and no attached Android device. Raw JSON remains under ignored
  `build/benchmarks/target-availability/`.
- The worktree still has unrelated local `.vscode/settings.json` and `.codex/`
  changes that are not part of this coordinator sequence.
- `packages/tagflow_benchmarks/test/native_runtime_gate_status_test.dart` keeps
  gate-manifest regressions around #73/#75 evidence, including stale-open
  expectation checks now that both trackers are closed.

External gate trackers:

- Real-app route evidence was tracked in
  https://github.com/devaryakjha/tagflow/issues/73, now closed via the public
  package-owned reference app route.
  Qualification rules and candidate-route stop rules are recorded in
  `docs/plans/2026-06-12-real-app-route-qualification.md`.
- The PR #72 synthetic benchmark decision is recorded in
  https://github.com/devaryakjha/tagflow/issues/74.
  The PR #72 benchmark gate is satisfied by the accepted synthetic
  report-only path recorded in
  `docs/benchmarks/2026-06-12-benchmark-gate-decision.md`; #74 is closed for
  that scoped decision. The #75 `physical-observed-profile` tracker is now
  closed by the iPhone 17 repeat-5 Xcode Time Profiler evidence, and public
  frame-budget, beta/stable, comparative performance, or package-page benchmark
  claims remain out of scope unless a future reviewed policy explicitly
  authorizes them.
- Machine-readable coordinator status is tracked in
  `docs/plans/native-runtime-gate-status.json`. The default
  `gate:native-runtime` Melos script checks the `pr72-draft` profile; set
  `TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=pr72-ready` to prove the stricter
  ready-to-undraft gate.

## Current Read

The native runtime direction is structurally in place:

- `TagflowDocument` is the canonical runtime input.
- `Tagflow.document(...)` and `Tagflow.html(...)` both route through the
  semantic runtime unless legacy custom converters are explicitly supplied.
- Native block JSON document and patch transport are strict and data-only.
- View-owned node taps, first button-like semantics for opted-in non-link tap
  targets, semantics-action activation coverage for document and HTML-adapted
  nodes, example-app native-block tap coverage, and adapter metadata
  inspectors exist.
- The first equivalent HTML/native fixture family has repeat-5 local evidence.

No non-owner beta-preapproval evidence gaps remain in the gate manifest:

- #73 is closed by the public package-owned reference app route recorded in
  `docs/validation/evidence/2026-06-13-reference-app-route.md`.
- #75 is closed by the iPhone 17 repeat-5 Xcode Time Profiler evidence recorded
  in
  `docs/benchmarks/baselines/2026-06-13-iphone17-time-profiler-repeat5.md`.
- The PR #72 benchmark gate is satisfied by synthetic report-only evidence, and
  memory-allocation review is satisfied as local report-only evidence.
- Release approval remains deferred. Do not interpret satisfied evidence gates
  as beta/stable release approval, package publishing approval, frame-budget
  approval, public benchmark approval, or comparative performance approval.

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
physical and observed-host qualification remain future work; latest target
audit still found no credible physical profile target

Tracker: https://github.com/devaryakjha/tagflow/issues/75

#74 is satisfied for PR #72 by the accepted synthetic viewport path. That
evidence proves internal harness stability only. It does not qualify this Mac
as a real `2.0x` reference target, does not qualify a physical iOS/Android
target, and does not support public benchmark, frame-budget, memory, beta,
stable, or comparative performance claims.

The equivalent answer-detail repeat-5 synthetic run is useful local evidence
for PR #72, but repeating the observed-host command on the current `1.0x`
display is still not expected to satisfy the `2.0x` observed-host policy.

The latest target-availability refresh is
`docs/benchmarks/baselines/2026-06-13-target-availability-refresh.md`. It found
no credible physical profile target: one iOS Simulator signal, two wireless
iOS signals, zero connected physical iOS devices in Flutter, zero
xctrace-online physical iOS devices, seven xctrace-offline physical iOS
devices, two CoreDevice available-paired summary signals, seven CoreDevice
blocking ids, and zero ADB-attached Android devices.

The repeatable target-audit preflight is now documented in
`docs/benchmarks/baselines/2026-06-12-target-availability-audit-tooling.md`.
Its current machine run
`2026-06-13-current-machine-r1` wrote ignored raw JSON under
`build/benchmarks/target-availability/` and returned
`canRunPhysicalProfileProbe=false`.

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

The current alpha.4 / pre-beta coordination cutline is
`docs/plans/2026-06-12-alpha4-prebeta-coordination.md`.

Slices 1 and 2 are complete. Slice 3 is now a coverage-only reference-path
confirmation: `examples/tagflow/lib/screens/native_json_example.dart`,
`examples/tagflow/test/native_json_example_test.dart`, and
`examples/tagflow/test/native_json_route_test.dart` cover document
decode/render, patch envelope apply, revision updates, removal/reset behavior,
public metadata helper tap summaries, and home-route navigation into the native
JSON screen. The root `melos run test` and `melos run coverage` scripts now
include `tagflow_example`, so that route/example coverage is part of the normal
workspace test lane. The node-tap follow-up now also has focused package
coverage for button-like semantics and semantics-action activation on opted-in
non-link document and HTML-adapted tap targets, plus example-app coverage for
semantics activation on app-authored native blocks.

The current beta-preapproval health check is the gate profile itself:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-preapproval \
  dart run melos run gate:native-runtime
```

It can pass because `real-app-route`, `physical-observed-profile`, and
`memory-allocation-review` are now satisfied. Do not reinterpret that pass as
beta approval, package publishing approval, or public performance-claim
approval; `release-approval` remains the owner approval gate.

Do not start another repeat-5 profile rerun unless a future PR explicitly
targets a different benchmark policy. The current physical profile evidence is
the iPhone 17 Xcode Time Profiler repeat-5 run recorded in
`docs/benchmarks/baselines/2026-06-13-iphone17-time-profiler-repeat5.md`.
