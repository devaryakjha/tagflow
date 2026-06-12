# 2026-06-12 Kite Non-GitLab Review Packet

## Status

- Date: 2026-06-12 Asia/Kolkata
- Related gate: #73 real-app route evidence
- Downstream repo: `/Users/arya/projects/kite`
- Downstream branch: `codex/tagflow-ipo-native-route`
- Packet artifact root:
  `/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route`
- Posture: owner-review packet prepared; not #73 closure

## Purpose

This packet makes the prepared Kite IPO route migration reviewable without
requiring immediate access to Kite's normal GitLab remote. It exists because
`git@gitlab.zerodha.tech:mobile-apps/kite.git` does not resolve from this
machine right now.

GitLab access is not a Tagflow package requirement. The packet can substitute
for the GitLab source-control link only if Kite's owner explicitly accepts it
as the review artifact for #73 and accepts the local debug fixture/auth
constraints. Until that owner acceptance exists, this is supporting evidence
only and #73 remains open.

## Included Artifacts

The ignored packet directory is stored under the Tagflow coordinator checkout,
not under the Kite checkout. It contains:

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

The route-smoke screenshot remains in the earlier ignored Tagflow artifact
path:

```text
build/benchmarks/kite-ipo-native-route/2026-06-12-afcons-tagflow-tables.jpg
```

## Packet Commands

The packet was generated from the current Kite route branch and written to the
Tagflow coordinator artifact directory with:

```bash
TAGFLOW_PACKET_DIR=/Users/arya/projects/tagflow/build/validation/kite-non-gitlab-review-packet/2026-06-12-ipo-native-route
git -C /Users/arya/projects/kite bundle create \
  "$TAGFLOW_PACKET_DIR/kite-tagflow-ipo-native-route.bundle" \
  feat/dashboard..HEAD
git -C /Users/arya/projects/kite format-patch \
  -o "$TAGFLOW_PACKET_DIR/patches" \
  feat/dashboard..HEAD
git -C /Users/arya/projects/kite log --format=fuller -3
git -C /Users/arya/projects/kite diff --stat feat/dashboard..HEAD
git -C /Users/arya/projects/kite diff --check feat/dashboard..HEAD
git -C /Users/arya/projects/kite diff feat/dashboard..HEAD -- \
  lib/main_local.dart \
  lib/screens/ipos/ipo_instrument_sheet.dart \
  test/ipos/tagflow_hosted_alpha3_test.dart
```

The generated patch series covers these commits:

```text
355c79d6 feat(ipo): render IPO content through tagflow registry
e9a86803 test(ipo): cover tagflow sheet registry path
50bee7ce test(ipo): serve local IPO fixture route
```

## Package Resolution

`package-resolution-proof.txt` records:

```text
tagflow: ^1.0.0-alpha.3
tagflow_table: ^1.0.0-alpha.1
tagflow source: hosted, version: "1.0.0-alpha.3"
tagflow_table source: hosted, version: "1.0.0-alpha.1"
```

The only local Tagflow path overrides in Kite `pubspec.yaml` remain commented
out.

## Validation

Focused Kite validation logs are included in the packet:

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
Those warnings did not fail validation and were not introduced by this route
packet.

## Remote Status

`logs/git-remote-status.txt` records:

```text
origin git@gitlab.zerodha.tech:mobile-apps/kite.git
ssh: Could not resolve hostname gitlab.zerodha.tech
git-ls-remote-exit-code=128
```

## Required Owner Acceptance

For #73, the missing acceptance is:

```text
Kite owner accepts this packet as the review artifact for the IPOInstrumentSheet
Tagflow native-runtime route, and accepts the local debug fixture/auth
constraints for #73.
```

Without that explicit owner acceptance, this packet is not a qualifying
source-control substitute. The route gate remains open.
