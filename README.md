<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/light/logo.svg">
    <img alt="tagflow" src="assets/dark/logo.svg" width="400">
  </picture>
</p>

# 🌊 Tagflow Monorepo

[![codecov](https://codecov.io/gh/devaryakjha/tagflow/graph/badge.svg)](https://codecov.io/gh/devaryakjha/tagflow)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

This is the monorepo for Tagflow, a native rich content runtime for Flutter
apps. The `1.0.0-alpha.x` prerelease line makes `TagflowDocument` the primary
runtime model, renders structured content with native Flutter widgets, and
keeps HTML as a first-party adapter through `TagflowHtmlAdapter` and
`Tagflow.html(...)`.

The native-runtime line is intentionally breaking and prerelease-only. Do not
promote it to beta or stable until the public API freeze review, benchmark
evidence gates, package-owned route evidence, and release approval are
reviewed and explicitly accepted.

## 📦 Packages

- [tagflow](packages/tagflow) - Core runtime, HTML adapter, content policy, and
  rendering APIs
- [tagflow_table](packages/tagflow_table) - Table rendering extension for
  Tagflow
- [examples](examples/tagflow) - Example Flutter app showcasing Tagflow features

## Alpha Usage

Install the alpha package:

```yaml
dependencies:
  tagflow: ^1.0.0-alpha.3
```

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

Trusted app-controlled JSON can use the native block transport instead of
round-tripping through HTML:

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

Runtime interactions stay view-owned: use
`TagflowViewOptions.nodeTapCallback` plus `tapTargetKinds` for tappable
semantic nodes, while links continue to use `linkTapCallback`.

Parser, converter, selector, and legacy node APIs remain available during the
alpha transition from `package:tagflow/legacy.dart`.

## 🛠️ Development

This project uses [Melos](https://melos.invertase.dev) for managing the monorepo.

### Setup

1. Install Melos:

```bash
dart pub global activate melos
```

2. Bootstrap the workspace:

```bash
melos bootstrap
```

### Common Tasks

```bash
# Run all tests
melos run test

# Clean build outputs
melos run build:clean

# Format code
melos run format

# Analyze code
melos run analyze

# Generate coverage report
melos run coverage
```

### Release Prep

```bash
# Mutate package versions for the next alpha, then run publish validation
make release-alpha

# Validate the current publishable package metadata without publishing
make publish-dry-run
```

Do not publish from local release-prep branches. Actual package publication is
handled by the package-specific GitHub Actions tag workflows.

## 🧪 Testing

We maintain high test coverage to ensure reliability:

- Unit tests for core functionality
- Widget tests for UI components
- Integration tests for end-to-end flows

View our latest coverage report [here](https://codecov.io/gh/devaryakjha/tagflow).

## 👥 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
