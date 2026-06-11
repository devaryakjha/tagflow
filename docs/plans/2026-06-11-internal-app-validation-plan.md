# Internal App Validation Plan for Tagflow 1.0.0 Alpha

**Status:** Draft for coordinator review
**Target release line:** `1.0.0-alpha.1`
**Scope:** one internal Flutter app content surface

## Goal

Validate Tagflow's native rich content runtime in one real internal Flutter app
before promoting beyond the alpha line. The trial should prove that controlled
AI, CMS, and server-authored content can render as native Flutter widgets
without publishing Tagflow, changing unrelated app areas, or depending on
webpage-style rendering behavior.

The stable `1.0.0` decision should wait until this validation has captured real
rendering, interaction, performance, theming, failure-policy, and rollback
evidence.

## Candidate Content Surface

Pick one app-owned rich content surface with production-like content and low
release blast radius. Good candidates are:

- announcement, release-note, or product-update detail body
- help-center article or FAQ answer generated from CMS content
- AI-authored answer card with paragraphs, lists, code, links, and citations
- internal policy or onboarding article where authors already control content

Do not start with arbitrary user-generated webpages, embedded scripts, forms,
iframes, or source content whose layout depends on broad browser CSS.

The first validation fixture must include:

- headings and paragraphs
- strong, emphasis, inline code, and at least one highlighted or secondary run
- ordered and unordered lists, including one nested item if the real surface
  uses nested content
- at least two links, one allowed and one rejected by policy
- one image-like block or media placeholder path
- one table with a header row and mixed inline cell content
- one unsupported or blocked element to verify predictable failure behavior
- dark-mode and light-mode screenshots of the same content

## Local Consumption Before Pub Release

The internal app should consume this checkout through path overrides only. Do
not publish, tag, or push package tags for the validation trial.

Use this dependency shape in the app's `pubspec.yaml`:

```yaml
dependencies:
  tagflow: ^1.0.0-alpha.1
  tagflow_table: ^1.0.0-alpha.1

dependency_overrides:
  tagflow:
    path: /Users/arya/projects/tagflow/packages/tagflow
  tagflow_table:
    path: /Users/arya/projects/tagflow/packages/tagflow_table
```

If the trial runs from an isolated Codex worktree instead of the main checkout,
point the paths at that exact worktree:

```yaml
dependency_overrides:
  tagflow:
    path: /Users/arya/.codex/worktrees/8b50/tagflow/packages/tagflow
  tagflow_table:
    path: /Users/arya/.codex/worktrees/8b50/tagflow/packages/tagflow_table
```

Refresh dependencies from the internal app root:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter pub get
```

Confirm the lockfile resolved both packages from local paths:

```bash
rg -n "tagflow|tagflow_table|source: path" pubspec.lock
```

Pass criteria:

- `pubspec.lock` resolves `tagflow` and `tagflow_table` from `source: path`.
- No hosted `tagflow` package is used during the trial.
- The override is isolated to the validation branch and can be removed in one
  revert commit.

## Integration Shape

Prefer native documents for app-authored structured content:

```dart
final document = TagflowDocument(
  id: 'release-note-2026-06-11',
  children: [
    TagflowDocumentNode.heading(
      id: 'release-note-2026-06-11.title',
      level: 1,
      children: [
        TagflowDocumentNode.text(
          id: 'release-note-2026-06-11.title.text',
          text: 'Margin rule changes',
        ),
      ],
    ),
  ],
);

Tagflow.document(
  document,
  registry: TagflowComponentRegistry(
    extensions: [tagflowTableComponents(treatFirstRowAsHeader: true)],
  ),
  viewOptions: TagflowViewOptions(
    selectable: const TagflowSelectableOptions(enabled: true),
    linkTapCallback: appLinkHandler,
  ),
);
```

Use `Tagflow.html(...)` only where the app currently receives controlled HTML:

```dart
Tagflow.html(
  html: cmsHtml,
  adapter: const TagflowHtmlAdapter(
    policy: TagflowContentPolicy(
      allowRemoteImages: false,
      allowDataImages: false,
      allowedSchemes: {'https', 'mailto'},
      unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
    ),
  ),
  renderBoundary: const TagflowRenderBoundary.comment(end: 'end-of-mobile'),
  viewOptions: TagflowViewOptions(linkTapCallback: appLinkHandler),
);
```

Do not use `package:tagflow/legacy.dart` for new integration code unless the
trial is explicitly validating an existing selector-based converter migration.

## Rendering Fidelity Checks

Capture the same fixture in the current production renderer and in Tagflow.
Compare by screen, not by raw HTML behavior.

Pass criteria:

- Body copy, headings, lists, code blocks, blockquotes, links, images, and
  tables are readable and preserve the intended semantic order.
- Light and dark themes use app typography, colors, spacing, and selection
  affordances without hard-coded colors that conflict with the app shell.
- Tables fit the app surface without clipping primary values on the target
  phone and desktop/tablet breakpoints used by the internal app.
- Unsupported input is either hidden or shown as an app-approved placeholder,
  matching the configured policy.
- Accessibility labels exist for image placeholders or the image is omitted
  according to product policy.

Evidence to capture:

- light-mode screenshot
- dark-mode screenshot
- narrow viewport or small-device screenshot
- current renderer screenshot for comparison, if one exists
- a short list of any semantic differences accepted by product/design

## Interaction Behavior Checks

Pass criteria:

- Link taps route through the app navigation or external-link handler, never
  through ad hoc `launchUrl` calls in content code.
- Selection is enabled only where the app expects copyable content.
- Images use the app's loading, failure, and blocked-resource behavior.
- Tapping inside lists, tables, and inline links does not interfere with parent
  scroll views or app-level gestures.
- Unsupported content does not throw during parse or render.

Evidence to capture:

- one log or test assertion showing the link callback received the expected URL
- one screenshot or test assertion for image failure or blocked media behavior
- one smoke test of scrolling the full content surface

## Performance Checks

Run the internal app in profile mode with the validation fixture loaded.

Suggested commands from the internal app root:

```bash
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter run --profile
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter drive --profile \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/tagflow_content_trial_test.dart
```

If the internal app does not yet have an integration-test harness, capture DevTools
or Flutter performance overlay evidence while repeatedly opening and scrolling
the content surface.

Pass criteria:

- First open has no visible blank state beyond the app's accepted loading
  placeholder.
- Reopening the same content does not reparse or rebuild unnecessarily if the
  app caches content documents.
- Scrolling remains smooth enough for the app's release bar on the target
  reference device.
- No new exceptions appear in the console for unsupported tags, image errors, or
  blocked links.

Evidence to capture:

- Flutter version and target device
- profile-mode command output or DevTools trace
- before/after frame timing summary when a previous renderer exists
- content fixture size: source bytes, node count, table row count, image count

## Failure Policy

Use explicit `TagflowContentPolicy` for HTML input and app-owned registry
overrides for native documents.

Pass criteria:

- `script`, `style`, `iframe`, form inputs, `javascript:` URLs, and unapproved
  image sources are rejected or preserved as placeholders according to policy.
- Rejected links do not call the app link handler.
- Rejected images do not start network fetches.
- User-visible fallback copy is product-approved and localized if the app
  surface is localized.
- Debug-only rejection details are not visible in production builds unless the
  app intentionally exposes them.

## Rollback Plan

The validation branch must be reversible without changing Tagflow itself.

Rollback steps:

1. Remove the `dependency_overrides` entries for `tagflow` and `tagflow_table`.
2. Revert the small integration wrapper or feature flag in the internal app.
3. Run `PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter pub get`.
4. Confirm `pubspec.lock` no longer resolves Tagflow from a local path.
5. Re-run the app's focused content-surface tests.

Pass criteria:

- One revert commit restores the previous renderer or disables the Tagflow
  surface.
- No shared design-system, routing, networking, or CMS model changes are
  required to roll back.
- The validation fixture remains available for future Tagflow trials.

## Tagflow-Side Support Fixture

The example app includes an "Internal App Validation" screen that mirrors this
trial without reaching into any internal app repo. Use it as a local reference
for expected API shape:

```bash
cd /Users/arya/projects/tagflow/examples/tagflow
PATH=/Users/arya/fvm/cache.git/bin:$PATH flutter run
```

The screen exercises:

- `Tagflow.document(...)` for native app-authored content
- `TagflowComponentRegistry` with the first-party table extension
- app-owned image and unsupported-node overrides
- `TagflowViewOptions` link callback and selection behavior
- `Tagflow.html(...)` with a strict HTML policy and blocked input

## Coordinator Decision Needed

Before starting the real internal app trial, the coordinator must pick:

- the internal app and exact route/surface
- the production-like source fixture owner
- target devices and viewports
- whether the trial is native-document first, controlled-HTML first, or both
- the rollback branch owner
- the minimum evidence bundle required before beta/stable promotion
