# Tagflow Beta Public API Freeze Review

**Status:** Draft review for `1.0.0-beta.0` readiness  
**Date:** 2026-06-12  
**Reviewed Baseline:** current coordinator branch through
`fe28a17 docs(benchmarks): record memory manifest smoke` after published
`tagflow-v1.0.0-alpha.3`; this includes post-publish public API follow-ups in
`packages/tagflow`, `packages/tagflow_table`, and benchmark/docs evidence
**Scope:** `package:tagflow/tagflow.dart`, `package:tagflow/legacy.dart`, and
the first-party `tagflow_table` extension posture

## Purpose

This review classifies the public API that is currently reachable through
`package:tagflow/tagflow.dart` before any `1.0.0-beta.0` naming or stability
claim is made.

The conclusion is conservative: Tagflow is not beta-ready yet. The runtime
direction is correct, but beta should wait until hosted alpha app integration
covers a pushed and merged production route, supported-target profile evidence
exists, memory/allocation evidence is reviewed, and release gates are approved.
The reviewed style and table public-surface blockers have been resolved on the
coordinator branch.

This review assumes one breaking native-runtime `1.0.0` prerelease line. A
future `1.0.0-beta.x` or `1.0.0-pre.x` label should be chosen only when the
freeze gates are satisfied; this document does not change package versions or
create a separate compatibility line.

This document does not authorize publishing, tagging, package-version changes,
or beta release copy.

## Coordinator-Head Delta Since Published `1.0.0-alpha.3`

The current review baseline is not identical to the already-published alpha.3
package.

- `package:tagflow/tagflow.dart` now hides `TagflowHtmlDocumentBridge`; the
  bridge remains public only through `package:tagflow/legacy.dart`.
- `TagflowDocument.validated(...)`, `TagflowDocument.copyWith(...)`,
  `TagflowDocument.copyWithValidated(...)`, and
  `TagflowDocumentNode.copyWith(...)` are public on current coordinator `HEAD`
  and therefore need beta classification even though they are not part of the
  published alpha.3 payload.
- The built-in runtime registry now gives `TagflowNodeKind.unsupported` a
  dedicated placeholder renderer instead of relying on the generic empty-leaf
  fallback.

This review therefore classifies the current coordinator export surface, not
only the published alpha.3 artifact.

## Classification Terms

- `beta-stable candidate`: likely to remain public through beta and stable with
  normal additive evolution.
- `alpha-only review required`: public during alpha, but needs a freeze,
  rename, narrowing, hiding, or support-window decision before beta.
- `compatibility surface`: retained to keep HTML-renderer migrations working,
  but not the primary extension model for the native runtime.

## Public Surface Classification

### Runtime Document Model

`beta-stable candidate`:

- `TagflowDocument`
- `TagflowDocument.validated(...)`
- `TagflowDocument.copyWith(...)`
- `TagflowDocument.copyWithValidated(...)`
- `TagflowDocumentNode`
- `TagflowDocumentNode.copyWith(...)`
- `TagflowNodeKind`
- `TagflowNodeKind.unsupported`
- `TagflowDocumentQueries`
- `TagflowDocumentPatch`
- `TagflowDocumentUpdates`
- `TagflowMetadata`
- `TagflowPresentation`
- `TagflowInlineSemantic`
- `TagflowSourceInfo`
- `TagflowSourceKind`
- `TagflowNodeIds`

Rationale: these are the core source-agnostic runtime model. They represent
the direction Tagflow should freeze around: immutable documents, semantic node
kinds, stable IDs, metadata, source records, presentation hints, and ordered
patch application. `TagflowDocument.validated(...)` is the preferred
fail-fast construction path for app-authored, CMS-authored, or AI-authored
native documents that need duplicate-ID validation before rendering or patch
application. The default `TagflowDocument(...)` constructor remains
permissive through beta for alpha source compatibility and for callers that
intentionally choose when to run `validateUniqueNodeIds()`. Do not make the
default constructor fail-fast for `1.0.0-beta.0`; revisit a deprecation,
rename, or stricter constructor only before stable and only with hosted app
evidence. The public copy helpers are additive structural-update helpers:
omitted nullable arguments preserve existing values, while explicit `clearX`
flags remove nullable runtime fields such as document `source` and node
payloads. Calling a helper with both a replacement value and the matching clear
flag is an `ArgumentError`.

`alpha-only review required`:

- `TagflowDocument.version`

Rationale: `TagflowNodeKind.unsupported` is now frozen as a runtime placeholder
kind, not as the native JSON unknown-kind compatibility model. Preserved
policy-rejection placeholders have a tested neutral renderer, and unsupported
runtime nodes with children render through the child-preserving fallback.
Unknown producer block kinds are not placeholders in the alpha native JSON
transport; they fail during codec decode before adaptation. The beta line still
needs a vocabulary decision only if Tagflow wants a future unknown-block
compatibility model. `TagflowDocument.version` must stay clearly described as
runtime schema rather than app payload schema.

### Rendering Registry

`beta-stable candidate`:

- `TagflowComponentBuilder`
- `TagflowComponentContext`
- `TagflowComponentRegistry`

Rationale: the registry is the native runtime extension point. It cleanly
separates semantic document input from Flutter widget construction and is the
right direction for app-owned and first-party extension renderers.

Current fallback policy:

- `TagflowComponentRegistry.builtIn` has a component or fallback path for every
  current `TagflowNodeKind`.
- `TagflowComponentRegistry(...)` creates a full registry. Even with no
  overrides or extensions, it includes built-in components and the built-in
  fallback. App overrides take precedence over extension components, which take
  precedence over built-ins.
- Leaf `TagflowNodeKind.unsupported` nodes render as a neutral "Unsupported
  content" placeholder and do not expose rejection details in visible text.
- Unsupported or otherwise unmapped runtime nodes with children render through
  the built-in fallback, preserving children. HTML-origin inline hints may
  still apply presentation such as strong/emphasis/highlight.
- Leaf unmapped runtime nodes with no children render as empty space through
  the fallback.
- `TagflowComponentRegistry.components(...)` creates an extension fragment, not
  a full render registry. If a fragment is used directly without a fallback,
  `canRender(...)` is false for missing kinds and `render(...)` throws
  `UnsupportedError`.

Rationale: this closes the beta ambiguity for runtime registry fallbacks. The
renderer fallback layer is separate from native JSON transport compatibility:
unknown native producer `kind` values still fail during codec decode before any
runtime registry can see them.

### Widget Entry Points and View Options

`beta-stable candidate`:

- `Tagflow`
- `Tagflow.document(...)`
- `Tagflow.html(...)`
- `TagflowViewOptions`
- `TagflowSelectableOptions`
- `TagflowImageSelectionBehavior`
- `TagflowLinkTapCallback`
- `TagflowErrorWidgetBuilder`
- `TagflowScope`

Rationale: these APIs now align with the native runtime framing. `Tagflow` can
render a `TagflowDocument` directly, and `Tagflow.html(...)` is an adapter-backed
convenience entry point. `TagflowViewOptions` is the correct place for view
behavior such as links, selection, images, cache behavior, and error rendering.

`beta-stable candidate`:

- `Tagflow.html(..., registry: ...)`

Rationale: this is the right ergonomic bridge for HTML-origin content that
needs semantic registry overrides. Focused package widget tests now cover the
semantic override path, legacy-converter precedence, and registry-only
rebuilds without reparsing. Kite hosted-alpha3 widget-test evidence was first
captured in commit `be97da15` and is now adopted locally on Kite
`feat/dashboard` as `80160401`; it exercises real IPO HTML fixture content
through
`Tagflow.html(..., registry: ...)` with `tagflow_table` registry extensions and
no legacy converters in the focused validation path. This verifies a hosted
widget-test evidence slice, not a pushed production-route or profile gate. The
Kite push remains blocked by DNS for `gitlab.zerodha.tech`.

`compatibility surface`:

- `TagflowOptions`
- `TagflowRenderBoundary`
- `ErrorWidgetBuilder`

Rationale: `TagflowOptions` bridges the older HTML-first widget API into
`TagflowViewOptions`. `TagflowRenderBoundary` remains HTML-specific and should
not become part of the source-agnostic runtime model. `ErrorWidgetBuilder` is a
legacy typedef alias.

Recommendation: keep `TagflowOptions` and the legacy `Tagflow(html: ...)`
constructor through beta. Mark new docs and examples toward
`TagflowViewOptions`, `Tagflow.html(...)`, and `Tagflow.document(...)`. The
migration guide now records this support window in "Compatibility Support
Windows". Decide before stable whether `TagflowOptions` is kept as a long-term
compatibility alias or deprecated with a stable migration window.

### HTML Adapter

`beta-stable candidate`:

- `TagflowHtmlAdapter`
- `TagflowHtmlNodeIdStrategy`

Rationale: HTML should remain an adapter into the runtime, not the runtime
itself. The adapter and ID strategy are important for dynamic content and patch
integration because apps need deterministic or authored IDs.

`alpha-only review required`:

- `TagflowHtmlDocumentBridge`

Rationale: this is explicitly transitional. It exists so legacy custom
converters can still run, but the future extension model is semantic registry
rendering, not conversion back into the legacy node tree. The current
coordinator barrel already hides it from `package:tagflow/tagflow.dart`. Keep
it available from `package:tagflow/legacy.dart`, not the primary
`package:tagflow/tagflow.dart` runtime barrel.

### Native Block Transport

`beta-stable candidate`:

- `TagflowNativeBlock`
- `TagflowNativeBlockKind`
- `TagflowNativeBlockDocument`
- `TagflowNativeBlockAdapter`
- `TagflowNativeBlockPatch`
- `TagflowNativeBlockPatchKind`
- `TagflowNativeBlockPatchEnvelope`
- `TagflowNativeBlockCodec`

Rationale: native block JSON is the right first transport for AI/CMS/app
generated rich content because it is data-only and adapts into the canonical
runtime model. Kite hosted-alpha3 widget-test evidence, now adopted locally as
commit `80160401`, decodes a native block document from real IPO fixture
values, adapts it, decodes a patch envelope, adapts the patch operations, and
applies them against hosted package APIs in a focused downstream test harness.
This is verified app-integration test evidence, not live production-route
validation and not benchmark/profile evidence.

`alpha-only review required`:

- native block kind vocabulary
- future unknown-block compatibility behavior
- transport revision semantics
- patch envelope revision semantics

Rationale: strict `schemaVersion == 1` is now the right alpha contract. The
hosted-package real-app evidence exists for document and patch transport, and
the alpha transport keeps unknown future block kinds strict at codec decode
time. That strict alpha policy is tested and documented. Beta must decide
whether to keep the strict policy, introduce placeholders through an explicit
unknown-block model, or require versioned codecs. Revision fields are currently
producer tokens, not a core sync/conflict protocol.

### Content Policy

`beta-stable candidate`:

- `TagflowContentPolicy`
- `TagflowUnsupportedBehavior`
- `TagflowResourceType`
- `TagflowTagPolicyDecision`
- `TagflowTagDecisionReason`
- `TagflowUrlPolicyDecision`
- `TagflowUrlDecisionReason`

Rationale: adapter-owned content policy is central to the native runtime story.
Generated or remote content must be validated before it becomes renderable
runtime input.

Current native block policy matrix:

- `link` is URL-bearing. A rejected link URL degrades to a neutral
  `container`, preserves already-adapted children, and records
  `policyDecisionReason` metadata.
- `image` is URL-bearing. A rejected image URL is dropped when
  `unsupportedBehavior` is `drop`, which is the default. With
  `preservePlaceholder`, it becomes a runtime `unsupported` node with policy
  metadata, and the built-in renderer shows the neutral placeholder.
- No other current `TagflowNativeBlockKind` has a URL-bearing field consumed by
  the adapter. Non-URL validation failures for known blocks, such as missing
  required attributes or invalid schema versions, remain adapter/codec errors
  rather than renderer fallback nodes.

Rationale: the beta line can freeze the current per-kind policy semantics for
known native URL-bearing blocks. This does not freeze a future unknown-block
compatibility vocabulary; unknown native JSON producer kinds remain strict
codec failures until beta explicitly introduces a versioned unknown-block
model.

### Style and Theme Surface

`compatibility surface`:

- `TagflowStyle`
- `StyleParser`
- `TagflowTheme`
- `TagflowThemeProvider`
- `FlexTypeExtensions`
- `JustifyContentExtensions`
- `AlignItemsExtensions`

Rationale: these APIs are still useful for existing HTML rendering and theme
migration, but the native runtime should not freeze its core around CSS parser
semantics. The shared style primitives now live on the primary style surface
even though their main use remains compatibility styling rather than the
primary component-registry contract.

Recommendation: keep these exported through beta for migration stability, but
avoid presenting CSS parsing as the future app-extension model.

Resolved for value types:

- `Display`, `SizeValue`, `SizeUnit`, `FlexDirection`, `JustifyContent`, and
  `AlignItems` are now intentionally exported from the primary style barrel as
  shared style primitives instead of remaining only reachable through the
  `legacy.dart` export chain.

Remaining beta question:

- `TagflowTheme` and `StyleParser` still model HTML/CSS compatibility behavior,
  and `TagflowTheme.resolveStyle(...)` still operates on the legacy HTML node
  tree rather than the native runtime document model.

Beta can now describe `package:tagflow/legacy.dart` as optional for these
style value types. The remaining compatibility decision is whether
HTML-node-based theme resolution stays public through beta as compatibility
styling, gets narrowed, or later moves behind a more explicit compatibility
surface.

## `package:tagflow/legacy.dart` Support Window

`package:tagflow/legacy.dart` should be treated as a compatibility surface
through the beta line.

Current compatibility exports include the legacy parser, converter, core model,
parser utilities, reusable legacy widgets, and the curated `tagflow.dart`
surface. This is useful for existing custom converter users, but it should not
be described as the future extension path.

Recommendation:

- keep `legacy.dart` available through all `1.0.0-beta.x` releases;
- document that new integrations should prefer `TagflowDocument`,
  `TagflowHtmlAdapter`, `TagflowNativeBlockAdapter`, and
  `TagflowComponentRegistry`;
- decide before `1.0.0` stable whether legacy remains indefinitely, moves to a
  separate compatibility package, or receives a formal deprecation window.

The migration guide now records this support window in "Compatibility Support
Windows".

## `tagflow_table` Posture Through Beta

`tagflow_table` should remain a separate first-party extension package through
beta.

Current public export classification:

`beta-stable candidate`:

- `tagflowTableComponents(...)`
- `TagflowTableBorder`

Rationale: these are the semantic extension points that match the native
runtime direction. `tagflowTableComponents(...)` is the primary registry
fragment apps should compose, and `TagflowTableBorder` is the only obviously
intentional public configuration type in that flow.

`compatibility surface`:

- `TagflowTableConverter`
- `TagflowTableCellConverter`

Rationale: these exports extend the legacy HTML converter path, not the
semantic runtime model. They are useful during migration, but they should not
define the first-party beta table story.

Resolved beta decision:

- hide `TagflowTable`, `TableCell`, `RenderTagflowTable`, and `TableCellData`
  from `package:tagflow_table/tagflow_table.dart`;
- keep package-internal tests on `package:tagflow_table/src/...` imports where
  they intentionally exercise render-object internals;
- keep `TagflowTableConverter` and `TagflowTableCellConverter` publicly
  exported as the legacy HTML compatibility surface.

Rationale: no reviewed beta docs depend on the low-level render-object types as
part of the first-party extension story. The semantic contract is the registry
fragment plus border configuration, while the converter pair remains the
bounded compatibility surface for HTML migrations.

Rationale:

- the core package already has a basic built-in table renderer;
- high-fidelity table behavior is an extension concern;
- keeping table rendering separate validates the `TagflowComponentRegistry`
  extension model;
- merging the package before real app evidence would prematurely couple core
  runtime stability to a complex renderer.

Beta release cadence policy:

- keep `tagflow_table` separate from `tagflow` through the beta line;
- release `tagflow_table` in lockstep with `tagflow` for `1.0.0-beta.0` so the
  first beta validates core runtime, package constraint, and first-party table
  registry compatibility together;
- after `beta.0`, allow independent `tagflow_table` patch or minor prereleases
  only when its `tagflow` constraint remains compatible with the current beta
  runtime and the semantic registry tests stay green;
- do not merge `tagflow_table` into core during beta unless real app evidence
  shows the separate package boundary is blocking adoption.

The migration guide now documents `tagflow_table` as the canonical
high-fidelity table registry extension through beta in "Compatibility Support
Windows". Hosted alpha.3 Kite validation also proved that `tagflow_table`
`1.0.0-alpha.1` can be resolved beside `tagflow` `1.0.0-alpha.3` for a
downstream widget-test integration. Current package evidence supports the beta
cadence policy: `tagflow_table` exports `tagflowTableComponents(...)` as the
semantic registry fragment, keeps the legacy HTML converter bridge available,
and depends on `tagflow: ^1.0.0-alpha.1` without forcing every core alpha patch
to republish the extension package.

## Beta.0 Readiness Checklist

`1.0.0-beta.0` is not ready until all of these are complete:

- Hosted alpha package is consumed by at least one real app through
  `Tagflow.html(...)` or `TagflowHtmlAdapter`. Verified for a Kite hosted
  widget test that uses real IPO fixture content; live production-route and
  profile evidence remain pending.
- Hosted alpha package is consumed by at least one real app through native block
  document and patch transport. Verified for a Kite hosted-alpha widget-test
  fixture; pushed production integration remains pending.
- App-authored/native document construction has a documented fail-fast identity
  validation path. Done with `TagflowDocument.validated(...)`. Beta posture is
  now explicit: keep `TagflowDocument(...)` permissive through beta for
  compatibility and explicit-validation callers, and recommend
  `TagflowDocument.validated(...)` for app-authored, CMS-authored, or
  AI-authored native documents.
- App-authored/native document copy helpers have explicit nullable-field
  clearing semantics. Done with `clearX` flags on document and node copy
  helpers; omitted nullable arguments continue to preserve current values.
- `Tagflow.html(..., registry: ...)` has focused package widget coverage for
  semantic overrides, legacy-converter precedence, and registry-only rebuilds
  without reparsing. Hosted widget-test validation is done in Kite commit
  `80160401` locally on `feat/dashboard`; a separate isolated Kite branch
  `codex/ipo-tagflow-registry-content` prepares content-only production
  rendering through the registry path as `e26a14e6` and keeps downstream table
  coverage aligned with the beta public barrel in test cleanup `6d0d29f8`.
  Push, merge, real-route validation, and profile evidence remain separate.
- `TagflowOptions` support window is written in migration docs. Done in
  "Compatibility Support Windows".
- `package:tagflow/legacy.dart` support window is written in migration docs.
  Done in "Compatibility Support Windows".
- Main-barrel style APIs either stop depending on `legacy.dart` value types or
  that coupling is explicitly frozen as part of beta compatibility policy. Done:
  shared style primitives are intentionally exported from the primary style
  surface, and style libraries no longer import them through `legacy.dart`.
- `tagflow_table` low-level render-object exports are either intentionally
  classified for beta support or narrowed before the freeze. Done: the public
  barrel is narrowed to the semantic extension surface, `TagflowTableBorder`,
  and legacy compatibility converters.
- Native block `schemaVersion == 1` policy is documented in release-facing
  adapter docs. Done in the migration guide and package README.
- Unknown native block kind and unsupported-content behavior are tested and
  documented for the alpha strict policy. Done for strict unknown-kind decode
  failures with pathful errors, strict schema-version failures, policy-rejected
  links degrading to neutral containers, default drop behavior for rejected
  image blocks, and preserved policy-rejection placeholders with neutral
  rendering; future unknown-block compatibility remains a beta vocabulary
  decision.
- `tagflow_table` beta posture is decided and documented. Done: keep it as a
  separate first-party extension through beta, release it in lockstep for
  `beta.0` compatibility validation, and permit independent patch/minor
  prereleases afterward only while compatible constraints and semantic registry
  tests remain green.
- Benchmark docs remain report-only unless a stable reference environment and
  threshold policy are approved.
- Release docs avoid beta/stable language until this checklist is green.
- Stable `1.0.0` remains blocked after beta until freeze decisions hold through
  prerelease adoption, benchmark evidence gates are credible, and at least one
  hosted real-app validation path is pushed, merged, routed, and reviewed.

## Verdict

Tagflow should continue hardening the alpha line after `1.0.0-alpha.3`, not
move to `1.0.0-beta.0` yet.

The beta shape is visible: canonical runtime documents, adapter-owned
transports, content policy, and semantic component registries. The remaining
work is not broad feature expansion; it is contract hardening and real app
evidence.
