<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/light/logo.svg">
    <img alt="tagflow" src="assets/dark/logo.svg" width="400">
  </picture>
</p>

> ⚠️ **IMPORTANT**: This package is currently undergoing a complete rewrite. For a stable version, please check out the [`stable`](https://github.com/devaryakjha/tagflow/tree/stable) branch.

# tagflow

Transform HTML markup into native Flutter widgets with an elegant, customizable converter. Supports tables, iframes, and other HTML elements through optional add-on packages.

[![pub package](https://img.shields.io/pub/v/tagflow.svg)](https://pub.dev/packages/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

---

## Feature Highlights

🚀 **Simple Integration**

```dart
final widget = Tagflow().convert(
  '<div>Hello, Flutter!</div>'
);
```

🎨 **Customizable Styling**

```dart
final widget = Tagflow(
  style: TagflowStyle(
    textStyle: TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  ),
).convert(htmlString);
```

📦 **Optional Add-ons**

```dart
final widget = Tagflow(
  plugins: [
    TagflowTablePlugin(),
    TagflowIframePlugin(),
  ],
).convert(complexHtmlString);
```

## Installation

Add `tagflow` to your `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^1.0.0
```

## Documentation

Visit our [documentation](https://docs.tagflow.dev) for detailed guides and examples.

## Add-on Packages

- `tagflow_table` - Enhanced table support
- `tagflow_iframe` - IFrame rendering capabilities
- `tagflow_media` - Media element handling
