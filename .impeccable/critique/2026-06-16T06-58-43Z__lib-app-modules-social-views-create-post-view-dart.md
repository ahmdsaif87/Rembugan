---
target: create post view
total_score: 11
p0_count: 2
p1_count: 2
timestamp: 2026-06-16T06-58-43Z
slug: lib-app-modules-social-views-create-post-view-dart
---
#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 1 | No loading/success/error feedback on "Post" tap. No character counts. No skill count display. |
| 2 | Match System / Real World | 2 | Bahasa Indonesia throughout. But "Post" button label is English; "Publik" label is unexplained. |
| 3 | User Control and Freedom | 2 | Skills can be removed. Back works. But: no undo, no discard confirmation, no preview, type switch clears all input. |
| 4 | Consistency and Standards | 1 | _AppInput ignores the design system entirely. AppTextField exists but unused. satoshiStyle/interStyle mixed. Pill-shaped button vs 12px spec. Sheet 24px radius vs 16px cap. |
| 5 | Error Prevention | 0 | Zero validation. Zero required field marks. Zero length limits. Empty form can be "submitted". |
| 6 | Recognition Rather Than Recall | 2 | Searchable major/skill pickers help. But skill list is static. No preview. No recently-used. |
| 7 | Flexibility and Efficiency | 1 | No multi-select skills (one-per-picker-trip). No custom skills. No drafts. No templates. |
| 8 | Aesthetic and Minimalist Design | 2 | Clean basic layout. But: fake-bottom-pills are deceptive. "Publik" is unnecessary. Nested card within scaffold. |
| 9 | Error Recovery | 0 | No way to undo accidental skill removal. No error messages. No retry on failure. |
| 10 | Help and Documentation | 0 | No help text, no tooltips, no explanation of "Tawaran" vs "Postingan", no "what is a slot" guidance. |
| **Total** | | **11/40** | **Poor** |

#### Anti-Patterns Verdict

**LLM assessment:** Yes, this screen would read as AI-generated or template-driven. Key tells: inputs completely ignore the design system (no filled bg, no custom borders, no focus state — defaults to Material underline), decorative non-interactive bottom pills that look tappable, mixed satoshiStyle/interStyle naming, post button uses pill radius (999px) instead of 12px spec, and zero validation states. The form looks like an unchecked prototype.

**Deterministic scan:** Ran detect.mjs against the target file — returned 0 findings. The detector is designed for HTML/CSS patterns (gradient text, glassmorphism, etc.) and does not parse Dart/Flutter code. Result is a false negative for this surface type.

**Visual overlays:** Not applicable. Target is a native Flutter mobile screen, not a web page. Browser injection is not a viable assessment path.

#### Overall Impression

The Create Post screen has solid bones — logical field order, student-appropriate copy, good use of bottom sheets for selection — but it's clearly unfinished. The most critical problems are systematic: every input on the page ignores the project's design system, there is zero form validation or feedback, and the submit button has no actual submission logic. The decorative bottom pills erode trust. This looks like a prototype that shipped without the final polish pass.

Single biggest opportunity: replace all custom inputs with the existing AppTextField from the design system, and wire up a proper form lifecycle (validation → loading → success/error).

#### What's Working

1. **Type toggle design**: The Postingan/Tawaran card toggle (AnimatedContainer, icon + title + subtitle) is a strong interaction pattern. Clear at a glance, uses indigo for active state, animated transition.

2. **Student-appropriate copy**: Hint texts are conversational and natural for Indonesian students ("Tulis update, cari anggota tim, atau bagikan progres..."). Not corporate, not childish.

3. **Bottom sheet pickers**: Searchable sheets for major/skill selection are a mobile-appropriate pattern. Filter-as-you-type, clear back navigation, visual selection feedback (checkmark).

#### Priority Issues

**[P0] Input fields ignore the entire design system**
**What:** _AppInput (L507–548) and the regular-post TextField (L194–202) don't set filled: true, don't customize enabledBorder/focusedBorder/errorBorder. Material underline default renders instead of the DESIGN.md spec (filled Cool Slate 50 bg, 1px border, 12px radius, focus → Indigo Soft + Indigo border). AppTextField already exists in codebase with correct spec — it's simply not used.
**Fix:** Replace _AppInput and raw TextField usage with AppTextField, or backfill _AppInput with proper filled OutlineInputBorder decoration.
**→ $impeccable polish**

**[P0] Zero form validation or feedback states**
**What:** No field is marked required. No validation on submit. No loading indicator. No error display. No success confirmation. The "Post" button only calls Get.back — it doesn't actually create a post.
**Fix:** Wrap in Form with GlobalKey, add validators, add loading state, pipe submit to async action with error/success handling, add discard confirmation.
**→ $impeccable harden**

**[P1] Bottom pills are decorative but look interactive**
**What:** AppTextPill (social_components.dart) has no onTap parameter. The three pills (Tambah gambar, Tandai proyek/Skill dibutuhkan) render as interactive controls but do nothing on tap.
**Fix:** Either make them functional (wire up onTap) or remove them entirely.
**→ $impeccable harden**

**[P1] "Post" button violates design system**
**What:** Uses AppRadius.pill (999px) and fontSize 13. DESIGN.md specifies 12px radius and 16px weight 600 for primary buttons.
**Fix:** Change to BorderRadius.circular(AppRadius.sm), fontSize 16, FontWeight.w600.
**→ $impeccable polish**

**[P2] Skills limited to 12 predefined options, one-per-picker-trip**
**What:** _skillOptions is a static const list. The picker lets you select one at a time, then closes. To add 5 skills = 5 modal interactions. User's actual skill (e.g. "Go", "Kotlin") can't be added.
**Fix:** Add text input for custom skill entry. Change picker to multi-select (stays open for batch selection).
**→ $impeccable shape**

#### Persona Red Flags

**Jordan (first-time poster):**
- Sees "Postingan" vs "Tawaran" with only 3-word subtitles. No tooltip or explanation. Picks wrong one. Didn't mean to make an offer.
- Skills pre-populated with "Flutter" and "UI/UX" — is Jordan supposed to know these? Removes them. Sees only 12 skill options. Their major ("Bioteknologi") isn't listed. Can't continue.
- "Slot tersisa" — what does this mean? Team capacity? The hint only says "Contoh: 2".
- Taps "Post" — nothing visible happens. No idea if it worked.

**Casey (distracted mobile):**
- Starts typing. Gets interrupted by notification. Switches away. Returns 10 minutes later — text is gone. No draft auto-save.
- Fat-fingers the back button. All input lost. No "Discard draft?" confirmation.
- Tries to tap "Tambah gambar" repeatedly — nothing happens. Assumes app is broken.
- Opens skill picker, accidentally taps an option while scrolling — picker closes immediately. Wanted to browse, not select.

**Alex (power user):**
- Needs to add 6 skills. Opens the picker 6 separate times. Each time: modal slides up → search → tap → modal slides down. 6× the friction.
- Wants to add "Go" — not in the 12-option list. Can't. Works around by typing it in the project name.
- Wants to preview the post before publishing. No preview feature.
- Spots satoshiStyle/interStyle naming inconsistency. Loses confidence in code quality.

#### Minor Observations

- Hardcoded user data ('Dede Fernanda', avatar asset) — should pull from auth state.
- Type switch (Postingan ↔ Tawaran) loses all input — no state preservation.
- Sheet titles (18px/600) vs DESIGN.md Title spec (20px/700).
- _MajorPickerSheet and _SearchablePickerSheet are ~90% identical code — should be refactored into one shared widget.
- Skill options include "React"/"Node.js" but not "React Native"/"TypeScript" — feels dated.
- No maxLength on any text field → unlimited input risk.
- 'Publik' label is unnecessary noise.

#### Questions to Consider

1. What if "Tawaran" were a separate creation flow entirely, halving the cognitive load of this screen?
2. The "Post" button calls Get.back — where's the actual create-post logic? Is this a missing controller layer?
3. Should the decorative bottom pills be removed entirely until they're functional, rather than shipping broken affordances?
4. Why does this view use local setState instead of a GetX controller when the rest of the app uses GetX everywhere?
