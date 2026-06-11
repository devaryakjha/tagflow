# Shipping a Safe Rich Content Runtime

Tagflow should render product-shaped content as native Flutter widgets while
keeping the input constrained, reviewable, and easy to theme.

> The immediate target is not arbitrary webpage fidelity. The target is
> controlled AI, CMS, and server-authored content that should feel native.

## Migration plan

1. Freeze the alpha public surface before broad runtime changes.
2. Introduce a native document model with safe defaults.
3. Adapt HTML into that model instead of shaping the runtime around tags.

## Practical constraints

- Keep fixtures deterministic and local-only.
- Prefer semantic components over browser-like layout tricks.
- Measure parsing, conversion, and frame behavior separately.

## Reference snippet

```dart
final widget = Tagflow(
  html: '<article><h1>Runtime</h1></article>',
  options: const TagflowOptions(),
);
```

## Comparison table

| Path | Strength | Risk |
| --- | --- | --- |
| HTML adapter | Fast migration path | Can keep legacy assumptions alive |
| Native document model | Clear rendering contract | Requires curated public exports |
| Bench harness | Reproducible evidence | Noisy if fixtures drift |

## Citations

Sources: internal runtime audit, benchmark spec, and parser behavior tests.
