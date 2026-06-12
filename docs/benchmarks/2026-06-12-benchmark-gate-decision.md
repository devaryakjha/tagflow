# Benchmark Gate Decision For PR #72

## Status

- Date: 2026-06-12 Asia/Kolkata
- Related PR: https://github.com/devaryakjha/tagflow/pull/72
- Related gate: https://github.com/devaryakjha/tagflow/issues/74
- Decision: #74 is satisfied for PR #72 by the accepted synthetic
  viewport/report-only path

This decision closes only the draft PR benchmark evidence gate. It does not
qualify a physical device, a real display-scale reference target, a public
benchmark ranking, a beta/stable release performance gate, a frame-budget gate,
or a memory/leak claim.

## Acceptance Audit

### Qualified Path

Issue #74 accepts one of several qualified paths, including a reviewed
synthetic viewport design that records requested and observed metadata
separately.

Current evidence satisfies that synthetic path:

- `docs/benchmarks/2026-06-12-synthetic-viewport-profile-design.md` is accepted
  for internal/report-only PR #72 evidence.
- `docs/benchmarks/policies/profile-synthetic-viewport-policy.json` is active
  only for report-only synthetic viewport harness-stability evidence.
- `docs/benchmarks/baselines/2026-06-12-synthetic-viewport-policy-probe.md`
  records the one-repeat synthetic probe.
- `docs/benchmarks/baselines/2026-06-12-synthetic-viewport-repeat5.md`
  records the repeat-5 synthetic collection.

The synthetic artifacts record:

- requested viewport: `800x600 @ 2.0x`;
- observed host before override: `800x600 @ 1.0x`;
- applied viewport: `800x600 @ 2.0x`;
- caveats: `test_view_override`, `not_real_display_scale`,
  `not_public_reference_target`.

### Probe Before Repeat-5

The one-repeat synthetic policy probe ran before the repeat-5 collection. The
tracked notes preserve that sequence:

- one-repeat run id:
  `2026-06-12-synthetic-viewport-policy-probe-r1`;
- repeat-5 run id:
  `2026-06-12-synthetic-viewport-repeat5-r1`.

### Artifact Placement

Raw artifacts remain under ignored `build/benchmarks/` paths:

- `build/benchmarks/profile-synthetic-probe/2026-06-12-synthetic-viewport-policy-probe-r1/`;
- `build/benchmarks/profile-synthetic/2026-06-12-synthetic-viewport-repeat5-r1/`.

Only summary notes and policy/design files are tracked.

### Report-Only Wording

The tracked notes explicitly block public or release-readiness claims. The
repeat-5 note records `totalRuns=5`, `successfulRuns=5`, `failedRuns=[]`,
`observedRepeats=5`, and `outlierRepeats=[]`, but keeps all timing values
report-only. It also states that the run did not request `--profile-memory`, so
memory and GC values are not used for memory claims.

### Simulator Scope

Simulator evidence remains route-smoke evidence only. It is not used to satisfy
the #74 benchmark decision because Flutter rejects iOS Simulator profile/release
builds before launch.

## Remaining Non-Claims

This decision does not prove:

- the local Mac is a real `800x600 @ 2.0x` observed-host reference target;
- a physical iOS or Android target has been qualified;
- synthetic timing can be compared with historical observed-host runs;
- Tagflow is faster or slower than another renderer;
- Tagflow is lower-memory, leak-free, or frame-budget ready;
- the native runtime is beta or stable ready.

Those require a separate policy, target qualification, collection, and review.

## PR Impact

PR #72 can treat #74 as closed for benchmark coordination, while keeping all
benchmark language report-only. PR #72 should remain draft until the separate
real-app route gate in #73 is satisfied.
