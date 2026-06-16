# Audit: Home Module

**Target:** `lib/app/modules/home/views/home_view.dart` + widgets in `views/widgets/`
**Date:** 2026-06-15
**Audit type:** Technical quality audit

---

## Audit Health Score

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Accessibility | 2/4 | GestureDetector everywhere (no ripple); touch targets <44px; no semantic labels/images alt text; no TabBar semantics |
| 2 | Performance | 2/4 | Obx wraps entire ListView (rebuilds everything); Image.asset without caching; AnimatedContainer layout animations |
| 3 | Theming | 4/4 | Excellent — full DS token usage (AppC, AppFonts, AppColors), no hard-coded colors |
| 4 | Responsive Design | 2/4 | Fixed-width cards in horizontal lists OK; PostCard content has no maxLines overflow; HeaderIcon 24x32 <44px touch target; fixed image heights |
| 5 | Anti-Patterns | 2/4 | GestureDetector ubiquity (no ripple, codex tell); hardcoded avatar in PostCardWidget; border + shadow paired on project card; shadow at rest on competition card |
| **Total** | | **12/20** | **Acceptable (significant work needed)** |

---

## Anti-Patterns Verdict

**Borderline.** The home module uses the design system well and the overall structure is intentional. But AI tells are present:
- `GestureDetector` used instead of `InkWell` throughout — the most visible Flutter codex tell
- `PostCardWidget` accepts `avatarUrl` but shows hardcoded `AssetImage('lib/assets/img/avatar.png')` — same bug as SocialPostCard (which was fixed)
- `RecommendedProjectCard` pairs `border: Border.all()` with `boxShadow` blur 14px — ghost card pattern
- No tooltips on any icon button

---

## Detailed Findings

### P1 — Major (fix before release)

**1. [P1] GestureDetector without InkWell (5 locations)**
- **Location**: `home_view.dart:107`, `post_card_widget.dart:98,109,119,318`, `header_icon.dart:13`
- **Category**: Accessibility / Anti-Pattern
- **Impact**: Buttons and interactive areas have no visual press feedback (no ripple, no state change). This makes the app feel unresponsive to taps and fails WCAG 2.5.5 (Target Size — also fails on touch feedback expectation).
- **Recommendation**: Replace `GestureDetector` with `Material` + `InkWell` on all interactive elements. At minimum: tab buttons, post card tap, header icons, interaction items (like, comment, share, bookmark).
- **Suggested command**: `$impeccable polish home`

**2. [P1] PostCardWidget hardcoded avatar**
- **Location**: `post_card_widget.dart:113-114`
- **Category**: Anti-Pattern
- **Impact**: `avatarUrl` parameter is accepted but never used; always shows placeholder asset. This is the same bug found and fixed in `SocialPostCard` — inconsistent across the app.
- **Recommendation**: Use `avatarUrl` with `NetworkImage`/`AssetImage` fallback, matching the pattern used in the social module fix.
- **Suggested command**: `$impeccable polish home`

**3. [P1] HeaderIcon touch target too small**
- **Location**: `header_icon.dart:17-19`
- **Category**: Accessibility / Responsive
- **Impact**: `SizedBox(width: 24, height: 32)` — width is 24px vs WCAG minimum 44px. Causes missed taps, especially on mobile. WCAG 2.5.5 failure.
- **Recommendation**: Increase to minimum 44x44, or use `AppIconButton` from `app_chrome.dart` which is already 44x44.
- **Suggested command**: `$impeccable adapt home`

### P2 — Minor (fix in next pass)

**4. [P2] Obx wrapping entire ListView**
- **Location**: `home_view.dart:34-39`
- **Category**: Performance
- **Impact**: `Obx` rebuilds the entire `ListView` children when any observable changes. As the controller grows with more observables, this causes unnecessary rebuilds.
- **Recommendation**: Scope `Obx` to the specific widgets that react to changes (e.g., tab content), or use `GetX` with custom `builder`.
- **Suggested command**: `$impeccable optimize home`

**5. [P2] Post content has no overflow protection**
- **Location**: `post_card_widget.dart:198-205`
- **Category**: Responsive
- **Impact**: Post body text has no `maxLines` or `TextOverflow.ellipsis`. Very long content will push layout on narrow screens.
- **Recommendation**: Add `maxLines: 8, overflow: TextOverflow.ellipsis` to post content text.
- **Suggested command**: `$impeccable polish home`

**6. [P2] RecommendedProjectCard pairs border + shadow**
- **Location**: `recommended_project_card.dart:48-67`
- **Category**: Anti-Pattern (ghost card)
- **Impact**: `Border.all(color: c.border, width: 1)` combined with `BoxShadow(blurRadius: 14)` violates the "pick one" rule from the impeccable anti-pattern bans.
- **Recommendation**: Remove the border when shadow is present, or reduce shadow blur to ≤8px.
- **Suggested command**: `$impeccable polish home`

**7. [P2] Tab buttons use GestureDetector instead of TabBar**
- **Location**: `home_view.dart:104-132`
- **Category**: Accessibility
- **Impact**: Custom tab implementation lacks proper accessibility semantics (ARIA roles, selected state announcement). Screen readers won't identify these as tabs.
- **Recommendation**: Consider using Flutter's `TabBar`/`TabBarView` or add `Semantics` wrapper.
- **Suggested command**: `$impeccable adapt home`

### P3 — Polish (fix if time permits)

**8. [P3] Image.asset without caching**
- **Location**: `post_card_widget.dart:217,238,253`, `recommended_competition_card.dart:33`
- **Category**: Performance
- **Impact**: Assets loaded from disk on each build. Minor performance impact on low-end devices.
- **Recommendation**: Ensure assets are loaded via `precacheImage` in initState, or use `ImageCache`-aware patterns.

**9. [P3] No tooltips on header icons**
- **Location**: `header_icon.dart:13-20`
- **Category**: Accessibility
- **Impact**: Chat, alert, and search icons have no tooltip/label for users unfamiliar with icons.
- **Recommendation**: Wrap in `Tooltip` with Indonesian labels.
- **Suggested command**: `$impeccable clarify home`

**10. [P3] RecommendedCompetitionCard shadow at rest**
- **Location**: `recommended_competition_card.dart:31`
- **Category**: Anti-Pattern
- **Impact**: `AppShadows.soft` applied at rest, conflicting with the flat-by-default direction established in the team/profile module polish.
- **Recommendation**: Remove shadow at rest, add elevated shadow on hover/press via InkWell.
- **Suggested command**: `$impeccable polish home`

---

## Positive Findings

- **Excellent theming**: Every color reference goes through `AppC.of(context)` tokens. No hard-coded colors anywhere. 4/4 score well deserved.
- **Good loading/error/empty states**: `HomeView` handles loading skeletons, error state with retry button, and empty "Mengikuti" tab with CTA. This covers all major state classes correctly.
- **Clean component decomposition**: Widgets are well-separated into single-purpose files (header_icon, share_sheet, post_card_widget, etc.) making the codebase easy to navigate.
- **Reactive architecture**: Proper use of `Obx` and `RxBool` for reactive UI state.
- **Consistent DS usage**: `AppFonts.satoshiStyle`, `AppRadius`, `AppSpacing` used consistently throughout.

---

## Recommended Actions

1. **[P1] `$impeccable polish home`** — Fix GestureDetector→InkWell (5 locations), hardcoded avatar in PostCardWidget, border+shadow ghost card, shadow at rest
2. **[P1] `$impeccable adapt home`** — Fix HeaderIcon touch target to 44x44
3. **[P2] `$impeccable optimize home`** — Scope Obx rebuilds, add overflow protection to post content
4. **[P2] `$impeccable clarify home`** — Add tooltips to header icons

Run `$impeccable audit home` after fixes to see your score improve.
