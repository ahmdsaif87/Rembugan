# Critique: team_view.dart

**Slug:** `lib-app-modules-team-views-team-view-dart`
**File:** `lib/app/modules/team/views/team_view.dart`
**Date:** 2026-06-15
**Assessor:** impeccable critique (degraded mode — spawn_agent unavailable)

---

## Assessment A — Design Review (Heuristic Evaluation)

Heuristic scoring (0–4 per heuristic, max 40):

| # | Heuristic | Score | Key observations |
|---|-----------|-------|-----------------|
| 1 | Visibility of System Status | 2/4 | Tab switch feedback OK via Obx; card hover OK. No loading spinner on workspace fetch; no unread-update feedback. |
| 2 | Match System / Real World | 3/4 | Bahasa Indonesia throughout (after polish). "workspace" is English but accepted in ID tech context. |
| 3 | User Control & Freedom | 2/4 | Back nav works in detail view; tabs toggle owned/joined. No edit/delete workspace from list; no leave action. |
| 4 | Consistency & Standards | 3/4 | DS colors/spacing consistent; tab indicator pattern matches home/explore (after fix). Shadow suppressed (flat-by-default). |
| 5 | Error Prevention | 2/4 | Works with local data so few error sources. Search button is dead (`onTap: () {}`). No confirm on destructive actions. |
| 6 | Recognition vs Recall | 3/4 | Icons + labels everywhere; member presence stack; progress bar; task count visible. |
| 7 | Flexibility & Efficiency | 1/4 | No shortcuts, no batch actions, search is dead. Single pathway: tap card → detail. |
| 8 | Aesthetic & Minimalist | 3/4 | Clean cards, restrained palette, gradient workspace icons. Empty state basic; member avatars retain shadow (minor). |
| 9 | Error Recovery | 2/4 | Detail view graceful (`SizedBox.shrink`) but uninformative. No explicit error states. |
| 10 | Help & Documentation | 1/4 | No tooltips, no help, search button is dead. |

**Total: 22/40** — Acceptable, with clear improvement areas.

---

## Assessment B — Detector

Flutter/Dart files are not supported by the detector (designed for web markup). No issues auto-detected. Manual analysis substituted.

---

## Synthesis & Recommended Actions

### Critical (impact UX significantly, low effort)
1. **Fix dead search button** — `team_view.dart:96` has an `onTap: () {}` that does nothing. Remove it or wire it to a search overlay/route.
2. **Add loading states** — `TeamView` currently shows nothing while workspaces load. A shimmer placeholder would improve perceived performance.
3. **Fix member avatar shadows** — The `_MemberPresenceStack` applies shadow to each avatar ring, which violates the flat-by-default direction from the polish pass. Remove shadow or apply only on hover.

### High (impact UX moderately)
4. **Default empty states** — The empty workspace views (`_EmptyWorkspace`) use `size: 56` icon in `grey400`. Make them more inviting: use a larger illustration, add a CTA button ("Buat workspace").
5. **Detail view null state** — When `selectedWorkspace` is null, `SizedBox.shrink()` is invisible to the user. Show a skeleton or a message.
6. **Remove unused imports / code** — The `team_controller.dart` import is used, but verify no dead code remains.

### Medium (polish)
7. **Add tooltip to action icons** — `FluentIcons.more_horizontal_24_regular` in the AppBar has no `Tooltip`.
8. **Inactive state enhancement** — The `_Tabs` widget's inactive text color is now `textSecondary`, which is better but could use a subtle icon dimming for disabled tabs.
9. **MemberPresenceStack shadow** — Consider removing shadow from online indicator dots too for consistency.

---

## Diff Snapshot

This critique was taken after the polish pass that:
- Removed shadow at rest from workspace cards (flat-by-default, border only)
- Fixed tab indicator height 2.5→2.0 px
- Changed inactive text grey400→grey500
- Fixed role text grey400→textSecondary
- Fixed "unread"→"belum dibaca", "task"→"tugas"
- Removed unused `_FileTab` from workspace_detail_view

---

## Next Run

When this target is critiqued again, compare scores to validate improvement. The biggest single-impact item is wiring up the search button (critical + low effort).
