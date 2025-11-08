# Game API Update - Implementation Task List

This document outlines the sequential steps needed to implement the API-driven sequential game flow as specified in `game_api_update_prd.md`.

## Implementation Phases

The implementation is divided into 6 phases that can be completed sequentially:

1. **Phase 1**: Create API simulation infrastructure
2. **Phase 2**: Create activity mapping and data structures
3. **Phase 3**: Modify GameManager for API-driven flow
4. **Phase 4**: Update game scripts to accept activity data
5. **Phase 5**: Remove global score tracking and vocabulary dependencies
6. **Phase 6**: Update completion screen and final cleanup

---

## Phase 1: Create API Simulation Infrastructure

### Task 1.1: Create APISimulator Singleton
**File**: `scripts/APISimulator.gd` (NEW)

**Steps**:
1. Create new file `scripts/APISimulator.gd`
2. Make it an autoload singleton:
   - Open Project → Project Settings → Autoload tab
   - Click folder icon, select `scripts/APISimulator.gd`
   - Set Node Name: `APISimulator`
   - Click "Add"
   - Save project settings
3. Implement base structure:
   ```gdscript
   extends Node
   
   var test_data_entries: Array[Dictionary] = []
   var current_test_index: int = 0
   var api_delay_ms: int = 300  # Configurable delay
   
   func _ready() -> void:
       _initialize_test_data()
   ```
4. Add method to add test data:
   ```gdscript
   func add_test_data(activity_data: Dictionary) -> void:
       test_data_entries.append(activity_data)
   ```
5. Add method to clear test data:
   ```gdscript
   func clear_test_data() -> void:
       test_data_entries.clear()
       current_test_index = 0
   ```
6. Add method to get all test data:
   ```gdscript
   func get_test_data() -> Array:
       return test_data_entries
   ```

**Test**: Verify file compiles and can be accessed as singleton

---

### Task 1.2: Implement API Request Simulation
**File**: `scripts/APISimulator.gd` (MODIFY)

**Steps**:
1. Add `request_next_activity()` method:
   ```gdscript
   func request_next_activity(session_id: String) -> Dictionary:
       # Simulate network delay
       await get_tree().create_timer(api_delay_ms / 1000.0).timeout
       
       # Check if test data available
       if test_data_entries.is_empty():
           push_error("No test data available")
           return {}
       
       # Round-robin selection
       var selected_data = test_data_entries[current_test_index].duplicate(true)  # Deep copy
       current_test_index = (current_test_index + 1) % test_data_entries.size()
       
       return selected_data
   ```
2. Add error handling for empty test data
3. Add validation check before returning data

**Test**: Call method and verify it returns a dictionary after delay

---

### Task 1.3: Create Test Data Initialization Method
**File**: `scripts/APISimulator.gd` (MODIFY)

**Steps**:
1. Create `_initialize_test_data()` method that populates test data
2. Load vocabulary data:
   ```gdscript
   func _initialize_test_data() -> void:
       # Get vocabulary words from VocabularyManager
       var vocab_words = VocabularyManager.get_all_words()
       if vocab_words.is_empty():
           push_error("No vocabulary data available")
           return
       
       var item_counter = 1
       # Ensure we have enough words (need at least 15 for 3 entries × 5 types)
       if vocab_words.size() < 20:
           push_warning("Limited vocabulary data, some words will repeat")
   ```
3. For each activity type, create 3 test entries:
   - `connect_def`: 3 entries (indices 0-2)
   - `context_cloze`: 3 entries (indices 3-5)
   - `select_usage`: 3 entries (indices 6-8)
   - `synonym_mcq`: 3 entries (indices 9-11)
   - `flashcard_usage`: 3 entries (indices 12-14)
4. Generate test data entries with proper structure:
   ```gdscript
   # Example for connect_def
   for i in range(3):
       var word = vocab_words[i]
       var entry = {
           "itemId": "test-item-%03d" % item_counter,
           "activityType": "connect_def",
           "phase": "new",
           "phaseProgress": {"current": i + 1, "total": 3},
           "word": {
               "wordId": "word-%03d" % item_counter,
               "headword": word["word"],
               "definition": word["definition"],
               "pos": "noun",  # Simplify for test data
               "media": []  # Empty for now (media not required)
           },
           "params": {
               "options": _generate_word_options(word["word"], vocab_words)
           }
       }
       test_data_entries.append(entry)
       item_counter += 1
   ```
5. Helper method to generate options:
   ```gdscript
   func _generate_word_options(correct_word: String, all_words: Array) -> Array:
       var options = [correct_word]
       # Add 3 random different words
       var shuffled = all_words.duplicate()
       shuffled.shuffle()
       for word_data in shuffled:
           if word_data["word"] != correct_word and options.size() < 4:
               options.append(word_data["word"])
       options.shuffle()
       return options
   ```
6. For `context_cloze`, use `example_sentence` field and create sentence with blank
7. For `select_usage` and `flashcard_usage`, format options as `{exampleId, text}`:
   ```gdscript
   "params": {
       "options": [
           {"exampleId": "ex-001", "text": word["example_sentence"].replace("___", word["word"])},
           # ... 3 more with different words in sentences
       ]
   }
   ```

**Test Data Structure Example**:
```gdscript
{
    "itemId": "test-item-001",
    "activityType": "connect_def",
    "phase": "new",
    "phaseProgress": {"current": 1, "total": 10},
    "word": {
        "wordId": "word-001",
        "headword": "example",
        "definition": "a thing characteristic of its kind",
        "pos": "noun",
        "media": [
            {
                "mediaId": "media-001",
                "kind": "audio",
                "url": "https://example.com/example.mp3",
                "mimeType": "audio/mpeg",
                "role": "word_pronunciation",
                "orderNo": 1
            }
        ]
    },
    "params": {
        "options": ["example", "sample", "instance", "illustration"]
    }
}
```

**Test**: Verify test data is populated on game start, check structure matches format

---

## Phase 2: Create Activity Mapping and Data Structures

### Task 2.1: Create ActivityMapper Utility
**File**: `scripts/ActivityMapper.gd` (NEW)

**Steps**:
1. Create new file `scripts/ActivityMapper.gd`
2. This is a utility class (not autoload), will be referenced by class_name
3. Create static class with mapping function:
   ```gdscript
   extends RefCounted
   class_name ActivityMapper
   
   static func get_scene_path(activity_type: String) -> String:
       var mapping = {
           "connect_def": "res://scenes/WordMatching.tscn",
           "context_cloze": "res://scenes/FillInBlank.tscn",
           "select_usage": "res://scenes/MultipleChoice.tscn",
           "synonym_mcq": "res://scenes/SynonymAntonym.tscn",
           "flashcard_usage": "res://scenes/MemoryGame.tscn"
       }
       # Default fallback to MultipleChoice
       return mapping.get(activity_type, "res://scenes/MultipleChoice.tscn")
   ```
3. Add method to validate activity type:
   ```gdscript
   static func is_valid_activity_type(activity_type: String) -> bool:
       var valid_types = [
           "connect_def", "context_cloze", "select_usage", 
           "synonym_mcq", "flashcard_usage"
       ]
       return activity_type in valid_types
   ```

**Test**: Verify mapping returns correct scene paths for each activity type

---

### Task 2.2: Create Activity Data Validation Helper
**File**: `scripts/APISimulator.gd` (MODIFY)

**Steps**:
1. Add validation method to APISimulator:
   ```gdscript
   func validate_activity_data(data: Dictionary) -> bool:
       # Check required fields
       if not data.has("itemId"):
           push_error("Missing itemId")
           return false
       if not data.has("activityType"):
           push_error("Missing activityType")
           return false
       if not data.has("word"):
           push_error("Missing word")
           return false
       if not data.has("params"):
           push_error("Missing params")
           return false
       
       # Validate word structure
       var word = data["word"]
       if not word.has("wordId") or not word.has("definition"):
           push_error("Invalid word structure")
           return false
       
       return true
   ```
2. Call validation in `request_next_activity()` before returning data
3. Return empty dictionary if validation fails

**Test**: Test with valid and invalid data structures

---

## Phase 3: Modify GameManager for API-Driven Flow

### Task 3.1: Remove Score Tracking from GameManager
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Remove `game_scores` array declaration
2. Remove `record_game_score()` method
3. Remove `get_total_score()` method
4. Remove `get_total_possible()` method
5. Remove `get_game_score_text()` method
6. Remove score-related logic from `reset_flow()` method

**Test**: Verify file compiles without errors

---

### Task 3.2: Remove Fixed Game Sequence from GameManager
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Remove `games` array declaration
2. Remove `current_game_index` variable
3. Remove `get_current_game_name()` method
4. Remove `get_current_game_scene()` method
5. Remove `get_next_game_name()` method
6. Remove `is_last_game()` method
7. Remove old `advance_to_next_game()` method

**Test**: Verify file compiles without errors

---

### Task 3.3: Add API Integration to GameManager
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Add new variables:
   ```gdscript
   var current_session_id: String = ""
   var current_activity_data: Dictionary = {}
   ```
2. Add new signals:
   ```gdscript
   signal next_activity_requested(session_id: String)
   signal activity_data_received(activity_data: Dictionary)
   signal activity_load_failed(error_message: String)
   ```
3. Add method to initialize session:
   ```gdscript
   func initialize_session() -> void:
       # Generate mock session ID
       current_session_id = "test-session-" + str(Time.get_unix_time_from_system())
   ```
4. Add method to request next activity:
   ```gdscript
   func request_next_activity() -> void:
       if current_session_id.is_empty():
           initialize_session()
       
       emit_signal("next_activity_requested", current_session_id)
       
       # Call APISimulator
       var activity_data = APISimulator.request_next_activity(current_session_id)
       
       if activity_data.is_empty():
           emit_signal("activity_load_failed", "Failed to load activity data")
           return
       
       current_activity_data = activity_data
       emit_signal("activity_data_received", activity_data)
   ```
5. Add method to load game from activity data:
   ```gdscript
   func load_game_from_activity(activity_data: Dictionary) -> void:
       var activity_type = activity_data.get("activityType", "")
       var scene_path = ActivityMapper.get_scene_path(activity_type)
       
       if scene_path.is_empty():
           push_error("Invalid activity type: " + activity_type)
           emit_signal("activity_load_failed", "Invalid activity type")
           _show_error_toast("Invalid activity type. Skipping to next activity.")
           # Try loading next activity
           request_next_activity()
           return
       
       emit_signal("load_game_scene", scene_path, activity_data)
   ```
6. Add error toast helper method:
   ```gdscript
   func _show_error_toast(message: String) -> void:
       # Emit signal for Main.gd to display error toast
       emit_signal("show_error_toast", message)
   ```
7. Add signal for error toast:
   ```gdscript
   signal show_error_toast(message: String)
   ```

**Test**: Verify methods compile and signals are properly defined

---

### Task 3.4: Update GameManager Signal Handlers
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Update `_ready()` method to connect to game completion:
   ```gdscript
   func _ready() -> void:
       game_completed.connect(_on_game_completed)
       # Keep existing connections
   ```
2. Modify `_on_game_completed()` method:
   ```gdscript
   func _on_game_completed(game_name: String) -> void:
       # REMOVED: Show ready modal logic
       # NEW: Request next activity directly
       await request_next_activity()  # Need await since it's async
   ```
3. Update `reset_flow()` method:
   ```gdscript
   func reset_flow() -> void:
       current_session_id = ""
       current_activity_data = {}
       # Reset vocabulary word usage tracking (will be removed later)
       VocabularyManager.reset_usage_tracking()
   ```
3. Connect new signals if needed

**Test**: Verify signal handlers work correctly

---

## Phase 4: Update Game Scripts to Accept Activity Data

### Task 4.1: Update MultipleChoice.gd for Activity Data
**File**: `scripts/MultipleChoice.gd` (MODIFY)

**Steps**:
1. Add new method `load_activity_data(activity_data: Dictionary)`:
   ```gdscript
   func load_activity_data(activity_data: Dictionary) -> void:
       var word_data = activity_data["word"]
       var params = activity_data["params"]
       var activity_type = activity_data["activityType"]
       
       # Clear existing questions
       questions.clear()
       current_question_index = 0
       score = 0
       
       # Create single question from activity data
       var q = Question.new()
       q.word = word_data.get("headword", "")
       q.correct_definition = word_data.get("definition", "")
       
       # Extract options based on activity type
       if activity_type == "select_usage" or activity_type == "flashcard_usage":
           # Options are Array of {exampleId, text}
           var options_array = params.get("options", [])
           var options_temp: Array[String] = []
           for option in options_array:
               if option is Dictionary:
                   options_temp.append(option.get("text", ""))
               else:
                   options_temp.append(str(option))
           q.options = options_temp
       else:
           # Fallback: use params.options as string array
           q.options = params.get("options", [])
       
       # Find correct index
       q.correct_index = q.options.find(q.correct_definition)
       if q.correct_index == -1:
           # If definition not in options, use first option as correct
           q.correct_index = 0
       
       questions.append(q)
       total_questions = 1  # Single question per activity
       
       # Display the question
       _display_question()
   ```
2. Modify `_ready()` method:
   - Remove call to `_generate_questions()`
   - Remove call to `_display_question()`
   - Keep character setup, button connections
3. Keep `_generate_questions()` method but don't call it (for backward compatibility during transition)
4. Modify `_on_game_complete()`:
   - Remove call to `GameManager.record_game_score()`
   - Keep local score tracking

**Test**: Load activity data and verify question displays correctly

---

### Task 4.2: Update FillInBlank.gd for Activity Data
**File**: `scripts/FillInBlank.gd` (MODIFY)

**Steps**:
1. Add `load_activity_data(activity_data: Dictionary)` method:
   ```gdscript
   func load_activity_data(activity_data: Dictionary) -> void:
       var word_data = activity_data["word"]
       var params = activity_data["params"]
       
       questions.clear()
       current_question_index = 0
       score = 0
       
       var q = SentenceQuestion.new()
       q.sentence = params.get("sentence", "")
       q.correct_word = word_data.get("headword", "")
       q.options = params.get("options", [])
       
       # Find correct index
       q.correct_index = q.options.find(q.correct_word)
       if q.correct_index == -1:
           q.correct_index = 0
       
       questions.append(q)
       total_questions = 1
       
       _display_question()
   ```
2. Modify `_ready()`:
   - Remove `_generate_questions()` call
   - Remove `_display_question()` call
   - Keep character and button setup
3. Remove or modify `_generate_questions()` method
4. Remove `GameManager.record_game_score()` call from `_on_game_complete()`

**Test**: Load activity data and verify sentence and options display correctly

---

### Task 4.3: Update WordMatching.gd for Activity Data
**File**: `scripts/WordMatching.gd` (MODIFY)

**Steps**:
1. Add `load_activity_data(activity_data: Dictionary)` method:
   ```gdscript
   func load_activity_data(activity_data: Dictionary) -> void:
       var word_data = activity_data["word"]
       var params = activity_data["params"]
       
       questions.clear()
       current_question_index = 0
       score = 0
       
       var q = MatchingQuestion.new()
       q.definition = word_data.get("definition", "")
       q.correct_word = word_data.get("headword", "")
       q.options = params.get("options", [])
       
       # Find correct index
       q.correct_index = q.options.find(q.correct_word)
       if q.correct_index == -1:
           q.correct_index = 0
       
       questions.append(q)
       total_questions = 1
       
       _display_question()
   ```
2. Modify `_ready()`:
   - Remove `_generate_questions()` call
   - Remove `_display_question()` call
   - Keep character and button setup
3. Remove or modify `_generate_questions()` method
4. Remove `GameManager.record_game_score()` call from `_on_game_complete()`

**Test**: Load activity data and verify definition and options display correctly

---

### Task 4.4: Update SynonymAntonym.gd for Activity Data
**File**: `scripts/SynonymAntonym.gd` (MODIFY)

**Steps**:
1. Add `load_activity_data(activity_data: Dictionary)` method:
   ```gdscript
   func load_activity_data(activity_data: Dictionary) -> void:
       var word_data = activity_data["word"]
       var params = activity_data["params"]
       
       questions.clear()
       current_question_index = 0
       score = 0
       
       var q = RelationshipQuestion.new()
       q.target_word = word_data.get("headword", "")
       q.question_type = "synonym"  # Default, could be determined from activity
       q.correct_answer = params.get("targetWord", {}).get("headword", "")
       if q.correct_answer.is_empty():
           # Fallback: use first option
           var options = params.get("options", [])
           if options.size() > 0:
               q.correct_answer = options[0].get("headword", "")
       
       # Extract options
       var options_array = params.get("options", [])
       var options_temp: Array[String] = []
       for option in options_array:
           if option is Dictionary:
               options_temp.append(option.get("headword", ""))
           else:
               options_temp.append(str(option))
       q.options = options_temp
       
       # Find correct index
       q.correct_index = q.options.find(q.correct_answer)
       if q.correct_index == -1:
           q.correct_index = 0
       
       questions.append(q)
       total_questions = 1
       
       _display_question()
   ```
2. Modify `_ready()`:
   - Remove `_generate_questions()` call
   - Remove `_display_question()` call
   - Keep character and button setup
3. Remove or modify `_generate_questions()` method
4. Remove `GameManager.record_game_score()` call from `_on_game_complete()`

**Test**: Load activity data and verify synonym/antonym question displays correctly

---

### Task 4.5: Update MemoryGame.gd for Single Flashcard Mode
**File**: `scripts/MemoryGame.gd` (MODIFY)
**Scene**: `scenes/MemoryGame.tscn` (MODIFY)

**Scene Modifications**:
1. Open `scenes/MemoryGame.tscn` in Godot editor
2. Remove or hide the `GridContainer` node with 16 card buttons
3. Add a new `Button` node (or use existing button) as main flashcard:
   - Name: `FlashcardButton`
   - Size: 600x400 pixels (large card)
   - Position: Center of screen
   - Add `CardContent` Label child for displaying text
4. Keep existing `Character`, `NextButton`, `HeaderBar` nodes
5. Save scene

**Script Modifications**:
1. Add variables at top of script:
   ```gdscript
   var current_word: String = ""
   var current_definition: String = ""
   var is_flipped: bool = false
   ```
2. Convert memory game to single flippable flashcard (word on one side, definition on other)
3. Add `load_activity_data(activity_data: Dictionary)` method:
   ```gdscript
   func load_activity_data(activity_data: Dictionary) -> void:
       var word_data = activity_data["word"]
       
       # Store word and definition for flashcard
       current_word = word_data.get("headword", "")
       current_definition = word_data.get("definition", "")
       
       # Setup flashcard display (word side first)
       _setup_flashcard()
       _display_word_side()
   ```
3. Modify game logic:
   - Remove 8-card grid system
   - Create single large card in center
   - Add flip animation when card is clicked
   - Show word on front, definition on back
   - Enable Next button after card is flipped at least once
4. Add methods:
   ```gdscript
   func _setup_flashcard() -> void:
       # Create or configure single card UI element
       # Position in center of screen
       
   func _display_word_side() -> void:
       # Show headword on card
       
   func _display_definition_side() -> void:
       # Show definition on card
       
   func _on_card_clicked() -> void:
       # 3D flip animation (rotate on Y axis)
       is_flipped = !is_flipped
       var tween = create_tween()
       tween.set_trans(Tween.TRANS_CUBIC)
       tween.set_ease(Tween.EASE_OUT)
       
       # Rotate to 90 degrees (edge view)
       tween.tween_property(card_node, "rotation:y", PI/2, 0.2)
       tween.tween_callback(func():
           if is_flipped:
               _display_definition_side()
               $NextButton.disabled = false  # Enable after first flip
           else:
               _display_word_side()
       )
       # Rotate back to 0 (or 180 for back side)
       tween.tween_property(card_node, "rotation:y", PI if is_flipped else 0, 0.2)
   ```
5. Remove all multi-card matching logic:
   - Remove `cards` array
   - Remove `selected_cards` array
   - Remove `matches_found` variable
   - Remove `_setup_game()` method (or comment out)
   - Remove `_on_card_pressed()` method for grid cards
   - Remove `_check_match()` method
   - Remove `_flip_card()` and `_flip_card_back()` methods for multiple cards
6. Update `_ready()` method:
   ```gdscript
   func _ready() -> void:
       # Create cat character
       var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Colors.PRIMARY_PURPLE)
       # ... tail setup (keep existing) ...
       
       # Connect flashcard button (NEW)
       $FlashcardButton.pressed.connect(_on_flashcard_clicked)
       
       # Connect next button
       $NextButton.pressed.connect(_on_next_pressed)
       $NextButton.mouse_entered.connect(_on_button_hover_enter)
       $NextButton.mouse_exited.connect(_on_button_hover_exit)
       $NextButton.disabled = true
       
       # REMOVE: _setup_game() call
       # Game will wait for load_activity_data() call
   ```
7. Keep character animations and visual style

**Test**: Load activity data and verify flashcard displays word, flips to show definition

---

### Task 4.6: Update Main.gd to Handle Activity-Based Loading
**File**: `scripts/Main.gd` (MODIFY)

**Steps**:
1. Modify `_on_load_game_scene()` to accept activity data:
   ```gdscript
   func _on_load_game_scene(scene_path: String, activity_data: Dictionary = {}) -> void:
       # Clear previous game
       for child in game_container.get_children():
           child.queue_free()
       
       # Load new game
       var game_scene = load(scene_path).instantiate()
       game_container.add_child(game_scene)
       game_container.show()
       
       # Pass activity data to game if provided
       if not activity_data.is_empty():
           if game_scene.has_method("load_activity_data"):
               game_scene.load_activity_data(activity_data)
   ```
2. Add error toast display method:
   ```gdscript
   func _show_error_toast(message: String) -> void:
       # Create simple toast notification
       var toast = Label.new()
       toast.text = message
       toast.add_theme_color_override("font_color", Colors.LIGHT_BASE)
       toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
       # Position at bottom center
       toast.position = Vector2(get_viewport_rect().size.x / 2 - 150, get_viewport_rect().size.y - 100)
       toast.size = Vector2(300, 50)
       add_child(toast)
       
       # Fade in, wait, fade out, remove
       toast.modulate.a = 0
       var tween = create_tween()
       tween.tween_property(toast, "modulate:a", 1.0, 0.3)
       tween.tween_interval(2.0)
       tween.tween_property(toast, "modulate:a", 0.0, 0.3)
       tween.tween_callback(toast.queue_free)
   ```
3. Update signal connections in `_ready()`:
   ```gdscript
   func _ready() -> void:
       # Existing connections
       VocabularyManager.vocabulary_load_failed.connect(_on_vocabulary_load_failed)
       VocabularyManager.vocabulary_loaded_successfully.connect(_on_vocabulary_loaded)
       start_button.pressed.connect(_on_start_pressed)
       start_button.mouse_entered.connect(_on_start_button_hover_enter)
       start_button.mouse_exited.connect(_on_start_button_hover_exit)
       
       # MODIFIED: Update load_game_scene connection to accept activity_data
       GameManager.load_game_scene.connect(_on_load_game_scene)
       
       # REMOVED: GameManager.show_ready_modal.connect(_show_ready_modal)
       
       # NEW: Add error toast connection
       GameManager.show_error_toast.connect(_show_error_toast)
       
       # Existing connection
       GameManager.show_completion_screen.connect(_show_completion_screen)
       
       game_container.hide()
   ```
4. Modify `_on_info_modal_action()`:
   - Instead of `GameManager.advance_to_next_game()`, call `GameManager.request_next_activity()`

**Test**: Verify games load with activity data passed correctly and error toasts display

---

### Task 4.7: Update Game Next Button Handlers
**Files**: All game scripts (MODIFY)

**Steps**:
1. In each game script, modify `_on_next_pressed()`:
   - Remove direct call to `GameManager.advance_to_next_game()`
   - Instead, emit signal or call `GameManager.request_next_activity()`
2. Example for MultipleChoice.gd:
   ```gdscript
   func _on_next_pressed() -> void:
       Anim.animate_button_press($NextButton)
       await get_tree().create_timer(0.4).timeout
       # Request next activity instead of fixed sequence
       GameManager.request_next_activity()
   ```
3. Repeat for all game scripts:
   - FillInBlank.gd
   - WordMatching.gd
   - SynonymAntonym.gd
   - MemoryGame.gd (if updated)

**Test**: Verify Next button triggers activity request

---

## Phase 5: Remove Global Score Tracking and Vocabulary Dependencies

### Task 5.1: Remove VocabularyManager Word Usage Tracking
**File**: `scripts/VocabularyManager.gd` (MODIFY)

**Steps**:
1. Remove `used_words` array declaration (line ~8)
2. Remove `reset_usage_tracking()` method (around line 149)
3. Modify `get_random_words()` method:
   ```gdscript
   # OLD VERSION (lines ~96-119):
   func get_random_words(count: int) -> Array:
       if not vocabulary_loaded:
           push_error("Vocabulary not loaded")
           return []
       
       var available_words = []
       for word in all_words:
           if not used_words.has(word["word"]):  # REMOVE THIS CHECK
               available_words.append(word)
       
       if available_words.size() < count:
           push_error("Not enough unused words available")
           return []
       
       available_words.shuffle()
       var selected = available_words.slice(0, count)
       
       for word in selected:
           used_words.append(word["word"])  # REMOVE THIS LINE
       
       return selected
   
   # NEW VERSION:
   func get_random_words(count: int) -> Array:
       if not vocabulary_loaded:
           push_error("Vocabulary not loaded")
           return []
       
       if all_words.size() < count:
           push_error("Not enough words available")
           return []
       
       var shuffled = all_words.duplicate()
       shuffled.shuffle()
       return shuffled.slice(0, count)
   ```
4. Keep all vocabulary loading functionality (needed for APISimulator test data)

**Test**: Verify vocabulary manager still loads words correctly

---

### Task 5.2: Remove VocabularyManager Calls from Game Scripts
**Files**: All game scripts (MODIFY)

**Steps**:
1. In each game script, remove all calls to:
   - `VocabularyManager.get_random_words()`
   - `VocabularyManager.get_random_definitions()`
   - `VocabularyManager.get_random_word_strings()`
2. Verify games no longer depend on VocabularyManager for content
3. Keep VocabularyManager as optional dependency (for test data generation)

**Test**: Verify games work without VocabularyManager calls

---

### Task 5.3: Update GameManager Reset Flow
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Find `reset_flow()` method (around line 85-91 in original file)
2. Remove `VocabularyManager.reset_usage_tracking()` call
3. Update to include new session tracking variables:
   ```gdscript
   func reset_flow() -> void:
       current_session_id = ""
       current_activity_data = {}
       session_start_time = 0.0
       activities_completed = 0
       # REMOVED: VocabularyManager.reset_usage_tracking()
   ```

**Test**: Verify reset flow works correctly and Play Again button resets session

---

## Phase 6: Update Completion Screen and Final Cleanup

### Task 6.1: Update Completion Screen Message
**File**: `scripts/Completion.gd` (MODIFY)

**Steps**:
1. Modify `_display_scores()` method:
   ```gdscript
   func _display_scores() -> void:
       # Get session stats from GameManager
       var activities_count = GameManager.activities_completed
       var elapsed_time = Time.get_unix_time_from_system() - GameManager.session_start_time
       var minutes = int(elapsed_time / 60)
       var seconds = int(elapsed_time) % 60
       
       # Show completion message with stats
       var message = "You completed %d activities in %d:%02d!" % [activities_count, minutes, seconds]
       $CenterContent/VBoxContainer/MessageLabel.text = message
   ```
2. Remove calls to `GameManager.get_total_score()` and `GameManager.get_total_possible()`

**Test**: Verify completion screen shows activities completed and time spent

---

### Task 6.2: Update Completion Screen Flow
**File**: `scripts/Completion.gd` (MODIFY)

**Steps**:
1. Modify `_on_play_again_pressed()`:
   - Ensure it calls `GameManager.reset_flow()`
   - Return to main screen
2. Verify completion screen appears at appropriate time (when session ends)

**Test**: Verify Play Again button works correctly

---

### Task 6.3: Update Main.gd Info Modal
**File**: `scripts/Main.gd` (MODIFY)

**Steps**:
1. Update info modal text to reflect new flow:
   - Remove references to "five games"
   - Update to mention activities instead
2. Example:
   ```gdscript
   var body_text = "[center]You'll complete vocabulary activities to learn new words!\n\n"
   body_text += "Each activity will help you practice and remember.\n\n"
   body_text += "Ready to start? Let's go![/center]"
   ```
   Note: Keep message generic, don't mention 10-minute time limit

**Test**: Verify info modal displays updated text

---

### Task 6.4: Remove Ready Modal Between Activities
**File**: `scripts/Main.gd` (MODIFY)

**Steps**:
1. Remove `_show_ready_modal()` method
2. Remove `_on_ready_modal_action()` method
3. Remove signal connection for `show_ready_modal` in `_ready()`
4. Update GameManager to not emit `show_ready_modal` signal (already handled in Task 3.4)
5. Activities should flow directly: Complete activity → Click Next → Next activity loads immediately

**Test**: Verify activities flow directly without modal interruption

---

### Task 6.5: Add Session End Logic (Time-Based + Data Exhaustion)
**File**: `scripts/GameManager.gd` (MODIFY)

**Steps**:
1. Add session tracking variables:
   ```gdscript
   var session_start_time: float = 0.0
   var session_duration_seconds: float = 600.0  # 10 minutes
   var activities_completed: int = 0
   ```
2. Update `initialize_session()` to record start time:
   ```gdscript
   func initialize_session() -> void:
       current_session_id = "test-session-" + str(Time.get_unix_time_from_system())
       session_start_time = Time.get_unix_time_from_system()
   ```
3. Add session end check method:
   ```gdscript
   func should_end_session() -> bool:
       # Check time limit (10 minutes)
       var elapsed_time = Time.get_unix_time_from_system() - session_start_time
       if elapsed_time >= session_duration_seconds:
           return true
       
       # Check if test data exhausted (no more activities available)
       if APISimulator.is_test_data_exhausted():
           return true
       
       return false
   ```
4. Add method to APISimulator:
   ```gdscript
   func is_test_data_exhausted() -> bool:
       # Always return false since we cycle through data indefinitely
       return false
   ```
   Note: Test data will cycle/repeat using round-robin, session ends only on time limit
5. Modify `request_next_activity()` to check session end:
   ```gdscript
   func request_next_activity() -> void:
       if current_session_id.is_empty():
           initialize_session()
       
       # Check if session should end
       if should_end_session():
           emit_signal("show_completion_screen")
           return
       
       emit_signal("next_activity_requested", current_session_id)
       
       # Call APISimulator (await the async call)
       var activity_data = await APISimulator.request_next_activity(current_session_id)
       
       if activity_data.is_empty():
           emit_signal("activity_load_failed", "Failed to load activity data")
           _show_error_toast("Failed to load activity. Please try again.")
           return
       
       current_activity_data = activity_data
       activities_completed += 1
       emit_signal("activity_data_received", activity_data)
       load_game_from_activity(activity_data)
   ```
6. Reset session tracking in `reset_flow()`:
   ```gdscript
   func reset_flow() -> void:
       current_session_id = ""
       current_activity_data = {}
       session_start_time = 0.0
       activities_completed = 0
   ```

**Test**: Verify completion screen appears after 10 minutes (test data cycles indefinitely)

---

### Task 6.6: Final Testing and Validation
**All Files** (TEST)

**Steps**:
1. Test complete flow:
   - Start game → Info modal → First activity loads
   - Complete activity → Click Next → Next activity loads
   - Repeat for multiple activities
   - Verify completion screen appears
2. Test all activity types:
   - `connect_def` → WordMatching
   - `context_cloze` → FillInBlank
   - `select_usage` → MultipleChoice
   - `synonym_mcq` → SynonymAntonym
   - `flashcard_usage` → MemoryGame (single flashcard)
3. Test error handling:
   - Invalid activity type
   - Missing test data
   - Invalid activity data structure
4. Verify no global score tracking
5. Verify no vocabulary usage tracking
6. Verify games operate independently

**Test**: Complete end-to-end testing of all functionality

---

## Implementation Notes

### Code Style
- Use Godot 4.x syntax (typed arrays, modern GDScript)
- Maintain existing code style and conventions
- Add comments for API simulation sections
- Keep error handling robust
- Line numbers mentioned are approximate (from current file state)

### Critical Technical Details

**Autoload Order**:
- VocabularyManager must load BEFORE APISimulator
- Check Project Settings → Autoload → Ensure VocabularyManager is above APISimulator
- APISimulator depends on VocabularyManager.get_all_words()

**Signal Changes**:
- `load_game_scene` signature changes from 1 to 2 parameters
- All existing signal connections must be updated
- Use `await` when calling async methods that return values

**Node Paths**:
- All `$NodePath` references assume scene structure unchanged except MemoryGame
- If node not found errors occur, verify scene hierarchy
- Use `get_node_or_null()` for optional nodes

**Data Type Consistency**:
- `questions` arrays are typed: `Array[Question]`, `Array[SentenceQuestion]`, etc.
- `activity_data` is always `Dictionary` (untyped keys)
- Use `.get()` with defaults for safe dictionary access

**Async Considerations**:
- `request_next_activity()` MUST be awaited if called from async context
- Don't call `await` in `_ready()` - causes initialization issues
- Use `call_deferred()` if needed to break circular awaits

### Testing Strategy
- Test each phase before moving to next
- After Phase 1: Run game, check console for "APISimulator initialized"
- After Phase 3: Verify GameManager compiles without errors
- After Phase 4: Test each game type loads with activity data
- Test error cases (invalid data, missing fields)
- Test async behavior (API delay simulation)
- Test complete 10-minute session

### Dependencies
- Phase 1 must complete before Phase 2
- Phase 2 must complete before Phase 3
- Phase 3 must complete before Phase 4
- Phase 4 can be done in parallel for different game scripts
- Phase 5 depends on Phase 4 completion
- Phase 6 depends on all previous phases

### Common Issues & Solutions

**Issue**: "Identifier 'APISimulator' not declared"
- Solution: Ensure APISimulator added to Autoload in project settings
- Restart Godot editor after adding autoload

**Issue**: "Invalid call. Nonexistent function 'load_activity_data'"
- Solution: Verify game script has the method defined before Main.gd calls it
- Check `has_method()` returns true

**Issue**: "Cannot await coroutine in non-coroutine function"
- Solution: Add `await` keyword when calling `request_next_activity()`
- Or use signals instead of direct await

**Issue**: Node not found errors in MemoryGame
- Solution: Update scene file first before modifying script
- Verify `$FlashcardButton` exists in scene tree

### Rollback Plan
- Keep VocabularyManager functional as fallback
- Keep game scenes loadable independently
- Maintain git commits at each phase for easy rollback
- Tag completion of each phase: `git tag phase-1-complete`

---

## Success Criteria Checklist

- [ ] APISimulator singleton created and functional
- [ ] Test data initialized with entries for all activity types
- [ ] ActivityMapper maps all activity types to game scenes
- [ ] GameManager uses API simulation instead of fixed sequence
- [ ] All game scripts accept activity data via `load_activity_data()`
- [ ] No global score tracking remains
- [ ] No vocabulary usage tracking remains
- [ ] Games operate independently with activity data
- [ ] Completion screen shows generic message (no scores)
- [ ] End-to-end flow works: Start → Activities → Completion
- [ ] All activity types tested and working
- [ ] Error handling works for edge cases

---

## Estimated Implementation Order

1. **Phase 1** (Tasks 1.1-1.3): ~2-3 hours
   - Task 1.1: 30 min (basic structure)
   - Task 1.2: 30 min (API simulation)
   - Task 1.3: 1.5-2 hours (test data generation with vocabulary.json parsing)

2. **Phase 2** (Tasks 2.1-2.2): ~1 hour
   - Task 2.1: 30 min (mapper utility)
   - Task 2.2: 30 min (validation)

3. **Phase 3** (Tasks 3.1-3.4): ~2 hours
   - Task 3.1: 30 min (remove scores)
   - Task 3.2: 30 min (remove fixed sequence)
   - Task 3.3: 45 min (add API integration)
   - Task 3.4: 15 min (update handlers)

4. **Phase 4** (Tasks 4.1-4.7): ~4-5 hours
   - Task 4.1: 45 min (MultipleChoice)
   - Task 4.2: 45 min (FillInBlank)
   - Task 4.3: 45 min (WordMatching)
   - Task 4.4: 45 min (SynonymAntonym)
   - Task 4.5: 1.5 hours (MemoryGame scene + script changes)
   - Task 4.6: 45 min (Main.gd updates)
   - Task 4.7: 30 min (Next button handlers)

5. **Phase 5** (Tasks 5.1-5.3): ~1 hour
   - Task 5.1: 30 min (VocabularyManager cleanup)
   - Task 5.2: 20 min (remove game script calls)
   - Task 5.3: 10 min (GameManager reset)

6. **Phase 6** (Tasks 6.1-6.6): ~2-3 hours
   - Task 6.1: 20 min (completion screen)
   - Task 6.2: 10 min (completion flow)
   - Task 6.3: 10 min (info modal)
   - Task 6.4: 20 min (remove ready modal)
   - Task 6.5: 45 min (session end logic)
   - Task 6.6: 45-60 min (comprehensive testing)

**Total Estimated Time**: ~12-15 hours

**Testing Checkpoints**: After phases 1, 3, 4, and 6

---

## File Reference Quick List

### New Files to Create
1. `scripts/APISimulator.gd` - API simulation singleton (Phase 1)
2. `scripts/ActivityMapper.gd` - Activity type mapper utility (Phase 2)

### Existing Files to Modify
1. `scripts/GameManager.gd` - Core changes (Phase 3)
2. `scripts/Main.gd` - Activity loading logic (Phase 4)
3. `scripts/MultipleChoice.gd` - Add load_activity_data (Phase 4)
4. `scripts/FillInBlank.gd` - Add load_activity_data (Phase 4)
5. `scripts/WordMatching.gd` - Add load_activity_data (Phase 4)
6. `scripts/SynonymAntonym.gd` - Add load_activity_data (Phase 4)
7. `scripts/MemoryGame.gd` - Convert to flashcard (Phase 4)
8. `scripts/VocabularyManager.gd` - Remove usage tracking (Phase 5)
9. `scripts/Completion.gd` - Update message (Phase 6)

### Scene Files to Modify
1. `scenes/MemoryGame.tscn` - Redesign as single flashcard (Phase 4)

### Project Settings to Update
1. Project → Project Settings → Autoload:
   - Add APISimulator (Phase 1)
   - Verify VocabularyManager loads before APISimulator

---

## Implementation Decisions

### Core Decisions
1. **Memory Game**: Convert to single flippable flashcard (word on front, definition on back) - maps to `flashcard_usage` activity type
2. **Session End**: 10-minute timer (test data cycles indefinitely via round-robin)
3. **SentenceGen**: Not implemented (scene doesn't exist) - removed from mapping
4. **Test Data Selection**: Round-robin (sequential cycling with infinite repeat)

### UX Decisions
5. **Ready Modal**: Remove completely - activities flow directly without interruption
6. **Error Recovery**: Show error toast (2-second fade notification), then skip to next activity
7. **Flashcard Animation**: 3D flip animation (rotate on Y axis)
8. **Loading State**: Silent wait during 300ms API delay (no spinner)

### Technical Decisions
9. **Test Data Source**: Parse vocabulary.json for realistic word data
10. **Async Flow**: Await-based (use `await` in GameManager for simplicity)
11. **Completion Screen**: Show activities completed + time spent
12. **Session Timer**: Hidden (no visible countdown for user)
13. **Info Modal**: Generic message, no mention of time limit

