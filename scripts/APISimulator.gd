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
	
	# Round-robin selection (cycles through test data indefinitely)
	var selected_data = test_data_entries[current_test_index].duplicate(true)  # Deep copy
	current_test_index = (current_test_index + 1) % test_data_entries.size()
	
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

## Check if test data is exhausted (always false, since we cycle indefinitely)
func is_test_data_exhausted() -> bool:
	return false

## Initialize test data from vocabulary
func _initialize_test_data() -> void:
	# Get vocabulary words from VocabularyManager
	var vocab_words = VocabularyManager.get_all_words()
	if vocab_words.is_empty():
		push_error("APISimulator: No vocabulary data available")
		return
	
	var item_counter = 1
	
	# Note: Creating 1 entry per activity type for easy testing/cycling
	# Each "Next" click will show a different activity type, then cycle through all 4
	
	# ========== ACTIVITY TYPE 1: context_cloze (FillInBlank - Space Invaders) (FIRST) ==========
	var word = vocab_words[0 % vocab_words.size()]
	var sentence = word["example_sentence"]
	var entry = {
		"itemId": _generate_uuid_like("item"),
		"activityType": "context_cloze",
		"phase": "new",
		"phaseProgress": {"current": 1, "total": 1},
		"word": {
			"wordId": _generate_uuid_like("word"),
			"headword": word["word"],
			"definition": word["definition"],
			"pos": "adjective",
			"media": _generate_media_array(word["word"], "word-%03d" % item_counter, true)
		},
		"params": {
			"sentence": sentence,
			"options": _generate_word_options(word["word"], vocab_words)
		}
	}
	test_data_entries.append(entry)
	item_counter += 1
	
	# ========== ACTIVITY TYPE 2: synonym_mcq ==========
	word = vocab_words[1 % vocab_words.size()]
	entry = {
		"itemId": _generate_uuid_like("item"),
		"activityType": "synonym_mcq",
		"phase": "review",
		"phaseProgress": {"current": 1, "total": 1},
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
	
	# ========== ACTIVITY TYPE 3: flashcard_usage ==========
	word = vocab_words[2 % vocab_words.size()]
	entry = {
		"itemId": _generate_uuid_like("item"),
		"activityType": "flashcard_usage",
		"phase": "new",
		"phaseProgress": {"current": 1, "total": 1},
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
	
	# ========== ACTIVITY TYPE 4: connect_def ==========
	word = vocab_words[3 % vocab_words.size()]
	entry = {
		"itemId": _generate_uuid_like("item"),
		"activityType": "connect_def",
		"phase": "new",
		"phaseProgress": {"current": 1, "total": 1},
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
	
	print("APISimulator: Initialized with ", test_data_entries.size(), " test entries (4 activity types, 1 per type for testing)")

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

