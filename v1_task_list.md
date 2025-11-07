# Vocabulary Cat v1.0 - Task List

**Based on:** v1_prd.md  
**Style Guide:** vocab_cat_style_guide.md  
**Total PRs:** 2 (Sequential)  
**Goal:** Complete implementation of PRD requirements - navigation flow with 4 game placeholders

---

## Style Guide Adherence

All implementation must follow the Vocabulary Cat Style Guide specifications:

**Reference Files:**
- `vocab_cat_style_guide.md` - Complete design specifications
- `scripts/VocabCatColors.gd` - Color constants
- `scripts/VocabCatConstants.gd` - Animation timing and spacing constants
- `assets/vocab_cat_theme.tres` - Godot theme resource

**Key Specifications:**

**Colors:**
- Use exact hex codes from VocabCatColors.gd
- Gradients at 45-135 degree angles
- Text must have 4.5:1 contrast ratio minimum

**Typography:**
- Headings: Fredoka Bold (Display 48-64px, H1 36-42px, H2 28-32px)
- Body: Nunito Regular (Body 16px, Large 18-20px, Small 14px)
- Line height: 1.4-1.6 for body, 1.2 for headings
- Letter spacing: 0.02-0.05em

**Border Radius:**
- Buttons: 12-16px (use 16px for primary)
- Cards/Panels: 16-24px (use 20px default)
- Modals: 20-28px (use 24px)
- Small elements: 8-12px

**Spacing (8px base unit):**
- Tiny: 4px, Small: 8px, Medium: 16px, Large: 24px, XLarge: 32px, XXLarge: 48px+

**Shadows:**
- Level 1: `0 2px 4px rgba(0,0,0,0.1)` (subtle)
- Level 2: `0 4px 12px rgba(0,0,0,0.15)` (buttons, cards)
- Level 3: `0 8px 24px rgba(0,0,0,0.2)` (modals, floating)
- Level 4: `0 12px 40px rgba(0,0,0,0.3)` (dramatic)
- Glow: `0 0 20px rgba(139, 92, 246, 0.6)` (hover states)

**Animations:**
- Micro-interactions: 0.1-0.15s (button press)
- UI transitions: 0.2-0.3s (fade, scale)
- Screen transitions: 0.3-0.4s
- Character animations: 0.4-0.6s
- Idle loops: 2-4s
- Easing: EASE_OUT for buttons/entrances, EASE_IN for exits, EASE_IN_OUT for loops

**Character Design:**
- Size: 200-300px tall
- Eyes: 30-40% of head size
- Outlines: 3-5px black (use 4px)
- Tail: Separate animated element, 2-second wiggle cycle
- Style: Cartoon 2D, simple shapes, round proportions

**Button Specifications:**
- Primary: Gradient purple→pink, 3px border, 12px 32px padding
- Hover: Scale 1.05, brightness 110%, add glow shadow (0.2s)
- Press: Scale 0.95 (0.1s) → 1.05 (0.15s) → 1.0 (0.1s)
- Min touch target: 44x44px

**Modal Specifications:**
- Overlay: rgba(30, 27, 46, 0.8)
- Panel: Card Background (#2D2640), 24px radius, Level 4 shadow
- Max width: 500-600px
- Padding: 32px
- Animation in: Overlay fade 0.2s, Panel scale 0.9→1.0 bounce 0.3s
- Animation out: Panel scale 0.95 fade 0.2s, Overlay fade 0.2s

**CRITICAL:** All implementation must strictly follow these style guide specifications. During code review, verify:
1. Exact hex codes are used (no color approximations)
2. Border radius values match specifications exactly
3. Animation timings match style guide durations
4. Fonts match specified families and sizes
5. Shadows use exact rgba values from style guide levels
6. Spacing follows 8px base unit system
7. All easing functions match style guide specifications

Use `VocabCatColors.gd` and `VocabCatConstants.gd` for consistency.

---

## PR 1: Core Infrastructure & Navigation Foundation

**Objective:** Establish core game architecture, main screen, modal system, and GameManager to handle flow control.

**Dependencies:** None (first PR)

### Tasks

#### 1.1 Create GameManager Singleton
**File:** `scripts/GameManager.gd`

**Implementation:**
- Create AutoLoad singleton to manage game state
- Track current game index (0-3)
- Store game metadata (names, scene paths, colors)
- Game list:
  - 0: Flashcards (Cat, #8B5CF6)
  - 1: Multiple Choice (Dog, #F97316)
  - 2: Fill-in-Blank (Rabbit, #3B82F6)
  - 3: Sentence Generation (Fox, #F97316)

**Methods:**
```gdscript
func get_current_game_name() -> String
func get_current_game_scene() -> String
func get_next_game_name() -> String
func advance_to_next_game() -> void
func reset_flow() -> void
func is_last_game() -> bool
```

**Signals:**
```gdscript
signal game_completed(game_name: String)
signal show_info_modal()
signal show_ready_modal(completed_game: String, next_game: String)
signal load_game_scene(scene_path: String)
signal show_completion_screen()
```

**Register in project.godot AutoLoad:**
```
[autoload]
GameManager="*res://scripts/GameManager.gd"
```

---

#### 1.2 Create Reusable Modal Component
**Files:** `scenes/Modal.tscn`, `scripts/Modal.gd`

**Scene Structure:**
```
Modal (Control - fullscreen anchors)
├─ Overlay (ColorRect - rgba(30,27,46,0.8), covers full screen)
├─ CenterContainer (centers content)
│  └─ ModalPanel (PanelContainer - max 600px width)
│     └─ ModalContent (VBoxContainer - 32px padding)
│        ├─ TitleLabel (Label - 32px bold)
│        ├─ BodyLabel (RichTextLabel - 18px)
│        ├─ Spacer (Control - 16px min size)
│        └─ ButtonContainer (HBoxContainer - centered)
│           └─ ActionButton (Button - gradient style)
```

**Styling (per Style Guide):**
- ModalPanel: 
  - Border radius: 24px (Modal spec)
  - Background: Card Background color (#2D2640)
  - Shadow: Level 4 `0 12px 40px rgba(0,0,0,0.3)`
  - Padding: 32px (XLarge spacing)
- TitleLabel: 
  - Font: Fredoka Bold
  - Size: 32px (H2 range 28-32px)
  - Color: #F8FAFC (Light Base, not pure white)
  - Line height: 1.2
- BodyLabel: 
  - Font: Nunito Regular
  - Size: 18px (Body Large)
  - Color: #F8FAFC
  - Line height: 1.5
  - Letter spacing: 0.03em
  - BBCode enabled
- ActionButton: 
  - Gradient: Purple→Pink (#8B5CF6 → #EC4899)
  - Border radius: 16px (Button spec)
  - Border: 3px solid #EC4899 (lighter pink)
  - Padding: 12px 32px (vertical, horizontal)
  - Font: Fredoka Bold, 20px
  - Min size: 44x44px (touch target)
  - Shadow: Level 2 `0 4px 12px rgba(0,0,0,0.15)`

**Script Features:**
```gdscript
func show_modal(title: String, body: String, button_text: String) -> void
func hide_modal() -> void
func _play_entrance_animation() -> void  # Scale 0.9→1.0, bounce
func _play_exit_animation() -> void      # Fade + scale down
signal modal_action_pressed()
signal modal_closed()
```

**Entrance Animation (per Style Guide):**
- Overlay: Fade in 0→1 opacity over 0.2s (UI transition timing)
- Panel: Scale from 0.9→1.0 with TRANS_BACK (bounce easing) over 0.3s
- Use VocabCatConstants.DURATION_UI (0.25s) for timing reference
- Easing: Tween.EASE_OUT + Tween.TRANS_BACK for bounce effect

**Exit Animation:**
- Panel: Scale to 0.95 + fade over 0.2s (Tween.EASE_IN)
- Overlay: Fade out over 0.2s
- Total exit: 0.2s (fast & snappy per style guide)

---

#### 1.3 Rebuild Main Screen
**Files:** `scenes/Main.tscn`, `scripts/Main.gd` (complete rewrite)

**Scene Structure:**
```
Main (Control - fullscreen anchors)
├─ Background (ColorRect - #1E1B2E, full screen)
├─ VBoxContainer (centered)
│  ├─ TitleLabel (Label - "Vocabulary Cat")
│  ├─ Spacer (Control - 100px min height)
│  └─ StartButton (Button - "Start")
├─ GameContainer (Control - fullscreen, initially hidden)
├─ ModalLayer (CanvasLayer - layer 10)
```

**Styling (per Style Guide):**
- Background: 
  - Color: Dark Base (#1E1B2E)
  - Full screen coverage
- TitleLabel: 
  - Font: Fredoka Bold
  - Size: 56px (Display range 48-64px)
  - Color: Primary Purple (#8B5CF6) or gradient purple→pink if possible
  - Alignment: Centered
  - Line height: 1.2
  - Text shadow: `0px 2px 4px rgba(0,0,0,0.3)` for floating effect
  - Position: Upper 1/3 of screen (per Main Menu layout)
- StartButton: 
  - Size: 200px width, 70px height (exceeds min 44x44px touch target)
  - Text: "Start" (Fredoka Bold, 24px, white #F8FAFC)
  - Background: Gradient purple→pink (#8B5CF6 → #EC4899)
  - Border: 3px solid #EC4899
  - Border radius: 16px (Button spec)
  - Padding: 12px 32px
  - Shadow: Level 2 `0 4px 12px rgba(0,0,0,0.15)`
  - Position: Centered on screen
- Hover state:
  - Scale: 1.05 (0.2s transition)
  - Shadow: Glow `0 0 20px rgba(139, 92, 246, 0.6)`
  - Brightness: 110%
  - Use VocabCatConstants.create_hover_scale() helper
- Press animation:
  - Use VocabCatConstants.animate_button_press() helper
  - Scale: 0.95 (0.1s) → 1.05 (0.15s) → 1.0 (0.1s)
  - Easing: EASE_OUT + TRANS_CUBIC

**Script Logic:**
```gdscript
extends Control

var modal_scene = preload("res://scenes/Modal.tscn")
var modal_instance = null

func _ready():
    $StartButton.pressed.connect(_on_start_pressed)
    GameManager.load_game_scene.connect(_on_load_game_scene)
    GameManager.show_info_modal.connect(_show_info_modal)
    GameManager.show_ready_modal.connect(_show_ready_modal)
    GameManager.show_completion_screen.connect(_show_completion_screen)

func _on_start_pressed():
    # Hide main menu
    $TitleLabel.hide()
    $StartButton.hide()
    # Show info modal
    _show_info_modal()

func _show_info_modal():
    modal_instance = modal_scene.instantiate()
    $ModalLayer.add_child(modal_instance)
    
    var body_text = "[center]You have [b]four awesome games[/b] to complete today:\n\n"
    body_text += "🎴 [b]Flashcards[/b] - Quick and fun!\n"
    body_text += "✅ [b]Multiple Choice[/b] - Pick the right answer\n"
    body_text += "✏️ [b]Fill-in-the-Blank[/b] - Complete the sentence\n"
    body_text += "✨ [b]Sentence Builder[/b] - Make your own sentence\n\n"
    body_text += "Ready to start? Let's go![/center]"
    
    modal_instance.show_modal("Welcome, Friend! 🎉", body_text, "Let's Go!")
    modal_instance.modal_action_pressed.connect(_on_info_modal_action)

func _on_info_modal_action():
    modal_instance.hide_modal()
    await modal_instance.modal_closed
    modal_instance.queue_free()
    # Load first game
    GameManager.advance_to_next_game()

func _show_ready_modal(completed_game: String, next_game: String):
    modal_instance = modal_scene.instantiate()
    $ModalLayer.add_child(modal_instance)
    
    var body_text = "[center]You completed [b]%s[/b]!\n\n" % completed_game
    body_text += "Are you ready for the next game?[/center]"
    
    modal_instance.show_modal("Great Job! 🎉", body_text, "Next Game")
    modal_instance.modal_action_pressed.connect(_on_ready_modal_action)

func _on_ready_modal_action():
    modal_instance.hide_modal()
    await modal_instance.modal_closed
    modal_instance.queue_free()
    GameManager.advance_to_next_game()

func _on_load_game_scene(scene_path: String):
    # Clear previous game if exists
    for child in $GameContainer.get_children():
        child.queue_free()
    
    # Load new game
    var game_scene = load(scene_path).instantiate()
    $GameContainer.add_child(game_scene)
    $GameContainer.show()

func _show_completion_screen():
    # Clear game container
    for child in $GameContainer.get_children():
        child.queue_free()
    
    # Load completion screen
    var completion_scene = load("res://scenes/Completion.tscn").instantiate()
    $GameContainer.add_child(completion_scene)
    $GameContainer.show()
```

---

#### 1.4 Update Project Configuration
**File:** `project.godot`

**Changes:**
- Add GameManager to AutoLoad section
- Verify theme application: `theme/custom="res://assets/vocab_cat_theme.tres"`
- Verify display settings:
  - Width: 1280
  - Height: 720
  - Stretch mode: canvas_items
  - Aspect: keep

---

#### 1.5 Create Placeholder Stub Files
**Files to create (empty/minimal for now, will be filled in PR2):**
- `scenes/Flashcards.tscn`
- `scenes/MultipleChoice.tscn`
- `scenes/FillInBlank.tscn`
- `scenes/SentenceGen.tscn`
- `scenes/Completion.tscn`

Each game scene should have minimal structure:
```
GameName (Control - fullscreen)
└─ Label (centered) - "Game Name Placeholder"
```

This allows PR1 to test navigation without full game implementation.

---

### PR 1 Testing Checklist

- [ ] GameManager correctly tracks game state (0-3)
- [ ] GameManager signals fire correctly
- [ ] Main screen displays with "Vocabulary Cat" title and "Start" button
- [ ] Start button has hover/press animations
- [ ] Clicking Start shows Info Modal with correct content
- [ ] Info Modal has entrance animation (scale bounce)
- [ ] Clicking "Let's Go!" closes modal and loads first game placeholder
- [ ] Modal overlay properly covers screen
- [ ] No console errors on any transition
- [ ] Theme is applied to all UI elements
- [ ] Project runs at 60fps

---

## PR 2: Game Screens, Characters & Completion

**Objective:** Implement all 4 game placeholder screens with simple character sprites, tail wiggle animations, completion screen with all characters, and full game flow integration.

**Dependencies:** PR 1 must be merged first

### Tasks

#### 2.1 Create Simple Character Drawing Helper
**File:** `scripts/CharacterHelper.gd`

**Purpose:** Shared functions to create simple geometric character sprites

**Functions:**
```gdscript
static func create_cat(parent: Node2D, center: Vector2, color: Color) -> Node2D
static func create_dog(parent: Node2D, center: Vector2, color: Color) -> Node2D
static func create_rabbit(parent: Node2D, center: Vector2, color: Color) -> Node2D
static func create_fox(parent: Node2D, center: Vector2, color: Color) -> Node2D
```

**Character Specifications (per Style Guide):**

All characters follow these design rules:
- **Total height:** 200-300px (aim for ~250px)
- **Eyes:** 30-40% of head size (use 35% as target)
- **Outlines:** 4px black (#000000) stroke around all shapes
- **Style:** Cartoon 2D, simple geometric shapes, round proportions
- **Expression:** Friendly, encouraging, never scary
- **Tail:** Separate Node2D child named "Tail" for independent animation

**Cat (Purple #8B5CF6 - Primary Purple):**
- Head: Circle (ColorRect with full corner radius) 100px diameter
- Body: Rectangle 120x80, rounded corners (20px radius)
- Eyes: 2 black circles, 35px diameter (35% of head)
- Eye spacing: 50px apart, centered on head
- Ears: 2 triangles (Polygon2D) 20px base x 30px tall, on top of head
- Tail: Separate Node2D with ColorRect 60x15, rounded ends (8px radius)
- Outline: 4px black stroke using border property or Line2D
- Total approximate height: 250px

**Dog (Orange #F97316 - Energy Orange):**
- Head: Circle 110px diameter
- Body: Rectangle 140x90, rounded corners (20px radius)
- Eyes: 2 black circles, 38px diameter (35% of head)
- Eye spacing: 55px apart
- Ears: 2 long rectangles (floppy style) 20x40, positioned on sides, rounded (8px radius)
- Tail: Separate Node2D with ColorRect 70x18, rounded (8px radius)
- Outline: 4px black stroke
- Total approximate height: 260px

**Rabbit (Blue #3B82F6 - Primary Blue):**
- Head: Circle 95px diameter
- Body: Rectangle 100x80, rounded corners (20px radius)
- Eyes: 2 black circles, 33px diameter (35% of head)
- Eye spacing: 45px apart
- Ears: 2 very long rectangles (standing) 15x70, on top of head, rounded tips (8px radius)
- Tail: Separate Node2D with small circle 25x25, full corner radius (fluffy)
- Outline: 4px black stroke
- Total approximate height: 255px (including tall ears)

**Fox (Red-Orange #F97316 with red tint):**
- Head: Circle 105px diameter
- Body: Rectangle 130x85, rounded corners (20px radius)
- Eyes: 2 black circles, 36px diameter (35% of head)
- Eye spacing: 52px apart
- Ears: 2 pointed triangles (Polygon2D) 18px base x 35px tall
- Tail: Separate Node2D with long ColorRect 80x25, fluffy (rounded 12px radius)
- Outline: 4px black stroke
- Total approximate height: 255px

**Implementation Notes:**
- Use ColorRect with corner_radius for rounded shapes
- Use Polygon2D for triangles (ears)
- Black outlines via border or Line2D around perimeter
- Position eyes to create friendly, welcoming expression
- All shapes use soft rounded corners (no sharp edges per style guide)
- Return root Node2D containing all character parts assembled

---

#### 2.2 Implement Flashcards Game (Game 1)
**Files:** `scenes/Flashcards.tscn`, `scripts/Flashcards.gd`

**Scene Structure:**
```
Flashcards (Control - fullscreen)
├─ Background (ColorRect - #8B5CF6, full screen)
├─ TitleLabel (Label - "Flashcards")
├─ ProgressLabel (Label - "1 of 4")
├─ Character (Node2D - centered at 640, 360)
│  ├─ [Cat parts created by CharacterHelper]
│  └─ Tail (Node2D - separate for animation)
├─ NextButton (Button - bottom right)
```

**Styling (per Style Guide):**
- Background: 
  - Color: Primary Purple (#8B5CF6)
  - Full screen coverage
- TitleLabel: 
  - Position: Top left (40px margin - Large spacing)
  - Font: Fredoka Semibold (or Bold)
  - Size: 28px (H2 range)
  - Color: #F8FAFC (Light Base, not pure white)
  - Line height: 1.2
  - Text shadow: `0px 2px 4px rgba(0,0,0,0.3)`
- ProgressLabel: 
  - Position: Top right (40px margin from right edge)
  - Font: Nunito Regular
  - Size: 22px (H3 range)
  - Color: #F8FAFC
- NextButton: 
  - Position: Bottom right (40px margin from edges)
  - Size: 140x60 (exceeds 44x44px min touch target)
  - Text: "Next" (Fredoka Bold, 20px, white)
  - Background: Gradient purple→pink (#8B5CF6 → #EC4899)
  - Border: 3px solid #EC4899
  - Border radius: 16px
  - Shadow: Level 2 `0 4px 12px rgba(0,0,0,0.15)`
  - Hover: Scale 1.05, glow shadow, brightness 110%
  - Press: Use VocabCatConstants.animate_button_press()

**Script:**
```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
var tail_base_x: float
var wiggle_timer: Timer

func _ready():
    # Create cat character
    var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Color("#8B5CF6"))
    tail_base_x = $Character/Tail.position.x
    
    # Setup tail wiggle timer
    wiggle_timer = Timer.new()
    wiggle_timer.wait_time = 2.0
    wiggle_timer.timeout.connect(_wiggle_tail)
    add_child(wiggle_timer)
    wiggle_timer.start()
    
    # Connect next button
    $NextButton.pressed.connect(_on_next_pressed)

func _wiggle_tail():
    # Tail wiggle per style guide: 2-second cycle, smooth sine wave, translation animation
    # Total animation: 0.75s (0.25s each direction + 0.25s return)
    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)  # Smooth loop easing per style guide
    tween.set_trans(Tween.TRANS_SINE)  # Sine wave motion
    tween.tween_property($Character/Tail, "position:x", tail_base_x + 10, 0.25)
    tween.tween_property($Character/Tail, "position:x", tail_base_x - 10, 0.25)
    tween.tween_property($Character/Tail, "position:x", tail_base_x, 0.25)

func _on_next_pressed():
    GameManager.emit_signal("game_completed", "Flashcards")
```

---

#### 2.3 Implement Multiple Choice Game (Game 2)
**Files:** `scenes/MultipleChoice.tscn`, `scripts/MultipleChoice.gd`

**Structure:** Same as Flashcards with these differences:
- Background: #F97316 (orange)
- TitleLabel: "Multiple Choice"
- ProgressLabel: "2 of 4"
- Character: Dog (using CharacterHelper.create_dog)
- Same tail wiggle logic

**Script:** Nearly identical to Flashcards.gd, with:
- Dog character instead of cat
- Signal emits "Multiple Choice" as game name

---

#### 2.4 Implement Fill-in-the-Blank Game (Game 3)
**Files:** `scenes/FillInBlank.tscn`, `scripts/FillInBlank.gd`

**Structure:** Same pattern with:
- Background: #3B82F6 (blue)
- TitleLabel: "Fill-in-the-Blank"
- ProgressLabel: "3 of 4"
- Character: Rabbit (using CharacterHelper.create_rabbit)
- Same tail wiggle logic

**Script:** Same pattern, emits "Fill-in-the-Blank"

---

#### 2.5 Implement Sentence Generation Game (Game 4)
**Files:** `scenes/SentenceGen.tscn`, `scripts/SentenceGen.gd`

**Structure:** Same pattern with:
- Background: #F97316 (orange, can be same as dog)
- TitleLabel: "Sentence Builder"
- ProgressLabel: "4 of 4"
- Character: Fox (using CharacterHelper.create_fox)
- Same tail wiggle logic

**Special behavior:** This is the last game
```gdscript
func _on_next_pressed():
    # Don't show ready modal, go straight to completion
    GameManager.emit_signal("show_completion_screen")
```

---

#### 2.6 Create Completion Screen
**Files:** `scenes/Completion.tscn`, `scripts/Completion.gd`

**Scene Structure:**
```
Completion (Control - fullscreen)
├─ Background (ColorRect - gradient purple→pink)
├─ VBoxContainer (centered)
│  ├─ TitleLabel (Label - "You Did It! 🌟")
│  ├─ MessageLabel (Label - "WOW! You completed ALL FOUR GAMES!")
│  ├─ SubtitleLabel (Label - "You're a Vocabulary Champion! 🏆")
│  ├─ Spacer (Control - 40px)
│  ├─ CharactersRow (HBoxContainer - centered, 32px spacing)
│  │  ├─ CatChar (Node2D - small version)
│  │  ├─ DogChar (Node2D - small version)
│  │  ├─ RabbitChar (Node2D - small version)
│  │  └─ FoxChar (Node2D - small version)
│  ├─ Spacer (Control - 40px)
│  └─ PlayAgainButton (Button - "Play Again")
├─ Confetti (CPUParticles2D - optional)
```

**Styling (per Style Guide):**
- Background: 
  - Gradient ColorRect: Purple→Pink (#8B5CF6 → #EC4899)
  - Angle: 45-135 degrees (per gradient usage rule)
  - Full screen coverage
- TitleLabel: 
  - Font: Fredoka Bold
  - Size: 56px (Display range 48-64px)
  - Color: #F8FAFC (Light Base)
  - Alignment: Centered
  - Line height: 1.2
  - Text shadow: `0px 2px 4px rgba(0,0,0,0.3)`
- MessageLabel: 
  - Font: Fredoka Bold
  - Size: 24px (H3 range)
  - Color: #F8FAFC
  - Alignment: Centered
- SubtitleLabel: 
  - Font: Nunito Regular
  - Size: 20px (Body Large)
  - Color: #F8FAFC
  - Alignment: Centered
  - Line height: 1.5
- Characters: 
  - Scale: 50% of normal size (~125px tall each)
  - Spacing: 32px between characters (XLarge spacing)
  - Arranged in HBoxContainer, centered
- PlayAgainButton: 
  - Size: 180x70 (exceeds 44x44px touch target)
  - Text: "Play Again" (Fredoka Bold, 20px, white)
  - Background: Gradient purple→pink (#8B5CF6 → #EC4899)
  - Border: 3px solid #EC4899
  - Border radius: 16px
  - Shadow: Level 2 `0 4px 12px rgba(0,0,0,0.15)`
  - Hover: Scale 1.05, glow shadow
  - Press: animate_button_press() helper
- Spacing between elements: Use 40px (between XLarge and XXLarge)

**Script:**
```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")

func _ready():
    _create_characters()
    _play_entrance_animation()
    $PlayAgainButton.pressed.connect(_on_play_again_pressed)

func _create_characters():
    # Create small versions of all 4 characters
    var cat = CharacterHelper.create_cat(Node2D.new(), Vector2.ZERO, Color("#8B5CF6"))
    cat.scale = Vector2(0.5, 0.5)
    $CharactersRow/CatChar.add_child(cat)
    
    var dog = CharacterHelper.create_dog(Node2D.new(), Vector2.ZERO, Color("#F97316"))
    dog.scale = Vector2(0.5, 0.5)
    $CharactersRow/DogChar.add_child(dog)
    
    var rabbit = CharacterHelper.create_rabbit(Node2D.new(), Vector2.ZERO, Color("#3B82F6"))
    rabbit.scale = Vector2(0.5, 0.5)
    $CharactersRow/RabbitChar.add_child(rabbit)
    
    var fox = CharacterHelper.create_fox(Node2D.new(), Vector2.ZERO, Color("#F97316"))
    fox.scale = Vector2(0.5, 0.5)
    $CharactersRow/FoxChar.add_child(fox)

func _play_entrance_animation():
    # SUCCESS MOMENT ANIMATION per Style Guide:
    # 1. Screen flash (white, 0.1s)
    # 2. Particle burst from center (stars/sparkles)
    # 3. Celebratory text pops in with scale bounce
    
    # 1. Screen flash (brief white overlay)
    var flash = ColorRect.new()
    flash.color = Color(1, 1, 1, 0.8)
    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(flash)
    
    var flash_tween = create_tween()
    flash_tween.tween_property(flash, "modulate:a", 0, 0.1)  # 0.1s per style guide
    flash_tween.finished.connect(func(): flash.queue_free())
    
    # 2. Title scale bounce (celebratory text pop-in)
    $TitleLabel.scale = Vector2(0.5, 0.5)
    var title_tween = create_tween()
    title_tween.set_trans(Tween.TRANS_BACK)  # Bounce easing per style guide
    title_tween.set_ease(Tween.EASE_OUT)
    title_tween.tween_property($TitleLabel, "scale", Vector2.ONE, 0.4)  # Character animation timing
    
    # 3. Characters pop in with staggered delay (scale bounce)
    for i in range(4):
        var char_node = $CharactersRow.get_child(i)
        char_node.modulate.a = 0
        char_node.scale = Vector2(0.3, 0.3)
        
        await get_tree().create_timer(0.1 * i).timeout  # 0.1s stagger
        
        var char_tween = create_tween()
        char_tween.set_parallel(true)
        char_tween.tween_property(char_node, "modulate:a", 1, 0.3)  # UI transition timing
        char_tween.tween_property(char_node, "scale", Vector2(0.5, 0.5), 0.3).set_trans(Tween.TRANS_BACK)

func _on_play_again_pressed():
    GameManager.reset_flow()
    # Return to main screen
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
```

---

#### 2.7 Update GameManager to Handle Game Flow
**File:** `scripts/GameManager.gd` (update from PR1)

**Add game completion logic:**
```gdscript
func _ready():
    game_completed.connect(_on_game_completed)

func _on_game_completed(game_name: String):
    if is_last_game():
        emit_signal("show_completion_screen")
    else:
        var next_game = get_next_game_name()
        emit_signal("show_ready_modal", game_name, next_game)
```

---

#### 2.8 Clean Up Old Files
**Delete:**
- `scenes/CatView.tscn`
- `scripts/CatView.gd`
- `scripts/CatView.gd.uid` (if exists)

---

### PR 2 Testing Checklist

**Functional Testing:**
- [ ] All 4 game screens display correctly with unique characters
- [ ] Each character has proper colors matching PRD
- [ ] Tails wiggle every 2 seconds (translation animation)
- [ ] Game titles display correctly in top left
- [ ] Progress indicators show "1 of 4", "2 of 4", "3 of 4", "4 of 4"
- [ ] Next buttons work on all game screens
- [ ] Game 1 → Ready Modal → Game 2 flow works
- [ ] Game 2 → Ready Modal → Game 3 flow works
- [ ] Game 3 → Ready Modal → Game 4 flow works
- [ ] Game 4 → Completion Screen (no ready modal)
- [ ] Ready modals display correct game names
- [ ] Completion screen shows all 4 characters
- [ ] Completion screen entrance animation plays
- [ ] Play Again button returns to Main Screen
- [ ] Full flow can be completed multiple times without errors

**Visual Testing (Style Guide Compliance):**
- [ ] All character eyes are visible and properly sized (30-40% of head per style guide)
- [ ] Character outlines are visible (4px black per style guide)
- [ ] All shapes have rounded corners (no sharp edges per style guide)
- [ ] Tail animations are smooth (no jitter)
- [ ] Background colors match exact hex codes (#8B5CF6, #F97316, #3B82F6, #1E1B2E)
- [ ] All text uses #F8FAFC (not pure white) per style guide
- [ ] Text contrast meets 4.5:1 minimum ratio (WCAG AA)
- [ ] Button borders are 3px as specified
- [ ] Button border radius is 16px
- [ ] Modal border radius is 24px
- [ ] All shadows match style guide levels (Level 2 for buttons, Level 4 for modals)
- [ ] Spacing uses 8px base unit (40px margins = Large spacing)
- [ ] No UI elements overlap or clip
- [ ] Test on 1920x1080 (16:9)
- [ ] Test on 1280x800 (16:10)
- [ ] Test on 1024x768 (4:3)

**Animation Testing:**
- [ ] Tail wiggles loop continuously every 2 seconds
- [ ] Tail translation is smooth (±10px side-to-side)
- [ ] Modal entrance animations work (scale bounce)
- [ ] Completion screen flash plays
- [ ] Completion title scales with bounce
- [ ] Characters pop in with staggered timing
- [ ] All animations run at smooth 60fps

**Edge Cases:**
- [ ] Rapidly clicking Next doesn't break flow
- [ ] Clicking modal overlay doesn't crash (if close on overlay is implemented)
- [ ] Playing through flow 3+ times in a row works correctly
- [ ] No memory leaks (characters are properly freed)

---

## Acceptance Criteria Summary

Upon completion of both PRs, the following must be true:

### Functional Requirements:
✅ Main screen displays with "Vocabulary Cat" title and "Start" button  
✅ Clicking Start shows Game Portal modal with correct content and styling  
✅ All four game placeholders implemented with unique characters (Cat, Dog, Rabbit, Fox)  
✅ Each character's tail wiggles every 2 seconds via translation animation  
✅ "Ready?" modal appears between games with actual game names inserted  
✅ Games proceed in correct order: Flashcards → Multiple Choice → Fill-in-Blank → Sentence Gen  
✅ Completion screen appears after game 4 with all 4 characters displayed  
✅ "Play Again" button returns to Main Screen and resets flow  
✅ All screens adapt to common aspect ratios (16:9, 16:10, 4:3) without clipping  
✅ All buttons have hover and press animations  
✅ All modals have entrance/exit animations  
✅ Theme is applied consistently across all screens  
✅ No console errors or warnings  
✅ Project runs at 60fps on target devices  

### Style Guide Compliance Requirements:
✅ All colors use exact hex codes from style guide (no approximations)  
✅ Text uses #F8FAFC (Light Base) instead of pure white  
✅ Text contrast meets 4.5:1 minimum ratio  
✅ All fonts are Fredoka Bold (headings) or Nunito Regular (body)  
✅ Font sizes match style guide ranges (Display 48-64px, H2 28-32px, etc.)  
✅ Button border radius is 16px (Button spec)  
✅ Modal border radius is 24px (Modal spec)  
✅ Card/Panel border radius is 20px  
✅ Button borders are 3px solid  
✅ Shadows use exact style guide levels (Level 2, Level 4)  
✅ Hover glow uses purple glow shadow specification  
✅ Spacing uses 8px base unit (40px = Large spacing)  
✅ Character eyes are 30-40% of head size  
✅ Character outlines are 4px black  
✅ All shapes have rounded corners (no sharp edges)  
✅ Gradients use 45-135 degree angles  
✅ Button hover scales to 1.05 in 0.2s  
✅ Button press animation follows 3-step pattern (0.95 → 1.05 → 1.0)  
✅ Modal entrance uses 0.3s scale with TRANS_BACK bounce  
✅ Tail wiggle uses EASE_IN_OUT + TRANS_SINE for smooth motion  
✅ All animations use specified easing (EASE_OUT for entrances, EASE_IN for exits)  
✅ Completion screen flash is exactly 0.1s  
✅ Touch targets meet 44x44px minimum  
✅ VocabCatConstants helpers are used for animations where applicable  

---

## Implementation Notes

### Color Reference
- Primary Purple: #8B5CF6
- Orange: #F97316  
- Primary Blue: #3B82F6
- Dark Base: #1E1B2E
- Primary Pink: #EC4899

### Font Reference
- Headings: Fredoka Bold
- Body: Nunito Regular
- Sizes: 56px (title), 32px (modal title), 28px (game title), 18-24px (body)

### Animation Timings (per Style Guide)
- **Button press**: 0.1s (scale to 0.95) → 0.15s (overshoot to 1.05) → 0.1s (settle to 1.0)
  - Total: 0.35s, Easing: EASE_OUT + TRANS_CUBIC
- **Button hover**: 0.2s scale to 1.05, add glow shadow
- **Modal entrance**: 0.3s scale 0.9→1.0 with TRANS_BACK (bounce), overlay fade 0.2s
- **Modal exit**: 0.2s scale to 0.95 + fade, EASE_IN
- **Tail wiggle**: 2-second interval (per timer), 0.75s animation duration
  - Movement: ±10px translation, EASE_IN_OUT + TRANS_SINE (smooth sine wave)
- **Screen transitions**: 0.3-0.4s (slide + fade)
- **Completion flash**: 0.1s white flash fade out
- **Completion text**: 0.4s scale bounce with TRANS_BACK
- **Character pop-in**: 0.3s fade + scale, staggered 0.1s delays
- **All timings align with VocabCatConstants**: DURATION_MICRO (0.125s), DURATION_UI (0.25s), etc.

### Testing Priority
1. Complete game flow (start to finish)
2. Modal animations and content
3. Character tail wiggles
4. Play Again loop
5. Responsive design across aspect ratios

---

## Post-Implementation

After both PRs are merged:
1. Run full testing checklist from PR2
2. Test on actual target devices (laptop + tablet if available)
3. Verify 60fps performance
4. Verify all acceptance criteria met
5. Document any deviations from PRD (should be none)

**Next Phase (Future):** Implement actual game logic per PRD Phase 2 roadmap

