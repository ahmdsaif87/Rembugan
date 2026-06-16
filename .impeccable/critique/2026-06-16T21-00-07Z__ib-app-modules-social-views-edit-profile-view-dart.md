---
target: edit profil
total_score: 17
p0_count: 1
p1_count: 2
p2_count: 2
timestamp: 2026-06-16T21-00-07Z
slug: ib-app-modules-social-views-edit-profile-view-dart
---
# Critique: Edit Profile View (edit_profile_view.dart)

## Anti-Patterns Verdict

**AI-generated tells detected: YES.** Satoshi font instead of Inter (system mandate), modal-as-first-thought for all 6 edit actions, EN/ID language mixing, dark AI card breaking visual consistency.

**Deterministic scan: 0 findings.** All issues are UX/font/pattern level.

## Heuristic Scores

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 1 | No loading state on save |
| 2 | Match System / Real World | 2 | EN/ID language mixing |
| 3 | User Control and Freedom | 2 | No undo, no discard |
| 4 | Consistency and Standards | 1 | Satoshi ≠ Inter |
| 5 | Error Prevention | 1 | Zero validation |
| 6 | Recognition Rather Than Recall | 3 | Icon + title pairs strong |
| 7 | Flexibility and Efficiency | 2 | 6 sheets for full edit |
| 8 | Aesthetic and Minimalist Design | 2 | Repetitive pattern, dark outlier |
| 9 | Error Recovery | 0 | No try/catch |
| 10 | Help and Documentation | 3 | Good helper text |
| **Total** | | **17/40** | **Poor** |

## Priority Issues

### P0: Satoshi font → Inter
Every text in the view uses AppFonts.satoshiStyle. Must be replaced with the Inter token.

### P1: Zero validation + no error handling
Empty name, garbage URL, huge bio accepted. API call can silently fail.

### P1: No save feedback
"Simpan" button has no loading state. Sheet closes silently.

### P2: Bottom sheet as exclusive model
6 sheets × open→edit→close = 12+ gestures. Inline editing would reduce friction ~60%.

### P2: Language inconsistency
"Personalize with AI", "Social Links", "profile" → all should be Indonesian.

## Cognitive Load
8 decision points visible (6 sections + AI card + Selesai). Skills sheet has nested StatefulBuilder + Wrap + TextField.

## Persona Red Flags
**Jordan**: No confirmation after save. AI card distracts. **Sam**: 12px text, low contrast helpers, 28px targets. **Riley**: No loading state → duplicate API calls. No error handling → silent failure.

## Minor Observations
- 28px mini edit button violates 54px min touch target
- code_24_regular icon for social link (should be link_24_regular)
- Two 28px icon buttons side by side in experience items
- AI card (grey900) is only dark card in view
- _LinkIcon uses code icon instead of link icon
