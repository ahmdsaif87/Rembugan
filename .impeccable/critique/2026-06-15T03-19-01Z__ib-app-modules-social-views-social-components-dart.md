---
timestamp: 2026-06-15T03-19-01Z
slug: ib-app-modules-social-views-social-components-dart
---
# Critique: Social Module

**Slug:** `ib-app-modules-social-views-social-components-dart`
**Primary artifact:** `lib/app/modules/social/views/social_components.dart`
**Supporting files:**
- `lib/app/modules/social/views/comment_view.dart`
- `lib/app/modules/social/views/create_post_view.dart`
- `lib/app/modules/social/views/other_profile_view.dart`
- `lib/app/modules/social/views/notification_view.dart`
- `lib/app/modules/social/views/settings_view.dart`
- `lib/app/modules/social/views/saved_view.dart`
- `lib/app/modules/social/views/edit_profile_view.dart`
- `lib/app/modules/social/views/empty_state_view.dart`
- `lib/app/modules/social/views/loading_state_view.dart`
**Date:** 2026-06-15
**Assessor:** impeccable critique (degraded mode — spawn_agent unavailable)

---

## Assessment A — Design Review (Heuristic Evaluation)

| # | Heuristic | Score | Key observations |
|---|-----------|-------|-----------------|
| 1 | Visibility of System Status | 2/4 | `SkeletonLine` exists (demo only). No loading states in `CommentView`, `CreatePostView` submit, `NotificationView`, `OtherProfileView`. No submit indicator on "Post". |
| 2 | Match System / Real World | 3/4 | Bahasa Indonesia consistent. Familiar patterns (back nav, follow toggle, comments sheet). "Post" button uses English (minor). |
| 3 | User Control & Freedom | 2/4 | Back nav on all views via `SocialScaffold`. Follow/unfollow toggle exists. No undo for actions (like, follow). |
| 4 | Consistency & Standards | 3/4 | `SocialScaffold` provides consistent layout across views — good pattern. DS tokens used (`AppFonts`, `AppColors`, `AppRadius`). `AppSurface` with `shadow: []` matches flat direction. Missing: `SettingsView` doesn't use `SocialScaffold`. |
| 5 | Error Prevention | 2/4 | `SocialPostCard` name has `maxLines`. **No `maxLines` on `body`**. `_ProfileIdentity` bio/social link have no overflow protection. No empty-submission guard in comment or post forms. |
| 6 | Recognition vs Recall | 3/4 | Icons + labels on most actions. Familiar social patterns (avatar, name, handle, heart/chat/bookmark). Clear tab labels in `NotificationView`. |
| 7 | Flexibility & Efficiency | 1/4 | No shortcuts, no batch actions, no search or filter. Single linear pathways only. |
| 8 | Aesthetic & Minimalist | 3/4 | Clean `SocialScaffold` layout. Flat surfaces, good spacing. Pull-down bar on comment sheet. `AppTextPill` and `_Metric` well proportioned. **`SocialPostCard` body can overflow.** `GestureDetector` in `_ProfileCircleButton` lacks ripple. |
| 9 | Error Recovery | 1/4 | `AppEmptyState` exists but unused by any actual view. No retry mechanisms. No error states in data views. |
| 10 | Help & Documentation | 1/4 | No tooltips on back/more buttons. Commented-out code in `create_post_view.dart:54-56`. No onboarding or help text. |

**Total: 21/40** — Acceptable, with clear areas for focused polish.

---

## Assessment B — Detector

Flutter/Dart files are not supported by the detector (designed for web markup). Manual analysis substituted.

---

## Synthesis & Recommended Actions

### Critical (impact UX significantly, low effort)

1. **Fix `SocialPostCard` avatar** — `avatarUrl` parameter is accepted (`social_components.dart:89`) but never used; the widget always shows `AssetImage('lib/assets/img/avatar.png')` (line 115). This is dead code and a bug for any caller passing a real URL.

2. **Add `maxLines` + `overflow` to `SocialPostCard.body`** — The body text (line 148) lacks overflow protection. Long content will break the card layout.

3. **Add overflow protection to `_ProfileIdentity` bio & link** — `other_profile_view.dart:200` (bio) and line 209 (social link) have no `maxLines` or `TextOverflow.ellipsis`.

### High (impact UX moderately)

4. **Replace `GestureDetector` with `InkWell` in `_ProfileCircleButton`** — `other_profile_view.dart:155-156` uses `GestureDetector` which provides no visual press feedback. Use `InkWell` for consistency with the rest of the app (see profile module polish).

5. **Remove commented-out subtitle** — `create_post_view.dart:54-56` has a commented-out subtitle string. Either uncomment it or delete it.

6. **Add submit loading indicator to `CreatePostView`** — The "Post" button has no disabled/loading state; double-tap could submit twice.

### Medium (polish)

7. **Add `Tooltip` to `SocialScaffold` back button** — Line 38-41 uses `IconButton` without a `Tooltip`. Could say "Kembali".

8. **Consider `SettingsView` migration to `SocialScaffold`** — `settings_view.dart` builds its own custom header instead of reusing `SocialScaffold`, duplicating layout code and creating visual inconsistency.

9. **Wire `SkeletonLine` into actual data views** — Currently only used in the demo `loading_state_view.dart`. Real views (`CommentView`, `NotificationView`) show nothing during load.

10. **Add `Tooltip` to more button in `OtherProfileView`** — Line 120-122 has no tooltip on the more actions icon.

---

## Diff Snapshot

This critique covers the full social module as of 2026-06-15. The module is structurally organized with shared components in `social_components.dart` and individual views composing with `SocialScaffold`. No previous polish or critique history exists for this module.

---

## Next Run

When critiqued again, focus on whether `SocialPostCard` avatar is wired, overflow protection is added, and whether `GestureDetector` → `InkWell` migration is done. The biggest single-impact fix is the dead `avatarUrl` parameter (critical + trivial effort).
