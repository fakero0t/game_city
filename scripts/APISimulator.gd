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
	
	# Note: System will automatically cycle through words using modulo if fewer words available
	# No minimum word count required - words will be reused as needed
	
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

