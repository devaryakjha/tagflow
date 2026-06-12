# 2026-06-12 Kite Non-GitLab Owner Acceptance Request

## Status

- Date: 2026-06-12 Asia/Kolkata
- Related gate: #73 real-app route evidence
- Downstream repo: `/Users/arya/projects/kite`
- Downstream branch: `codex/tagflow-ipo-native-route`
- Review packet:
  `/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route`
- Posture: owner decision request; not #73 closure until accepted

## Purpose

Make the remaining real-app route decision explicit. The Kite IPO route is the
strongest prepared downstream app path, and the non-GitLab review packet is
available locally with verified artifacts. The missing requirement is owner
acceptance that this packet can replace Kite's normal GitLab source-control
review link for #73.

This note does not approve beta/stable release wording, performance claims,
package publishing, or a Tagflow gate status change by itself.

## Current Packet Verification

Packet artifact root:

```text
/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
```

The packet is intentionally stored under the Tagflow coordinator checkout's
ignored `build/` directory. The content is generated from the Kite branch, but
the packet artifact itself is not stored under `/Users/arya/projects/kite`.

Current packet artifacts are present:

```text
artifact-list.txt
diff-check.txt
diff-stat.txt
full-diff.patch
git-log-fuller-3.txt
kite-tagflow-ipo-native-route.bundle
logs/flutter-analyze.txt
logs/flutter-test-tagflow-hosted-alpha3.txt
logs/git-remote-status.txt
package-resolution-proof.txt
patches/0001-feat-ipo-render-IPO-content-through-tagflow-registry.patch
patches/0002-test-ipo-cover-tagflow-sheet-registry-path.patch
patches/0003-test-ipo-serve-local-IPO-fixture-route.patch
sha256sums.txt
```

Artifact integrity check:

```bash
cd /Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
shasum -a 256 -c sha256sums.txt
```

Result:

```text
artifact-list.txt: OK
diff-check.txt: OK
diff-stat.txt: OK
full-diff.patch: OK
git-log-fuller-3.txt: OK
kite-tagflow-ipo-native-route.bundle: OK
logs/flutter-analyze.txt: OK
logs/flutter-test-tagflow-hosted-alpha3.txt: OK
logs/git-remote-status.txt: OK
package-resolution-proof.txt: OK
patches/0001-feat-ipo-render-IPO-content-through-tagflow-registry.patch: OK
patches/0002-test-ipo-cover-tagflow-sheet-registry-path.patch: OK
patches/0003-test-ipo-serve-local-IPO-fixture-route.patch: OK
```

The Kite route branch currently contains exactly these route commits over
`feat/dashboard`:

```text
50bee7ce test(ipo): serve local IPO fixture route
e9a86803 test(ipo): cover tagflow sheet registry path
355c79d6 feat(ipo): render IPO content through tagflow registry
```

Current route diff scope:

```text
lib/main_local.dart                        |  73 ++++++++++++++-
lib/screens/ipos/ipo_instrument_sheet.dart |  50 +++++------
test/ipos/tagflow_hosted_alpha3_test.dart  | 140 ++++++++++++++++++++++++++++-
3 files changed, 234 insertions(+), 29 deletions(-)
```

`git diff --check feat/dashboard..HEAD` passed.

## Hosted Package Resolution

Kite `pubspec.yaml` currently requests hosted prerelease packages:

```yaml
tagflow: ^1.0.0-alpha.3
tagflow_table: ^1.0.0-alpha.1
```

The only local Tagflow path overrides remain commented out:

```yaml
# tagflow:
#   path: /Users/arya/projects/personal/tagflow/packages/tagflow
# tagflow_table:
#   path: /Users/arya/projects/personal/tagflow/packages/tagflow_table
```

Kite `pubspec.lock` resolves:

```text
tagflow:
  source: hosted
  version: "1.0.0-alpha.3"
tagflow_table:
  source: hosted
  version: "1.0.0-alpha.1"
```

## Focused Validation In Packet

Packet validation logs record:

```bash
cd /Users/arya/projects/kite
PATH=/Users/arya/fvm/default/bin:$PATH \
  flutter analyze \
    lib/main_local.dart \
    lib/screens/ipos/ipo_instrument_sheet.dart \
    test/ipos/tagflow_hosted_alpha3_test.dart
PATH=/Users/arya/fvm/default/bin:$PATH \
  flutter test test/ipos/tagflow_hosted_alpha3_test.dart
```

Results:

```text
Analyzing 3 items...
No issues found! (ran in 5.5s)

00:00 +3: All tests passed!
```

The Flutter commands emitted existing Swift Package Manager plugin warnings.
Those warnings did not fail validation and are not introduced by this Tagflow
route packet.

## Review Substitute Decision

Kite's normal remote remains:

```text
origin git@gitlab.zerodha.tech:mobile-apps/kite.git
```

Recorded reachability result:

```text
ssh: Could not resolve hostname gitlab.zerodha.tech
git-ls-remote-exit-code=128
```

GitLab access is not itself a Tagflow package requirement. It matters only
because #73 requires the integration to be pushed, merged, or otherwise
reviewable through the app's intended source-control path.

The non-GitLab packet can satisfy the reviewability part of #73 only if the
owner explicitly accepts it as the review artifact for this route.

## Requested Owner Decision

Owner acceptance text:

```text
I accept the Kite non-GitLab review packet at
/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
as the review artifact for the IPOInstrumentSheet Tagflow native-runtime route
in #73. I accept the local debug fixture/auth constraints recorded for the
Bids -> IPO -> AFCONS -> IPOInstrumentSheet route smoke. This acceptance is
for the #73 real-app route gate only and does not approve beta/stable release,
publishing, or public performance claims.
```

If that owner decision is recorded, update #73 and
`docs/plans/native-runtime-gate-status.json` with:

- `real-app-route.status=satisfied`;
- this acceptance note and the existing non-GitLab review packet as evidence;
- route name: `Kite IPOInstrumentSheet`;
- navigation path:
  `Bids -> IPO -> AFCONS -> IPOInstrumentSheet`;
- hosted package versions:
  `tagflow 1.0.0-alpha.3`, `tagflow_table 1.0.0-alpha.1`;
- source-control substitute:
  non-GitLab packet accepted by owner.

Until that decision is recorded, #73 remains open.
