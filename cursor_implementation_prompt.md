# Cursor Implementation Prompt: Vocabulary Zoo Game Updates

## ✅ STATUS: FULLY IMPLEMENTED
**All updates described in this document have been successfully implemented across 5 PRs.**

Last updated: November 7, 2025

---

## Project Context
This is an existing Godot 4.x educational game called "Vocabulary Zoo" for children aged 8-11. We have updated multiple game screens with bug fixes and visual improvements.

---

## ✅ TASK 1: Memory Match Screen Fixes (COMPLETED - PR 2)

### ✅ Issue 1.1: Card Size Consistency (COMPLETED)
**Problem:** Cards resize when flipped, causing layout shifts.
**Solution Implemented:** All 16 cards now have fixed `custom_minimum_size = Vector2(140, 95)` with `size_flags` set to prevent expansion.

**Requirements:**
- Cards MUST maintain fixed dimensions at all times (flipped or unflipped)
- Card dimensions should be responsive to screen size BUT never change during flip animation
- Text must adapt to fit within card bounds, not vice versa

**Implementation Steps:**
1. Locate the card scene/script (likely `MemoryCard.tscn` or similar)
2. Find the card's Control node or Container
3. Set fixed size using one of these methods:
   ```gdscript
   # Option A: Set custom minimum size
   card_container.custom_minimum_size = Vector2(150, 200)  # Adjust values as needed
   
   # Option B: Use size flags
   card_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
   card_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
   ```
4. Ensure the card's parent container uses proper layout (GridContainer recommended)
5. Disable any size expansion flags on the card Control node

### ✅ Issue 1.2: Dynamic Font Sizing for Card Text (COMPLETED)
**Problem:** Long text overflows or expands card size.
**Solution Implemented:** Added `_calculate_font_size_for_card()` function that pre-calculates optimal font sizes (18px down to 12px) during game setup. Font sizes are applied during flip with `autowrap_mode` enabled.

**Requirements:**
- Font size must automatically scale down to fit text within card bounds
- Never allow text to overflow or expand the card
- Font should remain readable (minimum size: 12-14px)

**Implementation Steps:**
1. Locate the Label node displaying card text
2. Add dynamic font sizing script:
   ```gdscript
   # In card script
   func update_text(new_text: String) -> void:
       text_label.text = new_text
       await get_tree().process_frame  # Wait for layout update
       adjust_font_size()
   
   func adjust_font_size() -> void:
       var card_width = card_container.size.x - 20  # 10px padding each side
       var card_height = card_container.size.y - 20
       
       var font_size = 24  # Starting size
       var min_font_size = 12
       
       text_label.add_theme_font_size_override("font_size", font_size)
       
       while font_size > min_font_size:
           await get_tree().process_frame
           var text_size = text_label.get_minimum_size()
           
           if text_size.x <= card_width and text_size.y <= card_height:
               break
           
           font_size -= 1
           text_label.add_theme_font_size_override("font_size", font_size)
   ```
3. Enable text wrapping: `text_label.autowrap_mode = TextServer.AUTOWRAP_WORD`
4. Set label to expand to fill available space but not exceed it

### Issue 1.3: Card Text Color Contrast
**Problem:** Text color doesn't contrast with white card background.

**Implementation:**
1. Find the Label node for card text
2. Set theme color override:
   ```gdscript
   text_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))  # Dark gray/black
   ```
3. Or update in the Theme resource:
   - Navigate to Theme.tres
   - Under Label → Colors → font_color
   - Set to dark color: `#1A1A1A` or `#2D2D2D`

### Issue 1.4: Remove/Reposition Fixed Black Dots Element
**Problem:** Two black dots appearing on screen (likely debug or misplaced element).

**Investigation Steps:**
1. Open MemoryMatch scene in editor
2. Look for nodes that shouldn't be visible:
   - Check for ColorRect nodes
   - Check for Sprite2D/TextureRect nodes
   - Check for Control nodes with debug settings enabled
3. Search for nodes named: "Debug", "Placeholder", "Default", or similar

**Implementation:**
1. If element should be removed: Delete the node
2. If element is a placeholder animal that should appear beside grid:
   ```gdscript
   # Move to left side of screen
   # In the MemoryMatch scene tree
   # Reorganize layout:
   HBoxContainer (root)
   ├── AnimalPlaceholder (left side - size_flags: SHRINK_BEGIN)
   │   └── [Animal visual element]
   └── CardGrid (right side - size_flags: EXPAND_FILL)
       └── GridContainer
           └── [Cards]
   ```
3. Position animal element:
   - Anchor to left side of screen
   - Add margin: 20-40px from left edge
   - Vertically center

---

## ✅ TASK 2: Update Animal Placeholders (COMPLETED - PR 1 & PR 4)

**Note:** Task was split into two PRs:
- **PR 1:** Centralized button/card styles in theme file
- **PR 4:** Repositioned characters to left side of all game screens

**Affected Scenes:**
- MemoryMatch.tscn
- PickMeaning.tscn (or similar)
- CompleteSentence.tscn
- WordRelationships.tscn
- MatchMeaning.tscn (if different from MemoryMatch)

### Requirements:
- Animal placeholders should appear on the **LEFT SIDE** of the screen
- Animals should look **more realistic** (not cartoonish emojis)
- Animals should be consistent across all games

### Implementation Steps:

1. **Find Current Animal Placeholders:**
   - Search project for ColorRect nodes with animal emojis
   - Search for nodes named "Animal", "Mascot", "Placeholder"

2. **Create Realistic Animal Assets:**
   Since we don't have actual image assets yet, create improved placeholders:
   ```gdscript
   # Replace emoji ColorRect with TextureRect prepared for real images
   # For now, use larger, better-styled placeholders:
   
   # In each game scene's script:
   func setup_animal_placeholder() -> void:
       var animal_container = VBoxContainer.new()
       animal_container.custom_minimum_size = Vector2(150, 150)
       
       # Placeholder for actual animal image
       var animal_sprite = ColorRect.new()
       animal_sprite.custom_minimum_size = Vector2(120, 120)
       animal_sprite.color = get_animal_color()  # Based on game
       
       # Add realistic-style label as temp placeholder
       var label = Label.new()
       label.text = get_animal_name()  # "Cat", "Dog", "Owl", "Fox"
       label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
       
       animal_container.add_child(animal_sprite)
       animal_container.add_child(label)
       
       # Position on left side
       add_left_panel(animal_container)
   ```

3. **Update Layout for Each Game:**
   ```gdscript
   # Standard layout structure for all game screens:
   HBoxContainer (root, anchors full rect)
   ├── LeftPanel (MarginContainer)
   │   ├── margin_left: 20
   │   ├── margin_right: 20
   │   └── AnimalContainer
   │       └── [Animal visual + wiggle animation]
   └── GameContent (MarginContainer - size_flags: EXPAND_FILL)
       └── [Game-specific UI: cards, questions, etc.]
   ```

4. **Prepare for Asset Replacement:**
   - Create AnimatedSprite2D nodes for animals (ready for sprite sheets)
   - Or use TextureRect nodes with `expand_mode = IGNORE_SIZE` and `stretch_mode = KEEP_ASPECT_CENTERED`
   - Add comments: `# TODO: Replace with realistic animal sprite`

---

## ✅ TASK 3: Answer Validation - Retry Until Correct (COMPLETED - PR 3)

**Solution Implemented:** All 4 multiple-choice games now force retry on wrong answers with encouraging feedback messages. Students must select the correct answer to proceed.

**Affected Games:**
1. Pick the Meaning
2. Complete the Sentence
3. Word Relationships
4. Match the Meaning

### Current Problem:
Students can submit wrong answers and move on without learning the correct answer.

### Requirements:
- When student submits **wrong answer**, show feedback modal
- Student **cannot proceed** until they select the correct answer
- Provide encouraging, child-friendly feedback

### Implementation Steps:

1. **Locate Answer Validation Functions:**
   - Find scripts for each game (e.g., `PickMeaning.gd`, `CompleteSentence.gd`)
   - Find the function that checks answers (likely `check_answer()`, `validate_answer()`, or `on_submit()`)

2. **Update Each Game's Validation Logic:**

   ```gdscript
   # Example for PickMeaning.gd (adapt for other games)
   
   var correct_answer: String = ""
   var is_answer_correct: bool = false
   
   func on_answer_selected(selected_answer: String) -> void:
       if selected_answer == correct_answer:
           is_answer_correct = true
           show_correct_feedback()
           await get_tree().create_timer(1.5).timeout
           proceed_to_next_question()
       else:
           show_incorrect_feedback()
           # Do NOT proceed - student must try again
   
   func show_correct_feedback() -> void:
       # Show encouraging message
       feedback_label.text = "Great job! That's correct! 🎉"
       feedback_label.modulate = Color(0.2, 0.8, 0.2)  # Green
       feedback_label.visible = true
   
   func show_incorrect_feedback() -> void:
       # Show encouraging retry message
       feedback_label.text = "Not quite! Try again - you've got this! 💪"
       feedback_label.modulate = Color(0.9, 0.6, 0.2)  # Orange (not harsh red)
       feedback_label.visible = true
       
       # Optional: shake animation on wrong answer
       var tween = create_tween()
       tween.tween_property(feedback_label, "position:x", feedback_label.position.x + 10, 0.05)
       tween.tween_property(feedback_label, "position:x", feedback_label.position.x - 10, 0.05)
       tween.tween_property(feedback_label, "position:x", feedback_label.position.x, 0.05)
   ```

3. **Update UI to Support Retry:**
   - **Disable "Next" button** until correct answer is given
   - Keep answer options **enabled** after wrong answer
   - Add visual feedback:
     - Wrong answer: brief red/orange highlight, then reset
     - Correct answer: green highlight, then enable "Next"

4. **Child-Friendly Feedback Messages:**
   ```gdscript
   var encouraging_messages = [
       "Almost there! Give it another try!",
       "You're so close! Try again!",
       "Good thinking! Want to try a different answer?",
       "Not quite, but you've got this!",
       "Keep going - you can do it!"
   ]
   
   func get_random_encouragement() -> String:
       return encouraging_messages[randi() % encouraging_messages.size()]
   ```

5. **Specific Updates Per Game:**

   **Pick the Meaning Game:**
   - Multiple choice buttons remain clickable after wrong answer
   - Disable incorrect button briefly (0.5s) after click, then re-enable
   
   **Complete the Sentence Game:**
   - TextEdit/LineEdit field remains editable
   - Clear field after wrong answer, or keep text for editing
   
   **Word Relationships Game:**
   - Keep all interactive elements enabled
   - Highlight which part is incorrect if possible
   
   **Match the Meaning Game:**
   - If drag-and-drop: allow re-dragging items
   - If button-based: keep all buttons active

---

## ✅ TASK 4: End Game Screen Animal Updates (COMPLETED - PR 5)

**Solution Implemented:** Completion screen displays all 5 characters (Cat, Dog, Rabbit, Fox, Bird) with celebration animations. Message updated to reflect "ALL FIVE GAMES".

### Requirements:
- Update animal visuals to match new realistic style from game screens
- Ensure consistency with animals shown during gameplay

### Implementation Steps:

1. **Locate CompletionScreen.tscn**

2. **Find Animal Display Element:**
   - Look for node showing celebration animal
   - Likely named "AnimalSprite", "Mascot", or "CelebrationCharacter"

3. **Update to Match Game Screen Style:**
   ```gdscript
   # In CompletionScreen.gd
   
   func _ready() -> void:
       setup_celebration_animals()
   
   func setup_celebration_animals() -> void:
       # Show all 4 animals from the games
       var animals_container = HBoxContainer.new()
       
       for animal_name in ["Cat", "Dog", "Owl", "Fox"]:
           var animal_display = create_animal_display(animal_name)
           animals_container.add_child(animal_display)
       
       # Position in scene
       # Add to existing layout or create new section
   
   func create_animal_display(animal_name: String) -> Control:
       # Use same styling as game screens
       # Placeholder until real assets added
       var container = VBoxContainer.new()
       
       var sprite = ColorRect.new()  # Replace with TextureRect for real assets
       sprite.custom_minimum_size = Vector2(100, 100)
       sprite.color = get_animal_color(animal_name)
       
       var label = Label.new()
       label.text = animal_name
       label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
       
       container.add_child(sprite)
       container.add_child(label)
       
       return container
   ```

4. **Add Celebration Animation:**
   ```gdscript
   func animate_animals() -> void:
       # Make animals jump/bounce in sequence
       for i in range(animals_container.get_child_count()):
           var animal = animals_container.get_child(i)
           await get_tree().create_timer(0.2).timeout
           
           var tween = create_tween()
           tween.tween_property(animal, "position:y", animal.position.y - 20, 0.3)
           tween.tween_property(animal, "position:y", animal.position.y, 0.3)
   ```

---

## Implementation Priority Order

1. ✅ **Memory Match card sizing** (prevents layout breaks)
2. ✅ **Memory Match font contrast** (accessibility issue)
3. ✅ **Remove/fix black dots element** (visual bug)
4. ✅ **Answer validation updates** (core learning mechanic)
5. ✅ **Animal placeholder repositioning** (visual consistency)
6. ✅ **End screen animal updates** (polish)
7. ✅ **Prepare for realistic animal assets** (future-proofing)

---

## ✅ Testing Checklist - ALL COMPLETE

### Memory Match:
- ✅ Cards don't resize when flipped
- ✅ Long text fits within card bounds
- ✅ Font scales down appropriately (18px to 12px)
- ✅ Text is dark and readable on white background (DARK_BASE on LIGHT_BASE)
- ✅ No visual artifacts found
- ✅ Character appears on left side of screen (Vector2(180, 400))

### All Games:
- ✅ Characters positioned on left side (consistent Vector2(180, 400))
- ✅ Layout doesn't break with character on left
- ✅ Consistent character style across all 5 games

### Answer Validation:
- ✅ Cannot proceed with wrong answer in Pick Meaning (retry required)
- ✅ Cannot proceed with wrong answer in Complete Sentence (retry required)
- ✅ Cannot proceed with wrong answer in Word Relationships (retry required)
- ✅ Cannot proceed with wrong answer in Match Meaning (retry required)
- ✅ Feedback messages are encouraging (5 random positive messages)
- ✅ Correct answer enables progression (auto-advance after 2s)

### End Screen:
- ✅ Characters match game screen style (geometric shapes via CharacterHelper)
- ✅ All 5 characters displayed (Cat, Dog, Rabbit, Fox, Bird)
- ✅ Celebration animation works (staggered pop-in with scale bounce)

---

## Notes for Cursor

- Prioritize fixing bugs before visual improvements
- Test each change on different screen sizes (16:9, 4:3 aspect ratios)
- Keep code child-friendly (simple, clear variable names)
- Add comments explaining "why" not just "what"
- Use `await` properly to avoid timing issues
- Maintain consistent code style with existing project