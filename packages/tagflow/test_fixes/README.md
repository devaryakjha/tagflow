# Fix tests

Tests for the data-driven fixes in [`lib/fix_data.yaml`](../lib/fix_data.yaml).
Each `.dart` file uses deprecated APIs, and its `.dart.expect` file is the
same code after `dart fix --apply`. Run them from this folder:

```bash
dart fix --compare-to-golden
```

or from the repository root with `dart run melos run test:fixes`.

When you add a transform, add the old call to a `.dart` file and its migrated
form to the matching `.expect` file. The migrated code must compile.

See https://dart.dev/go/data-driven-fixes for the data file format.
