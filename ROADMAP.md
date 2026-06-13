# Tagflow Development Roadmap

## v1 Alpha Runtime Direction

- [x] Native `TagflowDocument` model as the canonical runtime input
- [x] HTML adapter through `TagflowHtmlAdapter` and `Tagflow.html(...)`
- [x] Direct native document rendering through `Tagflow.document(...)`
- [x] Content policy for unsafe HTML tags, URL schemes, images, and fallbacks
- [x] Semantic component registry for built-in renderer overrides
- [x] Runtime view options separated from HTML adapter compatibility options
- [x] Legacy compatibility barrel at `package:tagflow/legacy.dart`
- [x] Alpha benchmark harness for fixtures, parser, and widget render baselines
- [ ] Stable `1.0.0` API guarantees
- [ ] Separate adapter packages beyond first-party HTML support
- [ ] Production-grade benchmark comparisons and profile-mode frame timing

## Core Architecture

- [x] Basic HTML parsing using `html` package
- [x] Element model with attributes support
- [x] Converter system with plugin architecture
- [x] Style resolution system
- [x] Theme provider implementation
- [x] Options scope for configuration
- [x] Native runtime document model
- [x] HTML adapter layer
- [x] Semantic component registry
- [x] Error boundary implementation for graceful fallbacks

## HTML Element Support

- [x] Block Elements

  - [x] Paragraphs (`<p>`)
  - [x] Headings (`<h1>` to `<h6>`)
  - [x] Divisions (`<div>`)
  - [x] Articles (`<article>`)
  - [x] Sections (`<section>`)

- [x] Text Elements

  - [x] Basic text nodes
  - [x] Emphasis (`<em>`, `<i>`)
  - [x] Strong (`<strong>`, `<b>`)
  - [x] Code (`<code>`, `<pre>`)
  - [x] Subscript/Superscript (`<sub>`, `<sup>`)
  - [x] Quotes (`<blockquote>`, `<q>`)

- [x] Lists

  - [x] Unordered lists (`<ul>`, `<li>`)
  - [x] Ordered lists (`<ol>`, `<li>`)
  - [x] Description lists (`<dl>`, `<dt>`, `<dd>`)

- [ ] Tables

  - [x] Basic table structure
  - [x] Table headers
  - [x] Colspan/Rowspan support
  - [ ] Responsive table layout

- [ ] Media
  - [x] Images with `NetworkImage`
  - [ ] Responsive image sizing
  - [ ] Image loading states
  - [ ] Lazy loading implementation

## Styling System

- [x] Base style implementation
- [x] Element-specific styles
- [x] Class-based styling
- [x] Inline style parsing
- [ ] CSS-like Features
  - [x] Pseudo-classes (:first-child, :last-child, etc.)
  - [ ] Media queries support
  - [ ] Attribute selectors
  - [ ] State management (hover, focus, etc.)
  - [ ] CSS variables (custom properties)
  - [x] Cascade selectors (parent > child)
  - [ ] Animation/transition support
- [ ] Advanced CSS Properties
  - [ ] Flexbox layout
  - [ ] Grid layout
  - [ ] Border radius
  - [ ] Box shadow
  - [ ] Transforms
  - [ ] Transitions (where applicable)

## Performance Optimization

- [x] Alpha parser and widget render benchmark harness
- [x] Example-app profile benchmark scaffold for Tagflow frame timings
- [ ] Widget recycling for long content
- [ ] Lazy parsing for large documents
- [ ] Memory optimization for large DOMs
- [ ] Render optimization
  - [ ] `RepaintBoundary` strategic placement
  - [ ] `const` widget optimization
  - [ ] Custom `RenderObject` for complex layouts

## Interactive Features

- [x] Basic link handling
- [ ] Advanced Interaction
  - [x] Custom tap handlers per element type
  - [ ] Long press actions
  - [ ] Gesture recognition
  - [ ] Selection support
  - [ ] Copy/paste functionality

## Plugin System

- [x] Semantic component registry implementation
- [x] First-party table extension registry fragment for semantic document tables
- [ ] Full table extension migration off the legacy HTML converter bridge
- [ ] Hot-reload safe plugin loading
- [ ] Default Plugin Set
  - [ ] Code syntax highlighting
  - [ ] LaTeX rendering
  - [ ] Social media embeds
  - [ ] Video player integration

## Testing & Documentation

- [x] Core unit tests
- [x] Widget tests for base components
- [ ] Integration tests
- [ ] Golden tests for visual regression
- [x] Alpha performance benchmark harness
- [x] API Documentation
  - [x] Dart doc comments
  - [ ] Usage examples
  - [x] Migration guides
  - [ ] Best practices

## Developer Experience

- [x] Melos workspace setup
- [ ] Example App
  - [ ] Interactive demo
  - [x] Performance profiling page scaffold
  - [ ] Theme playground
  - [ ] Plugin showcase
- [ ] Dev Tools
  - [ ] Element inspector
  - [ ] Style debugger
  - [ ] Performance monitor
  - [ ] Error reporting

## CI/CD

- [x] GitHub Actions workflow
- [x] Automated testing
- [x] Code coverage reporting
- [x] Release automation
- [x] Package publishing
- [x] Version management
- [x] Changelog generation

## Optimization & Refinement

- [ ] Tree-shaking support
- [ ] Dead code elimination
- [ ] Size optimization
- [ ] Startup time optimization
- [ ] Memory leak detection
- [ ] Performance monitoring
