# Profile Policy Matrix Enforcement

## Status

- Date: 2026-06-12 Asia/Kolkata
- Branch: `codex/tagflow-native-runtime-master`
- Scope: profile checker policy semantics
- Posture: tooling evidence only; no public benchmark, beta/stable, frame
  budget, memory, or comparative claim

## Purpose

Record the checker behavior after `profile-*-policy.json` matrix declarations
became enforceable. A policy with a `matrix` now qualifies only the declared
renderer and fixture cells. This keeps the HTML reference policy, synthetic
viewport policy, and native JSON profile lanes from being accidentally treated
as interchangeable.

## Verified Existing Artifacts

Synthetic viewport policy against its declared cell:

```text
TAGFLOW_PROFILE_RUN_ID=2026-06-12-synthetic-viewport-repeat5-r1
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-synthetic
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-synthetic-viewport-policy.json
dart run melos run benchmark:profile:check

result=passed
reportOnlyFindings=[synthetic_viewport_not_reference_target]
```

Native JSON observed-host run against the HTML reference policy:

```text
TAGFLOW_PROFILE_RUN_ID=2026-06-12-observed-host-native-json-repeat5-timeout-r1
TAGFLOW_PROFILE_OUTPUT_DIR=build/benchmarks/profile-observed-host
TAGFLOW_PROFILE_CHECK_POLICY=docs/benchmarks/policies/profile-reference-runner-policy.json
dart run melos run benchmark:profile:check

result=failed
issues=[
  cell_outside_policy_matrix for tagflow_native_json:native_ai_answer,
  unexpected_viewport for observed 800x600 @ 1.0x versus expected
  800x600 @ 2.0x
]
```

The second result is expected. `profile-reference-runner-policy.json` describes
the default HTML renderer/fixture reference matrix. It should not qualify the
native JSON profile lane unless that policy is explicitly revised through a
future benchmark-policy decision.

## Claim Boundary

This tooling slice does not change the current beta-preapproval blockers:

- `physical-observed-profile` remains open;
- the current native JSON observed-host run remains local stabilization
  evidence only;
- no physical-device, observed-host reference, public performance,
  frame-budget, memory, comparative, beta/stable, publishing, or package-page
  claim is authorized.
