# Vocabulary Zoo - v2 Task List: Game UI Improvements

This task list implements the improvements outlined in the Game UI Improvements plan. Tasks are organized into sequential PRs for systematic implementation.

---

## PR 1: Centralize Styles in Theme File

**Goal:** Move all runtime-created styles into the global theme file for consistency and maintainability.

### Task 1.1: Add Memory Card Button Styles to Theme

**File:** `assets/vocab_zoo_theme.tres`

**Actions:**
1. Open `assets/vocab_zoo_theme.tres` in text editor (or Godot theme editor)

2. Create three new StyleBoxFlat sub-resources after existing button styles (around line 62):

   **Sub-resource for face-down cards:**
   ```
   [sub_resource type="StyleBoxFlat" id="button_memory_down"]
   bg_color = Color(0.545, 0.361, 0.965, 1)  # Purple #8B5CF6
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.925, 0.282, 0.6, 1)  # Pink #EC4899
   corner_radius_top_left = 12
   corner_radius_top_right = 12
   corner_radius_bottom_right = 12
   corner_radius_bottom_left = 12
   content_margin_left = 8
   content_margin_right = 8
   content_margin_top = 8
   content_margin_bottom = 8
   ```

   **Sub-resource for face-up cards:**
   ```
   [sub_resource type="StyleBoxFlat" id="button_memory_up"]
   bg_color = Color(0.973, 0.98, 0.988, 1)  # Light #F8FAFC
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.925, 0.282, 0.6, 1)  # Pink #EC4899
   corner_radius_top_left = 12
   corner_radius_top_right = 12
   corner_radius_bottom_right = 12
   corner_radius_bottom_left = 12
   content_margin_left = 8
   content_margin_right = 8
   content_margin_top = 8
   content_margin_bottom = 8
   ```

   **Sub-resource for matched cards:**
   ```
   [sub_resource type="StyleBoxFlat" id="button_memory_matched"]
   bg_color = Color(0.063, 0.725, 0.506, 1)  # Green #10B981
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.063, 0.725, 0.506, 1)  # Green border
   corner_radius_top_left = 12
   corner_radius_top_right = 12
   corner_radius_bottom_right = 12
   corner_radius_bottom_left = 12
   content_margin_left = 8
   content_margin_right = 8
   content_margin_top = 8
   content_margin_bottom = 8
   ```

3. Save the theme file

**Reference:** Values mirror current runtime implementation in `scripts/MemoryGame.gd` lines 158-222

### Task 1.2: Add Answer Button State Styles to Theme

**File:** `assets/vocab_zoo_theme.tres`

**Actions:**
1. Add two more StyleBoxFlat sub-resources after the memory card styles:

   **Sub-resource for correct answers:**
   ```
   [sub_resource type="StyleBoxFlat" id="button_answer_correct"]
   bg_color = Color(0.063, 0.725, 0.506, 1)  # Success green #10B981
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.063, 0.725, 0.506, 1)  # Green border
   corner_radius_top_left = 16
   corner_radius_top_right = 16
   corner_radius_bottom_right = 16
   corner_radius_bottom_left = 16
   content_margin_left = 12
   content_margin_right = 12
   content_margin_top = 8
   content_margin_bottom = 8
   ```

   **Sub-resource for wrong answers:**
   ```
   [sub_resource type="StyleBoxFlat" id="button_answer_wrong"]
   bg_color = Color(0.937, 0.267, 0.267, 1)  # Error red #EF4444
   border_width_left = 3
   border_width_top = 3
   border_width_right = 3
   border_width_bottom = 3
   border_color = Color(0.937, 0.267, 0.267, 1)  # Red border
   corner_radius_top_left = 16
   corner_radius_top_right = 16
   corner_radius_bottom_right = 16
   corner_radius_bottom_left = 16
   content_margin_left = 12
   content_margin_right = 12
   content_margin_top = 8
   content_margin_bottom = 8
   ```

2. Save the theme file

**Reference:** Values mirror current runtime implementation in all quiz game scripts (MultipleChoice.gd lines 166-206, etc.)

### Task 1.3: Update MemoryGame.gd to Use Theme Styles

**File:** `scripts/MemoryGame.gd`

**Actions:**
1. At top of script, preload the theme:
   ```gdscript
   const THEME = preload("res://assets/vocab_zoo_theme.tres")
   ```

2. Remove `_style_card_face_down()` function (lines 158-178) - delete entire function

3. Remove `_style_card_face_up()` function (lines 180-200) - delete entire function

4. Remove `_style_card_matched()` function (lines 202-222) - delete entire function

5. Replace calls to these functions with theme style application:
   - In `_setup_game()` for initial cards:
     ```gdscript
     button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_down", "Button"))
     ```
   - In `_flip_card()`:
     ```gdscript
     card.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_up", "Button"))
     ```
   - In `_flip_card_back()`:
     ```gdscript
     card.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_down", "Button"))
     ```
   - In `_check_match()` for matched cards:
     ```gdscript
     card1.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_matched", "Button"))
     ```

**Expected line reduction:** ~70 lines removed

### Task 1.4: Update MultipleChoice.gd to Use Theme Styles

**File:** `scripts/MultipleChoice.gd`

**Actions:**
1. At top of script, preload the theme:
   ```gdscript
   const THEME = preload("res://assets/vocab_zoo_theme.tres")
   ```

2. Remove `_style_button_correct()` function (lines 166-185) - delete entire function

3. Remove `_style_button_wrong()` function (lines 187-206) - delete entire function

4. Update `_on_answer_pressed()` to use theme styles:
   - For correct answer:
     ```gdscript
     answer_buttons[button_index].add_theme_stylebox_override("normal", THEME.get_stylebox("button_answer_correct", "Button"))
     ```
   - For wrong answer (button clicked):
     ```gdscript
     answer_buttons[button_index].add_theme_stylebox_override("normal", THEME.get_stylebox("button_answer_wrong", "Button"))
     ```
   - For revealing correct answer when wrong selected:
     ```gdscript
     answer_buttons[q.correct_index].add_theme_stylebox_override("normal", THEME.get_stylebox("button_answer_correct", "Button"))
     ```

5. Keep `_reset_button_style()` function (already just removes overrides)

**Expected line reduction:** ~40 lines removed

### Task 1.5: Update FillInBlank.gd to Use Theme Styles

**File:** `scripts/FillInBlank.gd`

**Actions:**
Same pattern as MultipleChoice.gd:
1. Preload theme at top: `const THEME = preload("res://assets/vocab_zoo_theme.tres")`
2. Remove `_style_button_correct()` function
3. Remove `_style_button_wrong()` function
4. Update `_on_answer_pressed()` to use `THEME.get_stylebox("button_answer_correct"/"button_answer_wrong", "Button")`
5. Keep `_reset_button_style()` as-is

**Expected line reduction:** ~40 lines removed

### Task 1.6: Update SynonymAntonym.gd to Use Theme Styles

**File:** `scripts/SynonymAntonym.gd`

**Actions:**
Same pattern as other quiz games:
1. Preload theme at top: `const THEME = preload("res://assets/vocab_zoo_theme.tres")`
2. Remove `_style_button_correct()` function
3. Remove `_style_button_wrong()` function
4. Update `_on_answer_pressed()` to use `THEME.get_stylebox("button_answer_correct"/"button_answer_wrong", "Button")`
5. Keep `_reset_button_style()` as-is

**Expected line reduction:** ~40 lines removed

### Task 1.7: Update WordMatching.gd to Use Theme Styles

**File:** `scripts/WordMatching.gd`

**Actions:**
Same pattern as other quiz games:
1. Preload theme at top: `const THEME = preload("res://assets/vocab_zoo_theme.tres")`
2. Remove `_style_button_correct()` function
3. Remove `_style_button_wrong()` function
4. Update `_on_answer_pressed()` to use `THEME.get_stylebox("button_answer_correct"/"button_answer_wrong", "Button")`
5. Keep `_reset_button_style()` as-is

**Expected line reduction:** ~40 lines removed

**PR 1 Summary:** Centralizes all button and label styling into theme file, removing ~230 lines of duplicated style creation code across 5 game scripts. Scripts reference theme styles using `THEME.get_stylebox()` method.

---

## PR 2: Memory Match Card Sizing and Text Fixes

**Goal:** Fix card resizing issues, add dynamic font sizing, and ensure text contrast.

### Task 2.1: Fix Card Size Consistency

**File:** `scenes/MemoryGame.tscn`

**Actions:**
1. Open scene in Godot editor
2. Select GridContainer node
3. Verify `columns` property is set to 4 (for 4x4 grid)
4. For each of the 16 Button children in GridContainer:
   - Set `custom_minimum_size` to appropriate fixed dimensions (e.g., Vector2(140, 100) - adjust based on screen size testing)
   - Set `size_flags_horizontal` to FILL
   - Set `size_flags_vertical` to FILL
5. Ensure GridContainer has appropriate separation values for card spacing

**Testing:** Cards should maintain fixed size when flipped between face-down, face-up, and matched states.

### Task 2.2: Implement Dynamic Font Sizing for Card Text

**File:** `scripts/MemoryGame.gd`

**Actions:**

1. **Update Card class** (around line 10) - Add font_size property:
   ```gdscript
   class Card:
       var content: String
       var is_word: bool
       var pair_id: int
       var is_flipped: bool = false
       var is_matched: bool = false
       var button: Button
       var font_size: int = 18  # NEW: Store calculated font size
   ```

2. **Add new function** after `_setup_game()` (around line 91):
   ```gdscript
   func _calculate_font_size_for_card(text: String, button_size: Vector2) -> int:
       # Create temporary label for size calculation
       var temp_label = Label.new()
       temp_label.text = text
       temp_label.autowrap_mode = TextServer.AUTOWRAP_WORD
       
       # Calculate available space (button size minus padding)
       var available_width = button_size.x - 32  # 16px padding each side
       var available_height = button_size.y - 32  # 16px padding top/bottom
       
       # Start with default size and reduce until it fits
       var font_size = 18
       var min_font_size = 12
       
       while font_size >= min_font_size:
           temp_label.add_theme_font_size_override("font_size", font_size)
           temp_label.size = Vector2(available_width, 0)  # Set width constraint
           var text_size = temp_label.get_minimum_size()
           
           # Check if text fits
           if text_size.x <= available_width and text_size.y <= available_height:
               temp_label.queue_free()
               return font_size
           
           font_size -= 1
       
       # If we get here, use minimum font size
       temp_label.queue_free()
       return min_font_size
   ```

3. **Modify `_setup_game()` function** (around line 51-75) - Add font size calculation for each card:
   ```gdscript
   # After creating word_card and def_card, before appending:
   # Get button size (assuming fixed size from scene)
   var button_size = Vector2(140, 100)  # Match Task 2.1 fixed size
   
   # Calculate font sizes
   word_card.font_size = _calculate_font_size_for_card(word_card.content, button_size)
   def_card.font_size = _calculate_font_size_for_card(def_card.content, button_size)
   ```

4. **Modify `_flip_card()` function** (around line 112-122) - Apply pre-calculated font size:
   ```gdscript
   func _flip_card(card: Card) -> void:
       card.is_flipped = true
       card.button.text = card.content
       card.button.autowrap_mode = TextServer.AUTOWRAP_WORD  # Enable wrapping
       card.button.add_theme_font_size_override("font_size", card.font_size)  # Apply pre-calculated size
       _style_card_face_up(card.button)
       
       # ... rest of function unchanged
   ```

**Goal:** Ensure full text is always visible on card, never truncated. Font size flexibly adjusts to content length while maintaining readability.

**Testing:** Test with longest definitions in vocabulary.json to verify text displays completely without truncation.

### Task 2.3: Verify Card Text Contrast

**File:** `scripts/MemoryGame.gd` (verification only)

**Actions:**
1. Check that theme style `button_memory_up` uses dark text color (Colors.DARK_BASE or #1E1B2E)
2. If contrast is insufficient during testing, update theme file to use even darker color: `Color(0.1, 0.1, 0.1)`
3. Test with light backgrounds to ensure readability

**Testing:** Card text should be clearly readable on white/light backgrounds.

### Task 2.4: Investigate and Remove Visual Artifacts

**File:** `scenes/MemoryGame.tscn`

**Actions:**
1. Open scene in Godot editor
2. Examine entire scene tree for unexpected visible nodes:
   - Look for ColorRect nodes with visibility enabled that shouldn't be visible
   - Look for Sprite2D or TextureRect nodes
   - Check for Control nodes with debug visualization enabled
3. Common node names to search for: "Debug", "Placeholder", "Default", "Dot", "Point"
4. If found, either delete or set `visible = false`
5. Check z-index/z-order of nodes to ensure proper layering

**Testing:** No unintended visual elements should appear on screen during gameplay.

**PR 2 Summary:** Resolves card sizing inconsistencies, implements smart font scaling for long text, ensures text readability, and removes visual artifacts.

---

## PR 3: Answer Validation - Force Retry on Wrong Answers

**Goal:** Implement retry-until-correct behavior for quiz games while maintaining testing bypass.

### Task 3.1: Update MultipleChoice.gd Answer Validation

**File:** `scripts/MultipleChoice.gd`

**Actions:**

1. **Add encouraging feedback messages array** at top of script (after class definition, around line 24):
   ```gdscript
   var encouraging_messages = [
       "Not quite! Try again - you've got this!",
       "Keep trying! You can figure this out!",
       "Good effort! Give it another try!",
       "So close! Try a different answer!",
       "Don't give up! Try again!"
   ]
   ```

2. **Modify `_on_answer_pressed()` function** (lines 113-151):

   **Keep CORRECT answer branch unchanged** (lines 124-131):
   ```gdscript
   if button_index == q.correct_index:
       # Correct answer - KEEP AS IS
       _style_button_correct(answer_buttons[button_index])
       $FeedbackLabel.text = "Correct! 🎉"
       $FeedbackLabel.add_theme_color_override("font_color", Colors.SUCCESS)
       score += 1
       $FooterBar/ScoreLabel.text = "Score: " + str(score) + "/" + str(total_questions)
       _play_dog_celebration()
   ```

   **Change WRONG answer branch** (lines 132-151):
   ```gdscript
   else:
       # Wrong answer - NEW BEHAVIOR
       _style_button_wrong(answer_buttons[button_index])
       
       # Show encouraging feedback with random message
       var random_msg = encouraging_messages[randi() % encouraging_messages.size()]
       $FeedbackLabel.text = random_msg
       $FeedbackLabel.add_theme_color_override("font_color", Colors.WARNING)  # Orange instead of red
       _play_dog_sympathy()
       
       # Show feedback label
       $FeedbackLabel.show()
       Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
       
       # Wait briefly, then re-enable buttons for retry
       await get_tree().create_timer(0.5).timeout
       
       # Re-enable all answer buttons
       for btn in answer_buttons:
           btn.disabled = false
       
       # Reset button styles for retry
       _reset_button_style(answer_buttons[button_index])
       
       # Set is_answering to false to allow retry
       is_answering = false
       
       # DO NOT advance to next question - student must try again
       return  # Exit function without advancing
   ```

3. **After the wrong answer branch, keep the correct answer flow**:
   ```gdscript
   # Show feedback (for correct answers)
   $FeedbackLabel.show()
   Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
   
   # Wait 2 seconds, then next question (ONLY for correct answers)
   await get_tree().create_timer(2.0).timeout
   current_question_index += 1
   
   if current_question_index < total_questions:
       _display_question()
   else:
       _on_game_complete()
   ```

**Key Changes:**
- Wrong answers no longer auto-advance
- Buttons re-enable after 0.5 seconds
- Encouraging feedback in orange (not harsh red)
- Student must select correct answer to proceed
- Testing bypass via Next button still works

**Testing Note:** Next button remains enabled (testing mode), allowing testers to skip ahead without finding correct answer.

### Task 3.2: Update FillInBlank.gd Answer Validation

**File:** `scripts/FillInBlank.gd`

**Actions:**
Apply same pattern as Task 3.1:

1. **Add encouraging feedback messages array** (around line 24):
   ```gdscript
   var encouraging_messages = [
       "Not quite! Try again - you've got this!",
       "Keep trying! You can figure this out!",
       "Good effort! Give it another try!",
       "So close! Try a different answer!",
       "Don't give up! Try again!"
   ]
   ```

2. **Modify `_on_answer_pressed()` function** - Keep correct answer branch unchanged, modify wrong answer branch to:
   ```gdscript
   else:
       # Wrong answer - NEW BEHAVIOR
       _style_button_wrong(answer_buttons[button_index])
       var random_msg = encouraging_messages[randi() % encouraging_messages.size()]
       $FeedbackLabel.text = random_msg
       $FeedbackLabel.add_theme_color_override("font_color", Colors.WARNING)
       _play_rabbit_sympathy()
       $FeedbackLabel.show()
       Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
       await get_tree().create_timer(0.5).timeout
       for btn in answer_buttons:
           btn.disabled = false
       _reset_button_style(answer_buttons[button_index])
       is_answering = false
       return  # Exit without advancing
   ```

**Result:** Rabbit game enforces retry-until-correct with encouraging feedback.

### Task 3.3: Update SynonymAntonym.gd Answer Validation

**File:** `scripts/SynonymAntonym.gd`

**Actions:**
Apply same pattern with context-appropriate messages:

1. **Add context-aware encouraging feedback messages** (around line 25):
   ```gdscript
   var encouraging_messages = [
       "Not quite! Try finding another word!",
       "Keep trying! Look for the right relationship!",
       "Good effort! Try a different option!",
       "So close! Think about what the word means!",
       "Don't give up! You can find it!"
   ]
   ```

2. **Modify `_on_answer_pressed()` function** - Same pattern as Tasks 3.1 and 3.2:
   - Keep correct answer branch unchanged
   - Modify wrong answer branch to use encouraging feedback and re-enable buttons
   - Use `Colors.WARNING` for feedback color
   - Return early without advancing to next question

**Result:** Fox game enforces retry-until-correct with word relationship context.

### Task 3.4: Update WordMatching.gd Answer Validation

**File:** `scripts/WordMatching.gd`

**Actions:**
Apply same pattern:

1. **Add encouraging feedback messages** (around line 22):
   ```gdscript
   var encouraging_messages = [
       "Not quite! Try again - you've got this!",
       "Keep trying! You can figure this out!",
       "Good effort! Give it another try!",
       "So close! Try a different answer!",
       "Don't give up! Try again!"
   ]
   ```

2. **Modify `_on_answer_pressed()` function** - Same pattern as previous tasks:
   - Keep correct answer branch unchanged
   - Modify wrong answer branch with encouraging feedback and button re-enabling
   - Use `Colors.WARNING` for feedback
   - Return early without advancing

**Result:** Bird game enforces retry-until-correct with encouraging feedback.

### Task 3.5: Add Feedback Animation for Wrong Answers (Optional Polish)

**Files:** All 4 quiz game scripts

**Actions:**
Add gentle shake animation to feedback label when wrong answer is selected:
1. In wrong answer branch, create a tween
2. Animate feedback label position: +10px, -10px, back to center over 0.15 seconds
3. Makes feedback more engaging without being harsh

**Note on State Management:**
The `is_answering` flag state during retry is not a concern for this implementation. The Next button remains always enabled for testing purposes (per TESTING_CHANGES.md), allowing testers to bypass retry logic. Before production, this testing bypass will be removed by uncommenting `$NextButton.disabled = true`, at which point proper state flow will be enforced.

**PR 3 Summary:** Implements educational best practice of retry-until-correct while preserving testing bypass via Next button. Students must engage with content until they understand it.

---

## PR 4: Reposition Characters to Left Side of All Game Screens

**Goal:** Position character elements on the left side of all game screens without changing existing layout or affecting other UI elements.

### Task 4.1: Position Character on Left in MemoryGame

**Files:** `scenes/MemoryGame.tscn` and `scripts/MemoryGame.gd`

**Actions:**

1. **Verify scene structure** in `scenes/MemoryGame.tscn`:
   - Open in Godot editor (or text editor)
   - Confirm `$Character` node exists as child of root Control
   - Note its current position (likely at 0,0 or similar)

2. **Modify character creation** in `scripts/MemoryGame.gd` (around line 30):
   
   **Current code:**
   ```gdscript
   var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Colors.PRIMARY_PURPLE)
   ```
   
   **Change to:**
   ```gdscript
   var cat = CharacterHelper.create_cat($Character, Vector2(150, 350), Colors.PRIMARY_PURPLE)
   ```
   
   **Position explanation:**
   - X: 150px from left edge (gives character space on left side)
   - Y: 350px from top (approximate vertical center for 720p viewport)
   - CharacterHelper creates characters ~200-250px tall, so this centers them

3. **Optional adjustment for different viewport sizes**:
   If character doesn't appear centered vertically:
   ```gdscript
   var viewport_height = get_viewport_rect().size.y
   var char_center_y = viewport_height / 2
   var cat = CharacterHelper.create_cat($Character, Vector2(150, char_center_y), Colors.PRIMARY_PURPLE)
   ```

4. **No other changes needed:**
   - GridContainer stays in place
   - HeaderBar, FooterBar, NextButton all unchanged
   - All node references remain valid

**Result:** Cat character appears on left side. Grid and UI elements remain in their original positions. Visual: Character on left, game content center-right.

### Task 4.2: Position Character on Left in MultipleChoice

**Files:** `scenes/MultipleChoice.tscn` and `scripts/MultipleChoice.gd`

**Actions:**

1. **Modify character creation** in `scripts/MultipleChoice.gd` (around line 28):
   
   **Current:**
   ```gdscript
   var dog = CharacterHelper.create_dog($Character, Vector2.ZERO, Colors.ORANGE)
   ```
   
   **Change to:**
   ```gdscript
   var dog = CharacterHelper.create_dog($Character, Vector2(150, 350), Colors.ORANGE)
   ```

2. No scene structure changes needed

**Result:** Dog character appears on left side. Quiz panel (QuestionPanel) and buttons remain in original positions.

### Task 4.3: Position Character on Left in FillInBlank

**Files:** `scenes/FillInBlank.tscn` and `scripts/FillInBlank.gd`

**Actions:**

1. **Modify character creation** in `scripts/FillInBlank.gd` (around line 28):
   
   **Current:**
   ```gdscript
   var rabbit = CharacterHelper.create_rabbit($Character, Vector2.ZERO, Colors.PRIMARY_BLUE)
   ```
   
   **Change to:**
   ```gdscript
   var rabbit = CharacterHelper.create_rabbit($Character, Vector2(150, 350), Colors.PRIMARY_BLUE)
   ```

2. No scene structure changes needed

**Result:** Rabbit character appears on left side. Sentence panel and answer buttons remain in original positions.

### Task 4.4: Position Character on Left in SynonymAntonym

**Files:** `scenes/SynonymAntonym.tscn` and `scripts/SynonymAntonym.gd`

**Actions:**

1. **Modify character creation** in `scripts/SynonymAntonym.gd` (around line 29):
   
   **Current:**
   ```gdscript
   var fox = CharacterHelper.create_fox($Character, Vector2.ZERO, Colors.ORANGE)
   ```
   
   **Change to:**
   ```gdscript
   var fox = CharacterHelper.create_fox($Character, Vector2(150, 350), Colors.ORANGE)
   ```

2. No scene structure changes needed

**Result:** Fox character appears on left side. Question panel with synonym/antonym options remains in original position.

### Task 4.5: Position Character on Left in WordMatching

**Files:** `scenes/WordMatching.tscn` and `scripts/WordMatching.gd`

**Actions:**

1. **Modify character creation** in `scripts/WordMatching.gd` (around line 28):
   
   **Current:**
   ```gdscript
   var bird = CharacterHelper.create_bird($Character, Vector2.ZERO, Colors.PRIMARY_GREEN)
   ```
   
   **Change to:**
   ```gdscript
   var bird = CharacterHelper.create_bird($Character, Vector2(150, 350), Colors.PRIMARY_GREEN)
   ```

2. No scene structure changes needed

**Result:** Bird character appears on left side. Definition panel and word options remain in original positions.

**PR 4 Summary:** Characters are positioned on the left side of all game screens using absolute positioning (Vector2(150, 350)). No layout restructuring, no container changes, no impact on existing UI elements. All ~150+ node path references in scripts remain valid. Zero breaking changes. Total changes: 5 lines across 5 files.

---

## PR 5: End Screen Verification and Documentation Updates

**Goal:** Verify completion screen works correctly and update project documentation.

### Task 5.1: Test Completion Screen

**File:** `scenes/Completion.tscn` / `scripts/Completion.gd`

**Actions:**
1. Run through all 5 games to reach completion screen
2. Verify all 5 characters display correctly:
   - Cat (purple)
   - Dog (orange)
   - Rabbit (blue)
   - Fox (orange)
   - Bird (green)
3. Verify staggered pop-in animation works (0.1s delay between each)
4. Verify celebration animations play
5. Verify score display is accurate
6. Verify Play Again button works

**Note:** No code changes expected unless issues are discovered.

### Task 5.2: Update cursor_implementation_prompt.md

**File:** `cursor_implementation_prompt.md`

**Actions:**
1. Remove all GDScript code snippets (replace with high-level descriptions)

2. Update TASK 1 (Memory Match fixes):
   - Reference button-based cards in GridContainer (not separate card scene)
   - Reference theme styles instead of runtime style creation
   - Reference `_adjust_card_font_size()` function for dynamic sizing
   - Update to reflect implemented solutions

3. Update TASK 2 (Animal positioning):
   - Reference CharacterHelper.gd functions (create_cat, create_dog, etc.)
   - Reference HBoxContainer + LeftPanel + GameContentPanel structure
   - Remove references to "emoji placeholders" (characters are geometric shapes)
   - Reference existing Node2D character structure

4. Update TASK 3 (Answer validation):
   - Clarify retry-until-correct behavior
   - Document testing bypass (Next button always enabled)
   - Reference TESTING_CHANGES.md for how to disable bypass
   - Add encouraging feedback examples

5. Update TASK 4 (End screen):
   - Update animal list: Cat, Dog, Rabbit, Fox, Bird (not Owl)
   - Reference existing CharacterHelper implementations
   - Note that this was already implemented

6. Add new TASK 5 (Theme centralization):
   - Document the theme file approach
   - Explain benefits of centralized styling
   - Reference specific theme style IDs added

7. Update testing checklist to reflect implemented changes

### Task 5.3: Update TESTING_CHANGES.md (if needed)

**File:** `TESTING_CHANGES.md`

**Actions:**
1. Add note about answer validation testing bypass
2. Document that "always enabled Next button" allows skipping retry logic
3. Add instructions for reverting to enforce retry behavior in production
4. Clarify impact on educational effectiveness when testing mode is active

### Task 5.4: Verify Theme File Documentation

**File:** `assets/vocab_zoo_theme.tres`

**Actions:**
1. Ensure comments document the new style variations added
2. Add usage notes for memory card styles
3. Add usage notes for answer button styles
4. Document which games use which styles

**PR 5 Summary:** Validates completion screen functionality and updates all project documentation to reflect implemented changes. Ensures documentation accuracy for future development.

---

## Testing Strategy

### Per-PR Testing

**PR 1 (Theme Centralization):**
- Visual regression test: All games should look identical to before
- Verify button states (normal, hover, pressed, disabled) work correctly
- Check memory cards (face-down, face-up, matched states)
- Check answer buttons (correct, wrong feedback states)

**PR 2 (Memory Match Fixes):**
- Test with shortest and longest definitions in vocabulary.json
- Verify cards don't resize when flipping
- Verify font scales down appropriately for long text
- Verify minimum font size maintains readability
- Check for any visual artifacts on screen

**PR 3 (Answer Validation):**
- Test wrong answer behavior: buttons re-enable, no auto-advance
- Test correct answer behavior: auto-advance after 2 seconds
- Verify Next button bypass works (can skip without correct answer)
- Test all 4 quiz games
- Verify encouraging feedback displays correctly

**PR 4 (Character Repositioning):**
- Test all 5 game screens
- Verify characters appear on left side
- Verify game content is centered and properly sized
- Test on different screen sizes/aspect ratios if possible
- Verify animations (tail wiggles, wing flaps) still work

**PR 5 (Verification & Documentation):**
- Complete full game flow from start to completion screen
- Verify all 5 characters display
- Verify animations work
- Review all updated documentation for accuracy

### Integration Testing

After all PRs are merged:
1. Complete full playthrough of all 5 games
2. Verify score tracking works correctly
3. Verify vocabulary words don't repeat within playthrough
4. Test on different screen sizes
5. Verify all character animations work
6. Verify theme consistency across all screens
7. Test answer validation in all quiz games
8. Verify testing bypass (Next button) works in all games

---

## Implementation Notes

### Preserve Existing Behavior

- Do NOT modify VocabularyManager integration
- Do NOT modify GameManager score tracking
- Do NOT modify vocabulary.json structure
- Keep all existing color constants (VocabZooColors.gd)
- Keep all existing animation helpers (VocabZooConstants.gd)
- Maintain existing character creation functions (CharacterHelper.gd)

### Code Style Guidelines

- Use VocabZooColors.gd constants for all colors
- Use VocabZooConstants.gd (Anim) for all animations
- Follow existing naming conventions
- Maintain 4px borders and 12-16px corner radius for rounded elements
- Use StyleBoxFlat for all custom styling
- Add comments explaining "why" not just "what"

### Testing Mode

Remember: Next buttons are currently always enabled (TESTING_CHANGES.md). Before production release, uncomment `$NextButton.disabled = true` in all 5 game scripts to enforce proper game flow.

---

## Success Criteria

1. All game screens have consistent visual layout with characters on left
2. Memory Match cards maintain fixed size and display text properly
3. Theme file contains all button and label style variations
4. Game scripts focus on logic, not style creation (~230 lines removed)
5. Quiz games enforce retry-until-correct with encouraging feedback
6. Testing bypass remains functional via Next button
7. All animations work correctly after layout changes
8. Completion screen displays all 5 characters correctly
9. Documentation accurately reflects implemented changes
10. No visual regressions or broken functionality
