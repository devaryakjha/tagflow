# 2026-06-12 Native Versus HTML Equivalence Slice

## Status

- Date: 2026-06-12
- Scope: next benchmark slice planning for native rich content versus the HTML
  bridge in Flutter
- Posture: SPEC and audit handoff only, no new benchmark claim

## Purpose

Tagflow already has report-only local evidence for:

- HTML compatibility and semantic profile lanes
- semantic patch streaming and authored insertion update lanes
- native JSON transport microbenchmarks
- native JSON repeat-5 local profile baselines
- local memory/allocation review inputs

That is enough to show the harness works. It is not enough to support a
credible native-versus-HTML runtime comparison, because the current native JSON
fixtures are intentionally native-only and not transport-equivalent to the HTML
fixtures.

This note records the smallest next slice that would create honest
cross-transport evidence without widening into thresholds, public claims, or
new memory policy.

## Audited Current State

### What already exists

- `benchmark:profile:baselines`, summary, and check support report-only local
  profile collection across HTML, semantic, patch, markdown, and native JSON
  lanes.
- `docs/benchmarks/baselines/2026-06-12-native-json-repeat5-local-baseline.md`
  already records repeat-5 local macOS evidence for:
  - `tagflow_native_json:native_ai_answer`
  - `tagflow_native_json:native_table_dense`
  - `tagflow_native_json:native_large_article`
- `docs/benchmarks/baselines/2026-06-11-semantic-streaming-pair-repeat5.md`
  and the authored-insertion notes already compare full reparses against patch
  application for the semantic runtime.
- `docs/benchmarks/baselines/2026-06-12-html-memory-evidence-interpretation-scope.md`
  already records the current non-device HTML memory evidence boundary.

### What does not exist yet

- A fixture family that is semantically equivalent across:
  - `Tagflow.html(...)` compatibility rendering
  - `Tagflow.document(...)` from HTML-adapted semantic content
  - `Tagflow.document(...)` from trusted native block JSON
- Artifact metadata that would let a reviewer say the native and HTML runs used
  the same authored content shape instead of merely similar benchmark
  categories.
- A reviewed note that compares equivalent HTML and native runtime paths while
  keeping transport overhead and render phases separate.

### Why current native JSON evidence is not enough

The current native fixtures explicitly avoid equivalence claims. For example:

- `packages/tagflow_benchmarks/fixtures/native/native_large_article.json`
  says not to compare that fixture against HTML engines.
- `packages/tagflow_benchmarks/fixtures/native/native_table_dense.json`
  says it intentionally has no competitor HTML equivalent.

That means the current native JSON repeat-5 baseline is valid native-only local
stabilization evidence, but it is not honest native-versus-HTML evidence.

## Decision

Do not extend the current reviewed notes into a native-versus-HTML claim from
the existing fixture set.

The next credible slice is one transport-equivalent fixture family with bounded
scope and existing profile metrics. Nothing broader is justified before that
lands.

## Smallest Credible Next Slice

### Slice summary

Add one new product-shaped benchmark family that has:

1. one HTML source fixture
2. one native block JSON fixture
3. equivalent authored content and feature coverage
4. explicit report-only benchmark notes

Recommended family id:

- `answer_detail_equivalent_v1`

### Why this slice first

Use a compact answer-detail surface first instead of `large_article` or
`table_stress` because it is the lowest-noise path that still exercises the
native rich-content direction:

- heading
- intro paragraph
- inline link
- callout
- ordered list
- compact table

That is enough to compare the runtime path without dragging in large-document
scroll variance, table-stress ceiling behavior, or patch-streaming attribution.

### Renderer scope

Keep the first equivalence slice limited to first-party Tagflow paths:

- `tagflow`
- `tagflow_semantic`
- `tagflow_native_json`

Do not include competitor HTML packages in this slice. The immediate question is
whether Tagflow's native runtime path produces credible report-only evidence
versus Tagflow's own HTML bridge path. Competitor fairness is separate work.

### Fixture contract

The HTML and native fixtures must match on authored semantics, not on bytes:

- same section order
- same heading levels
- same link destination
- same list length and order
- same table dimensions and header/body meaning
- same callout presence and tone
- same disclosure of benchmark caveats

They must also stay inside the shared feature subset already proven in both
paths:

- no raw CSS-dependent behavior
- no unsupported HTML-only constructs
- no patch-envelope semantics
- no external assets
- no async media

### Required metadata

Before claiming equivalence, the future implementation should record reviewer
visible metadata for both fixtures:

- fixture family id
- fixture source type
- source asset path
- source hash
- equivalence posture: `transport_equivalent_report_only`

This is the minimum metadata needed to keep future notes from drifting into
"same category" language when they only have "same content family" evidence.

### Metrics to reuse

Reuse the current profile harness exactly as it exists today:

- `coldInitialRender`
- `warmRebuild`
- `warmScroll`
- viewport metadata
- input metadata
- launch attribution when available

Keep all values report-only. Do not add thresholds or ranking language.

### Suggested future commands

After the equivalent fixtures exist, the first local collection pass should stay
bounded:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_PAIR=tagflow:answer_detail_equivalent_v1,tagflow_semantic:answer_detail_equivalent_v1,tagflow_native_json:answer_detail_equivalent_v1_native \
TAGFLOW_PROFILE_REPEAT=5 \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer \
dart run melos run benchmark:profile:baselines
```

Then summarize and check with the existing policy:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer \
dart run melos run benchmark:profile:summarize
```

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_PROFILE_RUN_ID=<run-id> \
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-equivalent-answer \
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json \
dart run melos run benchmark:profile:check
```

## Expected Implementation Surface

When the coordinator chooses to implement this slice, keep it focused to:

- one new HTML fixture under `packages/tagflow_benchmarks/fixtures/html/`
- one new native JSON fixture under `packages/tagflow_benchmarks/fixtures/native/`
- benchmark fixture metadata/tests in `packages/tagflow_benchmarks`
- example-app fixture registration in `examples/tagflow/lib/benchmarks/fixtures.dart`
- benchmark note updates under `docs/benchmarks/baselines/`

Do not widen into:

- physical-device qualification
- memory/allocation capture
- competitor adapters
- patch streaming
- public threshold policy

## Exit Criteria

This slice is complete when all of the following are true:

- the equivalent HTML and native fixtures are deterministic and committed
- the example app can run the three first-party profile cells above
- the summary/check flow passes with repeat `5`
- the reviewed note explicitly says the evidence is report-only and
  transport-equivalent, not byte-equivalent
- the reviewed note does not make a faster/slower, lower-memory, or ranking
  claim

## Recommendation

Treat this as the next benchmark evidence slice for native rich content versus
the HTML bridge. Do not spend another worker on new native JSON numbers until
the fixtures become equivalence-safe; additional native-only repeats would add
volume, not credibility.
