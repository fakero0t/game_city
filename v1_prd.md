# Vocabulary Zoo - Version 1.0 PRD
**Product Requirements Document**

---

## 1. Product Overview

**Product Name:** Vocabulary Zoo  
**Version:** 1.0 (MVP - Navigation Flow)  
**Target Audience:** Children aged 8-11  
**Platform:** Godot 4.x  
**Devices:** Laptops and tablets (common aspect ratios)  
**Status:** Phase 1 - Screen Flow & Placeholders

### Purpose
Create an engaging vocabulary learning game frontend that feels like **playing, not studying**. This MVP focuses on establishing the complete user flow, screen navigation, and visual foundation before implementing actual game logic.

---

## 2. User Flow

```
┌─────────────┐
│ Main Screen │
└──────┬──────┘
       │ Click "Start"
       ▼
┌─────────────────┐
│  Game Portal    │
│  (Info Modal)   │
└──────┬──────────┘
       │ Close/Continue
       ▼
┌─────────────────┐
│  Flashcards     │◄─┐
│  (Placeholder)  │  │
└──────┬──────────┘  │
       │ Click "Next" │
       ▼              │
┌─────────────────┐  │
│ "Ready?" Modal  │  │
└──────┬──────────┘  │
       │ Click "Next" │  This pattern
       ▼              │  repeats for
┌─────────────────┐  │  each game
│ Multiple Choice │  │
│  (Placeholder)  │  │
└──────┬──────────┘  │
       │              │
       ▼              │
┌─────────────────┐  │
│ "Ready?" Modal  │  │
└──────┬──────────┘  │
       │              │
       ▼              │
┌─────────────────┐  │
│ Fill-in-Blank   │  │
│  (Placeholder)  │  │
└──────┬──────────┘  │
       │              │
       ▼              │
┌─────────────────┐  │
│ "Ready?" Modal  │  │
└──────┬──────────┘  │
       │              │
       ▼              │
┌─────────────────┐  │
│ Sentence Gen    │  │
│  (Placeholder)  │──┘
└──────┬──────────┘
       │ Click "Next"
       ▼
┌─────────────────┐
│  Completion     │
│  Screen         │
└─────────────────┘
```

---

## 3. Screen Specifications

### 3.1 Main Screen

**Visual Elements:**
- Game logo/title: "Vocabulary Zoo" (top center, Fredoka Bold, 56px)
- Large "Start" button (center of screen)
- Background: `DARK_BASE` color (#1E1B2E)
- Optional: Settings icon (top right, future functionality)

**Interactions:**
- Click/tap "Start" button → Navigate to Game Portal

**Style Notes:**
- Button uses primary gradient (purple→pink)
- Button should have hover/press animations per style guide
- Logo should be colorful and inviting

---

### 3.2 Game Portal (Info Modal)

**Trigger:** Appears automatically after clicking "Start" on Main Screen

**Visual Elements:**
- Semi-transparent overlay (rgba(30, 27, 46, 0.8))
- Centered modal panel (max-width: 600px, 24px border-radius)
- Title: "Let's Play!" or "Welcome, Friend!" (32px, bold)
- Body text: "You have four awesome games to complete today!"
- List of games:
  1. 🎴 Flashcards
  2. ✅ Multiple Choice
  3. ✏️ Fill-in-the-Blank
  4. ✨ Sentence Builder
- "Let's Go!" button (bottom right)
- Optional close X (top right)

**Language Example:**
> **"Welcome, Friend! 🎉"**
> 
> You have **four awesome games** to complete today:
> 1. 🎴 **Flashcards** - Quick and fun!
> 2. ✅ **Multiple Choice** - Pick the right answer
> 3. ✏️ **Fill-in-the-Blank** - Complete the sentence
> 4. ✨ **Sentence Builder** - Make your own sentence
> 
> Ready to start? Let's go!

**Interactions:**
- Click "Let's Go!" → Close modal, show first game (Flashcards)
- Click X or outside modal → Close modal, show first game

**Animations:**
- Modal entrance: Scale from 0.9→1.0 with slight bounce (0.3s)
- Overlay fade in (0.2s)

---

### 3.3 Game Placeholder Screens (x4)

Each game has the same structure for v1:

**Games in Order:**
1. **Flashcards** (Cat character - purple/pink gradient)
2. **Multiple Choice** (Dog character - orange/yellow gradient)
3. **Fill-in-the-Blank** (Rabbit character - blue/cyan gradient)
4. **Sentence Generation** (Fox character - red/orange gradient)

**Visual Elements (per game):**
- Background: Solid color matching character theme
  - Flashcards: `PRIMARY_PURPLE`
  - Multiple Choice: `ORANGE`
  - Fill-in-Blank: `PRIMARY_BLUE`
  - Sentence Gen: Red/orange custom
- Character illustration: 200-300px tall, centered
  - 2D cartoon style, large expressive eyes
  - Thick 4px black outline
  - Facing viewer or 3/4 angle
- Game title: Top left (28px, semibold)
- "Next" button: Bottom right (gradient style)
- Optional: Progress indicator top right (e.g., "1 of 4")

**Character Animation:**
- Tail wiggles every 2 seconds (smooth sine wave motion)
- Idle loop: Subtle breathing/blinking (3-5 second cycle)
- Use AnimationPlayer for character
- Tail should be a separate node for independent animation

**Interactions:**
- Click "Next" button → Show "Ready?" modal
- For last game (Sentence Generation): "Next" → Show Completion Screen

**Technical Notes:**
- Each game should be a separate scene (e.g., `Flashcards.tscn`)
- Character sprite + tail sprite (separate for animation)
- Use `AnimationPlayer` with looping enabled for idle/tail
- Timer node triggers tail wiggle every 2 seconds

---

### 3.4 "Ready to Continue?" Modal

**Trigger:** Appears after clicking "Next" on any game (except the last one)

**Visual Elements:**
- Semi-transparent overlay
- Centered modal panel (similar style to info modal)
- Title: "Great Job! 🎉" or "Awesome! ⭐"
- Body text: "Are you ready for the next game?"
- "Next" button (center or bottom right)
- Optional: Brief encouragement ("You're doing amazing!")

**Language Example:**
> **"Great Job! 🎉"**
> 
> You completed **[Game Name]**!
> 
> Are you ready for the next game?
> 
> [Next Game Button]

**Interactions:**
- Click "Next" → Close modal, load next game in sequence
- No "back" or "skip" option in v1

**Animations:**
- Same modal entrance as info modal
- Button should have bounce animation on click

---

### 3.5 Completion Screen

**Trigger:** Appears after completing all four games

**Visual Elements:**
- Celebratory background (gradient or confetti particles)
- Large title: "You Did It! 🌟" (48-56px, bold)
- Congratulatory message (child-friendly)
- All four animal characters displayed (small, celebrating poses)
- "Play Again" button (center)
- Optional: Visual celebration effects (sparkles, confetti particles)

**Language Example:**
> **"You Did It! 🌟"**
> 
> WOW! You completed **ALL FOUR GAMES**!
> 
> You're a Vocabulary Champion! 🏆
> 
> [Play Again Button]

**Interactions:**
- Click "Play Again" → Return to Main Screen (reset flow)

**Animations:**
- Screen flash (white, 0.1s) on entry
- Particle burst from center (stars/sparkles)
- Text pops in with scale bounce
- Characters do celebration animation (jump/wiggle)
- Success sound effect

**Technical Notes:**
- Use `Particles2D` for confetti/sparkles
- 10-20 particles, 0.8-1.2s lifetime
- Colors: Match theme (purple, pink, blue, orange)

---

## 4. Technical Requirements

### 4.1 Project Structure

```
/game_city (or rename to /vocabulary_cat)
  /assets
    /fonts
      - fredoka-bold.ttf
      - nunito-regular.ttf
    /characters
      - cat.png (body)
      - cat_tail.png
      - dog.png
      - dog_tail.png
      - rabbit.png
      - rabbit_tail.png
      - fox.png
      - fox_tail.png
    /ui
      - (icons, decorative elements)
    vocab_zoo_theme.tres
  /scenes
    - Main.tscn (Main Screen)
    - GamePortal.tscn (or use modal in Main)
    - Flashcards.tscn
    - MultipleChoice.tscn
    - FillInBlank.tscn
    - SentenceGen.tscn
    - Completion.tscn
    - Modals/InfoModal.tscn
    - Modals/ReadyModal.tscn
  /scripts
    - Main.gd
    - GameManager.gd (handles flow state)
    - Flashcards.gd
    - MultipleChoice.gd
    - FillInBlank.gd
    - SentenceGen.gd
    - Completion.gd
    - VocabZooColors.gd
    - VocabZooConstants.gd
  project.godot
```

### 4.2 Scene Architecture

**Main Scene:**
- Root: `Control` node (with theme applied)
- Background: `ColorRect` (DARK_BASE)
- UI layer: `CanvasLayer` for modals
- Game container: Where game scenes are loaded

**Game Flow Manager:**
- Create `GameManager.gd` singleton (AutoLoad)
- Tracks current game index (0-3)
- Handles scene transitions
- Methods:
  - `start_game(game_index: int)`
  - `complete_game()`
  - `show_ready_modal()`
  - `reset_flow()`

### 4.3 Responsive Design

**Supported Aspect Ratios:**
- 16:9 (1920x1080, 1280x720) - Primary laptop
- 16:10 (1280x800) - MacBook
- 4:3 (1024x768) - Older tablets
- 3:2 (2160x1440) - Surface tablets

**Scaling Strategy:**
- Use `Control` anchors for layout
- Set project stretch mode: `viewport` or `canvas_items`
- Keep aspect ratio: `keep` or `expand`
- Minimum resolution: 1024x768
- Scale UI elements proportionally
- Maintain minimum touch target: 44x44px

**Project Settings:**
```
Display/Window/Size/Viewport Width: 1280
Display/Window/Size/Viewport Height: 720
Display/Window/Stretch/Mode: canvas_items
Display/Window/Stretch/Aspect: keep
```

### 4.4 Animation Specifications

**Button Press:**
- Duration: 0.1s scale to 0.95 → 0.15s to 1.05 → 0.1s to 1.0
- Easing: `EASE_OUT`, `TRANS_CUBIC`

**Modal Entrance:**
- Overlay: 0.2s fade from 0→1
- Panel: 0.3s scale from 0.9→1.0 with `TRANS_BACK`

**Screen Transitions:**
- Duration: 0.3-0.4s
- Current screen fades out while sliding left
- New screen fades in while sliding from right

**Tail Wiggle:**
- 2-second loop
- Rotate between -10° and +10° (or translate for side-to-side)
- Smooth sine wave motion
- Use `AnimationPlayer` with loop enabled

**Implementation:**
- Use `Tween` for UI animations
- Use `AnimationPlayer` for character animations
- Helper functions in `VocabZooConstants.gd`

---

## 5. Content & Copy Guidelines

### 5.1 Language Rules

**Target Reading Level:** Grade 3-5 (Ages 8-11)

**Do:**
- Use short, punchy sentences
- Use encouraging, enthusiastic tone
- Use emojis sparingly for visual interest (🎉⭐✨)
- Use "you" and direct address
- Explain actions clearly ("Click the button to continue")

**Don't:**
- Use complex vocabulary or long sentences
- Use condescending "baby talk"
- Use negative reinforcement or scary language
- Use corporate jargon ("commence," "proceed")

### 5.2 Sample Copy

**Modal Titles:**
- "Let's Play!"
- "Great Job!"
- "You Did It!"
- "Ready?"
- "Awesome!"

**Button Labels:**
- "Start" (not "Begin")
- "Let's Go!" (not "Proceed")
- "Next Game" (not "Continue")
- "Play Again" (not "Restart")

**Encouragement:**
- "You're doing amazing!"
- "Keep it up!"
- "You're a star!"
- "Way to go!"

---

## 6. Visual Design Requirements

### 6.1 Theme Application

- Apply `vocab_zoo_theme.tres` at project level
- All screens inherit base styling
- Use `VocabZooColors.gd` for custom colors
- Use `VocabZooConstants.gd` for animations

### 6.2 Character Specifications

**Style:**
- 2D cartoon, flat colors with subtle gradient
- Large expressive eyes (35-40% of head size)
- Round, huggable proportions
- 4px thick black outline
- Minimal detail, focus on silhouette

**Expressions:**
- Friendly, encouraging, never scary
- Neutral/happy idle state
- Optional: Celebration pose for completion screen

**Technical:**
- PNG with transparency
- Resolution: 512x512 or larger
- Separate body and tail sprites
- Tail pivot point at base

### 6.3 Color Usage Per Screen

- **Main Screen:** `DARK_BASE` background, purple/pink accents
- **Flashcards:** `PRIMARY_PURPLE` background, cat character
- **Multiple Choice:** `ORANGE` background, dog character
- **Fill-in-Blank:** `PRIMARY_BLUE` background, rabbit character
- **Sentence Gen:** Red/orange background, fox character
- **Completion:** Gradient background or light with confetti

---

## 7. Out of Scope for v1.0

The following are **NOT** included in this version:

❌ Actual game logic (vocabulary questions, answer validation)  
❌ User accounts or progress saving  
❌ Sound effects or background music  
❌ Settings menu (volume, accessibility)  
❌ Multiple difficulty levels  
❌ Score tracking or rewards system  
❌ Backend integration or API calls  
❌ Localization (English only)  
❌ Tutorial/onboarding flow  
❌ Pause menu or game interruption handling  

These will be addressed in future versions.

---

## 8. Acceptance Criteria

### Definition of Done:

✅ Main screen displays with functional "Start" button  
✅ Game portal modal shows with correct copy and styling  
✅ All four game placeholders are implemented with unique characters  
✅ Each character's tail wiggles every 2 seconds  
✅ "Ready?" modal appears between games with correct flow  
✅ Games proceed in correct order: Flashcards → Multiple Choice → Fill-in-Blank → Sentence Gen  
✅ Completion screen appears after all games with celebration  
✅ "Play Again" button returns to Main Screen  
✅ All screens adapt to common aspect ratios (no clipping or overlap)  
✅ All buttons have hover and press animations  
✅ All modals have entrance animations  
✅ Theme is applied consistently across all screens  
✅ No console errors or warnings  
✅ Project runs at 60fps on target devices  

---

## 9. Testing Checklist

### Functional Testing:
- [ ] Start button navigates to portal
- [ ] Portal modal can be closed
- [ ] Game 1 → Ready modal → Game 2 transition works
- [ ] Game 2 → Ready modal → Game 3 transition works
- [ ] Game 3 → Ready modal → Game 4 transition works
- [ ] Game 4 → Completion screen works
- [ ] Play Again returns to Main Screen
- [ ] Full flow can be completed multiple times

### Visual Testing:
- [ ] All text is readable on backgrounds
- [ ] Characters display correctly
- [ ] Tail animations loop smoothly
- [ ] Buttons have proper hover states
- [ ] Modals center correctly
- [ ] No UI overlap or clipping
- [ ] Test on 16:9 ratio (1920x1080)
- [ ] Test on 16:10 ratio (1280x800)
- [ ] Test on 4:3 ratio (1024x768)

### Animation Testing:
- [ ] Tail wiggles every 2 seconds consistently
- [ ] Button press animation completes
- [ ] Modal entrance is smooth (no jank)
- [ ] Screen transitions don't stutter
- [ ] Completion celebration plays fully

---

## 10. Future Roadmap (v2.0+)

### Phase 2 - Game Logic:
- Implement actual flashcard gameplay
- Implement multiple choice question system
- Implement fill-in-the-blank functionality
- Implement sentence generation UI

### Phase 3 - Polish:
- Add sound effects and music
- Add settings menu
- Add progress tracking
- Add reward system

### Phase 4 - Content:
- Connect to vocabulary API/database
- Add difficulty levels
- Add more game types
- Add customization options

---

## 11. Resources & References

- **Style Guide:** `vocab_zoo_style_guide.md`
- **Theme File:** `assets/vocab_zoo_theme.tres`
- **Color Constants:** `scripts/VocabZooColors.gd`
- **Animation Helpers:** `scripts/VocabZooConstants.gd`
- **Godot Documentation:** https://docs.godotengine.org/en/stable/

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Nov 2025 | Initial | First draft - MVP scope |

---

**Status:** ✅ Approved for Development  
**Priority:** P0 (Foundation)  
**Estimated Effort:** 2-3 development sessions

