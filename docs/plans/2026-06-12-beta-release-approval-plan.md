# Beta Release Approval Plan

## Status

- Date: 2026-06-12
- Coordinator branch: `codex/tagflow-native-runtime-master`
- Draft review PR: https://github.com/devaryakjha/tagflow/pull/72
- Gate manifest: `docs/plans/native-runtime-gate-status.json`
- Gate id: `release-approval`
- Posture: approval checklist only; no publish, tag, version bump, beta, or
  stable claim

## Purpose

Define the owner approval packet required before the native runtime line can
move from alpha coordination toward beta or stable promotion.

This plan deliberately does not satisfy the gate. It makes the deferred release
decision auditable so the coordinator cannot promote the line based only on
green package tests, example-app evidence, or internal benchmark artifacts.

## Current State

The `1.0.0-alpha.3` core package is already published as a prerelease. PR #72
continues as a draft coordinator branch for native-runtime hardening and gate
tracking.

The beta-candidate gate still fails on:

- `real-app-route`;
- `physical-observed-profile`;
- `release-approval`.

The `beta-preapproval` profile exists to check all non-owner-approval beta
gates without requiring `release-approval` itself. It must pass, or every
remaining non-approval failure must have an explicit owner waiver, before the
approval packet can satisfy `release-approval`.

The release approval gate must remain deferred until the evidence packet below
is complete and explicitly accepted by the owner.

## Approval Preconditions

Before `release-approval` can become satisfied, all of these must be true:

- `real-app-route` is satisfied, or the owner records an explicit waiver naming
  why beta may proceed without it;
- `physical-observed-profile` is satisfied, or the owner records an explicit
  waiver naming why beta may proceed without physical or qualified observed-host
  profile evidence;
- every non-approval gate in the selected release profile is satisfied, or each
  unsatisfied non-approval gate has an explicit owner waiver recorded in the
  approval packet;
- the owner approves the exact release lane: beta prerelease, stable release,
  or no release;
- the owner approves package scope, including whether `tagflow_table` remains
  separate and whether it is released with the core package;
- the owner approves public API freeze posture for the runtime model, native
  transport codec, semantic registry, HTML adapter, and legacy compatibility
  surface;
- release notes and README wording do not contain public faster/slower,
  lower-memory, leak-free, ranking, frame-budget, stable, or production-ready
  claims unsupported by the evidence gates;
- `TAGFLOW_NATIVE_RUNTIME_GATE_PROFILE=beta-preapproval dart run melos run
  gate:native-runtime` passes, or every remaining non-approval failure has an
  explicit owner waiver in the approval packet;
- publish validation passes without warnings for every package in scope;
- CI is green on the release candidate commit;
- any tag/publish step is separately approved after the packet is reviewed.

## Required Approval Packet

Prepare a single approval packet before asking for beta or stable release
permission. It should include:

- candidate commit SHA and branch;
- package versions and package scope;
- current `gate:native-runtime` output for `beta-preapproval` and the intended
  release profile;
- links to satisfied `real-app-route` and `physical-observed-profile` evidence,
  or explicit owner waiver text for each unsatisfied gate;
- public API surface summary and freeze risks;
- compatibility support-window summary for `package:tagflow/legacy.dart`,
  `TagflowOptions`, custom legacy converters, and `tagflow_table`;
- benchmark evidence summary with claim boundaries;
- memory/allocation evidence summary with claim boundaries;
- exact validation commands and results;
- publish dry-run output for every package in scope;
- release notes / changelog diff;
- README/package-page wording diff;
- explicit owner decision text.

Suggested owner decision text:

```text
I approve Tagflow <version> as a <beta prerelease|stable release> candidate
from commit <sha>, with package scope <packages>. I have reviewed the
real-app-route and profile evidence, accepted any named waivers, and approve
the release notes and public claim boundaries. Publishing still requires a
separate explicit go-ahead.
```

## Stop Rules

Leave `release-approval` deferred if any of these are true:

- #73 or an equivalent real-app route gate remains open without an explicit
  owner waiver;
- physical or qualified observed-host profile evidence remains open without an
  explicit owner waiver;
- `beta-preapproval` fails in `gate:native-runtime` without an explicit owner
  waiver for every remaining non-approval failure;
- the selected release profile fails in `gate:native-runtime` for any reason
  other than the still-deferred `release-approval` gate before owner approval;
- package scope is unclear;
- public API freeze posture is unclear;
- release notes or README copy makes unsupported performance or memory claims;
- publish dry-run has warnings or errors;
- the owner has not explicitly approved the release packet.

## Reporting

When approval exists, update the gate manifest with:

- `release-approval.status=satisfied`;
- a `localPath` evidence entry for the reviewed approval packet;
- the owner approval URL or note;
- the exact release lane and package scope.

Until then, PR #72 should remain draft for coordinator work, and beta/stable
promotion must remain blocked by `release-approval`.
