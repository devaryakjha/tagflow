# 2026-06-12 Memory And Allocation Evidence Probe

This note records the first bounded memory-capture probe for the native rich
content runtime on the current Tagflow benchmark harness.

It is report-only evidence. It does not set thresholds, does not support any
public memory or allocation claim, and does not replace the reviewed baseline
flow in
[`2026-06-12-memory-allocation-evidence-playbook.md`](2026-06-12-memory-allocation-evidence-playbook.md).

Raw memory JSON stayed only under ignored `build/` output:

```text
build/benchmarks/profile-memory-evidence/2026-06-12-native-large-article-probe/native-large-article-memory-profile.json
build/benchmarks/profile-memory-evidence/2026-06-12-authored-insertion-patch-probe/authored-insertion-patch-memory-profile.json
```

## Scope

- Collection commit:
  `94af01feeb48b345151e6e6543a4873e8da39b86`
- Branch context: `codex/tagflow-native-runtime-master`
- `tagflow` version: `1.0.0-alpha.3`
- Device: `macos`
- Host OS: `macOS 27.0 (26A5353q)`, `arm64`
- Flutter SDK: `3.45.0-0.1.pre (master)`
- Dart SDK: `3.11.0-81.0.dev`
- DevTools: `2.51.0`
- Selected cells:
  - `tagflow_native_json:native_large_article`
  - `tagflow_semantic_patch:streaming_ai_authored_insertion_patches`

## Feasibility

- The documented DevTools CLI path is available locally:

  ```bash
  PATH=/Users/arya/fvm/cache.git/bin:$PATH \
  dart devtools --help
  ```

  The local SDK exposes `--record-memory-profile=<file>`.

- For this short-lived `flutter drive` benchmark harness, the bounded path that
  completed reliably in one turn was the official Flutter wrapper:
  `flutter drive --profile-memory=<file>`.
- That path produced DevTools memory JSON with
  `samples.dartDevToolsScreen="memory"` and repeated
  `rss/capacity/used/external/gc/rasterCache` samples.
- This is enough to prove automated memory capture is feasible on the current
  local macOS runner.
- It is not the full playbook outcome yet because no interactive snapshots,
  class allocation diffs, or repeat-5 reviewed baseline were collected here.

## Commands

Native JSON large article:

```bash
cd examples/tagflow && \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter drive \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/tagflow_perf_test.dart \
  -d macos \
  --profile \
  --keep-app-running \
  --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false \
  --dart-define=TAGFLOW_RENDERER=tagflow_native_json \
  --dart-define=TAGFLOW_FIXTURE=native_large_article \
  --profile-memory=/Users/arya/.codex/worktrees/b503/tagflow/build/benchmarks/profile-memory-evidence/2026-06-12-native-large-article-probe/native-large-article-memory-profile.json
```

Dynamic patch lane:

```bash
cd examples/tagflow && \
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter drive \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/tagflow_perf_test.dart \
  -d macos \
  --profile \
  --dart-define=INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false \
  --dart-define=TAGFLOW_RENDERER=tagflow_semantic_patch \
  --dart-define=TAGFLOW_FIXTURE=streaming_ai_authored_insertion_patches \
  --profile-memory=/Users/arya/.codex/worktrees/b503/tagflow/build/benchmarks/profile-memory-evidence/2026-06-12-authored-insertion-patch-probe/authored-insertion-patch-memory-profile.json
```

## Results

| Cell | Harness result | Memory file | Observed DevTools samples | Paired benchmark artifact |
| --- | --- | --- | ---: | --- |
| `tagflow_native_json:native_large_article` | `flutter drive` passed | `native-large-article-memory-profile.json` | `19` | `examples/tagflow/build/integration_response_data.json` with `initial_render`, `warm_rebuild`, `scroll`, `launch_attribution`, and `viewport` keys for this cell |
| `tagflow_semantic_patch:streaming_ai_authored_insertion_patches` | `flutter drive` passed | `authored-insertion-patch-memory-profile.json` | `14` | `examples/tagflow/build/integration_response_data.json` with `updates`, `update_latencies`, `scroll`, `launch_attribution`, and `viewport` keys for this cell |

Command notes:

- The native JSON run emitted one engine warning during collection:
  `Reported frame time is older than the last one; clamping`.
- Both benchmark runs still completed with `All tests passed.`
- No raw memory JSON was promoted into `docs/` or any tracked artifact path.

## Interpretation Limits

- These probes prove the harness can produce reviewable DevTools memory sample
  files for the selected native JSON and dynamic patch cells on local macOS.
- These probes do not qualify memory or allocation wording on their own.
- They do not include:
  - repeat-5 baseline manifests or summary/check output
  - the full-reparse control cell for the dynamic authored-insertion lane in
    the same reviewed pass
  - interactive before/after heap snapshots
  - class allocation diffs or retained-object review
- The environment remains a prerelease host and prerelease Flutter toolchain,
  which is already disqualified for public claim use by
  [`../2026-06-12-reference-runner-qualification.md`](../2026-06-12-reference-runner-qualification.md).

## Reproduction Guidance

If a future worker needs the playbook-complete outcome instead of this bounded
probe:

1. Run the playbook baseline command with a stable `RUN_ID` for the target
   lane or ordered pair.
2. Keep the dynamic full-reparse control lane in the same pass for authored
   insertion review.
3. Collect DevTools Memory snapshots or allocation diffs at the checkpoints
   named in the playbook.
4. Keep raw exports under ignored `build/` output and write only reviewed notes
   back into `docs/benchmarks/baselines/`.
