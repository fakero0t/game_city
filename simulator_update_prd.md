# API Simulator Update - PRD

## Overview

This document outlines the plan to update the `APISimulator.gd` test data generator to match the new activity card format as defined in `activity_card_format.md`. The updated simulator will generate test data for all 9 activity types with proper structure, including media arrays and activity-specific parameter formats.

## Current State Analysis

### Existing Implementation (`scripts/APISimulator.gd`)

**Current Activity Types (5):**
- `connect_def` - Word Matching game
- `context_cloze` - Fill in Blank game  
- `select_usage` - Multiple Choice with sentences
- `synonym_mcq` - Synonym/Antonym game
- `flashcard_usage` - Memory/Flashcard game

**Current Data Structure:**
```gdscript
{
  "itemId": string,
  "activityType": string,
  "phase": string,
  "phaseProgress": { "current": int, "total": int },
  "word": {
    "wordId": string,
    "headword": string,
    "definition": string,
    "pos": string,
    "media": []  // Empty array
  },
  "params": { /* varies by activity */ }
}
```

**Test Data Generation:**
- 3 entries per activity type (15 total)
- Round-robin cycling through test data
- Auto-generates options from vocabulary pool
- Simulates 300ms network delay

## Required Changes

### 1. Update Base Data Structure

**Media Array Implementation:**
Add realistic media entries to word objects:
- `word_pronunciation` audio (synthesized URL)
- `illustration` image (placeholder URL)
- `sentence_audio` for example sentences (optional)

**Structure:**
```gdscript
"media": [
  {
    "mediaId": "media-[UUID]",
    "kind": "audio",
    "url": "https://test-cdn.example.com/audio/[word]-pronunciation.mp3",
    "mimeType": "audio/mpeg",
    "role": "word_pronunciation",
    "orderNo": 0
  },
  {
    "mediaId": "media-[UUID]",
    "kind": "image", 
    "url": "https://test-cdn.example.com/images/[word]-illustration.png",
    "mimeType": "image/png",
    "role": "illustration",
    "orderNo": 1
  }
]
```

### 2. Update Existing Activity Types

#### 2.1 `flashcard_usage`
**Changes Required:**
- Update `options` structure to use `exampleId` + `text` objects (currently supported)
- Generate UUID-like `exampleId` values (e.g., "ex-[UUID]")
- Ensure exactly 4 options (1 correct + 3 incorrect)

**Current vs New:**
```gdscript
# Current - ALREADY CORRECT ✓
"options": [
  {"exampleId": "ex-correct", "text": "sentence..."},
  {"exampleId": "ex-wrong-1", "text": "sentence..."}
]
```

#### 2.2 `connect_def`
**Changes Required:**
- Update `options` to be array of strings (currently supported)
- No structural changes needed

**Current vs New:**
```gdscript
# Current - ALREADY CORRECT ✓
"options": ["abundant", "cautious", "curious", "delicate"]
```

#### 2.3 `context_cloze`
**Changes Required:**
- Keep `sentence` field as-is
- Update `options` to be array of strings only (remove object structure)

**Current vs New:**
```gdscript
# Current - INCORRECT
"params": {
  "sentence": "The garden had an ____ supply of vegetables.",
  "options": [/* objects */]
}

# New - CORRECT
"params": {
  "sentence": "The garden had an ____ supply of vegetables.",
  "options": ["abundant", "cautious", "curious", "delicate"]
}
```

#### 2.4 `select_usage`
**Changes Required:**
- Structure already matches (uses `exampleId` + `text` objects)
- No changes needed

**Current vs New:**
```gdscript
# Current - ALREADY CORRECT ✓
"options": [
  {"exampleId": "ex-uuid-1", "text": "sentence..."}
]
```

#### 2.5 `synonym_mcq`
**Changes Required:**
- Update `options` structure to use `headword` only (no `wordId`)
- Keep `targetWord` structure with both `wordId` and `headword`

**Current vs New:**
```gdscript
# Current - INCORRECT
"options": [
  {"wordId": "syn-0", "headword": "plentiful"}
]

# New - CORRECT
"options": [
  {"headword": "plentiful"},
  {"headword": "ample"}
]
```

### 3. Add New Activity Types (4)

#### 3.1 `spell_typed`
**Implementation Details:**
- Hide `headword` field (set to empty string or omit)
- Set `params` to `null`
- Include pronunciation audio in media array
- Generate 2-3 test entries

**Data Structure:**
```gdscript
{
  "itemId": "test-item-016",
  "activityType": "spell_typed",
  "phase": "new",
  "phaseProgress": {"current": 1, "total": 2},
  "word": {
    "wordId": "word-016",
    "headword": "",  // HIDDEN
    "definition": "existing in large quantities; plentiful",
    "pos": "adjective",
    "media": [/* audio required */]
  },
  "params": null
}
```

#### 3.2 `definition_typed`
**Implementation Details:**
- Hide `headword` field
- Set `params` to `null`
- Media array can be empty or include illustration
- Generate 2-3 test entries

**Data Structure:**
```gdscript
{
  "itemId": "test-item-019",
  "activityType": "definition_typed",
  "phase": "review",
  "phaseProgress": {"current": 1, "total": 2},
  "word": {
    "wordId": "word-019",
    "headword": "",  // HIDDEN
    "definition": "careful to avoid potential problems or dangers",
    "pos": "adjective",
    "media": []
  },
  "params": null
}
```

#### 3.3 `sentence_typed_gen`
**Implementation Details:**
- Show `headword` field
- Add `cueWord` param (select random word from vocabulary)
- Optional `cuePos` param (can be same as target word's pos)
- Generate 2-3 test entries

**Data Structure:**
```gdscript
{
  "itemId": "test-item-022",
  "activityType": "sentence_typed_gen",
  "phase": "review",
  "phaseProgress": {"current": 1, "total": 2},
  "word": {
    "wordId": "word-022",
    "headword": "abundant",
    "definition": "existing in large quantities; plentiful",
    "pos": "adjective",
    "media": [/* full media array */]
  },
  "params": {
    "cueWord": "garden",
    "cuePos": "noun"
  }
}
```

**Vocabulary Extension Needed:**
- Consider adding a `cueWords` array to vocabulary.json (or generate from existing words)

#### 3.4 `paraphrase_typed_gen`
**Implementation Details:**
- Hide `headword` field
- Set `params` to `null`
- Definition is primary content
- Generate 2-3 test entries

**Data Structure:**
```gdscript
{
  "itemId": "test-item-025",
  "activityType": "paraphrase_typed_gen",
  "phase": "review",
  "phaseProgress": {"current": 1, "total": 2},
  "word": {
    "wordId": "word-025",
    "headword": "",  // HIDDEN
    "definition": "eager to know or learn something",
    "pos": "adjective",
    "media": []
  },
  "params": null
}
```

### 4. Updated Test Data Generation Strategy

**Total Test Entries:** 27 activities (3 entries for each of 9 types)

**Entry Distribution:**
```
Existing (15):
- flashcard_usage:    indices 0-2   (3 entries) ✓
- connect_def:        indices 3-5   (3 entries) ✓  
- context_cloze:      indices 6-8   (3 entries) - needs fix
- select_usage:       indices 9-11  (3 entries) ✓
- synonym_mcq:        indices 12-14 (3 entries) - needs fix

New (12):
- spell_typed:             indices 15-17 (3 entries)
- definition_typed:        indices 18-20 (3 entries)
- sentence_typed_gen:      indices 21-23 (3 entries)
- paraphrase_typed_gen:    indices 24-26 (3 entries)
```

**Word Selection Strategy:**
Use different words for each activity to maximize vocabulary coverage:
- flashcard_usage: words 0-2
- connect_def: words 3-5
- context_cloze: words 6-8
- select_usage: words 9-11
- synonym_mcq: words 12-14
- spell_typed: words 15-17
- definition_typed: words 18-20
- sentence_typed_gen: words 21-23
- paraphrase_typed_gen: words 24-26

Total words needed: 27 (vocabulary.json has 46, so sufficient)

### 5. Helper Function Implementations (Complete Code)

#### 5.1 New Helper: `_generate_media_array()`

**Purpose:** Generate realistic test media objects for word pronunciation and illustration.

**Complete Implementation:**
```gdscript
## Generate media array with audio and image URLs
func _generate_media_array(word: String, word_id: String, include_audio: bool = true) -> Array:
	var media = []
	
	# Add pronunciation audio if requested
	if include_audio:
		media.append({
			"mediaId": _generate_uuid_like("media"),
			"kind": "audio",
			"url": "https://test-cdn.example.com/audio/%s-pronunciation.mp3" % word.to_lower(),
			"mimeType": "audio/mpeg",
			"role": "word_pronunciation",
			"orderNo": 0
		})
	
	# Add illustration image
	media.append({
		"mediaId": _generate_uuid_like("media"),
		"kind": "image",
		"url": "https://test-cdn.example.com/images/%s-illustration.png" % word.to_lower(),
		"mimeType": "image/png",
		"role": "illustration",
		"orderNo": 1 if include_audio else 0
	})
	
	return media
```

**Usage Examples:**
```gdscript
# With audio (for spell_typed, sentence_typed_gen, etc.)
var media_with_audio = _generate_media_array("abundant", "word-001", true)

# Without audio (for definition_typed, paraphrase_typed_gen)
var media_without_audio = _generate_media_array("cautious", "word-002", false)

# Can also pass empty array for activities that don't need media
var no_media = []
```

#### 5.2 New Helper: `_generate_uuid_like()`

**Purpose:** Generate UUID-like identifiers for test data (exampleId, mediaId, wordId, etc.).

**Complete Implementation:**
```gdscript
## Generate a UUID-like string with optional prefix
func _generate_uuid_like(prefix: String = "") -> String:
	# Generate random hex characters for UUID format
	var hex_chars = "0123456789abcdef"
	var uuid_parts = []
	
	# UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
	# Part lengths: 8-4-4-4-12
	var part_lengths = [8, 4, 4, 4, 12]
	
	for length in part_lengths:
		var part = ""
		for i in range(length):
			part += hex_chars[randi() % hex_chars.length()]
		uuid_parts.append(part)
	
	var uuid = "-".join(uuid_parts)
	
	if prefix.is_empty():
		return uuid
	else:
		return "%s-%s" % [prefix, uuid]
```

**Usage Examples:**
```gdscript
# Example outputs:
_generate_uuid_like("ex")      # "ex-a3f2b1c4-5678-90ab-cdef-1234567890ab"
_generate_uuid_like("media")   # "media-deadbeef-1234-5678-9abc-def012345678"
_generate_uuid_like("item")    # "item-11223344-5566-7788-99aa-bbccddeeff00"
_generate_uuid_like("")        # "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

#### 5.3 Keep As-Is: `_generate_word_options()`

**Current Implementation (NO CHANGES):**
```gdscript
## Generate word options for connect_def activities (array of strings)
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

**Returns:** Array of 4 strings (headwords)
**Used by:** `connect_def`, `context_cloze`

#### 5.4 Update: `_generate_sentence_options()`

**Purpose:** Generate sentence options with UUID-like exampleIds.

**Updated Implementation:**
```gdscript
## Generate sentence options for select_usage/flashcard_usage (array of {exampleId, text})
func _generate_sentence_options(correct_word_data: Dictionary, all_words: Array) -> Array:
	var options = []
	
	# Add correct sentence (with word filled in)
	var correct_sentence = correct_word_data["example_sentence"].replace("___", correct_word_data["word"])
	options.append({
		"exampleId": _generate_uuid_like("ex"),  # CHANGED: Use UUID-like ID
		"text": correct_sentence
	})
	
	# Add 3 incorrect sentences (wrong words in similar contexts)
	var shuffled = all_words.duplicate()
	shuffled.shuffle()
	
	for word_data in shuffled:
		if word_data["word"] != correct_word_data["word"] and options.size() < 4:
			# Use the wrong word in the correct sentence context
			var wrong_sentence = correct_word_data["example_sentence"].replace("___", word_data["word"])
			options.append({
				"exampleId": _generate_uuid_like("ex"),  # CHANGED: Use UUID-like ID
				"text": wrong_sentence
			})
	
	options.shuffle()
	return options
```

**Changes Made:**
- Line 8: Changed `"ex-correct"` to `_generate_uuid_like("ex")`
- Line 19: Changed `"ex-wrong-%d" % option_num` to `_generate_uuid_like("ex")`
- Removed `option_num` variable (no longer needed)

**Returns:** Array of 4 objects with `{exampleId: string, text: string}`
**Used by:** `select_usage`, `flashcard_usage`

#### 5.5 Update: `_generate_synonym_options()`

**Purpose:** Generate synonym options with only headword field (remove wordId).

**Updated Implementation:**
```gdscript
## Generate synonym options for synonym_mcq (array of {headword})
func _generate_synonym_options(word_data: Dictionary) -> Array:
	var options = []
	var synonyms = word_data["synonyms"]
	
	# Use all 4 synonyms as options
	for i in range(min(4, synonyms.size())):
		options.append({
			"headword": synonyms[i]  # CHANGED: Removed wordId field
		})
	
	options.shuffle()
	return options
```

**Changes Made:**
- Line 7-9: Removed `"wordId": "syn-%d" % i` field
- Kept only `"headword": synonyms[i]`

**Returns:** Array of 4 objects with `{headword: string}`
**Used by:** `synonym_mcq`

#### 5.6 New Helper: `_select_cue_word()`

**Purpose:** Select a random cue word for sentence_typed_gen activities.

**Complete Implementation:**
```gdscript
## Select a cue word for sentence_typed_gen activity
func _select_cue_word(exclude_word: String, vocab_words: Array) -> Dictionary:
	# Filter out the target word
	var available_words = []
	for word_data in vocab_words:
		if word_data["word"] != exclude_word:
			available_words.append(word_data)
	
	# Pick a random word
	if available_words.is_empty():
		# Fallback if somehow no words available
		return {"cueWord": "garden", "cuePos": "noun"}
	
	var selected = available_words[randi() % available_words.size()]
	
	# For simplicity, use common POS tags or default to "noun"
	# Could be extended to track actual POS in vocabulary.json
	var cue_pos = "noun"  # Default assumption for test data
	
	return {
		"cueWord": selected["word"],
		"cuePos": cue_pos
	}
```

**Alternative with Common Words:**
```gdscript
## Select a cue word (alternative: use predefined common words)
func _select_cue_word(exclude_word: String, vocab_words: Array) -> Dictionary:
	# Predefined list of common cue words for test data
	var common_cues = [
		{"word": "garden", "pos": "noun"},
		{"word": "quickly", "pos": "adverb"},
		{"word": "beautiful", "pos": "adjective"},
		{"word": "think", "pos": "verb"},
		{"word": "friend", "pos": "noun"},
		{"word": "always", "pos": "adverb"},
		{"word": "happy", "pos": "adjective"},
		{"word": "walk", "pos": "verb"}
	]
	
	# Pick a random cue word
	var selected = common_cues[randi() % common_cues.size()]
	
	return {
		"cueWord": selected["word"],
		"cuePos": selected["pos"]
	}
```

**Returns:** Dictionary with `{cueWord: string, cuePos: string}`
**Used by:** `sentence_typed_gen`

### 6. Validation Function Implementation (Complete Code)

**Purpose:** Validate activity data structure before returning to ensure correctness.

**Complete Updated Implementation:**
```gdscript
## Validate activity data structure
func validate_activity_data(data: Dictionary) -> bool:
	# Check required top-level fields
	if not data.has("itemId"):
		push_error("APISimulator: Missing itemId")
		return false
	if not data.has("activityType"):
		push_error("APISimulator: Missing activityType")
		return false
	if not data.has("word"):
		push_error("APISimulator: Missing word")
		return false
	if not data.has("params"):
		push_error("APISimulator: Missing params")
		return false
	
	var activity_type = data["activityType"]
	var word = data["word"]
	
	# Validate word structure
	if not word.has("wordId"):
		push_error("APISimulator: Missing word.wordId")
		return false
	if not word.has("definition"):
		push_error("APISimulator: Missing word.definition")
		return false
	if not word.has("pos"):
		push_error("APISimulator: Missing word.pos")
		return false
	if not word.has("media"):
		push_error("APISimulator: Missing word.media")
		return false
	
	# Validate headword visibility rules
	var headword_hidden_types = ["spell_typed", "definition_typed", "paraphrase_typed_gen"]
	var should_hide_headword = headword_hidden_types.has(activity_type)
	
	if not word.has("headword"):
		push_error("APISimulator: Missing word.headword")
		return false
	
	if should_hide_headword and not word["headword"].is_empty():
		push_warning("APISimulator: Headword should be hidden for %s" % activity_type)
		# Not a hard error, just a warning
	
	# Validate media array structure
	if not word["media"] is Array:
		push_error("APISimulator: word.media must be an array")
		return false
	
	# Validate each media object if present
	for media_item in word["media"]:
		if not media_item is Dictionary:
			push_error("APISimulator: Each media item must be a dictionary")
			return false
		if not media_item.has("mediaId"):
			push_error("APISimulator: Media item missing mediaId")
			return false
		if not media_item.has("kind"):
			push_error("APISimulator: Media item missing kind")
			return false
		if not media_item.has("url"):
			push_error("APISimulator: Media item missing url")
			return false
		if not media_item.has("role"):
			push_error("APISimulator: Media item missing role")
			return false
		if not media_item.has("orderNo"):
			push_error("APISimulator: Media item missing orderNo")
			return false
	
	# Validate activity-specific params
	var params = data["params"]
	
	# Activities with null params
	if activity_type in ["spell_typed", "definition_typed", "paraphrase_typed_gen"]:
		if params != null:
			push_warning("APISimulator: %s should have null params" % activity_type)
	
	# Activities with options array
	if activity_type in ["connect_def", "context_cloze"]:
		if not params.has("options"):
			push_error("APISimulator: %s missing params.options" % activity_type)
			return false
		if not params["options"] is Array:
			push_error("APISimulator: %s options must be array" % activity_type)
			return false
	
	# Activities with sentence + options
	if activity_type == "context_cloze":
		if not params.has("sentence"):
			push_error("APISimulator: context_cloze missing params.sentence")
			return false
	
	# Activities with object array options (exampleId + text)
	if activity_type in ["flashcard_usage", "select_usage"]:
		if not params.has("options"):
			push_error("APISimulator: %s missing params.options" % activity_type)
			return false
		for option in params["options"]:
			if not option.has("exampleId") or not option.has("text"):
				push_error("APISimulator: %s option missing exampleId or text" % activity_type)
				return false
	
	# Synonym MCQ validation
	if activity_type == "synonym_mcq":
		if not params.has("targetWord"):
			push_error("APISimulator: synonym_mcq missing params.targetWord")
			return false
		if not params.has("options"):
			push_error("APISimulator: synonym_mcq missing params.options")
			return false
		for option in params["options"]:
			if not option.has("headword"):
				push_error("APISimulator: synonym_mcq option missing headword")
				return false
	
	# Sentence generation validation
	if activity_type == "sentence_typed_gen":
		if not params.has("cueWord"):
			push_error("APISimulator: sentence_typed_gen missing params.cueWord")
			return false
		# cuePos is optional, so don't require it
	
	return true
```

**Key Validation Points:**

1. **Top-level fields**: itemId, activityType, word, params
2. **Word structure**: wordId, headword, definition, pos, media array
3. **Headword visibility**: Empty for spell_typed, definition_typed, paraphrase_typed_gen
4. **Media array**: Each item must have mediaId, kind, url, role, orderNo
5. **Activity-specific params**:
   - `null` for: spell_typed, definition_typed, paraphrase_typed_gen
   - `options` array for: connect_def, context_cloze, flashcard_usage, select_usage, synonym_mcq
   - `sentence` + `options` for: context_cloze
   - `targetWord` + `options` for: synonym_mcq
   - `cueWord` + optional `cuePos` for: sentence_typed_gen

### 7. Complete `_initialize_test_data()` Implementation

**Purpose:** Generate all 27 test activity entries (3 per activity type) on startup.

**Complete Implementation Code:**

```gdscript
## Initialize test data from vocabulary
func _initialize_test_data() -> void:
	# Get vocabulary words from VocabularyManager
	var vocab_words = VocabularyManager.get_all_words()
	if vocab_words.is_empty():
		push_error("APISimulator: No vocabulary data available")
		return
	
	var item_counter = 1
	
	# Ensure we have enough words (need 27 for 3 entries × 9 types)
	if vocab_words.size() < 27:
		push_warning("APISimulator: Limited vocabulary data, some words will repeat")
	
	# ========== ACTIVITY TYPE 1: flashcard_usage (indices 0-2) ==========
	for i in range(3):
		var word = vocab_words[i % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "flashcard_usage",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"options": _generate_sentence_options(word, vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 2: connect_def (indices 3-5) ==========
	for i in range(3):
		var word = vocab_words[(i + 3) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "connect_def",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"options": _generate_word_options(word["word"], vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 3: context_cloze (indices 6-8) ==========
	for i in range(3):
		var word = vocab_words[(i + 6) % vocab_words.size()]
		var sentence = word["example_sentence"]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "context_cloze",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"sentence": sentence,
				"options": _generate_word_options(word["word"], vocab_words)  # CHANGED: String array
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 4: select_usage (indices 9-11) ==========
	for i in range(3):
		var word = vocab_words[(i + 9) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "select_usage",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"options": _generate_sentence_options(word, vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 5: synonym_mcq (indices 12-14) ==========
	for i in range(3):
		var word = vocab_words[(i + 12) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "synonym_mcq",
			"phase": "review",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"targetWord": {
					"wordId": _generate_uuid_like("word"),
					"headword": word["synonyms"][0]
				},
				"options": _generate_synonym_options(word)  # CHANGED: No wordId in options
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 6: spell_typed (indices 15-17) ==========
	for i in range(3):
		var word = vocab_words[(i + 15) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "spell_typed",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": "",  # HIDDEN
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)  # Audio required
			},
			"params": null
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 7: definition_typed (indices 18-20) ==========
	for i in range(3):
		var word = vocab_words[(i + 18) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "definition_typed",
			"phase": "review",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": "",  # HIDDEN
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, false)  # No audio
			},
			"params": null
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 8: sentence_typed_gen (indices 21-23) ==========
	for i in range(3):
		var word = vocab_words[(i + 21) % vocab_words.size()]
		var cue = _select_cue_word(word["word"], vocab_words)
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "sentence_typed_gen",
			"phase": "review",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": word["word"],  # VISIBLE
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
			},
			"params": {
				"cueWord": cue["cueWord"],
				"cuePos": cue["cuePos"]
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# ========== ACTIVITY TYPE 9: paraphrase_typed_gen (indices 24-26) ==========
	for i in range(3):
		var word = vocab_words[(i + 24) % vocab_words.size()]
		var entry = {
			"itemId": _generate_uuid_like("item"),
			"activityType": "paraphrase_typed_gen",
			"phase": "review",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": _generate_uuid_like("word"),
				"headword": "",  # HIDDEN
				"definition": word["definition"],
				"pos": "adjective",
				"media": _generate_media_array(word["word"], "word-%03d" % item_counter, false)  # No audio
			},
			"params": null
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	print("APISimulator: Initialized with ", test_data_entries.size(), " test entries (9 activity types × 3 each)")
```

**Key Changes from Current Implementation:**

1. **All activities now generate media arrays** via `_generate_media_array()`
2. **UUID-like IDs** for itemId and wordId using `_generate_uuid_like()`
3. **context_cloze fixed** to use string array for options (not objects)
4. **synonym_mcq fixed** to remove wordId from options
5. **4 new activity types added**: spell_typed, definition_typed, sentence_typed_gen, paraphrase_typed_gen
6. **Headword visibility** correctly implemented (empty string for hidden)
7. **Total entries** increased from 15 to 27

**Activity Type Summary:**

| Index   | Activity Type          | Phase  | Headword | Params Type           | Media |
|---------|------------------------|--------|----------|-----------------------|-------|
| 0-2     | flashcard_usage        | new    | Visible  | {options: [{},{}]}    | Audio+Image |
| 3-5     | connect_def            | new    | Visible  | {options: [str,str]}  | Audio+Image |
| 6-8     | context_cloze          | new    | Visible  | {sentence, options}   | Audio+Image |
| 9-11    | select_usage           | new    | Visible  | {options: [{},{}]}    | Audio+Image |
| 12-14   | synonym_mcq            | review | Visible  | {targetWord, options} | Audio+Image |
| 15-17   | spell_typed            | new    | Hidden   | null                  | Audio+Image |
| 18-20   | definition_typed       | review | Hidden   | null                  | Image only |
| 21-23   | sentence_typed_gen     | review | Visible  | {cueWord, cuePos}     | Audio+Image |
| 24-26   | paraphrase_typed_gen   | review | Hidden   | null                  | Image only |

### 8. Implementation Steps (Detailed Procedure)

**Phase 1: Add New Helper Functions**

1. **Add `_generate_uuid_like()` function**
   - Insert after line 8 (api_delay_ms declaration)
   - Copy complete implementation from Section 5.2
   - Test by calling: `print(_generate_uuid_like("test"))` should output UUID-like string

2. **Add `_generate_media_array()` function**
   - Insert after `_generate_uuid_like()`
   - Copy complete implementation from Section 5.1
   - Test by calling with sample word

3. **Add `_select_cue_word()` function**
   - Insert after `_generate_media_array()`
   - Use either implementation from Section 5.6 (vocabulary-based or predefined)
   - Recommend predefined list for consistency in testing

**Phase 2: Update Existing Helper Functions**

4. **Update `_generate_sentence_options()` function**
   - Replace lines 236-238 (ex-correct) with UUID generation
   - Replace lines 250-252 (ex-wrong) with UUID generation
   - Remove option_num variable (line 245)
   - See Section 5.4 for complete updated code

5. **Update `_generate_synonym_options()` function**
   - Remove line 267 (`"wordId": "syn-%d" % i`)
   - Keep only `"headword": synonyms[i]`
   - See Section 5.5 for complete updated code

**Phase 3: Rewrite `_initialize_test_data()` Function**

6. **Replace entire `_initialize_test_data()` function** (lines 82-213)
   - Use complete implementation from Section 7
   - Update warning message threshold from 20 to 27
   - Change order: flashcard_usage first (currently starts with connect_def)
   - Update final print statement to show 27 entries and 9 types

**Phase 4: Update Validation Function**

7. **Replace entire `validate_activity_data()` function** (lines 48-75)
   - Use complete implementation from Section 6
   - Add media array validation
   - Add headword visibility check
   - Add activity-specific param validation

**Phase 5: Testing & Verification**

8. **Run game and verify initialization**
   - Check console output: "APISimulator: Initialized with 27 test entries"
   - No errors during startup

9. **Test each activity type**
   - Click through first 27 activities (full cycle)
   - Verify correct structure for each type
   - Check media URLs are generated
   - Confirm headword visibility rules

10. **Test round-robin cycling**
   - Continue past 27 activities
   - Verify it cycles back to activity 0
   - Confirm data structure remains valid

**Phase 6: Edge Case Testing**

11. **Test with limited vocabulary**
   - Temporarily reduce vocabulary.json to 10 words
   - Verify warning appears but simulator still works
   - Restore full vocabulary

12. **Validate all 9 activity types load correctly**
   - Check each type can be processed by game scripts
   - Verify no crashes or missing data errors

### 9. No Changes Required

**The following will NOT be modified:**
- `request_next_activity()` - Round-robin logic stays the same
- `add_test_data()` - Manual test data addition still supported
- `clear_test_data()` - Clearing logic unchanged
- `is_test_data_exhausted()` - Always returns false (infinite cycling)
- Network delay simulation (300ms)
- VocabularyManager integration

### 9. Vocabulary.json Considerations

**Current Requirements Met:**
- 46 words available (need 27 for test data)
- Each word has: word, definition, synonyms[4], antonyms[4], example_sentence, difficulty
- Example sentences have `___` placeholder

**No Changes Needed:**
- Existing vocabulary.json structure is sufficient
- Can use any word as `cueWord` for sentence_typed_gen
- No additional fields required

### 10. Expected Output

**After Implementation:**
- 27 test activity entries generated on startup
- All 9 activity types represented (3 entries each)
- Proper data structure matching activity_card_format.md
- Media arrays populated with test URLs
- Headword visibility rules enforced
- Activity-specific param formats correct
- Round-robin cycling through all activities
- Existing validation and error handling maintained

### 11. Files Modified

**Primary File:**
- `/Users/ary/Desktop/game_city/scripts/APISimulator.gd` - Complete rewrite of test data generation logic

**No Other Files Modified:**
- VocabularyManager.gd - No changes
- vocabulary.json - No changes  
- GameManager.gd - No changes
- Individual game scripts - No changes (they will receive properly formatted data)

## Success Criteria

1. APISimulator generates 27 valid activity entries on startup
2. All entries match the structure defined in activity_card_format.md
3. Media arrays contain realistic test URLs
4. Headword visibility rules correctly implemented
5. Activity-specific params match required formats
6. Round-robin cycling works through all 27 activities
7. No errors during validation
8. Existing game scripts can consume the new data format

---

## Quick Reference

### Function Summary

| Function Name | Purpose | Returns | Status |
|---------------|---------|---------|--------|
| `_generate_uuid_like(prefix)` | Generate UUID-like IDs | String | NEW |
| `_generate_media_array(word, id, audio)` | Create media objects | Array | NEW |
| `_select_cue_word(exclude, words)` | Select cue for sentence gen | Dictionary | NEW |
| `_generate_word_options(word, words)` | String array options | Array | NO CHANGE |
| `_generate_sentence_options(word, words)` | Sentence object options | Array | UPDATED |
| `_generate_synonym_options(word)` | Synonym options | Array | UPDATED |
| `_initialize_test_data()` | Generate all test data | void | REWRITTEN |
| `validate_activity_data(data)` | Validate structure | bool | UPDATED |

### Activity Type Quick Reference

```
Activity Type             | Index  | Headword | Params           | Notes
--------------------------|--------|----------|------------------|------------------------
flashcard_usage           | 0-2    | Visible  | options[{id,txt}]| First exposure to word
connect_def               | 3-5    | Visible  | options[str]     | Match word to definition
context_cloze             | 6-8    | Visible  | sentence+options | Fill in blank
select_usage              | 9-11   | Visible  | options[{id,txt}]| Select correct usage
synonym_mcq               | 12-14  | Visible  | target+options   | Find synonym
spell_typed               | 15-17  | Hidden   | null             | Type word from audio
definition_typed          | 18-20  | Hidden   | null             | Type word from definition
sentence_typed_gen        | 21-23  | Visible  | cueWord+cuePos   | Generate sentence
paraphrase_typed_gen      | 24-26  | Hidden   | null             | Paraphrase definition
```

### Data Structure Checklist

**Every Activity Must Have:**
- ✅ itemId (UUID-like string)
- ✅ activityType (string from 9 types)
- ✅ phase ("new" or "review")
- ✅ phaseProgress ({current, total})
- ✅ word object with:
  - wordId (UUID-like string)
  - headword (string, empty if hidden)
  - definition (string)
  - pos (string, e.g., "adjective")
  - media (array of media objects)
- ✅ params (object or null, activity-specific)

**Media Object Structure:**
- mediaId (UUID-like string)
- kind ("audio" or "image")
- url (string URL)
- mimeType (optional string, e.g., "audio/mpeg")
- role (one of: word_pronunciation, alt_pronunciation, sentence_audio, illustration)
- orderNo (number, 0-indexed)

### Param Formats by Activity

```gdscript
// Activities with null params
spell_typed, definition_typed, paraphrase_typed_gen:
  params: null

// Activities with string array options
connect_def, context_cloze:
  params: {
    options: ["word1", "word2", "word3", "word4"],
    sentence: "..." // context_cloze only
  }

// Activities with object array options
flashcard_usage, select_usage:
  params: {
    options: [
      {exampleId: "uuid", text: "sentence..."},
      ...
    ]
  }

// Synonym MCQ
synonym_mcq:
  params: {
    targetWord: {wordId: "uuid", headword: "synonym"},
    options: [
      {headword: "word1"},
      {headword: "word2"},
      ...
    ]
  }

// Sentence generation
sentence_typed_gen:
  params: {
    cueWord: "word",
    cuePos: "noun" // optional
  }
```

### Common Pitfalls to Avoid

1. **Don't forget to hide headword** for spell_typed, definition_typed, paraphrase_typed_gen
2. **Use UUID-like IDs** for all itemId, wordId, exampleId, mediaId
3. **context_cloze uses string array** for options (not object array)
4. **synonym_mcq options have no wordId** (only headword)
5. **Media arrays are required** even if empty
6. **orderNo in media** should reflect actual order (0-indexed)
7. **Phase progress** should match loop index (current: i+1, total: 3)
8. **Sentence generation** needs cueWord selected (not same as target word)

### Testing Checklist

**During Development:**
- [ ] All 3 new helper functions compile without errors
- [ ] Updated helper functions maintain backward compatibility
- [ ] _initialize_test_data() generates exactly 27 entries
- [ ] Console shows: "Initialized with 27 test entries (9 activity types × 3 each)"
- [ ] No errors or warnings during initialization

**Functional Testing:**
- [ ] Round-robin cycles through all 27 activities in order
- [ ] Activity 28 returns to activity 1 (index 0)
- [ ] Each activity type appears 3 times in first 27
- [ ] Media URLs are properly formatted
- [ ] Headword correctly hidden for spell/definition/paraphrase types
- [ ] All UUIDs are unique and well-formed

**Validation Testing:**
- [ ] validate_activity_data() passes for all 27 entries
- [ ] No validation errors during runtime
- [ ] Media array validation works correctly
- [ ] Param validation catches malformed data

**Integration Testing:**
- [ ] Existing game scripts can load new data format
- [ ] No crashes when displaying activities
- [ ] Games correctly handle hidden headwords
- [ ] Media URLs don't cause errors (even though they're test URLs)

### Estimated Implementation Time

- Phase 1 (New Helpers): 30 minutes
- Phase 2 (Update Helpers): 15 minutes
- Phase 3 (Rewrite Init): 45 minutes
- Phase 4 (Update Validation): 30 minutes
- Phase 5 (Testing): 45 minutes
- Phase 6 (Edge Cases): 30 minutes

**Total: ~3 hours** for complete implementation and testing

### File Backup Recommendation

**Before starting implementation:**
```bash
cp scripts/APISimulator.gd scripts/APISimulator.gd.backup
```

**To restore if needed:**
```bash
cp scripts/APISimulator.gd.backup scripts/APISimulator.gd
```

### Post-Implementation Verification

Run these checks after implementation:

1. **Start game** → Check console for initialization message
2. **Play 30 activities** → Verify cycling and variety
3. **Check data structure** → Print first activity of each type
4. **Test edge cases** → Reduce vocabulary, test with invalid data
5. **Integration test** → Ensure all game scripts work with new format

### Notes

- **UUID generation is pseudo-random** - good enough for test data
- **Media URLs are fake** - they won't load actual files, just for structure
- **POS is hardcoded to "adjective"** - could be made dynamic if needed
- **Phase distribution** - first 5 types are "new", last 4 are "review"
- **Vocabulary requirement** - 27 unique words minimum (have 46 available)
- **Backward compatibility** - No changes to external API, only internal data generation

### Related Documentation

- **Activity Card Format**: `/Users/ary/Desktop/game_city/activity_card_format.md`
- **Current Implementation**: `/Users/ary/Desktop/game_city/scripts/APISimulator.gd`
- **Vocabulary Data**: `/Users/ary/Desktop/game_city/assets/vocabulary.json`
- **This PRD**: `/Users/ary/Desktop/game_city/simulator_update_prd.md`

