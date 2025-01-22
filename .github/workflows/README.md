# Testing GitHub Actions Workflows Locally

This guide explains how to test GitHub Actions workflows locally using [act](https://github.com/nektos/act).

## Prerequisites

1. Install `act` using Homebrew:

```bash
brew install act
```

2. Docker must be installed and running on your machine.

## Testing Package Publishing Workflow

The publishing workflow (`publish.yaml`) is triggered when a tag is pushed matching the pattern:
`tagflow*-v[0-9]+.[0-9]+.[0-9]+*`

This pattern works for all tagflow packages:

- `tagflow-v1.0.0` (core package)
- `tagflow_table-v1.0.0` (table package)
- `tagflow_any_extension-v1.0.0` (any future extension)

### Test Steps

1. Create a test event file (`.github/workflows/test-event.json`):

Example for any package:

```json
{
  "ref": "refs/tags/tagflow_your_extension-v1.0.0",
  "ref_name": "tagflow_your_extension-v1.0.0"
}
```

2. List available workflows:

```bash
act push -e .github/workflows/test-event.json --list
```

3. Dry run the workflow (recommended for testing):

```bash
act push -e .github/workflows/test-event.json --container-architecture linux/amd64 -n
```

4. Run the workflow (without actually publishing):

```bash
act push -e .github/workflows/test-event.json --container-architecture linux/amd64
```

Note: The `--container-architecture linux/amd64` flag is required for M1/M2 Macs.

### What Can Be Tested Locally

- ✅ Correct working directory selection based on tag
- ✅ Dependencies installation
- ✅ Dry-run publish step
- ❌ Actual publishing to pub.dev (requires authentication)

## Real Publishing

To publish a package:

1. Create a tag following the pattern `tagflow*-v[major].[minor].[patch]`:

```bash
# For any package
git tag tagflow_your_extension-v1.0.0
```

2. Push the tag:

```bash
git push origin <tag-name>
```

The GitHub Actions workflow will run automatically with proper pub.dev authentication.
