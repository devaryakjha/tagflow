<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

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

> ⚠️ **IMPORTANT**: This package is currently in development and is part of the Tagflow ecosystem. For production use, please wait for v1.0.0.

> 🚧 **Alpha Release**: APIs may change frequently. Use with caution in production environments.

# tagflow_table

A Flutter package that provides enhanced HTML table rendering capabilities for the Tagflow HTML rendering engine.

## ✨ Features

- 🔄 Seamless integration with Tagflow core package
- 📊 Support for complex table structures
- 🎨 Customizable table styling
- 📱 Responsive table layouts
- 🏷️ Support for table headers, footers, and merged cells
- 🖼️ Border customization options
- 🎯 Background color support

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tagflow_table: ^0.0.1
```

## 🚀 Usage

```dart
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() {
  final html = '''
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

  final tagflow = Tagflow(
    converters: [
      TableConverter(),
      // ... other converters
    ],
  );

  final widget = tagflow.toWidget(html);
}
```

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

You can apply the theme using TagflowThemeProvider:

```dart
TagflowThemeProvider(
  theme: theme,
  child: Tagflow(
    converters: [
      TableConverter(),
      // ... other converters
    ],
    html: htmlContent,
  ),
);
```

## 👥 Contributing

Contributions are welcome! Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
