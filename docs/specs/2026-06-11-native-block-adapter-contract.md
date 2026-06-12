# Tagflow Native Block Adapter Contract SPEC

**Status:** Implemented adapter foundation; follow-up contract review open
**Last Updated:** 2026-06-12
**Target Release Line:** post-`1.0.0-alpha.1` stabilization
**Primary Audience:** Tagflow runtime, adapter, benchmark, and internal-app
validation workers

**Current-state note:** the implementation-status section below reflects the
coordinator branch after alpha.3 follow-ups. It supersedes older
deferred-first-slice wording later in this SPEC. In particular, the narrow
`TagflowNativeBlockPatchEnvelope` JSON transport, first-class table blocks,
description-list blocks, and node-tap view callbacks have landed; broader
controller, cache, storage, sync, conflict semantics, and executable actions
remain deferred.

## Implementation Status

The first compileable adapter foundation landed in `packages/tagflow` on
2026-06-11 with these constraints:

- `TagflowNativeBlockDocument`, `TagflowNativeBlock`, and
  `TagflowNativeBlockAdapter` adapt typed block payloads into
  `TagflowDocument`.
- The typed block vocabulary now supports `paragraph`, `heading`, `text`,
  `link`, `list`, `listItem`, `descriptionList`, `descriptionTerm`,
  `descriptionDetails`, `blockquote`, `codeBlock`, `inlineCode`, `image`,
  `container`, and `horizontalRule`.
- Table blocks now map directly to runtime `table`, `tableRow`, and
  `tableCell` nodes while preserving stable IDs, child order, and the semantic
  `header`, `rowSpan`, and `colSpan` cell fields.
- Description-list blocks now map directly to runtime `descriptionList`,
  `descriptionTerm`, and `descriptionDetails` nodes. They are first-class
  native content, not HTML-only compatibility tags.
- Callout blocks now normalize to runtime `container` nodes. Stable IDs,
  children, and callout attributes remain preserved; `variant` is exposed as a
  presentation variant, while non-semantic attributes remain metadata-backed.
- Adapter validation now rejects blank or duplicate block IDs before runtime
  document creation and applies `TagflowContentPolicy` to link and image URLs.
- Native block patch adaptation now lands a narrow update slice through
  `TagflowNativeBlockPatch` plus
  `TagflowNativeBlockAdapter.adaptPatch(...)` /
  `adaptPatches(...)`, covering replace, append-children, insert-before, and
  remove operations without widening the runtime mutation model.
- Native block transport now has a deliberately small adapter-side JSON codec:
  `TagflowNativeBlockCodec` decodes and encodes
  `TagflowNativeBlockDocument`, `TagflowNativeBlock`, and
  `TagflowNativeBlockPatchEnvelope` payloads without introducing a generic
  serializer framework.
- The patch transport envelope carries document ID, adapter schema version,
  optional `baseRevision` / `revision` producer tokens, and ordered operations.
  Decoded operations still flow through
  `TagflowNativeBlockAdapter.adaptPatch(...)` / `adaptPatches(...)` and then
  `TagflowDocument.applyPatch(...)` / `applyPatches(...)`; no second mutation
  model was introduced.
- Replacement updates validate block-ID stability before runtime patch
  creation, and append/insert payloads reject duplicate block IDs within the
  update payload before runtime patch application.
- Non-semantic table attributes are not promoted into new typed runtime fields
  in this slice; they remain available in adapter metadata for diagnostics and
  future renderer work.
- Transport metadata and attributes are limited to JSON-like data: null, bool,
  finite numbers, strings, arrays, and string-keyed objects. Callbacks,
  widgets, opaque Dart objects, non-string map keys, and non-finite numbers fail
  with `FormatException`.
- Node tap behavior remains view-owned through `TagflowViewOptions`; native
  block documents, block attributes, native JSON payloads, and patch envelopes
  must remain data-only and must not encode executable handlers.
- Native JSON transport accepts only `schemaVersion: 1` for document envelopes
  and patch envelopes through the beta freeze. Future schema versions must fail
  during codec decode until producer evidence justifies a reviewed
  compatibility policy.
- Unknown block kinds and unknown patch operation names fail during codec
  decode with pathful `FormatException`s through the beta freeze. The beta
  transport does not include an explicit unknown-block representation.
- Source round-tripping is intentionally limited to the existing
  `TagflowSourceInfo` fields: `kind`, `adapter`, `uri`, `line`, `column`, and
  JSON-like metadata. Unknown source kinds fail instead of being silently
  widened.
- Follow-up slices remain for any future dedicated runtime callout renderer
  contract and for broader storage/sync protocol decisions outside this
  adapter-side transport shape.

## 1. Problem Statement

Tagflow's alpha runtime now has the right center of gravity:
`TagflowDocument` is the canonical render model, document patches exist, node
IDs are stable when authored deliberately, and HTML is already being reframed
as an adapter.

That still leaves an important gap for real Flutter apps. Many app, CMS, and
AI content pipelines already produce structured blocks or JSON-shaped rich
content. For those producers, forcing content through an HTML string can be the
wrong abstraction:

- it reparses a string even when the source is already structured
- it makes block identity and provenance harder to preserve
- it couples app-owned content authoring to HTML-tag semantics
- it treats dynamic updates like repeated full-document reparses instead of
  semantic document or patch updates

The next SPEC slice should define a native block-adapter contract for those
structured sources without changing the runtime center. The runtime model stays
`TagflowDocument`. HTML remains a first-party adapter. The new contract exists
so JSON-like block payloads can become documents and document patches without
pretending Tagflow is a browser DOM.

## 2. Positioning

This contract is for **Flutter-native structured rich content**, not for
general webpage rendering.

Expected producers:

- app-authored content assembled in Dart
- CMS block payloads
- AI/server responses emitted as structured content instead of HTML
- trusted backend serializers that already know logical block identity

Expected runtime posture:

- `TagflowDocument` remains the only canonical render input.
- HTML remains one adapter path through `TagflowHtmlAdapter`.
- A native block or JSON adapter becomes a second adapter path into the same
  runtime model.
- Dynamic updates travel through semantic document patches, not a mutable DOM.

This SPEC deliberately defines an adapter contract, not a controller, editor,
or storage format for every future use case.

## 3. Goals

- Define the minimum public contract for adapting structured block content into
  `TagflowDocument`.
- Preserve stable block identity across full-document adaptation and dynamic
  update payloads.
- Keep the contract semantic and Flutter-native rather than HTML-shaped.
- Make policy enforcement explicit before runtime documents or runtime patches
  are created.
- Support the content shapes already important to Tagflow:
  paragraphs, headings, lists, links, media, code, blockquotes, callouts, and
  realistic table structures.
- Leave room for future serializer work without freezing the wrong transport or
  caching story too early.

## 4. Non-Goals

- A controller-first API such as `TagflowDocumentController`.
- Editor or DOM mutation APIs.
- JavaScript execution.
- A styling-language explosion that recreates HTML plus CSS in JSON form.
- Replacing Flutter widgets with a webview or browser-emulation layer.
- Finalizing cross-platform storage, sync, or network transport semantics.
- Adding a cache API before there is evidence that adapter-level caching solves
  a real app bottleneck.

## 5. Proposed Contract Shape

### Public-shape rule

This SPEC defines the **semantic shape** of the adapter contract. Final class
names, Dart constructors, and JSON field casing may change during
implementation review, but the following concepts should be treated as
normative.

### 5.1 Document envelope

A native block payload should adapt from a document envelope with these
required fields:

- `id`: stable document identifier
- `schemaVersion`: adapter-schema version for the payload
- `blocks`: ordered root-level block list

Recommended fields:

- `metadata`: non-executable document metadata
- `source`: provenance such as adapter name, remote URI, or producer kind
- `revision`: producer-side revision token for update coordination

Illustrative shape:

```json
{
  "id": "announcement-2026-06-11",
  "schemaVersion": 1,
  "revision": "cms-rev-42",
  "source": {
    "kind": "json",
    "adapter": "native_block_v1",
    "uri": "cms://announcements/42"
  },
  "metadata": {
    "surface": "announcement_detail",
    "locale": "en-IN"
  },
  "blocks": []
}
```

Adaptation result:

- one envelope becomes one `TagflowDocument`
- `schemaVersion` maps to adapter-level compatibility handling
- runtime `TagflowDocument.version` remains the runtime-model version and is
  not required to equal the wire payload version

### 5.2 Block shape

Each block should support these fields:

- `id`: stable logical block identifier, unique within the document
- `kind`: semantic block type
- `text`: optional literal text payload for leaf-like nodes
- `attributes`: optional data-only attributes for kind-specific fields
- `children`: optional ordered child blocks
- `metadata`: optional non-executable metadata
- `source`: optional provenance override for per-block origin

Illustrative shape:

```json
{
  "id": "summary.callout",
  "kind": "callout",
  "attributes": {
    "tone": "info",
    "title": "What changed"
  },
  "children": [
    {
      "id": "summary.callout.p1",
      "kind": "paragraph",
      "children": [
        {
          "id": "summary.callout.p1.text",
          "kind": "text",
          "text": "Orders now settle on the next business day."
        }
      ]
    }
  ],
  "metadata": {
    "producer": "cms"
  }
}
```

Contract rules:

- IDs must be unique across the whole document, not just among siblings.
- IDs must be producer-stable for any content that expects semantic updates,
  state preservation, or benchmarked dynamic insertion behavior.
- `attributes` and `metadata` are data-only. They must not contain executable
  callbacks, widget factories, or opaque code blobs.
- `children` preserve source order and map directly to runtime child order.
- Producers may omit fields irrelevant to a block kind, but they must not
  overload `metadata` with required semantic fields that should live in
  `kind`, `text`, or `attributes`.

### 5.3 Supported semantic kinds

The contract must support a practical subset that maps cleanly into today's
runtime and renderer boundaries.

Required first-slice block kinds:

- `paragraph`
- `heading`
- `text`
- `link`
- `list`
- `listItem`
- `descriptionList`
- `descriptionTerm`
- `descriptionDetails`
- `blockquote`
- `codeBlock`
- `inlineCode`
- `image`
- `table`
- `tableRow`
- `tableCell`
- `horizontalRule`
- `container`

Additional supported contract shapes for the first slice:

- `callout`
- realistic media blocks that can normalize to image or container semantics
- table-like content with rows and cells, including header-cell intent

Normalization rules:

- Kinds already present in `TagflowDocumentNode` should map directly to their
  runtime equivalents.
- A `callout` block does not require a first-class runtime node on day one. It
  may normalize to `TagflowNodeKind.container` plus presentation and metadata
  until there is evidence that a dedicated runtime kind is necessary.
- Table-related attributes should stay minimal and semantic. They should carry
  structural facts such as header intent, spans, caption presence, or alignment
  hints, not a full HTML/CSS table model.
- Link and media blocks should treat URLs as data to be policy-checked before
  runtime node creation.

### 5.4 Kind-specific attributes

This slice should support the following kind-specific facts at the contract
level when they are semantically meaningful:

- headings: `level`
- lists: `ordered`, optional `startIndex`
- links: `url`, optional title-like metadata
- images/media: `url`, `alt`, optional `width`, `height`
- code blocks: optional `language`
- callouts: tone or variant hint, optional title
- table cells: `header`, `rowSpan`, `colSpan`

Rule:

- these attributes should stay narrow and data-oriented
- the adapter should not import a general style object, selector language, or
  arbitrary widget config into the public contract

### 5.5 Provenance and metadata

The contract should preserve enough provenance for debugging, analytics, and
policy review without making source details part of render semantics.

Recommended preserved facts:

- source kind such as `json`, `app`, or `unknown`
- adapter identifier
- optional remote or logical URI
- producer metadata such as CMS entry ID or AI response ID

Rule:

- provenance may inform logs, tests, debug placeholders, and migration audits
- provenance must not alter runtime behavior unless an explicit policy or
  adapter rule consumes it

## 6. Policy and Security Boundary

The policy boundary must exist **before** runtime documents or runtime patches
are created.

Required behavior:

- untrusted or remote block payloads must flow through a native block adapter
  policy step before they become `TagflowDocument`
- patch payloads from remote or generated sources must go through the same
  policy step before they become `TagflowDocumentPatch`
- URL-bearing attributes must be checked with the same scheme and resource
  rules already established by `TagflowContentPolicy`
- unsupported or blocked native content must fail or degrade predictably
  according to adapter policy, not leak through as half-trusted runtime nodes

Security posture:

- no script execution
- no embedded widget constructors or runtime callbacks in payloads
- no implicit webview fallback
- no trust upgrade merely because the source format is JSON instead of HTML

Policy design direction:

- reuse current `TagflowContentPolicy` concepts where possible
- extend policy at the semantic-kind layer only where HTML-tag rules are not
  expressive enough
- keep unsupported-content behavior aligned with the existing `drop` versus
  `preservePlaceholder` posture where the adapter chooses an `unsupported`
  placeholder fallback

## 7. Unsupported and Unknown Block Behavior

Current alpha transport behavior is intentionally strict: unknown native block
`kind` values fail in `TagflowNativeBlockCodec.decodeDocument(...)` before a
typed `TagflowNativeBlock` is created. Unknown patch operation names fail in
`decodePatchEnvelope(...)` before runtime patch adaptation. There is no public
unknown-block model in the native JSON transport yet.

Known blocks rejected by adapter policy are different from unknown producer
kinds. The current alpha implementation has two reviewed rejection paths:

- a known `image` block with a URL rejected by `TagflowContentPolicy` follows
  the policy's `unsupportedBehavior`: it is dropped, or it becomes a runtime
  `unsupported` placeholder with reason metadata;
- a known `link` block with a rejected URL does not become `unsupported`; it
  degrades to a neutral `container` node, preserves already-adapted children,
  and records the policy reason in metadata.

No other current `TagflowNativeBlockKind` has a URL-bearing field consumed by
the adapter. Missing required attributes, invalid block IDs, unsupported schema
versions, and unknown producer kinds remain validation or codec failures rather
than renderer fallback nodes.

The built-in runtime renderer displays preserved leaf placeholders as neutral
"Unsupported content" rather than leaking the rejected payload details.

Rules:

- behavior must be policy-driven, not adapter-accidental
- unknown native JSON block kinds fail the payload before adaptation
- link fallbacks and placeholders must retain enough metadata to explain what
  was rejected
- apps should be able to benchmark and validate unsupported behavior the same
  way they already do for blocked HTML content
- producers must not rely on policy-rejected known blocks and unknown future
  `kind` values sharing the same fallback behavior

Beta decision:

- Keep unknown producer block kinds as strict codec failures through the beta
  line.
- Keep unsupported document and patch envelope schema versions as strict codec
  failures through the beta line.
- Do not add `TagflowNativeUnknownBlock`, an unknown-kind placeholder transport,
  or schema negotiation for beta.
- Preserve placeholders only for reviewed, policy-rejected known blocks where
  `TagflowContentPolicy.unsupportedBehavior` requests it.

Reopen this decision only with concrete producer evidence: a trusted CMS or app
producer shipping ahead of the package vocabulary, a real migration that needs
old clients to retain unknown blocks losslessly, or a reviewed schema
negotiation design that can preserve data without silently rendering unreviewed
content.

## 8. Dynamic Updates

Dynamic update transport should align with the existing document-patch runtime
direction instead of inventing a second mutation model.

Recommended transport operations:

- replace block by `id`
- append children to parent by `id`
- insert blocks before sibling by `id`
- remove block by `id`

Patch-envelope requirements:

- wire `id` field, represented as `documentId` on
  `TagflowNativeBlockPatchEnvelope`
- `schemaVersion: 1`; other values fail during codec decode until a reviewed
  compatibility policy exists
- operation payloads referencing stable block IDs

Recommended patch fields:

- `revision` or `baseRevision` for coordination when the producer has one
- `metadata` or `source` when useful for diagnostics

Beta revision decision:

- `baseRevision` and `revision` are producer-owned opaque tokens.
- The codec validates their shape as optional strings and preserves them on
  `TagflowNativeBlockPatchEnvelope`.
- The adapter converts only `operations` into `TagflowDocumentPatch` values.
- Core `TagflowDocument.applyPatch(...)` and `applyPatches(...)` do not compare
  document revisions, reject stale envelopes, merge concurrent changes, or
  update document revision metadata.
- Apps, CMS clients, or backend protocols own revision matching and conflict
  handling before they choose to apply adapted patches.

Reopen core revision enforcement only with real-app evidence that multiple
integrations need the same generic conflict contract and that the contract can
stay independent of network retry, offline storage, sync queues, and CMS
protocol semantics.

Flow:

1. remote or app payload arrives as native block document or patch data
2. adapter validates schema and policy
3. adapter normalizes payload into `TagflowDocument` or `TagflowDocumentPatch`
4. runtime applies semantic patches through existing immutable update helpers

Rules:

- update transport stays semantic and immutable
- runtime patch application continues to own duplicate-ID and missing-target
  enforcement
- a future controller, if added later, should remain a thin convenience wrapper
  over immutable document updates

Landed first transport slice:

- `TagflowNativeBlockPatch.replaceNode(...)` adapts one native block into an
  existing `TagflowDocumentPatch.replaceNode(...)`.
- `TagflowNativeBlockPatch.appendChildren(...)` adapts ordered native children
  into `TagflowDocumentPatch.appendChildren(...)`.
- `TagflowNativeBlockPatch.insertBefore(...)` adapts ordered native nodes into
  `TagflowDocumentPatch.insertBefore(...)`.
- `TagflowNativeBlockPatch.removeNode(...)` maps directly to
  `TagflowDocumentPatch.removeNode(...)`.
- Policy and normalization reuse `TagflowNativeBlockAdapter` so callout, table,
  link, and image behavior stays aligned with full-document adaptation.
- `TagflowNativeBlockCodec.decodePatchEnvelope(...)` validates the JSON
  envelope shape at the codec boundary and returns a typed
  `TagflowNativeBlockPatchEnvelope`.
- Direct patch adaptation accepts typed `TagflowNativeBlockPatch` operations
  only, so there is no second adapter-level envelope schema hook in this
  slice.

Explicitly deferred:

- producer conflict handling or revision enforcement beyond preserving the
  landed narrow patch envelope fields: wire `id` / typed `documentId`,
  `schemaVersion`, `baseRevision`, and `revision`
- cross-patch batch conflict validation against an already-evolving runtime
  document
- controller or cache APIs layered above immutable document patches

## 9. Migration from HTML

This contract should expand Tagflow's authoring options without breaking the
HTML adapter story.

Migration posture:

- `Tagflow.html(...)` remains the compatibility entrypoint for controlled HTML
- `TagflowDocument` remains the canonical destination for both HTML and native
  block adaptation
- controlled HTML producers can keep using authored IDs such as
  `data-tagflow-id` while native-block producers emit those same logical IDs
  directly
- HTML and native-block adapters should converge on comparable semantic output
  for shared content shapes

Practical migration cases:

- apps currently receiving controlled HTML can stay on `TagflowHtmlAdapter`
  until their producer is ready to emit structured blocks
- new app-authored content should prefer native documents or the future native
  block adapter instead of building HTML strings
- CMS or AI pipelines can move one surface at a time without changing the
  renderer contract

## 10. Benchmarking and Internal Validation

This SPEC does not define benchmark thresholds. It does define the acceptance
evidence needed before the adapter contract is treated as credible.

Benchmark acceptance:

- extend the existing benchmark harness with a native-block or semantic-JSON
  lane before making performance claims
- compare dynamic block updates against the existing authored-ID HTML insertion
  and semantic patch evidence, including
  `docs/benchmarks/baselines/2026-06-11-authored-insertion-ordered-repeat3.md`
- treat benchmark output as reviewed evidence, not as a license to optimize
  around an unstable contract

Internal Flutter app validation:

- validate one real internal Flutter content surface using either app-authored
  native documents or the narrow native block adapter
- keep the validation path aligned with
  `docs/plans/2026-06-11-internal-app-validation-plan.md`
- capture the same kinds of evidence already required there: semantics,
  unsupported behavior, links, media policy, theme fit, and dynamic update
  behavior

Release posture:

- keep cache APIs and controller APIs deferred until benchmark and app evidence
  show that the adapter contract is correct
- do not publish broad transport promises before one internal app has exercised
  the contract on real content

## 11. Compatibility Risks

This contract is useful only if it avoids freezing the wrong abstraction.

Primary risks:

- making the block contract too HTML-shaped, which would reintroduce source
  coupling under a different name
- making the contract too presentation-heavy, which would create a second CSS
  problem
- adding too many first-class kinds before the runtime and registry actually
  need them
- finalizing patch transport before real producer revision and conflict cases
  have been observed
- introducing a cache or controller API that optimizes around the wrong update
  shape

Mitigation posture:

- keep the contract semantic, data-only, and small
- normalize richer source formats into the current runtime instead of expanding
  the runtime for every producer quirk
- treat callout, media, and table nuances as evidence-driven extensions

## 12. Implementation Sequencing

Implementation order should remain deliberately narrow:

1. SPEC
2. adapter data model
3. narrow parser and serializer
4. focused tests
5. benchmark and internal-app validation

Rules for sequencing:

- do not add cache APIs before the adapter model and validation evidence exist
- do not add a controller-first API before immutable update behavior proves
  insufficient
- keep parser and serializer scope narrow to the semantic block kinds already
  covered by the runtime
- use focused tests for schema validation, policy enforcement, normalization,
  unsupported behavior, and patch adaptation before broad integration work

## 13. Beta Decision Summary

No beta-blocking adapter contract decisions remain open in this SPEC. Richer
producer vocabulary can reopen specific sections later when real app evidence
exists.

Closed for beta: future `schemaVersion` negotiation and unknown producer block
preservation remain deferred. Beta keeps the strict `schemaVersion == 1` and
known-kind codec contract.

Closed for beta: the public native adapter surface is both typed-model and
JSON-codec based. `TagflowNativeBlock`, `TagflowNativeBlockDocument`,
`TagflowNativeBlockPatch`, `TagflowNativeBlockPatchEnvelope`,
`TagflowNativeBlockCodec`, and `TagflowNativeBlockAdapter` are exported through
`package:tagflow/tagflow.dart`. No additional serializer surface is added for
beta beyond the explicit codec.

Closed for beta: native block policy reuses `TagflowContentPolicy` directly.
Do not add a native-specific semantic-kind policy layer until a real app needs
kind-level allowlists, per-kind degradation, or source-specific behavior that
cannot be represented by the current URL/resource and unsupported-content
policy.

Closed for beta: `callout` stays a native producer kind normalized into
`TagflowNodeKind.container` with preserved native metadata and optional
presentation hints. Do not add a first-class runtime node kind or built-in
callout renderer until app integration proves the generic container plus
semantic registry path is insufficient.

Closed for beta: patch transport includes optional producer revision tokens as
part of the first public contract, but those tokens are not core conflict
semantics. Tagflow preserves them on envelopes and metadata while apps own
revision checks and state updates.

Closed for beta: native table normalization stays minimal and semantic.
`table`, `tableRow`, and `tableCell` normalize to the matching runtime nodes;
cell `header`, `rowSpan`, and `colSpan` become runtime fields; other
producer-specific table attributes such as `caption`, `alignment`, `scope`, or
future section hints remain preserved as native block metadata until a renderer
or first-party table extension needs a promoted runtime field.

Closed for beta: richer media groups are not part of the native block
vocabulary. The reviewed media path is the current known `image` block with URL
policy checks. Unknown media kinds such as `video` fail during codec decode
like any other unknown producer kind.

Closed for beta: unsupported behavior uses the shared
`TagflowContentPolicy.unsupportedBehavior` default and semantics. Do not add
adapter-specific unsupported defaults unless real app evidence shows native
producer payloads need a distinct policy from HTML and other runtime adapters.
