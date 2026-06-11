# Tagflow Dynamic Document Updates SPEC

**Status:** Active post-alpha stabilization SPEC
**Last Updated:** 2026-06-11
**Target Release Line:** post-`1.0.0-alpha.1` stabilization
**Primary Audience:** Tagflow runtime, adapter, table-extension, and benchmark
workers

## 1. Problem Statement

Tagflow now has the right alpha foundation for Flutter-native dynamic content:
`TagflowDocument`, `TagflowHtmlAdapter`, `TagflowContentPolicy`,
`TagflowComponentRegistry`, `Tagflow.html(...)`, and
`Tagflow.document(...)`.

The next product problem is different from the alpha problem. AI responses, CMS
blocks, and app-authored content often update after the first render. Tagflow
must support that without becoming a browser DOM, rich text editor, or mutable
HTML runtime.

The smallest useful next slice is to make semantic document node identity
meaningful for Flutter updates and to define a document-diff contract before
adding a controller or cache API.

## 2. Decision

Dynamic content should be **document-diff-based**, with stable semantic node
identity as the first implementation slice.

It should not be controller-based first. A controller can be a later convenience
for apps that want imperative append/replace helpers, but it should apply
immutable document updates internally rather than own the renderer state.

It should not be adapter-cache-based first. Caching repeated HTML adaptation can
reduce cost for streaming HTML, but it does not solve native app-authored
documents, CMS patch payloads, link/action preservation, table registry
interaction, or state preservation during reorders.

It should not be deferred entirely. The existing public node `id` field is
already part of the alpha document model, so the renderer should use it now as
Flutter identity while the broader update API remains deliberate.

## 3. Non-Goals

- Browser DOM mutation APIs.
- JavaScript execution or live CSSOM behavior.
- Rich text editing operations, cursor state, selection deltas, or undo stacks.
- Streaming HTML parsing.
- Mutable `TagflowDocumentNode` instances.
- A `TagflowDocumentController` as the first public dynamic API.
- A generalized action system beyond existing link handling.
- Table-layout mutation APIs that bypass semantic table nodes.
- Performance claims before the `streaming_ai_chunks` benchmark has a semantic
  document lane and reviewed baseline.

## 4. Current Runtime Audit

### Stable node ids

`TagflowDocumentNode.id` is public and required. App-authored documents can
already provide durable IDs. The HTML adapter currently assigns IDs with
`TagflowNodeIds.fromPath(path)`, so full reparses are deterministic only while
earlier sibling structure is unchanged. Inserting a paragraph before an existing
paragraph shifts path IDs and makes the same content look like different nodes.

First slice requirement:

- Semantic rendering must key widgets by `TagflowDocumentNode.id`.
- Future document update APIs must require IDs to be unique within a document.
- Path-generated HTML IDs are acceptable for compatibility, but they are not a
  stable identity strategy for arbitrary streaming insertions.

### Diffability

The document and node classes are immutable and deeply comparable, which is a
good base. Missing pieces:

- no public node lookup by ID
- no copy/update helpers
- no diff or patch result type
- no duplicate-ID validation
- no way to express append versus replace intent

The next API should add immutable update helpers before any controller.

### Cache boundaries

`Tagflow` currently caches the parsed `_document` inside widget state and
reparses HTML whenever `html`, adapter, view options, or render boundary change.
`TagflowHtmlAdapter.parse(...)` creates a parser for each parse. Registry
changes rerender document input without reparsing. Legacy custom converters
force the compatibility bridge path.

This is clear but coarse. Parser/adaptor caches should wait until stable IDs and
update semantics exist, otherwise cache hits will optimize the wrong behavior.

### Policy reapplication

`TagflowHtmlAdapter` applies `TagflowContentPolicy` on every parse. Native
`Tagflow.document(...)` intentionally trusts the supplied document as already
adapted. Dynamic update APIs must keep this boundary:

- HTML or remote source updates go through an adapter and policy.
- App-authored `TagflowDocument` updates are treated as trusted runtime input.
- A future JSON/native adapter must apply policy before producing a document or
  document update.

### Link/action preservation

Links are represented by semantic `TagflowNodeKind.link`, `url`, and sanitized
HTML attributes in metadata. Taps route through `TagflowViewOptions` /
`TagflowOptions.linkTapCallback`, so link behavior is view-owned rather than
node-owned.

The first dynamic API should preserve link nodes by ID and URL. It should not
introduce arbitrary node actions yet. A later action model can use stable node
IDs as the target identity.

### Table extension interaction

`tagflow_table` already renders semantic table nodes through
`tagflowTableComponents(...)`. It computes table layout from table, row, and
cell children each render and consumes normalized presentation hints from the
HTML adapter.

Dynamic table updates must preserve IDs on table rows and cells so Flutter state
and render-object children can move predictably. The first update slice should
not expose row-span or cell-layout mutation helpers; whole-node append/replace
is enough.

### API naming

The shipped alpha API uses `TagflowDocumentNode`, not the earlier spec's
shorter `TagflowNode`. Keep that name. The existing `TagflowNodeIds` helper
should be documented as path-ID generation, not as the preferred ID strategy for
dynamic app-authored content.

`TagflowDocumentController` is a tempting name, but it should be deferred until
there is a proven need for imperative lifecycle ownership.

## 5. Public API Proposal

This public API landed in `c4938e0 feat(runtime): add document patch updates`:

```dart
final class TagflowDocumentPatch {
  const TagflowDocumentPatch.replaceNode({
    required String nodeId,
    required TagflowDocumentNode node,
  });

  const TagflowDocumentPatch.appendChildren({
    required String parentNodeId,
    required List<TagflowDocumentNode> children,
  });

  const TagflowDocumentPatch.removeNode({required String nodeId});
}

extension TagflowDocumentUpdates on TagflowDocument {
  TagflowDocument applyPatch(TagflowDocumentPatch patch);

  TagflowDocument applyPatches(Iterable<TagflowDocumentPatch> patches);
}
```

Contract:

- Patches return a new immutable `TagflowDocument`.
- Patch application fails with `ArgumentError` when the target ID is missing.
- Patch application fails with `StateError` when duplicate node IDs would be
  introduced.
- Patch application preserves all untouched node object identities where
  practical.
- Replacement can change node kind, but the replacement node's ID must match
  `nodeId` unless an explicit rename operation is added later.
- Append operations are allowed for any node with `children`, including table
  rows and table cells, but table-specific validity remains the renderer's
  responsibility in this slice.

No controller should be added in this slice. If later needed, it should be a
thin notifier around `TagflowDocument.applyPatch(...)`:

```dart
final class TagflowDocumentController extends ValueNotifier<TagflowDocument> {
  TagflowDocumentController(super.value);

  void applyPatch(TagflowDocumentPatch patch) {
    value = value.applyPatch(patch);
  }
}
```

That shape keeps Flutter apps free to use their existing state management
instead of coupling Tagflow to one imperative update model.

## 6. Internal Architecture Changes

### Landed slices

- `TagflowComponentRegistry.render(...)` wraps each rendered semantic node in a
  `KeyedSubtree` with `ValueKey<String>(node.id)`.
- Focused widget coverage proves component state follows semantic node IDs
  across reorder updates.
- `TagflowDocumentPatch` supports immutable replace, append-children, and
  remove operations.
- `TagflowDocumentUpdates.applyPatch(...)` and `applyPatches(...)` landed as
  extension methods through the runtime public barrel.
- Runtime patch coverage proves append, replace, remove, missing-target
  failure, duplicate-ID failure, replacement-ID validation, and untouched
  branch identity preservation.

### Landed benchmark slice

- The example profile harness includes a patch-based semantic document
  streaming lane: `TAGFLOW_RENDERER=tagflow_semantic_patch` with
  `TAGFLOW_FIXTURE=streaming_ai_patches`.
- The patch lane adapts `ai_answer_rich` into a semantic document once, then
  applies `TagflowDocumentPatch` updates to append progressive child batches.
- Local macOS profile smoke evidence confirms the lane emits viewport, update,
  update-latency, and final scroll payloads. The result remains report-only
  until reviewed reference-runner baselines exist.

### Later implementation slices

- Add HTML adapter ID strategy options after patch semantics exist.
- Keep `tagflow_semantic` as the current semantic HTML benchmark lane for
  `streaming_ai_chunks`.
- Compare the patch-based semantic document benchmark lane against full-reparse
  `tagflow_semantic` once both run on the same reference runner.
- Add optional adapter cache only after the benchmark proves repeated HTML parse
  cost dominates.
- Consider a controller only after at least one real app needs imperative
  ownership instead of passing a new document through app state.

## 7. Benchmark Acceptance

The existing `streaming_ai_chunks` scenario measures four progressively larger
HTML payloads and reports update latencies plus final scroll metrics. Use
`tagflow_semantic` as the primary renderer for dynamic-content investigation
because it parses HTML into `TagflowDocument` and renders through semantic
components plus the first-party semantic table extension. The `tagflow`
renderer remains a compatibility lane that may use legacy converter bridges.

Current validation command:

```bash
TAGFLOW_RENDERER=tagflow_semantic TAGFLOW_FIXTURE=streaming_ai_chunks \
  dart run melos run benchmark:profile
```

Acceptance for the keyed-node slice:

- `git diff --check` passes.
- Focused semantic registry widget tests pass.
- `streaming_ai_chunks` remains non-gating but must still emit update latency
  and scroll payloads when run locally.

Acceptance for the patch API slice:

- Unit tests prove append, replace, remove, missing-target failure, and
  duplicate-ID failure.
- Replacement node IDs must match the target ID.
- Untouched branches preserve object identity where practical.

Acceptance for the patch benchmark slice:

- Existing keyed-render widget tests continue to prove state preservation across
  stable-ID reorders.
- Add a patch-based semantic document streaming benchmark lane that adapts
  `ai_answer_rich` once, applies document patches for each chunk, and records
  the same update-latency payload shape as the HTML semantic lane.
- The lane uses `tagflow_semantic_patch` plus `streaming_ai_patches` so it can
  be measured independently from full-reparse `tagflow_semantic`.
- On the same reference runner, semantic patch updates should not be slower
  than the current full-reparse HTML lane for `streaming_ai_chunks`. Treat
  timing as report-only until reviewed baselines exist.

## 8. Migration Compatibility

Existing compatibility remains:

- `Tagflow.html(...)` continues to parse full HTML strings.
- Legacy `Tagflow(html: ...)` remains an alpha compatibility alias.
- Legacy custom converters keep using the compatibility bridge when supplied.
- Existing app-authored `TagflowDocument` construction remains valid.

New guidance:

- Dynamic apps should create stable, domain-derived node IDs such as
  `answer.block.summary`, `message.42.paragraph.3`, or CMS block IDs.
- `TagflowNodeIds.fromPath(...)` is suitable for static generated trees and
  adapter fallback, not for long-lived dynamic app state that receives
  insertions before existing siblings.
- Apps that only have raw HTML streams can keep using `Tagflow.html(...)` while
  accepting full reparse behavior until an adapter cache or source-aware ID
  strategy lands.

## 9. Risks

- Keying by `node.id` turns duplicate sibling IDs into visible Flutter key
  conflicts. That is the right failure mode for a runtime identity contract, but
  the next patch slice should add explicit validation with clearer errors.
- Path IDs from the HTML adapter may still churn for inserted content. This spec
  does not solve streaming HTML identity by itself.
- Patch helpers could grow into an editor API if they accumulate cursor,
  selection, formatting, or undo behavior. Keep them structural and immutable.
- App-owned link/action state may need a richer action model later, but adding
  it before real usage would overbuild.
- Table updates can produce structurally odd tables. The first patch slice
  should preserve renderer behavior and avoid table-specific mutation APIs.

## 10. Open Decisions

- Should patch helpers stay extension-only through beta, or should they move to
  instance methods before stable?
- Should patch application expose a `TagflowDocumentPatchResult` with changed
  IDs and reused IDs, or is the new document enough for the first release?
- Should duplicate-ID validation happen eagerly in `TagflowDocument` creation,
  only in patch APIs, or both?
- Should HTML adapter ID strategy support an attribute such as `data-tagflow-id`
  before adapter caching?
- Should benchmark fixtures add a native document fixture alongside HTML and
  Markdown sources?
