# Vocabulary Cat v2.0 - Task List

**Based on:** v2_prd.md  
**Style Guide:** vocab_cat_style_guide.md  
**Total PRs:** 2 (Sequential)  
**Goal:** Complete implementation of game logic for all 5 vocabulary learning modes

---

## Style Guide Adherence

All implementation must follow the Vocabulary Cat Style Guide specifications established in v1.0:

**Reference Files:**
- `vocab_cat_style_guide.md` - Complete design specifications
- `scripts/VocabCatColors.gd` - Color constants
- `scripts/VocabCatConstants.gd` - Animation timing and spacing constants
- `assets/vocab_cat_theme.tres` - Godot theme resource

**Key Specifications:**

**Colors:**
- Use exact hex codes from VocabCatColors.gd
- Primary Purple: #8B5CF6, Primary Blue: #3B82F6, Primary Pink: #EC4899, Primary Green: #10B981
- Orange: #F97316, Cyan: #06B6D4, Yellow: #FBBF24
- Background: Dark Base #1E1B2E, Card Background #2D2640
- Semantic: Success #10B981, Error #EF4444

**Typography:**
- Headings: Fredoka Bold (Display 48-64px, H1 36-42px, H2 28-32px, H3 20-24px)
- Body: Nunito Regular (Large 18-20px, Body 16px, Small 14px)
- Line height: 1.4-1.6 for body, 1.2 for headings

**Border Radius:**
- Buttons: 16px, Cards/Panels: 20px, Modals: 24px, Small elements: 12px

**Spacing (8px base unit):**
- Tiny: 4px, Small: 8px, Medium: 16px, Large: 24px, XLarge: 32px, XXLarge: 48px

**Animations:**
- Micro-interactions: 0.1-0.15s (button press)
- UI transitions: 0.2-0.3s (fade, scale)
- Screen transitions: 0.3-0.4s
- Button press: 0.95 (0.1s) → 1.05 (0.15s) → 1.0 (0.1s)
- Modal entrance: Scale 0.9→1.0 with TRANS_BACK bounce (0.3s)

**CRITICAL:** All implementation must strictly follow these specifications. Verify during code review.

---

## PR 1: Vocabulary System, Error Handling & Data Infrastructure

**Objective:** Establish vocabulary data system, error handling, and core infrastructure for game logic.

**Dependencies:** v1.0 must be complete (navigation flow, modals, character system)

### Tasks

#### 1.1 Create Vocabulary JSON File
**File:** `assets/vocabulary.json`

**Requirements:**
- Exactly 46 words (minimum for all 5 games: 8+10+10+10+8)
- Each word must include ALL required fields
- Age-appropriate definitions (grade 3-5 reading level)
- Clear, contextual example sentences
- Exactly 4 synonyms per word
- Exactly 4 antonyms per word

**JSON Schema:**
```json
{
  "words": [
    {
      "word": "string (the vocabulary word)",
      "definition": "string (clear, child-friendly definition)",
      "synonyms": ["string", "string", "string", "string"],
      "antonyms": ["string", "string", "string", "string"],
      "example_sentence": "string (with ___ placeholder for the word)",
      "difficulty": 1
    }
  ]
}
```

**Example Entry:**
```json
{
  "word": "abundant",
  "definition": "existing in large quantities; plentiful",
  "synonyms": ["plentiful", "ample", "copious", "bountiful"],
  "antonyms": ["scarce", "rare", "lacking", "sparse"],
  "example_sentence": "The garden had an _____ supply of fresh vegetables.",
  "difficulty": 1
}
```

**46 Words to Include:**

1. abundant
2. cautious
3. curious
4. delicate
5. eager
6. fragile
7. generous
8. gloomy
9. humble
10. invisible
11. joyful
12. loyal
13. mysterious
14. nervous
15. obvious
16. peaceful
17. precious
18. quiet
19. rapid
20. sturdy
21. thoughtful
22. ancient
23. bold
24. clever
25. distant
26. elegant
27. fierce
28. gentle
29. harsh
30. immense
31. keen
32. lively
33. modest
34. nimble
35. ordinary
36. patient
37. quick
38. rough
39. sincere
40. timid
41. unique
42. vast
43. weary
44. wise
45. young
46. zealous

**Implementation Steps:**
1. Create `assets/vocabulary.json` file
2. For each of the 46 words:
   - Write age-appropriate definition (grade 3-5)
   - Create 4 accurate synonyms
   - Create 4 accurate antonyms
   - Write example sentence with ___ placeholder
   - Set difficulty to 1 (for v2.0)
3. Validate JSON syntax (use online validator)
4. Ensure all 46 entries are complete

**Quality Checklist:**
- [ ] All 46 words have complete entries
- [ ] All definitions are child-friendly
- [ ] All synonyms are accurate
- [ ] All antonyms are accurate
- [ ] All example sentences make contextual sense
- [ ] All sentences have ___ placeholder in correct position
- [ ] JSON is valid (no syntax errors)

---

#### 1.2 Create VocabularyManager Singleton
**File:** `scripts/VocabularyManager.gd`

**Purpose:** Load, validate, and serve vocabulary data to all games. Track word usage to prevent repetition across games in a single playthrough.

**Implementation:**

```gdscript
extends Node
## VocabularyManager - Singleton for vocabulary data management
## Loads vocabulary.json and provides word data to all games
## Tracks word usage to prevent repetition within a playthrough

# Vocabulary data
var all_words: Array[Dictionary] = []
var used_words: Array[String] = []  # Track words used in current playthrough
var vocabulary_loaded: bool = false
var load_error: String = ""

# Signals
signal vocabulary_loaded_successfully()
signal vocabulary_load_failed(error_message: String)

func _ready():
	load_vocabulary()

# Load vocabulary from JSON file
func load_vocabulary(file_path: String = "res://assets/vocabulary.json") -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		load_error = "Vocabulary file not found: " + file_path
		emit_signal("vocabulary_load_failed", load_error)
		vocabulary_loaded = false
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		load_error = "Failed to parse vocabulary file (JSON syntax error at line " + str(json.get_error_line()) + ")"
		emit_signal("vocabulary_load_failed", load_error)
		vocabulary_loaded = false
		return
	
	var data = json.get_data()
	
	if not data.has("words"):
		load_error = "Vocabulary file is missing 'words' array"
		emit_signal("vocabulary_load_failed", load_error)
		vocabulary_loaded = false
		return
	
	all_words = data["words"]
	
	# Validate word count
	if all_words.size() < 46:
		load_error = "Insufficient vocabulary: " + str(all_words.size()) + " words found, 46 required"
		emit_signal("vocabulary_load_failed", load_error)
		vocabulary_loaded = false
		return
	
	# Validate each word has required fields
	for i in range(all_words.size()):
		var word = all_words[i]
		if not _validate_word_entry(word, i):
			emit_signal("vocabulary_load_failed", load_error)
			vocabulary_loaded = false
			return
	
	vocabulary_loaded = true
	emit_signal("vocabulary_loaded_successfully")
	print("Vocabulary loaded successfully: ", all_words.size(), " words")

# Validate a single word entry has all required fields
func _validate_word_entry(word: Dictionary, index: int) -> bool:
	var required_fields = ["word", "definition", "synonyms", "antonyms", "example_sentence", "difficulty"]
	
	for field in required_fields:
		if not word.has(field):
			load_error = "Word entry #" + str(index) + " is missing required field: " + field
			return false
	
	# Validate synonyms array has exactly 4 items
	if word["synonyms"].size() != 4:
		load_error = "Word '" + word["word"] + "' must have exactly 4 synonyms (has " + str(word["synonyms"].size()) + ")"
		return false
	
	# Validate antonyms array has exactly 4 items
	if word["antonyms"].size() != 4:
		load_error = "Word '" + word["word"] + "' must have exactly 4 antonyms (has " + str(word["antonyms"].size()) + ")"
		return false
	
	# Validate example sentence contains placeholder
	if not word["example_sentence"].contains("___"):
		load_error = "Word '" + word["word"] + "' example sentence must contain ___ placeholder"
		return false
	
	return true

# Get random words that haven't been used yet
func get_random_words(count: int) -> Array[Dictionary]:
	if not vocabulary_loaded:
		push_error("Vocabulary not loaded")
		return []
	
	var available_words = []
	for word in all_words:
		if not used_words.has(word["word"]):
			available_words.append(word)
	
	if available_words.size() < count:
		push_error("Not enough unused words available")
		return []
	
	# Shuffle and take first 'count' words
	available_words.shuffle()
	var selected = available_words.slice(0, count)
	
	# Mark as used
	for word in selected:
		used_words.append(word["word"])
	
	return selected

# Get specific word data by word string
func get_word_data(word_string: String) -> Dictionary:
	for word in all_words:
		if word["word"] == word_string:
			return word
	return {}

# Get random definitions as distractors (excluding specific word)
func get_random_definitions(exclude_word: String, count: int) -> Array[String]:
	var definitions = []
	for word in all_words:
		if word["word"] != exclude_word:
			definitions.append(word["definition"])
	
	definitions.shuffle()
	return definitions.slice(0, count)

# Get random words (not definitions) as distractors
func get_random_word_strings(exclude_word: String, count: int) -> Array[String]:
	var words = []
	for word in all_words:
		if word["word"] != exclude_word:
			words.append(word["word"])
	
	words.shuffle()
	return words.slice(0, count)

# Reset word usage tracking (call on "Play Again")
func reset_usage_tracking() -> void:
	used_words.clear()

# Get all words (for debugging)
func get_all_words() -> Array[Dictionary]:
	return all_words

# Check if vocabulary is loaded and valid
func is_vocabulary_ready() -> bool:
	return vocabulary_loaded

# Get load error message
func get_load_error() -> String:
	return load_error
```

**Register in project.godot AutoLoad:**
```
[autoload]
VocabularyManager="*res://scripts/VocabularyManager.gd"
```

**Testing:**
- Create test vocabulary.json with 46 valid entries
- Test loading with valid file
- Test error cases:
  - Missing file
  - Invalid JSON syntax
  - Missing 'words' array
  - Insufficient word count (<46)
  - Missing required fields
  - Wrong synonym/antonym count
  - Missing ___ placeholder
- Verify word usage tracking (no repeats)

---

#### 1.3 Create Error Screen Scene
**Files:** `scenes/VocabularyError.tscn`, `scripts/VocabularyError.gd`

**Purpose:** Display vocabulary loading errors and prevent game start

**Scene Structure:**
```
VocabularyError (Control - fullscreen)
├─ Background (ColorRect - #1E1B2E, full screen)
├─ CenterContainer
│  └─ ErrorPanel (PanelContainer)
│     └─ VBoxContainer (padding: 40px)
│        ├─ ErrorIcon (Label - "⚠️", 72px font)
│        ├─ Spacer (16px)
│        ├─ ErrorTitle (Label - "Vocabulary Loading Error")
│        ├─ Spacer (24px)
│        ├─ ErrorMessage (Label - error details)
│        ├─ Spacer (32px)
│        └─ HelpText (Label - instructions)
```

**Styling (per Style Guide):**
- ErrorPanel:
  - Background: Card Background (#2D2640)
  - Border radius: 24px
  - Max width: 600px
  - Padding: 40px (XXLarge spacing)
  - Shadow: Level 3 `0 8px 24px rgba(0,0,0,0.2)`
- ErrorIcon:
  - Size: 72px
  - Color: Warning (#F59E0B)
  - Alignment: Center
- ErrorTitle:
  - Font: Fredoka Bold
  - Size: 36px (H1 range)
  - Color: Light Base (#F8FAFC)
  - Alignment: Center
- ErrorMessage:
  - Font: Nunito Regular
  - Size: 18px (Body Large)
  - Color: Light Base (#F8FAFC)
  - Alignment: Center
  - Line height: 1.5
  - Word wrap enabled
- HelpText:
  - Font: Nunito Regular
  - Size: 14px (Small)
  - Color: Light Base (#F8FAFC) with 70% opacity
  - Alignment: Center
  - Text: "Please check the console for details and ensure vocabulary.json is properly configured."

**Script:**
```gdscript
extends Control

func _ready():
	# This scene is shown when vocabulary fails to load
	# Error message is set by Main.gd
	pass

func set_error_message(message: String) -> void:
	$CenterContainer/ErrorPanel/VBoxContainer/ErrorMessage.text = message

func _play_entrance_animation() -> void:
	# Error panel scale bounce entrance
	$CenterContainer/ErrorPanel.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/ErrorPanel, "scale", Vector2.ONE, 0.4)
```

---

#### 1.4 Update Main.gd to Handle Vocabulary Loading
**File:** `scripts/Main.gd`

**Add vocabulary loading check before showing info modal:**

```gdscript
extends Control

var modal_scene = preload("res://scenes/Modal.tscn")
var error_scene = preload("res://scenes/VocabularyError.tscn")
var modal_instance = null

func _ready():
	# Connect vocabulary signals
	VocabularyManager.vocabulary_load_failed.connect(_on_vocabulary_load_failed)
	VocabularyManager.vocabulary_loaded_successfully.connect(_on_vocabulary_loaded)
	
	$StartButton.pressed.connect(_on_start_pressed)
	GameManager.load_game_scene.connect(_on_load_game_scene)
	GameManager.show_ready_modal.connect(_show_ready_modal)
	GameManager.show_completion_screen.connect(_show_completion_screen)

func _on_start_pressed():
	# Check if vocabulary is loaded
	if not VocabularyManager.is_vocabulary_ready():
		_on_vocabulary_load_failed(VocabularyManager.get_load_error())
		return
	
	# Hide main menu
	$TitleLabel.hide()
	$StartButton.hide()
	
	# Show info modal
	_show_info_modal()

func _on_vocabulary_load_failed(error_message: String):
	# Hide main menu
	$TitleLabel.hide()
	$StartButton.hide()
	
	# Show error screen
	var error_screen = error_scene.instantiate()
	$GameContainer.add_child(error_screen)
	error_screen.set_error_message(error_message)
	error_screen._play_entrance_animation()
	$GameContainer.show()

func _on_vocabulary_loaded():
	print("Vocabulary ready: ", VocabularyManager.get_all_words().size(), " words loaded")

# ... rest of existing Main.gd code remains unchanged
```

---

#### 1.5 Update GameManager for 5 Games
**File:** `scripts/GameManager.gd`

**Update game list and add score tracking:**

```gdscript
extends Node
## GameManager - Singleton for game flow control
## Manages navigation between 5 vocabulary games

var current_game_index: int = -1

var games = [
	{
		"name": "Memory Match",
		"scene": "res://scenes/MemoryGame.tscn",
		"character": "Cat",
		"color": "#8B5CF6"
	},
	{
		"name": "Pick the Meaning",
		"scene": "res://scenes/MultipleChoice.tscn",
		"character": "Dog",
		"color": "#F97316"
	},
	{
		"name": "Complete the Sentence",
		"scene": "res://scenes/FillInBlank.tscn",
		"character": "Rabbit",
		"color": "#3B82F6"
	},
	{
		"name": "Word Relationships",
		"scene": "res://scenes/SynonymAntonym.tscn",
		"character": "Fox",
		"color": "#F97316"
	},
	{
		"name": "Match the Meaning",
		"scene": "res://scenes/WordMatching.tscn",
		"character": "Bird",
		"color": "#10B981"
	}
]

# Score tracking: [score, total] for each game
var game_scores: Array = [
	[0, 8],   # Memory: 8 pairs
	[0, 10],  # Multiple Choice: 10 questions
	[0, 10],  # Fill-in-Blank: 10 questions
	[0, 10],  # Synonym/Antonym: 10 questions
	[0, 8]    # Word Matching: 8 questions
]

# Signals
signal game_completed(game_name: String)
signal show_info_modal()
signal show_ready_modal(completed_game: String, next_game: String)
signal load_game_scene(scene_path: String)
signal show_completion_screen()

func _ready():
	game_completed.connect(_on_game_completed)

func get_current_game_name() -> String:
	if current_game_index >= 0 and current_game_index < games.size():
		return games[current_game_index]["name"]
	return ""

func get_current_game_scene() -> String:
	if current_game_index >= 0 and current_game_index < games.size():
		return games[current_game_index]["scene"]
	return ""

func get_next_game_name() -> String:
	var next_index = current_game_index + 1
	if next_index < games.size():
		return games[next_index]["name"]
	return ""

func advance_to_next_game() -> void:
	current_game_index += 1
	if current_game_index < games.size():
		emit_signal("load_game_scene", games[current_game_index]["scene"])
	else:
		emit_signal("show_completion_screen")

func is_last_game() -> bool:
	return current_game_index >= games.size() - 1

func reset_flow() -> void:
	current_game_index = -1
	# Reset all scores
	for i in range(game_scores.size()):
		game_scores[i][0] = 0
	# Reset vocabulary word usage tracking
	VocabularyManager.reset_usage_tracking()

func record_game_score(game_index: int, score: int) -> void:
	if game_index >= 0 and game_index < game_scores.size():
		game_scores[game_index][0] = score

func get_total_score() -> int:
	var total = 0
	for score_data in game_scores:
		total += score_data[0]
	return total

func get_total_possible() -> int:
	var total = 0
	for score_data in game_scores:
		total += score_data[1]
	return total

func get_game_score_text(game_index: int) -> String:
	if game_index >= 0 and game_index < game_scores.size():
		return str(game_scores[game_index][0]) + "/" + str(game_scores[game_index][1])
	return "0/0"

func _on_game_completed(game_name: String):
	if is_last_game():
		emit_signal("show_completion_screen")
	else:
		var next_game = get_next_game_name()
		emit_signal("show_ready_modal", game_name, next_game)
```

---

#### 1.6 Update Info Modal Text for 5 Games
**File:** `scripts/Main.gd` (update _show_info_modal function)

**Update modal text to list 5 games:**

```gdscript
func _show_info_modal():
	modal_instance = modal_scene.instantiate()
	$ModalLayer.add_child(modal_instance)
	
	var body_text = "[center]You have [b]five awesome games[/b] to complete today:\n\n"
	body_text += "🧠 [b]Memory Match[/b] - Find the pairs!\n"
	body_text += "✅ [b]Pick the Meaning[/b] - Choose the definition\n"
	body_text += "✏️ [b]Complete the Sentence[/b] - Fill in the blank\n"
	body_text += "🔄 [b]Word Relationships[/b] - Find synonyms & antonyms\n"
	body_text += "🎯 [b]Match the Meaning[/b] - Which word fits?\n\n"
	body_text += "Ready to start? Let's go![/center]"
	
	modal_instance.show_modal("Welcome, Friend! 🎉", body_text, "Let's Go!")
	modal_instance.modal_action_pressed.connect(_on_info_modal_action)
```

---

#### 1.7 Create Bird Character in CharacterHelper
**File:** `scripts/CharacterHelper.gd`

**Add create_bird function:**

```gdscript
# Add to existing CharacterHelper.gd

static func create_bird(parent: Node2D, center: Vector2, color: Color) -> Node2D:
	var bird = Node2D.new()
	bird.name = "Bird"
	bird.position = center
	
	# Body (round, 110x90)
	var body = ColorRect.new()
	body.size = Vector2(110, 90)
	body.position = Vector2(-55, -20)  # Center on bird position
	body.color = color
	var body_style = StyleBoxFlat.new()
	body_style.bg_color = color
	body_style.corner_radius_top_left = 20
	body_style.corner_radius_top_right = 20
	body_style.corner_radius_bottom_left = 20
	body_style.corner_radius_bottom_right = 20
	body_style.border_width_left = 4
	body_style.border_width_right = 4
	body_style.border_width_top = 4
	body_style.border_width_bottom = 4
	body_style.border_color = Color.BLACK
	# Note: ColorRect doesn't support StyleBox, use Panel instead
	var body_panel = Panel.new()
	body_panel.custom_minimum_size = Vector2(110, 90)
	body_panel.position = Vector2(-55, -20)
	body_panel.add_theme_stylebox_override("panel", body_style)
	bird.add_child(body_panel)
	
	# Head (circle, 95px diameter)
	var head_panel = Panel.new()
	head_panel.custom_minimum_size = Vector2(95, 95)
	head_panel.position = Vector2(-47.5, -85)
	var head_style = StyleBoxFlat.new()
	head_style.bg_color = color
	head_style.corner_radius_top_left = 48
	head_style.corner_radius_top_right = 48
	head_style.corner_radius_bottom_left = 48
	head_style.corner_radius_bottom_right = 48
	head_style.border_width_left = 4
	head_style.border_width_right = 4
	head_style.border_width_top = 4
	head_style.border_width_bottom = 4
	head_style.border_color = Color.BLACK
	head_panel.add_theme_stylebox_override("panel", head_style)
	bird.add_child(head_panel)
	
	# Eyes (2 black circles, 33px diameter, 45px apart)
	var eye_left = create_circle(Vector2(-22, -55), 16.5, Color.BLACK)
	bird.add_child(eye_left)
	
	var eye_right = create_circle(Vector2(22, -55), 16.5, Color.BLACK)
	bird.add_child(eye_right)
	
	# Beak (small triangle, orange accent)
	var beak = Polygon2D.new()
	beak.polygon = PackedVector2Array([
		Vector2(0, -30),
		Vector2(-8, -20),
		Vector2(8, -20)
	])
	beak.color = Color("#F97316")  # Orange
	bird.add_child(beak)
	
	# Add black outline to beak
	var beak_outline = Line2D.new()
	beak_outline.add_point(Vector2(0, -30))
	beak_outline.add_point(Vector2(-8, -20))
	beak_outline.add_point(Vector2(8, -20))
	beak_outline.add_point(Vector2(0, -30))
	beak_outline.width = 4
	beak_outline.default_color = Color.BLACK
	bird.add_child(beak_outline)
	
	# Left Wing (separate Node2D for animation) - rounded rectangle 20x30
	var wing_left = Node2D.new()
	wing_left.name = "WingLeft"
	wing_left.position = Vector2(-60, -10)
	
	var wing_left_panel = Panel.new()
	wing_left_panel.custom_minimum_size = Vector2(20, 30)
	wing_left_panel.position = Vector2(-10, -15)
	var wing_style = StyleBoxFlat.new()
	wing_style.bg_color = color.darkened(0.2)
	wing_style.corner_radius_top_left = 8
	wing_style.corner_radius_top_right = 8
	wing_style.corner_radius_bottom_left = 8
	wing_style.corner_radius_bottom_right = 8
	wing_style.border_width_left = 4
	wing_style.border_width_right = 4
	wing_style.border_width_top = 4
	wing_style.border_width_bottom = 4
	wing_style.border_color = Color.BLACK
	wing_left_panel.add_theme_stylebox_override("panel", wing_style)
	wing_left.add_child(wing_left_panel)
	bird.add_child(wing_left)
	
	# Tail feathers (3 small feather shapes) - separate Node2D
	var tail = Node2D.new()
	tail.name = "Tail"
	tail.position = Vector2(0, 70)
	
	# 3 feather shapes (simple ovals)
	for i in range(3):
		var feather = Panel.new()
		feather.custom_minimum_size = Vector2(15, 25)
		feather.position = Vector2((i - 1) * 12 - 7.5, 0)
		var feather_style = StyleBoxFlat.new()
		feather_style.bg_color = color.darkened(0.3)
		feather_style.corner_radius_top_left = 12
		feather_style.corner_radius_top_right = 12
		feather_style.corner_radius_bottom_left = 12
		feather_style.corner_radius_bottom_right = 12
		feather_style.border_width_left = 3
		feather_style.border_width_right = 3
		feather_style.border_width_top = 3
		feather_style.border_width_bottom = 3
		feather_style.border_color = Color.BLACK
		feather.add_theme_stylebox_override("panel", feather_style)
		tail.add_child(feather)
	
	bird.add_child(tail)
	
	parent.add_child(bird)
	return bird

# Helper function to create circle (if not already present)
static func create_circle(position: Vector2, radius: float, color: Color) -> Panel:
	var circle = Panel.new()
	circle.custom_minimum_size = Vector2(radius * 2, radius * 2)
	circle.position = Vector2(position.x - radius, position.y - radius)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = int(radius)
	style.corner_radius_top_right = int(radius)
	style.corner_radius_bottom_left = int(radius)
	style.corner_radius_bottom_right = int(radius)
	circle.add_theme_stylebox_override("panel", style)
	return circle
```

---

### PR 1 Testing Checklist

**Vocabulary System:**
- [ ] vocabulary.json file created with exactly 46 words
- [ ] All words have complete entries (word, definition, synonyms, antonyms, example_sentence, difficulty)
- [ ] All synonyms arrays have exactly 4 items
- [ ] All antonyms arrays have exactly 4 items
- [ ] All example sentences contain ___ placeholder
- [ ] JSON syntax is valid (no parse errors)
- [ ] VocabularyManager loads successfully
- [ ] VocabularyManager validates all entries correctly

**Error Handling:**
- [ ] Error screen displays when vocabulary.json is missing
- [ ] Error screen displays when JSON is malformed
- [ ] Error screen displays when word count < 46
- [ ] Error screen displays when required fields are missing
- [ ] Error screen displays when synonym/antonym count is wrong
- [ ] Error screen displays when ___ placeholder is missing
- [ ] Error messages are clear and helpful
- [ ] Game prevents start when vocabulary fails to load

**GameManager Updates:**
- [ ] GameManager lists all 5 games correctly
- [ ] GameManager tracks scores for all 5 games
- [ ] Score tracking resets on "Play Again"
- [ ] Word usage tracking works (no repeated words across games)

**Info Modal:**
- [ ] Info modal lists all 5 games with correct names and emojis
- [ ] Modal displays correctly with updated text

**Bird Character:**
- [ ] Bird character renders correctly (green color)
- [ ] Bird has all required parts (head, body, eyes, beak, wing, tail feathers)
- [ ] Bird matches style guide (4px outline, rounded shapes, ~250px tall)
- [ ] Bird character follows same structure as other characters

**Integration:**
- [ ] Main screen starts normally
- [ ] Clicking "Start" checks vocabulary loading
- [ ] No console errors on successful vocabulary load
- [ ] Console shows clear error on vocabulary failure
- [ ] Project runs at 60fps

---

## PR 2: Game Logic Implementation for All 5 Modes

**Objective:** Implement complete gameplay logic for all 5 vocabulary games.

**Dependencies:** PR 1 must be merged first (vocabulary system operational)

### Tasks

#### 2.1 Implement Memory Match Game (Game 1)
**Files:** Update `scenes/MemoryGame.tscn` (currently `Flashcards.tscn`), `scripts/MemoryGame.gd` (currently `Flashcards.gd`)

**First: Rename existing files:**
- Rename `scenes/Flashcards.tscn` → `scenes/MemoryGame.tscn`
- Rename `scripts/Flashcards.gd` → `scripts/MemoryGame.gd`

**Scene Structure:**
```
MemoryGame (Control - fullscreen)
├─ Background (ColorRect - #8B5CF6, full screen)
├─ HeaderBar (HBoxContainer - top, 40px margin)
│  ├─ TitleLabel (Label - "Memory Match")
│  └─ ScoreLabel (Label - "Score: 0/8")
├─ GridContainer (4 columns, centered, 16px gap)
│  ├─ Card1...Card16 (Button - custom CardButton style)
├─ Character (Node2D - Cat, centered below grid)
│  └─ Tail (animated)
├─ WinMessage (Label - "All Matched! 🎉", hidden initially)
├─ NextButton (Button - bottom right, disabled initially)
```

**Card Styling:**
- Size: 140x100px (responsive, may scale)
- Border: 3px solid #EC4899 (pink)
- Border radius: 12px
- Font: Nunito Regular, 16px
- Text color: #1E1B2E (dark on light background)
- Background (face-down): Purple gradient
- Background (face-up): Light Base (#F8FAFC)
- Background (matched): Success green (#10B981) with green border
- Shadow: Level 2 `0 4px 12px rgba(0,0,0,0.15)`

**Script Implementation:**

```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

class Card:
	var content: String
	var is_word: bool  # true if word, false if definition
	var pair_id: int
	var is_flipped: bool = false
	var is_matched: bool = false
	var button: Button

var cards: Array[Card] = []
var selected_cards: Array[Card] = []
var matches_found: int = 0
var total_pairs: int = 8
var is_checking: bool = false  # Prevent clicks during check

# Tail animation
var tail_base_x: float
var wiggle_timer: Timer

func _ready():
	# Create cat character
	var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Colors.PRIMARY_PURPLE)
	if $Character.has_node("Tail"):
		tail_base_x = $Character/Tail.position.x
	
	# Setup tail wiggle timer
	wiggle_timer = Timer.new()
	wiggle_timer.wait_time = 2.0
	wiggle_timer.timeout.connect(_wiggle_tail)
	add_child(wiggle_timer)
	wiggle_timer.start()
	
	# Setup game
	_setup_game()
	
	# Connect next button
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.disabled = true

func _setup_game():
	# Get 8 random words from vocabulary
	var words = VocabularyManager.get_random_words(8)
	
	if words.size() < 8:
		push_error("Not enough vocabulary words")
		return
	
	# Create card data (8 word cards + 8 definition cards)
	var card_data = []
	for i in range(8):
		# Word card
		var word_card = Card.new()
		word_card.content = words[i]["word"]
		word_card.is_word = true
		word_card.pair_id = i
		card_data.append(word_card)
		
		# Definition card
		var def_card = Card.new()
		def_card.content = words[i]["definition"]
		def_card.is_word = false
		def_card.pair_id = i
		card_data.append(def_card)
	
	# Shuffle cards
	card_data.shuffle()
	
	# Assign to buttons in GridContainer
	var grid = $GridContainer
	for i in range(16):
		var card = card_data[i]
		var button = grid.get_child(i) as Button
		card.button = button
		cards.append(card)
		
		# Setup button
		button.text = "?"  # Face-down state
		button.pressed.connect(_on_card_pressed.bind(i))
		_style_card_face_down(button)

func _on_card_pressed(card_index: int):
	if is_checking:
		return
	
	var card = cards[card_index]
	
	# Can't click already flipped or matched cards
	if card.is_flipped or card.is_matched:
		return
	
	# Flip card
	_flip_card(card)
	selected_cards.append(card)
	
	# Check if we have 2 cards selected
	if selected_cards.size() == 2:
		is_checking = true
		await get_tree().create_timer(0.5).timeout
		_check_match()

func _flip_card(card: Card):
	card.is_flipped = true
	card.button.text = card.content
	_style_card_face_up(card.button)
	
	# Flip animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card.button, "scale", Vector2(1.1, 1.1), 0.15)
	tween.tween_property(card.button, "scale", Vector2.ONE, 0.15)

func _check_match():
	var card1 = selected_cards[0]
	var card2 = selected_cards[1]
	
	if card1.pair_id == card2.pair_id:
		# Match found!
		card1.is_matched = true
		card2.is_matched = true
		_style_card_matched(card1.button)
		_style_card_matched(card2.button)
		
		matches_found += 1
		$HeaderBar/ScoreLabel.text = "Score: " + str(matches_found) + "/" + str(total_pairs)
		
		# Cat celebration animation
		_play_cat_celebration()
		
		# Check if all matched
		if matches_found == total_pairs:
			_on_game_won()
	else:
		# No match - flip back after delay
		await get_tree().create_timer(1.5).timeout
		_flip_card_back(card1)
		_flip_card_back(card2)
	
	selected_cards.clear()
	is_checking = false

func _flip_card_back(card: Card):
	card.is_flipped = false
	card.button.text = "?"
	_style_card_face_down(card.button)

func _style_card_face_down(button: Button):
	# Purple gradient background
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	# Note: Button gradients require StyleBoxFlat with gradient
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.PRIMARY_PURPLE
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.PRIMARY_PINK
	button.add_theme_stylebox_override("normal", style)

func _style_card_face_up(button: Button):
	# Light background with dark text
	button.add_theme_color_override("font_color", Colors.DARK_BASE)
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.LIGHT_BASE
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.PRIMARY_PINK
	button.add_theme_stylebox_override("normal", style)

func _style_card_matched(button: Button):
	# Green background and border
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.SUCCESS
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.SUCCESS
	button.add_theme_stylebox_override("normal", style)

func _play_cat_celebration():
	# Cat bounce animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Character, "position:y", $Character.position.y - 20, 0.2)
	tween.tween_property($Character, "position:y", $Character.position.y, 0.2)

func _on_game_won():
	# Show win message
	$WinMessage.show()
	$WinMessage.text = "All Matched! 🎉"
	
	# Animate message
	$WinMessage.modulate.a = 0
	$WinMessage.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($WinMessage, "modulate:a", 1.0, 0.3)
	tween.tween_property($WinMessage, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	
	# Wait 2 seconds, then enable Next button
	await get_tree().create_timer(2.0).timeout
	$NextButton.disabled = false
	Anim.create_scale_bounce($NextButton, 1.0, 0.3)
	
	# Record score
	GameManager.record_game_score(0, matches_found)

func _wiggle_tail():
	if not $Character.has_node("Tail"):
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property($Character/Tail, "position:x", tail_base_x + 10, 0.25)
	tween.tween_property($Character/Tail, "position:x", tail_base_x - 10, 0.25)
	tween.tween_property($Character/Tail, "position:x", tail_base_x, 0.25)

func _on_next_pressed():
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	GameManager.emit_signal("game_completed", "Memory Match")
```

**Scene Setup in Godot Editor:**
1. Open `scenes/MemoryGame.tscn`
2. Update structure to match above
3. Add 16 Button nodes to GridContainer
4. Configure GridContainer: 4 columns
5. Set card button sizes: 140x100px minimum
6. Position Character node at center-bottom
7. Position WinMessage at center
8. Style all elements per style guide

---

#### 2.2 Implement Multiple Choice Game (Game 2)
**Files:** Update `scenes/MultipleChoice.tscn`, `scripts/MultipleChoice.gd`

**Scene Structure:**
```
MultipleChoice (Control - fullscreen)
├─ Background (ColorRect - #F97316, full screen)
├─ HeaderBar (HBoxContainer)
│  ├─ TitleLabel ("Pick the Meaning")
│  └─ ProgressLabel ("Question 1/10")
├─ QuestionPanel (PanelContainer - centered, max 700px width)
│  └─ VBoxContainer (32px padding)
│     ├─ QuestionLabel ("What does 'abundant' mean?")
│     ├─ Spacer (24px)
│     ├─ AnswerA (Button)
│     ├─ AnswerB (Button)
│     ├─ AnswerC (Button)
│     └─ AnswerD (Button)
├─ FeedbackLabel (Label - animated, hidden initially)
├─ Character (Node2D - Dog with tail)
├─ FooterBar (HBoxContainer)
│  ├─ ScoreLabel ("Score: 0/10")
│  └─ NextButton (disabled initially)
```

**Script Implementation:**

```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

class Question:
	var word: String
	var correct_definition: String
	var options: Array[String] = []  # 4 options, shuffled
	var correct_index: int = -1

var questions: Array[Question] = []
var current_question_index: int = 0
var score: int = 0
var total_questions: int = 10
var is_answering: bool = false

var answer_buttons: Array[Button] = []
var tail_base_x: float
var wiggle_timer: Timer

func _ready():
	# Create dog character
	var dog = CharacterHelper.create_dog($Character, Vector2.ZERO, Colors.ORANGE)
	if $Character.has_node("Tail"):
		tail_base_x = $Character/Tail.position.x
	
	# Setup tail wiggle
	wiggle_timer = Timer.new()
	wiggle_timer.wait_time = 2.0
	wiggle_timer.timeout.connect(_wiggle_tail)
	add_child(wiggle_timer)
	wiggle_timer.start()
	
	# Get answer buttons
	answer_buttons = [
		$QuestionPanel/VBoxContainer/AnswerA,
		$QuestionPanel/VBoxContainer/AnswerB,
		$QuestionPanel/VBoxContainer/AnswerC,
		$QuestionPanel/VBoxContainer/AnswerD
	]
	
	# Connect buttons
	for i in range(4):
		answer_buttons[i].pressed.connect(_on_answer_pressed.bind(i))
	
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.disabled = true
	
	# Setup questions
	_generate_questions()
	_display_question()

func _generate_questions():
	# Get 10 random words
	var words = VocabularyManager.get_random_words(10)
	
	if words.size() < 10:
		push_error("Not enough vocabulary words")
		return
	
	for word_data in words:
		var q = Question.new()
		q.word = word_data["word"]
		q.correct_definition = word_data["definition"]
		
		# Get 3 distractor definitions
		var distractors = VocabularyManager.get_random_definitions(q.word, 3)
		
		# Build options array
		q.options = [q.correct_definition] + distractors
		q.options.shuffle()
		
		# Find correct index
		q.correct_index = q.options.find(q.correct_definition)
		
		questions.append(q)

func _display_question():
	if current_question_index >= questions.size():
		return
	
	var q = questions[current_question_index]
	
	# Update question text
	$QuestionPanel/VBoxContainer/QuestionLabel.text = "What does '" + q.word + "' mean?"
	
	# Update progress
	$HeaderBar/ProgressLabel.text = "Question " + str(current_question_index + 1) + "/" + str(total_questions)
	
	# Update answer buttons
	for i in range(4):
		answer_buttons[i].text = q.options[i]
		_reset_button_style(answer_buttons[i])
		answer_buttons[i].disabled = false
	
	# Hide feedback
	$FeedbackLabel.hide()
	
	is_answering = false

func _on_answer_pressed(button_index: int):
	if is_answering:
		return
	
	is_answering = true
	var q = questions[current_question_index]
	
	# Disable all buttons
	for btn in answer_buttons:
		btn.disabled = true
	
	if button_index == q.correct_index:
		# Correct answer
		_style_button_correct(answer_buttons[button_index])
		$FeedbackLabel.text = "Correct! 🎉"
		$FeedbackLabel.add_theme_color_override("font_color", Colors.SUCCESS)
		score += 1
		$FooterBar/ScoreLabel.text = "Score: " + str(score) + "/" + str(total_questions)
		_play_dog_celebration()
	else:
		# Wrong answer
		_style_button_wrong(answer_buttons[button_index])
		_style_button_correct(answer_buttons[q.correct_index])
		$FeedbackLabel.text = "Not quite. The answer is " + _get_letter(q.correct_index)
		$FeedbackLabel.add_theme_color_override("font_color", Colors.ERROR)
		_play_dog_sympathy()
	
	# Show feedback
	$FeedbackLabel.show()
	Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
	
	# Wait 2 seconds, then next question
	await get_tree().create_timer(2.0).timeout
	current_question_index += 1
	
	if current_question_index < total_questions:
		_display_question()
	else:
		_on_game_complete()

func _on_game_complete():
	# Show final score
	$FeedbackLabel.text = "You got " + str(score) + "/" + str(total_questions) + " correct!"
	$FeedbackLabel.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	$FeedbackLabel.show()
	
	# Enable next button
	$NextButton.disabled = false
	Anim.create_scale_bounce($NextButton, 1.0, 0.3)
	
	# Record score
	GameManager.record_game_score(1, score)

func _style_button_correct(button: Button):
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.SUCCESS
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.SUCCESS
	button.add_theme_stylebox_override("normal", style)

func _style_button_wrong(button: Button):
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.ERROR
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.ERROR
	button.add_theme_stylebox_override("normal", style)

func _reset_button_style(button: Button):
	# Reset to default theme style
	button.remove_theme_color_override("font_color")
	button.remove_theme_stylebox_override("normal")

func _get_letter(index: int) -> String:
	return ["A", "B", "C", "D"][index]

func _play_dog_celebration():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Character, "rotation", -0.1, 0.15)
	tween.tween_property($Character, "rotation", 0.1, 0.15)
	tween.tween_property($Character, "rotation", 0, 0.15)

func _play_dog_sympathy():
	var tween = create_tween()
	tween.tween_property($Character, "position:y", $Character.position.y + 10, 0.2)
	tween.tween_property($Character, "position:y", $Character.position.y, 0.2)

func _wiggle_tail():
	if not $Character.has_node("Tail"):
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property($Character/Tail, "position:x", tail_base_x + 10, 0.25)
	tween.tween_property($Character/Tail, "position:x", tail_base_x - 10, 0.25)
	tween.tween_property($Character/Tail, "position:x", tail_base_x, 0.25)

func _on_next_pressed():
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	GameManager.emit_signal("game_completed", "Pick the Meaning")
```

---

#### 2.3 Implement Fill-in-the-Blank Game (Game 3)
**Files:** Update `scenes/FillInBlank.tscn`, `scripts/FillInBlank.gd`

**Scene Structure:** Nearly identical to Multiple Choice, but with sentence display instead of question

**Script Implementation:** Very similar to MultipleChoice.gd, with these key differences:

```gdscript
extends Control

# ... similar setup to MultipleChoice ...

class SentenceQuestion:
	var sentence: String  # with ___ placeholder
	var correct_word: String
	var options: Array[String] = []  # 4 word options
	var correct_index: int = -1

func _generate_questions():
	var words = VocabularyManager.get_random_words(10)
	
	for word_data in words:
		var q = SentenceQuestion.new()
		q.sentence = word_data["example_sentence"]
		q.correct_word = word_data["word"]
		
		# Get 3 distractor words
		var distractors = VocabularyManager.get_random_word_strings(q.correct_word, 3)
		
		q.options = [q.correct_word] + distractors
		q.options.shuffle()
		q.correct_index = q.options.find(q.correct_word)
		
		questions.append(q)

func _display_question():
	# ... similar logic ...
	var q = questions[current_question_index]
	
	# Display sentence with blank
	$QuestionPanel/VBoxContainer/SentenceLabel.text = q.sentence
	
	# Answer buttons show word options (not definitions)
	for i in range(4):
		answer_buttons[i].text = q.options[i]
		# ... rest of button setup ...

# ... rest of logic is nearly identical to MultipleChoice ...
```

---

#### 2.4 Implement Synonym/Antonym Game (Game 4)
**Files:** Rename and update `scenes/SentenceGen.tscn` → `scenes/SynonymAntonym.tscn`, update `scripts/SentenceGen.gd` → `scripts/SynonymAntonym.gd`

**Scene Structure:** Similar to Multiple Choice, with instruction text that changes color

**Script Implementation:**

```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

class RelationshipQuestion:
	var target_word: String
	var question_type: String  # "synonym" or "antonym"
	var correct_answer: String
	var options: Array[String] = []
	var correct_index: int = -1

var questions: Array[RelationshipQuestion] = []
var current_question_index: int = 0
var score: int = 0
var total_questions: int = 10

# ... similar setup to MultipleChoice ...

func _generate_questions():
	var words = VocabularyManager.get_random_words(10)
	
	for i in range(words.size()):
		var word_data = words[i]
		var q = RelationshipQuestion.new()
		q.target_word = word_data["word"]
		
		# Alternate between synonym and antonym (50/50 mix)
		if i % 2 == 0:
			q.question_type = "synonym"
			q.correct_answer = word_data["synonyms"][0]  # Use first synonym
			
			# Options: 1 correct synonym + 3 other words (could be antonyms or unrelated)
			var distractors = []
			distractors.append(word_data["antonyms"][0])  # Add 1 antonym as distractor
			distractors.append_array(VocabularyManager.get_random_word_strings(q.target_word, 2))
			
			q.options = [q.correct_answer] + distractors
		else:
			q.question_type = "antonym"
			q.correct_answer = word_data["antonyms"][0]  # Use first antonym
			
			# Options: 1 correct antonym + 3 other words
			var distractors = []
			distractors.append(word_data["synonyms"][0])  # Add 1 synonym as distractor
			distractors.append_array(VocabularyManager.get_random_word_strings(q.target_word, 2))
			
			q.options = [q.correct_answer] + distractors
		
		q.options.shuffle()
		q.correct_index = q.options.find(q.correct_answer)
		
		questions.append(q)

func _display_question():
	var q = questions[current_question_index]
	
	# Update instruction text with color coding
	if q.question_type == "synonym":
		$QuestionPanel/VBoxContainer/InstructionLabel.text = "Which word is a SYNONYM for"
		$QuestionPanel/VBoxContainer/InstructionLabel.add_theme_color_override("font_color", Colors.SUCCESS)  # Green
	else:
		$QuestionPanel/VBoxContainer/InstructionLabel.text = "Which word is an ANTONYM for"
		$QuestionPanel/VBoxContainer/InstructionLabel.add_theme_color_override("font_color", Colors.ORANGE)
	
	# Display target word
	$QuestionPanel/VBoxContainer/TargetWordLabel.text = "'" + q.target_word + "'?"
	
	# ... rest similar to Multiple Choice ...

# ... rest of logic similar to MultipleChoice ...
```

---

#### 2.5 Implement Word Matching Game (Game 5)
**Files:** Create new `scenes/WordMatching.tscn`, `scripts/WordMatching.gd`

**Scene Structure:** Same as Multiple Choice

**Script Implementation:**

```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

class MatchingQuestion:
	var definition: String
	var correct_word: String
	var options: Array[String] = []  # 4 word options
	var correct_index: int = -1

var questions: Array[MatchingQuestion] = []
var current_question_index: int = 0
var score: int = 0
var total_questions: int = 8  # Only 8 questions for this game

var answer_buttons: Array[Button] = []
var wing_base_y: float
var flap_timer: Timer

func _ready():
	# Create bird character
	var bird = CharacterHelper.create_bird($Character, Vector2.ZERO, Colors.PRIMARY_GREEN)
	if $Character.has_node("WingLeft"):
		wing_base_y = $Character/WingLeft.position.y
	
	# Setup wing flap timer (2 seconds, like tail wiggle)
	flap_timer = Timer.new()
	flap_timer.wait_time = 2.0
	flap_timer.timeout.connect(_flap_wing)
	add_child(flap_timer)
	flap_timer.start()
	
	# ... rest similar to MultipleChoice setup ...
	
	_generate_questions()
	_display_question()

func _generate_questions():
	var words = VocabularyManager.get_random_words(8)
	
	for word_data in words:
		var q = MatchingQuestion.new()
		q.definition = word_data["definition"]
		q.correct_word = word_data["word"]
		
		# Get 3 distractor words
		var distractors = VocabularyManager.get_random_word_strings(q.correct_word, 3)
		
		q.options = [q.correct_word] + distractors
		q.options.shuffle()
		q.correct_index = q.options.find(q.correct_word)
		
		questions.append(q)

func _display_question():
	var q = questions[current_question_index]
	
	# Display instruction
	$QuestionPanel/VBoxContainer/InstructionLabel.text = "Which word means:"
	
	# Display definition
	$QuestionPanel/VBoxContainer/DefinitionLabel.text = "\"" + q.definition + "\""
	
	# Update progress (out of 8, not 10)
	$HeaderBar/ProgressLabel.text = "Question " + str(current_question_index + 1) + "/8"
	
	# Answer buttons show word options
	for i in range(4):
		answer_buttons[i].text = q.options[i]
		_reset_button_style(answer_buttons[i])
		answer_buttons[i].disabled = false

func _flap_wing():
	if not $Character.has_node("WingLeft"):
		return
	
	# Wing flap animation (up and down)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property($Character/WingLeft, "position:y", wing_base_y - 15, 0.25)
	tween.tween_property($Character/WingLeft, "position:y", wing_base_y, 0.25)

func _play_bird_celebration():
	# Both wings flap rapidly
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property($Character/WingLeft, "position:y", wing_base_y - 20, 0.1)
	tween.tween_property($Character/WingLeft, "position:y", wing_base_y, 0.1)

# ... rest of logic very similar to MultipleChoice ...
# Record score to game index 4 (last game):
# GameManager.record_game_score(4, score)

func _on_next_pressed():
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	# Last game - go straight to completion (no ready modal)
	GameManager.emit_signal("show_completion_screen")
```

---

#### 2.6 Update Completion Screen
**Files:** Update `scenes/Completion.tscn`, `scripts/Completion.gd`

**Updates needed:**
1. Add 5th character (Bird) to character display
2. Update score display to show total score from all 5 games
3. Optional: Show per-game breakdown

**Script Updates:**

```gdscript
extends Control

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")

func _ready():
	_create_characters()
	_display_scores()
	_play_entrance_animation()
	$PlayAgainButton.pressed.connect(_on_play_again_pressed)

func _create_characters():
	# Create all 5 characters at 50% scale
	var cat = CharacterHelper.create_cat($CharactersRow/CatChar, Vector2.ZERO, Colors.PRIMARY_PURPLE)
	cat.scale = Vector2(0.5, 0.5)
	
	var dog = CharacterHelper.create_dog($CharactersRow/DogChar, Vector2.ZERO, Colors.ORANGE)
	dog.scale = Vector2(0.5, 0.5)
	
	var rabbit = CharacterHelper.create_rabbit($CharactersRow/RabbitChar, Vector2.ZERO, Colors.PRIMARY_BLUE)
	rabbit.scale = Vector2(0.5, 0.5)
	
	var fox = CharacterHelper.create_fox($CharactersRow/FoxChar, Vector2.ZERO, Colors.ORANGE)
	fox.scale = Vector2(0.5, 0.5)
	
	var bird = CharacterHelper.create_bird($CharactersRow/BirdChar, Vector2.ZERO, Colors.PRIMARY_GREEN)
	bird.scale = Vector2(0.5, 0.5)

func _display_scores():
	# Get total score from GameManager
	var total_score = GameManager.get_total_score()
	var total_possible = GameManager.get_total_possible()
	
	# Update message label
	$MessageLabel.text = "WOW! You answered " + str(total_score) + "/" + str(total_possible) + " questions correctly!"
	
	# Optional: Add per-game breakdown
	# var breakdown = "\n\nMemory: " + GameManager.get_game_score_text(0)
	# breakdown += " | Multiple Choice: " + GameManager.get_game_score_text(1)
	# ... etc

func _play_entrance_animation():
	# ... same as v1, but now animates 5 characters instead of 4 ...
	
	# Characters pop in with staggered delay
	for i in range(5):  # Changed from 4 to 5
		var char_node = $CharactersRow.get_child(i)
		char_node.modulate.a = 0
		char_node.scale = Vector2(0.3, 0.3)
		
		await get_tree().create_timer(0.1 * i).timeout
		
		var char_tween = create_tween()
		char_tween.set_parallel(true)
		char_tween.tween_property(char_node, "modulate:a", 1, 0.3)
		char_tween.tween_property(char_node, "scale", Vector2(0.5, 0.5), 0.3).set_trans(Tween.TRANS_BACK)

func _on_play_again_pressed():
	GameManager.reset_flow()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
```

**Scene Structure Update:**
- Add 5th Container node in CharactersRow: `BirdChar` (Node2D)
- Ensure CharactersRow HBoxContainer has 5 children with proper spacing

---

### PR 2 Testing Checklist

**Memory Game:**
- [ ] 16 cards displayed in 4×4 grid
- [ ] Cards start face-down
- [ ] Clicking card flips it to reveal text
- [ ] 8 word cards and 8 definition cards present
- [ ] Matching pairs stay revealed with green highlight
- [ ] Non-matching pairs flip back after 1.5s delay
- [ ] Can't click during check delay
- [ ] Can't click already matched cards
- [ ] Score updates correctly (0/8 → 8/8)
- [ ] Cat plays celebration on each match
- [ ] "All Matched!" message appears when complete
- [ ] Next button enables after win
- [ ] Score recorded in GameManager

**Multiple Choice:**
- [ ] 10 questions displayed sequentially
- [ ] Each question shows word and 4 definition options
- [ ] Options are shuffled (correct answer in different positions)
- [ ] Clicking correct answer shows green highlight
- [ ] Clicking wrong answer shows red (clicked) and green (correct)
- [ ] Feedback message displays correctly
- [ ] Auto-advances after 2 seconds
- [ ] Score increments only on correct answers
- [ ] Progress shows "Question X/10"
- [ ] Final score displayed after question 10
- [ ] Next button enables when complete
- [ ] Dog animations play correctly

**Fill-in-Blank:**
- [ ] 10 questions with sentences containing ___
- [ ] Each question shows 4 word options
- [ ] Correct word completes sentence logically
- [ ] Same feedback system as Multiple Choice
- [ ] Rabbit animations work
- [ ] All other functionality matches Multiple Choice

**Synonym/Antonym:**
- [ ] 10 questions with mix of synonym/antonym
- [ ] Instruction text color changes (green for synonym, orange for antonym)
- [ ] Target word displayed clearly
- [ ] 4 word options per question
- [ ] Correct relationship identified
- [ ] Feedback explains relationship
- [ ] Fox animations work
- [ ] Score tracking works

**Word Matching:**
- [ ] 8 questions (not 10)
- [ ] Each question shows definition and 4 word options
- [ ] Correct word matches definition
- [ ] Progress shows "Question X/8"
- [ ] Bird character renders correctly
- [ ] Wing flap animation works (every 2 seconds)
- [ ] Feedback and scoring work correctly
- [ ] Goes directly to Completion screen (no ready modal)

**Completion Screen:**
- [ ] All 5 characters displayed
- [ ] Characters arranged properly (not cramped)
- [ ] Total score displayed: "X/46 questions correct"
- [ ] Score matches sum of all game scores
- [ ] Entrance animations work for all 5 characters
- [ ] Play Again returns to Main Screen
- [ ] Play Again resets all scores and word tracking

**Cross-Game Integration:**
- [ ] No word appears in multiple games during one playthrough
- [ ] Full flow: Main → Info Modal → Game 1 → Ready → Game 2 → Ready → Game 3 → Ready → Game 4 → Ready → Game 5 → Completion
- [ ] Ready modals show correct game names
- [ ] Each game receives unique vocabulary words
- [ ] Playing through 3+ times works correctly
- [ ] Scores reset properly on replay

**Edge Cases:**
- [ ] Rapid clicking doesn't break game state
- [ ] All games handle minimum vocabulary (46 words)
- [ ] No memory leaks after multiple playthroughs
- [ ] All animations run smoothly at 60fps
- [ ] No console errors during gameplay

---

## Acceptance Criteria Summary

Upon completion of both PRs, the following must be true:

### Vocabulary System:
✅ vocabulary.json file exists with exactly 46 words  
✅ All words have complete data (word, definition, 4 synonyms, 4 antonyms, example_sentence, difficulty)  
✅ VocabularyManager loads and validates vocabulary correctly  
✅ VocabularyManager prevents word repetition across games  
✅ Error screen displays on vocabulary loading failure  
✅ Game cannot start if vocabulary is invalid  

### Game Logic:
✅ Memory Match: 16 cards (8 pairs), flip/match mechanics, win detection  
✅ Multiple Choice: 10 questions, 4 options each, immediate feedback, scoring  
✅ Fill-in-Blank: 10 questions, sentence context, word selection, scoring  
✅ Synonym/Antonym: 10 questions, mixed types, color-coded instructions, scoring  
✅ Word Matching: 8 questions, definition→word matching, scoring  
✅ All games track scores correctly  
✅ All games provide immediate feedback (correct/wrong)  
✅ All games auto-advance after feedback  
✅ All games enable "Next" button only when complete  

### Navigation & Flow:
✅ GameManager tracks all 5 games correctly  
✅ Info modal lists all 5 games  
✅ Ready modals appear between games 1-4  
✅ Game 5 goes directly to Completion (no ready modal)  
✅ Completion screen shows all 5 characters (including Bird)  
✅ Completion screen displays total score (X/46)  
✅ Play Again resets all game state and word tracking  

### Visual & Animation:
✅ Bird character implemented (green, matches style guide)  
✅ All character animations work (tail wiggles, wing flaps)  
✅ Button feedback (green/red) is clear and responsive  
✅ All animations follow style guide timing  
✅ UI adapts to common aspect ratios  
✅ No visual glitches or overlapping elements  

### Performance & Quality:
✅ Project runs at 60fps on target devices  
✅ No console errors or warnings  
✅ No memory leaks after multiple playthroughs  
✅ All style guide specifications followed exactly  

---

## Implementation Notes

### Vocabulary Word List

The 46 words should cover a range of common adjectives suitable for grade 3-5:

**Positive/Neutral:** abundant, curious, eager, generous, joyful, loyal, peaceful, precious, thoughtful, bold, clever, elegant, gentle, lively, modest, nimble, patient, sincere, wise, zealous

**Negative/Challenging:** cautious, delicate, fragile, gloomy, humble, invisible, mysterious, nervous, obvious, quiet, ancient, distant, fierce, harsh, immense, rough, timid, weary

**Descriptive:** rapid, sturdy, keen, unique, vast, young, ordinary, quick

Each word should have age-appropriate definitions and real-world examples children can relate to.

### Timing Reference

- Button feedback: 0.2s (color change)
- Feedback display: 1.5-2s before next question
- Card flip delay: 1.5s for non-matching pairs
- Auto-advance: 2s after feedback display
- Character animations: 0.4-0.6s
- Tail/wing wiggles: Every 2 seconds

### Score Distribution

- Memory Match: 8 points (8 pairs)
- Multiple Choice: 10 points (10 questions)
- Fill-in-Blank: 10 points (10 questions)
- Synonym/Antonym: 10 points (10 questions)
- Word Matching: 8 points (8 questions)
- **Total: 46 points possible**

---

## Post-Implementation

After both PRs are merged:

1. Run full testing checklist from PR2
2. Test on actual target devices (laptop + tablet)
3. Verify 60fps performance
4. Verify all acceptance criteria met
5. Playtest full game flow 5+ times
6. Document any deviations from PRD (should be none)

**Next Phase (Future):** v2.1 - Add sound effects, music, and progress saving

---

**Status:** 📋 Ready for Implementation  
**Priority:** P0 (Core Gameplay)  
**Estimated Effort:** 6-8 development sessions  
**Dependencies:** v1.0 must be complete

