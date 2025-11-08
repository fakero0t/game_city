extends Node
## APISimulator - Simulates API calls for activity data
## Provides test data in the format expected by the real API

# Test data storage
var test_data_entries: Array[Dictionary] = []
var current_test_index: int = 0
var api_delay_ms: int = 300  # Configurable delay to simulate network latency

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
	
	# Ensure we have enough words (need at least 15 for 3 entries × 5 types)
	if vocab_words.size() < 20:
		push_warning("APISimulator: Limited vocabulary data, some words will repeat")
	
	# Generate 3 test entries for each activity type (15 total)
	
	# 1. connect_def (indices 0-2) - Word Matching game
	for i in range(3):
		var word = vocab_words[i % vocab_words.size()]
		var entry = {
			"itemId": "test-item-%03d" % item_counter,
			"activityType": "connect_def",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": "word-%03d" % item_counter,
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": []
			},
			"params": {
				"options": _generate_word_options(word["word"], vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# 2. context_cloze (indices 3-5) - Fill in Blank game
	for i in range(3):
		var word = vocab_words[(i + 3) % vocab_words.size()]
		var sentence = word["example_sentence"]
		var entry = {
			"itemId": "test-item-%03d" % item_counter,
			"activityType": "context_cloze",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": "word-%03d" % item_counter,
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": []
			},
			"params": {
				"sentence": sentence,
				"options": _generate_word_options(word["word"], vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# 3. select_usage (indices 6-8) - Multiple Choice with sentences
	for i in range(3):
		var word = vocab_words[(i + 6) % vocab_words.size()]
		var entry = {
			"itemId": "test-item-%03d" % item_counter,
			"activityType": "select_usage",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": "word-%03d" % item_counter,
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": []
			},
			"params": {
				"options": _generate_sentence_options(word, vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# 4. synonym_mcq (indices 9-11) - Synonym/Antonym game
	for i in range(3):
		var word = vocab_words[(i + 9) % vocab_words.size()]
		var entry = {
			"itemId": "test-item-%03d" % item_counter,
			"activityType": "synonym_mcq",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": "word-%03d" % item_counter,
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": []
			},
			"params": {
				"targetWord": {
					"wordId": "target-%03d" % item_counter,
					"headword": word["synonyms"][0]
				},
				"options": _generate_synonym_options(word)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	# 5. flashcard_usage (indices 12-14) - Memory/Flashcard game
	for i in range(3):
		var word = vocab_words[(i + 12) % vocab_words.size()]
		var entry = {
			"itemId": "test-item-%03d" % item_counter,
			"activityType": "flashcard_usage",
			"phase": "new",
			"phaseProgress": {"current": i + 1, "total": 3},
			"word": {
				"wordId": "word-%03d" % item_counter,
				"headword": word["word"],
				"definition": word["definition"],
				"pos": "adjective",
				"media": []
			},
			"params": {
				"options": _generate_sentence_options(word, vocab_words)
			}
		}
		test_data_entries.append(entry)
		item_counter += 1
	
	print("APISimulator: Initialized with ", test_data_entries.size(), " test entries")

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

