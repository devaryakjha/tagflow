# 2026-06-12 Non-Kite Route Candidate Audit

## Status

- Date: 2026-06-12 18:02 IST
- Coordinator branch: `codex/tagflow-native-runtime-master`
- Related gate: https://github.com/devaryakjha/tagflow/issues/73
- Posture: read-only candidate audit; no downstream repo edits, commits,
  pushes, or route-qualification claims

## Purpose

Identify whether a non-Kite local Flutter app can satisfy the #73 real-app
route gate if Kite remains unavailable through its GitLab review path.

## Commands

```bash
rg -n "tagflow|Tagflow" pubspec.yaml pubspec.lock lib test \
  -g "*.dart" -g "pubspec.yaml" -g "pubspec.lock"
```

```bash
git remote -v
git status --short --branch
```

```bash
rg -n "BlogScreen|blog/:id|video-details|GeneralVideoDetails|htmlContent|Tagflow\\(" \
  lib -g "*.dart"
```

```bash
rg -n "tagflow|Tagflow" pubspec.yaml pubspec.lock lib packages \
  -g "*.dart" -g "pubspec.yaml" -g "pubspec.lock"
```

## Findings

No non-Kite local repo qualifies for #73 right now.

### Varsity

Repo: `/Users/arya/projects/varsity-2.0`

Varsity is the strongest non-Kite technical candidate because it already has
real app-owned routes rendering rich HTML through Tagflow:

- `/blog/:id` routes to `BlogScreen`.
- `BlogScreen` renders `widget.blog.htmlContent` with `Tagflow(...)`.
- `/video-details/:id` routes to `GeneralVideoDetails`.
- quiz, certification, module, and video-module surfaces also import and render
  Tagflow content.

Varsity does not qualify now:

- `pubspec.yaml` depends on `tagflow: ^0.0.7`.
- `pubspec.lock` resolves hosted `tagflow` `0.0.7`.
- the route uses the legacy `Tagflow(html: ...)` constructor, not the current
  hosted native-runtime path such as `Tagflow.html(...)` with a semantic
  registry or `Tagflow.document(...)`;
- the remote is `git@gitlab.zerodha.tech:mobile-apps/varsity-2.0.git`, so it
  has the same source-control review blocker as Kite while GitLab DNS/access is
  unavailable from this machine.

If GitLab access is restored, Varsity `/blog/:id` is the smallest non-Kite
candidate route to evaluate. A qualifying slice would need to update Varsity to
hosted `tagflow ^1.0.0-alpha.3`, migrate the blog renderer to the current
native-runtime public path, preserve app-owned image/iframe/table behavior or
record accepted deltas, validate through the intended app route, and make the
change reviewable through the Varsity GitLab repo.

### Seisei

Repo: `/Users/arya/projects/seisei`

Seisei has a GitHub remote and an optional `seisei_tagflow` adapter that maps
`seisei_ui` blocks into `TagflowDocument`. That is useful package-adapter
evidence, but it is not currently a real downstream user route with intended
navigation, data/auth constraints, and source-control review for an app-owned
content screen. It cannot close #73 as-is.

### Pulse

Repo: `/Users/arya/projects/pulse`

Pulse is a real app with news content, but the audit found no Tagflow
dependency. Its current news surfaces are not a current Tagflow native-runtime
route and cannot close #73 without a new approved product route.

## Result

Kite remains the strongest prepared route because its local branch already
resolves hosted alpha packages and migrates the IPO sheet to the semantic
registry path. Varsity is the most plausible non-Kite fallback, but it is not
currently closer to closure because it needs both a hosted-alpha migration and
GitLab review access.

If GitLab remains unavailable, the coordinator should ask for an approved
GitHub-hosted real Flutter app route rather than treating Kite or Varsity
GitLab access as a Tagflow package blocker.
