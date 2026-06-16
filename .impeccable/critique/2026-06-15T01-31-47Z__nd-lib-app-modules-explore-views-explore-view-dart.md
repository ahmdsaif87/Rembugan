---
timestamp: 2026-06-15T01-31-47Z
slug: nd-lib-app-modules-explore-views-explore-view-dart
---
## Design Health Score: 21/40 (Acceptable)

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | No loading/error/empty states; filter button has no active-count badge |
| 2 | Match System / Real World | 3 | Bahasa Indonesia throughout, student terminology accurate |
| 3 | User Control and Freedom | 3 | Filter reset, tab switching, dismissible sheets all work |
| 4 | Consistency and Standards | 2 | Mixed Material/FluentIcons; duplicate widgets (`_MatchBadge` ≈ `FeedMatchBadge`); shadow+border conflicts; dead send-icon affordance |
| 5 | Error Prevention | 2 | No loading guardrails; "Minta Bergabung"/"Daftar Lomba" fire without feedback |
| 6 | Recognition Rather Than Recall | 3 | Clear labels, icon hints, descriptive filter values |
| 7 | Flexibility and Efficiency | 2 | Search + multi-filter works; no favorites, no saved searches |
| 8 | Aesthetic and Minimalist Design | 2 | 2378-line file; duplicated widget code; _CompetitionCard deadline uses grey400 (contrast risk) |
| 9 | Error Recovery | 1 | No error/retry states anywhere |
| 10 | Help and Documentation | 1 | No onboarding or contextual help; filter subtitle helps minimally |

### Anti-Patterns Verdict

Zero anti-pattern violations detected. Design system is applied consistently (surface, border, radius tokens). No gradient text, glassmorphism, or side-stripe borders.

### Issues Found

**[P1] Mixed icon family.** 12 Material `Icons.*` used alongside `FluentIcons.*`. Critical in `_SearchBar` (search icon), `_PersonCard` (send icon — dead affordance), `_CompetitionTimelineBox` (fire/alarm icons).

**[P1] Duplicate widget classes.** `_MatchBadge` + `_StatusTone` duplicate `FeedMatchBadge` + `StatusTone` from home widgets. `_MiniChip` duplicates `FeedMiniChip`. `_ProjectAvatarStack` duplicates `FeedProjectAvatarStack`. `_showImageViewer` duplicates `image_viewer.dart`.

**[P1] Shadow + border on cards.** Project cards, person cards, and competition cards use both `border` and `boxShadow`. Home was hardened to flat (border-only). Inconsistent.

**[P2] No loading/error/empty states.** Controller loads data synchronously. User sees empty lists during load or on error. No retry mechanism.

**[P2] Grey400 contrast.** `_CompetitionCard` organizer text and `_SegmentButton` inactive tabs use `c.grey400` — likely fails WCAG AA (same issue originally in home).

**[P2] Dead send-icon affordance.** `_PersonCard` shows `Icons.send_outlined` but has no onTap (card navigates to OTHER_PROFILE). Suggests messaging but doesn't deliver.

**[P3] File size.** 2378 lines — largest in the codebase. Extract widget classes.

**[P3] Search bar uses `Icons.search` (Material)** while filter sheet uses `FluentIcons.search_24_regular`. Inconsistent within same view.
