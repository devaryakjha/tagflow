<p align="center">
  <img src="assets/dark/icon.svg" alt="Tagflow" width="80" height="80" />
</p>

<h1 align="center">Tagflow</h1>

<p align="center">Native rich content runtime for Flutter apps, with HTML support through a first-party adapter.</p>

<p align="center">
  <a href="https://docs.arya.run/tagflow">Documentation</a>
  ·
  <a href="https://pub.dev/packages/tagflow">tagflow</a>
  ·
  <a href="https://pub.dev/packages/tagflow_table">tagflow_table</a>
</p>

<p align="center">
  <a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" /></a>
  <br />
  <a href="https://github.com/devaryakjha/tagflow/actions/workflows/ci.yml"><img src="https://github.com/devaryakjha/tagflow/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI" /></a>
</p>

> **Beta** — `1.0.0-beta.0` is the first feature-rich native runtime prerelease. APIs may still change before `1.0.0`.

## What is this?

Tagflow used to be a Flutter HTML renderer. The beta line makes it a native
rich content runtime.

Instead of forcing every dynamic screen through HTML, apps can render
structured `TagflowDocument` content directly, accept trusted JSON from a
backend or AI pipeline, validate it, render native Flutter widgets, and apply
document patches for live content updates.

HTML still works through `Tagflow.html(...)`, but it is now an adapter into
the same runtime instead of the whole model.

## Packages

- [`tagflow`](packages/tagflow) - core runtime, HTML adapter, native block
  transport, content policy, and rendering APIs
- [`tagflow_table`](packages/tagflow_table) - first-party table extension for
  semantic `TagflowDocument` table nodes and legacy HTML table compatibility
- [`examples/tagflow`](examples/tagflow) - example Flutter app and benchmark
  host

## Install

```yaml
dependencies:
  tagflow: ^1.0.0-beta.0
```

Add semantic table support when needed:

```yaml
dependencies:
  tagflow: ^1.0.0-beta.0
  tagflow_table: ^1.0.0-beta.0
```

## Usage

Render HTML through the adapter entry point:

```dart
Tagflow.html(html: htmlContent);
```

Render a native document directly:

```dart
final document = TagflowDocument(
  id: 'article',
  children: [
    TagflowDocumentNode.paragraph(
      id: 'article.intro',
      children: [
        TagflowDocumentNode.text(
          id: 'article.intro.text',
          text: 'Native rich content for Flutter.',
        ),
      ],
    ),
  ],
);

Tagflow.document(document);
```

Use trusted app-controlled JSON without round-tripping through HTML:

```dart
const codec = TagflowNativeBlockCodec();
const adapter = TagflowNativeBlockAdapter();

final nativePayload = codec.decodeDocument(nativeJson);
final document = adapter.adapt(nativePayload);

Tagflow.document(document);
```

Patch envelopes decode through the same codec, adapt with
`TagflowNativeBlockAdapter.adaptPatches(...)`, and apply with
`TagflowDocument.applyPatches(...)`.

## Stable Channel

`0.0.8` remains the stable HTML-renderer line. The `stable` branch preserves
that pre-native-runtime version for Git users.

`main` carries the native runtime prerelease line.

## Development

```bash
dart pub get
dart run melos bootstrap
dart run melos run validate
```

Common commands:

```bash
dart run melos run analyze
dart run melos run test
dart run melos run format
dart run melos run publish:dry-run
```

## Project Structure

```text
packages/tagflow/             Core runtime and HTML adapter
packages/tagflow_table/       First-party table extension
packages/tagflow_benchmarks/  Benchmark and release-gate tooling
examples/tagflow/             Example app, routes, and profile host
docs/                         Specs, migration notes, and release evidence
```

## Releases

Package publication is handled by GitHub Actions tag workflows:

- `tagflow-v*` publishes `packages/tagflow`
- `tagflow_table-v*` publishes `packages/tagflow_table`

Run `dart run melos run publish:dry-run` before cutting tags.

## License

[MIT](LICENSE)
