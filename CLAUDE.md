# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tagflow is a Flutter HTML rendering engine that transforms HTML markup into native Flutter widgets. It's a monorepo managed with Melos containing multiple packages:

- `packages/tagflow` - Core HTML-to-Flutter converter package
- `packages/tagflow_table` - Table rendering extension
- `examples/tagflow` - Example Flutter application

## Development Commands

### Initial Setup
```bash
# Install Melos globally
dart pub global activate melos

# Bootstrap the workspace (run dependencies for all packages)
melos bootstrap
```

### Testing
```bash
# Run all tests across packages
melos run test

# Run tests with coverage
melos run coverage

# Run tests for a single package (from package directory)
cd packages/tagflow && flutter test

# Run a specific test file
flutter test test/src/converter/converters/text_converter_test.dart
```

### Code Quality
```bash
# Format all Dart files
melos run format

# Check if files are formatted
melos run format:check

# Run static analysis
melos run analyze

# Run all validations (analyze + format + test)
melos run validate

# Run all static analysis checks
melos run lint:all
```

### Building & Publishing
```bash
# Clean all build outputs
melos run build:clean

# Version packages with dev tag
melos run version:dev

# Version packages for stable release
melos run version:stable

# Publish all packages (requires confirmation)
melos run publish

# Publish individual package (from package directory)
cd packages/tagflow && dart pub publish
```

### Makefile Shortcuts
```bash
# Run tests
make test

# Format code
make format

# Full release process (test, format, version, publish)
make release

# Dev release (test, format, version:dev, publish)
make release-dev
```

## Architecture

### Three-Layer Processing Pipeline

Tagflow follows a three-stage pipeline for converting HTML to Flutter widgets:

1. **Parsing Layer** (`lib/src/core/parser/`)
   - `TagflowParser` - Main parser that orchestrates HTML document parsing
   - `NodeParser` - Abstract base class for specialized parsers
   - `ElementParser` - Default parser for standard HTML elements
   - `ImgParser` - Specialized parser for image elements
   - `TableParser` - Specialized parser for table structures
   - Output: `TagflowNode` tree (immutable node representation)

2. **Style Layer** (`lib/src/style/`)
   - `TagflowStyle` - Style configuration with support for relative units (rem, em, %, vh, vw)
   - `StyleParser` - CSS-like property parser (colors, sizes, borders, shadows, transforms)
   - `TagflowTheme` - Theme system with Material Design integration
   - `TagflowThemeProvider` - InheritedWidget for theme propagation
   - Handles style resolution and inheritance through the node tree

3. **Conversion Layer** (`lib/src/converter/`)
   - `TagflowConverter` - Main converter coordinating all element converters
   - `ElementConverter<T>` - Abstract base with CSS-like selector matching (supports !, >, :first-child, :last-child)
   - Built-in converters:
     - `TextConverter` - Base converter for text elements (p, span, h1-h6, strong, em, a, etc.)
     - `ListConverter` / `ListItemConverter` - Ordered/unordered lists
     - `BlockquoteConverter` - Blockquotes
     - `CodeConverter` - Code blocks
     - `ContainerConverter` - Divs and generic containers
     - `ImgConverter` - Images with loading/error states
     - `TableConverter` - Table structures
   - Output: Flutter `Widget` tree

### Key Design Patterns

**Node Reparenting**: After initial parsing, `TagflowNode.reparent()` establishes bidirectional parent-child relationships throughout the tree, enabling ancestor queries and context-aware styling.

**Selector Matching**: Converters use CSS-like selectors:
- `"p"` - Simple tag match
- `"ul > li"` - Direct child selector
- `"blockquote footer"` - Ancestor-descendant selector
- `"!ul > li"` - Negation selector
- `"p:first-child"` - Pseudo-selectors

**Style Resolution**: Styles cascade through the tree with `resolveStyle(element, context)` combining:
1. Theme default styles
2. Tag-specific theme styles
3. CSS class styles
4. Inline styles
5. Element-specific overrides

**Text Scale Factor Handling**: Applied directly to fontSize rather than using Text.rich's textScaler parameter to prevent compounding in nested elements (critical for nested lists).

## Important Patterns & Conventions

### When Adding HTML Element Support

1. Follow standard HTML specifications for element behavior
2. For table elements, the `border` attribute affects outer border width and adds 1px borders to cells
3. Document any deviations from standard HTML behavior in code comments
4. Add comprehensive test cases covering edge cases

### Style Parser Considerations

- `SizeValue` represents sizes with units (px, pt, rem, em, %, vh, vw)
- Use `SizeValue.resolve(context)` to convert relative units to pixels at render time
- `parseSize()` returns only absolute pixel values (null for relative values)
- `parseSizeValue()` returns a `SizeValue` object that can be resolved later

### Converter Implementation

When creating custom converters:

1. Extend `ElementConverter<TagflowElement>` or `TextConverter` for text-based elements
2. Override `supportedTags` with CSS-like selectors
3. Use `resolveStyle(element, context)` to get computed styles
4. For text elements, apply text scale factors in `getTextStyle()` by modifying fontSize directly
5. Use `StyledContainer` to wrap widgets that need styling (padding, margin, borders, etc.)

### Testing Patterns

- Place tests in `test/src/` mirroring the `lib/src/` structure
- Use descriptive test names: `'should render nested ordered lists with correct text scaling'`
- Test edge cases like empty nodes, deeply nested structures, and style inheritance
- Mock converters and parsers when testing specific components in isolation

## Code Style Standards

- Follow Dart Style Guide and use `dart format`
- Analysis rules defined in `analysis_options.yaml` (very_good_analysis)
- Line length limit: 80 characters
- Use `// ignore_for_file:` only when absolutely necessary with justification
- All public APIs must have documentation comments

## Package Structure

```
lib/
├── src/
│   ├── converter/          # Widget conversion layer
│   │   ├── converter.dart  # Main converter & base classes
│   │   ├── converters/     # Built-in element converters
│   │   └── styled_container.dart  # Container with style application
│   ├── core/
│   │   ├── models/         # Node, Element, Style data models
│   │   ├── parser/         # HTML parsing to TagflowNode tree
│   │   └── utils/          # Extensions and utilities
│   ├── style/              # Style system (theme, parser, types)
│   ├── widgets/            # Reusable widgets
│   ├── tagflow_widget.dart # Main Tagflow widget
│   └── tagflow_options.dart # Configuration options
└── tagflow.dart            # Public API exports
```

## Current Development Status

- **Alpha Release**: APIs may change frequently
- Active development targeting v1.0.0 for production stability
- Maintains high test coverage (tracked on Codecov)
- Follows semantic versioning with -dev prerelease tags

## Related Documentation

- [Tagflow Documentation](https://docs.arya.run/tagflow)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)
