<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/devaryakjha/tagflow/raw/main/assets/light/logo.svg">
    <img alt="tagflow" src="https://github.com/devaryakjha/tagflow/raw/main/assets/dark/logo.svg" width="400">
  </picture>
</p>

> ⚠️ **IMPORTANT**: This package is currently undergoing a complete rewrite. For a stable version, please check out the [`stable`](https://github.com/devaryakjha/tagflow/tree/stable) branch.

> 🚧 **Alpha Release**: This package is in active development. APIs may change frequently. For production use, please wait for v1.0.0.

# tagflow

Transform HTML markup into native Flutter widgets with an elegant, customizable converter. Supports rich text formatting, lists, code blocks, and blockquotes with extensive styling options.

[![pub package](https://img.shields.io/pub/v/tagflow.svg?label=tagflow&color=orange)](https://pub.dev/packages/tagflow)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![codecov](https://codecov.io/gh/devaryakjha/tagflow/branch/main/graph/badge.svg)](https://codecov.io/gh/devaryakjha/tagflow)

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

📝 **Article-Optimized Theme**

```dart
Tagflow(
  html: articleContent,
  theme: TagflowTheme.article(
    baseTextStyle: Theme.of(context).textTheme.bodyMedium!,
    headingTextStyle: Theme.of(context).textTheme.headlineMedium!,
    codeTextStyle: GoogleFonts.spaceMonoTextTheme(context).bodyMedium,
    codeBackground: Theme.of(context).colorScheme.surfaceContainerHigh,
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

## Installation

Add `tagflow` to your `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^0.0.1-dev.6
```

## Supported Features

- 📝 **Rich Text Elements**

  - Headings (h1-h6)
  - Paragraphs
  - Lists (ordered and unordered)
  - Blockquotes
  - Code blocks
  - Inline formatting (bold, italic, underline)

- 🎨 **Styling**

  - Material Design integration
  - Custom themes
  - CSS-like style attributes
  - Flexbox layout support
  - Responsive design

- 🔗 **Interactive Elements**
  - Clickable links
  - Selectable text
  - Custom tap callbacks

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

// Article Theme
TagflowTheme.article(
  baseTextStyle: Theme.of(context).textTheme.bodyMedium!,
  headingTextStyle: Theme.of(context).textTheme.headlineMedium!,
  maxWidth: 800,
  baseFontSize: 18.0,
)
```

## Documentation

Visit our [documentation](https://docs.arya.run/tagflow) for detailed guides and examples.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
