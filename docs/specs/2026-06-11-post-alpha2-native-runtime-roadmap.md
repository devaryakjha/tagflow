# Tagflow Post-Alpha.2 Native Runtime Roadmap SPEC

**Status:** Draft for master-thread review
**Last Updated:** 2026-06-11
**Observed Baseline:** `tagflow` `1.0.0-alpha.2` candidate on
`codex/tagflow-native-runtime-master`
**Primary Audience:** runtime, adapter, table-extension, docs, benchmark, and
internal-app implementation workers

## 1. Purpose

This SPEC defines the next architecture target after the native block JSON
transport slice prepared for `1.0.0-alpha.2`.

Owner release decision: use one breaking native-runtime `1.0.0` prerelease line.
Do not create a parallel compatibility package line and do not change package
versions from this SPEC. Future labels may use `1.0.0-beta.x` or
`1.0.0-pre.x` style prerelease wording, but the label is a release-gate
decision, not a docs-only churn mechanism.

The decision is conservative: the next natural target is
`1.0.0-alpha.3` for runtime contract hardening and app integration evidence,
not `1.0.0-beta.0`. Beta should wait until the public runtime and adapter
surface has been exercised by at least one real app using hosted prerelease
packages, and until the remaining alpha compatibility paths have an explicit
freeze, deprecation, or migration decision.

This document is a SPEC and implementation plan. It does not authorize a
publish, tag, package-version bump, or source-code implementation by itself.

## 2. Current Baseline Audit

### Landed through alpha.2 candidate

- `TagflowDocument` is the canonical runtime render input.
- `Tagflow.document(...)` renders native runtime documents through
  `TagflowComponentRegistry`.
- `Tagflow.html(...)` and the legacy `Tagflow(html: ...)` constructor parse
  controlled HTML through `TagflowHtmlAdapter` unless legacy custom converters
  are supplied.
- `TagflowHtmlAdapter` supports path IDs and authored IDs through
  `TagflowHtmlNodeIdStrategy.attribute(...)`.
- `TagflowDocumentPatch` supports immutable replace, append-children,
  insert-before, and remove updates.
- `TagflowNativeBlockDocument`, `TagflowNativeBlock`,
  `TagflowNativeBlockAdapter`, `TagflowNativeBlockPatch`, and
  `TagflowNativeBlockCodec` are public through `package:tagflow/tagflow.dart`.
- The native block JSON transport is data-only and includes document and patch
  envelope decode/encode.
- `TagflowContentPolicy.defaults` blocks executable HTML-like tags, rejects
  unsafe URL schemes, and controls unsupported-content behavior.
- `tagflow_table` provides a first-party semantic table registry extension, but
  remains a separate `1.0.0-alpha.1` package in the alpha.2 handoff.
- The curated public barrel no longer exports parser/converter/core internals;
  those compatibility surfaces live behind `package:tagflow/legacy.dart`.

### Docs that are now stale or need reinterpretation

- `docs/specs/2026-06-11-native-rich-content-runtime.md` targeted
  `1.0.0-alpha.1` and still names the runtime node type as `TagflowNode` in
  examples. The implemented public type is `TagflowDocumentNode`.
- The same alpha.1 SPEC asks for alpha cache scopes, but later update and
  adapter SPECs deliberately deferred cache APIs until identity, patches, and
  app evidence exist. The deferral is the current direction.
- `docs/specs/2026-06-11-native-block-adapter-contract.md` has an
  implementation-status section that records landed codec and patch-envelope
  work, but its later "Landed first slice" subsection still lists patch
  envelopes as deferred. Treat the status section and alpha.2 handoff as newer.
- `docs/specs/2026-06-11-dynamic-document-updates.md` matches the implemented
  immutable patch model closely and remains the best source for update
  semantics.
- `docs/plans/2026-06-11-tagflow-v1-alpha-acceptance-status.md` remains an
  alpha.1 tracker with an alpha.2 prep section. It should not be treated as a
  beta-readiness gate.

### Code constraints that shape the next slice

- `Tagflow.html(...)` accepts a semantic component registry directly for
  HTML-origin runtime documents. Apps that also need authored IDs, strict ID
  policy, source metadata, or parse-time inspection should still parse with
  `TagflowHtmlAdapter` and render with `Tagflow.document(...)`.
- Runtime patch application validates duplicate IDs during patch application,
  and `TagflowDocument.validated(...)` gives app-authored/native producers an
  opt-in fail-fast construction path. Plain `TagflowDocument(...)` remains
  permissive for alpha compatibility and explicit validation flows.
- Native block transport validates JSON-like values and known enum kinds at
  codec decode time; unknown future block kinds fail before adapter fallback
  behavior can preserve placeholders.
- Link taps and image loading remain view-owned through `TagflowViewOptions`
  and the compatibility `TagflowOptions` bridge.
- The core built-in table renderer is intentionally basic; higher fidelity
  table rendering belongs in the first-party `tagflow_table` registry
  extension unless the packages are intentionally merged later.

## 3. Product and Naming Decision

The Tagflow name still fits.

The package surface now supports the migration framing: Tagflow is a native rich
content runtime for Flutter apps, with HTML and native block JSON as adapters
into one runtime model. "Tagflow" does not bind the product to HTML, and the
public API now centers on `TagflowDocument`, adapters, content policy, and a
semantic component registry.

No rename should happen in the alpha line.

Migration implications of a rename would be high and unnecessary:

- package names, import paths, pub.dev pages, docs, examples, release tags, and
  dependent internal apps would all churn;
- existing alpha migration work already teaches `Tagflow.document(...)` and
  `Tagflow.html(...)`;
- the practical problem is not the name, but keeping docs from describing
  Tagflow as only an HTML renderer.

Recommendation: keep `tagflow` and keep shifting copy toward "native rich
content runtime for Flutter apps". Do not create a new package name unless the
product later splits into multiple independently versioned runtimes.

The name remains valid for the native-runtime line because Tagflow owns the
structured content flow inside Flutter: source adapters produce
`TagflowDocument`, policies bound the input, and registries render semantic
nodes. HTML remains an adapter and compatibility source, not the product
definition.

## 4. Versioned Architecture Target

### `1.0.0-alpha.3`: contract hardening target

Alpha.3 should make alpha.2 usable by real app workers without broadening the
runtime vision.

Current-state note: the coordinator branch has moved beyond this original
alpha.3 target. Adapter metadata inspectors, view-owned node taps, render error
fallbacks, description-list semantics, equivalent HTML/native fixtures, and the
DPR feasibility audit have landed. Remaining release movement should use
`docs/plans/2026-06-12-native-runtime-follow-up-sequence.md` for current
sequencing.

Required outcomes:

- document the hosted alpha native transport integration path after publish;
- close public API naming mismatches in docs, especially `TagflowDocumentNode`
  versus earlier `TagflowNode` examples;
- make the native transport unknown-kind behavior explicit before producers
  depend on placeholder semantics;
- document the already-landed `Tagflow.html(..., registry: ...)` path and make
  clear when apps should still prefer the manual parse-to-document path for
  authored IDs, strict policy, source metadata, or parse-time inspection;
- add focused real-app validation for `Tagflow.html(..., registry: ...)`,
  `tagflow_table` registry extensions, and native block document/patch
  payloads against hosted packages;
- keep all benchmark evidence report-only unless a benchmark policy document
  explicitly promotes a claim.

Alpha.3 should not be a feature expansion release. It should be the release that
proves the alpha.2 runtime and transport contracts are understandable,
integratable, and bounded.

### `1.0.0-beta.0`: API-freeze candidate

Beta.0 should wait until these gates are true:

- at least one real app consumes hosted alpha packages through both
  `Tagflow.html(...)` or `TagflowHtmlAdapter` and native block transport;
- the already-landed `Tagflow.html(..., registry: ...)` path is validated in a
  real app or deliberately narrowed with migration guidance before stable;
- `TagflowOptions` compatibility posture is written as keep, deprecate, or
  remove before stable;
- `package:tagflow/legacy.dart` has a documented support window;
- native block schema-version policy is explicit for incompatible future wire
  shapes;
- unsupported native block behavior is tested and documented, including the
  current split between rejected-link neutralization and rejected-leaf
  placeholder/drop policy;
- table extension ownership and cadence are decided for beta: keep
  `tagflow_table` as a separate first-party extension, promote
  `tagflowTableComponents(...)` as the canonical high-fidelity table registry
  path, release the extension in lockstep with `tagflow` for `beta.0`, and
  allow independent patch/minor prereleases afterward only while compatible
  constraints and registry API tests stay green;
- no unreviewed performance claims are present in release-facing docs.

Beta.0 should mean "API shape is close to stable", not "every renderer feature
is complete".

Stable `1.0.0` should wait until the beta freeze decisions above have held
through prerelease adoption, benchmark gates have credible supported-target and
memory/allocation evidence, and at least one hosted real-app path has been
pushed, merged, opened through the intended route, and reviewed as release
evidence.

## 5. Runtime Model

`TagflowDocument` remains the only canonical renderer input.

Runtime responsibilities:

- hold immutable semantic nodes with stable IDs;
- preserve source and metadata for debugging, analytics, migration, and policy
  review;
- apply immutable `TagflowDocumentPatch` updates in order;
- preserve untouched branch identity where practical during patch application;
- dispatch rendering through `TagflowComponentRegistry`;
- treat view behavior such as links, selection, image loading, and error
  builders as widget/view options, not document payload semantics.

Runtime non-responsibilities:

- parsing HTML, JSON, Markdown, or CMS payloads directly;
- executing scripts, callbacks, widget constructors, or producer-supplied code;
- owning network fetch, storage, sync, conflict resolution, or cache policy;
- acting as an editor, mutable DOM, or rich-text operation engine.

Runtime API stability rules for the alpha line:

- names exported from `package:tagflow/tagflow.dart` are public alpha APIs, but
  may still change before stable with migration notes;
- `TagflowDocument`, `TagflowDocumentNode`, `TagflowDocumentPatch`,
  `TagflowContentPolicy`, `TagflowComponentRegistry`, `TagflowHtmlAdapter`,
  and native block transport types are the highest scrutiny APIs;
- `package:tagflow/legacy.dart` is compatibility support, not the future
  extension model;
- any breaking rename must include a migration note in the same change.

## 6. Transport Model

Transport is adapter-owned.

The alpha.2 native block transport should stay small:

- JSON-like maps only;
- finite numbers only;
- string-keyed objects only;
- ordered block children and ordered patch operations;
- document `id`, integer `schemaVersion`, optional `revision`, optional
  `source`, optional data-only `metadata`, and ordered `blocks`;
- patch envelope `id`, integer `schemaVersion`, optional `baseRevision`,
  optional `revision`, and ordered `operations`.

Transport does not promise:

- arbitrary Dart object serialization;
- Flutter widget serialization;
- callbacks or action closures;
- CMS sync protocol semantics;
- network retry, conflict resolution, offline storage, or cache invalidation;
- compatibility with unknown future block kinds unless that behavior is
  deliberately added and tested.

Schema-version rule:

- `schemaVersion == 1` is the only producer shape currently reviewed;
- documents and patch envelopes with any other version fail during
  `TagflowNativeBlockCodec` decode;
- beta.0 should decide whether future schema versions keep failing strictly,
  degrade through adapter policy, or route through versioned codecs.

## 7. Patch and Update Semantics

The runtime patch model stays immutable and ID-based.

Current operation set:

- replace one node by ID;
- append children to a parent ID;
- insert nodes before a sibling ID;
- remove one node by ID.

Patch rules:

- operations apply in order;
- replacement node IDs must match the target ID;
- duplicate node IDs fail;
- missing target IDs fail;
- patch transport is adapted to runtime patches before application;
- remote or generated updates must pass through adapter validation and content
  policy before they become runtime patches;
- app-authored `TagflowDocument` updates are trusted runtime input.

Deferred update features:

- rename or move operations;
- multi-operation conflict detection beyond ordered application;
- producer revision enforcement inside core runtime;
- controller-first lifecycle ownership;
- streaming HTML parsing;
- adapter parse caches.

Alpha.3 should add documentation and tests before expanding the operation set.

## 8. Renderer Boundary

The renderer boundary is semantic node kind plus registry.

Responsibilities:

- render `TagflowDocumentNode` trees into Flutter widgets;
- key rendered subtrees by node ID;
- allow app overrides and first-party extension registries;
- keep links and image behavior wired through view options;
- provide a predictable fallback for unsupported or unmapped nodes.

Non-goals:

- HTML selector matching as the future extension mechanism;
- full CSS cascade or browser layout;
- webview fallback;
- producer-defined widgets;
- table-specific mutation APIs in core.

Alpha.3 renderer decision:

- `Tagflow.html(...)` accepts a `TagflowComponentRegistry` for HTML-origin
  runtime documents;
- `TagflowHtmlAdapter(...).parse(...)` plus `Tagflow.document(...)` remains the
  path for parse-time control, authored IDs, source metadata, and strict policy.

The ergonomic widget API must keep custom legacy `ElementConverter`s on the
compatibility bridge and preserve semantic registry precedence for built-in HTML
rendering.

## 9. Content Trust Model

Trust is not inferred from source format.

Content classes:

- **Trusted runtime input:** app-authored `TagflowDocument` instances.
- **Trusted app-controlled transport:** native block JSON produced by a known
  backend or local app model and decoded through `TagflowNativeBlockCodec`.
- **Controlled HTML:** HTML from an app-owned or known producer, parsed through
  `TagflowHtmlAdapter` and `TagflowContentPolicy`.
- **Untrusted remote content:** any content from user input, arbitrary web
  pages, third-party CMS fields without validation, or model output without an
  app-controlled schema.

Rules:

- adapters apply policy before runtime document or patch creation;
- payload metadata is data, not authority;
- JSON does not receive a trust upgrade over HTML;
- URL-bearing fields are policy checked;
- executable tags, callbacks, widget constructors, and arbitrary object graphs
  are outside the contract;
- unsupported content behavior must be explicit and test-covered.

Alpha.3 should keep telling producers that placeholders are only one policy
fallback. Unknown native JSON `kind` values still fail at codec decode, known
rejected `image` blocks follow `drop` versus `preservePlaceholder`, and known
rejected `link` blocks currently neutralize into containers instead of
preserved `unsupported` nodes. Producers should not rely on those alpha
fallbacks becoming the future unknown-kind compatibility story.

## 10. Extension Points

Supported extension points:

- `TagflowComponentRegistry` for semantic rendering overrides;
- first-party registry fragments such as `tagflowTableComponents(...)`;
- `TagflowHtmlAdapter` configuration for HTML parsing, boundaries, authored
  IDs, and policy;
- `TagflowNativeBlockAdapter` for native block adaptation and policy;
- `TagflowContentPolicy` for source/tag/URL/unsupported behavior;
- app state management around immutable `TagflowDocument` and
  `TagflowDocumentPatch`.

`tagflow_table` remains the canonical first-party registry example through
beta. The beta.0 package should release in lockstep with `tagflow` to validate
the runtime-extension contract together. Later `tagflow_table` prereleases may
move independently for table-only fixes or additive renderer improvements, but
only with compatible `tagflow` constraints and passing registry API tests.

Compatibility extension points:

- legacy parser/converter/core imports through `package:tagflow/legacy.dart`;
- custom `ElementConverter`s only through the HTML compatibility path.

Deferred extension points:

- generic adapter interface;
- controller API;
- action/callback model;
- cache API;
- plugin marketplace;
- separate `tagflow_html` package.

## 11. App Integration Contract

Apps should choose one of three integration paths.

### Runtime document path

Use when the app already owns structured content in Dart.

Contract:

- build `TagflowDocument` with stable node IDs;
- render through `Tagflow.document(...)`;
- apply immutable `TagflowDocumentPatch` updates in app state;
- use `TagflowViewOptions` for link/image/selection behavior.

### Native block transport path

Use when the app receives trusted structured JSON from a known producer.

Contract:

- decode with `TagflowNativeBlockCodec`;
- adapt with `TagflowNativeBlockAdapter`;
- render with `Tagflow.document(...)`;
- decode patch envelopes with the same codec;
- adapt operations with `TagflowNativeBlockAdapter.adaptPatches(...)`;
- apply patches through `TagflowDocument.applyPatches(...)`;
- keep producer revision checks in app or backend code for now.

### Controlled HTML path

Use when the producer still emits HTML.

Contract:

- prefer `Tagflow.html(...)` for simple built-in rendering;
- use `TagflowHtmlAdapter` plus `Tagflow.document(...)` when the app needs
  authored IDs, strict ID policy, source metadata, or parse-time inspection;
- pass `registry` to `Tagflow.html(...)` when HTML-origin content only needs
  semantic component overrides;
- use `data-tagflow-id` or configured authored IDs for dynamic controlled HTML;
- keep custom `ElementConverter`s on the compatibility path only.

## 12. Explicit Non-Goals

These are not alpha.3 or beta.0 requirements:

- rename Tagflow;
- publish, push, or tag from architecture/spec work;
- package version changes without release coordination;
- arbitrary webpage rendering;
- JavaScript execution;
- webview fallback;
- arbitrary CSS support;
- rich text editing;
- generic CMS sync protocol;
- network fetch layer;
- conflict-resolution engine;
- performance claims not backed by benchmark policy and reviewed evidence;
- moving HTML to a separate package before beta-readiness decisions.

## 13. Implementation Sequence

Each slice should be independently reviewable and should avoid touching package
versions unless a coordinator explicitly starts a release thread.

### Slice 1: docs alignment for alpha.2 baseline

Files:

- `docs/specs/2026-06-11-native-rich-content-runtime.md`
- `docs/specs/2026-06-11-native-block-adapter-contract.md`
- `docs/plans/2026-06-11-tagflow-native-rich-content-master-plan.md`

Work:

- replace stale `TagflowNode` examples with `TagflowDocumentNode` where they
  describe implemented public runtime APIs;
- remove or reword alpha.1 cache requirements that conflict with later
  deliberate cache deferral;
- update the native block SPEC's deferred patch-envelope language to match
  alpha.2;
- keep benchmark claims report-only.

Acceptance:

- `git diff --check` passes;
- no package metadata changes;
- no source-code changes;
- docs clearly distinguish alpha.1 history, alpha.2 baseline, and alpha.3
  target.

### Slice 2: hosted alpha real-app native transport validation

Status: completed for the hosted-alpha3 widget-test slice in Kite, first as
evidence commit `be97da15` and then adopted locally on Kite `feat/dashboard`
as `80160401 test(ipo): validate hosted tagflow alpha3`. Production
integration and profile-mode evidence remain separate follow-up work, and the
Kite push remains blocked by `gitlab.zerodha.tech` DNS resolution.

Files:

- Kite app dependency files and a focused test fixture in the Kite repo;
- Tagflow docs only for evidence handoff if validation reveals a contract gap.

Work:

- update Kite to hosted `tagflow: ^1.0.0-alpha.3` after publication;
- keep `tagflow_table: ^1.0.0-alpha.1`;
- add a fixture that decodes a native document, adapts it, decodes a patch
  envelope, applies patches, and asserts resulting text;
- do not route production IPO rendering through native transport until the
  fixture passes.

Acceptance:

- Kite validation uses hosted packages, not a local override;
- no `pubspec_overrides.yaml` is committed;
- fixture proves document and patch transport compile and run against hosted
  alpha packages.

### Slice 3: native unknown-kind and schema-version decision

Status: completed for the alpha strict policy. Unknown producer block kinds
and unsupported schema versions fail during codec decode; rejected native image
blocks drop by default or preserve a runtime `unsupported` placeholder when
`TagflowContentPolicy.unsupportedBehavior` requests it; rejected native links
degrade to neutral containers that preserve child content with policy metadata.
A future unknown-block compatibility model remains a beta vocabulary decision,
not an alpha placeholder behavior.

Files:

- `packages/tagflow/lib/src/adapters/native_block*.dart`
- `packages/tagflow/test/src/adapters/...`
- `docs/specs/2026-06-11-native-block-adapter-contract.md`

Work:

- keep unknown producer kinds failing in the codec until beta explicitly
  introduces a versioned unknown-block representation;
- keep schema versions other than `1` failing strictly in alpha.3;
- keep tests covering the chosen document and patch payload behavior;
- document the behavior in the adapter SPEC and release-facing docs.

Acceptance:

- unknown-kind behavior is predictable from public docs;
- schema-version behavior is predictable from public docs;
- tests cover both document and patch payload paths;
- no new arbitrary widget or callback transport is introduced.

### Slice 4: HTML registry ergonomics validation

Status: completed for focused package coverage and hosted Kite alpha3
widget-test evidence. Kite commit `80160401` renders checked-in IPO HTML
fixture content through `Tagflow.html(..., registry: ...)` with
`tagflowTableComponents(...)`, while preserving production IPO rendering on the
legacy converter bridge. A follow-up isolated Kite branch,
`codex/ipo-tagflow-registry-content`, prepares content-only production rendering
through the registry path as `e26a14e6` while keeping excerpt rendering on the
legacy bridge. The branch tip now includes test cleanup `6d0d29f8`, which keeps
downstream coverage on rendered table content and public `tagflowTableComponents`
instead of low-level table widget exports. Both Kite branches remain local until
GitLab DNS access is restored, and neither is profile evidence.

Files:

- focused widget or app validation that exercises HTML-origin registry
  overrides;
- migration docs if the API changes

Work:

- keep the shipped `registry` parameter on `Tagflow.html(...)` documented as
  the simple HTML-origin semantic override path;
- preserve legacy custom-converter behavior and registry precedence;
- retain focused package widget tests for HTML built-in rendering with a
  registry override, including registry-only rebuild coverage;
- keep production migration and profile evidence as separate beta/stable gates.

Acceptance:

- apps know how to override semantic rendering for HTML-origin content;
- legacy `converters:` compatibility keeps its current behavior;
- focused package widget tests cover registry override and registry-update
  behavior for `Tagflow.html(...)`;
- hosted real-app evidence exists for the Kite IPO fixture on hosted alpha3;
- no broad parser or converter refactor lands in the same slice.

### Slice 5: beta public API freeze review

Files:

- public API export tests;
- migration docs;
- README and package docs only after API decisions are made.

Work:

- list every export from `package:tagflow/tagflow.dart`,
  `package:tagflow/legacy.dart`, and
  `package:tagflow_table/tagflow_table.dart`;
- classify each as beta-stable, alpha-only, or compatibility;
- decide `TagflowOptions` and `package:tagflow/legacy.dart` support windows;
- decide whether the HTML-node-based styling helpers that remain in the
  primary barrel stay public through beta as compatibility styling after the
  shared style primitives (`Display`, `SizeValue`, and related enums) were
  promoted onto the primary style surface;
- decide table extension package posture through beta. Current decision:
  separate first-party package through beta, lockstep `beta.0`, then
  compatible independent patch/minor prereleases only with green registry API
  tests;
- low-level `tagflow_table` render-object exports are narrowed before freeze;
  the public barrel now centers on `tagflowTableComponents(...)`,
  `TagflowTableBorder`, and legacy compatibility converters.

Acceptance:

- beta.0 readiness checklist exists;
- every compatibility surface has a written keep/deprecate/remove decision;
- no beta wording appears in release docs until the checklist is satisfied.

## 14. Recommended Next Threads

1. `test(kite): land ipo registry content branch`
   - push and merge Kite branch `codex/ipo-tagflow-registry-content` after
     `gitlab.zerodha.tech` DNS is available, then validate the real route.
2. `bench(device): qualify one physical profile target`
   - fix iOS signing/provisioning for `dev.aryak.tagflow` or attach a real
     Android profile target, then rerun the bounded one-repeat native JSON
     probe before any repeat-5 collection.
3. `bench(app): profile the hosted-alpha production surface`
   - collect profile-mode evidence for the pushed Kite production route,
     separate from widget tests and debug VM timeline probes.
4. `docs(release): prepare alpha.4 or beta gate review`
   - only after the app, device, reference-environment, and wording-policy
     gates are reviewed; do not change versions or add beta/stable wording as
     a discovery workaround.
