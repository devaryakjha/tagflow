<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/light/logo.svg">
    <img alt="tagflow" src="assets/dark/logo.svg" width="400">
  </picture>
</p>

> ⚠️ **IMPORTANT**: This package is currently undergoing a complete rewrite. For a stable version, please check out the [`stable`](https://github.com/devaryakjha/tagflow/tree/stable) branch.

> 🚧 **Alpha Release**: This package is in active development. APIs may change frequently. For production use, please wait for v1.0.0.

# tagflow

Transform HTML markup into native Flutter widgets with an elegant, customizable converter. Supports tables, iframes, and other HTML elements through optional add-on packages.

[![pub package](https://img.shields.io/pub/v/tagflow.svg?label=tagflow&color=orange)](https://pub.dev/packages/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

---

## Feature Highlights

🚀 **Simple Integration**

```dart
class MyHtmlWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tagflow(
      html: '<div>Hello, Flutter!</div>',
    );
  }
}
```

🎨 **Material Design Integration**

```dart
Tagflow(
  html: htmlContent,
  theme: TagflowTheme.fromTheme(
    Theme.of(context),
    headingConfig: TagflowHeadingConfig(
      baseSize: 16.0,
      scales: [2.5, 2.0, 1.75, 1.5, 1.25, 1.0],
    ),
  ),
)
```

🎯 **CSS-like Styling**

```html
<div
  style="
    display: flex;
    flex-direction: column;
    gap: 16px;
    padding: 24px;
    background-color: var(--surface-container);
    border-radius: 8px;
  "
>
  <h1
    style="
      color: var(--on-surface);
      font-size: 2rem;
      margin: 0;
    "
  >
    Material Design
  </h1>
  <p class="highlight">Seamlessly integrates with your app's theme</p>
</div>
```

📦 **Custom Themes**

```dart
Tagflow(
  html: htmlContent,
  theme: TagflowTheme(
    defaultStyle: TagflowStyle(
      textStyle: TextStyle(fontSize: 16),
      padding: EdgeInsets.all(8),
    ),
    styles: {
      'h1': TagflowStyle(
        textStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        margin: EdgeInsets.symmetric(vertical: 16),
      ),
      '.highlight': TagflowStyle(
        backgroundColor: Colors.yellow.withOpacity(0.3),
        padding: EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(4),
      ),
    },
    namedColors: {
      'brand': Colors.purple,
      'accent': Colors.amber,
    },
  ),
)
```

## Installation

Add `tagflow` to your `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^1.0.0
```

## Theme System

Tagflow's theme system seamlessly integrates with Flutter's Material Design while providing powerful customization options:

- 🎨 **Material Integration**: Automatically uses your app's theme colors and typography
- 🔧 **Custom Styling**: Define styles for specific HTML elements and CSS classes
- 📏 **Responsive Units**: Supports rem, em, and percentage-based units
- 🎯 **CSS Features**: Flexbox layout, borders, shadows, and more
- 🌈 **Color System**: Use theme colors or define custom color palettes

### Theme Configuration

```dart
// Use Material Theme
TagflowTheme.fromTheme(
  Theme.of(context),
  spacingConfig: TagflowSpacingConfig(
    baseSize: 16.0,
    scale: 1.2,
  ),
)

// Basic Theme
TagflowTheme.basic(
  textStyle: TextStyle(fontSize: 16),
  padding: EdgeInsets.all(8),
)

// Minimal Theme
TagflowTheme.minimal(
  baseStyle: TextStyle(fontSize: 16),
  linkColor: Colors.blue,
)
```

## Documentation

Visit our [documentation](https://docs.arya.run/tagflow) for detailed guides and examples.

## Add-on Packages

- WIP
