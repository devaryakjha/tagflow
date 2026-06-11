# Benchmark Threshold and Reference Policy

## Status

- Date: 2026-06-12 Asia/Kolkata
- Scope: reference-environment policy, threshold promotion rules, and public
  performance-claim blockers
- Current posture: report-only internal evidence; no numeric performance,
  ranking, memory, allocation, or regression-threshold claim is qualified

## Purpose

Tagflow now has useful local evidence for the native rich content runtime:
repeat-5 macOS profile matrices, native JSON profile lanes, dynamic patch
lanes, launch-attribution metadata, memory sample captures, and physical-target
availability audits. This policy defines what those artifacts may prove today,
what they cannot prove, and what must be true before any threshold becomes a
release gate or public claim.

The current machine-readable checker policy remains intentionally conservative:
[`policies/profile-reference-runner-policy.json`](policies/profile-reference-runner-policy.json)
uses `thresholdPolicy.mode: report_only`. That means `benchmark:profile:check`
can fail collection-quality requirements, but it must not fail a run because a
frame-time, memory, or relative-speed number crossed a threshold.

## Evidence Levels

| Level | Acceptable environment | Minimum evidence | Allowed decision |
| --- | --- | --- | --- |
| Smoke evidence | Any developer machine or CI runner that can complete the selected command. | One or more selected cells complete and produce the expected artifact. | Harness health only. No performance wording. |
| Local stabilization evidence | Named local environment with recorded Flutter/Dart revision, OS, hardware, power, display, viewport, renderer ids, fixture ids, run id, and commit. | Five successful repeats per selected cell, no failed runs, viewport metadata present, and checker pass with report-only policy when applicable. | Internal release handoff and regression investigation. No public comparison. |
| Release-candidate collection gate | Stable or intentionally named candidate environment plus current benchmark docs. | Required smoke commands pass, selected profile lanes meet repeat/check policy, and every exception, missing artifact, OOM, failed scroll, or target failure is explained. | Block or proceed on collection and stability defects only. No numeric timing gate. |
| Public claim evidence | Promoted stable reference target, physical-device matrix or explicit desktop-only scope, real-app evidence for the claimed production surface, memory/allocation review when claimed, and committed comparison policy. | Fresh repeat evidence, artifact review, fixture fairness review, competitor configuration review, and a written threshold/comparison rule for the exact claim. | Limited external claim covered by the reviewed evidence and policy. |

## Required Artifact Fields

Every release-candidate or public-claim candidate run must retain or summarize
these fields before review:

- run id, command, commit SHA, package versions, and output directory
- Flutter channel, Flutter revision, Dart version, host OS, and target device
- renderer id, fixture id, repeat count, and selected renderer/fixture matrix
- successful and failed run counts, including failure class for every failure
- logical viewport width/height, physical viewport width/height, and device
  pixel ratio
- `coldInitialRender`, `warmRebuild`, and `warmScroll` frame summaries when
  available for static profile lanes
- update-latency and update-frame attribution for dynamic lanes
- `launchAttribution.status`, command-envelope provenance, first-fixture-render
  provenance, and explicit caveats such as `not_process_cold_start`
- input bytes, input length, source type, fixture path, and relevant fixture
  shape metadata such as table dimensions or update chunk counts
- new-generation and old-generation GC counts
- memory sample or snapshot references when memory or allocation behavior is
  being discussed

Missing fields are collection-quality defects for release-candidate gates when
the current harness is expected to emit them. For older historical artifacts,
missing fields may be documented as caveats but cannot support new public
claims.

## Repeat Policy by Lane

| Lane | Minimum for smoke | Minimum for local stabilization | Public-claim minimum |
| --- | ---: | ---: | ---: |
| Fixture validity | One full command pass | One full command pass on the named environment | One current pass on the promoted reference target |
| Parser microbench | One emitted result per selected fixture | Current fixture set with reviewed input sizes | Fresh repeated same-environment parser policy, not yet defined |
| Widget render microbench | One emitted result per selected fixture | Current fixture set with reviewed input sizes | Fresh repeated same-environment render policy, not yet defined |
| Default HTML profile matrix | One selected cell | Five repeats per renderer/fixture cell | Five or more repeats per claimed cell on the promoted target |
| Native JSON profile lane | One selected native fixture | Five repeats per selected native fixture | Five or more repeats per claimed native fixture on the promoted target |
| Dynamic patch/update lane | One ordered control/patch pair | Five repeats per paired control/patch lane | Five or more paired repeats plus explained GC/raster outliers |
| Native transport microbench | One command pass | Repeated samples with reviewed payload sizes | Separate transport threshold policy, not yet defined |
| Memory/allocation lane | Bounded memory capture exists | Repeat-5 profile evidence plus bounded memory samples | Heap snapshots or allocation diffs with retained-object review |
| Physical target lane | One-repeat probe with failure continuation | Repeat-5 physical run after the probe passes | Current physical iOS and Android evidence, unless claim is desktop-only |
| Real app lane | One reachable diagnostic probe | Profile-mode capture of the production surface | Production-surface profile evidence with real data/auth state documented |

## Comparison Rules

Comparisons must match the work being measured.

- HTML renderer comparisons may compare only fixtures and behaviors supported
  by every named renderer. Table support, unsupported HTML behavior, styling
  differences, and configuration must be documented before comparison.
- Native JSON profile lanes are first-party `TagflowDocument` rendering
  evidence. They must not be described as faster than HTML parsing unless a
  separate same-content HTML/native conversion policy exists.
- Native transport microbenchmarks measure JSON decode, adapt, patch decode,
  patch adapt, patch apply, and total transport phases. They do not measure
  frame rendering and cannot be used as renderer speed claims.
- Dynamic patch lanes may be compared only as paired control/patch runs from
  the same run id and environment. Old-gen GC, raster outliers, missed-frame
  counts, and update attribution must be reviewed before any dynamic-content
  wording.
- Memory samples are not allocation claims. Allocation claims require snapshot
  or allocation-diff evidence and retained-object review.
- Launch attribution must keep command-envelope, native launch markers, and
  first fixture render separate. `coldInitialRender` is not process cold start.

## Threshold Promotion Rules

No numeric threshold may move from advisory to gating until all of these are
true:

1. A stable reference environment is named and documented.
2. The relevant lane has a fresh repeat baseline on that environment.
3. The run passes collection-quality checks for repeat count, failed runs,
   viewport metadata, and required artifact fields.
4. Outliers, GC events, missed-frame counts, and failed or partial launch
   attribution are reviewed.
5. The exact metric is named, including phase and percentile where relevant.
6. The threshold rule states whether it is absolute, relative-to-baseline,
   relative-to-control, or trend-only.
7. The allowed variance, re-run policy, and failure classification are written.
8. The policy states which releases or CI jobs are allowed to enforce the
   threshold.

Until those conditions are met, timing values, GC values, memory samples,
launch markers, and relative differences remain report-only.

## Current Blockers for Public Claims

- Physical targets are not qualified. Current iOS discovery sees the phone as
  wireless/offline for profiling, and no physical Android target is attached.
- Real-app production profile evidence is missing. Kite hosted-alpha widget
  evidence exists, but production IPO profile-mode evidence remains blocked.
- The reference environment is not claim-grade because current local evidence
  was collected on prerelease Flutter and prerelease macOS.
- Memory/allocation evidence is not claim-grade. Bounded memory samples exist,
  but heap snapshots, allocation diffs, and retained-object review are pending.
- Native JSON and HTML lanes are not a direct speed comparison. They currently
  exercise different input paths.
- Dynamic patch lanes still have diagnostic GC/raster and missed-frame findings
  that must be explained before dynamic-content performance wording.
- Competitor fairness review is not complete for public ranking claims.
- No committed numeric threshold policy exists for any lane.

## Allowed Wording Today

Allowed:

- "Tagflow has a report-only benchmark harness for local alpha stabilization."
- "The harness can collect repeat-5 local macOS evidence for selected profile
  lanes."
- "Native JSON and dynamic patch lanes have local report-only evidence."
- "Current benchmark checks enforce collection quality, not timing thresholds."

Blocked:

- "Tagflow is faster than another Flutter HTML or rich-content renderer."
- "Tagflow meets a stable frame-time budget."
- "Native JSON is faster than HTML parsing."
- "Dynamic patch rendering avoids jank in production."
- "Tagflow uses less memory or allocates less than the control lane."
- "The current macOS numbers are public benchmark results."
