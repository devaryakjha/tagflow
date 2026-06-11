# Tagflow Native Rich Content Runtime SPEC

**Status:** Draft for master-thread review
**Last Updated:** 2026-06-11
**Target Release Line:** `1.0.0-alpha.1`
**Primary Audience:** implementation workers for `packages/tagflow`,
`packages/tagflow_table`, docs, and example-app migration work

**Current-state note:** this is the original alpha.1 architecture SPEC. For
alpha.3 planning, treat
`docs/specs/2026-06-11-post-alpha2-native-runtime-roadmap.md` and the
alpha.2 handoff as newer coordination sources. The implemented public runtime
node type is `TagflowDocumentNode`; older `TagflowNode` examples in this SPEC
should be read as historical shorthand only where not corrected below.

## 1. Context

Tagflow today is an HTML-first Flutter renderer:

- `Tagflow(html: ...)` is the main public entry point.
- Parsing, style resolution, and conversion are all centered around HTML tags.
- `tagflow.dart` exports most internals directly, including parser, models,
  styles, and converters.
- `tagflow_table` extends rendering quality for one HTML feature area instead of
  participating in a general runtime contract.

That architecture has been effective for early feature delivery, but it anchors
Tagflow to HTML as the source of truth. The product direction is different:
Tagflow should be a native rich content runtime for Flutter apps. HTML remains
important, but only as one adapter.

This spec defines the breaking architecture line for `1.0.0-alpha.1`. The goal
is not to finish the entire product vision in alpha. The goal is to land the
minimum durable runtime shape that later adapters, renderers, and editor-facing
APIs can build on.

## 2. Goals

### Alpha goals

- Make a native Tagflow document model the source of truth.
- Treat HTML as an adapter into that model, not as the runtime model itself.
- Preserve the existing end-user value for currently supported content:
  paragraphs, headings, emphasis, links, code, blockquotes, lists, images, and
  tables.
- Keep a compatibility path for `Tagflow(html: ...)` so existing adopters are
  not forced into a same-day rewrite.
- Introduce explicit contracts for:
  - document model
  - adapters
  - content policy and sanitization
  - renderer/component registry
  - theming versus adapter-derived presentation
  - caching
  - backwards-compatibility posture

### Non-goals for alpha

- Browser parity
- Arbitrary CSS support
- JavaScript execution
- DOM mutation APIs
- Full streaming HTML parsing
- Rich text editing
- A general plugin marketplace
- Moving HTML into a separate published package immediately

## 3. Product Principles

- Tagflow is a native content runtime, not a webview replacement.
- Semantic content comes before source-format fidelity.
- Runtime contracts must be Flutter-native and source-agnostic.
- HTML-specific behavior belongs in the HTML adapter boundary.
- Unsupported or unsafe input must fail predictably, not implicitly execute.
- Alpha may break internals aggressively, but it must not be vague about what is
  stable and what is not.

## 4. Current-State Findings That Shape This Spec

- The current parser already normalizes HTML into immutable node objects and
  reparents them. That is the correct direction, but the model is still HTML-tag
  shaped.
- The current converter seam is useful, but it is selector-based and therefore
  tightly coupled to HTML.
- `TagflowTheme` already provides a strong style merge mechanism, but it mixes
  semantic styling with HTML/CSS parsing concerns.
- `TagflowOptions` already contains runtime concerns such as links, image
  behavior, selection, and render boundaries. Those should survive the rewrite.
- Performance work in `0.0.6` and render-boundary work in `0.0.8` are worth
  preserving. The new architecture must not throw away those gains.
- `tagflow_table` proves there is real value in specialized renderers, which is
  a good argument for a first-class registry contract.

## 5. Proposed Architecture

### Runtime layers

Tagflow `1.0.0-alpha.1` should have five explicit layers:

1. **Document layer**
   - Immutable, source-agnostic rich content model.
2. **Adapter layer**
   - Converts source input into `TagflowDocument`.
   - Alpha ships HTML only.
3. **Policy layer**
   - Sanitization, allowlists, resource rules, and fallback behavior.
4. **Renderer layer**
   - Converts semantic document nodes into Flutter widgets via a registry.
5. **Theme/presentation layer**
   - Merges app-defined theme rules with adapter-supplied presentation hints.

### Package posture for alpha

- Keep `packages/tagflow` as the main published package.
- Keep HTML support inside `packages/tagflow` for alpha, but move it into an
  explicit adapter namespace.
- Keep `packages/tagflow_table` as a first-party renderer extension package.
- Do **not** split out `tagflow_html` in alpha. That would add package churn
  before the runtime contracts have stabilized.

## 6. Public API for Alpha

### Stable alpha public entry points

The alpha line should expose these primary concepts:

```dart
Tagflow.html(...)
Tagflow.document(...)

final document = TagflowHtmlAdapter(...).parse(html);

TagflowDocument
TagflowDocumentNode
TagflowContentPolicy
TagflowComponentRegistry
TagflowTheme
TagflowViewOptions
```

### Widget API

The main widget should evolve into named constructors:

```dart
class Tagflow extends StatelessWidget {
  const Tagflow.html({
    required String html,
    TagflowHtmlAdapter? adapter,
    TagflowTheme? theme,
    TagflowComponentRegistry? registry,
    TagflowViewOptions options = TagflowViewOptions.defaults,
    super.key,
  });

  const Tagflow.document({
    required TagflowDocument document,
    TagflowTheme? theme,
    TagflowComponentRegistry? registry,
    TagflowViewOptions options = TagflowViewOptions.defaults,
    super.key,
  });
}
```

Rules:

- `Tagflow.document` is the canonical runtime API.
- `Tagflow.html` is a convenience wrapper over `TagflowHtmlAdapter` plus
  `Tagflow.document`.
- The current default constructor `Tagflow({required html, ...})` may remain in
  alpha as a deprecated alias, but new docs should prefer named constructors.

### Legacy API posture

These APIs are **legacy compatibility surfaces** in alpha:

- `TagflowParser`
- `NodeParser`
- `ElementConverter`
- selector-based custom converter registration on the main widget

Compatibility rule:

- If an app uses only `Tagflow(html: ...)` plus theme/options, it should migrate
  onto the new runtime automatically.
- If an app depends on custom `ElementConverter`s, alpha may keep a legacy mode
  or bridge layer, but that path is explicitly transitional and not the primary
  extension story.

## 7. Document Model

### Root object

`TagflowDocument` is the immutable source of truth.

Required fields:

- `id`
- `children`
- `metadata`
- `source`
- `version`

Suggested shape:

```dart
final class TagflowDocument {
  const TagflowDocument({
    required this.id,
    required this.children,
    this.metadata = const {},
    this.source,
    this.version = 1,
  });

  final String id;
  final List<TagflowDocumentNode> children;
  final Map<String, Object?> metadata;
  final TagflowSourceInfo? source;
  final int version;
}
```

### Node model

The new node model must be semantic, not raw-tag based.

Alpha-required node kinds:

- `root`
- `container`
- `paragraph`
- `heading`
- `text`
- `link`
- `list`
- `listItem`
- `blockquote`
- `codeBlock`
- `inlineCode`
- `image`
- `table`
- `tableRow`
- `tableCell`
- `horizontalRule`
- `unsupported`

Every node must have:

- stable `id`
- `kind`
- `children`
- `presentation`
- `metadata`
- optional `source`

Specialized fields are allowed per node kind. Examples:

- `HeadingNode.level`
- `ListNode.ordered`
- `ImageNode.url`, `alt`, `width`, `height`
- `TableCellNode.rowSpan`, `colSpan`, `header`
- `LinkNode.url`
- `TextNode.text`

### Node identity

Node IDs must be deterministic for the same adapter output. Alpha does not need
distributed UUIDs. A path-based ID such as `0.1.3` or a hashed equivalent is
enough. Stable IDs are required now so later incremental rendering and editor
features do not force another document-model break.

### Adapter metadata versus runtime metadata

Node metadata is split conceptually into:

- `presentation`: normalized hints that may affect rendering
- `metadata`: non-visual adapter or app data

Examples:

- `presentation.padding` is valid.
- `metadata['htmlTag'] = 'blockquote'` is valid.
- raw CSS declaration strings are **not** a runtime contract.

## 8. Adapter Layer

### Base contract

Alpha introduces a source adapter contract:

```dart
abstract interface class TagflowAdapter<TInput> {
  TagflowDocument parse(
    TInput input, {
    TagflowContentPolicy policy = TagflowContentPolicy.defaults,
  });
}
```

### HTML adapter

Alpha ships one first-party adapter:

- `TagflowHtmlAdapter`

Responsibilities:

- parse HTML
- sanitize input under `TagflowContentPolicy`
- normalize HTML structures into semantic nodes
- preserve safe presentational hints where appropriate
- attach source metadata for debugging/migration
- support current render-boundary behavior

### HTML normalization rules

Representative mappings:

- `<p>` -> `paragraph`
- `<h1>` to `<h6>` -> `heading(level: n)`
- `<strong>`, `<b>` -> text emphasis in `presentation` or inline semantic nodes
- `<em>`, `<i>` -> same
- `<a>` -> `link`
- `<ul>`, `<ol>` -> `list`
- `<li>` -> `listItem`
- `<blockquote>` -> `blockquote`
- `<pre>` -> `codeBlock`
- `<code>` inside non-`pre` -> `inlineCode`
- `<img>` -> `image`
- `<table>` -> `table`
- structural wrappers such as `div`, `section`, `article`, `main`, `aside` ->
  `container`

Unknown safe container-like elements may degrade to `container`. Unsafe or
meaningless elements should degrade to `unsupported` or be dropped according to
policy.

### Render boundary

Current comment-boundary support should remain, but it becomes an
adapter-specific input filter:

- keep `TagflowRenderBoundary` in alpha for compatibility
- scope it to `TagflowHtmlAdapter`
- do not make comment markers part of the runtime document model

## 9. Content Policy and Sanitization

### Default policy

Alpha must ship with a safe default policy. By default:

- strip `script`, `style`, `iframe`, `object`, `embed`, `form`, `input`,
  `button`, `textarea`, and other executable or browser-dependent elements
- reject `javascript:` URLs
- reject non-image `data:` URLs
- allow remote images only when resource loading is enabled
- keep comments only for adapter-internal features such as render boundaries

### Policy shape

The policy API must make three decisions explicit:

1. Which source elements and attributes are allowed.
2. Which external resources are allowed to load.
3. How unsupported content degrades.

Suggested surface:

```dart
final class TagflowContentPolicy {
  const TagflowContentPolicy({
    this.allowRemoteImages = true,
    this.allowDataImages = false,
    this.allowedSchemes = const {'http', 'https', 'mailto'},
    this.unsupportedBehavior = TagflowUnsupportedBehavior.drop,
  });
}
```

### Unsupported content behavior

Alpha must support at least:

- `drop`
- `preservePlaceholder`

`preservePlaceholder` is important for debugging and migration. It allows apps
to surface that something was intentionally not rendered, instead of silently
losing content.

## 10. Renderer and Component Registry

### Registry contract

The renderer extension story must move from HTML selectors to semantic node
kinds.

Alpha introduces `TagflowComponentRegistry` with precedence:

1. app overrides
2. first-party extension packages
3. built-in core components

Each component is registered against semantic node kinds, not HTML selectors.

### Renderer responsibilities

The renderer:

- walks `TagflowDocument`
- resolves theme and presentation
- dispatches each node to a registered component
- handles nested inline/block composition
- applies interaction behavior from view options

### Table extension posture

`tagflow_table` should become the canonical example of the new registry:

- it registers renderers for `table`, `tableRow`, and `tableCell`
- it may override the basic core table renderer
- it must not require HTML parser knowledge beyond semantic table-node fields

That boundary is important. `tagflow_table` should consume `TableNode`, not
re-parse HTML-shaped table state.

## 11. Theming and Presentation Boundary

### Core rule

`TagflowTheme` is for app and semantic styling.
Adapter-specific style parsing is for presentation hints.
Those are related, but not the same thing.

### Alpha merge order

Resolved style for a node should come from:

1. runtime defaults
2. semantic theme defaults for the node kind
3. theme variants
4. adapter-derived presentation hints
5. app overrides targeted at that node

This ordering preserves app authority while still allowing HTML-derived
presentation where appropriate.

### HTML/CSS posture in alpha

Alpha keeps limited HTML style parsing only as an HTML-adapter concern:

- inline style parsing stays supported for currently covered features
- class-based styles may remain for HTML compatibility
- full CSS cascade, media queries, variables, and browser layout semantics are
  out of scope

Implementation note:

- the existing `StyleParser` and parts of `TagflowTheme` may stay physically in
  `packages/tagflow` for alpha, but they should be reorganized conceptually
  under the HTML adapter boundary instead of remaining the runtime contract

## 12. View Options

`TagflowOptions` should be renamed or re-scoped to `TagflowViewOptions` in the
new API. It remains responsible for runtime view behavior, not parsing
semantics.

Alpha-required options:

- link tap callback
- text selection enablement
- image loading and image error builders
- max image dimensions
- image cache toggle
- error widget builder

HTML-only options such as render boundaries belong either on
`TagflowHtmlAdapter` or on `Tagflow.html`.

## 13. Streaming and Incremental Rendering Posture

### Alpha posture

Alpha does **not** need general streaming parsing.

What alpha does need:

- immutable documents
- stable node IDs
- renderer logic that can rebuild subtrees deterministically
- adapter APIs that do not make whole-document replacement the only possible
  future

### Explicitly deferred

These are later-phase items:

- token-by-token streaming adapters
- partial HTML DOM patching
- viewport virtualization
- widget recycling for long documents

The architecture must remain compatible with those features, but alpha should
not pretend to deliver them.

## 14. Caching

Current alpha.2/alpha.3 posture: do not treat this historical alpha.1 cache
section as an implementation instruction. Later update and adapter SPECs
deliberately defer parser and adapter cache APIs until stable IDs, patch
semantics, benchmark evidence, and real-app integration evidence show the
right boundary.

### Alpha requirements

Alpha should include lightweight, explicit caching at the document and adapter
levels.

Required cache scopes:

- parse cache keyed by input hash plus adapter/policy configuration
- normalized document cache keyed by source plus adapter version

Non-requirements for alpha:

- cross-context widget caching
- global render-object reuse
- persistence to disk

Rules:

- caches must be opt-in or bounded
- cache invalidation keys must include policy and adapter config
- image caching should continue to rely primarily on Flutter/image-provider
  behavior

## 15. Backwards Compatibility Policy

### What alpha promises

- `Tagflow.html` will exist.
- Current built-in content types will keep working with equivalent behavior or a
  documented migration note.
- The migration path from current `Tagflow(html: ...)` usage will be documented.

### What alpha does not promise

- direct source compatibility for parser/converter internals
- selector-based custom converter APIs as a long-term extension surface
- raw HTML-tag node types remaining public forever
- exact current export layout from `tagflow.dart`

### Export policy

`tagflow.dart` should stop exporting every internal implementation unit by
default. Alpha should expose a curated public surface and move legacy/internal
types behind explicit legacy exports if needed.

## 16. File and Module Direction

Alpha implementation should move toward this structure inside
`packages/tagflow/lib/src/`:

- `document/`
  - `document.dart`
  - `nodes.dart`
  - `source_info.dart`
- `adapters/html/`
  - `html_adapter.dart`
  - `html_sanitizer.dart`
  - `html_style_parser.dart`
- `policy/`
  - `content_policy.dart`
- `render/`
  - `document_view.dart`
  - `component_registry.dart`
  - `components/`
- `theme/`
  - `theme.dart`
  - `resolved_style.dart`
- `legacy/`
  - compatibility wrappers for old parser/converter entry points

This is direction, not a requirement to land every file in one PR. The
important constraint is boundary clarity.

## 17. Alpha Acceptance Criteria

Current-state note: these criteria describe the alpha.1 gate and are preserved
as history. Alpha.3 planning should use the post-alpha.2 roadmap instead of
treating this list as a beta-readiness or alpha.3 release gate.

`1.0.0-alpha.1` is acceptable only if all of the following are true:

1. A public `TagflowDocument` model exists and is the canonical renderer input.
2. A public `TagflowHtmlAdapter` exists and is the canonical HTML entry point.
3. `Tagflow.html(...)` renders through the new document runtime for the built-in
   supported feature set.
4. The supported built-in feature set includes current coverage for headings,
   paragraphs, emphasis, links, lists, blockquotes, code, images, and tables.
5. A public `TagflowContentPolicy` exists with safe defaults and tests for
   unsafe content stripping and URL handling.
6. A semantic `TagflowComponentRegistry` exists and can override at least one
   built-in renderer from app code or `tagflow_table`.
7. Render-boundary behavior still works for HTML input.
8. The public API clearly separates runtime view options from HTML-adapter
   options.
9. The package exports are curated so new adopters do not import internals by
   accident.
10. There is a migration document from current `0.0.x` HTML-first usage to the
    alpha runtime.

## 18. Deferred to Beta and Later

These items are intentionally later than `1.0.0-alpha.1`:

- Markdown adapter
- broader JSON/native document serialization beyond the narrow native block
  transport prepared for the alpha.2 candidate
- editor-facing APIs
- virtualization for very large documents
- richer unsupported-content diagnostics
- accessibility audit beyond parity fixes
- browser-like CSS features
- separate published `tagflow_html` package
- long-term removal of legacy parser/converter APIs

## 19. Risks

### Main implementation risks

- **Compatibility drag:** preserving legacy converter hooks too deeply could
  prevent the semantic registry from becoming real.
- **Half-semantic model risk:** if HTML tags remain the practical source of
  truth inside the new model, the rewrite will only rename layers.
- **Theme coupling risk:** if CSS parsing stays embedded in core theme
  resolution, non-HTML adapters will inherit HTML assumptions.
- **Table split risk:** if `tagflow_table` still depends on HTML parsing
  details, the extension contract is not actually stabilized.
- **Export sprawl risk:** if alpha keeps exporting internals broadly, accidental
  public API growth will continue.

## 20. Decisions Needing Master-Thread Review

1. Should the current `converters:` parameter on `Tagflow` trigger an explicit
   legacy path in alpha, or should it be moved to a separate legacy widget/API?
2. Should `tagflow_table` remain a separate package through beta, or should it
   fold into core once the semantic registry exists?
3. Should unsupported content default to `drop` or `preservePlaceholder` in
   debug builds?
4. Is `TagflowOptions` renamed to `TagflowViewOptions` in alpha, or is that
   deferred to beta to reduce API churn?
5. Do we keep class-based style hooks in the HTML adapter for alpha, or reduce
   to inline-style plus semantic mapping only?

## 21. Recommended First Implementation Sequence

The master thread should schedule work roughly in this order:

1. define the document and policy types
2. add the HTML adapter and compatibility wrapper
3. add the semantic renderer registry
4. migrate built-in renderers
5. migrate `tagflow_table`
6. tighten exports and docs

That order creates the new source-of-truth model first and avoids starting with
cosmetic API reshuffles.
