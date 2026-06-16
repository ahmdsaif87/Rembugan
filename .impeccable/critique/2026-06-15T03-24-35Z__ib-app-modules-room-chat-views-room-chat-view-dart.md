---
timestamp: 2026-06-15T03-24-35Z
slug: ib-app-modules-room-chat-views-room-chat-view-dart
---
# Critique: room_chat_view.dart

**Slug:** `ib-app-modules-room-chat-views-room-chat-view-dart`
**File:** `lib/app/modules/room_chat/views/room_chat_view.dart`
**Supporting files:**
- `lib/app/modules/room_chat/controllers/room_chat_controller.dart`
**Date:** 2026-06-15
**Assessor:** impeccable critique (degraded mode — spawn_agent unavailable)

---

## Assessment A — Design Review (Heuristic Evaluation)

| # | Heuristic | Score | Key observations |
|---|-----------|-------|-----------------|
| 1 | Visibility of System Status | 2/4 | Obx provides reactive UI. Read receipts shown. No sending indicator, no scroll-to-bottom on new message, typing status hardcoded (always "Typing..."), no connection status. |
| 2 | Match System / Real World | 3/4 | Standard chat layout (left/right bubbles). Indonesian: "Ketik pesan", "Hari ini", "Dibaca". "Typing..." is English (minor). |
| 3 | User Control & Freedom | 2/4 | Back nav works. Attachment can be removed. No edit/delete message, no undo. |
| 4 | Consistency & Standards | 3/4 | Reuses DS tokens (AppC, AppFonts, AppColors, AppRadius, AppNetworkAvatar, AppListItem, AppShadows). Obx pattern consistent. Attachment chip pattern matches workspace_detail_view. |
| 5 | Error Prevention | 2/4 | `sendMessage` has blank-text guard. No character limit. No long-press to preview/confirm. File attachment is simulated (no real picker). |
| 6 | Recognition vs Recall | 3/4 | Chat bubbles with avatar context. Read receipts clear. "Lihat Postingan" CTA. Date separator "Hari ini" for orientation. Attachment card shows type icon + name + size. |
| 7 | Flexibility & Efficiency | 1/4 | No multi-select, no search, no quick actions, no reply/forward. Single linear flow. |
| 8 | Aesthetic & Minimalist | 2/4 | Clean layout, nice shared post card, polished bottom sheet. **Dead more button** (onPressed: () {}). **GestureDetector on 3 buttons** — no ripple feedback. **Fixed width 250** on shared card may overflow. Hardcoded avatar in bubbles. |
| 9 | Error Recovery | 1/4 | No send-error handling, no retry. Attachment UI reverts gracefully on dismiss. |
| 10 | Help & Documentation | 1/4 | No tooltips on any icon. Hint text "Ketik pesan" is helpful but minimal. |

**Total: 20/40** — Acceptable, significant improvements needed in Aesthetic, Error Recovery, Help.

---

## Assessment B — Detector

Flutter/Dart files are not supported by the detector (designed for web markup). Manual analysis substituted.

---

## Synthesis & Recommended Actions

### Critical (impact UX significantly, low effort)

1. **Fix dead more button** — `room_chat_view.dart:125`: `onPressed: () {}`. Remove it or wire to a meaningful action.
2. **GestureDetector → InkWell on 3 buttons** — Lines 472 (remove attachment), 502 (plus/attach), 648 (send). Add press ripple for visual feedback.
3. **Fix hardcoded avatar in message bubbles** — `avatarUrl` is passed (line 54) but unused: lines 149-150 always show `AssetImage('lib/assets/img/avatar.png')`. Same pattern as `SocialPostCard` bug.

### High (impact UX moderately)

4. **Fix fixed width 250 on shared post card** — Line 198: `width: 250` should use `double.infinity` or `MediaQuery` to avoid overflow on narrow screens.
5. **Add scroll-to-bottom on new message** — When `messages.length` changes, auto-scroll `ListView` to the latest message with animation.
6. **Add Tooltip to back & more buttons** — AppBar leading (line 80) and actions (line 120) icon buttons lack tooltips.

### Medium (polish)

7. **Remove hardcoded "Typing..."** — Line 106-113 always shows "Typing..." regardless of actual state. Remove or make data-driven.
8. **Read receipt refinement** — Currently `isRead: true` is always passed. Either make it meaningful or simplify the UI to just show time without "Dibaca" check for own messages.
9. **Add subtle send animation** — The send button could briefly scale or change color on tap.

---

## Diff Snapshot

This is the first critique of the room_chat module. No previous polish or critique history exists.

---

## Next Run

When critiqued again, check: dead more button removed, GestureDetector→InkWell migration done, avatar wired, shared post card width fixed. Biggest single-impact: dead more button + avatarUrl fix.
