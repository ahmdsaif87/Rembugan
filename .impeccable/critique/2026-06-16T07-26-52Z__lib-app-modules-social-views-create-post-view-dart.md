---
target: create post view
total_score: 17
p0_count: 2
p1_count: 2
timestamp: 2026-06-16T07-26-52Z
slug: lib-app-modules-social-views-create-post-view-dart
---
#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Loading spinner ✅, but no character count, no skill count in picker, no API progress |
| 2 | Match System / Real World | 3 | BI copy ✅, "Postingan"/"Tawaran" map to real concepts. "Slot" is English loanword ❌ |
| 3 | User Control and Freedom | 2 | "Selesai" button ✅, no unsaved-changes dialog, no undo |
| 4 | Consistency and Standards | 2 | Most sheets use `AppRadius.lg`, but image picker sheet uses `AppRadius.xl`. Divider alphas inconsistent (0.4 vs 0.3) |
| 5 | Error Prevention | 1 | No maxLength on post. No min skill validation. Image picker doesn't actually pick |
| 6 | Recognition Rather Than Recall | 2 | Skills in scrollable sheet — must search. "Kategori" is free text — must invent |
| 7 | Flexibility and Efficiency | 1 | No accelerators, no templates, no recent skills |
| 8 | Aesthetic and Minimalist Design | 2 | Clean but bottom bar has competing indigo elements. Dual search fields in skill picker is complex |
| 9 | Error Recovery | 2 | Validation messages ✅, no inline API error, no "you forgot skills" warning |
| 10 | Help and Documentation | 0 | No tooltips, no onboarding, no explanation of Tawaran vs Postingan |
| **Total** | | **17/40** | **Poor → Acceptable** |

#### Anti-Patterns Verdict

**LLM assessment:** Still reads as AI-generated in key areas — hardcoded user data ('Dede Fernanda', avatar asset), non-functional image picker (just closes the sheet, no actual image_picker import), `Future.delayed` as mock API call, static hardcoded major/skill lists. The visual layout improved significantly (no nested cards, borderless post field, type chips instead of big cards), but the production-readiness gaps are still the same AI tells.

**Deterministic scan:** detect.mjs returned 0 findings (expected — Dart files aren't scanned by the HTML/CSS detector).

**Visual overlays:** Not applicable (native Flutter, not web).

#### Overall Impression

The layout overhaul made a real difference — the post creation screen now follows social media conventions (borderless text area, inline type toggle, bottom action bar) and the spacing is clean. Major layout issues from the first critique are resolved. But the functional gaps remain: hardcoded user data blocks shipping, the image picker is a facade, and skills validation is missing. The score jump from 11→17 reflects real improvement, but the ceiling is capped by these production blockers.

#### What's Working

1. **Borderless post text area** — correct social media pattern. Auto-focus, expandable, no chrome. The hero it should be.
2. **Compact type pills** — Postingan/Tawaran toggle in the identity row is clean, uses less space, still clear.
3. **Bottom action bar** — thumb-friendly placement. Attachment icon + submit button is the standard mobile pattern.

#### Priority Issues

**[P0] Image picker does nothing**
**What:** `_showImagePicker` opens a sheet with two options, both just `Navigator.pop()`. No `image_picker` import, no `_images` state.
**Fix:** Import `image_picker`, add `List<XFile>? _images`, wire picker, show thumbnail.
**→ $impeccable harden**

**[P0] Hardcoded user identity**
**What:** `'Dede Fernanda'` and `'lib/assets/img/avatar.png'` are literal strings.
**Fix:** Read from auth state.
**→ $impeccable polish**

**[P1] "Kategori" is a text field, not a picker**
**What:** Free-text field where a picker/select is correct. Forces user to invent a category.
**Fix:** Make it a picker with preset options (Mobile, Web, AI/ML, Design, Research, etc.) or remove the field.
**→ $impeccable shape**

**[P1] Skill minimum not validated for offers**
**What:** Offer can be submitted with zero skills. Not in form validation scope.
**Fix:** Add check in `_handlePost`: `if (_isOffer && _skills.isEmpty) return`.
**→ $impeccable harden**

**[P2] Accessibility absent**
**What:** No `Semantics`, no labels on icon buttons, small tap targets on skill dismiss (16px vs 48px minimum).
**Fix:** Add `Semantics` widgets, increase dismiss tap target.
**→ $impeccable audit**

#### Minor Observations

- Image picker sheet uses `AppRadius.xl` (24px) while other sheets use `AppRadius.lg` (20px)
- Divider alpha inconsistent (0.4 vs 0.3)
- `SnackBar` + `Get.back()` race — if widget disposed during delay, snackbar won't show
- `_LabeledInput` vertical padding hack `maxLines > 1 ? 14 : 0` — single-line input has zero vertical padding
- Skill dismiss icon tap target is ~16px (Material minimum: 48px)
- No `autovalidateMode` — errors only show on submit
- Hardcoded major/skill lists (12 majors, 12 skills) — any backend change needs code push
