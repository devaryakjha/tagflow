# Tagflow Monorepo

This is the monorepo for the Tagflow project, a Flutter HTML rendering engine.

## Packages

- [tagflow](packages/tagflow) - Core package for rendering HTML in Flutter
- [examples](examples/tagflow) - Example Flutter app showcasing Tagflow features

## Development

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
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
