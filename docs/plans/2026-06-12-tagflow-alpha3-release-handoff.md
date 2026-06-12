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
- first-class semantic registry rendering for HTML `details` / `summary` as
  native disclosure widgets, including `open` attribute handling, mixed inline
  summary content, no-summary fallback, and legacy bridge round-trip coverage

`tagflow_table` remains at `1.0.0-alpha.1`. The package stays a separate
first-party extension during beta planning, and its stronger semantic table
renderer is still consumed through `tagflowTableComponents(...)`.

## Verified Gates

Coordinator evidence from `/Users/arya/projects/tagflow` after integrating the
alpha.3 metadata candidate and the HTML disclosure runtime slice through
`4d1aeca`:

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
- Focused disclosure coverage also passed through the full validation gate:
  `Tagflow.html(...)` and `Tagflow.document(...)` tests cover closed-by-default
  details, `open` initial expansion, mixed inline summary content, no-summary
  fallback, and `TagflowHtmlDocumentBridge` round-tripping `details open` /
  `summary` tags.

The Melos `version:alpha` lane was intentionally not used for this candidate:
the coordinator branch has no upstream tracking branch, and earlier runs showed
Melos attempting `git pull --tags -f`. A reviewed manual core-only version bump
was used instead.

## External State Check

The approved publish completed successfully:

- Branch pushed: `codex/tagflow-native-runtime-master`
- Published commit: `7f5d3ae4f2cc7837edd44f9b26a3720c72aae240`
- Published tag: `tagflow-v1.0.0-alpha.3`
- GitHub Actions run:
  `https://github.com/devaryakjha/tagflow/actions/runs/27372720018`
- Workflow result: `Publish tagflow` completed with conclusion `success`
- pub.dev accepted `tagflow` `1.0.0-alpha.3` at
  `2026-06-11T19:41:08.272476Z`
- Hosted resolver check:
  `dart pub cache add tagflow --version 1.0.0-alpha.3` resolved the published
  package

`tagflow_table` was not tagged or released as part of this handoff.

## Package Discovery Posture

The native runtime line is published only as a prerelease. As of the
2026-06-12 coordinator check, the pub.dev package API still reports stable
`tagflow` `0.0.8` as the default `latest` release and stable `tagflow_table`
`0.0.4+5` as the default `latest` release. Those stable versions carry the
older HTML-renderer and pluggable-table package descriptions, so pub.dev search
results and the default package pages can look HTML-first even though
`1.0.0-alpha.3` and `1.0.0-alpha.1` are available through the prerelease
version list.

Downstream validation must therefore depend explicitly on the native runtime
prerelease line:

```yaml
dependencies:
  tagflow: ^1.0.0-alpha.3
  tagflow_table: ^1.0.0-alpha.1
```

Do not promote Tagflow to beta or stable only to fix package-page discovery.
The beta/stable evidence gates still apply: production-route integration,
supported-target profile evidence, memory/allocation review, and public API
freeze review must remain separate release decisions.

## Publish Sequence

These are the steps that were run after coordinator approval.

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
   python3 - <<'PY'
   import json, urllib.request

   req = urllib.request.Request(
       'https://pub.dev/api/packages/tagflow',
       headers={'cache-control': 'no-cache'},
   )
   with urllib.request.urlopen(req, timeout=20) as response:
       payload = json.load(response)

   print([
       version['version']
       for version in payload['versions']
       if version['version'].startswith('1.0.0-alpha')
   ])
   PY
   PATH=/Users/arya/fvm/cache.git/bin:$PATH \
     dart pub cache add tagflow --version 1.0.0-alpha.3
   ```

   Result: pub.dev listed `1.0.0-alpha.3` and the hosted resolver reported the
   package as available. The API still reports stable `0.0.8` as `latest`,
   which is expected while the `1.0.0` line is prerelease-only.

## Post-Publish Kite Follow-Up

Kite hosted-alpha validation completed in isolated worktree
`/Users/arya/.codex/worktrees/cf2b/kite` at commit
`be97da15 test(ipo): validate hosted tagflow alpha3`.

The slice updated Kite to hosted `tagflow: ^1.0.0-alpha.3` and hosted
`tagflow_table: 1.0.0-alpha.1`, moved the legacy custom converter import to
`package:tagflow/legacy.dart`, and added focused IPO widget coverage around a
real Afcons IPO payload fixture. The worker also added a converter-free
`Tagflow.html(...)` test using
`TagflowComponentRegistry(extensions: [tagflowTableComponents(...)])` so
alpha3's built-in `details` / `summary` disclosure renderer is exercised in a
downstream Flutter app.

Validation evidence:

1. `fvm flutter pub get`
   - resolved hosted `tagflow 1.0.0-alpha.3` and hosted
     `tagflow_table 1.0.0-alpha.1`;
   - no local path override remained.
2. `fvm flutter test test/ipos/ipo_tagflow_render_test.dart`
   - passed two tests covering the real IPO payload render path and the
     converter-free disclosure path.
3. `fvm flutter analyze lib/component/tagflow_details_converter.dart lib/screens/ipos/ipo_instrument_sheet.dart test/ipos/ipo_tagflow_render_test.dart`
   - passed with `No issues found!`.

Later coordinator refreshes adopted the same hosted-alpha validation locally on
Kite and then consolidated the production-route candidate on
`codex/tagflow-ipo-native-route`:

- `80160401 test(ipo): validate hosted tagflow alpha3`
- `355c79d6 feat(ipo): render IPO content through tagflow registry`
- `e9a86803 test(ipo): cover tagflow sheet registry path`
- `50bee7ce test(ipo): serve local IPO fixture route`

That branch now renders both IPO excerpt and main IPO content through
`Tagflow.html(..., registry: tagflowRegistry())`, keeps assertions on public
rendered table content and `tagflowTableComponents(...)`, and includes a local
`main_local.dart` AFCONS fixture for simulator route smoke. Its `pubspec.lock`
resolves hosted `tagflow 1.0.0-alpha.3` and hosted
`tagflow_table 1.0.0-alpha.1`; the local Tagflow path overrides in
`pubspec.yaml` are commented out. The Kite branch remains local while
`gitlab.zerodha.tech` DNS is unavailable.

Limits:

- The registry migration branch is not merged, not pushed, and not profile
  evidence.
- The simulator smoke uses Kite's debug `main_local.dart` server and a fake
  imported dev session, not approved live/fixture auth constraints outside the
  local debug path.
- Built-in disclosure behavior is validated in a Kite widget harness, while
  the simulator route smoke exercises table/list content from the local AFCONS
  fixture rather than a live backend IPO payload containing authored
  `details` / `summary` markup.

Do not claim public performance wins from the current benchmark evidence. The
alpha.3 benchmark posture is collection-gate only.
