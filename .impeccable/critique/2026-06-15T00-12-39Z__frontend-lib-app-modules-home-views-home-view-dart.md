---
target: home view
total_score: 22
p0_count: 0
p1_count: 3
timestamp: 2026-06-15T00-12-39Z
slug: frontend-lib-app-modules-home-views-home-view-dart
---
## Design Health Score: 22/40 (Acceptable)

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Good press/hover states & snackbars; missing loading & empty states |
| 2 | Match System / Real World | 3 | Bahasa Indonesia throughout, student terminology fits |
| 3 | User Control and Freedom | 3 | Navigation, dismiss, back all work; no trapped states |
| 4 | Consistency and Standards | 2 | Two different follow button styles; competition card bypasses `AppSurface` system |
| 5 | Error Prevention | 2 | Dead search affordance; no disabled-state clarity |
| 6 | Recognition Rather Than Recall | 3 | Standard icons, clear labels, descriptive tabs |
| 7 | Flexibility and Efficiency | 1 | No shortcuts, no bulk actions, no jump-to-section |
| 8 | Aesthetic and Minimalist Design | 3 | Clean layout; dividers between every element cause visual noise |
| 9 | Error Recovery | 1 | No error states visible anywhere; success snackbars but no failure handling |
| 10 | Help and Documentation | 1 | No empty state guidance, no onboarding context |

### Anti-Patterns Verdict

**LLM assessment:** Not AI-generated in the obvious sense — no gradient text, glassmorphism, side-stripe borders, or numbered section markers. The 1707-line monolithic file, dead search button, and "Mengikuti" tab showing identical content are telltales of a pre-production surface, not AI slop.

**Deterministic scan:** Zero anti-pattern violations found. Design tokens are used consistently.

### What's Working

1. **Spatial pacing.** Horizontal recommendation carousels break up the linear feed effectively. Scroll direction change is a natural section affordance.
2. **Design system holds.** Colors, radii, spacing, typography applied consistently. `AppC` context resolver works well for dark mode.
3. **Interaction feedback.** Press states (scale + shadow), like/bookmark toggles, snackbar confirmations.

### Priority Issues

**[P1] "Mengikuti" tab is a dead end with no empty state.** Both tabs render near-identical content. Needs an actionable empty state.
**[P1] Every piece of content is hardcoded mock data.** No loading states, no error states, no real API wiring.
**[P1] The search icon does nothing.** `onTap: () {}` is a dead affordance that erodes trust.
**[P2] Text contrast fails for secondary labels.** `c.grey400` (#9EA2AE) on white scores 2.7:1 for timestamps, inactive tabs, interaction counts.
**[P2] Two different follow button patterns.** Post cards use outlined pill; recommended people use filled button. Same action, different visual language.
**[P2] Divider on every feed item creates visual noise.** `Divider(height: 1)` between every element adds redundant clutter.
**[P2] Competition cards have both border AND shadow.** Violates the flat-by-default DESIGN.md rule.
**[P3] Recommended people card follow states lack animation.** Snaps between filled/outlined with no transition.

### Persona Red Flags

**Casey (Distracted Mobile User):** No loading skeletons → blank screen on slow connections. Fixed-height sections clip longer content. Share sheet shortcuts don't actually open WhatsApp/Telegram.

**Dimas (Active Job-Seeker):** No "Apply" affordance in home view. No filter/sort for feed. 4 posts with 2-3 users — no sense of real community.

**Riley (Stress Tester):** Fixed ListView with no pagination → crashes at scale. No image error handling. Hardcoded share sheet friend list.

### Cognitive Load

✅ Low — 0 failures. Feed is scannable with clear hierarchy and ≤4 options per item.
