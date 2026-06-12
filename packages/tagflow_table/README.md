<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/light/logo.svg">
    <img alt="tagflow" src="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg" width="400">
  </picture>
</p>

[![pub package](https://img.shields.io/pub/v/tagflow_table.svg)](https://pub.dev/packages/tagflow_table)
[![codecov](https://codecov.io/gh/devaryakjha/tagflow/graph/badge.svg)](https://codecov.io/gh/devaryakjha/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

> ⚠️ **Alpha prerelease**: `tagflow_table` `1.0.0-alpha.1` is aligned with
> the Tagflow native rich content runtime alpha line. APIs may change before
> the stable `1.0.0` release.

# tagflow_table

A first-party table rendering extension for Tagflow. The alpha package remains
compatible with the HTML adapter and legacy converter bridge while Tagflow moves
toward a semantic rich content runtime.

## ✨ Features

- Integration with the `tagflow` `1.0.0-alpha.3` runtime package
- Semantic registry integration for native `TagflowDocument` table nodes
- HTML table converter compatibility through `package:tagflow/legacy.dart`
- Support for complex table structures, headers, and merged cells
- Customizable table borders, spacing, separators, and header backgrounds
- A focused beta-facing API centered on semantic registry extensions

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tagflow: ^1.0.0-alpha.3
  tagflow_table: ^1.0.0-alpha.1
```

## Beta posture

`tagflow_table` remains a separate first-party extension package through the
Tagflow beta line. Use `tagflowTableComponents(...)` as the canonical
high-fidelity table registry extension for native `TagflowDocument` table
nodes. `TagflowTableBorder` remains the public configuration type for that
semantic path.

The legacy HTML converter bridge remains publicly available for compatibility:
`TagflowTableConverter` and `TagflowTableCellConverter`.

Low-level render-object classes such as `TagflowTable`, `TableCell`,
`RenderTagflowTable`, and `TableCellData` are package internals rather than the
beta extension contract.

The package's current `tagflow: ^1.0.0-alpha.1` dependency constraint is
intentionally compatible with the `tagflow` alpha prerelease line while the
core runtime moves through alpha. Apps should use the latest reviewed core
alpha, currently `tagflow: ^1.0.0-alpha.3`, with
`tagflow_table: ^1.0.0-alpha.1`. For `1.0.0-beta.0`, `tagflow_table` should
release in lockstep
with `tagflow` to validate the runtime-extension contract together. After
`beta.0`, table-only patch or minor prereleases may move independently only
when the `tagflow` constraint remains compatible with the current beta runtime
and semantic registry API tests stay green.

## 🚀 Usage

Native runtime code can install the first-party table registry fragment:

```dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

class NativeTableArticle extends StatelessWidget {
  const NativeTableArticle({required this.document, super.key});

  final TagflowDocument document;

  @override
  Widget build(BuildContext context) {
    return Tagflow.document(
      document,
      registry: TagflowComponentRegistry(
        extensions: [
          tagflowTableComponents(
            border: TagflowTableBorder.all(color: const Color(0x1F000000)),
            columnSpacing: 8,
          ),
        ],
      ),
    );
  }
}
```

HTML input should enter through `Tagflow.html(...)`. Existing table-converter
integrations remain available through the alpha legacy converter bridge:

```dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

class TableArticle extends StatelessWidget {
  const TableArticle({super.key});

  static const html = '''
    <table>
      <tr>
        <th>Header 1</th>
        <th>Header 2</th>
      </tr>
      <tr>
        <td>Cell 1</td>
        <td>Cell 2</td>
      </tr>
    </table>
  ''';

  @override
  Widget build(BuildContext context) {
    return Tagflow.html(
      html: html,
      converters: const [
        TagflowTableConverter(),
      ],
    );
  }
}
```

For parser, converter, selector, and legacy node compatibility APIs, import:

```dart
import 'package:tagflow/legacy.dart';
```

New Tagflow runtime code should prefer `package:tagflow/tagflow.dart`,
`Tagflow.document(...)`, `Tagflow.html(...)`, and semantic registry APIs where
available. The legacy `ElementConverter` path remains available during the
alpha transition, but new native document integrations should prefer
`tagflowTableComponents(...)`.

## 🎨 Customization

You can customize table appearance using TagflowTheme. There are several ways to do this:

### 🔧 Using TagflowTheme.fromTheme

```dart
final theme = TagflowTheme.fromTheme(
  Theme.of(context),
  additionalStyles: {
    'table': TagflowStyle(
      border: Border.all(color: Colors.grey),
      margin: EdgeInsets.all(16),
    ),
    'th': TagflowStyle(
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.all(8),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    'td': TagflowStyle(
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
    ),
  },
);
```

### 📝 Using TagflowTheme.article

```dart
final theme = TagflowTheme.article(
  baseTextStyle: Theme.of(context).textTheme.bodyMedium!,
  headingTextStyle: Theme.of(context).textTheme.headlineMedium!,
  additionalStyles: {
    'table': TagflowStyle(
      maxWidth: 800,
      border: Border.all(color: Colors.grey[300]!),
      margin: EdgeInsets.symmetric(vertical: 16),
    ),
  },
);
```

### ⚙️ Using TagflowTheme.raw

For complete control over styling:

```dart
final theme = TagflowTheme.raw(
  styles: {
    'table': TagflowStyle(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
      margin: EdgeInsets.all(16),
      backgroundColor: Colors.grey[50],
    ),
    'th': TagflowStyle(
      padding: EdgeInsets.all(12),
      backgroundColor: Colors.blue[50],
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
    ),
    'td': TagflowStyle(
      padding: EdgeInsets.all(12),
      alignment: Alignment.center,
      borderBottom: BorderSide(color: Colors.grey[300]!),
    ),
    'tr:hover': TagflowStyle(
      backgroundColor: Colors.blue[50]!.withOpacity(0.3),
    ),
  ),
  defaultStyle: TagflowStyle(
    textStyle: TextStyle(fontSize: 14),
  ),
  namedColors: {
    'table-border': Colors.grey[300]!,
    'table-header': Colors.blue[50]!,
  },
);
```

You can apply the theme using `Tagflow.html(...)`:

```dart
TagflowThemeProvider(
  theme: theme,
  child: Tagflow.html(
    html: htmlContent,
    converters: const [
      TagflowTableConverter(),
    ],
  ),
);
```

## 👥 Contributing

Contributions are welcome! Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
