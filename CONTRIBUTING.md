# Contributing to Tagflow

We love your input! We want to make contributing to Tagflow as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://docs.github.com/en/get-started/using-github/github-flow)

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure `dart run melos run validate` passes.
5. Make sure your code follows the existing style.
6. Issue that pull request!

## Architecture and Workflow

Read [AGENTS.md](AGENTS.md) first. It covers the runtime architecture
(`TagflowDocument`, adapters, content policy, component registry, patches),
the workspace commands, and the conventions reviewers check for.

## Code Style and Standards

### Dart Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use the provided analysis_options.yaml
- Run `dart format` before committing
- Ensure there are no analyzer warnings

### HTML Support Standards

When adding support for HTML elements and attributes:

1. Follow standard HTML specifications
2. Implement attributes according to their standard behavior
   - Example: table `border` attribute affects outer border width and adds 1px borders to cells
3. Document any deviations from standard HTML behavior
4. Add appropriate test cases

### Golden Tests

Golden tests (tagged `golden`) render every built-in node kind in light and
dark themes and compare the result pixel by pixel against PNG baselines:

- `packages/tagflow/test/goldens/` covers the core node kinds.
- `packages/tagflow_table/test/goldens/` covers `tagflow_table`.

They use bundled fonts from `packages/tagflow/test/goldens/fonts/` so text is
legible and stable. Baselines are rendered on Linux with the Flutter version in
`.fvmrc`, which is what CI runs; other platforms anti-alias text differently
and will report small diffs, so regenerate baselines on Linux (or in a Linux
container) only.

```bash
# Run only the golden tests
dart run melos run goldens

# Regenerate baselines after an intentional visual change
dart run melos run goldens:update

# Skip goldens locally on macOS or Windows
flutter test --exclude-tags golden
```

When a golden fails, Flutter writes the diff images to a `failures/` folder
next to the test. Review regenerated PNGs in the pull request diff before
merging.

### Package Structure

- Keep core functionality in the `tagflow` package
- Place specialized widgets in their respective packages (e.g., `tagflow_table`)
- Maintain backward compatibility when possible

## License

By contributing, you agree that your contributions will be licensed under its MIT License.

## References

- [HTML Table Element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
