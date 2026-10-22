# Roadmap

Tagflow is heading to `1.0.0`: a native renderer for rich content in Flutter,
with rendering streamed LLM answers (Markdown) as the headline feature.
Breaking changes go out as betas first. Tagflow runs in production apps, so
every breaking change gets a beta soak before it reaches a stable release.

## Where things stand

`1.0.0-beta.0` (June 2026) shipped the runtime:

- `TagflowDocument` as the canonical, immutable input, built directly or by
  adapters.
- HTML through `TagflowHtmlAdapter` and `Tagflow.html(...)`.
- Strict, versioned native JSON transport (`TagflowNativeBlockCodec`,
  `TagflowNativeBlockAdapter`).
- Document patches for live updates with stable node ids.
- A content policy for unsafe tags, URL schemes and images.
- A semantic component registry for overrides and extensions, with
  `tagflow_table` as the first extension.
- Native `<details>` / `<summary>` disclosure.

`0.0.8` on the `stable` branch remains the stable HTML-renderer line until
`1.0.0` ships.

## Cleanup (no user-facing change)

- [ ] Remove release-gate tooling and point-in-time planning docs; keep the
      microbenchmarks.
- [ ] Refresh the contributor guide, this roadmap and the CI toolchain pin.
- [ ] Trim the example app to Tagflow-only content.
- [ ] Delete stale and merged branches.

## 1.0.0-beta.1: AI answers

- [ ] Markdown adapter: `Tagflow.markdown(...)` and `TagflowMarkdownAdapter`
      on `package:markdown` (GFM tables, task lists, fenced code), producing a
      normal `TagflowDocument` so the content policy, registry and tables all
      apply.
- [ ] Streaming helper: a controller that takes appended text chunks,
      re-parses only the open tail block, and emits patches with stable ids so
      finished blocks never rebuild.
- [ ] Code blocks: a registry hook for syntax highlighting and a copy button.
      Highlighting is an optional add-on so the core stays lean.
- [ ] Golden tests for every built-in node kind in light and dark themes.
- [ ] Example app rebuilt as a gallery: HTML, native JSON, Markdown and a
      live streaming demo.

## 1.0.0-beta.2: frozen API

- [ ] Close the review in
      [`docs/specs/2026-06-12-beta-public-api-freeze-review.md`](docs/specs/2026-06-12-beta-public-api-freeze-review.md).
- [ ] Mark the legacy converter API (`package:tagflow/legacy.dart`,
      `TagflowOptions` converters) `@Deprecated` with removal in 2.0.
- [ ] Move `tagflow_table` off the legacy HTML bridge.
- [ ] Write a `0.0.8` to `1.0` migration guide and refresh
      [docs.arya.run/tagflow](https://docs.arya.run/tagflow).
- [ ] Ship `1.0.0-beta.2` and move the internal apps onto it.

## 1.0.0

- [ ] Graduate once the internal apps run clean on beta.2.
- [ ] Publish `tagflow` and `tagflow_table` from tags.
- [ ] Tag the past `stable` line releases so the history is complete.

## Later (not in 1.0)

- Math rendering.
- Lazy or sliver rendering for very long documents.
- Richer CSS layout in the HTML adapter (flex, grid).
- Video embeds.
