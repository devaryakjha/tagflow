# Tagflow 1.0.0-alpha.2 Release Handoff

**Date:** 2026-06-11
**Coordinator branch:** `codex/tagflow-native-runtime-master`
**Release package:** `tagflow`
**Release version:** `1.0.0-alpha.2`
**Do not release:** `tagflow_table`

## Current State

`tagflow` is prepared for a core-only `1.0.0-alpha.2` prerelease that exposes
the native JSON transport API required by the Kite native transport fixture and
the first post-transport runtime ergonomics needed for app integration:

- `TagflowNativeBlockCodec`
- `TagflowNativeBlockAdapter`
- `TagflowNativeBlockPatchEnvelope`
- native JSON document decode/adapt/render path
- patch envelope decode/adapt/apply path
- `Tagflow.html(..., registry: ...)` for HTML-origin semantic registry
  overrides without breaking legacy custom converters
- report-only `benchmark:native-transport` lane
- report-only native JSON profile lane,
  `TAGFLOW_RENDERER=tagflow_native_json` with
  `TAGFLOW_FIXTURE=native_ai_answer`

`tagflow_table` remains at `1.0.0-alpha.1` because the native JSON transport
slice does not change the table extension package.

## Verified Gates

The coordinator has run these gates from current candidate commit `54566c8`:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run publish:dry-run
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run benchmark:native-transport
cd examples/tagflow
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter drive \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/tagflow_perf_test.dart \
  -d macos \
  --profile \
  --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false \
  --dart-define=TAGFLOW_RENDERER=tagflow_native_json \
  --dart-define=TAGFLOW_FIXTURE=native_ai_answer
```

Results:

- `validate`: passed.
- `publish:dry-run`: validated only `tagflow`; registry version
  `1.0.0-alpha.1`, local version `1.0.0-alpha.2`, `0` package warnings.
- `benchmark:native-transport`: passed and reported package version
  `1.0.0-alpha.2`.
- Native JSON profile smoke: passed on macOS profile mode. Flutter reported
  `Failed to foreground app; open returned 1`, then connected through the VM
  service and completed all tests.

The Melos `version:alpha` lane was intentionally not used for this candidate:
the coordinator branch has no upstream tracking branch, and Melos attempted
`git pull --tags -f`. A reviewed manual core-only bump was used instead.

## External State Check

Before publishing, confirm pub.dev still shows `1.0.0-alpha.1` as the latest
prerelease:

```bash
open https://pub.dev/packages/tagflow/versions
```

The package page should list latest stable `0.0.8` and latest prerelease
`1.0.0-alpha.1` until this release is actually published.

## Publish Sequence

Only run these steps after explicit coordinator approval to publish.

1. Re-run the final local checks:

   ```bash
   git status --short --branch
   PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate
   PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run publish:dry-run
   ```

2. Push the candidate commit if it is not already on GitHub:

   ```bash
   git push origin HEAD:codex/tagflow-native-runtime-master
   ```

3. Create and push only the `tagflow` tag:

   ```bash
   git tag tagflow-v1.0.0-alpha.2
   git push origin tagflow-v1.0.0-alpha.2
   ```

4. Watch the `Publish tagflow` GitHub Actions run. The workflow is triggered by
   `tagflow-v*` tags and checks that the tag name matches
   `packages/tagflow/pubspec.yaml`.

5. Verify pub.dev after the workflow completes:

   ```bash
   open https://pub.dev/packages/tagflow/versions
   ```

   Expected result: latest prerelease is `1.0.0-alpha.2`.

## Post-Publish Kite Follow-Up

After pub.dev exposes `tagflow` `1.0.0-alpha.2`, start a Kite follow-up on
`codex/kite-tagflow-alpha-runtime`:

1. Update Kite's hosted dependency to `tagflow: ^1.0.0-alpha.2`.
2. Keep `tagflow_table: ^1.0.0-alpha.1`.
3. Do not commit `pubspec_overrides.yaml`.
4. Add a test fixture that:
   - decodes trusted native JSON with `TagflowNativeBlockCodec`
   - adapts it with `TagflowNativeBlockAdapter`
   - verifies the resulting `TagflowDocument`
   - decodes a patch envelope
   - applies `adapter.adaptPatches(...)` through
     `document.applyPatches(...)`
   - asserts the patched text
5. Run Kite's repo-local validation, not the Tagflow FVM path.

Do not rewrite the IPO production rendering path for native JSON transport until
that hosted-dependency test fixture passes cleanly.
