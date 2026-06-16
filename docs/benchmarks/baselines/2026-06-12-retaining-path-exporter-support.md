# Retaining Path Exporter Support

This note records a harness capability change, not a benchmark result.

The VM-service memory evidence exporter can now collect optional bounded
`getRetainingPath` samples for selected classes during a live hold-open
checkpoint. This is intended to close part of the gap identified by the
authored-insertion class-growth review, where `TagflowDocumentNode` and
`TagflowDocument` were the package-level classes that still needed retained-path
inspection.

## Usage

Use the same live checkpoint flow as the existing memory evidence exporter, then
add retained-path class targets:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
TAGFLOW_MEMORY_EVIDENCE_VM_SERVICE_URI=<vm-service-uri> \
TAGFLOW_MEMORY_EVIDENCE_CHECKPOINT=after_scroll \
TAGFLOW_MEMORY_EVIDENCE_OUTPUT_DIR=build/benchmarks/profile-memory-evidence/<run-id>/devtools \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_CLASSES=TagflowDocumentNode,TagflowDocument \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_SAMPLE_LIMIT=1 \
TAGFLOW_MEMORY_EVIDENCE_RETAINING_PATH_LIMIT=20 \
dart run melos run benchmark:memory-evidence:export
```

The exporter still writes the existing allocation profile and heap class
summary files. When retained-path classes are provided, it also writes:

```text
<checkpoint>-retaining-paths.json
```

Class targets may be simple class names or library-qualified selectors in the
form `package:...::ClassName` when a class name is ambiguous.
Duplicate targets from repeated flags or env forwarding are de-duplicated in
first-seen order before export.

## Interpretation

The retained-path file is review input. It is not a public memory claim and it
does not replace raw DevTools heap snapshots or heap diffs when those are
needed for ownership review. The next benchmark evidence worker should run this
against a live authored-insertion patch checkpoint, then commit only a reviewed
baseline note that references the ignored JSON artifacts.

## Validation

Focused validation for the harness change:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter test test/memory_evidence_exporter_test.dart
```

Result: passed.

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH \
flutter analyze . --fatal-infos
```

Result: passed for `packages/tagflow_benchmarks`.
