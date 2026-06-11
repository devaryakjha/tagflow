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
apps. Tagflow is moving toward a semantic document model rendered by native
Flutter widgets, with HTML kept as a first-party adapter.

## 📦 Packages

- [tagflow](packages/tagflow) - Core runtime, HTML adapter, content policy, and
  rendering APIs
- [tagflow_table](packages/tagflow_table) - Table rendering extension for
  Tagflow
- [examples](examples/tagflow) - Example Flutter app showcasing Tagflow features

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

# Build all packages
melos run build

# Format code
melos run format

# Analyze code
melos run analyze

# Generate coverage report
melos run coverage
```

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
