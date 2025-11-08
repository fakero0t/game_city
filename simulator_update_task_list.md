# API Simulator Update - Task List

## Overview

This task list breaks down the implementation of the API Simulator update (as defined in `simulator_update_prd.md`) into sequential pull requests. Each PR builds on the previous one and can be tested independently.

**Goal**: Update `scripts/APISimulator.gd` to generate test data matching the new activity card format with all 9 activity types.

**Total PRs**: 3
**Estimated Time**: 3 hours total
**Files Modified**: `scripts/APISimulator.gd` (only file)

---

## Pull Request 1: Add Helper Functions and Update Existing Activities

**Branch Name**: `feature/simulator-helper-functions`

**Description**: Add new helper functions for UUID generation and media arrays. Update existing helper functions to use UUIDs. Fix existing activity types (context_cloze, synonym_mcq) to match new format.

**Estimated Time**: 1 hour

**No New Activity Types**: This PR only fixes existing 5 activity types.

### Task 1.1: Backup Current Implementation

**File**: `scripts/APISimulator.gd`

**Action**: Create backup before starting
```bash
cp scripts/APISimulator.gd scripts/APISimulator.gd.backup
```

**Verification**: Backup file exists in scripts directory

---

### Task 1.2: Add `_generate_uuid_like()` Helper Function

**File**: `scripts/APISimulator.gd`
**Location**: Insert after line 8 (after `api_delay_ms` declaration)

**Implementation**:
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

**Testing**:
- Call `print(_generate_uuid_like("test"))` in _ready()
- Verify output format: "test-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
- Remove test print statement

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Returns proper UUID format with hyphens
- [ ] Prefix parameter works correctly
- [ ] Empty prefix returns UUID without prefix

---

### Task 1.3: Add `_generate_media_array()` Helper Function

**File**: `scripts/APISimulator.gd`
**Location**: Insert after `_generate_uuid_like()` function

**Implementation**:
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

**Testing**:
- Call `print(_generate_media_array("test", "word-001", true))` 
- Verify returns array with 2 items (audio + image)
- Call `print(_generate_media_array("test", "word-001", false))`
- Verify returns array with 1 item (image only)
- Remove test print statements

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Returns array with correct structure
- [ ] Media objects have all required fields
- [ ] Audio included when include_audio is true
- [ ] Audio excluded when include_audio is false
- [ ] orderNo correctly set based on audio presence

---

### Task 1.4: Update `_generate_sentence_options()` Function

**File**: `scripts/APISimulator.gd`
**Location**: Replace existing function (lines ~230-257)

**Current Code** (to be replaced):
```gdscript
## Generate sentence options for select_usage/flashcard_usage (array of {exampleId, text})
func _generate_sentence_options(correct_word_data: Dictionary, all_words: Array) -> Array:
	var options = []
	
	# Add correct sentence (with word filled in)
	var correct_sentence = correct_word_data["example_sentence"].replace("___", correct_word_data["word"])
	options.append({
		"exampleId": "ex-correct",
		"text": correct_sentence
	})
	
	# Add 3 incorrect sentences (wrong words in similar contexts)
	var shuffled = all_words.duplicate()
	shuffled.shuffle()
	
	var option_num = 1
	for word_data in shuffled:
		if word_data["word"] != correct_word_data["word"] and options.size() < 4:
			# Use the wrong word in the correct sentence context
			var wrong_sentence = correct_word_data["example_sentence"].replace("___", word_data["word"])
			options.append({
				"exampleId": "ex-wrong-%d" % option_num,
				"text": wrong_sentence
			})
			option_num += 1
	
	options.shuffle()
	return options
```

**New Code**:
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

**Changes Made**:
- Line 8: Changed `"exampleId": "ex-correct"` to `"exampleId": _generate_uuid_like("ex")`
- Line 19: Changed `"exampleId": "ex-wrong-%d" % option_num` to `"exampleId": _generate_uuid_like("ex")`
- Removed `option_num` variable (line 15 and 23)

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Returns array of 4 objects
- [ ] Each object has exampleId (UUID format) and text
- [ ] exampleIds are unique
- [ ] Still returns 1 correct + 3 incorrect sentences

---

### Task 1.5: Update `_generate_synonym_options()` Function

**File**: `scripts/APISimulator.gd`
**Location**: Replace existing function (lines ~259-272)

**Current Code** (to be replaced):
```gdscript
## Generate synonym options for synonym_mcq (array of {wordId, headword})
func _generate_synonym_options(word_data: Dictionary) -> Array:
	var options = []
	var synonyms = word_data["synonyms"]
	
	# Use all 4 synonyms as options
	for i in range(min(4, synonyms.size())):
		options.append({
			"wordId": "syn-%d" % i,
			"headword": synonyms[i]
		})
	
	options.shuffle()
	return options
```

**New Code**:
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

**Changes Made**:
- Line 1: Updated comment to remove "wordId" mention
- Lines 8-9: Removed `"wordId": "syn-%d" % i,` line
- Kept only `"headword": synonyms[i]`

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Returns array of 4 objects
- [ ] Each object has only headword field (no wordId)
- [ ] All 4 synonyms included

---

### Task 1.6: Update Existing Activities in `_initialize_test_data()`

**File**: `scripts/APISimulator.gd`
**Location**: Update lines 82-213 (partial rewrite, 5 activity types only)

**Important**: This task only updates the 5 existing activity types. Do NOT add new activity types yet.

**Changes to Apply**:

1. **Update flashcard_usage (indices 0-2)**:
   - Change `"itemId"` from `"test-item-%03d"` to `_generate_uuid_like("item")`
   - Change `"wordId"` from `"word-%03d"` to `_generate_uuid_like("word")`
   - Change `"media": []` to `"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)`

2. **Update connect_def (indices 3-5)**:
   - Same changes as flashcard_usage above
   - No changes to params (already correct)

3. **Update context_cloze (indices 6-8)**:
   - Same UUID and media changes
   - **FIX params**: Change `"options": _generate_word_options(...)` 
   - Previously was calling wrong function, should be string array

4. **Update select_usage (indices 9-11)**:
   - Same UUID and media changes
   - No changes to params (already uses _generate_sentence_options)

5. **Update synonym_mcq (indices 12-14)**:
   - Same UUID and media changes
   - Update targetWord wordId to use `_generate_uuid_like("word")`
   - params.options already updated by Task 1.5

**Updated Code for _initialize_test_data()** (5 activity types only):

```gdscript
## Initialize test data from vocabulary
func _initialize_test_data() -> void:
	# Get vocabulary words from VocabularyManager
	var vocab_words = VocabularyManager.get_all_words()
	if vocab_words.is_empty():
		push_error("APISimulator: No vocabulary data available")
		return
	
	var item_counter = 1
	
	# Ensure we have enough words (need at least 15 for 3 entries × 5 types)
	if vocab_words.size() < 15:
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
				"options": _generate_word_options(word["word"], vocab_words)  # FIXED: String array
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
				"options": _generate_synonym_options(word)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	print("APISimulator: Initialized with ", test_data_entries.size(), " test entries")
```

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Still generates 15 entries (3 per type × 5 types)
- [ ] All itemIds are UUID format
- [ ] All wordIds are UUID format
- [ ] All entries have media arrays (2 items each)
- [ ] context_cloze now uses string array for options
- [ ] synonym_mcq options have no wordId field

---

### Task 1.7: Test PR1 Changes

**Testing Steps**:

1. **Compile and Run Game**
   - No compilation errors
   - Game starts successfully

2. **Check Console Output**
   - Should show: "APISimulator: Initialized with 15 test entries"
   - No errors or warnings during initialization

3. **Verify Data Structure**
   - Add temporary debug code in `_initialize_test_data()` after line 212:
   ```gdscript
   # Debug: Print first entry of each type
   print("=== DEBUG: First entry of each type ===")
   for i in [0, 3, 6, 9, 12]:
       var entry = test_data_entries[i]
       print("Type: ", entry["activityType"])
       print("  ItemId format: ", entry["itemId"])
       print("  WordId format: ", entry["word"]["wordId"])
       print("  Media count: ", entry["word"]["media"].size())
       print("  Media[0] has mediaId: ", entry["word"]["media"][0].has("mediaId"))
   ```
   - Remove debug code after verification

4. **Play Through Activities**
   - Click through first 15 activities
   - Verify no crashes
   - Check that activities cycle back to first after 15

5. **Validate Media Arrays**
   - Check that each entry has media array with 2 items
   - Verify audio URL format: "https://test-cdn.example.com/audio/[word]-pronunciation.mp3"
   - Verify image URL format: "https://test-cdn.example.com/images/[word]-illustration.png"

**Expected Results**:
- ✅ 15 test entries generated
- ✅ All UUIDs are properly formatted
- ✅ All media arrays populated
- ✅ context_cloze fixed (string array options)
- ✅ synonym_mcq fixed (no wordId in options)
- ✅ Round-robin cycling works
- ✅ No errors or crashes

**PR1 Completion Checklist**:
- [ ] All 7 tasks completed
- [ ] All tests pass
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] Game plays through 15+ activities successfully
- [ ] Ready for code review

---

## Pull Request 2: Add New Activity Types

**Branch Name**: `feature/simulator-new-activity-types`

**Base Branch**: `feature/simulator-helper-functions` (PR1)

**Description**: Add 4 new activity types (spell_typed, definition_typed, sentence_typed_gen, paraphrase_typed_gen) to test data generation. Increase total test entries from 15 to 27.

**Estimated Time**: 1 hour

**Adds**: 4 new activity types (12 new test entries)

### Task 2.1: Add `_select_cue_word()` Helper Function

**File**: `scripts/APISimulator.gd`
**Location**: Insert after `_generate_media_array()` function

**Implementation** (Using predefined common words approach):
```gdscript
## Select a cue word for sentence_typed_gen activity
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

**Alternative Implementation** (Using vocabulary words):
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

**Choose One**: Recommend predefined approach for consistency.

**Testing**:
- Call `print(_select_cue_word("test", vocab_words))` 
- Verify returns dictionary with cueWord and cuePos
- Remove test print statement

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Returns dictionary with cueWord and cuePos keys
- [ ] cueWord is never the excluded word
- [ ] cuePos is a valid part of speech

---

### Task 2.2: Add spell_typed Activity Type

**File**: `scripts/APISimulator.gd`
**Location**: In `_initialize_test_data()`, add after synonym_mcq block (after item_counter reaches 15)

**Code to Add**:
```gdscript
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
```

**Key Points**:
- **Headword**: Empty string (hidden)
- **Params**: null
- **Media**: Include audio (true parameter)
- **Phase**: "new"
- **Indices**: 15-17

**Verification Checklist**:
- [ ] Headword is empty string
- [ ] params is null (not object, not missing)
- [ ] Media array includes audio
- [ ] Item counter increments correctly

---

### Task 2.3: Add definition_typed Activity Type

**File**: `scripts/APISimulator.gd`
**Location**: In `_initialize_test_data()`, add after spell_typed block

**Code to Add**:
```gdscript
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
```

**Key Points**:
- **Headword**: Empty string (hidden)
- **Params**: null
- **Media**: No audio (false parameter)
- **Phase**: "review"
- **Indices**: 18-20

**Verification Checklist**:
- [ ] Headword is empty string
- [ ] params is null
- [ ] Media array excludes audio (only image)
- [ ] Phase is "review"

---

### Task 2.4: Add sentence_typed_gen Activity Type

**File**: `scripts/APISimulator.gd`
**Location**: In `_initialize_test_data()`, add after definition_typed block

**Code to Add**:
```gdscript
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
```

**Key Points**:
- **Headword**: Visible (actual word)
- **Params**: Object with cueWord and cuePos
- **Media**: Include audio
- **Phase**: "review"
- **Indices**: 21-23
- **Special**: Calls `_select_cue_word()` to get cue

**Verification Checklist**:
- [ ] Headword is populated (visible)
- [ ] params has cueWord and cuePos
- [ ] cueWord is different from target word
- [ ] Media array includes audio

---

### Task 2.5: Add paraphrase_typed_gen Activity Type

**File**: `scripts/APISimulator.gd`
**Location**: In `_initialize_test_data()`, add after sentence_typed_gen block

**Code to Add**:
```gdscript
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
```

**Key Points**:
- **Headword**: Empty string (hidden)
- **Params**: null
- **Media**: No audio (false parameter)
- **Phase**: "review"
- **Indices**: 24-26

**Verification Checklist**:
- [ ] Headword is empty string
- [ ] params is null
- [ ] Media array excludes audio
- [ ] Phase is "review"
- [ ] This is the last activity type added

---

### Task 2.6: Update Initialization Warning and Print Statement

**File**: `scripts/APISimulator.gd`
**Location**: In `_initialize_test_data()` function

**Changes**:

1. **Update warning threshold** (around line 92):
```gdscript
# OLD:
if vocab_words.size() < 15:
	push_warning("APISimulator: Limited vocabulary data, some words will repeat")

# NEW:
if vocab_words.size() < 27:
	push_warning("APISimulator: Limited vocabulary data, some words will repeat")
```

2. **Update final print statement** (last line of function):
```gdscript
# OLD:
print("APISimulator: Initialized with ", test_data_entries.size(), " test entries")

# NEW:
print("APISimulator: Initialized with ", test_data_entries.size(), " test entries (9 activity types × 3 each)")
```

**Verification Checklist**:
- [ ] Warning threshold is 27
- [ ] Print statement mentions 9 activity types

---

### Task 2.7: Test PR2 Changes

**Testing Steps**:

1. **Compile and Run Game**
   - No compilation errors
   - Game starts successfully

2. **Check Console Output**
   - Should show: "APISimulator: Initialized with 27 test entries (9 activity types × 3 each)"
   - No errors or warnings during initialization

3. **Verify All Activity Types Present**
   - Add temporary debug code:
   ```gdscript
   # Debug: Print all activity types
   print("=== DEBUG: All activity types ===")
   var type_counts = {}
   for entry in test_data_entries:
       var type = entry["activityType"]
       if not type_counts.has(type):
           type_counts[type] = 0
       type_counts[type] += 1
   for type in type_counts:
       print("  ", type, ": ", type_counts[type], " entries")
   ```
   - Should show 9 types, each with 3 entries
   - Remove debug code after verification

4. **Verify New Activity Types Structure**
   - Add temporary debug code:
   ```gdscript
   # Debug: Check new activity types
   print("=== DEBUG: New activity types ===")
   for i in [15, 18, 21, 24]:  # First of each new type
       var entry = test_data_entries[i]
       print("Type: ", entry["activityType"])
       print("  Headword empty: ", entry["word"]["headword"].is_empty())
       print("  Params is null: ", entry["params"] == null)
       print("  Has cueWord: ", entry["params"] != null and entry["params"].has("cueWord"))
   ```
   - Remove debug code after verification

5. **Play Through All Activities**
   - Click through first 30 activities (full cycle + 3 more)
   - Verify activities 28-30 are same as 1-3 (cycling works)
   - Check no crashes on any activity type

6. **Verify Headword Visibility Rules**
   - Headword should be empty for: spell_typed, definition_typed, paraphrase_typed_gen
   - Headword should be populated for: all other types

**Expected Results**:
- ✅ 27 test entries generated
- ✅ 9 activity types present
- ✅ Each type has 3 entries
- ✅ New types have correct structure
- ✅ Headword visibility rules correct
- ✅ Params match expected format for each type
- ✅ Round-robin cycling works through all 27

**PR2 Completion Checklist**:
- [ ] All 7 tasks completed
- [ ] All tests pass
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] Game cycles through all 27 activities
- [ ] All 9 activity types working
- [ ] Ready for code review

---

## Pull Request 3: Update Validation Function

**Branch Name**: `feature/simulator-validation-update`

**Base Branch**: `feature/simulator-new-activity-types` (PR2)

**Description**: Update `validate_activity_data()` function to properly validate new data structure including media arrays, headword visibility rules, and activity-specific parameter formats.

**Estimated Time**: 1 hour

**Updates**: 1 function (validate_activity_data)

### Task 3.1: Replace `validate_activity_data()` Function

**File**: `scripts/APISimulator.gd`
**Location**: Replace existing function (lines ~48-75)

**Current Code** (to be replaced):
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
	
	# Validate word structure
	var word = data["word"]
	if not word.has("wordId"):
		push_error("APISimulator: Missing word.wordId")
		return false
	if not word.has("headword"):
		push_error("APISimulator: Missing word.headword")
		return false
	if not word.has("definition"):
		push_error("APISimulator: Missing word.definition")
		return false
	
	return true
```

**New Code** (complete replacement):
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

**Key Changes**:
1. Added validation for word.pos and word.media
2. Added headword visibility rules checking
3. Added comprehensive media array validation (each item's fields)
4. Added activity-specific param validation for all 9 types
5. Added validation for new activity types

**Verification Checklist**:
- [ ] Function compiles without errors
- [ ] Validates all required fields
- [ ] Checks headword visibility rules
- [ ] Validates media array structure
- [ ] Validates activity-specific params for all 9 types

---

### Task 3.2: Test Validation with Valid Data

**Testing Steps**:

1. **Run Game Normally**
   - All 27 activities should pass validation
   - Console shows: "APISimulator: Initialized with 27 test entries (9 activity types × 3 each)"
   - No validation errors

2. **Test Each Activity Type**
   - Play through all 27 activities
   - Each should load without validation errors
   - No crashes or warnings

**Expected Results**:
- ✅ All 27 entries pass validation
- ✅ No validation errors in console
- ✅ Game plays through all activities successfully

---

### Task 3.3: Test Validation with Invalid Data

**Testing Steps** (Add temporary test code, then remove):

1. **Test Missing itemId**:
```gdscript
# In _ready(), before _initialize_test_data()
var test_invalid_1 = {
	"activityType": "connect_def",
	"word": {},
	"params": {}
}
print("Test missing itemId: ", validate_activity_data(test_invalid_1))
# Should print: false
# Should show error: "APISimulator: Missing itemId"
```

2. **Test Missing media**:
```gdscript
var test_invalid_2 = {
	"itemId": "test",
	"activityType": "connect_def",
	"word": {
		"wordId": "w1",
		"headword": "test",
		"definition": "test",
		"pos": "adjective"
		# Missing media
	},
	"params": {}
}
print("Test missing media: ", validate_activity_data(test_invalid_2))
# Should print: false
# Should show error: "APISimulator: Missing word.media"
```

3. **Test Invalid media structure**:
```gdscript
var test_invalid_3 = {
	"itemId": "test",
	"activityType": "connect_def",
	"word": {
		"wordId": "w1",
		"headword": "test",
		"definition": "test",
		"pos": "adjective",
		"media": [
			{
				"mediaId": "m1"
				# Missing: kind, url, role, orderNo
			}
		]
	},
	"params": {}
}
print("Test invalid media: ", validate_activity_data(test_invalid_3))
# Should print: false
# Should show error: "APISimulator: Media item missing kind"
```

4. **Test Headword visibility**:
```gdscript
var test_invalid_4 = {
	"itemId": "test",
	"activityType": "spell_typed",
	"word": {
		"wordId": "w1",
		"headword": "SHOULD_BE_EMPTY",  # Wrong!
		"definition": "test",
		"pos": "adjective",
		"media": []
	},
	"params": null
}
print("Test headword visibility: ", validate_activity_data(test_invalid_4))
# Should print: true (but with warning)
# Should show warning: "APISimulator: Headword should be hidden for spell_typed"
```

5. **Test null params for spell_typed**:
```gdscript
var test_invalid_5 = {
	"itemId": "test",
	"activityType": "spell_typed",
	"word": {
		"wordId": "w1",
		"headword": "",
		"definition": "test",
		"pos": "adjective",
		"media": []
	},
	"params": {"wrong": "data"}  # Should be null
}
print("Test spell_typed params: ", validate_activity_data(test_invalid_5))
# Should print: true (but with warning)
# Should show warning: "APISimulator: spell_typed should have null params"
```

6. **Test missing cueWord for sentence_typed_gen**:
```gdscript
var test_invalid_6 = {
	"itemId": "test",
	"activityType": "sentence_typed_gen",
	"word": {
		"wordId": "w1",
		"headword": "test",
		"definition": "test",
		"pos": "adjective",
		"media": []
	},
	"params": {}  # Missing cueWord
}
print("Test sentence_typed_gen: ", validate_activity_data(test_invalid_6))
# Should print: false
# Should show error: "APISimulator: sentence_typed_gen missing params.cueWord"
```

**After Testing**:
- Remove all test code
- Verify game still works normally

**Expected Results**:
- ✅ All validation errors caught correctly
- ✅ Appropriate error messages shown
- ✅ Function returns false for invalid data
- ✅ Function returns true for valid data

---

### Task 3.4: Test PR3 Changes - Integration Testing

**Testing Steps**:

1. **Full Cycle Test**
   - Start game fresh
   - Play through 50 activities (almost 2 full cycles)
   - Verify no validation errors
   - Verify cycling works correctly

2. **Stress Test - Rapid Clicking**
   - Click through activities as fast as possible
   - Should handle rapid requests without errors
   - Validation should not slow down game

3. **Check Console Logs**
   - No validation errors
   - No validation warnings (except for intentional test cases)
   - Clean initialization message

4. **Verify Each Activity Type One More Time**
   - Create checklist of all 9 types
   - Play until you've seen each type at least once
   - Check off each type as you verify it works

**Activity Type Verification Checklist**:
- [ ] flashcard_usage (indices 0-2) - Works correctly
- [ ] connect_def (indices 3-5) - Works correctly
- [ ] context_cloze (indices 6-8) - Works correctly
- [ ] select_usage (indices 9-11) - Works correctly
- [ ] synonym_mcq (indices 12-14) - Works correctly
- [ ] spell_typed (indices 15-17) - Works correctly
- [ ] definition_typed (indices 18-20) - Works correctly
- [ ] sentence_typed_gen (indices 21-23) - Works correctly
- [ ] paraphrase_typed_gen (indices 24-26) - Works correctly

**Expected Results**:
- ✅ Validation catches all errors correctly
- ✅ Validation doesn't block valid data
- ✅ No performance issues from validation
- ✅ All 9 activity types validate successfully
- ✅ Game plays smoothly through all activities

**PR3 Completion Checklist**:
- [ ] All 4 tasks completed
- [ ] All tests pass (valid and invalid data)
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] Validation working correctly
- [ ] All 9 activity types working
- [ ] Ready for code review

---

## Final Integration Testing

**After all 3 PRs are merged:**

### Final Test Suite

**Test 1: Clean Start**
- [ ] Fresh game start
- [ ] Console shows: "APISimulator: Initialized with 27 test entries (9 activity types × 3 each)"
- [ ] No errors or warnings

**Test 2: Complete Cycle**
- [ ] Play through all 27 activities
- [ ] Activity 28 is same as activity 1
- [ ] All activity types appear 3 times each

**Test 3: Data Structure Verification**
Add temporary verification code:
```gdscript
# In _initialize_test_data() after all entries created
print("=== FINAL VERIFICATION ===")
print("Total entries: ", test_data_entries.size())

var type_summary = {}
for entry in test_data_entries:
	var type = entry["activityType"]
	if not type_summary.has(type):
		type_summary[type] = []
	type_summary[type].append({
		"index": test_data_entries.find(entry),
		"headword_empty": entry["word"]["headword"].is_empty(),
		"media_count": entry["word"]["media"].size(),
		"params_null": entry["params"] == null
	})

for type in type_summary:
	print("Type: ", type)
	for info in type_summary[type]:
		print("  [", info["index"], "] headword_empty:", info["headword_empty"], 
		      " media:", info["media_count"], " params_null:", info["params_null"])
```

Expected output:
```
=== FINAL VERIFICATION ===
Total entries: 27
Type: flashcard_usage
  [0] headword_empty:false media:2 params_null:false
  [1] headword_empty:false media:2 params_null:false
  [2] headword_empty:false media:2 params_null:false
Type: connect_def
  [3] headword_empty:false media:2 params_null:false
  ...
Type: spell_typed
  [15] headword_empty:true media:2 params_null:true
  ...
```

Remove verification code after confirming.

**Test 4: Validation Check**
- [ ] All 27 entries pass validation
- [ ] No validation errors in console

**Test 5: Game Integration**
- [ ] Each activity type displays correctly
- [ ] No crashes or errors during gameplay
- [ ] Media URLs don't cause issues (even though fake)
- [ ] Headword hidden activities work correctly

**Test 6: Round-Robin Cycling**
- [ ] Activities cycle in correct order (0-26, then back to 0)
- [ ] No duplicates before full cycle complete
- [ ] Counter resets correctly

**Test 7: Performance**
- [ ] Initialization is fast (< 1 second)
- [ ] No lag when requesting next activity
- [ ] Memory usage reasonable

### Success Criteria (Final)

✅ **All PRs Merged Successfully**
- PR1: Helper functions and existing activity updates
- PR2: New activity types added
- PR3: Validation updated

✅ **Functionality Complete**
- 27 test entries generated
- 9 activity types (3 entries each)
- All data structures match activity_card_format.md
- Media arrays populated
- UUID-like IDs throughout
- Headword visibility rules enforced
- Activity-specific params correct

✅ **Quality Standards Met**
- No compilation errors
- No runtime errors
- No validation errors
- Clean console output
- Code is readable and well-commented

✅ **Testing Complete**
- Unit tests for each function
- Integration tests for data generation
- Validation tests (valid and invalid data)
- Full game playthrough test
- Stress test completed

✅ **Documentation Updated**
- Code comments accurate
- PRD matches implementation
- Task list completed
- All checklists verified

---

## Rollback Procedures

If issues are discovered after merging:

### Rollback PR3 Only
```bash
git revert <PR3-commit-hash>
```
- Reverts validation changes
- Keeps new activity types
- May show validation warnings but activities still work

### Rollback PR2 and PR3
```bash
git revert <PR3-commit-hash>
git revert <PR2-commit-hash>
```
- Reverts to 15 activity types (5 types × 3 each)
- Keeps helper functions and existing activity updates
- System fully functional with fewer activity types

### Rollback All Changes
```bash
git revert <PR3-commit-hash>
git revert <PR2-commit-hash>
git revert <PR1-commit-hash>
```
- OR restore from backup:
```bash
cp scripts/APISimulator.gd.backup scripts/APISimulator.gd
```
- Returns to original implementation

---

## Appendix: Quick Reference

### Activity Type Index Map
```
0-2:   flashcard_usage      (new, visible, sentence options)
3-5:   connect_def           (new, visible, word options)
6-8:   context_cloze         (new, visible, sentence + word options)
9-11:  select_usage          (new, visible, sentence options)
12-14: synonym_mcq           (review, visible, target + synonym options)
15-17: spell_typed           (new, HIDDEN, null)
18-20: definition_typed      (review, HIDDEN, null)
21-23: sentence_typed_gen    (review, visible, cue word)
24-26: paraphrase_typed_gen  (review, HIDDEN, null)
```

### Function Dependency Map
```
_initialize_test_data()
  ├── _generate_uuid_like()
  ├── _generate_media_array()
  │     └── _generate_uuid_like()
  ├── _generate_word_options()
  ├── _generate_sentence_options()
  │     └── _generate_uuid_like()
  ├── _generate_synonym_options()
  └── _select_cue_word()

request_next_activity()
  └── validate_activity_data()
```

### PR Dependency Chain
```
PR1 (Base) → PR2 (Depends on PR1) → PR3 (Depends on PR2)
```

### File Change Summary
```
scripts/APISimulator.gd
  - 3 new functions added
  - 2 functions updated
  - 1 function rewritten (_initialize_test_data)
  - 1 function replaced (validate_activity_data)
  - Total lines added: ~400
  - Total lines removed: ~150
  - Net change: ~250 lines
```

---

## Notes

- **Backup file**: Keep `scripts/APISimulator.gd.backup` until all PRs verified working
- **Testing between PRs**: Each PR should be tested independently before proceeding
- **Console output**: Monitor console for any errors or warnings during testing
- **Performance**: All changes should complete in < 1 second on initialization
- **Compatibility**: No changes to external API, only internal data generation
- **Vocabulary requirement**: Minimum 27 words needed (have 46 available)

---

**Document Version**: 1.0
**Last Updated**: Based on simulator_update_prd.md
**Total Estimated Time**: 3 hours (1 hour per PR)
**Risk Level**: Low (internal changes only, no API changes)

