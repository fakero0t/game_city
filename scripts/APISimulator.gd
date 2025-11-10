extends Node
## APISimulator - Simulates API calls for activity data
## Provides test data in the format expected by the real API

# Test data storage
var test_data_entries: Array[Dictionary] = []
var current_test_index: int = 0
var api_delay_ms: int = 300  # Configurable delay to simulate network latency

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

func _ready() -> void:
	_initialize_test_data()

## Add a single test data entry
func add_test_data(activity_data: Dictionary) -> void:
	test_data_entries.append(activity_data)

## Clear all test data
func clear_test_data() -> void:
	test_data_entries.clear()
	current_test_index = 0

## Reset test data index (allows cycling through words again)
func reset_progress() -> void:
	current_test_index = 0
	print("APISimulator: Progress reset - starting from beginning")

## Get all test data entries
func get_test_data() -> Array:
	return test_data_entries

## Request next activity (async to simulate API call)
func request_next_activity(session_id: String) -> Dictionary:
	# Simulate network delay
	await get_tree().create_timer(api_delay_ms / 1000.0).timeout
	
	# Check if test data available
	if test_data_entries.is_empty():
		push_error("APISimulator: No test data available")
		return {}
	
	# Check if we've exhausted all words
	if current_test_index >= test_data_entries.size():
		print("APISimulator: All words have been completed!")
		return {}
	
	# Get next entry (sequential, no cycling)
	var selected_data = test_data_entries[current_test_index].duplicate(true)  # Deep copy
	current_test_index += 1
	
	# Validate before returning
	if not validate_activity_data(selected_data):
		push_error("APISimulator: Invalid activity data structure")
		return {}
	
	return selected_data

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
	
	# Validate headword
	if not word.has("headword"):
		push_error("APISimulator: Missing word.headword")
		return false
	
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
	if activity_type == "flashcard_usage":
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
	
	return true

## Check if test data is exhausted (all words have been shown)
func is_test_data_exhausted() -> bool:
	return current_test_index >= test_data_entries.size()

## Get total number of activities
func get_total_activities() -> int:
	return test_data_entries.size()

## Get current activity number (1-indexed)
func get_current_activity_number() -> int:
	return current_test_index

## Initialize test data from vocabulary
func _initialize_test_data() -> void:
	# Get vocabulary words from VocabularyManager
	var vocab_words = VocabularyManager.get_all_words()
	if vocab_words.is_empty():
		push_error("APISimulator: No vocabulary data available")
		return
	
	# Activity types to cycle through
	var activity_types = ["flashcard_usage", "context_cloze", "connect_def", "synonym_mcq"]
	
	var item_counter = 1
	var used_words = {}  # Track which words have been used
	var activity_index = 0  # Track which activity type to use
	
	# Create entries for all vocabulary words, cycling through activity types
	for word in vocab_words:
		var word_key = word["word"]
		
		# Skip if word already used (should not happen with deduplicated vocab, but double-check)
		if used_words.has(word_key):
			print("APISimulator: WARNING - Skipping duplicate word in test data generation: ", word_key)
			continue
		
		# Mark word as used
		used_words[word_key] = true
		
		# Get current activity type and cycle to next
		var activity_type = activity_types[activity_index]
		activity_index = (activity_index + 1) % activity_types.size()
		
		# Calculate progress
		var progress_total = vocab_words.size()
		var progress_current = item_counter
		
		# Create entry based on activity type
		var entry: Dictionary = {}
		
		match activity_type:
			"flashcard_usage":
				entry = _create_flashcard_entry(word, vocab_words, item_counter, progress_current, progress_total)
			"context_cloze":
				entry = _create_context_cloze_entry(word, vocab_words, item_counter, progress_current, progress_total)
			"connect_def":
				entry = _create_connect_def_entry(word, vocab_words, item_counter, progress_current, progress_total)
			"synonym_mcq":
				entry = _create_synonym_mcq_entry(word, vocab_words, item_counter, progress_current, progress_total)
		
		test_data_entries.append(entry)
		item_counter += 1
	
	# Verify no duplicate words in final test data
	var final_check = {}
	var duplicates_found = false
	for entry in test_data_entries:
		var word_text = entry.get("word", {}).get("headword", "")
		if final_check.has(word_text):
			print("APISimulator: ERROR - Duplicate found in final test data: ", word_text)
			duplicates_found = true
		final_check[word_text] = true
	
	if duplicates_found:
		push_error("APISimulator: Duplicates detected in test data!")
	else:
		print("APISimulator: Initialized with ", test_data_entries.size(), " unique test entries across ", activity_types.size(), " activity types (no duplicates)")

## Create flashcard_usage entry
func _create_flashcard_entry(word: Dictionary, vocab_words: Array, item_counter: int, progress_current: int, progress_total: int) -> Dictionary:
	return {
		"itemId": _generate_uuid_like("item"),
		"activityType": "flashcard_usage",
		"phase": "new",
		"phaseProgress": {"current": progress_current, "total": progress_total},
		"word": {
			"wordId": _generate_uuid_like("word"),
			"headword": word["word"],
			"definition": word["definition"],
			"exampleSentence": word["example_sentence"],
			"pos": "adjective",
			"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
		},
		"params": {
			"options": _generate_sentence_options(word, vocab_words)
		}
	}

## Create context_cloze entry
func _create_context_cloze_entry(word: Dictionary, vocab_words: Array, item_counter: int, progress_current: int, progress_total: int) -> Dictionary:
	return {
		"itemId": _generate_uuid_like("item"),
		"activityType": "context_cloze",
		"phase": "new",
		"phaseProgress": {"current": progress_current, "total": progress_total},
		"word": {
			"wordId": _generate_uuid_like("word"),
			"headword": word["word"],
			"definition": word["definition"],
			"pos": "adjective",
			"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
		},
		"params": {
			"sentence": word["example_sentence"],
			"options": _generate_word_options(word["word"], vocab_words)
		}
	}

## Create connect_def entry
func _create_connect_def_entry(word: Dictionary, vocab_words: Array, item_counter: int, progress_current: int, progress_total: int) -> Dictionary:
	return {
		"itemId": _generate_uuid_like("item"),
		"activityType": "connect_def",
		"phase": "new",
		"phaseProgress": {"current": progress_current, "total": progress_total},
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

## Create synonym_mcq entry
func _create_synonym_mcq_entry(word: Dictionary, vocab_words: Array, item_counter: int, progress_current: int, progress_total: int) -> Dictionary:
	return {
		"itemId": _generate_uuid_like("item"),
		"activityType": "synonym_mcq",
		"phase": "review",
		"phaseProgress": {"current": progress_current, "total": progress_total},
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

## Generate sentence options for flashcard_usage (array of {exampleId, text})
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

## Generate synonym options for synonym_mcq (array of {headword})
## Creates 1 synonym (correct answer) and 3 antonyms (distractors)
func _generate_synonym_options(word_data: Dictionary) -> Array:
	var options = []
	var synonyms = word_data["synonyms"]
	var antonyms = word_data["antonyms"]
	
	# Add 1 synonym (the correct answer - same as targetWord)
	options.append({
		"headword": synonyms[0]  # This matches the targetWord
	})
	
	# Add 3 antonyms as distractors
	for i in range(min(3, antonyms.size())):
		options.append({
			"headword": antonyms[i]
		})
	
	options.shuffle()
	return options

