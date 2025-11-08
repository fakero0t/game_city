extends Node
## VocabularyManager - Singleton for vocabulary data management
## Loads vocabulary.json and provides word data to all games

# Vocabulary data
var all_words: Array = []
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

# Get random words (no usage tracking)
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

# Get specific word data by word string
func get_word_data(word_string: String) -> Dictionary:
	for word in all_words:
		if word["word"] == word_string:
			return word
	return {}

# Get random definitions as distractors (excluding specific word)
func get_random_definitions(exclude_word: String, count: int) -> Array:
	var definitions = []
	for word in all_words:
		if word["word"] != exclude_word:
			definitions.append(word["definition"])
	
	definitions.shuffle()
	return definitions.slice(0, count)

# Get random words (not definitions) as distractors
func get_random_word_strings(exclude_word: String, count: int) -> Array:
	var words = []
	for word in all_words:
		if word["word"] != exclude_word:
			words.append(word["word"])
	
	words.shuffle()
	return words.slice(0, count)

# Get all words (for debugging)
func get_all_words() -> Array:
	return all_words

# Check if vocabulary is loaded and valid
func is_vocabulary_ready() -> bool:
	return vocabulary_loaded

# Get load error message
func get_load_error() -> String:
	return load_error
