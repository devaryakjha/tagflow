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
already provide durable IDs. The HTML adapter now supports two ID strategies:

- `TagflowHtmlNodeIdStrategy.path()` remains the default compatibility mode and
  assigns IDs with `TagflowNodeIds.fromPath(path)`.
- `TagflowHtmlNodeIdStrategy.attribute()` reads authored IDs from
  `data-tagflow-id` by default and can use a custom attribute name when needed.

Full reparses with path IDs are deterministic only while earlier sibling
structure is unchanged. Inserting a paragraph before an existing paragraph
shifts path IDs and makes the same content look like different nodes. Authored
IDs are the dynamic-content path for controlled HTML, CMS, or AI producers that
can re-emit stable logical block identifiers across updates.

First slice requirement:

- Semantic rendering must key widgets by `TagflowDocumentNode.id`.
- Future document update APIs must require IDs to be unique within a document.
- Path-generated HTML IDs are acceptable for compatibility, but they are not a
  stable identity strategy for arbitrary streaming insertions.
- Attribute mode falls back to path IDs by default for unannotated nodes.
- Attribute mode with `fallbackToPath: false` is the strict adapter path and
  fails on unannotated text or element nodes.
- Duplicate IDs fail during adaptation, including collisions between authored
  IDs and fallback path IDs.

### Diffability

The document and node classes are immutable and deeply comparable, which is a
good base. The landed patch API now covers append, ordered insert, replace,
remove, and
duplicate-ID checks during patch application. The landed query/validation
helpers now add `TagflowDocument.nodeById(...)`,
`TagflowDocument.containsNodeId(...)`, and
`TagflowDocument.validateUniqueNodeIds()` using the same runtime traversal and
duplicate-ID rules as patch application. Remaining gaps for broader diff
tooling:

- no copy/update helpers outside patch application
- no diff or patch result type
- no eager whole-document duplicate-ID validation for plain
  `TagflowDocument(...)` construction

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

  const TagflowDocumentPatch.insertBefore({
    required String siblingNodeId,
    required List<TagflowDocumentNode> nodes,
  });

  const TagflowDocumentPatch.removeNode({required String nodeId});
}

extension TagflowDocumentUpdates on TagflowDocument {
  TagflowDocument applyPatch(TagflowDocumentPatch patch);

  TagflowDocument applyPatches(Iterable<TagflowDocumentPatch> patches);
}

extension TagflowDocumentQueries on TagflowDocument {
  TagflowDocumentNode? nodeById(String nodeId);

  bool containsNodeId(String nodeId);

  void validateUniqueNodeIds();
}
```

Contract:

- Patches return a new immutable `TagflowDocument`.
- Patch application fails with `ArgumentError` when the target ID is missing.
- Patch application fails with `StateError` when duplicate node IDs would be
  introduced.
- Patch application preserves all untouched node object identities where
  practical.
- Query helpers return existing node instances and do not mutate the document.
- Validation helpers remain explicit; `TagflowDocument(...)` construction does
  not eagerly reject duplicates in this slice.
- Replacement can change node kind, but the replacement node's ID must match
  `nodeId` unless an explicit rename operation is added later.
- Append operations are allowed for any node with `children`, including table
  rows and table cells, but table-specific validity remains the renderer's
  responsibility in this slice.
- Ordered insert operations target an existing sibling ID and insert new nodes
  immediately before that sibling, including at the document root.

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
- `TagflowDocumentPatch` supports immutable replace, append-children,
  insert-before, and remove operations.
- `TagflowDocumentUpdates.applyPatch(...)` and `applyPatches(...)` landed as
  extension methods through the runtime public barrel.
- Runtime patch coverage proves append, insert-before, replace, remove,
  missing-target failure, duplicate-ID failure, replacement-ID validation, and
  untouched branch identity preservation.

### Landed benchmark slice

- The example profile harness includes a patch-based semantic document
  streaming lane: `TAGFLOW_RENDERER=tagflow_semantic_patch` with
  `TAGFLOW_FIXTURE=streaming_ai_patches`.
- The patch lane adapts `ai_answer_rich` into a semantic document once, then
  applies `TagflowDocumentPatch` updates to append progressive child batches.
- Local macOS profile smoke evidence confirms the lane emits viewport, update,
  update-latency, and final scroll payloads. The result remains report-only
  until reviewed reference-runner baselines exist.

### Landed HTML adapter identity slice

- `TagflowHtmlAdapter` now supports authored-ID strategies through
  `TagflowHtmlNodeIdStrategy`.
- `TagflowHtmlNodeIdStrategy.path()` remains the default compatibility mode.
- `TagflowHtmlNodeIdStrategy.attribute()` reads `data-tagflow-id` by default
  and can be pointed at another attribute when integrating with controlled
  producers.
- Attribute mode fails on duplicate IDs during adaptation, including authored
  IDs that collide with fallback path IDs.
- Attribute mode with `fallbackToPath: false` is the strict mode for producers
  that want parsing to fail instead of silently mixing authored and generated
  IDs.

### Later implementation slices

- Keep `tagflow_semantic` as the current semantic HTML benchmark lane for
  `streaming_ai_chunks`.
- Add an authored-ID insertion benchmark slice for controlled dynamic HTML.
  The fixture should reparse HTML snapshots that preserve existing
  `data-tagflow-id` values while inserting new blocks before old siblings, then
  compare that report-only full-reparse lane against equivalent semantic patch
  updates on the same reference runner.
- The runtime patch API now supports ordered sibling insertion directly, so the
  authored-insertion patch lane no longer needs parent replacement as a
  semantic workaround. A later benchmark worker should switch the authored
  insertion patch stream from `replaceNode(...)` to `insertBefore(...)`.
- Keep the current repeat-5 caveat explicit while designing that slice: the
  patch lane is measurable, but the existing paired baseline showed old-gen GC
  on every repeat and one missed raster-budget frame, so the next run is for
  identity and GC diagnosis, not performance claims.
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

Next measurement slice to implement:

- Add a future fixture such as `streaming_ai_authored_insertions` for
  controlled HTML that can emit stable `data-tagflow-id` values across updates.
- Model insertions ahead of existing siblings so the fixture exercises the exact
  churn case that path IDs cannot preserve.
- Measure two report-only lanes on the same reference runner:
  `tagflow_semantic` reparsing HTML with
  `TagflowHtmlNodeIdStrategy.attribute()`, and
  `tagflow_semantic_patch` applying equivalent semantic document updates.
- Capture the same viewport, update, update-latency, and final scroll payloads
  as the current semantic pair. Do not add timing thresholds or faster/slower
  claims to this slice.
- Keep the paired repeat-5 caveat attached to the review note: the current
  patch lane is measurable but recorded old-gen GC on every repeat and one
  raster miss.

Acceptance for the keyed-node slice:

- `git diff --check` passes.
- Focused semantic registry widget tests pass.
- `streaming_ai_chunks` remains non-gating but must still emit update latency
  and scroll payloads when run locally.

Acceptance for the patch API slice:

- Unit tests prove append, insert-before, replace, remove, missing-target
  failure, and duplicate-ID failure.
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
- Pair it with an authored-ID insertion slice once the fixture exists, and keep
  both lanes report-only until reviewed baselines exist.
- Compare timing and GC diagnostics in reviewed notes only. Do not add hard
  thresholds or claim that patch updates are faster than reparsing.

## 8. Migration Compatibility

Existing compatibility remains:

- `Tagflow.html(...)` continues to parse full HTML strings.
- Legacy `Tagflow(html: ...)` remains an alpha compatibility alias.
- Legacy custom converters keep using the compatibility bridge when supplied.
- Existing app-authored `TagflowDocument` construction remains valid.

New guidance:

- Dynamic apps should create stable, domain-derived node IDs such as
  `answer.block.summary`, `message.42.paragraph.3`, or CMS block IDs.
- App-authored document updates can now insert nodes before existing siblings
  without replacing the whole parent subtree.
- `TagflowNodeIds.fromPath(...)` is suitable for static generated trees and
  adapter fallback, not for long-lived dynamic app state that receives
  insertions before existing siblings.
- Controlled HTML, CMS, or AI producers that can annotate content should use
  `TagflowHtmlNodeIdStrategy.attribute()` so reparses preserve authored logical
  IDs even when new siblings are inserted before old ones.
- `TagflowHtmlNodeIdStrategy.attribute()` uses `data-tagflow-id` by default.
  Set `fallbackToPath: false` when missing annotations should fail fast instead
  of mixing authored and generated IDs.
- Apps that only have raw HTML streams can keep using `Tagflow.html(...)` with
  default path IDs while accepting full reparse behavior and ID churn on
  insertions.

## 9. Risks

- Keying by `node.id` turns duplicate sibling IDs into visible Flutter key
  conflicts. Adapter parsing and patch application now fail explicitly on
  duplicates, but plain app-authored `TagflowDocument(...)` construction still
  lacks eager whole-document validation.
- Path IDs from the default HTML adapter strategy still churn for inserted
  content. Controlled producers need authored IDs to preserve identity across
  reparses.
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
- Should benchmark fixtures add a native document fixture alongside HTML and
  Markdown sources?
- Should the authored-ID insertion benchmark live as a distinct fixture or as a
  parameterized variant of the current semantic streaming fixtures?
