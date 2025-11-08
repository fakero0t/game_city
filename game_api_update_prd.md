# Game API Update PRD

## Overview

Transform the Godot vocabulary game from a fixed sequence of 5 games with global score tracking to an API-driven sequential flow where each game is loaded independently based on API responses. The system will simulate API calls using test data that matches the structure defined in `activity_card_format.md`.

## Goals

1. Remove global score display and continuous word list tracking
2. Implement API simulation layer that returns activity data on each "Next" click
3. Load games dynamically based on activity type from API response
4. Use test data matching the activity card format specification
5. Each game operates independently with its own content from the API response

## Current State Analysis

### Existing Architecture

- **GameManager**: Manages fixed sequence of 5 games, tracks global scores, handles transitions
- **VocabularyManager**: Loads vocabulary.json, tracks word usage across all games
- **Main.gd**: Entry point, handles modals and game container loading
- **Game Scripts**: 5 fixed games (MemoryGame, MultipleChoice, FillInBlank, SynonymAntonym, WordMatching)
- **Completion Screen**: Displays total score across all games

### Current Flow

1. User clicks "Start" → Info modal → First game loads
2. User completes game → Ready modal → Next game loads
3. Repeat for all 5 games
4. Completion screen shows total score

### Current Data Dependencies

- Games call `VocabularyManager.get_random_words()` to get content
- `VocabularyManager` tracks used words to prevent repetition
- `GameManager` tracks scores in `game_scores` array
- Completion screen reads `GameManager.get_total_score()`

## Requirements

### Functional Requirements

1. **API Simulation**
   - On "Next" click, simulate API call to `POST /api/session/:id/next`
   - Return test data matching activity card format structure
   - Include all required fields: `itemId`, `activityType`, `word`, `params`, etc.

2. **Dynamic Game Loading**
   - Map activity types to appropriate game scenes
   - Load game scene based on `activityType` from API response
   - Pass activity data to game script for content population

3. **Independent Game Operation**
   - Each game receives all content from API response
   - No dependency on VocabularyManager for word selection
   - No global score tracking
   - Games operate in isolation

4. **Test Data Management**
   - Create test data entries for each activity type
   - Store test data in a structured format (GDScript Dictionary/Array)
   - Select test data entry on each "Next" click
   - Support multiple test entries per activity type

5. **Removal of Global Features**
   - Remove global score display from completion screen
   - Remove VocabularyManager word usage tracking
   - Remove GameManager score tracking
   - Remove fixed game sequence

### Non-Functional Requirements

1. Maintain existing game UI/UX (no visual changes)
2. Preserve game mechanics and animations
3. Keep code structure modular and maintainable
4. Use async patterns for API simulation (simulate network delay)

## Architecture Changes

### New Components

1. **APISimulator** (new singleton)
   - Manages test data collection
   - Simulates API call with configurable delay
   - Returns activity card data structure
   - Handles test data selection logic

2. **ActivityData** (data structure)
   - Represents activity card format response
   - Validates required fields
   - Provides helper methods for data access

3. **ActivityMapper** (utility)
   - Maps `activityType` strings to game scene paths
   - Handles activity type to game type conversion

### Modified Components

1. **GameManager**
   - Remove: `game_scores` array, score tracking methods
   - Remove: Fixed `games` array and sequence logic
   - Add: API call handler for "Next" button
   - Add: Activity data storage and passing to games
   - Modify: `advance_to_next_game()` → `request_next_activity()`

2. **Main.gd**
   - Remove: References to fixed game sequence
   - Modify: Handle activity-based game loading
   - Modify: Remove score-related UI elements if any

3. **Game Scripts** (all 5 games)
   - Remove: Calls to `VocabularyManager.get_random_words()`
   - Add: `load_activity_data(activity_data: Dictionary)` method
   - Modify: Populate content from activity data instead of vocabulary manager
   - Modify: Remove score recording to GameManager

4. **Completion.gd**
   - Remove: Score display logic
   - Modify: Show generic completion message (no scores)

5. **VocabularyManager**
   - Keep: Vocabulary loading for fallback/test data generation
   - Remove: Word usage tracking (`used_words` array, `reset_usage_tracking()`)
   - Modify: Make optional dependency (games may not use it)

## API Simulation Layer

### APISimulator Singleton

**Location**: `scripts/APISimulator.gd`

**Responsibilities**:
- Store test data entries
- Simulate network delay (async)
- Return activity card format data
- Handle session ID (mock)

**Key Methods**:
```gdscript
# Request next activity (simulates POST /api/session/:id/next)
func request_next_activity(session_id: String) -> Dictionary

# Add test data entry
func add_test_data(activity_data: Dictionary) -> void

# Get all test data
func get_test_data() -> Array

# Clear test data
func clear_test_data() -> void
```

**Implementation Details**:
- Use `await get_tree().create_timer(delay).timeout` to simulate network delay (200-500ms)
- Store test data as Array of Dictionaries
- Select test data entry (round-robin, random, or sequential)
- Return deep copy of selected entry

## Test Data Structure

### Test Data Format

Test data entries must match the activity card format structure:

```gdscript
{
  "itemId": "uuid-string",
  "activityType": "connect_def" | "context_cloze" | "select_usage" | "synonym_mcq" | "flashcard_usage" | "spell_typed" | "definition_typed" | "sentence_typed_gen" | "paraphrase_typed_gen",
  "phase": "new" | "review",  # Optional
  "phaseProgress": {  # Optional
    "current": 1,
    "total": 10
  },
  "word": {
    "wordId": "uuid-string",
    "headword": "example",  # Optional (hidden for some activity types)
    "definition": "a thing",
    "pos": "noun",
    "media": [  # Array of media objects
      {
        "mediaId": "uuid-string",
        "kind": "audio" | "image",
        "url": "https://example.com/audio.mp3",
        "mimeType": "audio/mpeg",  # Optional
        "role": "word_pronunciation" | "alt_pronunciation" | "sentence_audio" | "illustration",
        "orderNo": 1
      }
    ]
  },
  "params": Dictionary | null  # Activity-specific parameters
}
```

### Test Data Collection

Create a test data collection with entries for each activity type:

1. **connect_def**: 3-5 test entries
2. **context_cloze**: 3-5 test entries
3. **select_usage**: 3-5 test entries
4. **synonym_mcq**: 3-5 test entries
5. **flashcard_usage**: 3-5 test entries
6. **spell_typed**: 2-3 test entries
7. **definition_typed**: 2-3 test entries
8. **sentence_typed_gen**: 2-3 test entries
9. **paraphrase_typed_gen**: 2-3 test entries

**Total**: ~25-40 test entries

### Test Data Storage

Store test data in `APISimulator` as a class variable:
```gdscript
var test_data_entries: Array[Dictionary] = []
var current_test_index: int = 0
```

Initialize with test data in `_ready()` or provide initialization method.

## Activity Type to Game Mapping

### Mapping Strategy

Map API activity types to existing game scenes:

| Activity Type | Game Scene | Notes |
|--------------|------------|-------|
| `connect_def` | `WordMatching.tscn` | Match definition to word |
| `context_cloze` | `FillInBlank.tscn` | Fill in blank in sentence |
| `select_usage` | `MultipleChoice.tscn` | Select correct usage sentence |
| `synonym_mcq` | `SynonymAntonym.tscn` | Select synonym/antonym |
| `flashcard_usage` | `MultipleChoice.tscn` | Select correct usage (first activity) |
| `spell_typed` | *New game or adapt existing* | Type spelling (not in current games) |
| `definition_typed` | *New game or adapt existing* | Type word from definition (not in current games) |
| `sentence_typed_gen` | `SentenceGen.tscn` | Type sentence (already exists) |
| `paraphrase_typed_gen` | *New game or adapt existing* | Type paraphrase (not in current games) |

### Implementation Notes

- For activity types without existing games (`spell_typed`, `definition_typed`, `paraphrase_typed_gen`), either:
  - Create placeholder games that show "Coming Soon" message
  - Map to closest existing game for testing
  - Create minimal implementations

- Create `ActivityMapper` utility class:
```gdscript
# scripts/ActivityMapper.gd
static func get_scene_path(activity_type: String) -> String:
    var mapping = {
        "connect_def": "res://scenes/WordMatching.tscn",
        "context_cloze": "res://scenes/FillInBlank.tscn",
        "select_usage": "res://scenes/MultipleChoice.tscn",
        "synonym_mcq": "res://scenes/SynonymAntonym.tscn",
        "flashcard_usage": "res://scenes/MultipleChoice.tscn",
        "sentence_typed_gen": "res://scenes/SentenceGen.tscn"
    }
    return mapping.get(activity_type, "res://scenes/MultipleChoice.tscn")  # Default fallback
```

## Data Flow

### New Flow Diagram

```
User clicks "Next"
    ↓
Game emits "next_activity_requested" signal
    ↓
GameManager.request_next_activity()
    ↓
APISimulator.request_next_activity(session_id)
    ↓
[Simulate network delay: 200-500ms]
    ↓
Select test data entry (round-robin or random)
    ↓
Return activity data Dictionary
    ↓
GameManager receives activity data
    ↓
ActivityMapper.get_scene_path(activity_type)
    ↓
Load game scene
    ↓
Pass activity data to game script
    ↓
Game.load_activity_data(activity_data)
    ↓
Game populates UI from activity data
    ↓
User plays game
```

### Signal Flow

**New Signals**:
```gdscript
# GameManager
signal next_activity_requested(session_id: String)
signal activity_data_received(activity_data: Dictionary)
signal activity_load_failed(error_message: String)

# Game scripts (when Next clicked)
signal next_clicked()  # Emitted by game, handled by GameManager
```

## Implementation Details

### GameManager Changes

**Remove**:
- `game_scores` array
- `record_game_score()` method
- `get_total_score()` method
- `get_total_possible()` method
- `get_game_score_text()` method
- Fixed `games` array
- `current_game_index` tracking
- `is_last_game()` method

**Add**:
- `current_session_id: String` (mock session ID)
- `current_activity_data: Dictionary` (current activity data)
- `request_next_activity()` method
- Connection to APISimulator

**Modify**:
- `advance_to_next_game()` → `request_next_activity()`
- `_on_game_completed()` → Handle activity completion, request next
- Remove score-related logic

### Game Script Changes

**All game scripts need**:

1. **New Method**: `load_activity_data(activity_data: Dictionary)`
   - Extract word data from `activity_data.word`
   - Extract params from `activity_data.params`
   - Populate game content (questions, options, etc.)
   - Set up game state

2. **Modify `_ready()`**:
   - Remove vocabulary manager calls
   - Wait for `load_activity_data()` call instead
   - Keep character setup, button connections

3. **Remove**:
   - Calls to `VocabularyManager.get_random_words()`
   - Calls to `VocabularyManager.get_random_definitions()`
   - Calls to `VocabularyManager.get_random_word_strings()`
   - Calls to `GameManager.record_game_score()`

4. **Modify**:
   - Question generation to use activity data
   - Answer validation to use activity data structure
   - Score tracking (local only, not sent to GameManager)

### Activity Data Extraction Examples

**For MultipleChoice (select_usage, flashcard_usage)**:
```gdscript
func load_activity_data(activity_data: Dictionary) -> void:
    var word_data = activity_data["word"]
    var params = activity_data["params"]
    
    # Extract options from params
    var options = params["options"]  # Array of {exampleId, text}
    
    # Create question
    var q = Question.new()
    q.word = word_data["headword"]
    q.correct_definition = word_data["definition"]
    # Map options to question format
    # ...
```

**For FillInBlank (context_cloze)**:
```gdscript
func load_activity_data(activity_data: Dictionary) -> void:
    var word_data = activity_data["word"]
    var params = activity_data["params"]
    
    # Extract sentence and options
    var sentence = params["sentence"]  # Sentence with "____"
    var options = params["options"]  # Array of headword strings
    
    # Create question
    var q = SentenceQuestion.new()
    q.sentence = sentence
    q.correct_word = word_data["headword"]
    q.options = options
    # ...
```

**For WordMatching (connect_def)**:
```gdscript
func load_activity_data(activity_data: Dictionary) -> void:
    var word_data = activity_data["word"]
    var params = activity_data["params"]
    
    # Extract definition and options
    var definition = word_data["definition"]
    var options = params["options"]  # Array of headword strings
    
    # Create question
    var q = MatchingQuestion.new()
    q.definition = definition
    q.correct_word = word_data["headword"]
    q.options = options
    # ...
```

### Completion Screen Changes

**Modify `_display_scores()`**:
```gdscript
func _display_scores() -> void:
    # Remove score calculation
    # Show generic completion message
    $CenterContent/VBoxContainer/MessageLabel.text = "Congratulations! You've completed all activities!"
```

## Files to Modify

### New Files

1. `scripts/APISimulator.gd` - API simulation singleton
2. `scripts/ActivityMapper.gd` - Activity type to scene mapping utility
3. `scripts/ActivityData.gd` (optional) - Data structure/validation helper

### Modified Files

1. `scripts/GameManager.gd`
   - Remove score tracking
   - Add API integration
   - Modify game flow logic

2. `scripts/Main.gd`
   - Update game loading logic
   - Remove score-related UI if any

3. `scripts/MemoryGame.gd`
   - Add `load_activity_data()` method
   - Remove vocabulary manager dependencies
   - Note: Memory game may need special handling (8 pairs) - may not map directly to activity types

4. `scripts/MultipleChoice.gd`
   - Add `load_activity_data()` method
   - Remove vocabulary manager dependencies
   - Support both `select_usage` and `flashcard_usage` activity types

5. `scripts/FillInBlank.gd`
   - Add `load_activity_data()` method
   - Remove vocabulary manager dependencies
   - Support `context_cloze` activity type

6. `scripts/SynonymAntonym.gd`
   - Add `load_activity_data()` method
   - Remove vocabulary manager dependencies
   - Support `synonym_mcq` activity type

7. `scripts/WordMatching.gd`
   - Add `load_activity_data()` method
   - Remove vocabulary manager dependencies
   - Support `connect_def` activity type

8. `scripts/Completion.gd`
   - Remove score display
   - Update completion message

9. `scripts/VocabularyManager.gd`
   - Remove word usage tracking
   - Keep vocabulary loading (for test data generation or fallback)

## Test Data Generation

### Test Data Creation Strategy

1. **Use existing vocabulary.json** as source for word data
2. **Generate test entries** programmatically or manually
3. **Store in APISimulator** initialization

### Test Data Entry Example

```gdscript
# Example test data entry for connect_def
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

### Test Data Selection Logic

Options for selecting test data on each "Next" click:

1. **Round-robin**: Cycle through test entries sequentially
2. **Random**: Select random entry each time
3. **Activity-type weighted**: Prefer certain activity types
4. **Sequential by type**: Complete all of one type before moving to next

**Recommendation**: Start with round-robin for predictable testing, allow configuration later.

## Edge Cases and Error Handling

### Error Scenarios

1. **No test data available**
   - Show error message
   - Fallback to default activity or end session

2. **Invalid activity type**
   - Use default game scene (MultipleChoice)
   - Log warning

3. **Missing required fields in activity data**
   - Validate before passing to game
   - Show error or use defaults

4. **API simulation failure**
   - Handle timeout/error gracefully
   - Retry or show error message

### Validation

Create validation function for activity data:
```gdscript
# In APISimulator or ActivityData
func validate_activity_data(data: Dictionary) -> bool:
    # Check required fields
    # Return true if valid, false otherwise
```

## Migration Strategy

### Phased Approach

1. **Phase 1**: Create APISimulator and test data structure
2. **Phase 2**: Modify GameManager to use API simulation
3. **Phase 3**: Update game scripts to accept activity data
4. **Phase 4**: Remove vocabulary manager dependencies
5. **Phase 5**: Remove score tracking
6. **Phase 6**: Update completion screen

### Backward Compatibility

- Keep VocabularyManager functional (for fallback)
- Keep game scenes loadable independently
- Maintain existing game logic (only change data source)

## Testing Considerations

### Test Scenarios

1. **Single activity flow**: Click Next → Load activity → Complete → Click Next
2. **Multiple activities**: Complete sequence of 5-10 activities
3. **Activity type variety**: Test all mapped activity types
4. **Error handling**: Test invalid data, missing fields
5. **API delay simulation**: Verify async behavior works correctly

### Test Data Requirements

- At least 2-3 entries per activity type
- Variety in word data (different POS, definitions)
- Complete media arrays (audio, images)
- Valid UUIDs for itemId, wordId, mediaId

## Success Criteria

1. ✅ No global score display
2. ✅ No continuous word list tracking
3. ✅ Each game loads independently after "Next" click
4. ✅ API simulation returns activity card format data
5. ✅ Test data matches activity_card_format.md structure
6. ✅ Games populate from activity data (not vocabulary manager)
7. ✅ All existing game mechanics preserved
8. ✅ Code is maintainable and well-structured

## Open Questions / Decisions Needed

1. **Memory Game Mapping**: Memory game requires 8 word pairs. How should this map to activity types?
   - Option A: Skip memory game in new flow
   - Option B: Create special activity type for memory game
   - Option C: Generate 8 activities and combine into memory game

2. **Unmapped Activity Types**: `spell_typed`, `definition_typed`, `paraphrase_typed_gen` don't have existing games
   - Option A: Create placeholder games
   - Option B: Map to closest existing game
   - Option C: Create minimal implementations

3. **Session Management**: How to handle session ID?
   - Option A: Generate mock UUID on start
   - Option B: Use fixed test session ID
   - Option C: Allow configuration

4. **Test Data Selection**: Which selection strategy?
   - Option A: Round-robin (sequential)
   - Option B: Random
   - Option C: Configurable

5. **Completion Screen**: When does session end?
   - Option A: After N activities (configurable)
   - Option B: When test data runs out
   - Option C: Infinite loop (cycle through test data)

## Implementation Notes

- Use Godot 4.x syntax (typed arrays, modern GDScript)
- Maintain existing code style and conventions
- Add comments for API simulation sections
- Keep error handling robust
- Preserve all existing animations and UI

## Dependencies

- No external dependencies required
- Uses existing Godot built-in functionality
- Test data can be generated from existing vocabulary.json

