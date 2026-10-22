# Contributor guide

This is the single guide for people and coding agents working in this
repository. `CLAUDE.md` points here; keep project guidance in this file only.

## What Tagflow is

Tagflow is a native rich content runtime for Flutter. Content is described by
a typed, immutable `TagflowDocument` tree and rendered to native Flutter
widgets through a component registry. HTML is one input among several: it
goes through a first-party adapter into the same document model.

`main` carries the `1.0.0-beta` line. The `stable` branch keeps the `0.0.x`
HTML-renderer line (latest `0.0.8`) and only takes fixes.

## Workspace

A Dart pub workspace driven by Melos (root `pubspec.yaml`):

| Path | What it is |
| --- | --- |
| `packages/tagflow` | Core runtime, adapters, renderer, style and theme |
| `packages/tagflow_table` | First-party table extension (registry fragment plus legacy HTML converter) |
| `packages/tagflow_benchmarks` | Parser, render and native-transport microbenchmarks (not published) |
| `examples/tagflow` | Example app (not published) |
| `docs/specs` | Design specs for the runtime, transport, patches and API freeze |
| `docs/migration` | Migration notes for users moving between lines |

The Flutter version is pinned in `.fvmrc`. CI reads the same file, so use that
version locally (`fvm use` or a matching `flutter` on your PATH).

## Commands

Run everything from the repository root. Melos is a dev dependency, so there
is nothing to install globally.

```bash
dart pub get                      # resolve the workspace
dart run melos bootstrap          # link packages
dart run melos run validate       # analyze + format check + tests (what CI runs)
```

Narrower commands:

```bash
dart run melos run analyze        # flutter analyze --fatal-infos in every package
dart run melos run format         # dart format everything
dart run melos run test           # flutter test --coverage in every package
dart run melos run publish:dry-run
dart run melos run goldens         # golden tests only
dart run melos run goldens:update  # regenerate baselines (Linux, Flutter from .fvmrc)

# One package or one file
cd packages/tagflow && flutter test
flutter test test/src/runtime/document_patch_test.dart
```

`dart run melos run validate` must pass before a PR is ready.

## Architecture

```text
 HTML string ──► TagflowHtmlAdapter ────────┐
 native JSON ──► TagflowNativeBlockCodec    │
                 └► TagflowNativeBlockAdapter├─► TagflowDocument ─► TagflowComponentRegistry ─► widgets
 app code ──────────────────────────────────┘        ▲
                                                     └── TagflowDocumentPatch (live updates)
```

### Document model (`lib/src/runtime/`)

- `TagflowDocument` is the canonical runtime input: an id, top-level
  children, metadata and source info.
- `TagflowDocumentNode` is an immutable node with a stable string `id` and a
  `TagflowNodeKind` (paragraph, heading, list, table, codeBlock, image, link,
  unsupported and so on). Build nodes with the named constructors, for example
  `TagflowDocumentNode.paragraph(...)`.
- `TagflowPresentation` carries inline semantics and styling hints;
  `TagflowMetadata` and `TagflowSourceInfo` carry provenance.
- Node ids must be unique within a document. Patches and widget keys depend
  on them.

### Patches (`runtime/document_patch.dart`)

`TagflowDocumentPatch` has four operations: `replaceNode`, `appendChildren`,
`insertBefore` and `removeNode`. `document.applyPatch(...)` and
`document.applyPatches(...)` return a new document and throw on a missing
target or duplicate ids. Because rendering keys each node by its id,
unchanged nodes keep their widget state across patches.

### Adapters (`lib/src/adapters/`)

- **HTML.** `TagflowHtmlAdapter.parse(html)` uses the HTML parser in
  `lib/src/core/parser/` and maps the result onto document nodes.
  `Tagflow.html(html: ...)` uses it by default. `TagflowHtmlNodeIdStrategy`
  picks between path-based and attribute-based ids.
- **Native JSON.** `TagflowNativeBlockCodec` decodes and encodes trusted
  JSON envelopes. It is strict: `schemaVersion` must be `1` and unknown block
  kinds fail during decode. `TagflowNativeBlockAdapter` turns decoded blocks
  and patch envelopes into documents and `TagflowDocumentPatch`es. The
  contract is in `docs/specs/2026-06-11-native-block-adapter-contract.md`.
- New input formats should be new adapters that produce a `TagflowDocument`,
  not new render paths.

### Content policy (`runtime/content_policy.dart`)

Every adapter applies a `TagflowContentPolicy`. The defaults block `script`,
`style`, `iframe`, form controls and similar tags, allow only `http`, `https`
and `mailto` URLs, reject `data:` images, and drop unsupported content (or
keep a placeholder with `TagflowUnsupportedBehavior.preservePlaceholder`).
Keep new adapters behind the same policy.

### Rendering (`lib/src/render/`)

`TagflowComponentRegistry` maps each `TagflowNodeKind` to a builder.
Precedence is app `overrides`, then `extensions` (for example
`tagflowTableComponents()` from `tagflow_table`), then the built-ins, then the
fallback builder. Builders get a `TagflowComponentContext` and render children
with `context.render(...)` / `context.renderChildren(...)` so precedence holds
all the way down.

### Widget and options

- `Tagflow.document(document)` renders a document directly.
- `Tagflow.html(html: ...)` adapts HTML first. Passing `converters` switches
  that widget to the legacy converter renderer.
- `TagflowViewOptions` holds runtime view settings (link and node tap
  callbacks, selection, image builders, error builder). `TagflowOptions` is
  the older shape and is kept for compatibility.
- `TagflowTheme` / `TagflowThemeProvider` and `lib/src/style/` resolve styles,
  including relative units (`rem`, `em`, `%`, `vh`, `vw`) through
  `SizeValue.resolve(context)`.

### Legacy pipeline

`lib/src/converter/`, `lib/src/core/` and `package:tagflow/legacy.dart` are the
pre-runtime HTML converter pipeline (`ElementConverter`, CSS-like selector
matching, `StyledContainer`). They still ship for compatibility and are
scheduled for deprecation before 1.0. Fix bugs there, but put new features on
the document model and registry.

## Conventions

- Lints come from `analysis_options.yaml` (very_good_analysis rules, strict
  casts, inference and raw types). `flutter analyze --fatal-infos` must be
  clean.
- 80-column lines, `dart format`, package imports only.
- Document every public API with a `///` comment, and export it from the
  package barrel (`lib/tagflow.dart`). `test/src/public_api/export_test.dart`
  guards the exported surface; update it when the surface changes on purpose.
- Use `// ignore:` only with a reason next to it.
- Follow the HTML specification for HTML behavior and note any deviation in a
  code comment. For tables, the `border` attribute sets the outer border and
  adds 1px cell borders.
- Apply text scale to `fontSize` directly rather than through
  `Text.rich(textScaler: ...)`, so nested content does not compound it.

## Tests

- Tests live in `test/src/`, mirroring `lib/src/`.
- Name tests by behavior, for example
  `'should keep unchanged node state after a patch'`.
- Cover empty input, deep nesting, policy rejections and id collisions for
  anything that touches the document model, adapters or patches.

## Releases

- Each package keeps its own `CHANGELOG.md`; those are the release notes.
- Bump versions in the package `pubspec.yaml` and changelog, then push a tag:
  `tagflow-v<version>` or `tagflow_table-v<version>`. The publish workflows
  check the tag against the pubspec and publish through pub.dev OIDC.
- Run `dart run melos run publish:dry-run` before tagging.
- The plan to 1.0 is in [ROADMAP.md](ROADMAP.md).
