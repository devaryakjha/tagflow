# Tagflow Beta Public API Freeze Review

**Status:** Draft review for `1.0.0-beta.0` readiness  
**Date:** 2026-06-12  
**Reviewed Baseline:** published `tagflow` `1.0.0-alpha.3` plus
`codex/tagflow-native-runtime-master` follow-up benchmark evidence
**Scope:** `package:tagflow/tagflow.dart`, `package:tagflow/legacy.dart`, and
the first-party `tagflow_table` extension posture

## Purpose

This review classifies the public API that is currently reachable through
`package:tagflow/tagflow.dart` before any `1.0.0-beta.0` naming or stability
claim is made.

The conclusion is conservative: Tagflow is not beta-ready yet. The runtime
direction is correct, but beta should wait until hosted alpha app integration
covers the production and native-transport paths, unsupported-content behavior
is fully frozen, and table extension release ownership is decided.

This document does not authorize publishing, tagging, package-version changes,
or beta release copy.

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
application. The public copy helpers are additive structural-update helpers:
omitted nullable arguments preserve existing values, while explicit `clearX`
flags remove nullable runtime fields such as document `source` and node
payloads. Calling a helper with both a replacement value and the matching clear
flag is an `ArgumentError`.

`alpha-only review required`:

- `TagflowNodeKind.unsupported`
- `TagflowDocument.version`

Rationale: unsupported placeholders and document-version semantics are public.
Preserved policy-rejection placeholders now have a tested neutral renderer, but
the beta line still needs a vocabulary decision for future unknown native block
kinds. `TagflowDocument.version` must also stay clearly described as runtime
schema rather than app payload schema.

### Rendering Registry

`beta-stable candidate`:

- `TagflowComponentBuilder`
- `TagflowComponentContext`
- `TagflowComponentRegistry`

Rationale: the registry is the native runtime extension point. It cleanly
separates semantic document input from Flutter widget construction and is the
right direction for app-owned and first-party extension renderers.

`alpha-only review required`:

- Registry fallback behavior for unknown or unsupported node kinds.

Rationale: the mechanism exists, but beta needs a documented policy for when
fallbacks should preserve content, fail loudly, or render placeholders.

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

`beta-stable candidate, pending app evidence`:

- `Tagflow.html(..., registry: ...)`

Rationale: this is the right ergonomic bridge for HTML-origin content that
needs semantic registry overrides. It should not be called beta-stable until at
least one real app consumes a hosted alpha package through this path.

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
rendering, not conversion back into the legacy node tree. Keep it available
from `package:tagflow/legacy.dart`, not the primary
`package:tagflow/tagflow.dart` runtime barrel.

### Native Block Transport

`beta-stable candidate, pending hosted app evidence`:

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
runtime model.

`alpha-only review required`:

- native block kind vocabulary
- future unknown-block compatibility behavior
- transport revision semantics
- patch envelope revision semantics

Rationale: strict `schemaVersion == 1` is now the right alpha contract. Before
beta, Tagflow still needs real-app evidence using hosted alpha packages, and
the alpha transport currently keeps unknown future block kinds strict at codec
decode time. Beta must decide whether to keep that policy, preserve
placeholders through an explicit unknown-block model, or require versioned
codecs. Revision fields are currently producer tokens, not a core sync/conflict
protocol.

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

`alpha-only review required`:

- exact default behavior for known native blocks rejected by policy.

Rationale: HTML blocked-tag behavior is documented and tested more clearly than
native policy-rejected block behavior. Beta needs those policy stories aligned.

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
semantics. The extension types currently depend on legacy CSS enum types, so
their beta support story should be documented as compatibility styling rather
than the primary component-registry contract.

Recommendation: keep these exported through beta for migration stability, but
avoid presenting CSS parsing as the future app-extension model.

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

Rationale:

- the core package already has a basic built-in table renderer;
- high-fidelity table behavior is an extension concern;
- keeping table rendering separate validates the `TagflowComponentRegistry`
  extension model;
- merging the package before real app evidence would prematurely couple core
  runtime stability to a complex renderer.

Required before beta:

- decide whether `tagflow_table` should release in lockstep with `tagflow`
  betas or remain independently versioned with compatible constraints.

The migration guide now documents `tagflow_table` as the canonical
high-fidelity table registry extension through beta in "Compatibility Support
Windows". Hosted alpha.3 Kite validation also proved that `tagflow_table`
`1.0.0-alpha.1` can be resolved beside `tagflow` `1.0.0-alpha.3` for a
downstream widget-test integration, but that does not decide beta release
cadence.

## Beta.0 Readiness Checklist

`1.0.0-beta.0` is not ready until all of these are complete:

- Hosted alpha package is consumed by at least one real app through
  `Tagflow.html(...)` or `TagflowHtmlAdapter`. Done for Kite widget-test and
  real-route validation; production profile evidence is still separate.
- Hosted alpha package is consumed by at least one real app through native block
  document and patch transport. Done for a Kite hosted-alpha widget-test
  fixture; production integration remains pending.
- App-authored/native document construction has a documented fail-fast identity
  validation path. Done with `TagflowDocument.validated(...)`; changing the
  permissive `TagflowDocument(...)` constructor remains a separate beta
  compatibility decision.
- App-authored/native document copy helpers have explicit nullable-field
  clearing semantics. Done with `clearX` flags on document and node copy
  helpers; omitted nullable arguments continue to preserve current values.
- `Tagflow.html(..., registry: ...)` is validated in a real app or explicitly
  scoped as still alpha. Done for Kite widget-test validation with
  `tagflow_table`; production rendering still uses the legacy converter bridge.
- `TagflowOptions` support window is written in migration docs. Done in
  "Compatibility Support Windows".
- `package:tagflow/legacy.dart` support window is written in migration docs.
  Done in "Compatibility Support Windows".
- Native block `schemaVersion == 1` policy is documented in release-facing
  adapter docs. Done in the migration guide and package README.
- Unknown native block kind and unsupported-content behavior are tested and
  documented for the alpha strict policy. Done for strict unknown-kind decode
  failures and preserved policy-rejection placeholders; future unknown-block
  compatibility remains a beta vocabulary decision.
- `tagflow_table` beta posture is decided and documented. Partly done in
  "Compatibility Support Windows"; hosted alpha dependency compatibility has
  evidence, but release cadence still needs a beta decision.
- Benchmark docs remain report-only unless a stable reference environment and
  threshold policy are approved.
- Release docs avoid beta/stable language until this checklist is green.

## Verdict

Tagflow should continue hardening the alpha line after `1.0.0-alpha.3`, not
move to `1.0.0-beta.0` yet.

The beta shape is visible: canonical runtime documents, adapter-owned
transports, content policy, and semantic component registries. The remaining
work is not broad feature expansion; it is contract hardening and real app
evidence.
