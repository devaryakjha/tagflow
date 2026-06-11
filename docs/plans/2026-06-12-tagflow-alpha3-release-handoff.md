# Tagflow 1.0.0-alpha.3 Release Handoff

**Date:** 2026-06-12
**Coordinator branch:** `codex/tagflow-native-runtime-master`
**Release package:** `tagflow`
**Release version:** `1.0.0-alpha.3`
**Do not release:** `tagflow_table`
**Supersedes:** `docs/plans/2026-06-11-tagflow-alpha2-release-handoff.md`

## Current State

`tagflow` is prepared for a core-only `1.0.0-alpha.3` prerelease. This
candidate keeps the native rich content runtime direction from alpha.2, then
adds the contract-hardening and release-facing docs needed before real-app
workers consume the line:

- strict native transport schema `1` for decoded documents and patch envelopes
- pathful failures for unsupported native schema versions and unknown patch
  operations
- clarified unsupported-native-block handling in the HTML adapter bridge
- alpha compatibility support windows for `TagflowOptions`,
  `package:tagflow/legacy.dart`, and the first-party `tagflow_table` extension
- report-only cold/warm native JSON profile smoke evidence and named profile
  phases
- benchmark gate policy that treats alpha.2/alpha.3 as collection and
  stability gates, not public performance-claim gates

`tagflow_table` remains at `1.0.0-alpha.1`. The package stays a separate
first-party extension during beta planning, and its stronger semantic table
renderer is still consumed through `tagflowTableComponents(...)`.

## Verified Gates

Coordinator evidence from `/Users/arya/projects/tagflow` after integrating the
alpha.3 metadata candidate:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  FLUTTER_ROOT=/Users/arya/fvm/cache.git \
  dart run melos run publish:dry-run
```

Results:

- `validate`: passed analysis, format check, and coverage tests for `tagflow`,
  `tagflow_table`, and `tagflow_benchmarks`.
- `publish:dry-run`: validated only `tagflow`, with registry version
  `1.0.0-alpha.1`, local version `1.0.0-alpha.3`, and `0` package warnings.

The Melos `version:alpha` lane was intentionally not used for this candidate:
the coordinator branch has no upstream tracking branch, and earlier runs showed
Melos attempting `git pull --tags -f`. A reviewed manual core-only version bump
was used instead.

## External State Check

Before publishing, confirm pub.dev still shows `1.0.0-alpha.1` as the latest
published prerelease unless another approved publish happened first:

```bash
open https://pub.dev/packages/tagflow/versions
```

## Publish Sequence

Only run these steps after explicit coordinator approval to publish.

1. Re-run the final local checks:

   ```bash
   git status --short --branch
   PATH=/Users/arya/fvm/cache.git/bin:$PATH dart run melos run validate
   PATH=/Users/arya/fvm/cache.git/bin:$PATH \
     FLUTTER_ROOT=/Users/arya/fvm/cache.git \
     dart run melos run publish:dry-run
   ```

2. Push the candidate commit if it is not already on GitHub:

   ```bash
   git push origin HEAD:codex/tagflow-native-runtime-master
   ```

3. Create and push only the `tagflow` tag:

   ```bash
   git tag tagflow-v1.0.0-alpha.3
   git push origin tagflow-v1.0.0-alpha.3
   ```

4. Watch the `Publish tagflow` GitHub Actions run. The workflow is triggered by
   `tagflow-v*` tags and checks that the tag name matches
   `packages/tagflow/pubspec.yaml`.

5. Verify pub.dev after the workflow completes:

   ```bash
   open https://pub.dev/packages/tagflow/versions
   ```

   Expected result: latest prerelease is `1.0.0-alpha.3`.

## Post-Publish Kite Follow-Up

After pub.dev exposes `tagflow` `1.0.0-alpha.3`, start Kite validation in small
slices:

1. Update Kite's hosted dependency to `tagflow: ^1.0.0-alpha.3`.
2. Keep `tagflow_table: ^1.0.0-alpha.1`.
3. Move Kite's legacy custom converter imports to `package:tagflow/legacy.dart`.
4. Change the IPO rich-content call sites to `Tagflow.html(...)`, preserving
   `converters`, `theme`, `TagflowOptions`, `TagflowTableConverter`, render
   boundaries, and link callbacks.
5. Run Kite's repo-local validation, not the Tagflow FVM path.
6. Treat that as HTML compatibility evidence only. Any non-empty custom
   converter list intentionally routes through the legacy compatibility
   renderer.

For semantic registry evidence, use a separate experiment without legacy
custom converters:

- render IPO content through
  `Tagflow.html(..., registry: TagflowComponentRegistry(extensions: [tagflowTableComponents(...)]))`;
- preserve the production path until the experiment has screenshots or tests;
- document that `details` / `summary` behavior still needs either legacy
  converters or a first-class semantic replacement before production migration.

Do not claim public performance wins from the current benchmark evidence. The
alpha.3 benchmark posture is collection-gate only.
