---
target: workspace card (_WorkspaceRow)
total_score: 13
p0_count: 0
p1_count: 3
p2_count: 2
timestamp: 2026-06-16T17-52-14Z
slug: lib-app-modules-team-views-team-view-dart
---
#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Active tab shows ✅, but no loading skeletons for workspace list |
| 2 | Match System / Real World | 3 | BI copy ✅. "Workspace" is English loanword but natural in Indonesian tech |
| 3 | User Control and Freedom | 2 | Tap to enter ✅. No swipe, no reorder, no dismissal from list |
| 4 | Consistency and Standards | 1 | Ghost card: border + boxShadow on hover (DS bans pairing them). Duplicate gradient palettes. Hover tracking on mobile app |
| 5 | Error Prevention | 1 | No confirmation for navigating away. No safeguards |
| 6 | Recognition Rather Than Recall | 2 | Name visible ✅. Category badge at 9px illegible. Member initials at 8px in 20px circles unreadable |
| 7 | Flexibility and Efficiency | 0 | No swipe, no search, no batch, no shortcuts |
| 8 | Aesthetic and Minimalist Design | 1 | 4 info rows fighting. Gradient icon + shadow + border = triple decoration. Progress + percentage + activity + pills = mobile information overload |
| 9 | Error Recovery | 1 | No workspace loading error state shown in list |
| 10 | Help and Documentation | 0 | Urgency dot colors unexplained. No workspace concept help |
| **Total** | | **13/40** | **Poor** |

#### Anti-Patterns Verdict

**LLM assessment**: Not obviously AI-generated — the card is clearly custom Flutter with specific state tracking. But the gradient icons + shadows + 1px borders (ghost card pattern) and the information density suggest developer-driven design without a UX pass. Duplicate gradient palettes (2 identical pairs in 6 options) confirm rushed implementation.

**Deterministic scan**: Not available (Flutter Dart file).

#### Overall Impression

The workspace card is a dashboard-widget packed into a list-item body. It tries to show everything — identity, urgency, category, role, members, progress, activity, messages, tasks, timestamp — across 4 rows and 10+ visual elements. A workspace card's job is selection ("which workspace should I enter?"), not overview. The excess information makes every card look the same (everything is important, so nothing stands out).

#### What's Working

1. **Activity cue text** — the `activityCue`/`lastActivity` line is the most useful "should I tap this?" signal. Readable, contextual.
2. **Unread count pill** — blue badge with icon works as an attention trigger, contrasts well.
3. **Workspace name weight** — 16px/700 is appropriately prominent; overflow handled with ellipsis ✅.

#### Priority Issues

**[P1] Information overload — 4 rows where 2 would do**
**Why**: Card packs 10+ distinct visual elements across 4 rows. On 375px mobile, user must scan: icon, urgency dot, name, category badge, role, member avatars, chevron, progress bar, percentage, activity text, unread pill, task pill, timestamp. The card's job is selection, not dashboard overview.
**Fix**: Strip to identity row + single status line. Move progress bar and task metrics inside the detail view. Show task count as compact badge in identity row.
**→ $impeccable distill**

**[P1] Ghost card pattern — 1px border + boxShadow on hover**
**Why**: DESIGN.md explicitly bans pairing border + shadow on the same element. The shadow only shows on hover — irrelevant on mobile (primary platform).
**Fix**: Remove hover tracking + boxShadow entirely. Keep the 1px border at rest. If press feedback is needed, use InkWell splash only.
**→ $impeccable polish**

**[P1] Duplicate gradient palettes**
**Why**: Palettes[1] and [4] are identical (`grey900/grey700`). Palettes[2] and [5] are identical (`primary900/primary700`). 6 options with only 4 unique. Also references `AppColors.grey800` etc. which may not map to DESIGN.md tokens.
**Fix**: Deduplicate to 4 unique gradients. Better: single solid color per workspace derived from name hash — less noise, same differentiation.
**→ $impeccable polish**

**[P2] Unreadable micro-elements — 9px badge, 8px initials, 11px dot**
**Why**: Category badge at 9px is below the smallest DS token (11px). Member initials at 8px are illegible. Urgency dot at 11px is too small to convey meaning.
**Fix**: Remove category badge (integrate into name row as 11px secondary text). Replace avatar stack with member count text. Increase urgency dot to 14px.
**→ $impeccable polish**

**[P2] Hover/press animation on mobile app**
**Why**: `onHover` + `AnimatedScale(0.985)` + `AnimatedContainer` with boxShadow — all for hover/press on a mobile app. Hover never fires on phone. Scale animation is imperceptible.
**Fix**: Remove `onHover`, `_hovered`, `AnimatedScale`, `AnimatedContainer`. Simple `InkWell` with splash is sufficient.
**→ $impeccable polish**

**[P3] Member presence stack doesn't communicate**
**Why**: 20px circles with 14px overlap and 8px initials are decorative, not informative. Users can't identify members this way.
**Fix**: Show "5 anggota" text instead. More informative at smaller width.
**→ $impeccable distill**

#### Persona Red Flags

**Jordan (First-Timer)**: What does the green/amber/red dot mean? No legend, no tooltip. Why are workspace icons different colors — random or meaningful? "Workspace" itself is unexplained. After tapping a card, will they know how to get back? No visible back affordance, just the app's navigation.

**Casey (Mobile User)**: 4 rows per card means heavy scanning one-handed. The overlapping avatar stack at top-right is in the thumb zone ✅ but the 8px initials are unreadable. Progress percentage + activity + pills create a wall of text hard to parse while moving.

**Alex (Power User)**: No swipe to enter. No long-press menu. No search or filter in the workspace list. Has to enter each workspace to see task status — too many taps for 5+ workspaces.

#### Minor Observations

- `_buildMemberPresenceStack` takes ~60px width for what "5 anggota" text would do in 30px
- Progress bar uses `ClipRRect(borderRadius: 2)` — should use the radius parameter or `BorderRadius.circular(2)`
- `hasUnread` bolds activity text but doesn't add a visual unread indicator (blue dot)
- Chevron at 18px/textTertiary is appropriately muted ✅
- Name overflow uses `TextOverflow.ellipsis` ✅
- Tab buttons in the parent view use `DecoratedBox` with bottom border — follows DS borders approach ✅

#### Questions to Consider

- "What if the workspace card showed only name + last activity + unread count, and pushed progress + tasks to the detail view?"
- "What if the list had swipe-to-enter instead of tap?"
- "Does each workspace need a unique gradient icon, or would a monogram on a solid color be cleaner?"
